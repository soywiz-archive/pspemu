module pspemu.hle.kd.ge.sceGe; // kd/ge.prx (sceGE_Manager)

import pspemu.core.gpu.Gpu;
import pspemu.core.gpu.DisplayList;
import pspemu.hle.ModuleNative;

//debug = DEBUG_SYSCALL;

import std.stdio;

import pspemu.core.gpu.Gpu;
import pspemu.core.gpu.DisplayList;
import pspemu.hle.ModuleNative;

import pspemu.hle.kd.ge.Types;

class sceGe_driver : ModuleNative {
	void initNids() {
		mixin(registerd!(0xE47E40E4, sceGeEdramGetAddr));
		mixin(registerd!(0xAB49E76A, sceGeListEnQueue));
		mixin(registerd!(0x1C0D95A6, sceGeListEnQueueHead));
		mixin(registerd!(0xE0D68148, sceGeListUpdateStallAddr));
		mixin(registerd!(0x03444EB4, sceGeListSync));
		mixin(registerd!(0xB287BD61, sceGeDrawSync));
		mixin(registerd!(0xA4FC06A4, sceGeSetCallback));
		mixin(registerd!(0x05DB22CE, sceGeUnsetCallback));
		mixin(registerd!(0x1F6752AD, sceGeEdramGetSize));
		mixin(registerd!(0xDC93CFEF, sceGeGetCmd));
		mixin(registerd!(0x57C8945B, sceGeGetMtx));
		mixin(registerd!(0x5FB86AB0, sceGeListDeQueue));
		mixin(registerd!(0xB448EC0D, sceGeBreak));
		mixin(registerd!(0x4C06E472, sceGeContinue));
		mixin(registerd!(0x438A385A, sceGeSaveContext));
		mixin(registerd!(0x0BF608FB, sceGeRestoreContext));
		mixin(registerd!(0xB77905EA, sceGeEdramSetAddrTranslation));
	}

	PspGeCallbackData[] callbackDataList;
	
	uint eDRAMMemoryWidth = 1024;
	
	/**
	 * Set Graphics Engine eDRAM address translation mode
	 */
	int sceGeEdramSetAddrTranslation(int width) {
		scope (exit) eDRAMMemoryWidth = width;
		return eDRAMMemoryWidth;
	}
	
	/**
	 * Save the GE's current state.
	 *
	 * @param context - Pointer to a ::PspGeContext.
	 *
	 * @return ???
	 */
	int sceGeSaveContext(PspGeContext* context) {
		unimplemented();
		return -1;
	}

	/**
	 * Restore a previously saved GE context.
	 *
	 * @param context - Pointer to a ::PspGeContext.
	 *
	 * @return ???
	 */
	int sceGeRestoreContext(PspGeContext* context) {
		unimplemented();
		return -1;
	}

	// @TODO: Unknown prototype
	void sceGeBreak() {
		unimplemented();
	}

	// @TODO: Unknown prototype
	void sceGeContinue() {
		unimplemented();
	}

	/**
	 * Retrive the current value of a GE command.
	 *
	 * @param cmd - The GE command register to retrieve.
	 *
	 * @return The value of the GE command.
	 */
	uint sceGeGetCmd(int cmd) {
		unimplemented();
		return 0;
	}

	/**
	 * Retrieve a matrix of the given type.
	 *
	 * @param type - One of ::PspGeMatrixTypes.
	 * @param matrix - Pointer to a variable to store the matrix.
	 *
	 * @return ???
	 */
	int sceGeGetMtx(int type, void *matrix) {
		unimplemented();
		return 0;
	}

	/**
	 * Get the address of VRAM.
	 *
	 * @return A pointer to the base of VRAM.
	 */
	uint sceGeEdramGetAddr() {
		Logger.log(Logger.Level.TRACE, "sceGe_driver", "sceGeEdramGetAddr()");
		return currentEmulatorState.memory.Segments.frameBuffer.address;
	}

	/**
	 * Get the size of VRAM.
	 *
	 * @return The size of VRAM (in bytes).
	 */
	uint sceGeEdramGetSize() {
		Logger.log(Logger.Level.TRACE, "sceGe_driver", "sceGeEdramGetSize()");
		return currentEmulatorState.memory.Segments.frameBuffer.size;
	}

	/**
	 * Register callback handlers for the the Ge 
	 *
	 * @param cb - Configured callback data structure
	 * @return The callback ID, < 0 on error
	 */
	int sceGeSetCallback(PspGeCallbackData* cb) {
		currentEmulatorState().gpu.pspGeCallbackData = *cb;

		logInfo("Partially Implemented: sceGeSetCallback (should be able to create several callbacks?)");
		return 0;
	}

