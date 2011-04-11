module pspemu.hle.SystemHLE;

import pspemu.All;

class SystemHLE {
	PspUID pspUID;
	ISyscall syscall;
	ModuleManager moduleManager;
	MemoryManager memoryManager;
	
	this(PspUID pspUID, ISyscall syscall, ModuleManager moduleManager, MemoryManager memoryManager) {
		this.pspUID = pspUID;
		this.syscall = syscall;
		this.moduleManager = moduleManager;
		this.memoryManager = memoryManager;
	}
}