module pspemu.hle.kd.loadexec; // kd/loadexec.prx (sceLoadExec)

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class LoadExecForUser : Module {
	this() {
		mixin(register(0xBD2F1094, "sceKernelLoadExec"));
		mixin(register(0x2AC9954B, "sceKernelExitGameWithStatus"));
		mixin(registerd!(0x05572A5F, sceKernelExitGame));
		mixin(registerd!(0x4AC57943, sceKernelRegisterExitCallback));
	}

	/**
	 * Exit game and go back to the PSP browser.
	 *
	 * @note You need to be in a thread in order for this function to work
	 *
	 */
	void sceKernelExitGame() {
		throw(new Exception("sceKernelExitGame"));
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
		return 0;
	}
}

class LoadExecForKernel : LoadExecForUser {
}

static this() {
	mixin(Module.registerModule("LoadExecForUser"));
	mixin(Module.registerModule("LoadExecForKernel"));
}