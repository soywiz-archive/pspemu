module pspemu.core.cpu.interpreter.ops.Cpu_Branch;

import std.stdio;

enum Likely { NO, YES }
enum Link   { NO, YES }

static pure nothrow string BRANCH(Likely likely, Link link, string condition) {
	string r;
	r ~= "if (" ~ condition ~ ") {";
		if (link) r ~= "	registers[31] = registers.nPC + 4;";
	r ~= "	registers.pcAdvance(instruction.OFFSET2);";
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
	void OP_BEQ () { mixin(BRANCH(Likely.NO , Link.NO , "(cast(int)registers[instruction.RS]) == (cast(int)registers[instruction.RT])")); }
	void OP_BEQL() { mixin(BRANCH(Likely.YES, Link.NO , "(cast(int)registers[instruction.RS]) == (cast(int)registers[instruction.RT])")); }

	// BGEZ -- Branch on greater than or equal to zero
	// BGEZAL -- Branch on greater than or equal to zero and link
	// BGEZL -- Branch on greater than or equal to zero likely
	// Branches if the register is greater than or equal to zero
	// Branches if the register is greater than or equal to zero and saves the return address in $31
	// if $s >= 0 .pcAdvance (offset << 2)); else .pcAdvance (4);
	// if $s >= 0 $31 = PC + 8 (or nPC + 4); advance_pc (offset << 2)); else .pcAdvance (4);
	void OP_BGEZ   () { mixin(BRANCH(Likely.NO , Link.NO , "(cast(int)registers[instruction.RS]) >= 0")); }
	void OP_BGEZL  () { mixin(BRANCH(Likely.YES, Link.NO , "(cast(int)registers[instruction.RS]) >= 0")); }
	void OP_BGEZAL () { mixin(BRANCH(Likely.NO , Link.YES, "(cast(int)registers[instruction.RS]) >= 0")); }
	void OP_BGEZALL() { mixin(BRANCH(Likely.YES, Link.YES, "(cast(int)registers[instruction.RS]) >= 0")); }

	// BGTZ -- Branch on greater than zero
	// Branches if the register is greater than zero
	// if $s > 0 advance_pc (offset << 2)); else advance_pc (4);
	void OP_BGTZ () { mixin(BRANCH(Likely.NO , Link.NO , "(cast(int)registers[instruction.RS]) > 0")); }
	void OP_BGTZL() { mixin(BRANCH(Likely.YES, Link.NO , "(cast(int)registers[instruction.RS]) > 0")); }

	// BLEZ -- Branch on less than or equal to zero
	// Branches if the register is less than or equal to zero
	// if $s <= 0 advance_pc (offset << 2)); else advance_pc (4);
	void OP_BLEZ () { mixin(BRANCH(Likely.NO , Link.NO , "(cast(int)registers[instruction.RS]) <= 0")); }
	void OP_BLEZL() { mixin(BRANCH(Likely.YES, Link.NO , "(cast(int)registers[instruction.RS]) <= 0")); }

	// BLTZ -- Branch on less than zero
	// Branches if the register is less than zero
	// if $s < 0 advance_pc (offset << 2)); else advance_pc (4);
	void OP_BLTZ   () { mixin(BRANCH(Likely.NO , Link.NO , "(cast(int)registers[instruction.RS]) < 0")); }
	void OP_BLTZL  () { mixin(BRANCH(Likely.YES, Link.NO , "(cast(int)registers[instruction.RS]) < 0")); }
	void OP_BLTZAL () { mixin(BRANCH(Likely.NO , Link.YES, "(cast(int)registers[instruction.RS]) < 0")); }
	void OP_BLTZALL() { mixin(BRANCH(Likely.YES, Link.YES, "(cast(int)registers[instruction.RS]) < 0")); }

	// BNE -- Branch on not equal
	// Branches if the two registers are not equal
	// if $s != $t advance_pc (offset << 2)); else advance_pc (4);
	void OP_BNE () { mixin(BRANCH(Likely.NO , Link.NO , "(cast(int)registers[instruction.RS]) != (cast(int)registers[instruction.RT])")); }
	void OP_BNEL() { mixin(BRANCH(Likely.YES, Link.NO , "(cast(int)registers[instruction.RS]) != (cast(int)registers[instruction.RT])")); }
}
