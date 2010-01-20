module pspemu.core.cpu.cpu_ops_alu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

import std.stdio;

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

	// http://www-graphics.stanford.edu/~seander/bithacks.html#BitReverseObvious
	static uint  REV4(uint v) {
		v = ((v >> 1) & 0x55555555) | ((v & 0x55555555) << 1 ); // swap odd and even bits
		v = ((v >> 2) & 0x33333333) | ((v & 0x33333333) << 2 ); // swap consecutive pairs
		v = ((v >> 4) & 0x0F0F0F0F) | ((v & 0x0F0F0F0F) << 4 ); // swap nibbles ... 
		v = ((v >> 8) & 0x00FF00FF) | ((v & 0x00FF00FF) << 8 ); // swap bytes
		v = ( v >> 16             ) | ( v               << 16); // swap 2-byte long pairs
		return v;
	}

	// ADD -- Add
	// ADDU -- Add unsigned
	// Adds two registers and stores the result in a register
	// $d = $s + $t; advance_pc (4);
	void OP_ADD () { mixin(ALU("+", Register, Signed  )); }
	void OP_ADDU() { mixin(ALU("+", Register, Unsigned)); }

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

	// ANDI -- Bitwise and immediate
	// ORI -- Bitwise and immediate
	// Bitwise ands a register and an immediate value and stores the result in a register
	// $t = $s & imm; advance_pc (4);
	void OP_ANDI() { mixin(ALU("&", Immediate, Unsigned)); }
	void OP_ORI () { mixin(ALU("|", Immediate, Unsigned)); }

	// LUI -- Load upper immediate
	// The immediate value is shifted left 16 bits and stored in the register. The lower 16 bits are zeroes.
	// $t = (imm << 16); advance_pc (4);
	void OP_LUI() {
		registers[instruction.RT] = instruction.IMMU << 16;
		registers.pcAdvance(4);
	}

	// BITREV - Bit Reverse
	void OP_BITREV() {
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