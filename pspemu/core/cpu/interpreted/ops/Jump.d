module pspemu.core.cpu.interpreted.ops.Jump;

import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Instruction;
import pspemu.core.Memory;

import std.stdio;

//debug = DEBUG_CALLS;

template TemplateCpu_JUMP() {
	mixin TemplateCpu_JUMP_Utils;
	
	// J -- Jump
	// Jumps to the calculated address
	// PC = nPC; nPC = (PC & 0xf0000000) | (target << 2);
	auto OP_J() { mixin(JUMP); }

	// JAL -- Jump and link
	// Jumps to the calculated address and stores the return address in $31
	// $31 = PC + 8 (or nPC + 4); PC = nPC; nPC = (PC & 0xf0000000) | (target << 2);
	auto OP_JAL() {
		mixin(LINK ~ JUMP);
		debug (DEBUG_CALLS) {
			registers.CallStack ~= registers.nPC;
			foreach (n; 0..registers.CallStack.length) writef("|");
			writef("JAL: %08X->%08X (", registers.RA, registers.nPC);
			for (int n = 0; n < 3; n++) writef("a%d=%08X, ", n, registers.R[4 + n]);
			writef("SP=%08X", registers.SP);
			writefln(")");
		}
	}

	// JR -- Jump register
	// Jump to the address contained in register $s
	// PC = nPC; nPC = $s;
	auto OP_JR() {
		debug (DEBUG_CALLS) if (instruction.RS == 31) {
			foreach (n; 0..registers.CallStack.length) writef("|");
			writefln("/jr RA %08X", registers.RA);
			registers.dump();
			if (registers.CallStack.length > 0) registers.CallStack.length = registers.CallStack.length - 1;
		}
		mixin(JUMPR);
	}

	// JALR -- Jump and link register
	auto OP_JALR() { mixin(LINK ~ JUMPR); }
}

template TemplateCpu_JUMP_Utils() {
	static pure nothrow {
		string LINK() {
			return q{
				registers.RA = registers.nPC + 4;
			};
		}
		string JUMP() {
			return q{
				registers.PC  = registers.nPC;
				registers.nPC = (registers.PC & 0x_F0000000) | instruction.JUMP2;
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