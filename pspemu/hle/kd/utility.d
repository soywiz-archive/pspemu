module pspemu.hle.kd.utility; // kd/utility.prx (sceUtility_Driver):

import pspemu.hle.Module;

import pspemu.hle.kd.utility_sysparam;

class sceUtility : Module {
	mixin sceUtility_sysparams;

	void initNids() {
		mixin(registerd!(0x50C4CD57, sceUtilitySavedataInitStart));
		mixin(registerd!(0x9790B33C, sceUtilitySavedataShutdownStart));
		mixin(registerd!(0xD4B95FFB, sceUtilitySavedataUpdate));
		mixin(registerd!(0x8874DBE0, sceUtilitySavedataGetStatus));

		mixin(registerd!(0x5EEE6548, sceUtilityCheckNetParam));
		mixin(registerd!(0x434D4B3A, sceUtilityGetNetParam));

		mixin(registerd!(0x2A2B3DE0, sceUtilityLoadModuleFunction));
		mixin(registerd!(0xE49BFE92, sceUtilityUnloadModuleFunction));

		mixin(registerd!(0x2AD8E239, sceUtilityMsgDialogInitStart));
		mixin(registerd!(0x67AF3428, sceUtilityMsgDialogShutdownStart));
		mixin(registerd!(0x95FC253B, sceUtilityMsgDialogUpdate));
		mixin(registerd!(0x9A1C91D7, sceUtilityMsgDialogGetStatus));
		
		mixin(registerd!(0xC629AF26, sceUtilityLoadAvModule));
		
		mixin(registerd!(0x4DB1E739, sceUtilityNetconfInitStart));
		mixin(registerd!(0xF88155F6, sceUtilityNetconfShutdownStart));
		mixin(registerd!(0x91E70E35, sceUtilityNetconfUpdate));
		mixin(registerd!(0x6332AA39, sceUtilityNetconfGetStatus));

		mixin(registerd!(0x3DFAEBA9, sceUtilityOskShutdownStart));
		mixin(registerd!(0x4B85C861, sceUtilityOskUpdate));
		mixin(registerd!(0xF3F76017, sceUtilityOskGetStatus));
		mixin(registerd!(0xF6269B82, sceUtilityOskInitStart));

		mixin(registerd!(0x1579A159, sceUtilityLoadNetModule));
		mixin(registerd!(0x64D50C56, sceUtilityUnloadNetModule));

		initNids_sysparams();
	}

	/**
	 * Remove a currently active keyboard. After calling this function you must
	 *
	 * poll sceUtilityOskGetStatus() until it returns PSP_UTILITY_DIALOG_NONE.
	 *
	 * @return < 0 on error.
	 */
	int sceUtilityOskShutdownStart() {
		unimplemented();
		return -1;
	}

	/**
	 * Refresh the GUI for a keyboard currently active
	 *
	 * @param n - Unknown, pass 1.
	 *
	 * @return < 0 on error.
	 */
	int sceUtilityOskUpdate(int n) {
		unimplemented();
		return -1;
	}

	/**
	 * Get the status of a on-screen keyboard currently active.
	 *
	 * @return the current status of the keyboard. See ::pspUtilityDialogState for details.
	 */
	int sceUtilityOskGetStatus() {
		unimplemented();
		return -1;
	}

	/**
	 * Create an on-screen keyboard
	 *
	 * @param params - OSK parameters.
	 *
	 * @return < 0 on error.
	 */
	int sceUtilityOskInitStart(SceUtilityOskParams* params) {
		unimplemented();
		return -1;
	}

