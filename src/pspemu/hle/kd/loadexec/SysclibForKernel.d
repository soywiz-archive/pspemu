module pspemu.hle.kd.loadexec.SysclibForKernel;

import pspemu.hle.ModuleNative;

import pspemu.hle.ModuleNative;

import pspemu.hle.kd.loadexec.Types;

class SysclibForKernel : HleModuleHost {
	mixin TRegisterModule;

	void initNids() {
		mixin(registerFunction!(0x52DF196C, strlen));
	}

	int strlen(string str) {
		return str.length;
	}
}
