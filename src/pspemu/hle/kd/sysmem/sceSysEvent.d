module pspemu.hle.kd.sysmem.sceSysEvent; // kd/sysmem.prx (sceSystemMemoryManager)

import pspemu.hle.ModuleNative;
import pspemu.core.exceptions.NotImplementedException;

import pspemu.hle.kd.sysmem.Types; 

class sceSysEventForKernel : HleModuleHost {
	mixin TRegisterModule;

	PspSysEventHandler pspSysEventHandler;
	
	void initNids() {
		mixin(registerFunction!(0xCD9E4BB5, sceKernelRegisterSysEventHandler));
		mixin(registerFunction!(0x36331294, sceKernelSysEventDispatch));
	}

	/**
	 * Register a SysEvent handler.
	 *
	 * @param handler - the handler to register
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelRegisterSysEventHandler(PspSysEventHandler *handler) {
		logInfo("sceKernelRegisterSysEventHandler");
		pspSysEventHandler = *handler;
		return 0;
	}
	
	/**
	 * Dispatch a SysEvent event.
	 *
	 * @param ev_type_mask  - the event type mask
	 * @param ev_id         - the event id
	 * @param ev_name       - the event name
	 * @param param         - the pointer to the custom parameters
	 * @param result        - the pointer to the result
	 * @param break_nonzero - set to 1 to interrupt the calling chain after the first non-zero return
	 * @param break_handler - the pointer to the event handler having interrupted
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelSysEventDispatch(int ev_type_mask, int ev_id, /*char**/uint ev_name, /*void**/ uint param, /*int**/ uint result, int break_nonzero, PspSysEventHandler* break_handler) {
		logWarning("Not fully implemented sceKernelSysEventDispatch");
		hleEmulatorState.callbacksHandler.addToExecuteQueue(
			pspSysEventHandler.handler,
			[ev_id, ev_name, param, result]
		);
		return 0;
	}
	 
}
