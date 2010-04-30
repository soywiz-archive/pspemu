module pspemu.hle.kd.threadman; // kd/threadman.prx (sceThreadManager)

//debug = DEBUG_THREADS;
//debug = DEBUG_SYSCALL;

public import pspemu.hle.kd.threadman_common;
public import pspemu.hle.ThreadManager;

public import pspemu.hle.kd.threadman_threads;
public import pspemu.hle.kd.threadman_semaphores;

/**
 * Library imports for the kernel threading library.
 */
class ThreadManForUser : Module {
	mixin ThreadManForUser_Threads;
	mixin ThreadManForUser_Semaphores;

	void initModule() {
		initModule_Threads();
		initModule_Semaphores();
		moduleManager.getCurrentThreadName = { return threadManager.currentThread.name; };
	}

	void initNids() {
		initNids_Threads();
		initNids_Semaphores();
		mixin(registerd!(0xE81CAF8F, sceKernelCreateCallback));
		mixin(registerd!(0x55C20A00, sceKernelCreateEventFlag));
		mixin(registerd!(0xEF9E4C70, sceKernelDeleteEventFlag));
		mixin(registerd!(0x1FB15A32, sceKernelSetEventFlag));
		mixin(registerd!(0x7C0DC2A0, sceKernelCreateMsgPipe));
		mixin(registerd!(0xF0B7DA1C, sceKernelDeleteMsgPipe));
		mixin(registerd!(0x876DBFAD, sceKernelSendMsgPipe));
		mixin(registerd!(0x884C9F90, sceKernelTrySendMsgPipe));
		mixin(registerd!(0x74829B76, sceKernelReceiveMsgPipe));
		mixin(registerd!(0xDF52098F, sceKernelTryReceiveMsgPipe));
		mixin(registerd!(0x33BE4024, sceKernelReferMsgPipeStatus));
		mixin(registerd!(0xBC6FEBC5, sceKernelReferSemaStatus));
		mixin(registerd!(0x812346E4, sceKernelClearEventFlag));
		mixin(registerd!(0x402FCF22, sceKernelWaitEventFlag));
		mixin(registerd!(0x328C546A, sceKernelWaitEventFlagCB));
		mixin(registerd!(0x30FD48F0, sceKernelPollEventFlag));
		mixin(registerd!(0x369ED59D, sceKernelGetSystemTimeLow));
		mixin(registerd!(0xA66B0120, sceKernelReferEventFlagStatus));

		mixin(registerd!(0xEDBA5844, sceKernelDeleteCallback));
		mixin(registerd!(0x349D6D6C, sceKernelCheckCallback));
		mixin(registerd!(0x82BC5777, sceKernelGetSystemTimeWide));

		mixin(registerd!(0x8125221D, sceKernelCreateMbx));
		mixin(registerd!(0x86255ADA, sceKernelDeleteMbx));
		mixin(registerd!(0xE9B3061E, sceKernelSendMbx));
		mixin(registerd!(0x18260574, sceKernelReceiveMbx));
		mixin(registerd!(0x0D81716A, sceKernelPollMbx));
		mixin(registerd!(0x87D4DD36, sceKernelCancelReceiveMbx));
		mixin(registerd!(0xA8E8C846, sceKernelReferMbxStatus));

		mixin(registerd!(0xC8CD158C, sceKernelUSec2SysClockWide));
		mixin(registerd!(0x39810265, sceKernelReferVplStatus));
		mixin(registerd!(0x56C039B5, sceKernelCreateVpl));
		mixin(registerd!(0x64D4540E, sceKernelReferThreadProfiler));
		mixin(registerd!(0x8218B4DD, sceKernelReferGlobalProfiler));
		mixin(registerd!(0xAF36D708, sceKernelTryAllocateVpl));
		mixin(registerd!(0xB736E9FF, sceKernelFreeVpl));
	}

