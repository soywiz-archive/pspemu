module pspemu.core.cpu.interpreter.ops.Cpu_Alu;

import pspemu.core.cpu.interpreter.Utils;

alias CpuExpression CE;

//version = VERSION_SHIFT_ASM;

// http://pspemu.googlecode.com/svn/branches/old/src/core/cpu.d
// http://pspemu.googlecode.com/svn/branches/old/util/gen/impl/SPECIAL
// http://pspemu.googlecode.com/svn/branches/old/util/gen/impl/MISC
template TemplateCpu_ALU() {
	mixin TemplateCpu_ALU_Utils;

	// $ = unsigned
	// # = signed

	// ADD(U) -- Add (Unsigned)
	// Adds two registers and stores the result in a register
	// $d = $s + $t; advance_pc (4);
	void OP_ADD () { mixin(CE("$rd = #rs + #rt;")); }
	void OP_ADDU() { mixin(CE("$rd = $rs + $rt;")); }
	void OP_SUB () { mixin(CE("$rd = #rs - #rt;")); }
	void OP_SUBU() { mixin(CE("$rd = $rs - $rt;")); }

	// TODO: Check std.intrinsic
	// Count Leading Ones in Word
	void OP_CLO() { mixin(CE("$rd = CLO($rs);")); }
	// Count Leading Zeros in Word
	void OP_CLZ() { mixin(CE("$rd = CLZ($rs);")); }

	// ADDI(U) -- Add immediate (Unsigned)
	// Adds a register and a signed immediate value and stores the result in a register
	// $t = $s + imm; advance_pc (4);
	void OP_ADDI () { mixin(CE("$rt = #rs + #im;")); }
	void OP_ADDIU() { mixin(CE("$rt = $rs + #im;")); }

	// AND -- Bitwise and
	// Bitwise ands two registers and stores the result in a register
	// $d = $s & $t; advance_pc (4);
	void OP_AND() { mixin(CE("$rd = $rs & $rt;")); }
	void OP_OR () { mixin(CE("$rd = $rs | $rt;")); }
	void OP_XOR() { mixin(CE("$rd = $rs ^ $rt;")); }
	void OP_NOR() { mixin(CE("$rd = ~($rs | $rt);")); }

	// MOVZ -- MOV If Zero?
	// MOVN -- MOV If Non Zero?
	void OP_MOVZ() { mixin(CE("if ($rt == 0) $rd = $rs;")); }
	void OP_MOVN() { mixin(CE("if ($rt != 0) $rd = $rs;")); }

	// ANDI -- Bitwise and immediate
	// ORI -- Bitwise and immediate
	// Bitwise ands a register and an immediate value and stores the result in a register
	// $t = $s & imm; advance_pc (4);
	void OP_ANDI() { mixin(CE("$rt = $rs & $im;")); }
	void OP_ORI () { mixin(CE("$rt = $rs | $im;")); }
	void OP_XORI() { mixin(CE("$rt = $rs ^ $im;")); }

	// SLT(I)(U)  -- Set Less Than (Immediate) (Unsigned)
	void OP_SLT  () { mixin(CE("$rd = #rs < #rt;")); }
	void OP_SLTU () { mixin(CE("$rd = $rs < $rt;")); }
	void OP_SLTI () { mixin(CE("$rt = #rs < #im;")); }
	void OP_SLTIU() { mixin(CE("$rt = $rs < cast(uint)#im;")); }

	// LUI -- Load upper immediate
	// The immediate value is shifted left 16 bits and stored in the register. The lower 16 bits are zeroes.
	// $t = (imm << 16); advance_pc (4);
	void OP_LUI() { mixin(CE("$rt = (#im << 16);")); }

	// SEB - Sign Extension Byte
	// SEH - Sign Extension Half
	void OP_SEB() { mixin(CE("$rd = SEB(cast(ubyte )$rt);")); }
	void OP_SEH() { mixin(CE("$rd = SEH(cast(ushort)$rt);")); }

	// ROTR  -- Rotate Word Right
	// ROTRV -- Rotate Word Right Variable
	void OP_ROTR () { mixin(CE("$rd = ROTR($rt, $ps);")); }
	void OP_ROTRV() { mixin(CE("$rd = ROTR($rt, $rs);")); }

	// SLL(V) - Shift Word Left Logical (Variable)
	// SRA(V) - Shift Word Right Arithmetic (Variable)
	// SRL(V) - Shift Word Right Logic (Variable)
	void OP_SLL () { mixin(CE("$rd = SLL($rt, $ps);")); }
	void OP_SLLV() { mixin(CE("$rd = SLL($rt, $rs);")); }
	void OP_SRA () { mixin(CE("$rd = SRA($rt, $ps);")); }
	void OP_SRAV() { mixin(CE("$rd = SRA($rt, $rs);")); }
	void OP_SRL () { mixin(CE("$rd = SRL($rt, $ps);")); }
	void OP_SRLV() { mixin(CE("$rd = SRL($rt, $rs);")); }

	// EXT -- EXTract
	// INS -- INSert
	void OP_EXT() { mixin(CE("EXT($rt, $rs, $ps, $ne);")); }
	void OP_INS() { mixin(CE("INS($rt, $rs, $ps, $ni);")); }

	// BITREV - Bit Reverse
	void OP_BITREV() { mixin(CE("$rd = REV32($rt);")); }

	// MAX/MIN
	void OP_MAX() { mixin(CE("$rd = MAX(#rs, #rt);")); }
	void OP_MIN() { mixin(CE("$rd = MIN(#rs, #rt);")); }

	// DIV -- Divide
	// DIVU -- Divide Unsigned
	// Divides $s by $t and stores the quotient in $LO and the remainder in $HI
	// $LO = $s / $t; $HI = $s % $t; advance_pc (4);
	void OP_DIV () { mixin(CE("$lo = #rs / #rt; $hi = #rs % #rt;")); }
	void OP_DIVU() { mixin(CE("$lo = $rs / $rt; $hi = $rs % $rt;")); }

	// MULT/MADD/MSUB    -- Multiply
	void OP_MULT () { mixin(CE("$hl  = cast(long)#rs * cast(long)#rt;")); }
	void OP_MADD () { mixin(CE("$hl += cast(long)#rs * cast(long)#rt;")); }
	void OP_MSUB () { mixin(CE("$hl -= cast(long)#rs * cast(long)#rt;")); }

	// MULTU/MADDU/MSUBU -- Multiply unsigned
	void OP_MULTU() { mixin(CE("$hl  = cast(ulong)$rs * cast(ulong)$rt;")); }
	void OP_MADDU() { mixin(CE("$hl += cast(ulong)$rs * cast(ulong)$rt;")); }
	void OP_MSUBU() { mixin(CE("$hl -= cast(ulong)$rs * cast(ulong)$rt;")); }

	// MFHI/MFLO -- Move from HI/LO
	// MTHI/MTLO -- Move to HI/LO
	void OP_MFHI() { mixin(CE("$rd = $hi;")); }
	void OP_MFLO() { mixin(CE("$rd = $lo;")); }
	void OP_MTHI() { mixin(CE("$hi = $rs;")); }
	void OP_MTLO() { mixin(CE("$lo = $rs;")); }

	// WSBH -- Word Swap Bytes Within Halfwords
	// WSBW -- Word Swap Bytes Within Words?? // FIXME! Not sure about this!
	void OP_WSBH() { mixin(CE("$rd = WSBH($rt);")); }
	void OP_WSBW() { mixin(CE("$rd = WSBW($rt);")); }
}

