module pspemu.core.cpu.cpu_alu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

import std.stdio;

template TemplateCpu_ALU() {
	void OP_ADD() {
		registers[instruction.RD] = registers[instruction.RS] + registers[instruction.RT];
		registers.advance_pc(4);
	}

	void OP_ADDI() {
		registers[instruction.RD] = registers[instruction.RS] + instruction.IMM;
		registers.advance_pc(4);
	}
}

unittest {
	writefln("Unittesting: CPU.ALU...");
	scope memory    = new Memory;
	scope registers = new Registers;
	Instruction instruction = void;

	mixin TemplateCpu_ALU;

	// Check ADD.
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
}