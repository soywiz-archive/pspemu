module pspemu.hle.kd.modulemgr; // kd/modulemgr.prx (sceModuleManager)

import pspemu.hle.Module;

class ModuleMgrForUser : Module {
	void initNids() {
		mixin(registerd!(0xD675EBB8, sceKernelSelfStopUnloadModule));
	}

	/**
	 * Stop and unload the current module.
	 *
	 * @param unknown - Unknown (I've seen 1 passed).
	 * @param argsize - Size (in bytes) of the arguments that will be passed to module_stop().
	 * @param argp - Pointer to arguments that will be passed to module_stop().
	 *
	 * @return ??? on success, otherwise one of ::PspKernelErrorCodes.
	 */
	int sceKernelSelfStopUnloadModule(int unknown, SceSize argsize, void *argp) {
		throw(new Exception("sceKernelSelfStopUnloadModule"));
		return 0;
	}
}

class ModuleMgrForKernel : ModuleMgrForUser {
}

static this() {
	mixin(Module.registerModule("ModuleMgrForUser"));
	mixin(Module.registerModule("ModuleMgrForKernel"));
}