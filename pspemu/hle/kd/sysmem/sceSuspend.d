module pspemu.hle.kd.sysmem.sceSuspend; // kd/sysmem.prx (sceSystemMemoryManager)

import pspemu.hle.ModuleNative;

class sceSuspendForKernel : ModuleNative {
	void initNids() {
		mixin(registerd!(0xEADB1BD7, sceKernelPowerLock));
		mixin(registerd!(0x3AEE7261, sceKernelPowerUnlock));
		mixin(registerd!(0x090CCB3F, sceKernelPowerTick));
	}

	// @TODO: Unknown.
	void sceKernelPowerLock() {
		//unimplemented_notice();
	}

	// @TODO: Unknown.
	void sceKernelPowerUnlock() {
		//unimplemented_notice();
	}

	/**
	 * Will prevent the backlight to turn off.
	 */
	void sceKernelPowerTick(uint value) {
		//logWarning("Not Implemented sceKernelPowerTick");
	}
}

class sceSuspendForUser : sceSuspendForKernel {
}

static this() {
	mixin(ModuleNative.registerModule("sceSuspendForUser"));
	mixin(ModuleNative.registerModule("sceSuspendForKernel"));
}
