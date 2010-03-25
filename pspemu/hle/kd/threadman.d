module pspemu.hle.kd.threadman; // kd/threadman.prx (sceThreadManager)

//debug = DEBUG_THREADS;
//debug = DEBUG_SYSCALL;

import std.algorithm;
import core.thread;

import pspemu.hle.Module;
import pspemu.core.cpu.Registers;

import pspemu.hle.kd.sysmem; // kd/sysmem.prx (sceSystemMemoryManager)

/**
 * Library imports for the kernel threading library.
 */
class ThreadManForUser : Module {
	void initNids() {
		mixin(registerd!(0xE81CAF8F, sceKernelCreateCallback));
		mixin(registerd!(0x9ACE131E, sceKernelSleepThread));
		mixin(registerd!(0x82826F70, sceKernelSleepThreadCB));
		mixin(registerd!(0x446D8DE6, sceKernelCreateThread));
		mixin(registerd!(0x9FA03CD3, sceKernelDeleteThread));
		mixin(registerd!(0xF475845D, sceKernelStartThread));
		mixin(registerd!(0xAA73C935, sceKernelExitThread));
		mixin(registerd!(0x55C20A00, sceKernelCreateEventFlag));
		mixin(registerd!(0xEF9E4C70, sceKernelDeleteEventFlag));
		mixin(registerd!(0x809CE29B, sceKernelExitDeleteThread));
		mixin(registerd!(0x1FB15A32, sceKernelSetEventFlag));
		mixin(registerd!(0x293B45B8, sceKernelGetThreadId));
		mixin(registerd!(0x17C1684E, sceKernelReferThreadStatus));
		mixin(registerd!(0x7C0DC2A0, sceKernelCreateMsgPipe));
		mixin(registerd!(0xF0B7DA1C, sceKernelDeleteMsgPipe));
		mixin(registerd!(0x876DBFAD, sceKernelSendMsgPipe));
		mixin(registerd!(0x884C9F90, sceKernelTrySendMsgPipe));
		mixin(registerd!(0x74829B76, sceKernelReceiveMsgPipe));
		mixin(registerd!(0xDF52098F, sceKernelTryReceiveMsgPipe));
		mixin(registerd!(0x33BE4024, sceKernelReferMsgPipeStatus));
		mixin(registerd!(0x278C0DF5, sceKernelWaitThreadEnd));
		mixin(registerd!(0xCEADEB47, sceKernelDelayThread));
		mixin(registerd!(0x68DA9E36, sceKernelDelayThreadCB));
		mixin(registerd!(0xD6DA4BA1, sceKernelCreateSema));
		mixin(registerd!(0x28B6489C, sceKernelDeleteSema));
		mixin(registerd!(0x3F53E640, sceKernelSignalSema));
		mixin(registerd!(0x4E3A1105, sceKernelWaitSema));
		mixin(registerd!(0x58B1F937, sceKernelPollSema));
		mixin(registerd!(0xBC6FEBC5, sceKernelReferSemaStatus));
		mixin(registerd!(0x383F7BCC, sceKernelTerminateDeleteThread));
		mixin(registerd!(0x71BC9871, sceKernelChangeThreadPriority));
		mixin(registerd!(0xEA748E31, sceKernelChangeCurrentThreadAttr));
	}

	/**
	 * Thread Manager
	 */
	PspThreadManager    threadManager;
	PspSemaphoreManager semaphoreManager;

	void initModule() {
		threadManager    = new PspThreadManager(this);
		semaphoreManager = new PspSemaphoreManager(this);
	}

	void processCallbacks() {
		// @TODO
	}