	/**
	 * Get the thread profiler registers.
	 * @return Pointer to the registers, NULL on error
	 */
	PspDebugProfilerRegs* sceKernelReferThreadProfiler() {
		unimplemented();
		return null;
	}

	/**
	 * Get the globile profiler registers.
	 * @return Pointer to the registers, NULL on error
	 */
	PspDebugProfilerRegs *sceKernelReferGlobalProfiler() {
		unimplemented();
		return null;
	}

	/**
	 * Free a block
	 *
	 * @param uid - The UID of the pool
	 * @param data - The data block to deallocate
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelFreeVpl(SceUID uid, void* data) {
		unimplemented();
		return -1;
	}

	/**
	 * Create a variable pool
	 *
	 * @param name - Name of the pool
	 * @param part - The memory partition ID
	 * @param attr - Attributes
	 * @param size - Size of pool
	 * @param opt  - Options (set to NULL)
	 *
	 * @return The UID of the created pool, < 0 on error.
	 */
	SceUID sceKernelCreateVpl(string name, int part, int attr, uint size, SceKernelVplOptParam* opt) {
		unimplemented();
		return -1;
	}

	/**
	 * Try to allocate from the pool 
	 *
	 * @param uid - The UID of the pool
	 * @param size - The size to allocate
	 * @param data - Receives the address of the allocated data
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelTryAllocateVpl(SceUID uid, uint size, void** data) {
		unimplemented();
		return -1;
	}

	/**
	 * Convert a number of microseconds to a wide time
	 * 
	 * @param usec - Number of microseconds.
	 *
	 * @return The time
	 */
	SceInt64 sceKernelUSec2SysClockWide(uint usec) {
		unimplemented();
		return 0;
	}

	/**
	 * Get the status of an VPL
	 *
	 * @param uid - The uid of the VPL
	 * @param info - Pointer to a ::SceKernelVplInfo structure
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelReferVplStatus(SceUID uid, SceKernelVplInfo* info) {
		unimplemented();
		return -1;
	}

	/**
	 * Creates a new messagebox
	 *
	 * @par Example:
	 * @code
	 * int mbxid;
	 * mbxid = sceKernelCreateMbx("MyMessagebox", 0, NULL);
	 * @endcode
	 *
	 * @param name - Specifies the name of the mbx
	 * @param attr - Mbx attribute flags (normally set to 0)
	 * @param option - Mbx options (normally set to NULL)
	 * @return A messagebox id
	 */
	SceUID sceKernelCreateMbx(string name, SceUInt attr, SceKernelMbxOptParam* option) {
		unimplemented();
		return -1;
	}

	/**
	 * Destroy a messagebox
	 *
	 * @param mbxid - The mbxid returned from a previous create call.
	 * @return Returns the value 0 if its succesful otherwise an error code
	 */
	int sceKernelDeleteMbx(SceUID mbxid) {
		unimplemented();
		return -1;
	}

	/**
	 * Send a message to a messagebox
	 *
	 * @par Example:
	 * @code
	 * struct MyMessage {
	 * 	SceKernelMsgPacket header;
	 * 	char text[8];
	 * };
	 *
	 * struct MyMessage msg = { {0}, "Hello" };
	 * // Send the message
	 * sceKernelSendMbx(mbxid, (void*) &msg);
	 * @endcode
	 *
	 * @param mbxid - The mbx id returned from sceKernelCreateMbx
	 * @param message - A message to be forwarded to the receiver.
	 * 					The start of the message should be the 
	 * 					::SceKernelMsgPacket structure, the rest
	 *
	 * @return < 0 On error.
	 */
	int sceKernelSendMbx(SceUID mbxid, void *message) {
		unimplemented();
		return -1;
	}