template TemplateCpu_ALU_Utils() {
	static final {
		int MASK(uint bits) { return ((1 << cast(ubyte)bits) - 1); }

		version (VERSION_SHIFT_ASM) {
			uint SEB(ubyte  r0) { uint r1; asm { xor EAX, EAX; mov AL, r0; movsx EBX, AL; mov r1, EBX; } return r1; }
			uint SEH(ushort r0) { uint r1; asm { xor EAX, EAX; mov AX, r0; movsx EBX, AX; mov r1, EBX; } return r1; }
			uint SLA(int a, int b) { asm { mov EAX, a; mov ECX, b; sal EAX, CL; mov a, EAX; } return a; }
			uint SLL(int a, int b) { asm { mov EAX, a; mov ECX, b; shl EAX, CL; mov a, EAX; } return a; }
			uint SRA(int a, int b) { asm { mov EAX, a; mov ECX, b; sar EAX, CL; mov a, EAX; } return a; }
			uint SRL(int a, int b) { asm { mov EAX, a; mov ECX, b; shr EAX, CL; mov a, EAX; } return a; }
			uint ROTR(uint a, uint b) { b = (b & 0x1F); asm { mov EAX, a; mov ECX, b; ror EAX, CL; mov a, EAX; } return a; }
		} else {
			int  SEB(byte  a) { return a; }
			int  SEH(short a) { return a; }
			uint SLL(int a, int b) { return a << b; }
			uint SRA(int a, int b) { return a >> b; }
			uint SRL(int a, int b) { return a >>> b; }
			version (all) {
				uint ROTR(uint a, uint b) { b = (b & 0x1F); asm { mov EAX, a; mov ECX, b; ror EAX, CL; mov a, EAX; } return a; }
			} else {
				uint ROTR(uint a, uint b) { b &= 0x1F; return (a >>> b) | ((a & MASK(b)) << (32 - b)); }
			}
		}

		// http://www-graphics.stanford.edu/~seander/bithacks.html#BitReverseObvious
		uint REV32(uint v) {
			v = ((v >> 1) & 0x55555555) | ((v & 0x55555555) << 1 ); // swap odd and even bits
			v = ((v >> 2) & 0x33333333) | ((v & 0x33333333) << 2 ); // swap consecutive pairs
			v = ((v >> 4) & 0x0F0F0F0F) | ((v & 0x0F0F0F0F) << 4 ); // swap nibbles ... 
			v = ((v >> 8) & 0x00FF00FF) | ((v & 0x00FF00FF) << 8 ); // swap bytes
			v = ( v >> 16             ) | ( v               << 16); // swap 2-byte long pairs
			return v;
		}
		T MAX(T)(T a, T b) { return (a > b) ? a : b; }
		T MIN(T)(T a, T b) { return (a < b) ? a : b; }
		uint WSBH(uint v) { return ((v & 0x_FF00_FF00) >> 8) | ((v & 0x_00FF_00FF) << 8); } // swap bytes
		uint WSBW(uint v) {
			if (1) {
				static struct UINT { union { uint i; ubyte[4] b; } }
				UINT vs = void, vd = void; vs.i = v;
				vd.b[0] = vs.b[3];
				vd.b[1] = vs.b[2];
				vd.b[2] = vs.b[1];
				vd.b[3] = vs.b[0];
				return vd.i;
			} else {
				// CHECK?
				return std.intrinsic.bswap(v);
			}
		}

		// Count Leading Zeros in Word
		uint CLZ(uint v) { return (v != 0) ? (31 - std.intrinsic.bsr(v)) : 32; }
		// Count Leading Ones in Word
		uint CLO(uint v) { return CLZ(~v); }

		void EXT(ref uint base, uint data, uint pos, uint size) {
			base = (data >>> pos) & MASK(size);
		}
		void INS(ref uint base, uint data, uint pos, uint size) {
			uint mask = MASK(size);
			//writefln("base=%08X, data=%08X, pos=%d, size=%d", base, data, pos, size);
			base &= ~(mask << pos);
			base |= (data & mask) << pos;
		}
	}
}
