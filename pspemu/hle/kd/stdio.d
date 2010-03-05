module pspemu.hle.kd.stdio; // kd/stdio.prx (sceStdio)

import pspemu.hle.Module;

class StdioForKernel : Module {
}

class StdioForUser : StdioForKernel {
}

static this() {
	mixin(Module.registerModule("StdioForKernel"));
	mixin(Module.registerModule("StdioForUser"));
}