	/**
	 * Wait for a message to arrive in a messagebox
	 *
	 * @par Example:
	 * @code
	 * void *msg;
	 * sceKernelReceiveMbx(mbxid, &msg, NULL);
	 * @endcode
	 *
	 * @param mbxid - The mbx id returned from sceKernelCreateMbx
	 * @param pmessage - A pointer to where a pointer to the
	 *                   received message should be stored
	 * @param timeout - Timeout in microseconds
	 *
	 * @return < 0 on error.
	 */
	int sceKernelReceiveMbx(SceUID mbxid, void **pmessage, SceUInt *timeout) {
		unimplemented();
		return -1;
	}

	/**
	 * Check if a message has arrived in a messagebox
	 *
	 * @par Example:
	 * @code
	 * void *msg;
	 * sceKernelPollMbx(mbxid, &msg);
	 * @endcode
	 *
	 * @param mbxid - The mbx id returned from sceKernelCreateMbx
	 * @param pmessage - A pointer to where a pointer to the
	 *                   received message should be stored
	 *
	 * @return < 0 on error (SCE_KERNEL_ERROR_MBOX_NOMSG if the mbx is empty).
	 */
	int sceKernelPollMbx(SceUID mbxid, void **pmessage) {
		unimplemented();
		return -1;
	}

	/**
	 * Abort all wait operations on a messagebox
	 *
	 * @par Example:
	 * @code
	 * sceKernelCancelReceiveMbx(mbxid, NULL);
	 * @endcode
	 *
	 * @param mbxid - The mbx id returned from sceKernelCreateMbx
	 * @param pnum  - A pointer to where the number of threads which
	 *                were waiting on the mbx should be stored (NULL
	 *                if you don't care)
	 *
	 * @return < 0 on error
	 */
	int sceKernelCancelReceiveMbx(SceUID mbxid, int *pnum) {
		unimplemented();
		return -1;
	}

	/**
	 * Retrieve information about a messagebox.
	 *
	 * @param mbxid - UID of the messagebox to retrieve info for.
	 * @param info - Pointer to a ::SceKernelMbxInfo struct to receive the info.
	 *
	 * @return < 0 on error.
	 */
	int sceKernelReferMbxStatus(SceUID mbxid, SceKernelMbxInfo *info) {
		unimplemented();
		return -1;
	}

	/**
	 * Delete a callback
	 *
	 * @param cb - The UID of the specified callback
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelDeleteCallback(SceUID cb) {
		unimplemented();
		return -1;
	}

	/**
	 * Check callback ?
	 *
	 * @return Something or another
	 */
	int sceKernelCheckCallback() {
		unimplemented();
		return -1;
	}

	/**
	 * Get the system time (wide version)
	 *
	 * @return The system time
	 */
	SceInt64 sceKernelGetSystemTimeWide() {
		unimplemented();
		return 0;
	}

	void sceKernelReferEventFlagStatus() {
		unimplemented();
	}
	
	/**
	 * Process callbacks in sceKernel*ThreadCB() methods.
	 */
	void processCallbacks() {
		// @TODO
	}

	/**
	 * Get the low 32bits of the current system time
	 *
	 * @return The low 32bits of the system time
	 */
	uint sceKernelGetSystemTimeLow() {
		unimplemented();
		return 0;
	}

