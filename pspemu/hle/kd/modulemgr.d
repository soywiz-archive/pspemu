module pspemu.hle.kd.modulemgr; // kd/modulemgr.prx (sceModuleManager)

import pspemu.hle.Module;

class ModuleMgrForKernel : Module {
}

class ModuleMgrForUser : ModuleMgrForKernel {
}

static this() {
	mixin(Module.registerModule("ModuleMgrForUser"));
	mixin(Module.registerModule("ModuleMgrForKernel"));
}