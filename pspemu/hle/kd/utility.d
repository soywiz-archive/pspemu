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
		
		initNids_sysparams();
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
}

union netData {
	u32 asUint;
	char asString[128];
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

static this() {
	mixin(Module.registerModule("sceUtility"));
}