	/**
	 * Events related stuff.
	 */
	template TemplateEvent() {
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
		 * Clear a event flag bit pattern
		 *
		 * @param evid - The event id returned by ::sceKernelCreateEventFlag
		 * @param bits - The bits to clean
		 *
		 * @return < 0 on Error
		 */
		int sceKernelClearEventFlag(SceUID evid, u32 bits) {
			unimplemented();
			return -1;
		}

		/** 
		 * Wait for an event flag for a given bit pattern.
		 *
		 * @param evid - The event id returned by sceKernelCreateEventFlag.
		 * @param bits - The bit pattern to poll for.
		 * @param wait - Wait type, one or more of ::PspEventFlagWaitTypes or'ed together
		 * @param outBits - The bit pattern that was matched.
		 * @param timeout  - Timeout in microseconds
		 * @return < 0 On error
		 */
		int sceKernelWaitEventFlag(int evid, u32 bits, u32 wait, u32 *outBits, SceUInt *timeout) {
			unimplemented();
			return -1;
		}

		/** 
		 * Wait for an event flag for a given bit pattern with callback.
		 *
		 * @param evid - The event id returned by sceKernelCreateEventFlag.
		 * @param bits - The bit pattern to poll for.
		 * @param wait - Wait type, one or more of ::PspEventFlagWaitTypes or'ed together
		 * @param outBits - The bit pattern that was matched.
		 * @param timeout  - Timeout in microseconds
		 * @return < 0 On error
		 */
		int sceKernelWaitEventFlagCB(int evid, u32 bits, u32 wait, u32 *outBits, SceUInt *timeout) {
			unimplemented();
			return -1;
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
		  * Poll an event flag for a given bit pattern.
		  *
		  * @param evid - The event id returned by sceKernelCreateEventFlag.
		  * @param bits - The bit pattern to poll for.
		  * @param wait - Wait type, one or more of ::PspEventFlagWaitTypes or'ed together
		  * @param outBits - The bit pattern that was matched.
		  * @return < 0 On error
		  */
		int sceKernelPollEventFlag(int evid, u32 bits, u32 wait, u32 *outBits) {
			unimplemented();
			return -1;
		}
	}

	/**
	 * Callbacks related stuff.
	 */
	template TemplateCallback() {
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
			return reinterpret!(int)(new PspCallback(name, func, arg));
		}
	}
	
	template TemplateMsgPipe() {
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

	mixin TemplateEvent;
	mixin TemplateCallback;
	mixin TemplateMsgPipe;
}

/**
 * Library imports for the kernel threading library.
 */
class ThreadManForKernel : ThreadManForUser {
}

/**
 * Psp Callback.
 */
class PspCallback {
	/**
	 * Name of the callback.
	 */
	string name;

	/**
	 * Pointer to the callback function to execute.
	 */
	SceKernelCallbackFunction func;

	/**
	 * Argument to send to callback function.
	 */
	void* arg;

	/**
	 * Constructor.
	 */
	this(string name, SceKernelCallbackFunction func, void* arg) {
		this.name = name;
		this.func = func;
		this.arg  = arg;
	}
}

struct SceKernelMbxOptParam {
	/** Size of the ::SceKernelMbxOptParam structure. */
	SceSize 	size;
}

struct SceKernelMbxInfo {
	SceSize 	size;     // Size of the ::SceKernelMbxInfo structure.
	char 		name[32]; // NUL-terminated name of the messagebox.
	SceUInt 	attr;     // Attributes
	int 		numWaitThreads; // The number of threads waiting on the messagebox.
	int 		numMessages; // Number of messages currently in the messagebox.
	void		*firstMessage; // The message currently at the head of the queue.
}

struct PspDebugProfilerRegs {
	//volatile:
	u32 enable;
	u32 systemck;
	u32 cpuck;
	u32 internal;
	u32 memory;
	u32 copz;
	u32 vfpu;
	u32 sleep;
	u32 bus_access;
	u32 uncached_load;
	u32 uncached_store;
	u32 cached_load;
	u32 cached_store;
	u32 i_miss;
	u32 d_miss;
	u32 d_writeback;
	u32 cop0_inst;
	u32 fpu_inst;
	u32 vfpu_inst;
	u32 local_bus;
}

struct SceKernelVplOptParam {
	SceSize size;
}

struct SceKernelVplInfo {
	SceSize  size;
	char[32] name;
	SceUInt  attr;
	int      poolSize;
	int      freeSize;
	int      numWaitThreads;
}

static this() {
	mixin(Module.registerModule("ThreadManForUser"));
	mixin(Module.registerModule("ThreadManForKernel"));
}
