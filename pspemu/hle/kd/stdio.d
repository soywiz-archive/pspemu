module pspemu.hle.kd.stdio; // kd/stdio.prx (sceStdio)

import pspemu.hle.Module;

class StdioForUser : Module {
	void initNids() {
		mixin(registerd!(0x172D316E, sceKernelStdin));
		mixin(registerd!(0xA6BAB2E9, sceKernelStdout));
		mixin(registerd!(0xF78BA90A, sceKernelStderr));
		mixin(registerd!(0x98220F3E, sceKernelStdoutReopen));
		mixin(registerd!(0xFB5380C5, sceKernelStderrReopen));
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

	/** 
	 * Function reopen the stdout file handle to a new file
	 *
	 * @param file - The file to open.
	 * @param flags - The open flags 
	 * @param mode - The file mode
	 * 
	 * @return < 0 on error.
	 */
	int sceKernelStdoutReopen(string file, int flags, SceMode mode) {
		unimplemented();
		return -1;
	}

	/** 
	 * Function reopen the stderr file handle to a new file
	 *
	 * @param file - The file to open.
	 * @param flags - The open flags 
	 * @param mode - The file mode
	 * 
	 * @return < 0 on error.
	 */
	int sceKernelStderrReopen(string file, int flags, SceMode mode) {
		unimplemented();
		return -1;
	}
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