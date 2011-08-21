module pspemu.hle.kd.lowio.sceSysreg;

import pspemu.hle.ModuleNative;

class sceSysreg_driver : HleModuleHost {
	mixin TRegisterModule;
	
	void initNids() {
		mixin(registerFunction!(0xDE59DACB, sceSysregMeResetEnable));
		mixin(registerFunction!(0x44F6CDA7, sceSysregMeBusClockEnable));
		mixin(registerFunction!(0x2DB0EB28, sceSysregMeResetDisable));
		mixin(registerFunction!(0x7558064A, sceSysregVmeResetDisable));
	}
	
	/**
	  * Enable the ME reset.
	  *
	  * @return < 0 on error.
	  */
	int sceSysregMeResetEnable() {
		unimplemented_notice();
		return 0;
	}
	
	/**
	  * Disable the ME reset.
	  *
	  * @return < 0 on error.
	  */
	int sceSysregMeResetDisable() {
		unimplemented_notice();
		return 0;
	}
	
	/**
	  * Enable the VME reset.
	  *
	  * @return < 0 on error.
	  */
	int sceSysregVmeResetEnable() {
		unimplemented_notice();
		return 0;
	}
	
	/**
	  * Disable the VME reset.
	  *
	  * @return < 0 on error.
	  */
	int sceSysregVmeResetDisable() {
		unimplemented_notice();
		return 0;
	}
	
	/**
	  * Enable the ME bus clock.
	  *
	  * @return < 0 on error.
	  */
	int sceSysregMeBusClockEnable() {
		unimplemented_notice();
		return 0;
	}
	
	/**
	  * Disable the ME bus clock.
	  *
	  * @return < 0 on error.
	  */
	int sceSysregMeBusClockDisable() {
		unimplemented_notice();
		return 0;
	}
}
