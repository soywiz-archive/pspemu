module pspemu.hle.kd.utility.sceUtility_Sysparam;

import std.process;

template sceUtility_sysparams() {
	void initNids_sysparams() {
		mixin(registerd!(0xA5DA2406, sceUtilityGetSystemParamInt));
		mixin(registerd!(0x34B78343, sceUtilityGetSystemParamString));
	}

	/**
	 * Get Integer System Parameter
	 *
	 * @param id    - which parameter to get
	 * @param value - pointer to integer value to place result in
	 *
	 * @return PSP_SYSTEMPARAM_RETVAL.OK on success, PSP_SYSTEMPARAM_RETVAL.FAIL on failure
	 */
	PSP_SYSTEMPARAM_RETVAL sceUtilityGetSystemParamInt(PSP_SYSTEMPARAM_ID id, int* value) {
		switch (id) {
			default:
				logError("Unknown sceUtilityGetSystemParamInt(%d)", id);
				return PSP_SYSTEMPARAM_RETVAL.FAIL;
			break;
			case PSP_SYSTEMPARAM_ID.INT_ADHOC_CHANNEL: {
				*value = PSP_SYSTEMPARAM_ADHOC_CHANNEL.AUTOMATIC;
			} break;
			case PSP_SYSTEMPARAM_ID.INT_WLAN_POWERSAVE: {
				*value = PSP_SYSTEMPARAM_WLAN_POWERSAVE.ON;
			} break;
			case PSP_SYSTEMPARAM_ID.INT_DATE_FORMAT: {
				*value = PSP_SYSTEMPARAM_DATE_FORMAT.YYYYMMDD; // English
			} break;
			case PSP_SYSTEMPARAM_ID.INT_TIME_FORMAT: {
				*value = PSP_SYSTEMPARAM_TIME_FORMAT._24HR;
			} break;
			case PSP_SYSTEMPARAM_ID.INT_TIMEZONE: {
				*value = -5 * 60;
			} break;
			case PSP_SYSTEMPARAM_ID.INT_DAYLIGHTSAVINGS: {
				*value = PSP_SYSTEMPARAM_DAYLIGHTSAVINGS.STD;
			} break;
			case PSP_SYSTEMPARAM_ID.INT_LANGUAGE: {
				*value = PSP_SYSTEMPARAM_LANGUAGE.ENGLISH;
			} break;
			case PSP_SYSTEMPARAM_ID.INT_BUTTON_PREFERENCE: {
				*value = PSP_SYSTEMPARAM_BUTTON_PREFERENCE.NA;
			} break;
		}
		return PSP_SYSTEMPARAM_RETVAL.OK;
	}

	/**
	 * Get String System Parameter
	 *
	 * @param id  - which parameter to get
	 * @param str - char * buffer to place result in
	 * @param len - length of str buffer
	 *
	 * @return PSP_SYSTEMPARAM_RETVAL.OK on success, PSP_SYSTEMPARAM_RETVAL.FAIL on failure
	 */
	PSP_SYSTEMPARAM_RETVAL sceUtilityGetSystemParamString(PSP_SYSTEMPARAM_ID id, char* str, int len) {
		switch (id) {
			default:
				logError("Unknown sceUtilityGetSystemParamString(%d)", id);
				return PSP_SYSTEMPARAM_RETVAL.FAIL;
			case PSP_SYSTEMPARAM_ID.STRING_NICKNAME: {
				string nick = std.process.getenv("USERNAME") ~ "\0";
				if (nick.length > len) return PSP_SYSTEMPARAM_RETVAL.FAIL;
				str[0..nick.length] = nick;
			} break;
		}
		return PSP_SYSTEMPARAM_RETVAL.OK;
	}

	/**
	 * Set Integer System Parameter
	 *
	 * @param id - which parameter to set
	 * @param value - integer value to set
	 *
	 * @return PSP_SYSTEMPARAM_RETVAL.OK on success, PSP_SYSTEMPARAM_RETVAL.FAIL on failure
	 */
	PSP_SYSTEMPARAM_RETVAL sceUtilitySetSystemParamInt(PSP_SYSTEMPARAM_ID id, int value) {
		unimplemented();
		return PSP_SYSTEMPARAM_RETVAL.FAIL;
	}

	/**
	 * Set String System Parameter
	 *
	 * @param id - which parameter to set
	 * @param str - char * value to set
	 *
	 * @return PSP_SYSTEMPARAM_RETVAL.OK on success, PSP_SYSTEMPARAM_RETVAL.FAIL on failure
	 */
	PSP_SYSTEMPARAM_RETVAL sceUtilitySetSystemParamString(PSP_SYSTEMPARAM_ID id, string str) {
		unimplemented();
		return PSP_SYSTEMPARAM_RETVAL.FAIL;
	}
}

/**
 * IDs for use inSystemParam functions
 * PSP_SYSTEMPARAM_ID_INT    are for use with SystemParamInt    funcs
 * PSP_SYSTEMPARAM_ID_STRING are for use with SystemParamString funcs
 */
enum PSP_SYSTEMPARAM_ID {
	STRING_NICKNAME       = 1,
	INT_ADHOC_CHANNEL     = 2,
	INT_WLAN_POWERSAVE    = 3,
	INT_DATE_FORMAT       = 4,
	INT_TIME_FORMAT       = 5,
	INT_TIMEZONE          = 6, // Timezone offset from UTC in minutes, (EST = -300 = -5 * 60)
	INT_DAYLIGHTSAVINGS   = 7,
	INT_LANGUAGE          = 8,
	INT_BUTTON_PREFERENCE = 9,
}

/**
 * Return values for the SystemParam functions
 */
enum PSP_SYSTEMPARAM_RETVAL {
	OK   = 0,
	FAIL = 0x80110103,
}

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_ADHOC_CHANNEL
 */
enum PSP_SYSTEMPARAM_ADHOC_CHANNEL {
	AUTOMATIC = 0,
	C1  = 1,
	C6  = 6,
	C11 = 11,
}

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_WLAN_POWERSAVE
 */
enum PSP_SYSTEMPARAM_WLAN_POWERSAVE {
	OFF = 0,
	ON  = 1,
}

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_DATE_FORMAT
 */
enum PSP_SYSTEMPARAM_DATE_FORMAT {
	YYYYMMDD = 0,
	MMDDYYYY = 1,
	DDMMYYYY = 2,
}

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_TIME_FORMAT
 */
enum PSP_SYSTEMPARAM_TIME_FORMAT {
	_24HR = 0,
	_12HR = 1,
}

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_DAYLIGHTSAVINGS
 */
enum PSP_SYSTEMPARAM_DAYLIGHTSAVINGS {
	STD    = 0,
	SAVING = 1,
}

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_LANGUAGE
 */
enum PSP_SYSTEMPARAM_LANGUAGE {
	JAPANESE    = 0,
	ENGLISH     = 1,
	FRENCH      = 2,
	SPANISH     = 3,
	GERMAN      = 4,
	ITALIAN     = 5,
	DUTCH       = 6,
	PORTUGUESE  = 7,
	RUSSIAN     = 8,
	KOREAN      = 9,
	CHINESE_TRADITIONAL = 10,
	CHINESE_SIMPLIFIED  = 11,
}

/**
 * #9 seems to be Region or maybe X/O button swap.
 * It doesn't exist on JAP v1.0
 * is 1 on NA v1.5s
 * is 0 on JAP v1.5s
 * is read-only
 */
enum PSP_SYSTEMPARAM_BUTTON_PREFERENCE {
	JAP = 0,
	NA  = 1,
}
