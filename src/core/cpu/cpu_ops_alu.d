module pspemu.core.cpu.cpu_ops_alu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

import std.stdio;

template TemplateCpu_ALU() {
	// ADD -- Add
	// Adds two registers and stores the result in a register
	// $d = $s + $t; advance_pc (4);
	void OP_ADD() {
		registers[instruction.RD] = registers[instruction.RS] + registers[instruction.RT];
		registers.advance_pc(4);
	}

	// ADDI -- Add immediate
	// Adds a register and a signed immediate value and stores the result in a register
	// $t = $s + imm; advance_pc (4);
	void OP_ADDI() {
		registers[instruction.RT] = registers[instruction.RS] + instruction.IMM;
		registers.advance_pc(4);
	}

	// ADDIU -- Add immediate unsigned
	// Adds a register and an unsigned immediate value and stores the result in a register
	// $t = $s + imm; advance_pc (4);
	alias OP_ADDI OP_ADDIU;

	// ADDU -- Add unsigned
	// Adds two registers and stores the result in a register
	// $d = $s + $t; advance_pc (4);
	alias OP_ADD OP_ADDU;

	// AND -- Bitwise and
	// Bitwise ands two registers and stores the result in a register
	// $d = $s & $t; advance_pc (4);
	void OP_AND() {
		registers[instruction.RD] = registers[instruction.RS] & registers[instruction.RT];
		registers.advance_pc(4);
	}

	// ANDI -- Bitwise and immediate
	// Bitwise ands a register and an immediate value and stores the result in a register
	// $t = $s & imm; advance_pc (4);
	void OP_ANDI() {
		registers[instruction.RT] = registers[instruction.RS] & instruction.IMMU;
		registers.advance_pc(4);
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