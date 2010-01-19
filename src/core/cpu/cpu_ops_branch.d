module pspemu.core.cpu.cpu_ops_branch;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

import std.stdio;

template TemplateCpu_BRANCH() {
	static string BRANCH(string condition) {
		string r;
		r ~= "if (" ~ condition ~ ") {";
		r ~= "	registers.advance_pc(instruction.OFFSET << 2);";
		r ~= "} else {";
		r ~= "	registers.advance_pc(4);";
		r ~= "}";
		return r;
	}

	// BEQ -- Branch on equal
	// Branches if the two registers are equal
	// if $s == $t advance_pc (offset << 2)); else advance_pc (4);
	void OP_BEQ() { mixin(BRANCH(q{ registers[instruction.RS] == registers[instruction.RT] })); }

	// BGEZ -- Branch on greater than or equal to zero
	// Branches if the register is greater than or equal to zero
	// if $s >= 0 advance_pc (offset << 2)); else advance_pc (4);
	void OP_BGEZ() { mixin(BRANCH(q{ registers[instruction.RS] >= 0 })); }
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope memory    = new Memory;
	scope registers = new Registers;
	Instruction instruction = void;

	mixin TemplateCpu_BRANCH;

	uint base = 0x1000;
	registers[1] = 1;

	writefln("  Check BEQ (Branch)");
	{
		registers.set_pc(base);
		instruction.RS = 0;
		instruction.RT = 0;
		instruction.OFFSET = -7;
		OP_BEQ();
		assert(registers.PC == base + 4);
		assert(registers.nPC == base + 4 - 7 * 4);
	}

	writefln("  Check BEQ (No branch)");
	{
		registers.set_pc(base);
		instruction.RS = 0;
		instruction.RT = 1;
		instruction.OFFSET = -7;
		OP_BEQ();
		assert(registers.PC == base + 4);
		assert(registers.nPC == base + 8);
	}
}