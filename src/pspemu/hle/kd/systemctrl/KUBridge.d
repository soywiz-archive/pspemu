module pspemu.hle.kd.systemctrl.KUBridge;

import std.stdio;

import pspemu.hle.ModuleNative;
import pspemu.hle.kd.sysmem.Types;
import pspemu.hle.kd.modulemgr.Types;
import pspemu.hle.kd.iofilemgr.Types;
import pspemu.hle.kd.modulemgr.ModuleMgr;

class KUBridge : HleModuleHost {
	mixin TRegisterModule;

	void initNids() {
		mixin(registerFunction!(0x4C25EA72, kuKernelLoadModule));
	}

	SceUID kuKernelLoadModule(string path, int flags, SceKernelLMOption *option) {
		return hleEmulatorState.moduleManager.get!ModuleMgrForUser().sceKernelLoadModule(path, flags, option);
	}
}
