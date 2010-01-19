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

	void reset() {
		registers.reset();
		memory.reset();
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
	scope cpu = new CPU();
	scope assembler = new AllegrexAssembler(cpu.memory);

	void reset() {
		cpu.reset();
	}

	writefln("  (v0 = (7 + 11 - 5)) == 13");
	{
		reset();

		assembler.assembleBlock(r"
			.text
			addi a0, zero, 7
			addi a1, zero, 11
			add  v0, a0, a1
			addi v0, v0, -5
		");

		cpu.registers.set_pc(assembler.segments["text"]);
		cpu.execute(4);
		//cpu.registers.dump(true);
		assert(cpu.registers["v0"] == 13);
	}

	writefln("  v0 = 2; while (v--);");
	{
		reset();

		assembler.assembleBlock(r"
			.text
			addi v0, zero, 2
			loop:
				bgez v0, loop
				addi v0, v0, -1
		");

		cpu.registers.set_pc(assembler.segments["text"]);
		foreach (step, expectedValue; [2, 2, 1, 1, 0, 0]) {
			//writefln("PC: %08X, nPC: %08X, STEP: %d", cpu.registers.PC, cpu.registers.nPC, step);
			cpu.executeSingle();
			assert(cpu.registers["v0"] == expectedValue, format("step: %d; v0 = %d; v0 != %d", step, cpu.registers["v0"], expectedValue));
		}
	}
}
