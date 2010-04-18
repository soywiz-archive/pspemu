module pspemu.hle.kd.mediaman; // kd/mediaman.prx (sceUmd_driver):

import pspemu.hle.Module;
 
class sceUmdUser : Module {
	void initNids() {
		mixin(registerd!(0xC6183D47, sceUmdActivate));
		mixin(registerd!(0x6B4A146C, sceUmdGetDriveStat));
		mixin(registerd!(0x46EBB729, sceUmdCheckMedium));
		mixin(registerd!(0xE83742BA, sceUmdDeactivate));
		mixin(registerd!(0x4A9E5E29, sceUmdWaitDriveStatCB));
		mixin(registerd!(0x8EF08FCE, sceUmdWaitDriveStat));

		mixin(registerd!(0x20628E6F, sceUmdGetErrorStat));
		mixin(registerd!(0x56202973, sceUmdWaitDriveStatWithTimer));
		mixin(registerd!(0xAEE7404D, sceUmdRegisterUMDCallBack));
		mixin(registerd!(0xBD2BDE07, sceUmdUnRegisterUMDCallBack));
	}

	/** 
	 * Register a callback for the UMD drive
	 * @note Callback is of type UmdCallback
	 *
	 * @param cbid - A callback ID created from sceKernelCreateCallback
	 * @return < 0 on error
	 * @par Example:
	 * @code
	 * int umd_callback(int unknown, int event)
	 * {
	 *      //do something
	 * }     
	 * int cbid = sceKernelCreateCallback("UMD Callback", umd_callback, NULL);
	 * sceUmdRegisterUMDCallBack(cbid);
	 * @endcode
	 */
	int sceUmdRegisterUMDCallBack(int cbid) {
		unimplemented();
		return -1;
	}

	/** 
	 * Un-register a callback for the UMD drive
	 *
	 * @param cbid - A callback ID created from sceKernelCreateCallback
	 *
	 * @return < 0 on error
	 */
	int sceUmdUnRegisterUMDCallBack(int cbid) {
		unimplemented();
		return -1;
	}

	/** 
	 * Get the error code associated with a failed event
	 *
	 * @return < 0 on error, the error code on success
	 */
	int sceUmdGetErrorStat() {
		unimplemented();
		return -1;
	}

	/** 
	 * Wait for the UMD drive to reach a certain state
	 *
	 * @param stat - One or more of ::pspUmdState
	 *
	 * @param timeout - Timeout value in microseconds
	 *
	 * @return < 0 on error
	 */
	int sceUmdWaitDriveStatWithTimer(int stat, uint timeout) {
		unimplemented();
		return -1;
	}

	/** 
	 * Check whether there is a disc in the UMD drive
	 *
	 * @return 0 if no disc present, anything else indicates a disc is inserted.
	 */
	int sceUmdCheckMedium() {
		unimplemented();
		return -1;
	}

	/** 
	 * Deativates the UMD drive
	 * 
	 * @param unit - The unit to initialise (probably). Should be set to 1.
	 *
	 * @param drive - A prefix string for the fs device to mount the UMD on (e.g. "disc0:")
	 *
	 * @return < 0 on error
	 */
	int sceUmdDeactivate(int unit, string drive) {
		unimplemented();
		return -1;
	}

	/** 
	 * Wait for the UMD drive to reach a certain state
	 *
	 * @param stat - One or more of ::pspUmdState
	 *
	 * @return < 0 on error
	 */
	int sceUmdWaitDriveStat(int stat) {
		unimplemented();
		return -1;
	}

	/** 
	 * Wait for the UMD drive to reach a certain state (plus callback)
	 *
	 * @param stat - One or more of ::pspUmdState
	 *
	 * @param timeout - Timeout value in microseconds
	 *
	 * @return < 0 on error
	 */
	int sceUmdWaitDriveStatCB(int stat, uint timeout) {
		unimplemented();
		return -1;
	}

	/** 
	 * Activates the UMD drive
	 * 
	 * @param unit - The unit to initialise (probably). Should be set to 1.
	 *
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
	int sceUmdActivate(int unit, string drive) {
		unimplemented();
		return -1;
	}

	/** 
	 * Get (poll) the current state of the UMD drive
	 *
	 * @return < 0 on error, one or more of ::pspUmdState on success
	 */
	int sceUmdGetDriveStat() {
		unimplemented();
		return -1;
	}
}

static this() {
	mixin(Module.registerModule("sceUmdUser"));
}