	/**
	 * Init the Network Configuration Dialog Utility
	 *
	 * @param data - pointer to pspUtilityNetconfData to be initialized
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceUtilityNetconfInitStart(pspUtilityNetconfData *data) {
		unimplemented(); return -1;
	}

	/**
	 * Shutdown the Network Configuration Dialog Utility
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceUtilityNetconfShutdownStart() {
		unimplemented(); return -1;
	}

	/**
	 * Update the Network Configuration Dialog GUI
	 * 
	 * @param unknown - unknown; set to 1
	 * @return 0 on success, < 0 on error
	 */
	int sceUtilityNetconfUpdate(int unknown) {
		unimplemented(); return -1;
	}

	/**
	 * Get the status of a running Network Configuration Dialog
	 *
	 * @return one of pspUtilityDialogState on success, < 0 on error
	 */
	int sceUtilityNetconfGetStatus() {
		unimplemented(); return -1;
	}

	/**
	 * Create a message dialog
	 *
	 * @param params - dialog parameters
	 *
	 * @return 0 on success
	 */
	int sceUtilityMsgDialogInitStart(pspUtilityMsgDialogParams* params) {
		unimplemented();
		return -1;
	}

	/**
	 * Remove a message dialog currently active.  After calling this
	 * function you need to keep calling GetStatus and Update until
	 * you get a status of 4.
	 */
	void sceUtilityMsgDialogShutdownStart() {
		unimplemented();
	}

	/**
	 * Refresh the GUI for a message dialog currently active
	 *
	 * @param n - unknown, pass 1
	 */
	void sceUtilityMsgDialogUpdate(int n) {
		unimplemented();
	}

	/**
	 * Get the current status of a message dialog currently active.
	 *
	 * @return 2 if the GUI is visible (you need to call sceUtilityMsgDialogGetStatus).
	 *         3 if the user cancelled the dialog, and you need to call sceUtilityMsgDialogShutdownStart.
	 *         4 if the dialog has been successfully shut down.
	 */
	int sceUtilityMsgDialogGetStatus() {
		unimplemented();
		return -1;
	}

	// @TODO: Unknown
	void sceUtilityLoadModuleFunction() {
		unimplemented();
	}

	// @TODO: Unknown
	void sceUtilityUnloadModuleFunction() {
		unimplemented();
	}

	/**
	 * Saves or Load savedata to/from the passed structure
	 * After having called this continue calling sceUtilitySavedataGetStatus to
	 * check if the operation is completed
	 *
	 * @param params - savedata parameters
	 *
	 * @return 0 on success
	 */
	int sceUtilitySavedataInitStart(/*SceUtilitySavedataParam*/void* params) {
		unimplemented();
		return -1;
	}

	/**
	 * Shutdown the savedata utility. after calling this continue calling
	 * ::sceUtilitySavedataGetStatus to check when it has shutdown
	 *
	 * @return 0 on success
	 */
	int sceUtilitySavedataShutdownStart() {
		unimplemented();
		return -1;
	}

	/**
	 * Refresh status of the savedata function
	 *
	 * @param unknown - unknown, pass 1
	 */
	void sceUtilitySavedataUpdate(int unknown) {
		unimplemented();
	}
	
	/**
	 * Check the current status of the saving/loading/shutdown process
	 * Continue calling this to check current status of the process
	 * before calling this call also sceUtilitySavedataUpdate
	 *
	 * @return 2 if the process is still being processed.
	 * 3 on save/load success, then you can call sceUtilitySavedataShutdownStart.
	 * 4 on complete shutdown.
	 */
	int sceUtilitySavedataGetStatus() {
		unimplemented();
		return -1;
	}

	/**
	 * Check existance of a Net Configuration
	 *
	 * @param id - id of net Configuration (1 to n)
	 * @return 0 on success, 
	 */
	int sceUtilityCheckNetParam(int id) {
		unimplemented_notice();
		return -1;
	}

	/**
	 * Get Net Configuration Parameter
	 *
	 * @param conf  - Net Configuration number (1 to n)
	 *               (0 returns valid but seems to be a copy of the last config requested)
	 * @param param - which parameter to get
	 * @param data  - parameter data
	 *
	 * @return 0 on success, 
	 */
	int sceUtilityGetNetParam(int conf, int param, netData *data) {
		unimplemented_notice();
		return -1;
	}

