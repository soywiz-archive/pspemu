module pspemu.hle.kd.threadman.Types;

public import pspemu.hle.kd.Types;

import pspemu.utils.String;

enum PspThreadStatus : uint {
	PSP_THREAD_RUNNING = 1,
	PSP_THREAD_READY   = 2,
	PSP_THREAD_WAITING = 4,
	PSP_THREAD_SUSPEND = 8,
	PSP_THREAD_STOPPED = 16, // Before startThread
	PSP_THREAD_KILLED  = 32, // Thread manager has killed the thread (stack overflow)
}

enum PspEventFlagAttributes {
	PSP_EVENT_WAITMULTIPLE = 0x200, /// Allow the event flag to be waited upon by multiple threads
}

struct SceKernelThreadInfo {
	SceSize                size;               /// Size of the structure
	char    	           name[32];           /// Null terminated name of the thread
	SceUInt                attr;               /// Thread attributes
	PspThreadStatus        status;             /// Thread status
	SceKernelThreadEntry   entry;              /// Thread entry point
	void *                 stack;              /// Thread stack pointer
	int                    stackSize;          /// Thread stack size
	void *                 gpReg;              /// Pointer to the gp
	int     	           initPriority;       /// Initial Priority
	int     	           currentPriority;    /// Current Priority
	PspEventFlagWaitTypes  waitType;           /// Wait Type
	SceUID  	           waitId;             /// Wait id
	int     	           wakeupCount;        /// Wakeup count
	int     	           exitStatus;         /// Exit status of the thread
	SceKernelSysClock      runClocks;          /// Number of clock cycles run
	SceUInt                intrPreemptCount;   /// Interrupt preemption count
	SceUInt                threadPreemptCount; /// Thread preemption count
	SceUInt                releaseCount;       /// Release count
	
	mixin(DString("name", "dname"));
}

/** Additional options used when creating threads. */
struct SceKernelThreadOptParam {
	SceSize     size;      /// Size of the ::SceKernelThreadOptParam structure.
	SceUID      stackMpid; /// UID of the memory block (?) allocated for the thread's stack.
}

/** Attribute for threads. */
enum PspThreadAttributes : uint {
	PSP_THREAD_ATTR_NONE = 0,
	
	PSP_THREAD_ATTR_VFPU         = 0x00004000, /// Enable VFPU access for the thread.
	PSP_THREAD_ATTR_USER         = 0x80000000, /// Start the thread in user mode (done automatically if the thread creating it is in user mode).
	PSP_THREAD_ATTR_USBWLAN      = 0xa0000000, /// Thread is part of the USB/WLAN API.
	PSP_THREAD_ATTR_VSH          = 0xc0000000, /// Thread is part of the VSH API.
	PSP_THREAD_ATTR_SCRATCH_SRAM = 0x00008000, /// Allow using scratchpad memory for a thread, NOT USABLE ON V1.0
	PSP_THREAD_ATTR_NO_FILLSTACK = 0x00100000, /// Disables filling the stack with 0xFF on creation
	PSP_THREAD_ATTR_CLEAR_STACK  = 0x00200000, /// Clear the stack when the thread is deleted
}

struct SceKernelSemaInfo {
	SceSize   size;           /// Size of the ::SceKernelSemaInfo structure.
	char      name[32];       /// NUL-terminated name of the semaphore.
	SceUInt   attr;           /// Attributes.
	int       initCount;      /// The initial count the semaphore was created with.
	int       currentCount;   /// The current count.
	int       maxCount;       /// The maximum count.
	int       numWaitThreads; /// The number of threads waiting on the semaphore.
}

struct SceKernelSemaOptParam {
	SceSize size;             /// Size of the ::SceKernelSemaOptParam structure.
}

/** Event flag wait types */
enum PspEventFlagWaitTypes : uint {
	PSP_EVENT_WAITAND      = 0x00, /// Wait for all bits in the pattern to be set 
	PSP_EVENT_WAITOR       = 0x01, /// Wait for one or more bits in the pattern to be set
	PSP_EVENT_WAITCLEARALL = 0x10, /// Clear all the wait pattern when it matches
	PSP_EVENT_WAITCLEAR    = 0x20, /// Clear the wait pattern when it matches
};

struct SceKernelVTimerInfo {
	SceSize                 size;
	char                    name[32];
	int                     active;
	SceKernelSysClock       base;
	SceKernelSysClock       current;
	SceKernelSysClock       schedule;
	SceKernelVTimerHandler 	handler;
	void * 	                common;
}

/*
alias SceUInt function(SceUID uid, SceKernelSysClock *, SceKernelSysClock *, void *) SceKernelVTimerHandler;
alias SceUInt function(SceUID uid, SceInt64, SceInt64, void *) SceKernelVTimerHandlerWide;
*/

alias uint SceKernelVTimerHandler;
alias uint SceKernelVTimerHandlerWide;

