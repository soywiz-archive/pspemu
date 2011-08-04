module pspemu.core.cpu.ISyscall;

import pspemu.core.ThreadState;
import pspemu.core.cpu.CpuThreadBase;

interface ISyscall {
	public void syscall(CpuThreadBase cpuThreadBase, int syscallNum);
}