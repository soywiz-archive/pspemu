module pspemu.core.cpu.Registers;

import std.stdio, std.string;

version = VERSION_R0_CHECK;

final class Registers {
	protected static int[string] aliases;
	protected static const auto aliasesInv = [
		"zr", "at", "v0", "v1", "a0", "a1", "a2", "a3",
		"t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7",
		"s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7",
		"t8", "t9", "k0", "k1", "gp", "sp", "fp", "ra"
	];
	enum Fcsr { Rint = 0, Cast, Ceil, Floor }

	bool PAUSED;
	uint PC, nPC;    // Program Counter
	uint IC;         // Interrupt controller
	Fcsr FCSR;       // Floating point Control / Status register
	bool CC;         // Control Word (Floating point? C1)
	uint CLOCKS;
	uint[] CallStack;
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
	union { uint[32] RF; float[32] F; } // Floating point registers.
	union {
		struct { float[4 * 4 * 8] VF; }
		struct { float[4 * 4][8]  VF_MATRIX; }
	}

	static class FP {
		protected static int[string] aliases;

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
		this.PC   = that.PC;
		this.nPC  = that.nPC;
		this.HILO = that.HILO;
		this.IC   = that.IC;
		this.FCSR = that.FCSR;
		this.CC   = that.CC;
		this.R [] = that.R [];
		this.RF[] = that.RF[];
		this.CLOCKS   = that.CLOCKS;
		if (that.CallStack.length) {
			this.CallStack = that.CallStack.dup;
		} else {
			this.CallStack = [];
		}
	}

	static this() {
		aliases["zero"] = 0;
		foreach (n; 0..32) aliases[format("r%d", n)] = aliases[format("$%d", n)] = n;
		foreach (n, name; aliasesInv) aliases[name] = n;
		aliases = aliases.rehash;
	}

	void reset() {
		PC = 0; nPC = 4;
		R[0..$] = 0;
		F[0..$] = 0.0;
		//D[0..$] = 0.0;
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


	void pcAdvance(int offset = 4) { PC = nPC; nPC += offset; }
	void pcSet(uint address) { PC  = address; nPC = PC + 4; }

	void dump(bool reduced = true) {
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

version (Unittest):

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope registers = new Registers();

	// Set all the integer registers expect the 0.
	foreach (n; 1 .. 32) {
		registers[n] = n;
		assert(registers[n] == n);
	}

	// Check setting register 0.
	version (VERSION_R0_CHECK) {
		registers[0] = 1;
		assert(registers[0] == 0);
	} else {
		registers[0] = 1;
		assert(registers[0] == 1);
	}

	// Check PC set and increment.
	registers.pcSet(0x1000);
	assert(registers.PC == 0x1000);
	assert(registers.nPC == 0x1004);

	registers.pcAdvance(4);
	assert(registers.PC == 0x1004);
	assert(registers.nPC == 0x1008);
}
