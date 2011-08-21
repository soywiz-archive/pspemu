module pspemu.hle.kd.mediaman.sceUmd;

import std.file;
import pspemu.hle.ModuleNative;

import pspemu.hle.kd.mediaman.Types;
import pspemu.hle.kd.threadman.Types;
import pspemu.hle.Callbacks;
import pspemu.hle.kd.threadman.ThreadMan;

class sceUmdUser : HleModuleHost {
	mixin TRegisterModule;

	void initNids() {
		mixin(registerFunction!(0x20628E6F, sceUmdGetErrorStat));
		mixin(registerFunction!(0xAEE7404D, sceUmdRegisterUMDCallBack));
		mixin(registerFunction!(0xBD2BDE07, sceUmdUnRegisterUMDCallBack));
		mixin(registerFunction!(0x56202973, sceUmdWaitDriveStatWithTimer));
		mixin(registerFunction!(0x46EBB729, sceUmdCheckMedium));
		mixin(registerFunction!(0xC6183D47, sceUmdActivate));
		mixin(registerFunction!(0xE83742BA, sceUmdDeactivate));
		mixin(registerFunction!(0x6B4A146C, sceUmdGetDriveStat));
		mixin(registerFunction!(0x8EF08FCE, sceUmdWaitDriveStat));
		mixin(registerFunction!(0x4A9E5E29, sceUmdWaitDriveStatCB));
		mixin(registerFunction!(0x6AF9B50A, sceUmdCancelWaitDriveStat));
	}
	
	/** 
	  * Get the error code associated with a failed event
	  *
	  * @return < 0 on error, the error code on success
	  */
	int sceUmdGetErrorStat() {
		return 0;
	}
	
	int umdPspCallbackId;
	PspCallback umdPspCallback;
	
	/** 
	  * Register a callback for the UMD drive
	  * This function schedules a call to the callback with the current UMD status.
	  * So you can expect this to be executed when processing callbacks at least once. 
	  *
	  * @note Callback is of type UmdCallback
	  *
	  * @param cbid - A callback ID created from sceKernelCreateCallback
	  *
	  * @return < 0 on error
	  * @par Example:
	  * @code
	  * int umd_callback(int cbid, pspUmdState state, void *argument)
	  * {
	  *      //do something
	  * }     
	  * int cbid = sceKernelCreateCallback("UMD Callback", umd_callback, argument);
	  * sceUmdRegisterUMDCallBack(cbid);
	  * @endcode
	  */
	int sceUmdRegisterUMDCallBack(int cbid) {
		//logWarning("Not implemented: sceUmdRegisterUMDCallBack");
		unimplemented_notice();
		
		umdPspCallback = uniqueIdFactory.get!PspCallback(cbid);
		
		hleEmulatorState.callbacksHandler.register(CallbacksHandler.Type.Umd, umdPspCallback);
		umdPspCallbackId = cbid;
		triggerUmdStatusChange();
		
		return 0;
	}
	
	void triggerUmdStatusChange() {
		hleEmulatorState.callbacksHandler.trigger(CallbacksHandler.Type.Umd, [umdPspCallbackId, cast(uint)sceUmdGetDriveStat(), 0], 2);
	}
	
	/** 
	  * Un-register a callback for the UMD drive
	  *
	  * @param cbid - A callback ID created from sceKernelCreateCallback
	  *
	  * @return < 0 on error
	  */
	int sceUmdUnRegisterUMDCallBack(int cbid) {
		//unimplemented();
		if (umdPspCallback is null) return -1;
		hleEmulatorState.callbacksHandler.unregister(CallbacksHandler.Type.Umd, umdPspCallback);
		umdPspCallback = null;
		return 0;
	}
	
	/** 
	  * Wait for the UMD drive to reach a certain state
	  *
	  * @param stat    - One or more of ::pspUmdState
	  * @param timeout - Timeout value in microseconds
	  *
	  * @return < 0 on error
	  */
	int sceUmdWaitDriveStatWithTimer(int stat, uint timeout) {
		logWarning("Not implemented: sceUmdWaitDriveStatWithTimer");
		return 0;
	}
	
	/** 
	  * Check whether there is a disc in the UMD drive
	  *
	  * @return 0 if no disc present, 1 if the disc is present.
	  */
	int sceUmdCheckMedium() {
		//logWarning("Partially implemented: sceUmdCheckMedium");
		return 1;
	}
	
	/** 
	  * Activates the UMD drive
	  * 
	  * @param mode  - Mode.
	  * @param drive - A prefix string for the fs device to mount the UMD on (e.g. "disc0:")
	  *
	  * @return < 0 on error
	  *
	  * @par Example:
	  * @code
	  * // Wait for disc and mount to filesystem
	  * int i;
	  * i = sceUmdCheckMedium();
	  * if(i == 0)
	  * {
	  *    sceUmdWaitDriveStat(PSP_UMD_PRESENT);
	  * }
	  * sceUmdActivate(1, "disc0:"); // Mount UMD to disc0: file system
	  * sceUmdWaitDriveStat(PSP_UMD_READY);
	  * // Now you can access the UMD using standard sceIo functions
	  * @endcode
	  */
	int sceUmdActivate(int mode, string drive) {
		logWarning("Partially implemented: sceUmdActivate(%d, '%s')", mode, drive);
		//triggerUmdStatusChange();
		return 0;
	}
	
	/** 
	  * Deativates the UMD drive
	  * 
	  * @param mode  - Mode.
	  * @param drive - A prefix string for the fs device to mount the UMD on (e.g. "disc0:")
	  *
	  * @return < 0 on error
	  */
	int sceUmdDeactivate(int mode, const char *drive) {
		unimplemented_notice();
		return 0;
	}

	/** 
	  * Get (poll) the current state of the UMD drive
	  *
	  * @return < 0 on error, one or more of ::PspUmdState on success
	  */
	PspUmdState sceUmdGetDriveStat() {
		logTrace("Partially implemented: sceUmdGetDriveStat");
		return PspUmdState.PSP_UMD_PRESENT | PspUmdState.PSP_UMD_READY | PspUmdState.PSP_UMD_READABLE;
	}
	
	/** 
	  * Wait for the UMD drive to reach a certain state
	  *
	  * @param stat - One or more of ::pspUmdState
	  *
	  * @return < 0 on error
	  */
	int sceUmdWaitDriveStat(PspUmdState stat) {
		logWarning("Not implemented: sceUmdWaitDriveStat(%d)", stat);
		return 0;
	}
	
	/** 
	  * Wait for the UMD drive to reach a certain state (plus callback)
	  *
	  * @param stat    - One or more of ::pspUmdState
	  * @param timeout - Timeout value in microseconds
	  *
	  * @return < 0 on error
	  */
	int sceUmdWaitDriveStatCB(PspUmdState stat, uint timeout) {
		logWarning("Not implemented: sceUmdWaitDriveStatCB(%s:%d, %d)", to!string(stat), stat, timeout);
		
		hleEmulatorState.moduleManager.get!ThreadManForUser.sceKernelCheckCallback();
		
		return 0;
	}
	
	int sceUmdCancelWaitDriveStat() {
		unimplemented_notice();
		return 0;
	}
}
