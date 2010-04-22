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
		pspThread.info.gpReg = cast(void *)cpu.registers.GP;

		// Set thread registers.
		with (pspThread.registers) {
			pspThread.registers.R[] = 0; // Clears all the registers (though it's not necessary).
			pcSet(entry);
			GP = cpu.registers.GP;
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
		pspThread.registers.A0 = arglen;
		pspThread.registers.A1 = cpu.memory.getPointerReverseOrNull(argp);
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
	  * @param thid - The ID of the thread (from sceKernelCreateThread or sceKernelGetThreadId)
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
	 * @param attr - The thread attributes to modify.  One of ::PspThreadAttributes.
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
	 * @param thid - Id of the thread to wait for.
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
	 * @param thid - Id of the thread to wait for.
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
	 * @code
	 * sceKernelDelayThread(1000000); // Delay for a second
	 * @endcode
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
	 * @code
	 * sceKernelDelayThread(1000000); // Delay for a second
	 * @endcode
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
	 * @code
	 * SceKernelThreadInfo status;
	 * status.size = sizeof(SceKernelThreadInfo);
	 * if(sceKernelReferThreadStatus(thid, &status) == 0)
	 * { Do something... }
	 * @endcode 
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
	 * @code
	 * // Once all callbacks have been setup call this function
	 * sceKernelSleepThreadCB();
	 * @endcode
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
		return 0;
	}
}

class PspThreadManager {
	mixin ThreadSubsystemManager;

	PspThread currentThread;
	PspThread[] threadRunningList;
	PspThread[SceUInt] createdThreads;

	PspThread getNextThread(bool doThrow = false) {
		uint threadPreemptCount = -1;
		PspThread minThread;
		foreach (thread; threadRunningList) {
			if (thread.info.threadPreemptCount < threadPreemptCount) {
				threadPreemptCount = thread.info.threadPreemptCount;
				minThread = thread;
			}
		}
		if (doThrow && (minThread is null)) throw(new Exception("threadMinPreemptCount: null: No threads?"));
		return minThread;
	}
	
	uint threadMinPreemptCount() {
		auto thread = getNextThread();
		return thread ? thread.info.threadPreemptCount : 0;
	}

	void threadsRemoveDead() {
		PspThread[] list;
		foreach (thread; threadRunningList) if (thread.alive) list ~= thread;
		threadRunningList = list;
	}

	void threadsNormalizePreemptCount() {
		if (!threadRunningList.length) return;
		uint min = threadMinPreemptCount;
		foreach (thread; threadRunningList) thread.info.threadPreemptCount -= min;
	}

	void dumpThreads() {
		writefln("CurrentThread:");
		writefln("  %s", currentThread);
		writefln("Threads(%d) {", threadRunningList.length);
		foreach (thread; threadRunningList) {
			writefln("  %s", thread);
		}
		writefln("}");
	}

	bool allThreadsPaused() {
		foreach (thread; threadRunningList) if (!thread.paused) return false;
		return true;
	}

	void switchNextThread() {
		threadsNormalizePreemptCount();
		threadsRemoveDead();
		
		if (allThreadsPaused) sleep(1);

		if (threadRunningList.length == 0) {
			throw(new Exception("No threads left!"));
		}
		
		auto nextThread = getNextThread;
		nextThread.updatePreemptCount();

		debug (DEBUG_THREADS) {
			dumpThreads();
			writefln("Current: %s", currentThread);
			writefln("Next:    %s", nextThread);
		}

		nextThread.switchToThisThread();
	}

	void addToRunningList(PspThread pspThread) {
		pspThread.info.threadPreemptCount = threadMinPreemptCount;
		threadRunningList ~= pspThread;
	}
}

/**
 * A Thread in Psp machine.
 */
class PspThread {
	uint thid;

	/**
	 * Thread Manager associate to this thread.
	 */
	PspThreadManager threadManager;

	/**
	 * State of registers to restore when switching to this thread.
	 */
	Registers registers;

	/**
	 * State of registers before a pause.
	 */
	Registers resumeRegisters;

	/**
	 * Name of the thread.
	 */
	string name;

	/**
	 * Memory Segment with the stack.
	 */
	MemorySegment stack;

	/**
	 * Information of the thread.
	 */
	SceKernelThreadInfo info;

	/**
	 * Flag showing if this thread is paused.
	 */
	bool paused = false;

	/**
	 * Flag showing if this thread is alive.
	 */
	bool alive = true;
	
	string pausedName;
	alias void delegate(PspThread) PausedCallback;
	PausedCallback pausedCallback;

	this(PspThreadManager threadManager) {
		this.threadManager   = threadManager;
		this.registers       = new Registers;
		this.resumeRegisters = new Registers;
	}

	void executeHlePausedEnterCallback() {
		debug (DEBUG_THREADS) { writefln("  PspThread.executeHlePausedEnterCallback = 0x%08X", reinterpret!(uint)(pausedCallback)); }
		if (pausedCallback !is null) {
			pausedCallback(this);
		}
	}
	
