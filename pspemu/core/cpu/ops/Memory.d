module pspemu.core.cpu.ops.Memory;

import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Instruction;
import pspemu.core.Memory;

import pspemu.utils.Utils;

import std.stdio;

template TemplateCpu_MEMORY() {
	mixin TemplateCpu_MEMORY_Utils;

	// LB(U) -- Load byte (unsigned)
	// LH(U) -- Load half (unsigned)
	// LW    -- Load word
	// A byte/half/word is loaded into a register from the specified address.
	// $t = MEM[$s + offset]; advance_pc (4);
	auto OP_LB () { mixin(LOAD(8 , Signed  )); }
	auto OP_LBU() { mixin(LOAD(8 , Unsigned)); }

	auto OP_LH () { mixin(LOAD(16, Signed  )); }
	auto OP_LHU() { mixin(LOAD(16, Unsigned)); }

	auto OP_LW () { mixin(LOAD(32, Unsigned)); }

	// LWL -- Load Word Left
	// LWR -- Load Word Right
	auto OP_LWL() {
		registers[instruction.RT] = (
			(registers[instruction.RT] & 0x_0000_FFFF) |
			((memory.read16(registers[instruction.RS] + instruction.IMM - 1) << 16) & 0x_FFFF_0000)
		);
		registers.pcAdvance(4);
	}
	auto OP_LWR() {
		registers[instruction.RT] = (
			(registers[instruction.RT] & 0x_FFFF_0000) |
			((memory.read16(registers[instruction.RS] + instruction.IMM - 0) << 0) & 0x_0000_FFFF)
		);
		registers.pcAdvance(4);
	}

	// SB -- Store byte
	// SH -- Store half
	// SW -- Store word
	// The contents of $t is stored at the specified address.
	// MEM[$s + offset] = $t; advance_pc (4);
	auto OP_SB() { mixin(STORE(8 )); }
	auto OP_SH() { mixin(STORE(16)); }
	auto OP_SW() { mixin(STORE(32)); }

	// SWL -- Store Word Left
	// SWR -- Store Word Right
	auto OP_SWL() { memory.write16(registers[instruction.RS] + instruction.IMM - 1, (registers[instruction.RT] >> 16) & 0xFFFF); registers.pcAdvance(4); }
	auto OP_SWR() { memory.write16(registers[instruction.RS] + instruction.IMM - 0, (registers[instruction.RT] >>  0) & 0xFFFF); registers.pcAdvance(4); }

	// CACHE
	auto OP_CACHE() {
		.writefln("Unimplemented CACHE");
		registers.pcAdvance(4);
	}
}

template TemplateCpu_MEMORY_Utils() {
	static pure nothrow {
		string LOAD(uint size, bool signed) {
			return (
				"registers[instruction.RT] = cast(" ~ (signed ? "s" : "u") ~ tos(size) ~ ")memory.read" ~ tos(size) ~ "(registers[instruction.RS] + instruction.OFFSET);" ~
				"registers.pcAdvance(4);"
			);
		}

		string STORE(uint size) {
			return (
				"memory.write" ~ tos(size) ~ "(registers[instruction.RS] + instruction.OFFSET, cast(u" ~ tos(size) ~ ")registers[instruction.RT]);" ~
				"registers.pcAdvance(4);"
			);
		}
	}
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
