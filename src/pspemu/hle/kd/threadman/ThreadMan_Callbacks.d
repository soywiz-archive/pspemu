module pspemu.hle.kd.threadman.ThreadMan_Callbacks;

import pspemu.hle.kd.threadman.Types;

/**
 * Callbacks related stuff.
 */
template ThreadManForUser_Callbacks() {
	void initModule_Callbacks() {
		
	}
	
	void initNids_Callbacks() {
		mixin(registerFunction!(0xE81CAF8F, sceKernelCreateCallback));
		mixin(registerFunction!(0xEDBA5844, sceKernelDeleteCallback));
		mixin(registerFunction!(0x349D6D6C, sceKernelCheckCallback));
		mixin(registerFunction!(0xC11BA8C4, sceKernelNotifyCallback));
	    mixin(registerFunction!(0x2A3D44FF, sceKernelGetCallbackCount));
	}
	
	/**
	 * Notify a callback
	 *
	 * @param cb   - The UID of the specified callback
	 * @param arg2 - Passed as arg2 into the callback function
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelNotifyCallback(SceUID cb, int arg2) {
		PspCallback pspCallback = uniqueIdFactory.get!PspCallback(cb);
		
		hleEmulatorState.executeGuestCode(currentThreadState, pspCallback.func, [pspCallback.arg, arg2]);
		
		return 0;
	}

	/**
	 * Create callback
	 *
	 * @par Example:
	 * @code
	 * int cbid;
	 * cbid = sceKernelCreateCallback("Exit Callback", exit_cb, NULL);
	 * @endcode
	 *
	 * @param name - A textual name for the callback
	 * @param func - A pointer to a function that will be called as the callback
	 * @param arg  - Argument for the callback ?
	 *
	 * @return >= 0 A callback id which can be used in subsequent functions, < 0 an error.
	 */
	int sceKernelCreateCallback(string name, SceKernelCallbackFunction func, uint arg) {
		PspCallback pspCallback = new PspCallback(name, func, arg);
		int uid = uniqueIdFactory.add(pspCallback);
		logInfo("sceKernelCreateCallback('%s':%d, %08X, %08X)", name, uid, cast(uint)func, cast(uint)arg);
		return uid;
	}
	
	/**
	 * Delete a callback
	 *
	 * @param cb - The UID of the specified callback
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelDeleteCallback(SceUID cb) {
		uniqueIdFactory.remove!PspCallback(cb);
		return 0;
	}

	/**
	 * Run all peding callbacks and return if executed any.
	 *
	 * @note Callbacks cannot be executed inside a interrupt
	 *       Here callbacks can be executed.
	 *
	 * @return Returns:
	 *       0 - if the calling thread has no reported callbacks
	 *       1 - if the calling thread has reported callbacks which were executed successfully.
	 */
	int sceKernelCheckCallback() {
		int result = hleEmulatorState.callbacksHandler.executeQueued(currentThreadState) ? 1 : 0;
		if (result != 0) {
			//logError("sceKernelCheckCallback: %d", result);
		}
		return result;
	}
	
	/**
	 * Get the callback count
	 *
	 * @param cb - The UID of the specified callback
	 *
	 * @return The callback count, < 0 on error
	 */
	int sceKernelGetCallbackCount(SceUID cb) {
		PspCallback pspCallback = uniqueIdFactory.get!PspCallback(cb);
		return pspCallback.notifyCount;
	}

}