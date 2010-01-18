module pspemu.core.cpu.cpu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.cpu_table;
import pspemu.core.cpu.cpu_switch;
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

	void execute(uint count = 0x_FFFFFFFF) {
		Registers registers = this.registers;
		Instruction instruction = void;

		// Operations.
		mixin TemplateCpu_ALU;
		void OP_UNK() { writefln("Unknown operation %s", instruction); }

		while (count--) {
			instruction.v = memory.read32(registers.PC);
			mixin(genSwitch(PspInstructions));
		}
	}

	void executeSingle() {
		execute(1);
	}
}

unittest {
	writefln("Unittesting: core.cpu.cpu...");
	scope cpu = new CPU();
	cpu.memory.position = Memory.mainMemoryAddress;
	cpu.memory.write(cast(uint)0x_FFFFFFFF);
	cpu.memory.write(cast(uint)0x_FFFFFFFF);
	
	foreach (n; 0..32) cpu.registers[n] = n;

	cpu.registers.set_pc(Memory.mainMemoryAddress);
	cpu.executeSingle();
}

//unittest { static void main() { } }