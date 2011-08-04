module pspemu.interfaces.ISyscall;

import pspemu.core.cpu.Registers;

interface ISyscall {
	void syscall(Registers registers, int syscallNum);
}