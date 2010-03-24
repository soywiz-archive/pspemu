module pspemu.hle.kd.threadman; // kd/threadman.prx (sceThreadManager)

//debug = DEBUG_THREADS;
//version = FAKE_SINGLE_THREAD;

import std.algorithm;

import pspemu.hle.Module;
import pspemu.core.cpu.Registers;

import pspemu.hle.kd.sysmem; // kd/sysmem.prx (sceSystemMemoryManager)

class PspThread {
	Registers registers;

	string name;

	// Id used for sorting threads.
	uint nextId = 0;
	
	uint priority = 32;
	uint stackSize = 0x1000;
	bool waiting = false;
	bool alive = true;
	
	//uint EntryPoint;
	//bool running;
	
	this() {
		registers = new Registers;
	}

	void switchTo(Cpu cpu) {
		cpu.registers.copyFrom(registers);
	}

	void switchFrom(Cpu cpu) {
		registers.copyFrom(cpu.registers);
	}

	void updateNextId() {
		nextId += (priority + 1);
	}

	string toString() {
		return std.string.format(
			"Thread(ID=0x%06X, PC=0x%08X, SP=0x%08X, nextId=0x%03X, priority=0x%02X, stackSize=0x%05X, waiting=%d, alive=%d)",
			cast(uint)cast(void *)this, registers.PC, registers.SP, nextId, priority, stackSize, waiting, alive
		);
	}
}

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
	}

	void initModule() {
		currentThread = new PspThread;
		currentThread.stackSize = 0x10000;
		threadRunningList ~= currentThread;
	}

	PspThread currentThread;
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

			if (nextThread != currentThread) {
				if (currentThread) currentThread.switchFrom(cpu);
				if (nextThread   ) nextThread.switchTo(cpu);
				currentThread = nextThread;
			}
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
		auto thread = cast(PspThread)cast(void *)thid;
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
		return cast(SceUID)cast(void *)currentThread;
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
		return 0;
	}

	/** 
	  * Exit a thread and delete itself.
	  *
	  * @param status - Exit status
	  */
	int sceKernelExitDeleteThread(int status) {
		// TODO
		return 0;
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
		return 0;
	}

	/** 
	 * Delete an event flag
	 *
	 * @param evid - The event id returned by sceKernelCreateEventFlag.
	 *
	 * @return < 0 On error
	 */
	int sceKernelDeleteEventFlag(int evid) {
		return 0;
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
			cpu.registers.pcSet(cpu.registers.PC - 4); // Forces loop execution.
			debug (DEBUG_THREADS) {
				writefln("WAITING! %s", currentThread);
			}
			if (currentThread) currentThread.waiting = true;

			// Switch to another thread immediately.
			thread0InterruptHandler();
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
			cpu.registers.pcSet(cpu.registers.PC - 4); // Forces loop execution.
			debug (DEBUG_THREADS) {
				writefln("WAITING! %s", currentThread);
			}
			if (currentThread) currentThread.waiting = true;

			// Switch to another thread immediately.
			thread0InterruptHandler();
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
			currentThread.waiting = true;
			currentThread.alive   = false;

			// Switch to another thread immediately.
			thread0InterruptHandler();
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
		auto pspThread = cast(PspThread)cast(void *)thid;
		if (pspThread is null) {
			//throw(new Excepti);
			return -1;
		}
		pspThread.alive = false;
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
		auto pspThread = new PspThread;
		pspThread.name = name.idup;
		pspThread.registers.copyFrom(cpu.registers);
		pspThread.registers.pcSet(entry);
		//
		uint allocStack(uint stackSize) {
			return moduleManager.get!(SysMemUserForUser).allocStack(stackSize);
		}
		writefln("stackCurrent: %08X", pspThread.registers.SP);
		pspThread.registers.SP = allocStack(stackSize);
		writefln("stackNew: %08X", pspThread.registers.SP);
		pspThread.priority = initPriority;
		pspThread.stackSize = stackSize;
		return cast(SceUID)cast(void *)pspThread;
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
			auto pspThread = cast(PspThread)cast(void *)thid;
			if (pspThread is null) throw(new Exception("sceKernelStartThread: Null"));
			cpu.registers.pcSet(pspThread.registers.PC);
			cpu.registers.A0 = 0;
			cpu.registers.A1 = 0;
		} else {
			auto pspThread = cast(PspThread)cast(void *)thid;
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
		return 0;
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
};

static this() {
	mixin(Module.registerModule("ThreadManForUser"));
	mixin(Module.registerModule("ThreadManForKernel"));
}