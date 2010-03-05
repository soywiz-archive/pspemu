module pspemu.hle.kd.loadexec; // kd/loadexec.prx (sceLoadExec)

import pspemu.hle.Module;

class LoadExecForUser : Module {
	this() {
		mixin(register(0xBD2F1094, "sceKernelLoadExec"));
		mixin(register(0x2AC9954B, "sceKernelExitGameWithStatus"));
		mixin(register(0x05572A5F, "sceKernelExitGame"));
		mixin(register(0x4AC57943, "sceKernelRegisterExitCallback"));
	}
}

class LoadExecForKernel : LoadExecForUser {
}

static this() {
	mixin(Module.registerModule("LoadExecForUser"));
	mixin(Module.registerModule("LoadExecForKernel"));
}