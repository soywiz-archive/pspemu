module pspemu.hle.kd.wlan; // kd/wlan.prx (sceWlan_Driver):

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class sceWlanDrv : Module {
	void initNids() {
		mixin(registerd!(0xD7763699, sceWlanGetSwitchState));
		mixin(registerd!(0x0C622081, sceWlanGetEtherAddr));
	}

	/**
	 * Determine the state of the Wlan power switch
	 *
	 * @return 0 if off, 1 if on
	 */
	int sceWlanGetSwitchState() {
		unimplemented_notice();
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
		unimplemented();
		return 0;
	}
}

static this() {
	mixin(Module.registerModule("sceWlanDrv"));
}
