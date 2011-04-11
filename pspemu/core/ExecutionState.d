module pspemu.core.ExecutionState;

import pspemu.All;

class ExecutionState : PspHardwareComponent, IDebugSource {
	string threadName;
	Thread thread;

	/**
	 * Registers.
	 */
	Registers registers;

	/**
	 * Memory.
	 */
	Memory memory;
	
	/**
	 * CPU.
	 */
	Cpu cpu;

	/**
	 * GPU.
	 */
	Gpu gpu;

	/**
	 * Display.
	 */
	Display display;
	
	/**
	 * Controller.
	 */
	IController controller;
	
	/**
	 * Interrupts.
	 */
	Interrupts interrupts;

	/**
	 * SystemHLE.
	 */
	SystemHLE systemHLE;

	/**
	 * lastValidPC.
	 */
	uint lastValidPC = 0;
	
	static ExecutionState forCurrentThread() {
		throw(new Exception("Not Implemented"));
	}
	
	void execute() {
		cpu.execute(this);
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
	
	IDebugSource debugSource;

	bool lookupDebugSourceLine(ref DebugSourceLine debugSourceLine, uint address) {
		if (!debugSource) return false;
		return debugSource.lookupDebugSourceLine(debugSourceLine, address);
	}

	bool lookupDebugSymbol(ref DebugSymbol debugSymbol, uint address) {
		if (!debugSource) return false;
		return debugSource.lookupDebugSymbol(debugSymbol, address);
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
		Instruction instruction = void; instruction.v = memory.tread!(uint)(PC);
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
	
	mixin BreakPointStuff;
}
