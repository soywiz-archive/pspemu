module pspemu.hle.kd.threadman.ThreadMan_MsgPipes;

import pspemu.core.exceptions.HaltException;

import pspemu.utils.sync.WaitEvent;
import pspemu.utils.sync.WaitMultipleObjects;

import pspemu.hle.HleEmulatorState;
import pspemu.core.ThreadState;

import pspemu.hle.kd.threadman.Types;

import pspemu.utils.Logger;
import pspemu.utils.String;

import std.datetime;
import std.stdio;

/**
 * Events related stuff.
 */
template ThreadManForUser_MsgPipes() {
	void initModule_MsgPipes() {
		
	}
	
	void initNids_MsgPipes() {
		mixin(registerd!(0x7C0DC2A0, sceKernelCreateMsgPipe));
		mixin(registerd!(0xF0B7DA1C, sceKernelDeleteMsgPipe));
		mixin(registerd!(0x876DBFAD, sceKernelSendMsgPipe));
		mixin(registerd!(0x884C9F90, sceKernelTrySendMsgPipe));
		mixin(registerd!(0x74829B76, sceKernelReceiveMsgPipe));
		mixin(registerd!(0xDF52098F, sceKernelTryReceiveMsgPipe));
		mixin(registerd!(0x33BE4024, sceKernelReferMsgPipeStatus));
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
