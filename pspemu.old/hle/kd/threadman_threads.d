module pspemu.hle.kd.threadman_threads;

import pspemu.hle.kd.threadman_common;

template ThreadManForUser_Threads() {
	/**
	 * Thread Manager
	 */
	PspThreadManager threadManager;

	void initModule_Threads() {
		threadManager = new PspThreadManager(this);
	}

	void initNids_Threads() {
		mixin(registerd!(0x9ACE131E, sceKernelSleepThread));
		mixin(registerd!(0x82826F70, sceKernelSleepThreadCB));
		mixin(registerd!(0x446D8DE6, sceKernelCreateThread));
		mixin(registerd!(0x9FA03CD3, sceKernelDeleteThread));
		mixin(registerd!(0xF475845D, sceKernelStartThread));
		mixin(registerd!(0xAA73C935, sceKernelExitThread));
		mixin(registerd!(0x809CE29B, sceKernelExitDeleteThread));
		mixin(registerd!(0x293B45B8, sceKernelGetThreadId));
		mixin(registerd!(0x17C1684E, sceKernelReferThreadStatus));
		mixin(registerd!(0x278C0DF5, sceKernelWaitThreadEnd));
		mixin(registerd!(0xCEADEB47, sceKernelDelayThread));
		mixin(registerd!(0x68DA9E36, sceKernelDelayThreadCB));
		mixin(registerd!(0x383F7BCC, sceKernelTerminateDeleteThread));
		mixin(registerd!(0x71BC9871, sceKernelChangeThreadPriority));
		mixin(registerd!(0xEA748E31, sceKernelChangeCurrentThreadAttr));
		mixin(registerd!(0xD59EAD2F, sceKernelWakeupThread));
		mixin(registerd!(0x9944F31F, sceKernelSuspendThread));
		mixin(registerd!(0x840E8133, sceKernelWaitThreadEndCB));
		mixin(registerd!(0x94AA61EE, sceKernelGetThreadCurrentPriority));
		mixin(registerd!(0x75156E8F, sceKernelResumeThread));
		mixin(registerd!(0x616403BA, sceKernelTerminateThread));
		mixin(registerd!(0x3B183E26, sceKernelGetThreadExitStatus));
	}

	PspThread getThreadFromId(SceUID thid) {
		if ((thid in threadManager.createdThreads) is null) throw(new Exception(std.string.format("No thread with THID/UID(%d)", thid)));
		return threadManager.createdThreads[thid];
	}

	/**
	 * Resume a thread previously put into a suspended state with ::sceKernelSuspendThread.
	 *
	 * @param thid - UID of the thread to resume.
	 *
	 * @return Success if >= 0, an error if < 0.
	 */
	int sceKernelResumeThread(SceUID thid) {
		unimplemented();
		return -1;
	}

	/**
	 * Create a thread
	 *
	 * @par Example:
	 * @code
	 * SceUID thid;
	 * thid = sceKernelCreateThread("my_thread", threadFunc, 0x18, 0x10000, 0, NULL);
	 * @endcode
	 *
	 * @param name         - An arbitrary thread name.
	 * @param entry        - The thread function to run when started.
	 * @param initPriority - The initial priority of the thread. Less if higher priority.
	 * @param stackSize    - The size of the initial stack.
	 * @param attr         - The thread attributes, zero or more of ::PspThreadAttributes.
	 * @param option       - Additional options specified by ::SceKernelThreadOptParam.

	 * @return UID of the created thread, or an error code.
	 */
	SceUID sceKernelCreateThread(string name, SceKernelThreadEntry entry, int initPriority, int stackSize, SceUInt attr, SceKernelThreadOptParam *option) {
		auto pspThread = new PspThread(threadManager);

		SceUID thid = 0; foreach (thid_cur; threadManager.createdThreads.keys) if (thid < thid_cur) thid = thid_cur; thid++;

		threadManager.createdThreads[thid] = pspThread;
		
		pspThread.thid = thid;

		pspThread.name = cast(string)pspThread.info.name[0..name.length];

		pspThread.info.name[0..name.length] = name[0..name.length];
		pspThread.info.currentPriority = pspThread.info.initPriority = initPriority;
		pspThread.info.size      = pspThread.info.sizeof;
		pspThread.info.stackSize = stackSize;
		pspThread.info.entry     = entry;
		pspThread.info.attr      = attr;
		pspThread.info.status    = PspThreadStatus.PSP_THREAD_STOPPED;

		// Set stack.
		pspThread.createStack(moduleManager.get!(SysMemUserForUser));
		
		// Set extra info.
		pspThread.info.gpReg = cast(void *)executionState.registers.GP;

		// Set thread registers.
		with (pspThread.registers) {
			pspThread.registers.R[] = 0; // Clears all the registers (though it's not necessary).
			pcSet(entry);
			GP = executionState.registers.GP;
			SP = pspThread.stack.block.high - 0x600;
			//K0 = pspThread.stack.block.high - 0x600; //?
			RA = 0x08000200; // sceKernelExitDeleteThread
		}

		return thid;
	}

	/**
	 * Start a created thread
	 *
	 * @param thid   - Thread id from sceKernelCreateThread
	 * @param arglen - Length of the data pointed to by argp, in bytes
	 * @param argp   - Pointer to the arguments.
	 */
	int sceKernelStartThread(SceUID thid, SceSize arglen, void* argp) {
		if (thid < 0) return -1;
		auto pspThread = getThreadFromId(thid);
		if (pspThread is null) {
			writefln("sceKernelStartThread: Null");
			return -1;
		}
		//writefln("sceKernelStartThread:%d,%d,%d", thid, arglen, executionState.memory.getPointerReverseOrNull(argp));
		pspThread.registers.A0 = arglen;
		pspThread.registers.A1 = executionState.memory.getPointerReverseOrNull(argp);
		pspThread.info.status  = PspThreadStatus.PSP_THREAD_RUNNING;
		threadManager.addToRunningList(pspThread);

		// NOTE: It's mandatory to switch immediately to this thread, because the new thread
		// may use volatile data (por example a value that will be change in the parent thread)
		// in a few instructions.
		// Set the value to the current thread.
		returnValue = 0;
		avoidAutosetReturnValue();

		// Then change to the next thread and avoid writting the return value to that thread.
		pspThread.switchToThisThread();

		return 0;
	}

	/**
	 * Delete a thread
	 *
	 * @param thid - UID of the thread to be deleted.
	 *
	 * @return < 0 on error.
	 */
	int sceKernelDeleteThread(SceUID thid) {
		if (thid < 0) return -1;
		auto pspThread = getThreadFromId(thid);
		threadManager.createdThreads.remove(thid);
		if (pspThread is null) {
			throw(new Exception("Invalid sceKernelDeleteThread"));
			return -1;
		}
		pspThread.exit();
		return 0;
	}

	/** 
	  * Exit a thread and delete itself.
	  *
	  * @param status - Exit status
	  */
	int sceKernelExitDeleteThread(int status) {
		return sceKernelExitThread(status);
	}

	/**
	 * Terminate and delete a thread.
	 *
	 * @param thid - UID of the thread to terminate and delete.
	 *
	 * @return Success if >= 0, an error if < 0.
	 */
	int sceKernelTerminateDeleteThread(SceUID thid) {
		return sceKernelDeleteThread(thid);
	}

	/**
	 * Exit a thread
	 *
	 * @param status - Exit status.
	 */
	int sceKernelExitThread(int status) {
		threadManager.currentThread.exit();
		return 0;
	}
	
	/**
	  * Change the threads current priority.
	  * 
	  * @param thid     - The ID of the thread (from sceKernelCreateThread or sceKernelGetThreadId)
	  * @param priority - The new priority (the lower the number the higher the priority)
	  *
	  * @par Example:
	  * @code
	  * int thid = sceKernelGetThreadId();
	  * // Change priority of current thread to 16
	  * sceKernelChangeThreadPriority(thid, 16);
	  * @endcode
	  *
	  * @return 0 if successful, otherwise the error code.
	  */
	int sceKernelChangeThreadPriority(SceUID thid, int priority) {
		if (thid < 0) return -1;
		auto pspThread = getThreadFromId(thid);
		pspThread.info.currentPriority = priority;
		return 0;
	}
	
	/**
	 * Modify the attributes of the current thread.
	 *
	 * @param unknown - Set to 0.
	 * @param attr    - The thread attributes to modify.  One of ::PspThreadAttributes.
	 *
	 * @return < 0 on error.
	 */
	int sceKernelChangeCurrentThreadAttr(int unknown, SceUInt attr) {
		threadManager.currentThread.info.attr = attr;
		return 0;
	}

	/** 
	 * Wait until a thread has ended.
	 *
	 * @param thid    - Id of the thread to wait for.
	 * @param timeout - Timeout in microseconds (assumed).
	 *
	 * @return < 0 on error.
	 */
	int sceKernelWaitThreadEnd(SceUID thid, SceUInt* timeout) {
		if (thid < 0) return -1;
		
		// @TODO implement timeout
		try {
			return threadManager.currentThread.pauseAndYield("sceKernelWaitThreadEnd", (PspThread pausedThread) {
				try {
					auto threadToWait = getThreadFromId(thid);
					if ((threadToWait is null) || !threadToWait.alive) throw(new Exception("sceKernelWaitThreadEnd.end"));
				} catch {
					pausedThread.resumeAndReturn(0);
				}
			});
		} catch (Object o) {
			writefln("sceKernelWaitThreadEnd: %s", o);
			return -1;
		}
	}

	/**
	 * Wake a thread previously put into the sleep state.
	 *
	 * @param thid - UID of the thread to wake.
	 *
	 * @return Success if >= 0, an error if < 0.
	 */
	int sceKernelWakeupThread(SceUID thid) {
		unimplemented();
		return -1;
	}

	/**
	 * Suspend a thread.
	 *
	 * @param thid - UID of the thread to suspend.
	 *
	 * @return Success if >= 0, an error if < 0.
	 */
	int sceKernelSuspendThread(SceUID thid) {
		unimplemented();
		return -1;
	}

	/** 
	 * Wait until a thread has ended and handle callbacks if necessary.
	 *
	 * @param thid    - Id of the thread to wait for.
	 * @param timeout - Timeout in microseconds (assumed).
	 *
	 * @return < 0 on error.
	 */
	int sceKernelWaitThreadEndCB(SceUID thid, SceUInt *timeout) {
		unimplemented();
		return -1;
	}
		
	/**
	 * Delay the current thread by a specified number of microseconds
	 *
	 * @param delay - Delay in microseconds.
	 *
	 * @par Example:
	 * <code>
	 *     sceKernelDelayThread(1000000); // Delay for a second
	 * </code>
	 */
	int sceKernelDelayThread(SceUInt delay) {
		mixin(changeAfterTimerPausedMicroseconds);

		return threadManager.currentThread.pauseAndYield("sceKernelDelayThread", (PspThread pausedThread) {
			if (!paused) pausedThread.resumeAndReturn(0);
		});
	}

	/**
	 * Delay the current thread by a specified number of microseconds and handle any callbacks.
	 *
	 * @param delay - Delay in microseconds.
	 *
	 * @par Example:
	 * <code>
	 *     sceKernelDelayThread(1000000); // Delay for a second
	 * </code>
	 */
	int sceKernelDelayThreadCB(SceUInt delay) {
		mixin(changeAfterTimerPausedMicroseconds);

		return threadManager.currentThread.pauseAndYield("sceKernelDelayThreadCB", (PspThread pausedThread) {
			processCallbacks();
			if (!paused) pausedThread.resumeAndReturn(0);
		});
	}

	/** 
	 * Get the status information for the specified thread.
	 * 
	 * @param thid - Id of the thread to get status
	 * @param info - Pointer to the info structure to receive the data.
	 * Note: The structures size field should be set to
	 * sizeof(SceKernelThreadInfo) before calling this function.
	 *
	 * @par Example:
	 * <code>
	 *     SceKernelThreadInfo status;
	 *     status.size = sizeof(SceKernelThreadInfo);
	 *     if (sceKernelReferThreadStatus(thid, &status) == 0) { Do something... }
	 * </code>
	 *
	 * @return 0 if successful, otherwise the error code.
	 */
	int sceKernelReferThreadStatus(SceUID thid, SceKernelThreadInfo* info) {
		if (thid < 0) return -1;
		auto thread = getThreadFromId(thid);
		if (thread is null) return -1;
		if (info   is null) return -2;

		//if (size < threadManager.currentThread.info)
		
		ubyte[] copyFrom = TA(threadManager.currentThread.info);
		ubyte[] copyTo   = (cast(ubyte*)info)[0..info.size];

		uint copyLength = pspemu.utils.Utils.min(copyFrom.length, copyTo.length);

		uint restoreSize = info.size;
		copyTo[0..copyLength] = copyFrom[0..copyLength];
		info.size = restoreSize;

		return 0;
	}

	/** 
	 * Get the current thread Id
	 *
	 * @return The thread id of the calling thread.
	 */
	SceUID sceKernelGetThreadId() {
		return threadManager.currentThread.thid;
	}

	/**
	 * Sleep thread
	 *
	 * @return < 0 on error.
	 */
	int sceKernelSleepThread() {
		// Sets the position of the thread to the syscall again.
		// Sets the thread as waiting.
		// Switch to another thread immediately.
		return threadManager.currentThread.pauseAndYield("sceKernelSleepThread", (PspThread pausedThread) {
			//writefln("sceKernelSleepThread");
		});
	}

	/**
	 * Sleep thread but service any callbacks as necessary
	 *
	 * @par Example:
	 * <code>
	 *     // Once all callbacks have been setup call this function
	 *     sceKernelSleepThreadCB();
	 * </code>
	 */
	int sceKernelSleepThreadCB() {
		// Ditto.
		return threadManager.currentThread.pauseAndYield("sceKernelSleepThreadCB", (PspThread pausedThread) {
			processCallbacks();
		});
	}

	/**
	 * Get the current priority of the thread you are in.
	 *
	 * @return The current thread priority
	 */
	int sceKernelGetThreadCurrentPriority() {
		unimplemented();
		return -1;
	}

	/**
	 * Terminate a thread.
	 *
	 * @param thid - UID of the thread to terminate.
	 *
	 * @return Success if >= 0, an error if < 0.
	 */
	int sceKernelTerminateThread(SceUID thid) {
		unimplemented();
		return -1;
	}

	/**
	 * Get the exit status of a thread.
	 *
	 * @param thid - The UID of the thread to check.
	 *
	 * @return The exit status
	 */
	int sceKernelGetThreadExitStatus(SceUID thid) {
		unimplemented();
		return 0;
	}
}
