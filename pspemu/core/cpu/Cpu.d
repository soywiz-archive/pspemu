module pspemu.core.cpu.Cpu;

import core.thread;

// Hack. It shoudln't be here.
// Create a PspHardwareComponents class with all the components there?
import pspemu.core.gpu.Gpu;
import pspemu.models.IDisplay;
import pspemu.models.IController;
import pspemu.models.ISyscall;

// For breakpoints.
import pspemu.core.cpu.Disassembler;
import pspemu.core.cpu.InstructionCounter;

import pspemu.models.IDebugSource;

import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Assembler;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Interrupts;
import pspemu.core.Memory;

import pspemu.utils.Utils;
import pspemu.utils.Logger;

import std.stdio, std.string, std.stream;

abstract class Cpu : PspHardwareComponent, IDebugSource {
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

	Display display;
	
	IController controller;
	
	ISyscall syscall;
	
	Interrupts interrupts;

	uint lastValidPC = 0;
	
	mixin DebugSourceProxy;

	/**
	 * Constructor. It will create the registers and the memory.
	 *
	 * @param  memory  Optional. A Memory object.
	 */
	this(Memory memory, Gpu gpu, Display display, IController controller) {
		this.interrupts = new Interrupts();
		this.registers  = new Registers();
		this.memory     = memory;
		this.gpu        = gpu;
		this.display    = display;
		this.controller = controller;
		this.errorHandler = &defaultErrorHandler;
	}

	/**
	 * It will reset the cpu status: registers and memory.
	 */
	void reset() {
		registers.reset();
		memory.reset();
		interrupts.reset();
		gpu.reset();
		display.reset();
		controller.reset();
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
	
	abstract void execute(uint count);


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
	
	void queueCallbacks(uint[] callbacks, uint[] params = []) {
		assert(callbacks.length <= 1);
		if (callbacks.length == 1) {
			writefln("queueCallbacks(%s)", callbacks);
			//callbacks[0]
		}
	}

	mixin BreakPointStuff;
	
	void delegate(Cpu cpu, Object error) errorHandler;
	
	void defaultErrorHandler(Cpu cpu, Object error) {
		cpu.registers.dump();
		auto dissasembler = new AllegrexDisassembler(cpu.memory);
		writefln("CPU Error: %s", error.toString());
		dissasembler.registersType = AllegrexDisassembler.RegistersType.Symbolic;
		dissasembler.dump(cpu.registers.PC, -3, +3);
		writefln("CPU Error: %s", error.toString());
	}
	
	override void run() {
		//Thread.getThis.priority = +1;

		try {
			componentInitialized = true;
			execute();
		} catch (Object error) {
			if (errorHandler !is null) errorHandler(this, error);
			//throw(error);
		} finally {
			Logger.log(Logger.Level.DEBUG, "Cpu", "End CPU executing.");
			stop();
			gpu.stop();
		}
	}
}

template BreakPointStuff() {
	uint breakPointPrevPC;

	static struct BreakPoint {
		uint PC;
		string[] traceRegisters;
		bool traceStep = false;
		void delegate() callback;
		AllegrexDisassembler.RegistersType registersType = AllegrexDisassembler.RegistersType.Symbolic;
		//disassembler
		//dissasembler.registersType = AllegrexDisassembler.RegistersType.Symbolic;
	}
	Registers breakpointRegisters;
	BreakPoint breakpointStep;
	BreakPoint[uint] breakpoints;
	bool checkBreakpoints;
	bool traceStep;
	
	void startTracing() {
		traceStep = true;
		checkBreakpoints = true;
		//checkBreakpoints = true;
		//addBreakpoint(cpu.BreakPoint(registers.PC, [], true));	}
	}

	void stopTracing() {
		checkBreakpoints = false;
		instructionCounter.dump();
	}
	
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

	InstructionCounter instructionCounter;
	
	void trace(BreakPoint bp, uint PC, bool traceOnlyIfChanged = false) {
		if (breakpointRegisters is null) breakpointRegisters = new Registers;
		if (bp.callback) bp.callback();
		if (instructionCounter is null) instructionCounter = new InstructionCounter();
		Instruction instruction = void; instruction.v = memory.read32(PC);
		instructionCounter.count(instruction);
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
			//writef("changes: ");
			
			bool showRegister(int index) {
				//if (index == 29) return true;
				//if (index == 31) return true;
				return breakpointRegisters.R[index] != registers.R[index];
			}
			
			foreach (index; 0..32) if (showRegister(index)) {
				if (dissasembler.registersType == AllegrexDisassembler.RegistersType.Simple) {
					writef(" r%d = 0x%08X, ", index, registers.R[index]);
				} else {
					writef(" %s = 0x%08X, ", Registers.aliasesInv[index], registers.R[index]);
				}
			}
			foreach (k; 0..32) if (breakpointRegisters.RF[k] != registers.RF[k]) writef(" f%d = $f, ", k, registers.F[k]);
			if (breakpointRegisters.HILO != registers.HILO) writef(" hilo = 0x%016X, ",registers.HILO);
		}
		
		writefln("");
	}
}
