module pspemu.core.cpu.cpu_ops_branch;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

import std.stdio;

template TemplateCpu_BRANCH() {
	static enum Flags { None = 0, Link = 1, Likely = 2 }

	/*
	$text = preg_replace('/branch\\(([^;]+)\\);/Umsi', 'PC = nPC; nPC += ($1) ? (IMM << 2) : 4;', $text);
	$text = preg_replace('/branchl\\(([^;]+)\\);/Umsi', 'if ($1) { PC = nPC; nPC += (IMM << 2); } else { PC = nPC + 4; nPC = PC + 4; }', $text);
	*/

	static string BRANCH(string condition, Flags flags) {
		string r;
		r ~= "if (" ~ condition ~ ") {";
		if (flags & Flags.Link) {
			assert(!(flags & Flags.Likely));
			//r ~= "	registers[31] = registers.PC + 8;";
			r ~= "	registers[31] = registers.nPC + 4;";
		}
		r ~= "	registers.advance_pc(instruction.OFFSET << 2);";
		r ~= "} else {";
		if (flags & Flags.Likely) {
			r ~= "	registers.PC  = registers.nPC + 4;";
			r ~= "  registers.nPC = registers.PC  + 4;";
		} else {
			r ~= "	registers.advance_pc(4);";
		}
		r ~= "}";
		return r;
	}

	// BEQ -- Branch on equal
	// Branches if the two registers are equal
	// if $s == $t advance_pc (offset << 2)); else advance_pc (4);
	void OP_BEQ() { mixin(BRANCH(q{ registers[instruction.RS] == registers[instruction.RT] }, Flags.None)); }

	// BGEZ -- Branch on greater than or equal to zero
	// Branches if the register is greater than or equal to zero
	// if $s >= 0 advance_pc (offset << 2)); else advance_pc (4);
	void OP_BGEZ() { mixin(BRANCH(q{ registers[instruction.RS] >= 0 }, Flags.None)); }

	// BGEZAL -- Branch on greater than or equal to zero and link
	// Branches if the register is greater than or equal to zero and saves the return address in $31
	// if $s >= 0 $31 = PC + 8 (or nPC + 4); advance_pc (offset << 2)); else advance_pc (4);
	void OP_BGEZAL() { mixin(BRANCH(q{ registers[instruction.RS] >= 0 }, Flags.Link)); }

	// BGEZL -- Branch on greater than or equal to zero likely
	void OP_BGEZL() { mixin(BRANCH(q{ registers[instruction.RS] >= 0 }, Flags.Likely)); }
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