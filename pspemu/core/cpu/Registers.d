module pspemu.core.cpu.Registers;

import std.stdio, std.string, std.bitmanip;

version = VERSION_R0_CHECK;

final class Registers {
//struct Registers {
	protected __gshared int[string] aliases;
	protected __gshared const auto aliasesInv = [
		"zr", "at", "v0", "v1", "a0", "a1", "a2", "a3",
		"t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7",
		"s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7",
		"t8", "t9", "k0", "k1", "gp", "sp", "fp", "ra"
	];
	
	static struct Fcr0 { // readonly
		union {
			uint VALUE;
			struct {
				ubyte REV;
				ubyte IMP;
				ubyte[2] UNK;
			}
		}
		static assert (this.sizeof == 4);
	}
	
	static struct Fcr31 {
		enum Type : uint { Rint = 0, Cast = 1, Ceil = 2, Floor = 3 }
		union {
			uint VALUE;

			struct { mixin(bitfields!(
				// 0b_0000000_1_1_000000000000000000000_11
				Type, "RM", 2,
				uint, "",   21,
				bool, "C" , 1,
				bool, "FS", 1,
				uint, "",   7
			)); }
		}
		static assert (this.sizeof == 4);
	}

	uint EXECUTED_INSTRUCTION_COUNT_THIS_THREAD;
	//uint EXECUTED_SYSCALL_COUNT_THIS_THREAD;
	bool PAUSED;
	uint PC, nPC;    // Program Counter
	uint IC;         // Interrupt controller
	Fcr0  FCR0; // readonly?
	Fcr31 FCR31;
	uint[1024] CallStack;
	int CallStackPos;
	
	uint[] RealCallStack() {
		return CallStack[0..CallStackPos];
	}
	
	void CallStackPush() {
		if (CallStackPos < CallStack.length - 1) {
			CallStack[CallStackPos] = PC;
		}
		CallStackPos++;
	}
	
	void CallStackPop() {
		if (CallStackPos > 0) CallStackPos--;
	}
	
	union {
		uint[32] R;      // GPR | General Purpose Registers
		struct {
		    //   +00 +01 +02 +03 +04 +05  +06 +07
			uint _ZR, AT, V0, V1, A0, A1,  A2, A3; // +00
			uint  T0, T1, T2, T3, T4, T5,  T6, T7; // +08
			uint  S0, S1, S2, S3, S4, S5,  S6, S7; // +16
			uint  T8, T9, K0, K1, GP, SP, _FP, RA; // +24
		}
	}
	union {
		struct { uint LO, HI; }  // HIgh, LOw for multiplications and divisions.
		ulong HILO;
	}
	uint CMP[2]; // Used for dynarec.
	uint CLOCKS;
	union { uint[32] RF; float[32] F; } // Floating point registers.
	union {
		struct { float[8 * 4 * 4] VF;        } // cells
		struct { float[8][4 * 4]  VF_MATRIX; } // matrix,cell
		struct { float[8][4][4]   VF_CELLS ; } // matrix,column,row
	}
	//bool VF_CC[8];
	bool VF_CC[6];

	struct VfpuPrefix {
		/*
		op VPFXS(110111:00:----:negw:negz:negy:negx:cstw:cstz:csty:cstx:absw:absz:absy:absx:swzw:swzz:swzy:swzx)
		op VPFXT(110111:01:----:negw:negz:negy:negx:cstw:cstz:csty:cstx:absw:absz:absy:absx:swzw:swzz:swzy:swzx)
		negw:1; negz:1; negy:1; negx:1;
		cstw:1; cstz:1; csty:1; cstx:1;
		absw:1; absz:1; absy:1; absx:1;
		swzw:2; swzz:2; swzy:2; swzx:2;

		op VPFXD(110111:10:------------:mskw:mskz:msky:mskx:satw:satz:saty:satx)
		mskw:1; mskz:1; msky:1; mskx:1;
		satw:2; satz:2; saty:2; satx:2;
		*/
		uint value = 0;
		bool enabled = false;
		
		template PrefixSrc() {
			int index(int i) { // swz(xyzw)
				assert(i >= 0 && i < 4);
				return (value >> (0 + i * 2)) & 3;
			}

			bool absolute(int i) { // abs(xyzw)
				assert(i >= 0 && i < 4);
				return (value >> (8 + i * 1)) & 1;
			}

			bool constant(int i) { // cst(xyzw)
				assert(i >= 0 && i < 4);
				return (value >> (12 + i * 1)) & 1;
			}
			
			bool negate(int i) { // neg(xyzw)
				assert(i >= 0 && i < 4);
				return (value >> (16 + i * 1)) & 1;
			}
		}

		template PrefixDst() {
			int saturation(int i) { // sat(xyzw)
				assert(i >= 0 && i < 4);
				return (value >> (0 + i * 2)) & 3;
			}

			bool mask(int i) { // msk(xyzw)
				assert(i >= 0 && i < 4);
				return (value >> (8 + i * 1)) & 1;
			}
		}
		
		mixin PrefixSrc;
		mixin PrefixDst;
	}

	union {
		struct { VfpuPrefix vfpu_prefix_s, vfpu_prefix_t, vfpu_prefix_d; }
		struct { VfpuPrefix[3] vfpu_prefixes; }
	}

