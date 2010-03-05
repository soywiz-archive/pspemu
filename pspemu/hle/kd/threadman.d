module pspemu.hle.kd.threadman; // kd/threadman.prx (sceThreadManager)

import pspemu.hle.Module;

class ThreadManForUser : Module {
	this() {
		mixin(register(0xE81CAF8F, "sceKernelCreateCallback"));
		mixin(register(0x82826F70, "sceKernelSleepThreadCB"));
		mixin(register(0x446D8DE6, "sceKernelCreateThread"));
		mixin(register(0xF475845D, "sceKernelStartThread"));
		mixin(register(0xAA73C935, "sceKernelExitThread"));
	}
}

class ThreadManForKernel : ThreadManForUser {
}


static this() {
	mixin(Module.registerModule("ThreadManForUser"));
	mixin(Module.registerModule("ThreadManForKernel"));
}