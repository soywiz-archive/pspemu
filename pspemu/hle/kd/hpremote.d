module pspemu.hle.kd.hpremote; // kd/hpremote.prx (sceHP_Remote_Driver)

import pspemu.hle.Module;

class sceHprm : Module {
	void initNids() {
		mixin(registerd!(0x1910B327, sceHprmPeekCurrentKey));
		mixin(registerd!(0x208DB1BD, sceHprmIsRemoteExist));
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
		//unimplemented();
		//return -1;
		return 0;
	}

	/** 
	 * Determines whether the remote is plugged in.
	 *
	 * @return 1 if the remote is plugged in, else 0.
	 */
	int sceHprmIsRemoteExist() {
		return 0;
	}
}

static this() {
	mixin(Module.registerModule("sceHprm"));
}
