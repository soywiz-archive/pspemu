module pspemu.hle.kd.wlan.sceWlan;

import std.stdio;

import pspemu.hle.ModuleNative;


class sceWlanDrv : ModuleNative {
	void initNids() {
		mixin(registerd!(0x93440B11, sceWlanDevIsPowerOn));
		mixin(registerd!(0xD7763699, sceWlanGetSwitchState));
		mixin(registerd!(0x0C622081, sceWlanGetEtherAddr));
	}
	
	/**
	 * Determine if the wlan device is currently powered on
	 *
	 * @return 0 if off, 1 if on
	 */
	int sceWlanDevIsPowerOn() {
		return 0;
	}
	
	/**
	 * Determine the state of the Wlan power switch
	 *
	 * @return 0 if off, 1 if on
	 */
	int sceWlanGetSwitchState() {
		return 0;
	}
	
	/**
	 * Get the Ethernet Address of the wlan controller
	 *
	 * @param etherAddr - pointer to a buffer of u8 (NOTE: it only writes to 6 bytes, but 
	 * requests 8 so pass it 8 bytes just in case)
	 * @return 0 on success, < 0 on error
	 */
	int sceWlanGetEtherAddr(u8 *etherAddr) {
		for (int n = 0; n < 6; n++) etherAddr[n] = 6;
		return 0;;
	}
	
	/**
	 * Attach to the wlan device
	 *
	 * @return 0 on success, < 0 on error.
	 */
	int sceWlanDevAttach() {
		return -1;
	}
	
	/**
	 * Detach from the wlan device
	 *
	 * @return 0 on success, < 0 on error/
	 */
	int sceWlanDevDetach() {
		return -1;
	}
}

static this() {
	mixin(ModuleNative.registerModule("sceWlanDrv"));
}
