module pspemu.hle.kd.modulemgr; // kd/modulemgr.prx (sceModuleManager)

import pspemu.hle.Module;

debug = DEBUG_SYSCALL;

class ModuleMgrForUser : Module {
	void initNids() {
		mixin(registerd!(0xD675EBB8, sceKernelSelfStopUnloadModule));
		mixin(registerd!(0xB7F46618, sceKernelLoadModuleByID));
		mixin(registerd!(0x977DE386, sceKernelLoadModule));
		mixin(registerd!(0x50F0C1EC, sceKernelStartModule));
		mixin(registerd!(0xD1FF982A, sceKernelStopModule));
		mixin(registerd!(0x2E0911AA, sceKernelUnloadModule));
		mixin(registerd!(0xD8B73127, sceKernelGetModuleIdByAddressFunction));
		mixin(registerd!(0xF0A26395, sceKernelGetModuleIdFunction));
		mixin(registerd!(0x8F2DF740, ModuleMgrForUser_8F2DF740));
	}
	
	void sceKernelGetModuleIdByAddressFunction() {
		unimplemented();
	}

	void sceKernelGetModuleIdFunction() {
		unimplemented();
	}

	void ModuleMgrForUser_8F2DF740() {
		unimplemented();
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

	/**
	 * Load a module from the given file UID.
	 *
	 * @param fid - The module's file UID.
	 * @param flags - Unused, always 0.
	 * @param option - Pointer to an optional ::SceKernelLMOption structure.
	 *
	 * @return The UID of the loaded module on success, otherwise one of ::PspKernelErrorCodes.
	 */
	SceUID sceKernelLoadModuleByID(SceUID fid, int flags, SceKernelLMOption *option) {
		unimplemented();
		return 0;
	}

	/**
	 * Load a module.
	 * @note This function restricts where it can load from (such as from flash0) 
	 * unless you call it in kernel mode. It also must be called from a thread.
	 * 
	 * @param path - The path to the module to load.
	 * @param flags - Unused, always 0 .
	 * @param option  - Pointer to a mod_param_t structure. Can be NULL.
	 *
	 * @return The UID of the loaded module on success, otherwise one of ::PspKernelErrorCodes.
	 */
	SceUID sceKernelLoadModule(string path, int flags, SceKernelLMOption* option) {
		unimplemented();
		return -1;
	}

	/**
	 * Start a loaded module.
	 *
	 * @param modid - The ID of the module returned from LoadModule.
	 * @param argsize - Length of the args.
	 * @param argp - A pointer to the arguments to the module.
	 * @param status - Returns the status of the start.
	 * @param option - Pointer to an optional ::SceKernelSMOption structure.
	 *
	 * @return ??? on success, otherwise one of ::PspKernelErrorCodes.
	 */
	int sceKernelStartModule(SceUID modid, SceSize argsize, void *argp, int *status, SceKernelSMOption *option) {
		unimplemented();
		return -1;
	}

	/**
	 * Stop a running module.
	 *
	 * @param modid - The UID of the module to stop.
	 * @param argsize - The length of the arguments pointed to by argp.
	 * @param argp - Pointer to arguments to pass to the module's module_stop() routine.
	 * @param status - Return value of the module's module_stop() routine.
	 * @param option - Pointer to an optional ::SceKernelSMOption structure.
	 *
	 * @return ??? on success, otherwise one of ::PspKernelErrorCodes.
	 */
	int sceKernelStopModule(SceUID modid, SceSize argsize, void *argp, int *status, SceKernelSMOption *option) {
		unimplemented();
		return -1;
	}

	/**
	 * Unload a stopped module.
	 *
	 * @param modid - The UID of the module to unload.
	 *
	 * @return ??? on success, otherwise one of ::PspKernelErrorCodes.
	 */
	int sceKernelUnloadModule(SceUID modid) {
		unimplemented();
		return -1;
	}
}

class ModuleMgrForKernel : ModuleMgrForUser {
}

struct SceKernelLMOption {
	SceSize size;
	SceUID  mpidtext;
	SceUID  mpiddata;
	uint    flags;
	char    position;
	char    access;
	char    creserved[2];
}

struct SceKernelSMOption {
	SceSize size;
	SceUID  mpidstack;
	SceSize stacksize;
	int     priority;
	uint    attribute;
}

struct SceModuleInfo {
	ushort modattribute;
	ubyte  modversion[2];
	char   modname[27];
	char   terminal;
	void*  gp_value;
	void*  ent_top;
	void*  ent_end;
	void*  stub_top;
	void*  stub_end;
}

enum PspModuleInfoAttr {
	PSP_MODULE_USER			= 0,
	PSP_MODULE_NO_STOP		= 0x0001,
	PSP_MODULE_SINGLE_LOAD	= 0x0002,
	PSP_MODULE_SINGLE_START	= 0x0004,
	PSP_MODULE_KERNEL		= 0x1000,
};

static this() {
	mixin(Module.registerModule("ModuleMgrForUser"));
	mixin(Module.registerModule("ModuleMgrForKernel"));
}