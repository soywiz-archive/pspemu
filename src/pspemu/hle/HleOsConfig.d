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
	PspLanguages     language      = PspLanguages.ENGLISH;
	PspConfirmButton confirmButton = PspConfirmButton.CROSS;
	bool enabledDisplay = true;
}