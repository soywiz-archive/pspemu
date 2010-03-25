module pspemu.core.cpu.Cpu;

const uint THREAD0_CALL_MASK = 0xFFFF;
//const uint THREAD0_CALL_MASK = 0xFF;

//debug = DEBUG_GEN_SWITCH;
version = ENABLE_BREAKPOINTS;

// Hack. It shoudln't be here.
// Create a PspHardwareComponents class with all the components there.
import pspemu.core.gpu.Gpu;
import pspemu.models.IDisplay;
import pspemu.models.IController;
import pspemu.models.ISyscall;

import pspemu.models.IDebugSource;

import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Table;
import pspemu.core.cpu.Switch;
import pspemu.core.cpu.Assembler;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Utils;
import pspemu.core.Memory;

import core.thread;
import pspemu.utils.Utils;

// OPS.
import pspemu.core.cpu.Utils;
import pspemu.core.cpu.Interrupts;
import pspemu.core.cpu.ops.Alu;
import pspemu.core.cpu.ops.Branch;
import pspemu.core.cpu.ops.Jump;
import pspemu.core.cpu.ops.Memory;
import pspemu.core.cpu.ops.Misc;
import pspemu.core.cpu.ops.Fpu;
import pspemu.core.cpu.ops.VFpu;
import pspemu.core.cpu.ops.Unimplemented;

// For breakpoints.
import pspemu.core.cpu.Disassembler;

import std.stdio, std.string, std.math;

version (ENABLE_BREAKPOINTS) {
	import pspemu.core.cpu.InstructionCounter;
}

/**
 * Class that will be on charge of the emulation of Allegrex main CPU.
 */
class Cpu : IDebugSource {
	mixin PspHardwareComponent;

	/**
	 * Registers.
	 */
	Registers registers;

	/**
	 * Memory.
	 */
	Memory memory;

	/**
	 * Gpu.
	 */
	Gpu gpu;

	IDisplay display;
	
	IController controller;
	
	ISyscall syscall;
	
	Interrupts interrupts;
	
	mixin DebugSourceProxy;

	bool running = true;

	void stop() {
		running = false;
	}

