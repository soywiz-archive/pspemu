module pspemu.hle.kd.loadexec.LoadExec; // kd/loadexec.prx (sceLoadExec)

import pspemu.hle.ModuleNative;

//debug = DEBUG_SYSCALL;

import pspemu.hle.ModuleNative;

import pspemu.hle.kd.loadexec.Types;

class LoadExecForUser : HleModuleHost {
	mixin TRegisterModule;

	void initNids() {
		mixin(registerFunction!(0xBD2F1094, sceKernelLoadExec));
		mixin(registerFunction!(0x2AC9954B, sceKernelExitGameWithStatus));
		mixin(registerFunction!(0x05572A5F, sceKernelExitGame));
		mixin(registerFunction!(0x4AC57943, sceKernelRegisterExitCallback));
	}

	void sceKernelExitGameWithStatus(int status) {
		throw(new HaltException("sceKernelExitGameWithStatus"));
	}

	/** 
	  * Execute a new game executable, limited when not running in kernel mode.
	  * 
	  * @param file  - The file to execute.
	  * @param param - Pointer to a ::SceKernelLoadExecParam structure, or NULL.
	  *
	  * @return < 0 on error, probably.
	  *
	  */
	int sceKernelLoadExec(string file, SceKernelLoadExecParam *param) {
		//hleEmulatorState.moduleLoader.load
		//public ModulePsp loadModuleFromVfs(string fsProgramPath, uint argc, uint argv, string pspModulePath = null) {
		uint argc, argv;

		if (param is null) {
			argc = cast(uint)param.args;
			argv = cast(uint)param.argp;
		}
		
		logInfo("sceKernelLoadExec('%s')", file);
		hleEmulatorState.moduleManager.loadModuleFromVfs(file, argc, argv);
		
		//unimplemented();
		return 0;
	}

	/**
	 * Exit game and go back to the PSP browser.
	 *
	 * @note You need to be in a thread in order for this function to work
	 *
	 */
	void sceKernelExitGame() {
		throw(new HaltException("sceKernelExitGame"));
	}

	/**
	 * Register callback
	 *
	 * @note By installing the exit callback the home button becomes active. However if sceKernelExitGame
	 * is not called in the callback it is likely that the psp will just crash.
	 *
	 * @par Example:
	 * @code
	 * int exit_callback(void) { sceKernelExitGame(); }
	 *
	 * cbid = sceKernelCreateCallback("ExitCallback", exit_callback, NULL);
	 * sceKernelRegisterExitCallback(cbid);
	 * @endcode
	 *
	 * @param cbid Callback id
	 * @return < 0 on error
	 */
	int sceKernelRegisterExitCallback(int cbid) {
		//unimplemented();
		return 0;
	}
}

class LoadExecForKernel : LoadExecForUser {
	mixin TRegisterModule;
}
