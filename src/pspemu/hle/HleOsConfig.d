module pspemu.hle.HleOsConfig;

enum PspLanguages : int {
    JAPANESE   = 0,
    ENGLISH    = 1,
    FRENCH     = 2,
    SPANISH    = 3,
    GERMAN     = 4,
    ITALIAN    = 5,
    DUTCH      = 6,
    PORTUGUESE = 7,
    RUSSIAN    = 8,
    KOREAN     = 9,
    TRADITIONAL_CHINESE = 10,
    SIMPLIFIED_CHINESE  = 11,
}

enum PspConfirmButton : int {
    CIRCLE = 0,
    CROSS  = 1,
}

class HleOsConfig {
	/**
	 * Get the firmware version.
	 * 
	 * 0x01000300 on v1.00 unit,
	 * 0x01050001 on v1.50 unit,
	 * 0x01050100 on v1.51 unit,
	 * 0x01050200 on v1.52 unit,
	 * 0x02000010 on v2.00/v2.01 unit,
	 * 0x02050010 on v2.50 unit,
	 * 0x02060010 on v2.60 unit,
	 * 0x02070010 on v2.70 unit,
	 * 0x02070110 on v2.71 unit.
	 */
	ubyte[4] firmwareVersionBytes = [6, 6, 0, 16];

	@property uint firmwareVersion() {
		return bswap(*cast(uint *)firmwareVersionBytes.ptr);
	}
	
	PspLanguages     language      = PspLanguages.ENGLISH;
	PspConfirmButton confirmButton = PspConfirmButton.CROSS;
	bool enabledDisplay = true;
}