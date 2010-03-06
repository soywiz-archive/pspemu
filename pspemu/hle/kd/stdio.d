module pspemu.hle.kd.stdio; // kd/stdio.prx (sceStdio)

import pspemu.hle.Module;

class StdioForUser : Module {
	this() {
		mixin(register(0x172D316E, "sceKernelStdin"));
		mixin(register(0xA6BAB2E9, "sceKernelStdout"));
		mixin(register(0xF78BA90A, "sceKernelStderr"));
	}

	void sceKernelStdin () { cpu.registers.V0 = -2; }
	void sceKernelStdout() { cpu.registers.V0 = -3; }
	void sceKernelStderr() { cpu.registers.V0 = -4; }
}

class StdioForKernel : StdioForUser {
}

static this() {
	mixin(Module.registerModule("StdioForKernel"));
	mixin(Module.registerModule("StdioForUser"));
}