	static class FP {
		protected __gshared int[string] aliases;

		static this() {
			foreach (n; 0..32) {
				aliases[format("$f%d", n)] = n;
				aliases[format("f%d", n)] = n;
			}
			aliases = aliases.rehash;
		}

		static int getAlias(string aliasName) {
			assert((aliasName in aliases) !is null, std.string.format("Unknown register alias '%s'", aliasName));
			return aliases[aliasName];
		}
	}

	void copyFrom(Registers that) {
		//writefln("registers: v0 <- %08X : PC <- %08X", that.V0, that.PC);
		this.PC     = that.PC;
		this.nPC    = that.nPC;
		this.HILO   = that.HILO;
		this.IC     = that.IC;
		this.PAUSED = that.PAUSED;
		this.FCR0   = that.FCR0;
		this.FCR31  = that.FCR31;
		this.R []   = that.R [];
		this.RF[]   = that.RF[];
		this.CMP[]  = that.CMP[];
		this.CLOCKS = that.CLOCKS;

		/*
		if (that.CallStack.length) {
			this.CallStack = that.CallStack.dup;
		} else {
			this.CallStack = [];
		}
		*/
	}
	
	void copyFromVFPU(Registers that) {
		this.VF[]  = that.VF[]; // Only if preserved!
		this.vfpu_prefixes[] = that.vfpu_prefixes[];
	}

	static this() {
		aliases["zero"] = 0;
		foreach (n; 0..32) aliases[format("r%d", n)] = aliases[format("$%d", n)] = n;
		foreach (n, name; aliasesInv) aliases[name] = n;
		aliases = aliases.rehash;
	}

	void reset() {
		EXECUTED_INSTRUCTION_COUNT_THIS_THREAD = 0;
		EXECUTED_SYSCALL_COUNT_THIS_THREAD = 0;
		PAUSED = false;
		PC = 0; nPC = 4;
		IC = 0;
		R[0..$] = 0;
		F[0..$] = 0.0;
		VF[0..$] = 0.0;
		vfpu_prefixes[0..3] = VfpuPrefix.init;
		FCR0 = FCR0.init;
		FCR31 = FCR31.init;
		CallStack[] = 0;
		CallStackPos = 0;
	}

	uint opIndex(uint   index) { return R[index]; }
	uint opIndex(string index) { return this[getAlias(index)]; }

	uint opIndexAssign(uint value, uint index) {
		R[index] = value;
		version (VERSION_R0_CHECK) if (index == 0) R[index] = 0;
		return R[index];
	}
	
	uint opIndexAssign(uint value, string index) {
		return this[getAlias(index)] = value;
	}

	static int getAlias(string aliasName) {
		assert(aliasName in aliases, format("Unknown register alias '%s'", aliasName));
		return aliases[aliasName];
	}

	/**
	 * Executes a block of code restoring registers.
	 *
	 * @params  callback  - Delegate to execute.
	 */
	void restoreBlock(void delegate() callback) {
		synchronized (this) {
			scope Registers thisBackup = new Registers();
			thisBackup.copyFrom(this);
			scope (exit) this.copyFrom(thisBackup);

			callback();
		}
	}


	void pcAdvance(int offset = 4) { PC = nPC; nPC += offset; }
	void pcSet(uint address) { PC  = address; nPC = PC + 4; }
	
	void dump2() {
		synchronized (this) {
	    	//.,writefln();
	    	.writefln("REGISTERS:");
	    	foreach (k, value; registers.R) {
	    		//.writef("   r%2d: %08X", k, value);
	    		.writef("   %s: %08X", Registers.aliasesInv[k], value);
	    		if ((k % 4) == 3) .writefln("");
	    	}
	    	.writefln("   pc: %08X", registers.PC);
	    }
	}

	void dump(bool reduced = true) {
		synchronized (this) {
			writefln("Registers {");
			writef("  PC = 0x%08X | nPC = 0x%08X", PC, nPC);
			writef("  LO = 0x%08X | HI  = 0x%08X", LO, HI );
			writef("  IC = 0x%08X", IC);
			writefln("");
			int count, columns = 4;
			
			count = 0;
			foreach (k, v; R) {
				if (reduced && (v == 0)) continue;
				writef("  r%-2d = 0x%08X (%s)", k, v, aliasesInv[k]);
				if ((count++ % columns) == (columns - 1)) writefln("");
			}
			if (count != 0) writefln("");
			writefln("}");
			writefln("Float registers {");
			count = 0;
			foreach (k, v; F) {
				if (reduced && (v == 0.0)) continue;
				writefln("  f%-2d = %f | 0x%08X", k, v, RF[k]);
				if ((count++ % columns) == (columns - 1)) writefln("");
			}
			if (count != 0) writefln("");
			writefln("}");
		}
	}
	
	void vfpu_dump() {
		for (int matrix = 0; matrix < 8; matrix++) {
			writefln("MATRIX(%d):", matrix);
			for (int column = 0; column < 4; column++) { 
				for (int row = 0; row < 4; row++) {
					writef("%.8f ", VF_CELLS[matrix][column][row]); 
				}
				writefln("");
			}
			writefln("");
		}
	}
}