	/**
	 * Semaphore related stuff.
	 */
	template TemplateSemaphore() {
		/**
		 * Poll a sempahore.
		 *
		 * @param semaid - UID of the semaphore to poll.
		 * @param signal - The value to test for.
		 *
		 * @return < 0 on error.
		 */
		int sceKernelPollSema(SceUID semaid, int signal) {
			unimplemented();
			return -1;
		}

		/**
		 * Retrieve information about a semaphore.
		 *
		 * @param semaid - UID of the semaphore to retrieve info for.
		 * @param info - Pointer to a ::SceKernelSemaInfo struct to receive the info.
		 *
		 * @return < 0 on error.
		 */
		int sceKernelReferSemaStatus(SceUID semaid, SceKernelSemaInfo* info) {
			unimplemented();
			return -1;
		}

		/**
		 * Lock a semaphore
		 *
		 * @par Example:
		 * @code
		 * sceKernelWaitSema(semaid, 1, 0);
		 * @endcode
		 *
		 * @param semaid - The sema id returned from sceKernelCreateSema
		 * @param signal - The value to wait for (i.e. if 1 then wait till reaches a signal state of 1)
		 * @param timeout - Timeout in microseconds (assumed).
		 *
		 * @return < 0 on error.
		 */
		int sceKernelWaitSema(SceUID semaid, int signal, SceUInt* timeout) {
			auto semaphore = reinterpret!(PspSemaphore)(semaid);
			
			// @TODO implement timeout!

			threadManager.currentThread.pause("sceKernelWaitSema", (PspThread pausedThread) {
				if (semaphore.info.currentCount >= signal) {
					semaphore.info.currentCount -= signal;
					pausedThread.resume();
				}
				//writefln("%d >= %d", semaphore.signal, signal);
				//writefln("sceKernelSleepThread.entering!");
			});

			return 0;
		}

		/**
		 * Send a signal to a semaphore
		 *
		 * @par Example:
		 * @code
		 * // Signal the sema
		 * sceKernelSignalSema(semaid, 1);
		 * @endcode
		 *
		 * @param semaid - The sema id returned from sceKernelCreateSema
		 * @param signal - The amount to signal the sema (i.e. if 2 then increment the sema by 2)
		 *
		 * @return < 0 On error.
		 */
		int sceKernelSignalSema(SceUID semaid, int signal) {
			auto semaphore = reinterpret!(PspSemaphore)(semaid);
			if (signal    <= 0   ) return PspKernelErrorCodes.SCE_KERNEL_ERROR_ILLEGAL_COUNT;
			if (semaphore is null) return PspKernelErrorCodes.SCE_KERNEL_ERROR_UNKNOWN_UID;

			with (semaphore.info) {
				currentCount += signal;
				if (currentCount > maxCount) {
					currentCount = maxCount;
				}
			}
			return 0;
		}

		/**
		 * Destroy a semaphore
		 *
		 * @param semaid - The semaid returned from a previous create call.
		 * @return Returns the value 0 if its succesful otherwise -1
		 */
		int sceKernelDeleteSema(SceUID semaid) {
			auto pspSemaphore = reinterpret!(PspSemaphore)(semaid);
			if (pspSemaphore is null) return -1;
			semaphoreManager.removeSemaphore(pspSemaphore);
			return 0;
		}

		/**
		 * Creates a new semaphore
		 *
		 * @par Example:
		 * @code
		 * int semaid;
		 * semaid = sceKernelCreateSema("MyMutex", 0, 1, 1, 0);
		 * @endcode
		 *
		 * @param name      - Specifies the name of the sema
		 * @param attr      - Sema attribute flags (normally set to 0)
		 * @param initCount - Sema initial value 
		 * @param maxCount  - Sema maximum value
		 * @param option    - Sema options (normally set to 0)
		 * @return A semaphore id
		 */
		SceUID sceKernelCreateSema(string name, SceUInt attr, int initCount, int maxCount, SceKernelSemaOptParam* option) {
			auto semaphore = semaphoreManager.createSemaphore();

			with (semaphore) {
				info.name[0..name.length] = name[0..$];
				info.attr           = attr;
				info.initCount      = initCount;
				info.currentCount   = initCount; // Actually value
				info.maxCount       = maxCount;
				info.numWaitThreads = 0;
			}

			return reinterpret!(SceUID)(semaphore);
		}
	}
	
