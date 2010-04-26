module pspemu.hle.Utils;

import pspemu.core.Memory;
import pspemu.core.cpu.Interrupts;
import pspemu.hle.Syscall;

/**
 * Utility for creating an interrupt callback that will run 
 */
Interrupts.Callback createUserInterruptCallback(Cpu cpu, Memory.Pointer callback, uint[] params = []) {
	return {
		Syscall(0x1001); // _pspemuHLEInterruptCallbackEnter
		foreach (n, param; params) {
			cpu.registers.R[4 + n] = param; // a0, a1...
		}
		cpu.registers.ra = 0x08000300; // This address will call 0x1002 (_pspemuHLEInterruptCallbackReturn)
		cpu.setPC(cast(uint)callback);
	};
}