	/**
	 * Constructor. It will create the registers and the memory.
	 *
	 * @param  memory  Optional. A Memory object.
	 */
	this(Memory memory, Gpu gpu, IDisplay display, IController controller) {
		this.interrupts = new Interrupts();
		this.registers  = new Registers();
		this.memory     = memory;
		this.gpu        = gpu;
		this.display    = display;
		this.controller = controller;
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

	/*void opDispatch(string s)() {
		//.writefln("Unimplemented CPU instruction '%s'", s);
		//assert(0, std.string.format("Unimplemented CPU instruction '%s'", s));
	}*/

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
		auto cpu       = this;

		// Declaration for instruction struct that will allow to decode instructions easily.
		Instruction instruction = void;

		// Operations.
		mixin TemplateCpu_ALU;
		mixin TemplateCpu_BRANCH;
		mixin TemplateCpu_JUMP;
		mixin TemplateCpu_MEMORY;
		mixin TemplateCpu_MISC;
		mixin TemplateCpu_FPU;
		mixin TemplateCpu_VFPU;
		mixin TemplateCpu_UNIMPLEMENTED;

		// Will execute instructions until count reach zero or an exception is thrown.
		//writefln("Execute: %08X", count);
		while (count--) {
			// Process IRQ (Interrupt ReQuest)

			// Add a THREAD Interrupt (to switch threads)
			if ((count & THREAD0_CALL_MASK) == 0) interrupts.queue(Interrupts.Type.THREAD0);

			// Process interrupts if there are pending interrupts
			if (interrupts.InterruptFlag) interrupts.process();

			version (ENABLE_BREAKPOINTS) {
				if (checkBreakpoints) {
					breakPointPrevPC = registers.PC;
					if (traceStep) {
						if (breakpointRegisters) breakpointRegisters.copyFrom(registers);
						//breakpointStep.registers.
					}
				}
			}
			
			if (!running) throw(new HaltException("stop"));

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
		//writefln("Execute: end");
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
			checkBreakpoints = true;
		}
		bool checkBreakpoint(uint PC) {
			if (breakpointRegisters is null) breakpointRegisters = new Registers;
			if (breakpoints.length == 0) return false;
			auto bp = PC in breakpoints;
			if (bp is null) return false;
			if (bp.traceStep) {
				traceStep = true;
				breakpointStep = *bp;
				breakpointRegisters.copyFrom(registers);
			}
			trace(*bp, PC, false);
			return true;
		}

		version (ENABLE_BREAKPOINTS) {
			InstructionCounter instructionCounter;
		}
		
		void trace(BreakPoint bp, uint PC, bool traceOnlyIfChanged = false) {
			version (ENABLE_BREAKPOINTS) {
				if (instructionCounter is null) instructionCounter = new InstructionCounter();
				Instruction instruction = void; instruction.v = memory.read32(PC);
				instructionCounter.count(instruction);
			}
			if (traceOnlyIfChanged && bp.traceRegisters.length) {
				bool cancel = true;
				foreach (reg; bp.traceRegisters) {
					// Float
					if (reg[0] == 'f') {
						uint regIndex = Registers.FP.getAlias(reg);
						if (breakpointRegisters.F[regIndex] != registers.F[regIndex]) {
							breakpointRegisters.F[regIndex] = registers.F[regIndex];
							//writefln("changed %s", reg);
							cancel = false;
							//break;
						}
					}
					// Integer
					else {
						if (breakpointRegisters[reg] != registers[reg]) {
							breakpointRegisters[reg] = registers[reg];
							//writefln("changed %s", reg);
							cancel = false;
							//break;
						}
					}
				}
				if (cancel) return;
			}
			if (bp.traceRegisters.length) {
				foreach (k, reg; bp.traceRegisters) {
					if (k != 0) writef(",");
					if (reg[0] == 'f') {
						writef("%s=%f", reg, registers.F[Registers.FP.getAlias(reg)]);
					} else {
						writef("%s=%08X", reg, registers[reg]);
					}
				}
			} else {
				/*
				foreach (k, reg; ["f0", "f1", "f12"]) {
					if (k != 0) writef(",");
					if (reg[0] == 'f') {
						int regIndex = Registers.FP.getAlias(reg);
						writef("%s(%d)=%f", reg, regIndex, registers.F[regIndex]);
					} else {
						writef("%s=%08X", reg, registers[reg]);
					}
				}
				*/
			}
			writef(" :: ");
			AllegrexDisassembler dissasembler;
			if (dissasembler is null) dissasembler = new AllegrexDisassembler(memory);
			dissasembler.registersType = bp.registersType;
			string dis = dissasembler.dissasmSimple(PC);
			
			writef("%08X: ", PC);
			writef("%s", dis);
			int count = 30 - dis.length;
			for (int n = 0; n < count; n++) writef(" ");
			
			writef(" | ");
			
			DebugSourceLine debugSourceLine = void;
			if (lookupDebugSourceLine(debugSourceLine, PC)) {
				writef(" %s", debugSourceLine);
			} else {
				writef(" --");
			}

			writef(" | ");
			
			if (breakpointRegisters) {
				if (0) {
					foreach (k; 0..32) if (breakpointRegisters.R [k] != registers.R [k]) writef(" r%d = 0x%08X, ", k, registers.R[k]);
				} else {
					foreach (k; 0..32) if (breakpointRegisters.R [k] != registers.R [k]) writef(" %s = 0x%08X, ", Registers.aliasesInv[k], registers.R[k]);
				}
				foreach (k; 0..32) if (breakpointRegisters.RF[k] != registers.RF[k]) writef(" f%d = $f, ", k, registers.F[k]);
				if (breakpointRegisters.HILO != registers.HILO) writef(" hilo = 0x%016X, ",registers.HILO);
			}
			
			writefln("");
		}
	}
	mixin BreakPointStuff;
	
	void run() {
		//Thread.sleep(2000_0000);
		//Sleep(2000);
		try {
			_running = true;
			execute();
		} catch (Object o) {
			writefln("CPU Error: %s", o.toString());
			registers.dump();
			auto dissasembler = new AllegrexDisassembler(memory);
			dissasembler.registersType = AllegrexDisassembler.RegistersType.Symbolic;
			dissasembler.dump(registers.PC, -6, 6);
			writefln("CPU Error: %s", o.toString());
		} finally {
			.writefln("End CPU executing.");
			stop();
			gpu.stop();
			/*
			cpu.stop();
			Application.exit();
			*/
		}
	}
}

// Shows the generated switch.
debug (DEBUG_GEN_SWITCH) {
	pragma(msg, genSwitch(PspInstructions));
}
