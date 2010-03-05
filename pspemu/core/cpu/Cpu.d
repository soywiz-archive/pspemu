module pspemu.core.cpu.Cpu;

//debug = DEBUG_GEN_SWITCH;

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

/**
 * Class that will be on charge of the emulation of Allegrex main CPU.
 */
class CPU {
	/**
	 * Registers.
	 */
	Registers registers;

	/**
	 * Memory.
	 */
	Memory    memory;

	/**
	 * Constructor. It will create the registers and the memory.
	 *
	 * @param  memory  Optional. A Memory object.
	 */
	this(Memory memory = null) {
		this.registers = new Registers();
		this.memory    = (memory !is null) ? memory : (new Memory());
	}

	/**
	 * It will reset the cpu status: registers and memory.
	 */
	void reset() {
		registers.reset();
		memory.reset();
	}

	/**
	 * It will reset only registers.
	 */
	void resetFast() {
		registers.reset();
	}

	/**
	 * Will execute a number of instructions.
	 *
	 * Note: Some instructions may throw some kind of exceptions that will break the flow.
	 *
	 * @param  count  Maximum number of instructions to execute.
	 */
	void execute(uint count) {
		// Shortcuts for registers and memory.
		auto registers = this.registers;
		auto memory    = this.memory;

		// Declaration for instruction struct that will allow to decode instructions easily.
		Instruction instruction = void;

		// Operations.
		mixin TemplateCpu_ALU;
		mixin TemplateCpu_BRANCH;
		mixin TemplateCpu_JUMP;
		mixin TemplateCpu_MEMORY;
		mixin TemplateCpu_MISC;
		mixin TemplateCpu_FPU;

		// Will execute instructions until count reach zero or an exception is thrown.
		while (count--) {
			// TODO: Process IRQ (Interrupt ReQuest)
			instruction.v = memory.read32(registers.PC);
			mixin(genSwitch(PspInstructions));
		}
	}

	/**
	 * Will execute forever (Until a unhandled Exception is thrown).
	 */
	void execute() {
		while (true) execute(0x_FFFFFFFF);
	}

	/**
	 * Executes a single instruction. Shortcut for execute(1).
	 */
	void executeSingle() {
		execute(1);
	}

	/**
	 * Executes until halt. It will execute until a HaltException is thrown.
	 * The instructions that throw HaltException are: BREAK, DBREAK, HALT.
	 */
	void executeUntilHalt() {
		try { execute(); } catch (HaltException he) { }
	}
}

// Shows the generated switch.
debug (DEBUG_GEN_SWITCH) {
	pragma(msg, genSwitch(PspInstructions));
}