	/**
	 * Load an audio/video module (PRX) from user mode.
	 *
	 * Available on firmware 2.00 and higher only.
	 *
	 * @param module - module number to load (PSP_AV_MODULE_xxx)
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceUtilityLoadAvModule(int _module) {
		unimplemented();
		return -1;
	}

	/**
	 * Load a network module (PRX) from user mode.
	 * Load PSP_NET_MODULE_COMMON and PSP_NET_MODULE_INET
	 * to use infrastructure WifI (via an access point).
	 * Available on firmware 2.00 and higher only.
	 *
	 * @param module - module number to load (PSP_NET_MODULE_xxx)
	 * @return 0 on success, < 0 on error
	 */
	int sceUtilityLoadNetModule(int _module) {
		unimplemented();
		return -1;
	}

	/**
	 * Unload a network module (PRX) from user mode.
	 * Available on firmware 2.00 and higher only.
	 *
	 * @param module - module number be unloaded
	 * @return 0 on success, < 0 on error
	 */
	int sceUtilityUnloadNetModule(int _module) {
		unimplemented();
		return -1;
	}
}

union netData {
	u32 asUint;
	char asString[128];
}

enum {
	PSP_NET_MODULE_COMMON    = 1,
	PSP_NET_MODULE_ADHOC     = 2,
	PSP_NET_MODULE_INET      = 3,
	PSP_NET_MODULE_PARSEURI  = 4,
	PSP_NET_MODULE_PARSEHTTP = 5,
	PSP_NET_MODULE_HTTP      = 6,
	PSP_NET_MODULE_SSL       = 7,
}

enum pspUtilityMsgDialogMode {
	PSP_UTILITY_MSGDIALOG_MODE_ERROR = 0, /* Error message */
	PSP_UTILITY_MSGDIALOG_MODE_TEXT /* String message */
}

enum pspUtilityMsgDialogOption {
	PSP_UTILITY_MSGDIALOG_OPTION_ERROR = 0, /* Error message (why two flags?) */
	PSP_UTILITY_MSGDIALOG_OPTION_TEXT = 0x00000001, /* Text message (why two flags?) */
	PSP_UTILITY_MSGDIALOG_OPTION_YESNO_BUTTONS = 0x00000010,	/* Yes/No buttons instead of 'Cancel' */
	PSP_UTILITY_MSGDIALOG_OPTION_DEFAULT_NO  = 0x00000100	/* Default position 'No', if not set will default to 'Yes' */
}

enum pspUtilityMsgDialogPressed {
	PSP_UTILITY_MSGDIALOG_RESULT_UNKNOWN1 = 0,
	PSP_UTILITY_MSGDIALOG_RESULT_YES,
	PSP_UTILITY_MSGDIALOG_RESULT_NO,
	PSP_UTILITY_MSGDIALOG_RESULT_BACK
}

/**
 * Structure to hold the parameters for a message dialog
**/
struct pspUtilityMsgDialogParams {
    pspUtilityDialogCommon base;
    int unknown;
	pspUtilityMsgDialogMode mode;
	uint errorValue;
    /** The message to display (may contain embedded linefeeds) */
    char message[512];
	pspUtilityMsgDialogOption options;
	pspUtilityMsgDialogPressed buttonPressed;
}

struct pspUtilityDialogCommon {
	uint size;	/** Size of the structure */
	int language;		/** Language */
	int buttonSwap;		/** Set to 1 for X/O button swap */
	int graphicsThread;	/** Graphics thread priority */
	int accessThread;	/** Access/fileio thread priority (SceJobThread) */
	int fontThread;		/** Font thread priority (ScePafThread) */
	int soundThread;	/** Sound thread priority */
	int result;			/** Result */
	int reserved[4];	/** Set to 0 */
}

