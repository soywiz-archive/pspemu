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
		r ~= "	registers.pcAdvance(instruction.OFFSET << 2);";
		r ~= "} else {";
			if (flags & Flags.Likely) {
				r ~= "	registers.PC  = registers.nPC + 4;";
				r ~= "  registers.nPC = registers.PC  + 4;";
			} else {
				r ~= "	registers.pcAdvance(4);";
			}
		r ~= "}";
		return r;
	}

	// BEQ -- Branch on equal
	// Branches if the two registers are equal
	// if $s == $t .pcAdvance (offset << 2)); else .pcAdvance (4);
	void OP_BEQ() { mixin(BRANCH(q{ (cast(int)registers[instruction.RS]) == (cast(int)registers[instruction.RT]) }, Flags.None)); }

	// BGEZ -- Branch on greater than or equal to zero
	// Branches if the register is greater than or equal to zero
	// if $s >= 0 .pcAdvance (offset << 2)); else .pcAdvance (4);
	void OP_BGEZ() { mixin(BRANCH(q{ (cast(int)registers[instruction.RS]) >= 0 }, Flags.None)); }

	// BGEZAL -- Branch on greater than or equal to zero and link
	// Branches if the register is greater than or equal to zero and saves the return address in $31
	// if $s >= 0 $31 = PC + 8 (or nPC + 4); advance_pc (offset << 2)); else .pcAdvance (4);
	void OP_BGEZAL() { mixin(BRANCH(q{ (cast(int)registers[instruction.RS]) >= 0 }, Flags.Link)); }

	// BGEZL -- Branch on greater than or equal to zero likely
	void OP_BGEZL() { mixin(BRANCH(q{ (cast(int)registers[instruction.RS]) >= 0 }, Flags.Likely)); }
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope memory    = new Memory;
	scope registers = new Registers;
	Instruction instruction = void;

	mixin TemplateCpu_BRANCH;

	uint base = 0x1000;
	registers[0] =  0;
	registers[1] = +1;
	registers[2] = -1;
	int offset = -7;

	void set_RS_RT_OFFSET(int rs, int rt = 0) {
		instruction.RS = rs;
		instruction.RT = rt;
		instruction.OFFSET = offset;
	}

	writefln("  Check BEQ (Branch)");
	{
		registers.pcSet(base);
		set_RS_RT_OFFSET(0, 0);
		OP_BEQ();
		assert(registers.PC == base + 4);
		assert(registers.nPC == registers.PC + offset * 4);
	}

	writefln("  Check BEQ (No branch)");
	{
		registers.pcSet(base);
		set_RS_RT_OFFSET(0, 1);
		OP_BEQ();
		assert(registers.PC == base + 4);
		assert(registers.nPC == base + 8);
	}

	writefln("  Check OP_BGEZL (Branch)");
	{
		registers.pcSet(base);
		set_RS_RT_OFFSET(1);
		OP_BGEZL();
		assert(registers.PC == base + 4);
		assert(registers.nPC ==  registers.PC + offset * 4);
	}

	writefln("  Check OP_BGEZL (No Branch)");
	{
		registers.pcSet(base);
		set_RS_RT_OFFSET(2);
		OP_BGEZL();
		assert(registers.PC == base + 8);
		assert(registers.nPC == registers.PC + 4);
	}
}