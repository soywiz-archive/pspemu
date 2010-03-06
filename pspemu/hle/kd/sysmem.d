module pspemu.hle.kd.sysmem; // kd/sysmem.prx (sceSystemMemoryManager)

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