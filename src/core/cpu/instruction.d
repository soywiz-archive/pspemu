module pspemu.core.cpu.instruction;

import std.stdio, std.bitmanip;

struct Instruction {
	union {
		// Normal value.
		uint v;
		
		// Type Register.
		struct { mixin(bitfields!(
			uint, "",   11,
			uint, "RD", 5,
			uint, "RT", 5,
			uint, "RS", 5,
			uint, "",   6
		)); }

		// Type Immediate.
		struct { mixin(bitfields!(
			int, "IMM", 16,
			uint, "IMM_", 16
		)); }
	}

	static assert (this.sizeof == 4, "Instruction length should be 4 bytes/32 bits.");

	uint opCast() { return v; }
}

unittest {
	writefln("Unittesting: Instruction...");
	Instruction i;
	//       ------ SSSSS TTTTT DDDDD -----------
	i.v = 0b_111111_10001_11011_00100_11111111111;
	assert(i.RS == 0b_10001);
	assert(i.RT == 0b_11011);
	assert(i.RD == 0b_00100);

	//static void main() { }
}
