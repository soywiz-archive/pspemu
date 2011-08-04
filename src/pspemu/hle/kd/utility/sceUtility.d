module pspemu.hle.kd.utility.sceUtility; // kd/utility.prx (sceUtility_Driver):

import std.string;
import std.conv;
import std.file;
import std.utf;
import std.c.windows.windows;

import pspemu.hle.ModuleNative;
import pspemu.hle.HleEmulatorState;

import pspemu.hle.kd.utility.sceUtility_Sysparam;

import pspemu.hle.kd.utility.Types;

extern (Windows) {
	int MessageBoxW(HWND hWnd, wchar* lpText, wchar* lpCaption, UINT uType);
}

wchar* toStringz(wstring str) {
	return cast(wchar *)(str ~ '\0').ptr;
}

class sceUtility : ModuleNative {
	mixin sceUtility_sysparams;

	void initNids() {
		mixin(registerd!(0x50C4CD57, sceUtilitySavedataInitStart));
		mixin(registerd!(0x9790B33C, sceUtilitySavedataShutdownStart));
		mixin(registerd!(0xD4B95FFB, sceUtilitySavedataUpdate));
		mixin(registerd!(0x8874DBE0, sceUtilitySavedataGetStatus));

		mixin(registerd!(0x5EEE6548, sceUtilityCheckNetParam));
		mixin(registerd!(0x434D4B3A, sceUtilityGetNetParam));

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
		
		mixin(registerd!(0x2A2B3DE0, sceUtilityLoadModule));
		mixin(registerd!(0xE49BFE92, sceUtilityUnloadModule));
		
		mixin(registerd!(0xC492F751, sceUtilityGameSharingInitStart));
		mixin(registerd!(0xEFC6F80F, sceUtilityGameSharingShutdownStart));
		mixin(registerd!(0x7853182D, sceUtilityGameSharingUpdate));
		mixin(registerd!(0x946963F3, sceUtilityGameSharingGetStatus));

		initNids_sysparams();
	}
	
	enum DialogStep {
		NONE         = 0,
		INIT         = 1,
		PROCESSING   = 2,
		SUCCESS      = 3,
		SHUTDOWN     = 4,
	}
	
	DialogStep currentDialogStep;

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
		unimplemented_notice();
		params.base.result = 0;
		
		int result = MessageBoxW(
			null,
			toStringz(toUTF16(to!string(params.message.ptr))),
			toStringz(toUTF16(std.string.format("Info (%08X)", currentThreadState.registers.PC))),
			MB_OKCANCEL | MB_ICONEXCLAMATION | MB_DEFBUTTON1
		);
		//int MessageBoxA(HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, UINT uType);
		
		switch (result) {
			case 2: // cancel
				params.buttonPressed = pspUtilityMsgDialogPressed.PSP_UTILITY_MSGDIALOG_RESULT_BACK;
			break;
			case 3, 5, 7: // abort, ignore, no
				params.buttonPressed = pspUtilityMsgDialogPressed.PSP_UTILITY_MSGDIALOG_RESULT_NO;
			break;
			case 11, 1, 4, 10, 6: // continue, ok, retry, try again, yes
				params.buttonPressed = pspUtilityMsgDialogPressed.PSP_UTILITY_MSGDIALOG_RESULT_YES;
			break;
			default:
				params.buttonPressed = pspUtilityMsgDialogPressed.PSP_UTILITY_MSGDIALOG_RESULT_UNKNOWN1;
			break;
		}
		
		/*
		pspUtilityMsgDialogPressed buttonPressed;
		
		PSP_UTILITY_MSGDIALOG_RESULT_UNKNOWN1 = 0,
		PSP_UTILITY_MSGDIALOG_RESULT_YES      = 1,
		PSP_UTILITY_MSGDIALOG_RESULT_NO       = 2,
		PSP_UTILITY_MSGDIALOG_RESULT_BACK     = 3,
		*/
		
		/*
		IDABORT
		3
		The Abort button was selected.
		
		IDCANCEL
		2
		The Cancel button was selected.
		
		IDCONTINUE
		11
		The Continue button was selected.
		
		IDIGNORE
		5
		The Ignore button was selected.
		
		IDNO
		7
		The No button was selected.
		
		IDOK
		1
		The OK button was selected.
		
		IDRETRY
		4
		The Retry button was selected.
		
		IDTRYAGAIN
		10
		The Try Again button was selected.
		
		IDYES
		6
		*/
		
