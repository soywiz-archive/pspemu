module pspemu.hle.kd.ge; // kd/ge.prx (sceGE_Manager)

//debug = DEBUG_SYSCALL;

import pspemu.hle.Module;
import pspemu.core.gpu.Gpu;
import pspemu.core.gpu.DisplayList;

class sceGe_driver : Module {
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
	}

	PspGeCallbackData[] callbackDataList;

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
	 * Wait for syncronisation of a list.
	 *
	 * @param qid - The queue ID of the list to sync.
	 * @param syncType - Specifies the condition to wait on.  One of ::PspGeSyncType.
	 * 
	 * @return ???
	 */
	int sceGeListSync(int qid, int syncType) {
		cpu.gpu.sceGeListSync(cast(DisplayList*)qid, syncType);
		return 0;
	}

	/**
	 * Get the address of VRAM.
	 *
	 * @return A pointer to the base of VRAM.
	 */
	uint sceGeEdramGetAddr() {
		return cpu.memory.frameBufferAddress;
	}

	/**
	 * Get the size of VRAM.
	 *
	 * @return The size of VRAM (in bytes).
	 */
	uint sceGeEdramGetSize() {
		return cpu.memory.frameBufferMask + 1;
	}

	/**
	 * Register callback handlers for the the Ge 
	 *
	 * @param cb - Configured callback data structure
	 * @return The callback ID, < 0 on error
	 */
	int sceGeSetCallback(PspGeCallbackData* cb) {
		int n;
		PspGeCallbackData* callbackDataPtr;
		for (n = 0; n < callbackDataList.length; n++) {
			callbackDataPtr = &callbackDataList[n];
			if (*callbackDataPtr == PspGeCallbackData.init) {
				*callbackDataPtr = *cb;
				break;
			}
		}

		if (n == callbackDataList.length) {
			callbackDataList ~= *cb;
			callbackDataPtr = &callbackDataList[$ - 1];
		}
		
		return cast(int)cast(void *)callbackDataPtr;
	}

	/**
	 * Unregister the callback handlers
	 *
	 * @param cbid - The ID of the callbacks from sceGeSetCallback
	 * @return < 0 on error
	 */
	int sceGeUnsetCallback(int cbid) {
		auto callbackDataPtr = (cast(PspGeCallbackData*)cbid);
		if (callbackDataPtr is null) return -1;
		*callbackDataPtr = PspGeCallbackData.init;
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
		return cast(int)cast(void*)cpu.gpu.sceGeListEnQueue(list, stall);
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
		return cast(int)cast(void*)cpu.gpu.sceGeListEnQueueHead(list, stall);
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
		cpu.gpu.sceGeListUpdateStallAddr(cast(DisplayList*)qid, stall);
		return 0;
	}

	/**
	 * Wait for drawing to complete.
	 * 
	 * @param syncType - Specifies the condition to wait on.  One of ::PspGeSyncType.
	 * 
	 * @return ???
	 */
	int sceGeDrawSync(int syncType) {
		cpu.gpu.sceGeDrawSync(syncType);
		return 0;
	}
}

class sceGe_user : sceGe_driver {
}

/** Stores the state of the GE. */
struct PspGeContext {
	uint context[512];
}

/** Typedef for a GE callback */
alias void function(int id, void *arg) PspGeCallback;

/** Structure to hold the callback data */
struct PspGeCallbackData {
	/** GE callback for the signal interrupt */
	PspGeCallback signal_func;
	/** GE callback argument for signal interrupt */
	void *signal_arg;
	/** GE callback for the finish interrupt */
	PspGeCallback finish_func;
	/** GE callback argument for finish interrupt */
	void *finish_arg;
}

struct PspGeListArgs {
	uint	size;
	PspGeContext*	context;
}

static this() {
	mixin(Module.registerModule("sceGe_driver"));
	mixin(Module.registerModule("sceGe_user"));
}