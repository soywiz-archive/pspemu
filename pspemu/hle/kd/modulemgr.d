module pspemu.hle.kd.modulemgr; // kd/modulemgr.prx (sceModuleManager)

import pspemu.hle.Module;

class ModuleMgrForUser : Module {
	this() {
		mixin(register(0xD675EBB8, "sceKernelSelfStopUnloadModule"));
	}

	void sceKernelSelfStopUnloadModule() {
		throw(new Exception("sceKernelSelfStopUnloadModule"));
	}
}

class ModuleMgrForKernel : ModuleMgrForUser {
}

static this() {
	mixin(Module.registerModule("ModuleMgrForUser"));
	mixin(Module.registerModule("ModuleMgrForKernel"));
}