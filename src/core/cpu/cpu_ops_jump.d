module pspemu.core.cpu.cpu_ops_jump;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

import std.stdio;

template TemplateCpu_JUMP() {
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

	// J -- Jump
	// Jumps to the calculated address
	// PC = nPC; nPC = (PC & 0xf0000000) | (target << 2);
	void OP_J() { mixin(JUMP); }

	// JAL -- Jump and link
	// Jumps to the calculated address and stores the return address in $31
	// $31 = PC + 8 (or nPC + 4); PC = nPC; nPC = (PC & 0xf0000000) | (target << 2);
	void OP_JAL() { mixin(LINK ~ JUMP); }

	// JR -- Jump register
	// Jump to the address contained in register $s
	// PC = nPC; nPC = $s;
	void OP_JR() { mixin(JUMPR); }

	// JALR -- Jump and link register
	void OP_JALR() { mixin(LINK ~ JUMPR); }
}
