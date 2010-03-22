module pspemu.hle.kd.ge; // kd/ge.prx (sceGE_Manager)

//debug = DEBUG_SYSCALL;

import pspemu.hle.Module;
import pspemu.core.gpu.Gpu;

class sceGe_driver : Module {
	this() {
		mixin(registerd!(0xE47E40E4, sceGeEdramGetAddr));
		mixin(registerd!(0xAB49E76A, sceGeListEnQueue));
		mixin(registerd!(0xE0D68148, sceGeListUpdateStallAddr));
		mixin(registerd!(0x03444EB4, sceGeListSync));
		mixin(registerd!(0xB287BD61, sceGeDrawSync));
		mixin(registerd!(0xA4FC06A4, sceGeSetCallback));
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
		cpu.gpu.sceGeListSync(cast(Gpu.DisplayList*)qid, syncType);
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
	 * Register callback handlers for the the Ge 
	 *
	 * @param cb - Configured callback data structure
	 * @return The callback ID, < 0 on error
	 */
	int sceGeSetCallback(PspGeCallbackData *cb) {
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
	 * Update the stall address for the specified queue.
	 * 
	 * @param qid - The ID of the queue.
	 * @param stall - The stall address to update
	 *
	 * @return Unknown. Probably 0 if successful.
	 */
	int sceGeListUpdateStallAddr(int qid, void *stall) {
		cpu.gpu.sceGeListUpdateStallAddr(cast(Gpu.DisplayList*)qid, stall);
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