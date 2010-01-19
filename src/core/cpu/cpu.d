module pspemu.core.cpu.cpu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.cpu_table;
import pspemu.core.cpu.cpu_switch;
import pspemu.core.cpu.cpu_ops_alu;
import pspemu.core.cpu.cpu_ops_branch;
import pspemu.core.cpu.cpu_asm;
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
		mixin TemplateCpu_BRANCH;
		void OP_UNK() { writefln("Unknown operation %s", instruction); }

		while (count--) {
			instruction.v = memory.read32(registers.PC);
			void EXEC() { mixin(genSwitch(PspInstructions)); }
			EXEC();
		}
	}

	void executeSingle() {
		execute(1);
	}
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope cpu = new CPU(); foreach (n; 0..32) cpu.registers[n] = 0;

	scope assembler = new AllegrexAssembler(cpu.memory);

	// (v0 = (7 + 11 - 5)) == 13
	writefln("  (v0 = (7 + 11 - 5)) == 13");
	{
		assembler.startSegment("code", Memory.mainMemoryAddress);
		assembler("addi a0, zero, 7");
		assembler("addi a1, zero, 11");
		assembler("add v0, a0, a1  ");
		assembler("addi v0, v0, -5 ");

		cpu.registers.set_pc(Memory.mainMemoryAddress);
		cpu.execute(4);
		assert(cpu.registers["v0"] == 13);
	}
}
