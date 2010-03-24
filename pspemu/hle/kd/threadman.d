module pspemu.hle.kd.threadman; // kd/threadman.prx (sceThreadManager)

//debug = DEBUG_THREADS;
//version = FAKE_SINGLE_THREAD;
//debug = DEBUG_SYSCALL;

import std.algorithm;

import pspemu.hle.Module;
import pspemu.core.cpu.Registers;

import pspemu.hle.kd.sysmem; // kd/sysmem.prx (sceSystemMemoryManager)

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
		pspThread.priority = priority;
		return 0;
	}

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
		unimplemented();
		return -1;
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
		unimplemented();
		return -1;
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
		pspSemaphore.exit();
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
	 * @param name - Specifies the name of the sema
	 * @param attr - Sema attribute flags (normally set to 0)
	 * @param initVal - Sema initial value 
	 * @param maxVal - Sema maximum value
	 * @param option - Sema options (normally set to 0)
	 * @return A semaphore id
	 */
	SceUID sceKernelCreateSema(string name, SceUInt attr, int initVal, int maxVal, SceKernelSemaOptParam* option) {
		return reinterpret!(SceUID)(new PspSemaphore(name, attr, initVal, maxVal, option));
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
		unimplemented();
		return -1;
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
		unimplemented();
		return -1;
	}

	void initModule() {
		initThreads();
	}

	void initThreads() {
	}

	PspThread   currentThread;
	PspThread[] threadRunningList;

	PspThread threadMinNextId() {
		uint minNextId = -1;
		PspThread minThread;
		foreach (thread; threadRunningList) {
			if (thread.nextId < minNextId) {
				minNextId = thread.nextId;
				minThread = thread;
			}
		}
		if (minThread is null) throw(new Exception("threadMinNextId: null: No threads?"));
		return minThread;
	}

	void threadsRemoveDead() {
		PspThread[] list;
		foreach (thread; threadRunningList) if (thread.alive) list ~= thread;
		threadRunningList = list;
	}

	void threadsNormalizeNextId() {
		if (!threadRunningList.length) return;
		uint min = threadMinNextId.nextId;
		foreach (thread; threadRunningList) thread.nextId -= min;
	}

	PspThread[] threadsWaiting() {
		PspThread[] list;
		foreach (thread; threadRunningList) if (thread.waiting || !thread.alive) list ~= thread;
		return list;
	}

	bool allThreadsWaiting() {
		return threadsWaiting.length == threadRunningList.length;
	}

	void dumpThreads() {
		writefln("Threads(%d) {", threadRunningList.length);
		foreach (thread; threadRunningList) {
			writefln("  %s", thread);
		}
		writefln("}");
	}

	void thread0InterruptHandler() {
		version (FAKE_SINGLE_THREAD) {
			debug (DEBUG_THREADS) {
				writefln("thread0InterruptHandler");
			}
		} else {
			PspThread nextThread;
			
			if (threadRunningList.length <= 1) {
				debug (DEBUG_THREADS) {
					dumpThreads();
				}
				return;
			}
			
			bool allThreadsWaiting = this.allThreadsWaiting;

			if (allThreadsWaiting) {
				dumpThreads();
				writefln("All threads waiting!");
				sleep(1);
				//throw(new Exception("All threads waiting!"));
			}

			int count = 0;
			do {
				nextThread = threadMinNextId;
				nextThread.updateNextId();
				
				// If we found a thread waiting, we will execute a HLE callback to try to resume it.
				if (nextThread.waiting) nextThread.executeHlePausedEnterCallback();

				if (count++ > 1024) {
					throw(new Exception("threadman stalled!"));
				}
				if (allThreadsWaiting) break;
			} while (nextThread.waiting || !nextThread.alive);
			
			if (nextThread.nextId > 0x2000) {
				threadsNormalizeNextId();
			}
			threadsRemoveDead();

			debug (DEBUG_THREADS) {
				dumpThreads();
				writefln("Current: %s", currentThread);
				writefln("Next:    %s", nextThread);
			}

			nextThread.switchFromTo();
		}
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

		*info = SceKernelThreadInfo(0);
		return -1;
	}

	/** 
	 * Get the current thread Id
	 *
	 * @return The thread id of the calling thread.
	 */
	SceUID sceKernelGetThreadId() {
		return reinterpret!(SceUID)(currentThread);
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
		unimplemented();
		return -1;
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
		version (FAKE_SINGLE_THREAD) {
			throw(new Exception("FAKE_SINGLE_THREAD.sceKernelSleepThread"));
			return 0;
		} else {
			// Sets the position of the thread to the syscall again.
			// Sets the thread as waiting.
			// Switch to another thread immediately.
			currentThread.stall({
				//writefln("sceKernelSleepThread.entering!");
			});
			return 0;
		}
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
		version (FAKE_SINGLE_THREAD) {
			throw(new Exception("FAKE_SINGLE_THREAD.sceKernelSleepThreadCB"));
			return 0;
		} else {
			// Ditto.
			currentThread.stall({
				//writefln("sceKernelSleepThreadCB.entering!");
			});
			return 0;
		}
	}
	
	/**
	 * Exit a thread
	 *
	 * @param status - Exit status.
	 */
	void sceKernelExitThread(int status) {
		version (FAKE_SINGLE_THREAD) {
			throw(new Exception("FAKE_SINGLE_THREAD.sceKernelExitThread"));
		} else {
			currentThread.exit();
		}
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
	 * @param name - An arbitrary thread name.
	 * @param entry - The thread function to run when started.
	 * @param initPriority - The initial priority of the thread. Less if higher priority.
	 * @param stackSize - The size of the initial stack.
	 * @param attr - The thread attributes, zero or more of ::PspThreadAttributes.
	 * @param option - Additional options specified by ::SceKernelThreadOptParam.

	 * @return UID of the created thread, or an error code.
	 */
	SceUID sceKernelCreateThread(string name, SceKernelThreadEntry entry, int initPriority, int stackSize, SceUInt attr, SceKernelThreadOptParam *option) {
		auto pspThread = new PspThread(this);
		pspThread.name = name.idup;
		pspThread.registers.copyFrom(cpu.registers);
		pspThread.registers.pcSet(entry);
		debug (DEBUG_THREADS) writefln("stackCurrent: %08X", pspThread.registers.SP);
		pspThread.stack = moduleManager.get!(SysMemUserForUser).allocStack(stackSize);
		pspThread.registers.SP = pspThread.stack.block.high;
		pspThread.registers.RA = 0x08000000;
		debug (DEBUG_THREADS) writefln("stackNew: %08X", pspThread.registers.SP);
		pspThread.priority = initPriority;
		pspThread.stackSize = stackSize;
		return reinterpret!(SceUID)(pspThread);
	}

	/**
	 * Start a created thread
	 *
	 * @param thid - Thread id from sceKernelCreateThread
	 * @param arglen - Length of the data pointed to by argp, in bytes
	 * @param argp - Pointer to the arguments.
	 */
	//int sceKernelStartThread(SceUID thid, SceSize arglen, void* argp) {
	void sceKernelStartThread(SceUID thid, SceSize arglen, void* argp) {
		version (FAKE_SINGLE_THREAD) {
			auto pspThread = reinterpret!(PspThread)(thid);
			if (pspThread is null) throw(new Exception("sceKernelStartThread: Null"));
			cpu.registers.pcSet(pspThread.registers.PC);
			cpu.registers.A0 = 0;
			cpu.registers.A1 = 0;
		} else {
			auto pspThread = reinterpret!(PspThread)(thid);
			if (pspThread is null) {
				//throw(new Exception("sceKernelStartThread: Null"));
				writefln("sceKernelStartThread: Null");
				cpu.registers.V0 = -1;
				return;
			}
			pspThread.registers.A0 = arglen;
			pspThread.registers.A1 = cpu.memory.getPointerReverseOrNull(argp);
			pspThread.nextId = threadRunningList.length ? threadMinNextId.nextId : 0;
			threadRunningList ~= pspThread;
			cpu.registers.V0 = 0;
			return;
		}
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

alias uint SceKernelThreadEntry;
alias uint SceKernelCallbackFunction;

//alias int function(SceSize args, void *argp) SceKernelThreadEntry;
//alias int function(int arg1, int arg2, void *arg) SceKernelCallbackFunction;

/** Structure to hold the event flag information */
struct SceKernelEventFlagInfo {
	SceSize 	size;
	char 		name[32];
	SceUInt 	attr;
	SceUInt 	initPattern;
	SceUInt 	currentPattern;
	int 		numWaitThreads;
}

/** 64-bit system clock type. */
struct SceKernelSysClock {
	SceUInt32   low;
	SceUInt32   hi;
}

struct SceKernelThreadInfo {
	/** Size of the structure */
	SceSize     size;
	/** Nul terminated name of the thread */
	char    	name[32];
	/** Thread attributes */
	SceUInt     attr;
	/** Thread status */
	int     	status;
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

struct SceKernelEventFlagOptParam {
	SceSize 	size;
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

struct SceKernelMppInfo {
	SceSize 	size;
	char 	name[32];
	SceUInt 	attr;
	int 	bufSize;
	int 	freeSize;
	int 	numSendWaitThreads;
	int 	numReceiveWaitThreads;
}

struct SceKernelSemaInfo {
	/** Size of the ::SceKernelSemaInfo structure. */
	SceSize 	size;
	/** NUL-terminated name of the semaphore. */
	char 		name[32];
	/** Attributes. */
	SceUInt 	attr;
	/** The initial count the semaphore was created with. */
	int 		initCount;
	/** The current count. */
	int 		currentCount;
	/** The maximum count. */
	int 		maxCount;
	/** The number of threads waiting on the semaphore. */
	int 		numWaitThreads;
}

struct SceKernelSemaOptParam {
	/** Size of the ::SceKernelSemaOptParam structure. */
	SceSize 	size;
}

class PspThread {
	ThreadManForUser threadManager;
	Registers registers;

	string name;
	MemorySegment stack;

	// Id used for sorting threads.
	uint nextId = 0;
	
	uint priority  = 32;
	uint stackSize = 0x1000;
	bool waiting   = false;
	bool alive     = true;
	
	//uint EntryPoint;
	//bool running;
	
	void delegate() pausedCallback;

	void executeHlePausedEnterCallback() {
		debug (DEBUG_THREADS) {
			writefln("  PspThread.executeHlePausedEnterCallback = 0x%08X", reinterpret!(uint)(pausedCallback));
		}
		if (pausedCallback !is null) {
			pausedCallback();
		}
	}
	
	this(ThreadManForUser threadManager) {
		this.threadManager = threadManager;
		this.registers     = new Registers;
	}

	void switchTo() {
		threadManager.cpu.registers.copyFrom(registers);
		threadManager.currentThread = this;
	}

	void switchFrom() {
		registers.copyFrom(threadManager.cpu.registers);
	}
	
	void switchFromTo() {
		if (threadManager.currentThread != this) {
			if (threadManager.currentThread) threadManager.currentThread.switchFrom();
			this.switchTo();
		}
	}

	void updateNextId() {
		nextId += (priority + 1);
	}

	string toString() {
		return std.string.format(
			"Thread(ID=0x%06X, PC=0x%08X, SP=0x%08X, nextId=0x%03X, priority=0x%02X, stackSize=0x%05X, waiting=%d, alive=%d)",
			reinterpret!(uint)(this), registers.PC, registers.SP, nextId, priority, stackSize, waiting, alive
		);
	}

	void switchToOtherThread() {
		debug (DEBUG_THREADS) {
			writefln("  PspThread.switchToOtherThread()");
		}
		// Change execution to another thread.
		threadManager.thread0InterruptHandler();
	}

	void pause(void delegate() pausedCallback = null) {
		debug (DEBUG_THREADS) {
			writefln("  PspThread.pause(); callback = %s", reinterpret!(uint)(pausedCallback));
		}
		this.pausedCallback = pausedCallback;
		waiting = true;
		switchToOtherThread();
	}

	void stall(void delegate() pausedCallback = null) {
		debug (DEBUG_THREADS) {
			writefln("  PspThread.stall()");
		}
		threadManager.cpu.registers.pcSet(threadManager.cpu.registers.PC - 4);
		pause(pausedCallback);
	}

	void resume() {
		debug (DEBUG_THREADS) {
			writefln("  PspThread.resume()");
		}
		waiting = false;
	}

	void exit() {
		debug (DEBUG_THREADS) {
			writefln("  PspThread.exit()");
		}
		alive = false;
		stack.free();
		stall();
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
	string name;
	SceUInt attr;
	int initVal;
	int value;
	int maxVal;
	SceKernelSemaOptParam* option;
	bool alive = true;

	this(string name, SceUInt attr, int initVal, int maxVal, SceKernelSemaOptParam* option) {
		this.name    = name;
		this.attr    = attr;
		this.initVal = initVal;
		this.maxVal  = maxVal;
		this.option  = option;
	}

	void exit() {
		alive = false;
	}
}

// @TODO
class ThreadManager {
}

static this() {
	mixin(Module.registerModule("ThreadManForUser"));
	mixin(Module.registerModule("ThreadManForKernel"));
}