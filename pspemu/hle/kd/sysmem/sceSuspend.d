module pspemu.hle.kd.sysmem.sceSuspend; // kd/sysmem.prx (sceSystemMemoryManager)

import pspemu.hle.ModuleNative;

class sceSuspendForKernel : ModuleNative {
	void initNids() {
		mixin(registerd!(0xEADB1BD7, sceKernelPowerLock));
		mixin(registerd!(0x3AEE7261, sceKernelPowerUnlock));
		mixin(registerd!(0x090CCB3F, sceKernelPowerTick));
		mixin(registerd!(0x3E0271D3, sceKernelVolatileMemLock));
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
	
	/**
	 * Allocate the extra 4megs of RAM
	 *
	 * @param unk  - No idea as it is never used, set to anything
	 * @param ptr  - Pointer to a pointer to hold the address of the memory
	 * @param size - Pointer to an int which will hold the size of the memory
	 *
	 * @return 0 on success
	 */
	int sceKernelVolatileMemLock(int unk, uint* ptr, int *size) {
		*ptr  = 0x08400000;
		*size = 0x400000;    // 4 MB
		return 0;
	}
}

class sceSuspendForUser : sceSuspendForKernel {
}

static this() {
	mixin(ModuleNative.registerModule("sceSuspendForUser"));
	mixin(ModuleNative.registerModule("sceSuspendForKernel"));
}
