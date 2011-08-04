module pspemu.hle.kd.loadexec.SysclibForKernel;

import pspemu.hle.ModuleNative;

import pspemu.hle.ModuleNative;

import pspemu.hle.kd.loadexec.Types;

class SysclibForKernel : ModuleNative {
	void initNids() {
		mixin(registerd!(0x52DF196C, strlen));
	}

	int strlen(string str) {
		return str.length;
	}
}

static this() {
	mixin(ModuleNative.registerModule("SysclibForKernel"));
}