module pspemu.hle.kd.hpremote.sceHprm; // kd/hpremote.prx (sceHP_Remote_Driver)

import pspemu.hle.ModuleNative;

class sceHprm : HleModuleHost {
	mixin TRegisterModule;

	void initNids() {
		mixin(registerFunction!(0x1910B327, sceHprmPeekCurrentKey));
		mixin(registerFunction!(0x208DB1BD, sceHprmIsRemoteExist));
		mixin(registerFunction!(0x7E69EDA4, sceHprmIsHeadphoneExist));
		mixin(registerFunction!(0x219C58F1, sceHprmIsMicrophoneExist));
	}

	/**
	 * Determines whether the headphones are plugged in.
	 *
	 * @return 1 if the headphones are plugged in, else 0.
	 */
	int sceHprmIsHeadphoneExist() {
		unimplemented_notice();
		return 0;
	}

	/** 
	 * Determines whether the microphone is plugged in.
	 *
	 * @return 1 if the microphone is plugged in, else 0.
	 */
	int sceHprmIsMicrophoneExist() {
		unimplemented_notice();
		return 0;
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
		logTrace("sceHprmPeekCurrentKey");
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
