module pspemu.hle.ThreadManager;

public import std.algorithm;
public import core.thread;

public import pspemu.hle.Module;
public import pspemu.core.cpu.Registers;

public import pspemu.hle.kd.sysmem; // kd/sysmem.prx (SysMemUserForUser)

//debug = DEBUG_CHECK_HOST_THREAD;

//debug = DEBUG_THREADS;
debug = DEBUG_THREADS_EX;

class PspThreadManager {
	mixin ThreadSubsystemManager;

	PspThread currentThread;
	PspThread[] threadRunningList;
	PspThread[SceUInt] createdThreads;
	
	PspThread getNextThread(bool doThrow = false) {
		checkHostThread();
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
		checkHostThread();
		auto thread = getNextThread();
		return thread ? thread.info.threadPreemptCount : 0;
	}

	void threadsRemoveDead() {
		checkHostThread();
		PspThread[] list;
		foreach (thread; threadRunningList) if (thread.alive) list ~= thread;
		threadRunningList = list;
	}

	void threadsNormalizePreemptCount() {
		checkHostThread();
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
		checkHostThread();
		//debug (DEBUG_THREADS_EX) writefln("PspThreadManager.switchNextThread");
		threadsNormalizePreemptCount();
		threadsRemoveDead();
		
		if (allThreadsPaused) {
			//sleep(0);
			//sleep(1);
		}

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
		checkHostThread();
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
		checkHostThread();
		debug (DEBUG_THREADS) { writefln("  PspThread.executeHlePausedEnterCallback = 0x%08X", reinterpret!(uint)(pausedCallback)); }
		if (pausedCallback !is null) {
			pausedCallback(this);
		}
	}
	
	protected void switchTo() {
		checkHostThread();
		threadManager.cpu.registers.copyFrom(registers);
		threadManager.cpu.registers.CLOCKS = 0;
		threadManager.currentThread = this;
	}

	protected void switchFrom() {
		checkHostThread();
		registers.copyFrom(threadManager.cpu.registers);
	}
	
	void updatePreemptCount() {
		checkHostThread();
		info.threadPreemptCount += (info.currentPriority + 1);
	}

	string toString() {
		return std.string.format(
			"Thread(ID=0x%06X, PC=0x%08X, SP=0x%08X, threadPreemptCount=0x%03X, currentPriority=0x%02X, stackSize=0x%05X\n"
			"    paused=%d, alive=%d, callback='%s':%08X, Name='%s')\n"
			"    resume-PC:%08X, resume-RA:%08X, resume-V0:%08X\n"
			"    registers-V0:%08X, cpu.registers.V0:%08X, cpu.registers.CLOCKS:%08X",
			reinterpret!(uint)(this), registers.PC, registers.SP, info.threadPreemptCount, info.currentPriority,
			info.stackSize, paused, alive, pausedName, reinterpret!(uint)(pausedCallback), name,
			resumeRegisters.PC, resumeRegisters.RA, resumeRegisters.V0,
			registers.V0, threadManager.cpu.registers.V0, threadManager.cpu.registers.CLOCKS
		);
	}

	void switchToOtherThread() {
		checkHostThread();
		debug (DEBUG_THREADS) { writefln("  PspThread.switchToOtherThread()"); }
		// Change execution to another thread.
		threadManager.switchNextThread();
	}

	void switchToThisThread() {
		//writefln("PspThread.switchToThisThread");
		checkHostThread();

		//threadManager.cpu.registers.PAUSED = paused;
		//registers.PAUSED = paused;
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
		checkHostThread();
		debug (DEBUG_THREADS) { writefln("  PspThread.pauseAndYield(); callback = %s", reinterpret!(uint)(pausedCallback)); }
		
		if (paused) throw(new Exception("PspThread::pauseAndYield(). Already paused!"));

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
		checkHostThread();
		debug (DEBUG_THREADS) { writefln("  PspThread.resume()"); }

		if (!paused) throw(new Exception("PspThread::resume(). Not paused!"));
		
		paused = false;
		switchToThisThread();
		
		this.registers.copyFrom(resumeRegisters);
		threadManager.cpu.registers.copyFrom(resumeRegisters);
	}