		currentDialogStep = DialogStep.SUCCESS;
		return 0;
	}

	/**
	 * Remove a message dialog currently active.  After calling this
	 * function you need to keep calling GetStatus and Update until
	 * you get a status of 4.
	 */
	void sceUtilityMsgDialogShutdownStart() {
		unimplemented_notice();
		currentDialogStep = DialogStep.SHUTDOWN;
	}

	/**
	 * Refresh the GUI for a message dialog currently active
	 *
	 * @param n - unknown, pass 1
	 */
	void sceUtilityMsgDialogUpdate(int n) {
		unimplemented_notice();
	}
	
	DialogStep _sceUtilityMsgDialogGetStatus() {
		//unimplemented_notice();
		logInfo("sceUtilitySavedataGetStatus(%s:%d)", to!string(currentDialogStep), currentDialogStep);
		
		scope (exit) {
			// After returning SHUTDOWN, start returning NONE.
			if (currentDialogStep == DialogStep.SHUTDOWN) {
				currentDialogStep = DialogStep.NONE;
			}
		}

		return currentDialogStep;
	}


	/**
	 * Get the current status of a message dialog currently active.
	 *
	 * @return 2 if the GUI is visible (you need to call sceUtilityMsgDialogGetStatus).
	 *         3 if the user cancelled the dialog, and you need to call sceUtilityMsgDialogShutdownStart.
	 *         4 if the dialog has been successfully shut down.
	 */
	DialogStep sceUtilityMsgDialogGetStatus() {
		return _sceUtilityMsgDialogGetStatus();
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
	int sceUtilitySavedataInitStart(SceUtilitySavedataParam* params) {
		const int ERROR_SAVEDATA_SAVE_ACCESS_ERROR = 0x80110385;

		//toStringz(params.saveNameList);
		
		logWarning("Not implemented: sceUtilitySavedataInitStart(%s)", to!string(params.mode));
		
		std.file.write("lastsceUtilitySavedataInitStart.bin", params[0..1]);
		
		//string saveFilePath = "SAVE_" ~ to!string(params.fileName.ptr);
		string saveFilePath = "SAVE_" ~ to!string(params.gameName.ptr);
		//dataBuf
		void *dataBuf  = hleEmulatorState.emulatorState.memory.getPointerOrNull(cast(uint)params.dataBuf);
		ubyte[] data;
		if (dataBuf !is null) {
			data = (cast(ubyte *)dataBuf)[0..params.dataBufSize];
		}
		
		logTrace("sceUtilitySavedataInitStart[%08X:%d,%d]", cast(uint)dataBuf, params.dataSize, params.dataBufSize);
		
		int result = 0;
		
		switch (params.mode) {
			case PspUtilitySavedataMode.PSP_UTILITY_SAVEDATA_AUTOSAVE, PspUtilitySavedataMode.PSP_UTILITY_SAVEDATA_SAVE, PspUtilitySavedataMode.PSP_UTILITY_SAVEDATA_LISTSAVE:
			{
				std.file.write(saveFilePath, data[0..params.dataSize]);
				params.base.result = 0;
			}
			break;
			case PspUtilitySavedataMode.PSP_UTILITY_SAVEDATA_AUTOLOAD, PspUtilitySavedataMode.PSP_UTILITY_SAVEDATA_LOAD, PspUtilitySavedataMode.PSP_UTILITY_SAVEDATA_LISTLOAD:
			{
				try {
					if (std.file.exists(saveFilePath)) {
						auto readed = cast(ubyte[])std.file.read(saveFilePath);
						int minSize = min(readed.length, params.dataBufSize);
						data[0..minSize] = readed[0..minSize];
						params.base.result = 0;
					} else {
						params.base.result = SceKernelErrors.ERROR_SAVEDATA_LOAD_NO_DATA;
					}
				} catch (Throwable o) {
					logWarning("ERROR_SAVEDATA_SAVE_ACCESS_ERROR: %s", o);
					params.base.result = SceKernelErrors.ERROR_SAVEDATA_LOAD_ACCESS_ERROR;
					result = -1;
				}
				//result = -1;
			} 
			break;
			default:
				logError("sceUtilitySavedataInitStart: %d", params.mode);
				logError("sceUtilitySavedataInitStart: %d:%s", params.mode, to!string(params.mode));
				unimplemented_notice();
			break;
		}
		
		//currentDialogStep = DialogStep.PROMPT;
		currentDialogStep = DialogStep.SUCCESS;
		return result;
	}
	
	/**
	 * Check the current status of the saving/loading/shutdown process
	 * Continue calling this to check current status of the process
	 * before calling this call also sceUtilitySavedataUpdate
	 *
	 * @return 2 if the process is still being processed.
	 *         3 on save/load success, then you can call sceUtilitySavedataShutdownStart.
	 *         4 on complete shutdown.
	 */
	DialogStep sceUtilitySavedataGetStatus() {
		return _sceUtilityMsgDialogGetStatus();
	}

	/**
	 * Shutdown the savedata utility. after calling this continue calling
	 * ::sceUtilitySavedataGetStatus to check when it has shutdown
	 *
	 * @return 0 on success
	 */
	int sceUtilitySavedataShutdownStart() {
		unimplemented_notice();
		currentDialogStep = DialogStep.SHUTDOWN;
		return 0;
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
		unimplemented_notice();
		//return -1;
		return 0;
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
		//unimplemented();
		unimplemented_notice();
		Logger.log(Logger.Level.WARNING, "sceUtility", "sceUtilityLoadNetModule not implemented!");
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
	
	/**
	 * Load a module (PRX) from user mode.
	 *
	 * @param module - module to load (PSP_MODULE_xxx)
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceUtilityLoadModule(PspModule _module) {
		unimplemented_notice();
		logInfo("sceUtilityLoadModule(%s:%d)", to!string(_module), _module);
		switch (_module) {
			// Loaded modules.
			case PspModule.PSP_MODULE_AV_AVCODEC:
				return 0;
			break;
			default:
				logError("Not loaded: sceUtilityLoadModule(%s:%d)", to!string(_module), _module);
				//unimplemented();
				//return -1;
				//return SceKernelErrors.ERROR_MODULE_BAD_ID;
				return 0;
			break;
		}
	}
	
	/**
	 * Unload a module (PRX) from user mode.
	 *
	 * @param module - module to unload (PSP_MODULE_xxx)
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceUtilityUnloadModule(PspModule _module) {
		return -1;
	}
	
	enum pspUtilityGameSharingMode {
		PSP_UTILITY_GAMESHARING_MODE_SINGLE		= 1,	/* Single send */
		PSP_UTILITY_GAMESHARING_MODE_MULTIPLE	= 2		/* Up to 4 simultaneous sends */
	}
	
	enum pspUtilityGameSharingDataType {
		PSP_UTILITY_GAMESHARING_DATA_TYPE_FILE		= 1, /* EBOOT is a file */
		PSP_UTILITY_GAMESHARING_DATA_TYPE_MEMORY	= 2, /* EBOOT is in memory */
	}
	
	/**
	 * Structure to hold the parameters for Game Sharing
	**/
	struct pspUtilityGameSharingParams
	{
	    pspUtilityDialogCommon base;
	    int unknown1;							/* Set to 0 */
		int unknown2;							/* Set to 0 */
		char name[8];
		int unknown3;							/* Set to 0 */
		int unknown4;							/* Set to 0 */
		int unknown5;							/* Set to 0 */
		int result;								/* Return value */
		char *filepath;							/* File path if PSP_UTILITY_GAMESHARING_DATA_TYPE_FILE specified */
		pspUtilityGameSharingMode mode;			/* Send mode. One of ::pspUtilityGameSharingMode */
		pspUtilityGameSharingDataType datatype; /* Data type. One of ::pspUtilityGameSharingDataType */
		void *data;								/* Pointer to the EBOOT data in memory */
		uint datasize;				         	/* Size of the EBOOT data in memory */
	
	}
	
	/**
	 * Init the game sharing
	 *
	 * @param params - game sharing parameters
	 * @return 0 on success, < 0 on error.
	 */
	int sceUtilityGameSharingInitStart(pspUtilityGameSharingParams *params) {
		unimplemented();
		return 0;
	}
	
	/**
	 * Shutdown game sharing. 
	 */
	void sceUtilityGameSharingShutdownStart() {
		unimplemented();
	}
	
	/**
	 * Get the current status of game sharing.
	 *
	 * @return 2 if the GUI is visible (you need to call sceUtilityGameSharingGetStatus).
	 * 3 if the user cancelled the dialog, and you need to call sceUtilityGameSharingShutdownStart.
	 * 4 if the dialog has been successfully shut down.
	 */
	int sceUtilityGameSharingGetStatus() {
		unimplemented();
		return 0;
	}
	
	/**
	 * Refresh the GUI for game sharing
	 *
	 * @param n - unknown, pass 1
	 */
	void sceUtilityGameSharingUpdate(int n) {
		unimplemented();
	}

}

static this() {
	mixin(ModuleNative.registerModule("sceUtility"));
}