/+
struct SceUtilitySavedataParam {
	pspUtilityDialogCommon base;

	PspUtilitySavedataMode mode;
	
	int unknown1;
	
	int overwrite;

	/** gameName: name used from the game for saves, equal for all saves */
	char gameName[13];
	char reserved[3];
	/** saveName: name of the particular save, normally a number */
	char saveName[20];

	/** saveNameList: used by multiple modes */
	char (*saveNameList)[20];

	/** fileName: name of the data file of the game for example DATA.BIN */
	char fileName[13];
	char reserved1[3];

	/** pointer to a buffer that will contain data file unencrypted data */
	void *dataBuf;
	/** size of allocated space to dataBuf */
	SceSize dataBufSize;
	SceSize dataSize;

	PspUtilitySavedataSFOParam sfoParam;

	PspUtilitySavedataFileData icon0FileData;
	PspUtilitySavedataFileData icon1FileData;
	PspUtilitySavedataFileData pic1FileData;
	PspUtilitySavedataFileData snd0FileData;

	/** Pointer to an PspUtilitySavedataListSaveNewData structure */
	PspUtilitySavedataListSaveNewData *newData;

	/** Initial focus for lists */
	PspUtilitySavedataFocus focus;

	/** unknown2: ? */
	int unknown2[4];

//#if _PSP_FW_VERSION >= 200

	/** key: encrypt/decrypt key for save with firmware >= 2.00 */
	char key[16];

	/** unknown3: ? */
	char unknown3[20];

//#endif

}
+/

enum pspUtilityNetconfActions {
	PSP_NETCONF_ACTION_CONNECTAP,
	PSP_NETCONF_ACTION_DISPLAYSTATUS,
	PSP_NETCONF_ACTION_CONNECT_ADHOC,
    PSP_NETCONF_ACTION_CONNECTAP_LASTUSED,
}

struct pspUtilityNetconfAdhoc {
	char name[8];
	uint timeout;
}

struct pspUtilityNetconfData {
	pspUtilityDialogCommon base;
	int action; /** One of pspUtilityNetconfActions */
	pspUtilityNetconfAdhoc *adhocparam; //* Adhoc connection params */
	int hotspot; /** Set to 1 to allow connections with the 'Internet Browser' option set to 'Start' (ie. hotspot connection) */
	int hotspot_connected; /** Will be set to 1 when connected to a hotspot style connection */
	int wifisp; /** Set to 1 to allow connections to Wifi service providers (WISP) */
}




/**
 * Enumeration for input language
 */
enum SceUtilityOskInputLanguage {
	PSP_UTILITY_OSK_LANGUAGE_DEFAULT   = 0x00,
	PSP_UTILITY_OSK_LANGUAGE_JAPANESE  = 0x01,
	PSP_UTILITY_OSK_LANGUAGE_ENGLISH   = 0x02,
	PSP_UTILITY_OSK_LANGUAGE_FRENCH    = 0x03,
	PSP_UTILITY_OSK_LANGUAGE_SPANISH   = 0x04,
	PSP_UTILITY_OSK_LANGUAGE_GERMAN    = 0x05,
	PSP_UTILITY_OSK_LANGUAGE_ITALIAN   = 0x06,
	PSP_UTILITY_OSK_LANGUAGE_DUTCH     = 0x07,
	PSP_UTILITY_OSK_LANGUAGE_PORTUGESE = 0x08,
	PSP_UTILITY_OSK_LANGUAGE_RUSSIAN   = 0x09,
	PSP_UTILITY_OSK_LANGUAGE_KOREAN    = 0x0a,
};

/**
 * Enumeration for OSK internal state
 */
