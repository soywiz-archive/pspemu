module pspemu.core.cpu.cpu_ops_memory;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

import std.stdio;

template TemplateCpu_MEMORY() {
	enum { Unsigned, Signed }

	// FIXME: This should be moved to another place.
	alias byte   s8;
	alias ubyte  u8;
	alias short  s16;
	alias ushort u16;
	alias int    s32;
	alias uint   u32;
	alias long   s64;
	alias ulong  u64;

	static pure nothrow {
		string LOAD(string size, bool signed) {
			return (
				"registers[instruction.RT] = cast(" ~ (signed ? "s" : "u") ~ size ~ ")memory.read" ~ size ~ "(registers[instruction.RS] + instruction.OFFSET);" ~
				"registers.pcAdvance(4);"
			);
		}
	}

	// LB(U) -- Load byte (unsigned)
	// LH(U) -- Load half (unsigned)
	// LW    -- Load word
	// A byte/half/word is loaded into a register from the specified address.
	// $t = MEM[$s + offset]; advance_pc (4);
	void OP_LB () { mixin(LOAD("8" , Signed  )); }
	void OP_LBU() { mixin(LOAD("8" , Unsigned)); }

	void OP_LH () { mixin(LOAD("16", Signed  )); }
	void OP_LHU() { mixin(LOAD("16", Unsigned)); }

	void OP_LW () { mixin(LOAD("32", Unsigned)); }
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope memory    = new Memory;
	scope registers = new Registers;
	Instruction instruction = void;

	mixin TemplateCpu_MEMORY;

	uint value = 0x_12_34_56_78;

	writefln("  Check LB (Sign extension)...");
	{
		memory[Memory.mainMemoryAddress] = cast(ubyte)-1;
		registers[2] = Memory.mainMemoryAddress;
		instruction.RT = 1;
		instruction.RS = 2;
		instruction.OFFSET = 0;
		OP_LB();
		assert(registers[instruction.RT] == -1);
	}
}