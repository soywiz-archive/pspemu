module pspemu.core.cpu.Cpu;

//debug = DEBUG_GEN_SWITCH;
version = ENABLE_BREAKPOINTS;

import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Table;
import pspemu.core.cpu.Switch;
import pspemu.core.cpu.Assembler;
import pspemu.core.cpu.Instruction;
import pspemu.core.Memory;

// OPS.
import pspemu.core.cpu.Utils;
import pspemu.core.cpu.ops.Alu;
import pspemu.core.cpu.ops.Branch;
import pspemu.core.cpu.ops.Jump;
import pspemu.core.cpu.ops.Memory;
import pspemu.core.cpu.ops.Misc;
import pspemu.core.cpu.ops.Fpu;

// For breakpoints.
import pspemu.core.cpu.Disassembler;

import std.stdio, std.string, std.math;

/**
 * Class that will be on charge of the emulation of Allegrex main CPU.
 */
class Cpu {
	/**
	 * Registers.
	 */
	Registers registers;

	/**
	 * Memory.
	 */
	Memory    memory;

	bool stop = false;

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
		auto cpu       = this;
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
		writefln("Execute: %08X", count);
		while (count--) {
			// TODO: Process IRQ (Interrupt ReQuest)
			version (ENABLE_BREAKPOINTS) {
				if (checkBreakpoints) {
					breakPointPrevPC = registers.PC;
				}
			}
			
			if (stop) throw(new HaltException("stop"));

			instruction.v = memory.read32(registers.PC);
			mixin(genSwitch(PspInstructions));

			version (ENABLE_BREAKPOINTS) {
				if (checkBreakpoints) {
					if (traceStep) {
						trace(breakpointStep, breakPointPrevPC, true);
					} else {
						if (!checkBreakpoint(breakPointPrevPC)) {
						}
					}
				}
			}
		}
		writefln("Execute: end");
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

	template BreakPointStuff() {
		version (ENABLE_BREAKPOINTS) uint breakPointPrevPC;

		static struct BreakPoint {
			uint PC;
			string[] traceRegisters;
			bool traceStep = false;
			AllegrexDisassembler.RegistersType registersType = AllegrexDisassembler.RegistersType.Symbolic;
			//disassembler
			//dissasembler.registersType = AllegrexDisassembler.RegistersType.Symbolic;
		}
		Registers breakpointRegisters;
		BreakPoint breakpointStep;
		BreakPoint[uint] breakpoints;
		bool checkBreakpoints;
		bool traceStep;

		void addBreakpoint(BreakPoint bp) {
			breakpoints[bp.PC] = bp;
		}
		bool checkBreakpoint(uint PC) {
			if (breakpointRegisters is null) breakpointRegisters = new Registers;
			if (breakpoints.length == 0) return false;
			auto bp = PC in breakpoints;
			if (bp is null) return false;
			if (bp.traceStep) {
				traceStep = true;
				breakpointStep = *bp;
				breakpointRegisters.R[0..32] = registers.R[0..32];
			}
			trace(*bp, PC, false);
			return true;
		}
		void trace(BreakPoint bp, uint PC, bool traceOnlyIfChanged = false) {
			if (traceOnlyIfChanged && bp.traceRegisters.length) {
				bool cancel = true;
				foreach (reg; bp.traceRegisters) {
					if (breakpointRegisters[reg] != registers[reg]) {
						breakpointRegisters[reg] = registers[reg];
						//writefln("changed %s", reg);
						cancel = false;
						//break;
					}
				}
				if (cancel) return;
			}
			foreach (k, reg; bp.traceRegisters) {
				if (k != 0) writef(",");
				writef("%s=%08X", reg, registers[reg]);
			}
			writef(" :: ");
			AllegrexDisassembler dissasembler;
			if (dissasembler is null) dissasembler = new AllegrexDisassembler(memory);
			dissasembler.registersType = bp.registersType;
			dissasembler.dumpSimple(PC);
		}
	}
	mixin BreakPointStuff;
}

// Shows the generated switch.
debug (DEBUG_GEN_SWITCH) {
	pragma(msg, genSwitch(PspInstructions));
}
