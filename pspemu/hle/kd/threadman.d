module pspemu.hle.kd.threadman; // kd/threadman.prx (sceThreadManager)

//debug = DEBUG_THREADS;
//debug = DEBUG_SYSCALL;

import pspemu.hle.kd.threadman_common;

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

static this() {
	mixin(Module.registerModule("ThreadManForUser"));
	mixin(Module.registerModule("ThreadManForKernel"));
}
