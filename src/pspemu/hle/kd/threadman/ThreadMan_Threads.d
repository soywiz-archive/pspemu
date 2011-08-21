module pspemu.hle.kd.threadman.ThreadMan_Threads;

import std.datetime;

import pspemu.hle.kd.sysmem.SysMem;

import pspemu.hle.kd.threadman.Types;
import pspemu.core.ThreadState;
import pspemu.hle.ModuleNative;

import pspemu.utils.sync.WaitMultipleObjects;

import pspemu.utils.Logger;

template ThreadManForUser_Threads() {
	/**
	 * Thread Manager
	 */
	//PspThreadManager threadManager;

	void initModule_Threads() {
		//threadManager = new PspThreadManager(this);
	}

	void initNids_Threads() {
		mixin(registerFunction!(0x446D8DE6, sceKernelCreateThread));
		mixin(registerFunction!(0xF475845D, sceKernelStartThread ));
		mixin(registerFunction!(0xAA73C935, sceKernelExitThread  ));
		mixin(registerFunction!(0xEA748E31, sceKernelChangeCurrentThreadAttr));
		mixin(registerFunction!(0x293B45B8, sceKernelGetThreadId));
		mixin(registerFunction!(0x17C1684E, sceKernelReferThreadStatus));
		mixin(registerFunction!(0x71BC9871, sceKernelChangeThreadPriority));
		mixin(registerFunction!(0x809CE29B, sceKernelExitDeleteThread));
		mixin(registerFunction!(0x9FA03CD3, sceKernelDeleteThread));
		mixin(registerFunction!(0x383F7BCC, sceKernelTerminateDeleteThread));
		mixin(registerFunction!(0x94AA61EE, sceKernelGetThreadCurrentPriority));
		mixin(registerFunction!(0x75156E8F, sceKernelResumeThread));
		mixin(registerFunction!(0xD59EAD2F, sceKernelWakeupThread));
		mixin(registerFunction!(0x9944F31F, sceKernelSuspendThread));
		mixin(registerFunction!(0x616403BA, sceKernelTerminateThread));
		mixin(registerFunction!(0x3B183E26, sceKernelGetThreadExitStatus));

		mixin(registerFunction!(0x9ACE131E, sceKernelSleepThread,                   FunctionOptions.NoSynchronized));
		mixin(registerFunction!(0x82826F70, sceKernelSleepThreadCB,                 FunctionOptions.NoSynchronized));
		mixin(registerFunction!(0xCEADEB47, sceKernelDelayThread,                   FunctionOptions.NoSynchronized));
		mixin(registerFunction!(0x68DA9E36, sceKernelDelayThreadCB,                 FunctionOptions.NoSynchronized));
		mixin(registerFunction!(0x278C0DF5, sceKernelWaitThreadEnd,                 FunctionOptions.NoSynchronized));
		mixin(registerFunction!(0x840E8133, sceKernelWaitThreadEndCB,               FunctionOptions.NoSynchronized));
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
	SceUID sceKernelCreateThread(string name, SceKernelThreadEntry entry, int initPriority, int stackSize, PspThreadAttributes attr, SceKernelThreadOptParam *option) {
		ThreadState newThreadState = new ThreadState(dupStr(name), currentEmulatorState, new Registers());
		
		newThreadState.threadModule = currentThreadState.threadModule;
		
		newThreadState.registers.copyFrom(currentRegisters);
		newThreadState.registers.pcSet = entry;
		
		//allocStack
		
		//auto segment = hleEmulatorState.moduleManager.get!SysMemUserForUser().allocStack(stackSize, std.string.format("stack for thread '%s'", name), true);
		//newThreadState.registers.SP = segment.block.high; 
		
		newThreadState.registers.SP = hleEmulatorState.memoryManager.allocStack(
			PspPartition.User,
			std.string.format("stack for thread '%s'", name),
			stackSize,
			!(attr & PspThreadAttributes.PSP_THREAD_ATTR_NO_FILLSTACK)
		);
		
		newThreadState.registers.RA = 0x08000000;
		newThreadState.thid = uniqueIdFactory.add(newThreadState);
		
		logInfo("sceKernelCreateThread(thid:'%d', entry:%08X, name:'%s', initPriority=%d, SP:0x%08X)", newThreadState.thid, entry, name, initPriority, newThreadState.registers.SP);
		
		newThreadState.sceKernelThreadInfo.attr = attr;
		newThreadState.sceKernelThreadInfo.name[0..name.length] = name;
		newThreadState.sceKernelThreadInfo.initPriority = initPriority;
		newThreadState.sceKernelThreadInfo.currentPriority = initPriority;
		newThreadState.sceKernelThreadInfo.gpReg = cast(void *)currentRegisters().GP;
		newThreadState.sceKernelThreadInfo.stackSize = stackSize;
		newThreadState.sceKernelThreadInfo.stack = cast(void *)(newThreadState.registers.SP - stackSize);
		newThreadState.sceKernelThreadInfo.entry = entry;
		newThreadState.sceKernelThreadInfo.size = SceKernelThreadInfo.sizeof;
		newThreadState.sceKernelThreadInfo.status = PspThreadStatus.PSP_THREAD_STOPPED;

		newThreadState.name = cast(string)newThreadState.sceKernelThreadInfo.name[0..name.length];
		
		return newThreadState.thid;
	}
	
	/**
	 * Start a created thread
	 *
	 * @param thid   - Thread id from sceKernelCreateThread
	 * @param arglen - Length of the data pointed to by argp, in bytes
	 * @param argp   - Pointer to the arguments.
	 */
	int sceKernelStartThread(SceUID thid, SceSize arglen, /*void**/ uint argp) {
		logInfo("sceKernelStartThread(%d, %d, %08X)", thid, arglen, argp);
		
		ThreadState newThreadState = uniqueIdFactory.get!(ThreadState)(thid);
		
		newThreadState.registers.A0 = arglen;
		newThreadState.registers.A1 = argp;
		
		CpuThreadBase newCpuThread = currentCpuThread().createCpuThread(newThreadState);
		
		newCpuThread.start();

		newThreadState.sceKernelThreadInfo.status = PspThreadStatus.PSP_THREAD_RUNNING;

		currentCpuThread.threadState.waitingBlock("sceKernelStartThread", {
			// newCpuThread could access parent's stack because it has some cycles at the start.
			newCpuThread.thisThreadWaitCyclesAtLeast(1_000_000);
		});
		
		return 0;
	}
	
	void _sceKernelTerminateThread(ThreadState threadState) {
		logInfo("_sceKernelTerminateThread(%s)", threadState);
		threadState.sceKernelThreadInfo.status |=  PspThreadStatus.PSP_THREAD_STOPPED;
		threadState.sceKernelThreadInfo.status &= ~PspThreadStatus.PSP_THREAD_RUNNING;
		threadState.onDeleteThread();
		threadState.threadEndedEvent.signal();
	}

	/**
	 * Exit a thread
	 *
	 * @param status - Exit status.
	 */
	void sceKernelExitThread(int status) {
		ThreadState threadState = currentCpuThread.threadState; 
		
		threadState.sceKernelThreadInfo.exitStatus = status;
		logInfo("sceKernelExitThread(%d)", status);

		_sceKernelTerminateThread(threadState);

		//writefln("sceKernelExitThread(%d)", status);
		throw(new HaltException(std.string.format("sceKernelExitThread(%d)", status)));
	}
	
	/** 
	  * Exit a thread and delete itself.
	  *
	  * @param status - Exit status
	  */
	int sceKernelExitDeleteThread(int status) {
		logInfo("sceKernelExitDeleteThread(%d)", status);
		throw(new HaltException(std.string.format("sceKernelExitDeleteThread(%d)", status)));
		return 0;
	}
	
	WaitMultipleObjects _getWaitMultipleObjects(bool handleCallbacks, bool addWakeup = false) {
		WaitMultipleObjects waitMultipleObjects = new WaitMultipleObjects();

		// We will listen to the stopping event that will launch a HaltException when triggered.		
		waitMultipleObjects.add(currentEmulatorState.runningState.stopEventCpu);
		
		// If while sleeping we have to handle callbacks, we will listen to those too.
		if (handleCallbacks) {
			waitMultipleObjects.add(hleEmulatorState.callbacksHandler.waitEvent);
			// @TODO
		}
		
		if (addWakeup) {
			waitMultipleObjects.add(currentThreadState.wakeUpEvent);
		}
		
		waitMultipleObjects.object = currentThreadState;
		
		return waitMultipleObjects;
	}

	int _sceKernelSleepThreadCB(bool handleCallbacks) {
		currentThreadState.waitingBlock("_sceKernelSleepThreadCB", {
			currentThreadState.sleepingCriticalSection.lock({
				scope waitMultipleObjects = _getWaitMultipleObjects(handleCallbacks, true);
				
				logInfo("_sceKernelSleepThreadCB() :: wakeUpCount:%d", currentThreadState.getWakeUpCount());

				if (currentThreadState.getWakeUpCount() >= 0) {
					currentThreadState.decrementWakeUpCount();
				}
				
				//logInfo("@@ Thread sleeping(%s)", currentCpuThread.threadState);
				while (currentThreadState.getWakeUpCount() < 0) {
					waitMultipleObjects.waitAny();
				}
			});
		});
		
		return 0;
	}
	
	int _sceKernelDelayThread(SceUInt delayInMicroseconds, bool handleCallbacks) {
		scope waitMultipleObjects = _getWaitMultipleObjects(handleCallbacks);
		
		currentCpuThread.threadState.waitingBlock(std.string.format("_sceKernelDelayThread%s(%d)", handleCallbacks ? "CB" : "", delayInMicroseconds), {
			scope StopWatch stopWatch;
			
			stopWatch.start();

			try {
				//currentThreadState.sleeping = true;
				while (true) {
					long microsecondsToWaitMax = delayInMicroseconds - stopWatch.peek.usecs;
					if (microsecondsToWaitMax <= 0) break;
	
					waitMultipleObjects.waitAny(cast(uint)(microsecondsToWaitMax / 1000));
				}
			} catch (HaltException haltException) {
				logWarning("HaltException launched on sceKernelDelayThread");
				throw(haltException);
			}
			
			stopWatch.stop();
			//logTrace("Time sleeping %s", stopWatch);
		});

		return 0;
	}
	
	/**
	 * Sleep thread until sceKernelWakeUp is called.
	 *
	 * @return < 0 on error.
	 */
	int sceKernelSleepThread() {
		//logInfo("sceKernelSleepThread()");
		return _sceKernelSleepThreadCB(false);
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
		logInfo("sceKernelSleepThreadCB()");
		return _sceKernelSleepThreadCB(true);
	}
	
	/**
	 * Wake a thread previously put into the sleep state.
	 *
	 * @note
	 * This function increments a wakeUp count and sceKernelSleep(CB) decrements it.
	 * So when calling sceKernelSleep(CB) if this function have been executed before one or more times,
	 * the thread won't sleep until Sleeps is executed as many times as sceKernelWakeupThread.
	 *
	 * ?? This waits until the thread has been awaken? TO CONFIRM.
	 *
	 * @param thid - UID of the thread to wake.
	 *
	 * @return Success if >= 0, an error if < 0.
	 */
	int sceKernelWakeupThread(SceUID thid) {
		ThreadState threadState = uniqueIdFactory.get!(ThreadState)(thid);
		
		logInfo("sceKernelWakeupThread");
		
		threadState.sleepingCriticalSection.tryLock({
			threadState.incrementWakeUpCount();
		}, {
			threadState.resetWakeUpCount();
			threadState.wakeUpEvent.signal();
			
			// Must wait until terminated?
			threadState.sleepingCriticalSection.waitEnded();
		});

		return 0;
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
		logTrace("sceKernelDelayThread(%d)", delay);
		scope (exit) logTrace("Returning from sceKernelDelayThreadCB");
		return _sceKernelDelayThread(delay, /*callbacks = */false);
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
		logTrace("sceKernelDelayThreadCB(%d)", delay);
		scope (exit) logTrace("Returning from sceKernelDelayThreadCB");
		return _sceKernelDelayThread(delay, /*callbacks = */true);
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
		//writefln("UNIMPLEMENTED: sceKernelChangeCurrentThreadAttr(%d, %d)", unknown, attr);
		unimplemented_notice();
		//threadManager.currentThread.info.attr = attr;
		return 0;
	}

	/** 
	 * Get the current thread Id
	 *
	 * @return The thread id of the calling thread.
	 */
	SceUID sceKernelGetThreadId() {
		logTrace("sceKernelGetThreadId()");
		return currentThreadState().thid;
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
		// @TODO : @README Threads start by uid 0? or 0 means the current thread?!
		
		logInfo("sceKernelReferThreadStatus(%d)", thid);
		if (thid < 0) return -1;
		ThreadState threadState = uniqueIdFactory.get!(ThreadState)(thid);
		if (threadState is null) return -1;
		if (info        is null) return -2;

		// @TODO use size when copying
		//info.size;
		
		*info = threadState.sceKernelThreadInfo;
		
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
		logInfo("sceKernelChangeThreadPriority(%d, %d)", thid, priority);
		try {
			if (thid < 0) return -1;
			ThreadState threadState = uniqueIdFactory.get!(ThreadState)(thid);
			threadState.sceKernelThreadInfo.currentPriority = priority; 
			return 0;
		} catch {
			logError("sceKernelChangeThreadPriority");
			return 0;
		}
	}
	
	/**
	 * Get the current priority of the thread you are in.
	 *
	 * @return The current thread priority
	 */
	int sceKernelGetThreadCurrentPriority() {
		ThreadState threadState = ThreadState.getFromThread();
		return threadState.sceKernelThreadInfo.currentPriority;
	}

	
	int _sceKernelWaitThreadEndCB(SceUID thid, SceUInt* timeout, bool handleCallbacks) {
		currentThreadState.waitingBlock(std.string.format("_sceKernelWaitThreadEndCB%s(thid=%d)", handleCallbacks ? "CB" : "", thid), {
			logInfo("_sceKernelWaitThreadEndCB");

			ThreadState threadState = uniqueIdFactory.get!(ThreadState)(thid);
			
			WaitMultipleObjects waitMultipleObjects = _getWaitMultipleObjects(handleCallbacks, false);
			
			// @TODO: Only one per thread!
			waitMultipleObjects.add(threadState.threadEndedEvent);
			
			//writefln("threadState.sceKernelThreadInfo.status: %d", threadState.sceKernelThreadInfo.status);
			
			bool mustContinue() {
				if (threadState.sceKernelThreadInfo.status & PspThreadStatus.PSP_THREAD_STOPPED) return false;
				if (threadState.sceKernelThreadInfo.status & PspThreadStatus.PSP_THREAD_KILLED) return false;
				return true;
			}
			
			try {
				while (mustContinue) {
					if (timeout is null) {
						waitMultipleObjects.waitAnyException();
					} else {
						waitMultipleObjects.waitAnyException(cast(uint)std.datetime.convert!("usecs", "msecs")(*timeout));
					}
				}
			} catch (WaitObjectTimeoutException) {
				
			}
		});
		
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
		return _sceKernelWaitThreadEndCB(thid, timeout, false);
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
		return _sceKernelWaitThreadEndCB(thid, timeout, true);
	}

	/**
	 * Terminate a thread.
	 *
	 * @param thid - UID of the thread to terminate.
	 *
	 * @return Success if >= 0, an error if < 0.
	 */
	int sceKernelTerminateThread(SceUID thid) {
		ThreadState threadState = uniqueIdFactory.get!(ThreadState)(thid);
		_sceKernelTerminateThread(threadState);
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
		uniqueIdFactory.remove!(ThreadState)(thid);
		return 0;
	}

	/**
	 * Terminate and delete a thread.
	 *
	 * @param thid - UID of the thread to terminate and delete.
	 *
	 * @return Success if >= 0, an error if < 0.
	 */
	int sceKernelTerminateDeleteThread(SceUID thid) {
		sceKernelTerminateThread(thid);
		return sceKernelDeleteThread(thid);
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
	 * Get the exit status of a thread.
	 *
	 * @param thid - The UID of the thread to check.
	 *
	 * @return The exit status
	 */
	int sceKernelGetThreadExitStatus(SceUID thid) {
		ThreadState threadState = uniqueIdFactory.get!(ThreadState)(thid);
		//unimplemented();
		return threadState.sceKernelThreadInfo.exitStatus;
	}
}

/+
enum PspThreadStatus {
	PSP_THREAD_RUNNING = 1,
	PSP_THREAD_READY   = 2,
	PSP_THREAD_WAITING = 4,
	PSP_THREAD_SUSPEND = 8,
	PSP_THREAD_STOPPED = 16, // Before startThread
	PSP_THREAD_KILLED  = 32, // Thread manager has killed the thread (stack overflow)
}

struct SceKernelThreadInfo {
	/** Size of the structure */
	SceSize     size;
	/** Nul terminated name of the thread */
	char    	name[32];
	/** Thread attributes */
	SceUInt     attr;
	/** Thread status */
	PspThreadStatus status;
	/** Thread entry point */
	SceKernelThreadEntry    entry;
	/** Thread stack pointer */
	void *  	stack;
	/** Thread stack size */
	int     	stackSize;
	/** Pointer to the gp */
	void *  	gpReg;
	/** Initial priority */
	int     	initPriority;
	/** Current priority */
	int     	currentPriority;
	/** Wait type */
	int     	waitType;
	/** Wait id */
	SceUID  	waitId;
	/** Wakeup count */
	int     	wakeupCount;
	/** Exit status of the thread */
	int     	exitStatus;
	/** Number of clock cycles run */
	SceKernelSysClock   runClocks;
	/** Interrupt preemption count */
	SceUInt     intrPreemptCount;
	/** Thread preemption count */
	SceUInt     threadPreemptCount;
	/** Release count */
	SceUInt     releaseCount;
}
+/
