module pspemu.hle.kd.wlan; // kd/wlan.prx (sceWlan_Driver):

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class sceWlanDrv : Module {
	void initNids() {
		mixin(registerd!(0xD7763699, sceWlanGetSwitchState));
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
}

static this() {
	mixin(Module.registerModule("sceWlanDrv"));
}
