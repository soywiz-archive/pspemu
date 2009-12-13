module core.cpu.Instruction;

import std.bitmanip;

struct Instruction {
	string   name;
	uint     opcode;
	uint     mask;

	// Extra.
	enum Type    { NONE = 0, PSP = 1, B = 2, JUMP = 4, JAL = 8, BRANCH = B | JUMP | JAL }
	enum Address { NONE = 0, T16 = 1, T26 = 2, REG = 3 }
	string   fmt;
	Address  addrtype;
	Type     type;
};

struct OPCODE {
	union {
		// Normal value.
		uint v;
		
		// Type Register.
		struct { mixin(bitfields!(
			uint, "", 11,
			uint, "RD", 5,
			uint, "RT", 5,
			uint, "RS", 5,
			uint, "",  6
		)); }

		// Type Immediate.
		struct { mixin(bitfields!(
			int, "IMM", 16,
			uint, "IMM_", 16
		)); }
	}

	// Length of OPCODE should be 4 bytes / 32 bits.
	static assert (OPCODE.sizeof == 4);

	uint opCast() { return v; }
}
