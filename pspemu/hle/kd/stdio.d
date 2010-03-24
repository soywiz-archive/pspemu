module pspemu.hle.kd.stdio; // kd/stdio.prx (sceStdio)

import pspemu.hle.Module;

class StdioForUser : Module {
	void initNids() {
		mixin(registerd!(0x172D316E, sceKernelStdin));
		mixin(registerd!(0xA6BAB2E9, sceKernelStdout));
		mixin(registerd!(0xF78BA90A, sceKernelStderr));
	}

	/**
	 * Function to get the current standard in file no
	 * 
	 * @return The stdin fileno
	 */
	SceUID sceKernelStdin() { return STDIN; }

	/**
	 * Function to get the current standard out file no
	 * 
	 * @return The stdout fileno
	 */
	SceUID sceKernelStdout() { return STDOUT; }

	/**
	 * Function to get the current standard err file no
	 * 
	 * @return The stderr fileno
	 */
	SceUID sceKernelStderr() { return STDERR; }
}

class StdioForKernel : StdioForUser {
}

enum : SceUID {
	STDIN  = -1,
	STDOUT = -2,
	STDERR = -3
}

static this() {
	mixin(Module.registerModule("StdioForKernel"));
	mixin(Module.registerModule("StdioForUser"));
}