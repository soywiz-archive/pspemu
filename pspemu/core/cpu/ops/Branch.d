module pspemu.core.cpu.ops.Branch;

import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Instruction;
import pspemu.core.Memory;

import std.stdio;

enum Likely { NO, YES }
enum Link   { NO, YES }

static pure nothrow string BRANCH(Likely likely, Link link, string condition) {
	string r;
	r ~= "if (" ~ condition ~ ") {";
		if (link) r ~= "	registers[31] = registers.nPC + 4;";
	r ~= "	registers.pcAdvance(instruction.OFFSET << 2);";
	r ~= "} else {";
		if (likely) {
			r ~= "	registers.PC  = registers.nPC + 4;";
			r ~= "  registers.nPC = registers.PC  + 4;";
		} else {
			r ~= "	registers.pcAdvance(4);";
		}
	r ~= "}";
	return r;
}

template TemplateCpu_BRANCH() {
	// BEQ -- Branch on equal
	// BGEZL -- Branch on greater than or equal to zero likely
	// Branches if the two registers are equal
	// if $s == $t .pcAdvance (offset << 2)); else .pcAdvance (4);
	auto OP_BEQ () { mixin(BRANCH(Likely.NO , Link.NO , "registers[instruction.RS] == registers[instruction.RT]")); }
	auto OP_BEQL() { mixin(BRANCH(Likely.YES, Link.NO , "registers[instruction.RS] == registers[instruction.RT]")); }

	// BGEZ -- Branch on greater than or equal to zero
	// BGEZAL -- Branch on greater than or equal to zero and link
	// BGEZL -- Branch on greater than or equal to zero likely
	// Branches if the register is greater than or equal to zero
	// Branches if the register is greater than or equal to zero and saves the return address in $31
	// if $s >= 0 .pcAdvance (offset << 2)); else .pcAdvance (4);
	// if $s >= 0 $31 = PC + 8 (or nPC + 4); advance_pc (offset << 2)); else .pcAdvance (4);
	auto OP_BGEZ  () { mixin(BRANCH(Likely.NO , Link.NO , "(cast(int)registers[instruction.RS]) >= 0")); }
	auto OP_BGEZAL() { mixin(BRANCH(Likely.NO , Link.YES, "(cast(int)registers[instruction.RS]) >= 0")); }
	auto OP_BGEZL () { mixin(BRANCH(Likely.YES, Link.NO , "(cast(int)registers[instruction.RS]) >= 0")); }

	// BGTZ -- Branch on greater than zero
	// Branches if the register is greater than zero
	// if $s > 0 advance_pc (offset << 2)); else advance_pc (4);
	auto OP_BGTZ () { mixin(BRANCH(Likely.NO , Link.NO , "(cast(int)registers[instruction.RS]) > 0")); }
	auto OP_BGTZL() { mixin(BRANCH(Likely.YES, Link.NO , "(cast(int)registers[instruction.RS]) > 0")); }

	// BLEZ -- Branch on less than or equal to zero
	// Branches if the register is less than or equal to zero
	// if $s <= 0 advance_pc (offset << 2)); else advance_pc (4);
	auto OP_BLEZ () { mixin(BRANCH(Likely.NO , Link.NO , "(cast(int)registers[instruction.RS]) <= 0")); }
	auto OP_BLEZL() { mixin(BRANCH(Likely.YES, Link.NO , "(cast(int)registers[instruction.RS]) <= 0")); }

	// BLTZ -- Branch on less than zero
	// Branches if the register is less than zero
	// if $s < 0 advance_pc (offset << 2)); else advance_pc (4);
	auto OP_BLTZ   () { mixin(BRANCH(Likely.NO , Link.NO , "(cast(int)registers[instruction.RS]) < 0")); }
	auto OP_BLTZL  () { mixin(BRANCH(Likely.YES, Link.NO , "(cast(int)registers[instruction.RS]) < 0")); }
	auto OP_BLTZAL () { mixin(BRANCH(Likely.NO , Link.YES, "(cast(int)registers[instruction.RS]) < 0")); }
	auto OP_BLTZALL() { mixin(BRANCH(Likely.YES, Link.YES, "(cast(int)registers[instruction.RS]) < 0")); }

	// BNE -- Branch on not equal
	// Branches if the two registers are not equal
	// if $s != $t advance_pc (offset << 2)); else advance_pc (4);
	auto OP_BNE () { mixin(BRANCH(Likely.NO , Link.NO , "registers[instruction.RS] != registers[instruction.RT]")); }
	auto OP_BNEL() { mixin(BRANCH(Likely.YES, Link.NO , "registers[instruction.RS] != registers[instruction.RT]")); }
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
