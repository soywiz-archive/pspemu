module pspemu.core.cpu.interpreter.ops.Cpu_Special;

import std.stdio;

// http://pspemu.googlecode.com/svn/branches/old/src/core/cpu.d
// http://pspemu.googlecode.com/svn/branches/old/util/gen/impl/SPECIAL
// http://pspemu.googlecode.com/svn/branches/old/util/gen/impl/MISC
template TemplateCpu_SPECIAL() {
	// sceKernelSuspendInterrupts
	void OP_MFIC() {
		registers[instruction.RT] = registers.IC;
		registers.pcAdvance(4);
	}

	void OP_MTIC() {
		registers.IC = registers[instruction.RT];
		registers.pcAdvance(4);
	}

	void OP_BREAK() {
		registers.pcAdvance(4);
		throw(new HaltException("BREAK"));
	}

	void OP_DBREAK() {
		registers.pcAdvance(4);
		throw(new HaltException("DBREAK"));
	}

	void OP_HALT() {
		registers.pcAdvance(4);
		throw(new HaltException("HALT"));
	}

	void OP_SYNC() {
		std.stdio.writefln("Unimplemented SYNC");
		registers.pcAdvance(4);
	}

	void OP_SYSCALL() {
		registers.pcAdvance(4);
		registers.EXECUTED_SYSCALL_COUNT_THIS_THREAD++;
		if (threadState.emulatorState.syscall is null) {
			std.stdio.writefln("Syscall handler not set");
		} else {
			threadState.emulatorState.syscall.syscall(cpuThread, instruction.CODE);
		}
	}

	/*
	// Inlined.
	void OP_UNK() {
		.writefln("Unknown operation 0x%08X at 0x%08X", instruction.v, registers.PC);
		version (STOP_AT_UNKNOWN_INSTRUCTION) throw(new Exception(std.string.format("Unknown operation 0x%08X at 0x%08X", instruction.v, registers.PC)));
		registers.pcAdvance(4);
	}
	*/
}
