module pspemu.core.cpu.ISyscall;

import pspemu.core.cpu.Registers;

interface ISyscall {
	public void syscall(Registers registers, int syscallNum);
}