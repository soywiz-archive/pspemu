module pspemu.hle.kd.impose.sceImpose;

import pspemu.hle.ModuleNative;
import pspemu.hle.HleEmulatorState;

public import pspemu.hle.OsConfig;

class sceImpose : ModuleNative {
	uint umdPopupStatus;
	
	void initNids() {
		mixin(registerd!(0x8C943191, sceImposeGetBatteryIconStatus));
		mixin(registerd!(0x36AA6E91, sceImposeSetLanguageMode));
		mixin(registerd!(0x24FD7BCF, sceImposeGetLanguageMode));
        mixin(registerd!(0x72189C48, sceImposeSetUMDPopupFunction));
        mixin(registerd!(0xE0887BC8, sceImposeGetUMDPopupFunction));
	}
	
	uint sceImposeSetUMDPopupFunction(uint umdPopupStatus) {
		this.umdPopupStatus = umdPopupStatus;
		return 0;
	}
	
	uint sceImposeGetUMDPopupFunction() {
		return this.umdPopupStatus; 
	}
	
	/**
	 * Set the language and button assignment parameters
	 *
	 * @param language      - Language
	 * @param confirmButton - Button assignment (Cross or circle)
	 *
	 * @return < 0 on error
	 */
	int sceImposeSetLanguageMode(PspLanguages language, PspConfirmButton confirmButton) {
		logError("sceImposeSetLanguageMode(%s, %s)", to!string(language), to!string(confirmButton));
		hleEmulatorState.osConfig.language      = language;
		hleEmulatorState.osConfig.confirmButton = confirmButton;
		return 0;
	} 
	
	/**
	 * Get the language and button assignment parameters
	 *
	 * @param language      - Pointer to store the language
	 * @param confirmButton - Pointer to store the button assignment (Cross or circle)
	 *
	 * @return < 0 on error
	 */
	int sceImposeGetLanguageMode(PspLanguages* language, PspConfirmButton* confirmButton) {
		*language      = hleEmulatorState.osConfig.language;
		*confirmButton = hleEmulatorState.osConfig.confirmButton;
		
		return 0;
	}
	
	uint sceImposeGetBatteryIconStatus(uint* addrCharging, uint* addrIconStatus) {
        if (addrCharging !is null) {
        	*addrCharging = hleEmulatorState.emulatorState.battery.isCharging ? 1 : 0; // 0..1
        }

        if (addrIconStatus !is null) {
        	*addrIconStatus = cast(int)(hleEmulatorState.emulatorState.battery.chargedPercentage * 3); // 0..3
        }

        return 0;
	}
}

static this() {
	mixin(ModuleNative.registerModule("sceImpose"));
}
