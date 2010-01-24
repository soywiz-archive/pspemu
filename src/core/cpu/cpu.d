module pspemu.core.cpu.cpu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.cpu_table;
import pspemu.core.cpu.cpu_switch;
import pspemu.core.cpu.cpu_asm;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

// OPS.
import pspemu.core.cpu.cpu_utils;
import pspemu.core.cpu.cpu_ops_alu;
import pspemu.core.cpu.cpu_ops_branch;
import pspemu.core.cpu.cpu_ops_jump;
import pspemu.core.cpu.cpu_ops_memory;
import pspemu.core.cpu.cpu_ops_misc;
import pspemu.core.cpu.cpu_ops_fpu;

import std.stdio, std.string, std.math;

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

	void resetFast() {
		registers.reset();
		//memory.reset();
	}

	void execute(uint count = 0x_FFFFFFFF) {
		Registers   registers = this.registers;
		Memory      memory    = this.memory;
		Instruction instruction;

		// Operations.
		mixin TemplateCpu_ALU;
		mixin TemplateCpu_BRANCH;
		mixin TemplateCpu_JUMP;
		mixin TemplateCpu_MEMORY;
		mixin TemplateCpu_MISC;
		mixin TemplateCpu_FPU;

		void OP_UNK() {
			.writefln("Unknown operation %s", instruction);
			registers.pcAdvance(4);
		}

		while (count--) {
			instruction.v = memory.read32(registers.PC);
			void EXEC() { mixin(genSwitch(PspInstructions)); }
			EXEC();
		}
	}

	void executeSingle() {
		execute(1);
	}

	void executeUntilHalt() {
		try { execute(); } catch (HaltException he) { }
	}
}
