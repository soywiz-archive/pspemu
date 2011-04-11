module pspemu.hle.Utils;

import pspemu.core.cpu.Cpu;
import pspemu.core.Memory;
import pspemu.core.cpu.Interrupts;
import pspemu.hle.Syscall;

import pspemu.hle.Module;
import pspemu.hle.kd.threadman;

import std.stdio;

/**
 * Utility for creating an interrupt callback that will run 
 */
Interrupts.Callback createUserInterruptCallback(ModuleManager moduleManager, Cpu cpu, Memory.Pointer callback, uint[] params = []) {
	return {
		cpu.syscall(0x1001); // _pspemuHLEInterruptCallbackEnter
		foreach (n, param; params) {
			executionState.registers.R[4 + n] = param; // a0, a1...
		}
		executionState.registers.RA = 0x08000300; // This address will call 0x1002 (_pspemuHLEInterruptCallbackReturn)
		executionState.registers.pcSet(cast(uint)callback);
		//writefln("PC: %08X. %08X", executionState.registers.PC, cast(uint)callback);
		//moduleManager.get!(ThreadManForUser).threadManager.dumpThreads();
	};
}
