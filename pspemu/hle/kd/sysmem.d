module pspemu.hle.kd.sysmem; // kd/sysmem.prx (sceSystemMemoryManager)

import pspemu.hle.Module;

class SysMemForKernel : Module {
}

class SysMemUserForUser : SysMemForKernel {
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