module pspemu.core.cpu.cpu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.cpu_alu;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

import std.stdio, std.string;

class CPU {
	Registers registers;
	Memory    memory;

	this() {
		registers = new Registers();
		memory    = new Memory();
	}

	void executeSingle() {
		uint PC = registers.PC, nPC = registers.nPC;
		Registers registers = this.registers;
		Instruction instruction = void;
		instruction.v = memory.read32(PC);
		void advance_pc(int offset) { PC = nPC; nPC += offset; }
		mixin TemplateCpu_ALU;
	}
}

unittest {
	writefln("Unittesting: CPU...");
	scope cpu = new CPU();
}

//unittest { static void main() { } }