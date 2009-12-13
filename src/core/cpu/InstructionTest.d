import std.stdio;

import core.cpu.Instruction;
import core.cpu.InstructionSwitch;
import core.cpu.InstructionTable;

uint[32] Registers;

alias Registers R;

void OP_ADD(OPCODE o) {
	R[o.RD] = R[o.RS] + R[o.RT];
}

void OP_ADDI(OPCODE o) {
	R[o.RT] = R[o.RS] + o.IMM;
}

void OP_UNK(OPCODE o) {
	writefln("Unknown operator (%d)", o.v);
}

// http://svn.ps2dev.org/filedetails.php?repname=psp&path=/trunk/prxtool/disasm.C&rev=0&sc=0

//debug = GeneratedSwitch;

debug (GeneratedSwitch) {
	pragma(msg, "{{{");
	pragma(msg, InstructionSwitch.genSwitch(PspInstructions));
	pragma(msg, "}}}");
	void execute(OPCODE o) { }
} else {
	void execute(OPCODE o) {
		mixin(core.cpu.InstructionSwitch.genSwitch("OP_", PspInstructions));
	}
}

void main() {
	execute(OPCODE(0x_00ffffff));
	//mixin(Instruction.genSwitch(PspInstructions));
}