	protected void switchTo() {
		threadManager.cpu.registers.copyFrom(registers);
		threadManager.currentThread = this;
	}

	protected void switchFrom() {
		registers.copyFrom(threadManager.cpu.registers);
	}
	
	void updatePreemptCount() {
		info.threadPreemptCount += (info.currentPriority + 1);
	}

	string toString() {
		return std.string.format(
			"Thread(ID=0x%06X, PC=0x%08X, SP=0x%08X, threadPreemptCount=0x%03X, currentPriority=0x%02X, stackSize=0x%05X\n"
			"    paused=%d, alive=%d, callback='%s':%08X, Name='%s')\n"
			"    resume-PC:%08X, resume-RA:%08X",
			reinterpret!(uint)(this), registers.PC, registers.SP, info.threadPreemptCount, info.currentPriority,
			info.stackSize, paused, alive, pausedName, reinterpret!(uint)(pausedCallback), name, resumeRegisters.PC, resumeRegisters.RA
		);
	}

	void switchToOtherThread() {
		debug (DEBUG_THREADS) { writefln("  PspThread.switchToOtherThread()"); }
		// Change execution to another thread.
		threadManager.switchNextThread();
	}

	void switchToThisThread() {
		if (paused) {
			executeHlePausedEnterCallback();
			threadManager.cpu.registers.PAUSED = true;
		} else {
			threadManager.cpu.registers.PAUSED = false;
			if (threadManager.currentThread != this) {
				if (threadManager.currentThread) threadManager.currentThread.switchFrom();
				this.switchTo();
			}
		}
	}

	uint pauseAndYield(string pausedName = null, PausedCallback pausedCallback = null) {
		debug (DEBUG_THREADS) { writefln("  PspThread.pauseAndYield(); callback = %s", reinterpret!(uint)(pausedCallback)); }
		
		assert(!paused);

		// Stalls at syscall.
		resumeRegisters.copyFrom(threadManager.cpu.registers);
		threadManager.cpu.registers.pcSet(0x08000010);

		this.pausedName     = pausedName;
		this.pausedCallback = pausedCallback;
		this.paused = true;
		threadManager.cpu.registers.PAUSED = true;
		//this.switchToOtherThread();

		threadManager.threadManForUser.avoidAutosetReturnValue();
		return 0;
	}

	void resume() {
		debug (DEBUG_THREADS) { writefln("  PspThread.resume()"); }

		assert(paused);
		
		paused = false;
		switchToThisThread();
		
		this.registers.copyFrom(resumeRegisters);
		threadManager.cpu.registers.copyFrom(resumeRegisters);
	}

	void resumeAndReturn(uint value) {
		resume();
		threadManager.cpu.registers.V0 = value;
	}

	void createStack(SysMemUserForUser sysMemUserForUser) {
		this.stack = sysMemUserForUser.allocStack(this.info.stackSize, this.name, !(this.info.attr & PspThreadAttributes.PSP_THREAD_ATTR_NO_FILLSTACK));
		if (!(this.info.attr & PspThreadAttributes.PSP_THREAD_ATTR_NO_FILLSTACK)) {
			// TODO: Fills to FF
			// Remove that code from allocStack.
		}
		this.info.stack = cast(void*)this.stack.block.low;
	}

	void deleteStack() {
		if (this.info.attr & PspThreadAttributes.PSP_THREAD_ATTR_CLEAR_STACK) {
			// TODO: Sets stack to 0
		}
		
		stack.free();
	}

	void exit() {
		debug (DEBUG_THREADS) {
			writefln("  PspThread.exit()");
		}
		alive = false;
		paused = true;
		deleteStack();
		//pauseAndYield();
	}
}

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

/** Additional options used when creating threads. */
struct SceKernelThreadOptParam {
	/** Size of the ::SceKernelThreadOptParam structure. */
	SceSize 	size;
	/** UID of the memory block (?) allocated for the thread's stack. */
	SceUID 		stackMpid;
}

/** Attribute for threads. */
enum PspThreadAttributes {
	/** Enable VFPU access for the thread. */
	PSP_THREAD_ATTR_VFPU = 0x00004000,
	/** Start the thread in user mode (done automatically 
	  if the thread creating it is in user mode). */
	PSP_THREAD_ATTR_USER = 0x80000000,
	/** Thread is part of the USB/WLAN API. */
	PSP_THREAD_ATTR_USBWLAN = 0xa0000000,
	/** Thread is part of the VSH API. */
	PSP_THREAD_ATTR_VSH = 0xc0000000,
	/** Allow using scratchpad memory for a thread, NOT USABLE ON V1.0 */
	PSP_THREAD_ATTR_SCRATCH_SRAM = 0x00008000,
	/** Disables filling the stack with 0xFF on creation */
	PSP_THREAD_ATTR_NO_FILLSTACK = 0x00100000,
	/** Clear the stack when the thread is deleted */
	PSP_THREAD_ATTR_CLEAR_STACK = 0x00200000,
}
