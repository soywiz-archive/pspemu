module pspemu.hle.kd.usbstorboot; // kd/usbstorboot.prx (sceUSB_Stor_Boot_Driver):

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class sceUsbstorBoot : Module {
	void initNids() {
		mixin(registerd!(0xE58818A8, sceUsbstorBootSetCapacity));
	}

	/**
	 * Tell the USBstorBoot driver the size of MS
	 *
	 * @note I'm not sure if this is the actual size of the media or not
	 * as it seems to have no bearing on what size windows detects.
	 * PSPPET passes 0x800000
	 * 
	 * @param size - capacity of memory stick
	 *
	 * @return 0 on success
	 */
	int sceUsbstorBootSetCapacity(u32 size) {
		unimplemented();
		return -1;
	}
}

static this() {
	mixin(Module.registerModule("sceUsbstorBoot"));
}