	mixin TemplateSemaphore;

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
		auto pspThread = cast(PspThread)cast(void *)thid;
		if (pspThread is null) return -1;
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
		unimplemented();
		return -1;
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

		threadManager.currentThread.pause("sceKernelDelayThread", (PspThread pausedThread) {
			if (!paused) pausedThread.resume();
		});

		return 0;
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

		threadManager.currentThread.pause("sceKernelDelayThreadCB", (PspThread pausedThread) {
			processCallbacks();
			if (!paused) pausedThread.resume();
		});

		return 0;
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
		auto thread = reinterpret!(PspThread)(thid);
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
		return reinterpret!(SceUID)(threadManager.currentThread);
	}

	/** 
	  * Set an event flag bit pattern.
	  *
	  * @param evid - The event id returned by sceKernelCreateEventFlag.
	  * @param bits - The bit pattern to set.
	  *
	  * @return < 0 On error
	  */
	int sceKernelSetEventFlag(SceUID evid, u32 bits) {
		unimplemented();
		return -1;
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
	  * Create an event flag.
	  *
	  * @param name - The name of the event flag.
	  * @param attr - Attributes from ::PspEventFlagAttributes
	  * @param bits - Initial bit pattern.
	  * @param opt  - Options, set to NULL
	  * @return < 0 on error. >= 0 event flag id.
	  *
	  * @par Example:
	  * @code
	  * int evid;
	  * evid = sceKernelCreateEventFlag("wait_event", 0, 0, 0);
	  * @endcode
	  */
	SceUID sceKernelCreateEventFlag(string name, int attr, int bits, SceKernelEventFlagOptParam *opt) {
		//unimplemented();
		return -1;
	}

	/** 
	 * Delete an event flag
	 *
	 * @param evid - The event id returned by sceKernelCreateEventFlag.
	 *
	 * @return < 0 On error
	 */
	int sceKernelDeleteEventFlag(int evid) {
		//unimplemented();
		return -1;
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
		threadManager.currentThread.pause("sceKernelSleepThread", (PspThread pausedThread) {
			//writefln("sceKernelSleepThread");
		});
		return 0;
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
		threadManager.currentThread.pause("sceKernelSleepThreadCB", (PspThread pausedThread) {
			processCallbacks();
		});
		return 0;
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
	 * Delate a thread
	 *
	 * @param thid - UID of the thread to be deleted.
	 *
	 * @return < 0 on error.
	 */
	int sceKernelDeleteThread(SceUID thid) {
		auto pspThread = reinterpret!(PspThread)(thid);
		if (pspThread is null) {
			throw(new Exception("Invalid sceKernelDeleteThread"));
			return -1;
		}
		pspThread.exit();
		return 0;
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
		auto pspThread = threadManager.createThread();
		// Set stack.
		pspThread.stack = moduleManager.get!(SysMemUserForUser).allocStack(stackSize, name);

		// Copy name string.
		pspThread.name = name;
		pspThread.info.name[0..name.length] = name[0..name.length];

		// Set stack info.
		pspThread.info.stack     = cast(void*)pspThread.stack.block.low;
		pspThread.info.stackSize = stackSize;

		// Set priority info.
		pspThread.info.initPriority    = initPriority;
		pspThread.info.currentPriority = initPriority;

		// Set entry info.
		pspThread.info.entry = entry;

		// Set extra info.
		pspThread.info.size  = pspThread.info.sizeof;
		pspThread.info.attr  = attr;
		pspThread.info.gpReg = cast(void *)cpu.registers.GP;

		// Set thread registers.
		with (pspThread.registers) {
			copyFrom(cpu.registers);
			pcSet(entry);
			SP = pspThread.stack.block.high;
			RA = 0x08000000; // sleep
		}

		return reinterpret!(SceUID)(pspThread);
	}

	/**
	 * Start a created thread
	 *
	 * @param thid   - Thread id from sceKernelCreateThread
	 * @param arglen - Length of the data pointed to by argp, in bytes
	 * @param argp   - Pointer to the arguments.
	 */
	int sceKernelStartThread(SceUID thid, SceSize arglen, void* argp) {
		auto pspThread = reinterpret!(PspThread)(thid);
		if (pspThread is null) {
			writefln("sceKernelStartThread: Null");
			return -1;
		}
		pspThread.registers.A0 = arglen;
		pspThread.registers.A1 = cpu.memory.getPointerReverseOrNull(argp);
		threadManager.addToRunningList(pspThread);
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
	int sceKernelCreateCallback(string name, SceKernelCallbackFunction func, void *arg) {
		return reinterpret!(int)(new Callback(name, func, arg));
	}
	/**
	 * Create a message pipe
	 *
	 * @param name - Name of the pipe
	 * @param part - ID of the memory partition
	 * @param attr - Set to 0?
	 * @param unk1 - Unknown
	 * @param opt  - Message pipe options (set to NULL)
	 *
	 * @return The UID of the created pipe, < 0 on error
	 */
	SceUID sceKernelCreateMsgPipe(string name, int part, int attr, void* unk1, void* opt) {
		unimplemented();
		return -1;
	}

	/**
	 * Delete a message pipe
	 *
	 * @param uid - The UID of the pipe
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelDeleteMsgPipe(SceUID uid) {
		unimplemented();
		return -1;
	}

	/**
	 * Send a message to a pipe
	 *
	 * @param uid - The UID of the pipe
	 * @param message - Pointer to the message
	 * @param size - Size of the message
	 * @param unk1 - Unknown
	 * @param unk2 - Unknown
	 * @param timeout - Timeout for send
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelSendMsgPipe(SceUID uid, void* message, uint size, int unk1, void* unk2, uint* timeout) {
		unimplemented();
		return -1;
	}

	/**
	 * Try to send a message to a pipe
	 *
	 * @param uid - The UID of the pipe
	 * @param message - Pointer to the message
	 * @param size - Size of the message
	 * @param unk1 - Unknown
	 * @param unk2 - Unknown
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelTrySendMsgPipe(SceUID uid, void* message, uint size, int unk1, void* unk2) {
		unimplemented();
		return -1;
	}

	/**
	 * Receive a message from a pipe
	 *
	 * @param uid - The UID of the pipe
	 * @param message - Pointer to the message
	 * @param size - Size of the message
	 * @param unk1 - Unknown
	 * @param unk2 - Unknown
	 * @param timeout - Timeout for receive
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelReceiveMsgPipe(SceUID uid, void* message, uint size, int unk1, void* unk2, uint* timeout) {
		unimplemented();
		return -1;
	}

	/**
	 * Receive a message from a pipe
	 *
	 * @param uid - The UID of the pipe
	 * @param message - Pointer to the message
	 * @param size - Size of the message
	 * @param unk1 - Unknown
	 * @param unk2 - Unknown
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelTryReceiveMsgPipe(SceUID uid, void* message, uint size, int unk1, void* unk2) {
		unimplemented();
		return -1;
	}

	/**
	 * Get the status of a Message Pipe
	 *
	 * @param uid - The uid of the Message Pipe
	 * @param info - Pointer to a ::SceKernelMppInfo structure
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelReferMsgPipeStatus(SceUID uid, SceKernelMppInfo* info) {
		unimplemented();
		return -1;
	}
}

class ThreadManForKernel : ThreadManForUser {
}

class PspThread {
	PspThreadManager threadManager;
	Registers registers;
	Registers resumeRegisters;

	string name;
	MemorySegment stack;

	SceKernelThreadInfo info;

	bool paused   = false;
	bool alive     = true;
	
	//uint EntryPoint;
	//bool running;
	
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
	
	void updateNextId() {
		info.threadPreemptCount += (info.currentPriority + 1);
	}

	string toString() {
		return std.string.format(
			"Thread(ID=0x%06X, PC=0x%08X, SP=0x%08X, threadPreemptCount=0x%03X, currentPriority=0x%02X, "
			"stackSize=0x%05X, paused=%d, alive=%d, callback='%s':%08X, Name='%s') resume-PC:%08X, resume-RA:%08X",
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
		} else {
			if (threadManager.currentThread != this) {
				if (threadManager.currentThread) threadManager.currentThread.switchFrom();
				this.switchTo();
			}
		}
	}

	void pause(string pausedName = null, PausedCallback pausedCallback = null) {
		debug (DEBUG_THREADS) { writefln("  PspThread.pause(); callback = %s", reinterpret!(uint)(pausedCallback)); }
		
		assert(!paused);

		// Stalls at syscall.
		resumeRegisters.copyFrom(threadManager.cpu.registers);
		threadManager.cpu.registers.pcSet(0x08000010);
		threadManager.threadManForUser.setReturnValue = false;

		this.pausedName     = pausedName;
		this.pausedCallback = pausedCallback;
		this.paused = true;
		//this.switchToOtherThread();
	}

	void resume() {
		debug (DEBUG_THREADS) { writefln("  PspThread.resume()"); }

		assert(paused);
		
		paused = false;
		switchToThisThread();
		
		this.registers.copyFrom(resumeRegisters);
		threadManager.cpu.registers.copyFrom(resumeRegisters);
	}

	void exit() {
		debug (DEBUG_THREADS) {
			writefln("  PspThread.exit()");
		}
		alive = false;
		threadManager.createdThreads.remove(this);
		stack.free();
		pause();
	}
}

class Callback {
	string name;
	SceKernelCallbackFunction func;
	void* arg;

	this(string name, SceKernelCallbackFunction func, void* arg) {
		this.name = name;
		this.func = func;
		this.arg  = arg;
	}
}

class PspSemaphore {
	PspSemaphoreManager semaphoreManager;
	SceKernelSemaInfo info;

	this(PspSemaphoreManager semaphoreManager) {
		this.semaphoreManager = semaphoreManager;
	}
}

template ThreadSubsystemManager() {
	ThreadManForUser threadManForUser;
	Cpu cpu() { return threadManForUser.cpu; }

	public this(ThreadManForUser threadManForUser) {
		this.threadManForUser = threadManForUser;
	}
}

class PspThreadManager {
	mixin ThreadSubsystemManager;

	PspThread currentThread;
	PspThread[] threadRunningList;
	bool[PspThread] createdThreads;

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
		writefln("Threads(%d) {", threadRunningList.length);
		foreach (thread; threadRunningList) {
			writefln("  %s", thread);
		}
		writefln("}");
	}

	void switchNextThread() {
		threadsNormalizePreemptCount();
		threadsRemoveDead();

		if (threadRunningList.length == 0) {
			throw(new Exception("No threads left!"));
		}
		
		auto nextThread = getNextThread;
		nextThread.updateNextId();

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

	PspThread createThread() {
		auto pspThread = new PspThread(this);
		createdThreads[pspThread] = true;
		return pspThread;
	}

	void removeThread(PspThread pspThread) {
		createdThreads.remove(pspThread);
		pspThread.exit();
	}
}

class PspSemaphoreManager {
	mixin ThreadSubsystemManager;

	bool[PspSemaphore] createdSemaphores;

	PspSemaphore createSemaphore() {
		auto pspSemaphore = new PspSemaphore(this);
		createdSemaphores[pspSemaphore] = true;
		return pspSemaphore;
	}

	void removeSemaphore(PspSemaphore pspSemaphore) {
		createdSemaphores.remove(pspSemaphore);
	}
}

static this() {
	mixin(Module.registerModule("ThreadManForUser"));
	mixin(Module.registerModule("ThreadManForKernel"));
}