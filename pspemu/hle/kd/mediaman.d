module pspemu.hle.kd.mediaman; // kd/mediaman.prx (sceUmd_driver):

import pspemu.hle.Module;
 
class sceUmdUser : Module {
	void initNids() {
		mixin(registerd!(0xC6183D47, sceUmdActivate));
		mixin(registerd!(0x6B4A146C, sceUmdGetDriveStat));
		mixin(registerd!(0x46EBB729, sceUmdCheckMedium));
		mixin(registerd!(0xE83742BA, sceUmdDeactivate));
		mixin(registerd!(0x4A9E5E29, sceUmdWaitDriveStatCB));
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