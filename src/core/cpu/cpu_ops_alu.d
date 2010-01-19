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
}