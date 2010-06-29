module pspemu.core.cpu.interpreted.ops.Memory;
import pspemu.core.cpu.interpreted.Utils;

//debug = DEBUG_SB;

template TemplateCpu_MEMORY() {
	mixin TemplateCpu_MEMORY_Utils;
	
	// LB(U) -- Load byte (unsigned)
	// LH(U) -- Load half (unsigned)
	// LW    -- Load word
	// A byte/half/word is loaded into a register from the specified address.
	// $t = MEM[$s + offset]; advance_pc (4);
	auto OP_LB () { LOAD!(byte); }
	auto OP_LBU() { LOAD!(ubyte); }

	auto OP_LH () { LOAD!(short); }
	auto OP_LHU() { LOAD!(ushort); }

	auto OP_LW () { LOAD!(uint); }

	// LWL -- Load Word Left
	// LWR -- Load Word Right
	auto OP_LWL() {
		registers[instruction.RT] = (
			(registers[instruction.RT] & 0x_0000_FFFF) |
			((memory.tread!(ushort)(registers[instruction.RS] + instruction.IMM - 1) << 16) & 0x_FFFF_0000)
		);
		registers.pcAdvance(4);
	}
	auto OP_LWR() {
		registers[instruction.RT] = (
			(registers[instruction.RT] & 0x_FFFF_0000) |
			((memory.tread!(ushort)(registers[instruction.RS] + instruction.IMM - 0) << 0) & 0x_0000_FFFF)
		);
		registers.pcAdvance(4);
	}

	// SB -- Store byte
	// SH -- Store half
	// SW -- Store word
	// The contents of $t is stored at the specified address.
	// MEM[$s + offset] = $t; advance_pc (4);
	auto OP_SB() { STORE!(ubyte); }
	auto OP_SH() { STORE!(ushort); }
	auto OP_SW() { STORE!(uint); }

	// SWL -- Store Word Left
	// SWR -- Store Word Right
	auto OP_SWL() { memory.twrite!(ushort)(registers[instruction.RS] + instruction.IMM - 1, (registers[instruction.RT] >> 16) & 0xFFFF); registers.pcAdvance(4); }
	auto OP_SWR() { memory.twrite!(ushort)(registers[instruction.RS] + instruction.IMM - 0, (registers[instruction.RT] >>  0) & 0xFFFF); registers.pcAdvance(4); }

	// CACHE
	auto OP_CACHE() {
		.writefln("Unimplemented CACHE");
		registers.pcAdvance(4);
	}
}

template TemplateCpu_MEMORY_Utils() {
	void LOAD(T)() {
		registers[instruction.RT] = cast(uint)memory.tread!(T)(registers[instruction.RS] + instruction.OFFSET);
		registers.pcAdvance(4);
	}

	void STORE(T)() {
		static if (is(T == ubyte)) {
			debug (DEBUG_SB) {
				writef("%08X: ", registers[instruction.RS] + instruction.OFFSET);
				for (int n = -4; n <= 4; n++) writef("%02X", memory[registers[instruction.RS] + instruction.OFFSET + n]);
				writef(" -> ");
			}
		}

		memory.twrite!(T)(registers[instruction.RS] + instruction.OFFSET, cast(T)registers[instruction.RT]);
		registers.pcAdvance(4);

		static if (is(T == ubyte)) {
			debug (DEBUG_SB) {
				for (int n = -4; n <= 4; n++) writef("%02X", memory[registers[instruction.RS] + instruction.OFFSET + n]);
				writefln("");
			}
		}
	}
}
