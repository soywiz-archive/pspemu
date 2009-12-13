import std.stdio;

import core.cpu.Instruction;
import core.cpu.InstructionSwitch;
import core.cpu.InstructionTable;

uint[32] Registers;
alias Registers R;

void OP_ADD(Instruction i) {
	R[i.RD] = R[i.RS] + R[i.RT];
}

void OP_ADDI(Instruction i) {
	R[i.RT] = R[i.RS] + i.IMM;
}

void OP_UNK(Instruction i) {
	writefln("Unknown opcode (0x%08X)", i.v);
}

//debug = GeneratedSwitch;

debug (GeneratedSwitch) {
	pragma(msg, "{{{");
	pragma(msg, core.cpu.InstructionSwitch.genSwitch("OP_", PspInstructions));
	pragma(msg, "}}}");
	void execute(Instruction i) { }
} else {
	void execute(Instruction i) {
		mixin(core.cpu.InstructionSwitch.genSwitch("OP_", PspInstructions));
	}
}

void main() {
	execute(Instruction(0x_00ffffff));
	//mixin(Instruction.genSwitch(PspInstructions));
}
