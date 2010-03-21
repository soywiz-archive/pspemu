module pspemu.core.cpu.ops.Jump;

import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Instruction;
import pspemu.core.Memory;

import std.stdio;

template TemplateCpu_JUMP() {
	mixin TemplateCpu_JUMP_Utils;

	// J -- Jump
	// Jumps to the calculated address
	// PC = nPC; nPC = (PC & 0xf0000000) | (target << 2);
	auto OP_J() { mixin(JUMP); }

	// JAL -- Jump and link
	// Jumps to the calculated address and stores the return address in $31
	// $31 = PC + 8 (or nPC + 4); PC = nPC; nPC = (PC & 0xf0000000) | (target << 2);
	auto OP_JAL() { mixin(LINK ~ JUMP); }

	// JR -- Jump register
	// Jump to the address contained in register $s
	// PC = nPC; nPC = $s;
	auto OP_JR() { mixin(JUMPR); }

	// JALR -- Jump and link register
	auto OP_JALR() { mixin(LINK ~ JUMPR); }
}

template TemplateCpu_JUMP_Utils() {
	static pure nothrow {
		string LINK() {
			return q{
				registers[31] = registers.nPC + 4;
			};
		}
		string JUMP() {
			return q{
				registers.PC  = registers.nPC;
				registers.nPC = (registers.PC & 0x_F0000000) | (instruction.JUMP << 2);
			};
		}
		string JUMPR() {
			return q{
				registers.PC  = registers.nPC;
				registers.nPC = registers[instruction.RS];
			};
		}
	}
}