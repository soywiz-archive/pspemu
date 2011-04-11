module pspemu.hle.kd.pspnet; // kd/pspnet.prx (sceNet_Library):

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class sceNet : Module {
	void initNids() {
		mixin(registerd!(0x39AF39A6, sceNetInit));
		mixin(registerd!(0x281928A9, sceNetTerm));
	}

	/**
	 * Initialise the networking library
	 *
	 * @param poolsize - Memory pool size (appears to be for the whole of the networking library).
	 * @param calloutprio - Priority of the SceNetCallout thread.
	 * @param calloutstack - Stack size of the SceNetCallout thread (defaults to 4096 on non 1.5 firmware regardless of what value is passed).
	 * @param netintrprio - Priority of the SceNetNetintr thread.
	 * @param netintrstack - Stack size of the SceNetNetintr thread (defaults to 4096 on non 1.5 firmware regardless of what value is passed).
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetInit(int poolsize, int calloutprio, int calloutstack, int netintrprio, int netintrstack) {
		unimplemented();
		return -1;
	}

	/**
	 * Terminate the networking library
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetTerm() {
		unimplemented();
		return -1;
	}
}

static this() {
	mixin(Module.registerModule("sceNet"));
}
