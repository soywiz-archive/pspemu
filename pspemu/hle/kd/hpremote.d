module pspemu.hle.kd.hpremote; // kd/hpremote.prx (sceHP_Remote_Driver)

import pspemu.hle.Module;

class sceHprm : Module {
	void initNids() {
		mixin(registerd!(0x1910B327, sceHprmPeekCurrentKey));
	}

	/** 
	 * Peek at the current being pressed on the remote.
	 * 
	 * @param key - Pointer to the u32 to receive the key bitmap, should be one or
	 * more of ::PspHprmKeys
	 *
	 * @return < 0 on error
	 */
	int sceHprmPeekCurrentKey(u32 *key) {
		*key = 0;
		unimplemented();
		return -1;
	}
}

static this() {
	mixin(Module.registerModule("sceHprm"));
}
