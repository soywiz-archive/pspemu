module pspemu.hle.kd.threadman_common;

public import pspemu.All;

public import pspemu.hle.kd.sysmem; // kd/sysmem.prx (SysMemUserForUser)


/*template ThreadSubsystemManager() {
	Module threadManForUser;
	Cpu cpu() { return threadManForUser.cpu; }

	public this(Module threadManForUser) {
		this.threadManForUser = threadManForUser;
	}
}*/
