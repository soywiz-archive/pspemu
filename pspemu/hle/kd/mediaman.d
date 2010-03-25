module pspemu.hle.kd.mediaman; // kd/mediaman.prx (sceUmd_driver):

import pspemu.hle.Module;
 
class sceUmdUser : Module {
	void initNids() {
		mixin(registerd!(0xC6183D47, sceUmdActivate));
		mixin(registerd!(0x6B4A146C, sceUmdGetDriveStat));
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