module pspemu.core.cpu.interpreter.ops.Cpu_Memory;

import std.stdio;

//debug = DEBUG_SB;

template TemplateCpu_MEMORY() {
	mixin TemplateCpu_MEMORY_Utils;
	
	// LB(U) -- Load byte (unsigned)
	// LH(U) -- Load half (unsigned)
	// LW    -- Load word
	// A byte/half/word is loaded into a register from the specified address.
	// $t = MEM[$s + offset]; advance_pc (4);
	void OP_LB () { LOAD!(byte); }
	void OP_LBU() { LOAD!(ubyte); }

	void OP_LH () { LOAD!(short); }
	void OP_LHU() { LOAD!(ushort); }

	void OP_LW () { LOAD!(uint); }

	// LWL -- Load Word Left
	// LWR -- Load Word Right
	void OP_LWL() {
		registers[instruction.RT] = (
			(registers[instruction.RT] & 0x_0000_FFFF) |
			((memory.tread!(ushort)(registers[instruction.RS] + instruction.IMM - 1) << 16) & 0x_FFFF_0000)
		);
		registers.pcAdvance(4);
	}
	void OP_LWR() {
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
	void OP_SB() { STORE!(ubyte); }
	void OP_SH() { STORE!(ushort); }
	void OP_SW() { STORE!(uint); }

	// SWL -- Store Word Left
	// SWR -- Store Word Right
	void OP_SWL() {
		memory.twrite!(ushort)(registers[instruction.RS] + instruction.IMM - 1, (registers[instruction.RT] >> 16) & 0xFFFF);
		registers.pcAdvance(4);
	}
	void OP_SWR() {
		memory.twrite!(ushort)(registers[instruction.RS] + instruction.IMM - 0, (registers[instruction.RT] >>  0) & 0xFFFF);
		registers.pcAdvance(4);
	}

	// CACHE
	void OP_CACHE() {
		//std.stdio.writefln("Unimplemented CACHE");
		registers.pcAdvance(4);
	}
}

template TemplateCpu_MEMORY_Utils() {
	void LOAD(T)() {
		registers[instruction.RT] = cast(uint)memory.tread!(T)(registers[instruction.RS] + instruction.OFFSET);
		static if (is(T == short)) {
			//writefln("%d", registers[instruction.RT]);
		}
		registers.pcAdvance(4);
	}

	void STORE(T)() {
		static if (is(T == ubyte)) {
			debug (DEBUG_SB) {
				writef("PC(%08X): ", registers.PC);
				writef("%08X: ", registers[instruction.RS] + instruction.OFFSET);
				//for (int n = -4; n <= 4; n++) writef("%02X", memory[registers[instruction.RS] + instruction.OFFSET + n]);
				writef("%02X", memory[registers[instruction.RS] + instruction.OFFSET + 0]);
				writef(" -> ");
			}
		}

		memory.twrite!(T)(registers[instruction.RS] + instruction.OFFSET, cast(T)registers[instruction.RT]);
		registers.pcAdvance(4);

		static if (is(T == ubyte)) {
			debug (DEBUG_SB) {
				//for (int n = -4; n <= 4; n++) writef("%02X", memory[registers[instruction.RS] + instruction.OFFSET + n]);
				writef("%02X'%s'", memory[registers[instruction.RS] + instruction.OFFSET + 0], cast(char)memory[registers[instruction.RS] + instruction.OFFSET + 0]);
				writefln("");
			}
		}
	}
}