	void resumeAndReturn(uint value) {
		checkHostThread();
		resume();
		threadManager.cpu.registers.V0 = value;
	}

	void createStack(SysMemUserForUser sysMemUserForUser) {
		checkHostThread();
		this.stack = sysMemUserForUser.allocStack(this.info.stackSize, this.name, !(this.info.attr & PspThreadAttributes.PSP_THREAD_ATTR_NO_FILLSTACK));
		if (!(this.info.attr & PspThreadAttributes.PSP_THREAD_ATTR_NO_FILLSTACK)) {
			// TODO: Fills to FF
			// Remove that code from allocStack.
		}
		this.info.stack = cast(void*)this.stack.block.low;
	}

	void deleteStack() {
		checkHostThread();
		if (this.info.attr & PspThreadAttributes.PSP_THREAD_ATTR_CLEAR_STACK) {
			// TODO: Sets stack to 0
		}
		
		stack.free();
	}

	void exit() {
		checkHostThread();
		debug (DEBUG_THREADS) {
			writefln("  PspThread.exit()");
		}
		alive = false;
		paused = true;
		deleteStack();
		//pauseAndYield(); // Check.
		if (threadManager.currentThread is this) {
			switchToOtherThread();
		}
	}

	void checkHostThread() {
		debug (DEBUG_CHECK_HOST_THREAD) threadManager.checkHostThread();
	}
}

/**
 * Psp Semaphore.
 */
class PspSemaphore {
	/**
	 * Semaphore Manager associate to this semaphore.
	 */
	PspSemaphoreManager semaphoreManager;

	/**
	 * Information of the semaphore.
	 */
	SceKernelSemaInfo info;

	/**
	 * Name of the semaphore.
	 */
	string name;

	/**
	 * Constructor.
	 */
	this(PspSemaphoreManager semaphoreManager) {
		this.semaphoreManager = semaphoreManager;
	}

	string toString() {
		return std.string.format(
			"Semaphore('%s', attr=0x%08X, initCount=%d, currentCount=%d, maxCount=%d, numWaitThreads=%d)",
			name, info.attr, info.initCount, info.currentCount, info.maxCount, info.numWaitThreads
		);
	}

	void checkHostThread() {
		semaphoreManager.checkHostThread();
	}
}

class PspSemaphoreManager {
	mixin ThreadSubsystemManager;

	bool[PspSemaphore] createdSemaphores;

	PspSemaphore createSemaphore() {
		checkHostThread();
		auto pspSemaphore = new PspSemaphore(this);
		createdSemaphores[pspSemaphore] = true;
		return pspSemaphore;
	}

	void removeSemaphore(PspSemaphore pspSemaphore) {
		checkHostThread();
		createdSemaphores.remove(pspSemaphore);
	}

	void dumpSemaphores() {
		writefln("Semaphores(%d) {", createdSemaphores.length);
		foreach (semaphore; createdSemaphores.keys) {
			writefln("  %s", semaphore);
		}
		writefln("}");
	}
}

__gshared Thread hostThread;
__gshared int hostThreadChangeCount = 0;

template ThreadSubsystemManager() {
	Module threadManForUser;
	Cpu cpu() { return threadManForUser.cpu; }

	public this(Module threadManForUser) {
		this.threadManForUser = threadManForUser;
		debug (DEBUG_CHECK_HOST_THREAD) hostThread = core.thread.Thread.getThis;
		checkHostThread();
	}

	void checkHostThread() {
		debug (DEBUG_CHECK_HOST_THREAD) {
			if (hostThread != core.thread.Thread.getThis) {
				//throw(new Exception("PspThread functions called outside of the Cpu thread!"));
				hostThreadChangeCount++;
				writefln("PspThread functions called outside of the Cpu thread! (%d)", hostThreadChangeCount);
				hostThread = core.thread.Thread.getThis;
				if (hostThreadChangeCount >= 2) {
					throw(new Exception("PspThread functions called outside of the Cpu thread!"));
				}
			}
		}
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
