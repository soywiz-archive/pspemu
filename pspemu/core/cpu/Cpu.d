module pspemu.core.cpu.Cpu;

import pspemu.All;

abstract class Cpu {
	/**
	 * Constructor. It will create the registers and the memory.
	 *
	 * @param  memory  Optional. A Memory object.
	 */
	this() {
	}

	abstract void execute(ExecutionState executionState, uint count);

	/**
	 * Will execute forever (Until a unhandled Exception is thrown).
	 */
	void execute(ExecutionState executionState) {
		while (true) execute(executionState, 0x_FFFFFFFF);
	}

	/**
	 * Executes a single instruction. Shortcut for execute(1).
	 */
	void executeSingle(ExecutionState executionState) {
		execute(executionState, 1);
	}

	/**
	 * Executes until halt. It will execute until a HaltException is thrown.
	 * The instructions that throw HaltException are: BREAK, DBREAK, HALT.
	 */
	void executeUntilHalt(ExecutionState executionState) {
		try { execute(executionState); } catch (HaltException he) { }
	}
	
	/*
	void queueCallbacks(uint[] callbacks, uint[] params = []) {
		assert(callbacks.length <= 1);
		if (callbacks.length == 1) {
			writefln("queueCallbacks(%s)", callbacks);
			//callbacks[0]
		}
	}

	void delegate(Cpu cpu, Object error) errorHandler;
	
	void defaultErrorHandler(Cpu cpu, Object error) {
		executionState.registers.dump();
		auto dissasembler = new AllegrexDisassembler(executionState.memory);
		writefln("CPU Error: %s", error.toString());
		dissasembler.registersType = AllegrexDisassembler.RegistersType.Symbolic;
		dissasembler.dump(executionState.registers.PC, -3, +3);
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
	*/
}
