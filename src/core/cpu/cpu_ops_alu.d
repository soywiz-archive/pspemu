module pspemu.core.cpu.cpu_ops_alu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

import std.stdio;

// http://pspemu.googlecode.com/svn/branches/old/src/core/cpu.d
// http://pspemu.googlecode.com/svn/branches/old/util/gen/impl/SPECIAL
// http://pspemu.googlecode.com/svn/branches/old/util/gen/impl/MISC
template TemplateCpu_ALU() {
	enum { Unsigned, Signed }
	enum { Register, Immediate }

	static pure nothrow {
		string ALU(string operator, bool immediate, bool signed) {
			string r;
			if (immediate) {
				r ~= "registers[instruction.RT] = registers[instruction.RS] " ~ operator ~ " instruction." ~ (signed ? "IMM" : "IMMU") ~ ";";
				r ~= "registers.pcAdvance(4);";
			} else {
				// FIXME: Check if we need sign here.
				r ~= "registers[instruction.RD] = registers[instruction.RS] " ~ operator ~ " registers[instruction.RT];";
				r ~= "registers.pcAdvance(4);";
			}
			return r;
		}
	}

	static final int MASK(uint bits) { return ((1 << cast(ubyte)bits) - 1); }

	// ADD(U) -- Add (Unsigned)
	// Adds two registers and stores the result in a register
	// $d = $s + $t; advance_pc (4);
	void OP_ADD () { mixin(ALU("+", Register, Signed  )); }
	void OP_ADDU() { mixin(ALU("+", Register, Unsigned)); }

	void OP_SUB () { mixin(ALU("-", Register, Signed  )); }
	void OP_SUBU() { mixin(ALU("-", Register, Unsigned)); }

	// ADDI -- Add immediate
	// ADDIU -- Add immediate unsigned
	// Adds a register and a signed immediate value and stores the result in a register
	// $t = $s + imm; advance_pc (4);
	void OP_ADDI () { mixin(ALU("+", Immediate, Signed  )); }
	void OP_ADDIU() { mixin(ALU("+", Immediate, Unsigned)); }

	// AND -- Bitwise and
	// Bitwise ands two registers and stores the result in a register
	// $d = $s & $t; advance_pc (4);
	void OP_AND() { mixin(ALU("&", Register, Unsigned)); }
	void OP_OR () { mixin(ALU("|", Register, Unsigned)); }
	void OP_XOR() { mixin(ALU("^", Register, Unsigned)); }
	void OP_NOR() { registers[instruction.RD] = ~(registers[instruction.RS] | registers[instruction.RT]); registers.pcAdvance(4); }

	// MOVZ -- MOV If Zero?
	// MOVN -- MOV If Non Zero?
	void OP_MOVZ() { if (registers[instruction.RT] == 0) registers[instruction.RD] = registers[instruction.RS]; registers.pcAdvance(4); }
	void OP_MOVN() { if (registers[instruction.RT] != 0) registers[instruction.RD] = registers[instruction.RS]; registers.pcAdvance(4); }

	// ANDI -- Bitwise and immediate
	// ORI -- Bitwise and immediate
	// Bitwise ands a register and an immediate value and stores the result in a register
	// $t = $s & imm; advance_pc (4);
	void OP_ANDI() { mixin(ALU("&", Immediate, Unsigned)); }
	void OP_ORI () { mixin(ALU("|", Immediate, Unsigned)); }
	void OP_XORI() { mixin(ALU("^", Immediate, Unsigned)); }

	// SLT(I)(U)  -- Set Less Than (Immediate) (Unsigned)
	void OP_SLT  () { mixin(ALU("<", Register , Signed  )); }
	void OP_SLTU () { mixin(ALU("<", Register , Unsigned)); }
	void OP_SLTI () { mixin(ALU("<", Immediate, Signed  )); }
	void OP_SLTIU() { mixin(ALU("<", Immediate, Unsigned)); }

	// LUI -- Load upper immediate
	// The immediate value is shifted left 16 bits and stored in the register. The lower 16 bits are zeroes.
	// $t = (imm << 16); advance_pc (4);
	void OP_LUI() {
		registers[instruction.RT] = instruction.IMMU << 16;
		registers.pcAdvance(4);
	}

	// SEB - Sign Extension Byte
	// SEH - Sign Extension Half
	// FIXME: Check if we can get it using cast(). Try when the unittesting is done.
	void OP_SEB() {
		static uint SEB(ubyte  r0) { uint r1; asm { xor EAX, EAX; mov AL, r0; movsx EBX, AL; mov r1, EBX; } return r1; }
		registers[instruction.RD] = SEB(cast(ubyte)registers[instruction.RT]);
		registers.pcAdvance(4);
	}
	void OP_SEH() {
		uint SEH(ushort r0) { uint r1; asm { xor EAX, EAX; mov AX, r0; movsx EBX, AX; mov r1, EBX; } return r1; }
		registers[instruction.RD] = SEH(cast(ushort)registers[instruction.RT]);
		registers.pcAdvance(4);
	}

	static uint ROTR(uint a, uint b) { b = (b & 0x1F); asm { mov EAX, a; mov ECX, b; ror EAX, CL; mov a, EAX; } return a; }
	// ROTR -- Rotate Word Right
	// ROTV -- Rotate Word Right Variable
	void OP_ROTR() {
		registers[instruction.RD] = ROTR(registers[instruction.RT], registers[instruction.POS]);
		registers.pcAdvance(4);
	}
	void OP_ROTV() {
		registers[instruction.RD] = ROTR(registers[instruction.RT], registers[instruction.RS]);
		registers.pcAdvance(4);
	}

	// Not used.
	//static uint SLA(int a, int b) { asm { mov EAX, a; mov ECX, b; sal EAX, CL; mov a, EAX; } return a; }

	// SLL(V) - Shift Word Left Logical (Variable)
	static uint SLL(int a, int b) { asm { mov EAX, a; mov ECX, b; shl EAX, CL; mov a, EAX; } return a; }
	void OP_SLL () { registers[instruction.RD] = SLL(registers[instruction.RT], registers[instruction.POS]); registers.pcAdvance(4); }
	void OP_SLLV() { registers[instruction.RD] = SLL(registers[instruction.RT], registers[instruction.RS ]); registers.pcAdvance(4); }

	// SRA(V) - Shift Word Right Arithmetic (Variable)
	static uint SRA(int a, int b) { asm { mov EAX, a; mov ECX, b; sar EAX, CL; mov a, EAX; } return a; }
	void OP_SRA () { registers[instruction.RD] = SRA(registers[instruction.RT], registers[instruction.POS]); registers.pcAdvance(4); }
	void OP_SRAV() { registers[instruction.RD] = SRA(registers[instruction.RT], registers[instruction.RS ]); registers.pcAdvance(4); }

	// SRL(V) - Shift Word Right Logic (Variable)
	static uint SRL(int a, int b) { asm { mov EAX, a; mov ECX, b; shr EAX, CL; mov a, EAX; } return a; }
	void OP_SRL () { registers[instruction.RD] = SRA(registers[instruction.RT], registers[instruction.POS]); registers.pcAdvance(4); }
	void OP_SRLV() { registers[instruction.RD] = SRA(registers[instruction.RT], registers[instruction.RS ]); registers.pcAdvance(4); }

	// EXT -- EXTract
	// INS -- INSert
	void OP_EXT() {
		registers[instruction.RT] = (registers[instruction.RS] >> instruction.POS) & MASK(instruction.SIZE + 1);
		registers.pcAdvance(4);
	}
	void OP_INS() {
		uint mask = MASK(instruction.SIZE - instruction.POS + 1);
		registers[instruction.RT] = (registers[instruction.RT] & ~(mask << instruction.POS)) | ((registers[instruction.RS] & mask) << instruction.POS);
		registers.pcAdvance(4);
	}

	// BITREV - Bit Reverse
	void OP_BITREV() {
		// http://www-graphics.stanford.edu/~seander/bithacks.html#BitReverseObvious
		static uint  REV4(uint v) {
			v = ((v >> 1) & 0x55555555) | ((v & 0x55555555) << 1 ); // swap odd and even bits
			v = ((v >> 2) & 0x33333333) | ((v & 0x33333333) << 2 ); // swap consecutive pairs
			v = ((v >> 4) & 0x0F0F0F0F) | ((v & 0x0F0F0F0F) << 4 ); // swap nibbles ... 
			v = ((v >> 8) & 0x00FF00FF) | ((v & 0x00FF00FF) << 8 ); // swap bytes
			v = ( v >> 16             ) | ( v               << 16); // swap 2-byte long pairs
			return v;
		}
		registers[instruction.RD] = REV4(registers[instruction.RT]);
		registers.pcAdvance(4);
	}

	// MAX
	void OP_MAX() {
		static int MAX(int a, int b) { return (a > b) ? a : b; }
		registers[instruction.RD] = MAX(cast(int)registers[instruction.RS], cast(int)registers[instruction.RT]);
		registers.pcAdvance(4);
	}
	
	// MIN
	void OP_MIN() {
		static int MIN(int a, int b) { return (a < b) ? a : b; }
		registers[instruction.RD] = MIN(cast(int)registers[instruction.RS], cast(int)registers[instruction.RT]);
		registers.pcAdvance(4);
	}

	// DIV -- Divide
	// DIVU -- Divide Unsigned
	// Divides $s by $t and stores the quotient in $LO and the remainder in $HI
	// $LO = $s / $t; $HI = $s % $t; advance_pc (4);
	void OP_DIV() {
		void DIVS(int a, int b) { registers.LO = a / b; registers.HI = a % b; }
		DIVS(registers[instruction.RS], registers[instruction.RT]);
		registers.pcAdvance(4);
	}
	void OP_DIVU() {
		void DIVU(uint a, uint b) { registers.LO = a / b; registers.HI = a % b; }
		DIVU(registers[instruction.RS], registers[instruction.RT]);
		registers.pcAdvance(4);
	}

	// MULT -- Multiply
	// MULTU -- Multiply unsigned
	void OP_MULT() {
		void MULTS(int  a, int  b) { int l, h; asm { mov EAX, a; mov EBX, b; imul EBX; mov l, EAX; mov h, EDX; } registers.LO = l; registers.HI = h; }
		MULTS(registers[instruction.RS], registers[instruction.RT]);
		registers.pcAdvance(4);
	}
	void OP_MULTU() {
		void MULTU(uint a, uint b) { int l, h; asm { mov EAX, a; mov EBX, b; mul EBX; mov l, EAX; mov h, EDX; } registers.LO = l; registers.HI = h; }
		MULTU(registers[instruction.RS], registers[instruction.RT]);
		registers.pcAdvance(4);
	}

	// MADD
	void OP_MADD() {
		int rs = registers[instruction.RS], rt = registers[instruction.RT], lo = registers.LO, hi = registers.HI;
		asm { mov EAX, rs; imul rt; add lo, EAX; adc hi, EDX; }
		registers.LO = lo;
		registers.HI = hi;
		registers.pcAdvance(4);
	}
	void OP_MADDU() {
		int rs = registers[instruction.RS], rt = registers[instruction.RT], lo = registers.LO, hi = registers.HI;
		asm { mov EAX, rs; mul rt; add lo, EAX; adc hi, EDX; }
		registers.LO = lo;
		registers.HI = hi;
		registers.pcAdvance(4);
	}

	// MSUB
	void OP_MSUB() { // FIXME: CHECK.
		int rs = registers[instruction.RS], rt = registers[instruction.RT], lo = registers.LO, hi = registers.HI;
		asm { mov EAX, rs; imul rt; sub lo, EAX; sub hi, EDX; }
		registers.LO = lo;
		registers.HI = hi;
		registers.pcAdvance(4);
	}
	void OP_MSUBU() { // FIXME: CHECK.
		int rs = registers[instruction.RS], rt = registers[instruction.RT], lo = registers.LO, hi = registers.HI;
		asm { mov EAX, rs; mul rt; sub lo, EAX; sub hi, EDX; }
		registers.LO = lo;
		registers.HI = hi;
		registers.pcAdvance(4);
	}

	// MFHI/MFLO -- Move from HI/LO
	// MTHI/MTLO -- Move to HI/LO
	void OP_MFHI() { registers[instruction.RD] = registers.HI; registers.pcAdvance(4); }
	void OP_MFLO() { registers[instruction.RD] = registers.LO; registers.pcAdvance(4); }
	void OP_MTHI() { registers.HI = registers[instruction.RS]; registers.pcAdvance(4); }
	void OP_MTLO() { registers.LO = registers[instruction.RS]; registers.pcAdvance(4); }

	// WSBH -- Word Swap Bytes Within Halfwords
	void OP_WSBH() {
		static uint WSBH(uint v) { return ((v & 0x_FF00_FF00) >> 8) | ((v & 0x_00FF_00FF) << 8); }
		registers[instruction.RD] = WSBH(registers[instruction.RT]); registers.pcAdvance(4);
	}

	// WSBW -- Word Swap Bytes Within Words?? // FIXME! Not sure about this!
	static uint WSBW(uint v) {
		static struct UINT { union { uint i; ubyte[4] b; } }
		UINT vs = void, vd = void; vs.i = v;
		vd.b[0] = vs.b[3];
		vd.b[1] = vs.b[2];
		vd.b[2] = vs.b[1];
		vd.b[3] = vs.b[0];
		return vd.i;
	}
	void OP_WSBW() { registers[instruction.RD] = WSBW(registers[instruction.RT]); registers.pcAdvance(4); }
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope memory    = new Memory;
	scope registers = new Registers;
	Instruction instruction = void;

	mixin TemplateCpu_ALU;

	writefln("  Check ADD");
	{
		registers.PC = 0x1000;
		registers.nPC = 0x1004;
		registers[2] = 7;
		registers[3] = 11;
		instruction.RD = 1;
		instruction.RS = 2;
		instruction.RT = 3;
		OP_ADD();
		assert(registers[1] == 7 + 11);
		assert(registers.PC == 0x1004);
		assert(registers.nPC == 0x1008);
	}

	writefln("  Check AND");
	{
		registers[2] = 0x_FEFFFFFE;
		registers[3] = 0x_A7B39273;
		instruction.RD = 1;
		instruction.RS = 2;
		instruction.RT = 3;
		OP_AND();
		assert(registers[1] == (0x_FEFFFFFE & 0x_A7B39273));
		assert(registers.nPC == registers.PC + 4);
	}

	writefln("  Check ANDI");
	{
		registers[2] = 0x_FFFFFFFF;
		instruction.RT = 1;
		instruction.RS = 2;
		instruction.IMMU = 0x_FF77;
		OP_ANDI();
		assert(registers[1] == (0x_FFFFFFFF & 0x_FF77));
		assert(registers.nPC == registers.PC + 4);
	}

	writefln("  Check BITREV");
	{
		// php -r"$r = ''; for ($n = 0; $n < 32; $n++) $r .= mt_rand(0, 1); echo '0b_' . $r . ' : 0b_' . strrev($r) . ',' . chr(10);"
		scope expectedList = [
			// Hand crafted.
			0b_00000000000000000000000000000000 : 0b_00000000000000000000000000000000,
			0b_11111111111111111111111111111111 : 0b_11111111111111111111111111111111,
			0b_10000000000000000000000000000000 : 0b_00000000000000000000000000000001,

			// Random.
			0b_10110010011111100010101010000011 : 0b_11000001010101000111111001001101,
			0b_01110101010111100111010110010001 : 0b_10001001101011100111101010101110,
			0b_10001010010110110111011100101011 : 0b_11010100111011101101101001010001,
			0b_01101110000110111011101110001010 : 0b_01010001110111011101100001110110,
			0b_10000110001100101110100111011111 : 0b_11111011100101110100110001100001,
			0b_11001001000110110011001010111110 : 0b_01111101010011001101100010010011,
		];

		foreach (a, b; expectedList) {
			foreach (entry; [[a, b], [b, a]]) {
				registers[2] = entry[0];
				instruction.RD = 1;
				instruction.RT = 2;
				OP_BITREV();
				//registers.dump(); writefln("%08X:%08X", entry[0], entry[1]);
				assert(registers[1] == entry[1]);
				assert(registers.nPC == registers.PC + 4);
			}
		}
	}
}
