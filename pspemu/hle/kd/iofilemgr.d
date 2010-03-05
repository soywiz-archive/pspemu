module pspemu.hle.kd.iofilemgr; // kd/iofilemgr.prx (sceIOFileManager)

import pspemu.hle.Module;

class IoFileMgrForKernel : Module {
	this() {
		mixin(register(0xB29DDF9C, "sceIoDopen"));
		mixin(register(0xEB092469, "sceIoDclose"));
		mixin(register(0x55F4717D, "sceIoChdir"));
	}
}

class IoFileMgrForUser : IoFileMgrForKernel {
}

static this() {
	mixin(Module.registerModule("IoFileMgrForUser"));
	mixin(Module.registerModule("IoFileMgrForKernel"));
}