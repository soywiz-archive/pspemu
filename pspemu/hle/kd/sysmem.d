module pspemu.hle.kd.sysmem; // kd/sysmem.prx (sceSystemMemoryManager)

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class SysMemUserForUser : Module {
	this() {
		mixin(register(0xA291F107, "sceKernelMaxFreeMemSize"));
		mixin(register(0xF919F628, "sceKernelTotalFreeMemSize"));
		mixin(register(0x237DBD4F, "sceKernelAllocPartitionMemory"));
		mixin(register(0xB6D61D02, "sceKernelFreePartitionMemory"));
		mixin(register(0x9D9A5BA1, "sceKernelGetBlockHeadAddr"));
		mixin(register(0x3FC9AE6A, "sceKernelDevkitVersion"));
	}

	void sceKernelMaxFreeMemSize() {
		cpu.registers.V0 = 8 * 1024 * 1024; // 8 MB
		debug (DEBUG_SYSCALL) .writefln("sceKernelMaxFreeMemSize() == %d", cpu.registers.V0);
	}

	void sceKernelAllocPartitionMemory() {
		// SceUID 	sceKernelAllocPartitionMemory (SceUID partitionid, const char *name, int type, SceSize size, void *addr)
		cpu.registers.V0 = 1; // blockid = 1
		debug (DEBUG_SYSCALL) .writefln("sceKernelAllocPartitionMemory(partitionid=%d, name='%s', type=%d, size=%d, addr=0x%08X) : blockid=%d", param(0), param_p(1), param(2), param(3), param(4), cpu.registers.V0);
	}

	void sceKernelGetBlockHeadAddr() {
		cpu.registers.V0 = 0x08_000000;
		// void * 	sceKernelGetBlockHeadAddr (SceUID blockid)
		debug (DEBUG_SYSCALL) .writefln("sceKernelGetBlockHeadAddr(blockid=%d) : address=0x%08X", param(0), cpu.registers.V0);
	}
}

class SysMemForKernel : Module {
}

class sceSysEventForKernel : Module {
}

class sceSuspendForKernel : Module {
}

class sceSuspendForUser : sceSuspendForKernel {
}

class KDebugForKernel : Module {
}

static this() {
	mixin(Module.registerModule("SysMemForKernel"));
	mixin(Module.registerModule("SysMemUserForUser"));
	mixin(Module.registerModule("sceSysEventForKernel"));
	mixin(Module.registerModule("sceSuspendForKernel"));
	mixin(Module.registerModule("sceSuspendForUser"));
	mixin(Module.registerModule("KDebugForKernel"));
}