enum SceUtilityOskState {
	PSP_UTILITY_OSK_DIALOG_NONE      = 0, /// No OSK is currently active
	PSP_UTILITY_OSK_DIALOG_INITING   = 1, /// The OSK is currently being initialized
	PSP_UTILITY_OSK_DIALOG_INITED    = 2, /// The OSK is initialised
	PSP_UTILITY_OSK_DIALOG_VISIBLE   = 3, /// The OSK is visible and ready for use
	PSP_UTILITY_OSK_DIALOG_QUIT      = 4, /// The OSK has been cancelled and should be shut down
	PSP_UTILITY_OSK_DIALOG_FINISHED  = 5, /// The OSK has successfully shut down 
};

/**
 * Enumeration for OSK field results
 */
enum SceUtilityOskResult {
	PSP_UTILITY_OSK_RESULT_UNCHANGED = 0,
	PSP_UTILITY_OSK_RESULT_CANCELLED = 1,
	PSP_UTILITY_OSK_RESULT_CHANGED   = 2,
};

/**
 * Enumeration for input types (these are limited by initial choice of language)
 */
enum SceUtilityOskInputType {
	PSP_UTILITY_OSK_INPUTTYPE_ALL                    = 0x00000000,
	PSP_UTILITY_OSK_INPUTTYPE_LATIN_DIGIT            = 0x00000001,
	PSP_UTILITY_OSK_INPUTTYPE_LATIN_SYMBOL           = 0x00000002,
	PSP_UTILITY_OSK_INPUTTYPE_LATIN_LOWERCASE        = 0x00000004,
	PSP_UTILITY_OSK_INPUTTYPE_LATIN_UPPERCASE        = 0x00000008,
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_DIGIT         = 0x00000100,
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_SYMBOL        = 0x00000200,
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_LOWERCASE     = 0x00000400,
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_UPPERCASE     = 0x00000800,
	// http://en.wikipedia.org/wiki/Hiragana
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_HIRAGANA      = 0x00001000,
	// http://en.wikipedia.org/wiki/Katakana
	// Half-width Katakana
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_HALF_KATAKANA = 0x00002000,
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_KATAKANA      = 0x00004000,
	// http://en.wikipedia.org/wiki/Kanji
	PSP_UTILITY_OSK_INPUTTYPE_JAPANESE_KANJI         = 0x00008000,
	PSP_UTILITY_OSK_INPUTTYPE_RUSSIAN_LOWERCASE      = 0x00010000,
	PSP_UTILITY_OSK_INPUTTYPE_RUSSIAN_UPPERCASE      = 0x00020000,
	PSP_UTILITY_OSK_INPUTTYPE_KOREAN                 = 0x00040000,
	PSP_UTILITY_OSK_INPUTTYPE_URL                    = 0x00080000,
};

/**
 * OSK Field data
 */
struct SceUtilityOskData {
	int unk_00;                          /// Unknown. Pass 0.
    int unk_04;                          /// Unknown. Pass 0.
    SceUtilityOskInputLanguage language; /// One of ::SceUtilityOskInputLanguage
    int unk_12;                          /// Unknown. Pass 0.
    SceUtilityOskInputType inputtype;    /// One or more of ::SceUtilityOskInputType (types that are selectable by pressing SELECT)
    int     lines;                       /// Number of lines
    int     unk_24;                      /// Unknown. Pass 0.
    ushort* desc;                        /// Description text
    ushort* intext;                      /// Initial text
    int     outtextlength;               /// Length of output text
    ushort* outtext;                     /// Pointer to the output text
    SceUtilityOskResult result;          /// Result.
    int     outtextlimit;                /// The max text that can be input
}

/**
 * OSK parameters
 */
struct SceUtilityOskParams {
	pspUtilityDialogCommon base;
	int datacount;           /// Number of input fields
	SceUtilityOskData* data; /// Pointer to the start of the data for the input fields
	int state;               /// The local OSK state, one of ::SceUtilityOskState
	int unk_60;              /// Unknown. Pass 0
	
}

static this() {
	mixin(Module.registerModule("sceUtility"));
}