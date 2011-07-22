module pspemu.hle.kd.threadman.Types;

public import pspemu.hle.kd.Types;

enum PspThreadStatus {
	PSP_THREAD_RUNNING = 1,
	PSP_THREAD_READY   = 2,
	PSP_THREAD_WAITING = 4,
	PSP_THREAD_SUSPEND = 8,
	PSP_THREAD_STOPPED = 16, // Before startThread
	PSP_THREAD_KILLED  = 32, // Thread manager has killed the thread (stack overflow)
}

enum PspEventFlagAttributes {
	/** Allow the event flag to be waited upon by multiple threads */
	PSP_EVENT_WAITMULTIPLE = 0x200
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

/** Event flag wait types */
enum PspEventFlagWaitTypes
{
	/// Wait for all bits in the pattern to be set
	PSP_EVENT_WAITAND = 0,
	/// Wait for one or more bits in the pattern to be set
	PSP_EVENT_WAITOR  = 1,
	/// Clear all the wait pattern when it matches
	PSP_EVENT_WAITCLEARALL = 0x10,
	/// Clear the wait pattern when it matches
	PSP_EVENT_WAITCLEAR = 0x20,
};


/*
alias SceUInt function(SceUID uid, SceKernelSysClock *, SceKernelSysClock *, void *) SceKernelVTimerHandler;
alias SceUInt function(SceUID uid, SceInt64, SceInt64, void *) SceKernelVTimerHandlerWide;
*/

alias uint SceKernelVTimerHandler;
alias uint SceKernelVTimerHandlerWide;