	/**
	 * Unregister the callback handlers
	 *
	 * @param cbid - The ID of the callbacks from sceGeSetCallback
	 * @return < 0 on error
	 */
	int sceGeUnsetCallback(int cbid) {
		Logger.log(Logger.Level.ERROR, "sceGe_driver", "Not Implemented: sceGeUnsetCallback()");
		/*
		auto callbackDataPtr = (cast(PspGeCallbackData*)cbid);
		if (callbackDataPtr is null) return -1;
		*callbackDataPtr = PspGeCallbackData.init;
		*/
		return 0;
	}

	/** 
	 * Enqueue a display list at the tail of the GE display list queue.
	 *
	 * @param list - The head of the list to queue.
	 * @param stall - The stall address.
	 * If NULL then no stall address set and the list is transferred immediately.
	 * @param cbid - ID of the callback set by calling sceGeSetCallback
	 * @param arg - Structure containing GE context buffer address
	 *
	 * @return The ID of the queue.
	 */
	int sceGeListEnQueue(void* list, void* stall, int cbid, PspGeListArgs *arg) {
		Logger.log(Logger.Level.TRACE, "sceGe_driver", "sceGeListEnQueue()");
		return cast(int)cast(void*)currentEmulatorState.gpu.sceGeListEnQueue(list, stall);
	}
	
	/**
	 * Enqueue a display list at the head of the GE display list queue.
	 * 
	 * @param list - The head of the list to queue.
	 * @param stall - The stall address.
	 * If NULL then no stall address set and the list is transferred immediately.
	 * @param cbid - ID of the callback set by calling sceGeSetCallback
	 * @param arg - Structure containing GE context buffer address
	 *
	 * @return The ID of the queue.
	 */
	int sceGeListEnQueueHead(void* list, void* stall, int cbid, PspGeListArgs* arg) {
		writefln("sceGeListEnQueueHead()");
		return cast(int)cast(void*)currentEmulatorState.gpu.sceGeListEnQueueHead(list, stall);
	}

	/**
	 * Cancel a queued or running list.
	 *
	 * @param qid - The ID of the queue.
	 *
	 * @return ???
	 */
	int sceGeListDeQueue(int qid) {
		unimplemented();
		return 0;
	}

	/**
	 * Update the stall address for the specified queue.
	 * 
	 * @param qid - The ID of the queue.
	 * @param stall - The stall address to update
	 *
	 * @return Unknown. Probably 0 if successful.
	 */
	int sceGeListUpdateStallAddr(int qid, void *stall) {
		Logger.log(Logger.Level.TRACE, "sceGe_driver", "sceGeListUpdateStallAddr()");
		currentEmulatorState.gpu.sceGeListUpdateStallAddr(cast(DisplayList*)qid, stall);
		return 0;
	}

	/**
	 * Wait for syncronisation of a list.
	 *
	 * @param qid - The queue ID of the list to sync.
	 * @param syncType - Specifies the condition to wait on.  One of ::PspGeSyncType.
	 * 
	 * @return ???
	 */
	int sceGeListSync(int qid, int syncType) {
		Logger.log(Logger.Level.TRACE, "sceGe_driver", "sceGeListSync()");
		currentEmulatorState.gpu.sceGeListSync(cast(DisplayList*)qid, syncType);
		return 0;
	}

	/**
	 * Wait until display list has finished executing
	 *
	 * @par Example: Wait for the currently executing display list
	 * @code
	 * sceGuSync(0,0);
	 * @endcode
	 *
	 * Available what are:
	 *   - GU_SYNC_WHAT_DONE
	 *   - GU_SYNC_WHAT_QUEUED
	 *   - GU_SYNC_WHAT_DRAW
	 *   - GU_SYNC_WHAT_STALL
	 *   - GU_SYNC_WHAT_CANCEL
	 *
	 * Available mode are:
	 *   - GU_SYNC_FINISH - Wait until the last sceGuFinish command is reached
	 *   - GU_SYNC_SIGNAL - Wait until the last (?) signal is executed
	 *   - GU_SYNC_DONE   - Wait until all commands currently in list are executed
	 *   - GU_SYNC_LIST   - Wait for the currently executed display list (GU_DIRECT)
	 *   - GU_SYNC_SEND   - Wait for the last send list
	 *
	 * @param mode - What to wait for
	 * @param what - What to sync to
	 *
	 * @return Unknown at this time
	**/
	// int sceGuSync(int mode, int what);

	/**
	 * Wait for drawing to complete.
	 * 
	 * @param syncType - Specifies the condition to wait on.  One of ::PspGeSyncType.
	 * 
	 * @return ???
	 */
	int sceGeDrawSync(int syncType) {
		Logger.log(Logger.Level.TRACE, "sceGe_driver", "sceGeDrawSync(%d)", syncType);
		currentEmulatorState.gpu.sceGeDrawSync(syncType);
		Logger.log(Logger.Level.TRACE, "sceGe_driver", "/sceGeDrawSync(%d)", syncType);
		return 0;
	}
}

class sceGe_user : sceGe_driver {
}

static this() {
	mixin(ModuleNative.registerModule("sceGe_user"));
	mixin(ModuleNative.registerModule("sceGe_driver"));
}