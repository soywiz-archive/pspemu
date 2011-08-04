module pspemu.hle.kd.threadman.ThreadMan_Mbx;

import pspemu.hle.kd.threadman.Types;
import pspemu.hle.kd.threadman.ThreadMan_Semaphores;
import pspemu.hle.kd.SceKernelErrors;

// @TODO @NOTE :: This should be implemented as a priority queue.
struct SceKernelMsgPacket {
	/** Pointer to next msg (used by the kernel) */
	SceKernelMsgPacket* next;
	/** Priority ? */
	SceUChar    msgPriority;
	SceUChar    dummy[3];
	/** After this can be any user defined data */
}

/**
 * Callbacks related stuff.
 */
template ThreadManForUser_Mbx() {
	void initModule_Mbx() {
	}
	
	void initNids_Mbx() {
		mixin(registerd!(0x8125221D, sceKernelCreateMbx));
		mixin(registerd!(0x86255ADA, sceKernelDeleteMbx));
		mixin(registerd!(0xE9B3061E, sceKernelSendMbx));
		mixin(registerd!(0x18260574, sceKernelReceiveMbx));
		mixin(registerd!(0x0D81716A, sceKernelPollMbx));
		mixin(registerd!(0x87D4DD36, sceKernelCancelReceiveMbx));
		mixin(registerd!(0xA8E8C846, sceKernelReferMbxStatus));
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
	 * @param name   - Specifies the name of the mbx
	 * @param attr   - Mbx attribute flags (normally set to 0)
	 * @param option - Mbx options (normally set to NULL)
	 *
	 * @return A messagebox id
	 */
	SceUID sceKernelCreateMbx(string name, SceUInt attr, SceKernelMbxOptParam* option) {
		PspMessageBox messageBox = new PspMessageBox(name);
		uint uid = uniqueIdFactory.add(messageBox);
		return uid;
	}

	/**
	 * Destroy a messagebox
	 *
	 * @param mbxid - The mbxid returned from a previous create call.
	 *
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
	 * @param mbxid   - The mbx id returned from sceKernelCreateMbx
	 * @param message - A message to be forwarded to the receiver. The start of the message should be the ::SceKernelMsgPacket structure, the rest
	 *
	 * @return < 0 On error.
	 */
	int sceKernelSendMbx(SceUID mbxid, SceKernelMsgPacket* message) {
		PspMessageBox messageBox = uniqueIdFactory.get!PspMessageBox(mbxid);
		messageBox.send(message);
		return 0;
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
	 * @param mbxid    - The mbx id returned from sceKernelCreateMbx
	 * @param pmessage - A pointer to where a pointer to the received message should be stored
	 * @param timeout  - Timeout in microseconds
	 *
	 * @return < 0 on error.
	 */
	int sceKernelReceiveMbx(SceUID mbxid, uint* /* SceKernelMsgPacket* **/ pmessage, SceUInt *timeout) {
		PspMessageBox messageBox = uniqueIdFactory.get!PspMessageBox(mbxid);
		if (pmessage !is null) {
			*pmessage = cast(uint)messageBox.recv();
			return 0;
		} else {
			return -1;
		}
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
	 * @param mbxid    - The mbx id returned from sceKernelCreateMbx
	 * @param pmessage - A pointer to where a pointer to the received message should be stored
	 *
	 * @return < 0 on error (SCE_KERNEL_ERROR_MBOX_NOMSG if the mbx is empty).
	 */
	int sceKernelPollMbx(SceUID mbxid, uint* /* SceKernelMsgPacket** */ pmessage) {
		PspMessageBox messageBox = uniqueIdFactory.get!PspMessageBox(mbxid);

		if (!messageBox.hasMessages) return 0x800201b2/*SceKernelErrors.SCE_KERNEL_ERROR_MBOX_NOMSG*/;
		
		return sceKernelReceiveMbx(mbxid, pmessage, null);
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
	 * @param pnum  - A pointer to where the number of threads which were waiting on the mbx should be stored (NULL if you don't care)
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
	 * @param info  - Pointer to a ::SceKernelMbxInfo struct to receive the info.
	 *
	 * @return < 0 on error.
	 */
	int sceKernelReferMbxStatus(SceUID mbxid, SceKernelMbxInfo *info) {
		unimplemented();
		return -1;
	}
}

class PspMessageBox {
	string name;
	PspSemaphore semaphore;
	SceKernelMsgPacket* message;
	
	@property bool hasMessages() {
		return message !is null;
	}
	
	void send(SceKernelMsgPacket* message) {
		synchronized (this) {
			this.message = message;
			semaphore.incrementCount(1);
		}
	}
	
	SceKernelMsgPacket* recv() {
		/*
		synchronized (this) {
			this.message = message;
			semaphore.incrementCount(1);
		}
		*/
		throw(new Exception("Not implemented yet"));
	}

	this(string name) {
		this.name = name;
		this.semaphore = new PspSemaphore("sema-" ~ name, 0, 0, 256);
	}
}