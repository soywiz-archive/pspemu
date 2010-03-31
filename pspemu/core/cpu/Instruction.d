module pspemu.core.cpu.Instruction;

import std.stdio, std.string, std.bitmanip;

// Extra.
enum { INSTR_TYPE_NONE = 0, INSTR_TYPE_PSP = 1, INSTR_TYPE_B = 2, INSTR_TYPE_JUMP = 4, INSTR_TYPE_JAL = 8, INSTR_TYPE_BRANCH = INSTR_TYPE_B | INSTR_TYPE_JUMP | INSTR_TYPE_JAL }
enum { ADDR_TYPE_NONE = 0, ADDR_TYPE_16 = 1, ADDR_TYPE_26 = 2, ADDR_TYPE_REG = 3 }

struct InstructionDefinition {
	string  name;
	uint    opcode;
	uint    mask;

	string  fmt;
	uint    addrtype;
	uint    type;

	string toString() {
		return format("InstructionDefinition('%s', %08X, %08X, '%s', %s, %s)", name, opcode, mask, fmt, addrtype, type);
	}
}

struct Instruction {
	union {
		// Normal value.
		uint v;
		ubyte[4] vv;
		
		// Type Register.
		struct { mixin(bitfields!(
			uint, "",   11,
			uint, "RD", 5,
			uint, "RT", 5,
			uint, "RS", 5,
			uint, "",   6
		)); }

		// Type Float Register.
		struct { mixin(bitfields!(
			uint, "",   6,
			uint, "FD", 5,
			uint, "FS", 5,
			uint, "FT", 5,
			uint, "",   11
		)); }

		//010001:00010:rt:c1cr:00000:000000
		//alias RD C1CR;
		alias FS C1CR;

		// Type Immediate.
		struct { mixin(bitfields!(
			int, "IMM", 16,
			int, "__0",  16
		)); }

		// Type Immediate Unsigned.
		struct { mixin(bitfields!(
			uint, "IMMU" , 16,
			uint, "__1", 16
		)); }

		// JUMP 26 bits.
		struct { mixin(bitfields!(
			uint, "JUMP", 26,
			uint, "__2",  6
		)); }

		uint JUMP2() { return JUMP << 2; }
		uint JUMP2(uint v) { JUMP = v >> 2; return v; }

		// LSB/MSB
		struct { mixin(bitfields!(
			uint, "",      6,
			uint, "LSB",   5,
			uint, "MSB",   5,
			uint, "",      16
		)); }

		
		uint SIZE_E() { return MSB + 1; }
		uint SIZE_E(uint size) { MSB = size - 1; return size; }

		uint SIZE_I() { return MSB - LSB + 1; }
		uint SIZE_I(uint size) { MSB = LSB + size - 1; return size; }

		// CODE
		struct { mixin(bitfields!(
			uint, "__5",   6,
			uint, "CODE",  20,
			uint, "__6",   6
		)); }

		alias LSB POS; // EXT/INS (POS/SIZE_E/SIZE_I)
		alias CODE CODE_BREAK; // @TODO Fixme! BREAK %c
		alias IMM OFFSET;
	}

	static assert (this.sizeof == 4, "Instruction length should be 4 bytes/32 bits.");

	uint opCast() { return v; }
	string toString() { return std.string.format("OP(%08X)", v); }
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	Instruction i;
	//       ------ SSSSS TTTTT DDDDD -----------
	i.v = 0b_111111_10001_11011_00100_11111111111;
	assert(i.RS == 0b_10001);
	assert(i.RT == 0b_11011);
	assert(i.RD == 0b_00100);

	//static void main() { }
}
