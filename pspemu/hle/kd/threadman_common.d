module pspemu.hle.kd.threadman_common;

public import std.algorithm;
public import core.thread;

public import pspemu.hle.Module;
public import pspemu.core.cpu.Registers;

public import pspemu.hle.kd.sysmem; // kd/sysmem.prx (SysMemUserForUser)

/*template ThreadSubsystemManager() {
	Module threadManForUser;
	Cpu cpu() { return threadManForUser.cpu; }

	public this(Module threadManForUser) {
		this.threadManForUser = threadManForUser;
	}
}*/
