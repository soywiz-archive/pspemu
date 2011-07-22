module pspemu.hle.kd.interruptman.InterruptManager; // kd/interruptman.prx (sceInterruptManager):

//debug = DEBUG_SYSCALL;
//debug = DEBUG_CONTROLLER;

import pspemu.hle.ModuleNative;

//import pspemu.core.cpu.Interrupts;
import pspemu.core.Memory;

import pspemu.hle.kd.interruptman.Types;

import pspemu.hle.Callbacks;

//import pspemu.utils.Utils;
//import pspemu.hle.Utils;

// http://forums.ps2dev.org/viewtopic.php?t=5687

// @TODO! Fixme! In which thread should handlers be executed?

class InterruptManager : ModuleNative {
	void initNids() {
		mixin(registerd!(0xCA04A2B9, sceKernelRegisterSubIntrHandler));
		mixin(registerd!(0xFB8E22EC, sceKernelEnableSubIntr));
		mixin(registerd!(0xD61E6961, sceKernelReleaseSubIntrHandler));
		mixin(registerd!(0xD2E8363F, sceKernelQueryIntrHandlerInfo)); // QueryIntrHandlerInfo
		mixin(registerd!(0x36B1EF81, sceKernelQueryIntrHandlerInfo));
	}

	//Interrupts.Callback[int][int] handlers;
	PspCallback[int][int] handlers;

	/** 
	 * Register a sub interrupt handler.
	 * 
	 * @param intno   - The interrupt number to register.
	 * @param no      - The sub interrupt handler number (user controlled) (0-15)
	 * @param handler - The interrupt handler
	 * @param arg     - An argument passed to the interrupt handler
	 *
	 * @return < 0 on error.
	 */
	int sceKernelRegisterSubIntrHandler(PspSubInterrupts intno, int no, uint handler, uint arg) {
		logInfo("sceKernelRegisterSubIntrHandler(%d:%s, %d, %08X, %08X)", intno, to!string(intno), no, handler, arg);
		
		handlers[intno][no] = new PspCallback("sceKernelRegisterSubIntrHandlerCallback", handler, arg);
		
		return 0;
	}
	
	CallbacksHandler.Type convertPspSubInterruptsToCallbacksHandlerType(PspSubInterrupts intno) {
		switch (intno) {
			case PspSubInterrupts.PSP_DISPLAY_SUBINT: return CallbacksHandler.Type.VerticalBlank;
			default:
				throw(new Exception("Unhandled convertPspSubInterruptsToCallbacksHandlerType.PspSubInterrupts"));
			break;
		}
	}

	/**
	 * Enable a sub interrupt.
	 * 
	 * @param intno - The sub interrupt to enable.
	 * @param no    - The sub interrupt handler number (0-15)
	 * 
	 * @return < 0 on error.
	 */
	int sceKernelEnableSubIntr(PspSubInterrupts intno, int no) {
		//cpu.interrupts.registerCallback(cast(Interrupts.Type)intno, handlers[intno][no]);
		//unimplemented();
		
		hleEmulatorState.callbacksHandler.register(
			convertPspSubInterruptsToCallbacksHandlerType(intno),
			handlers[intno][no]
		);

		unimplemented_notice();
		return 0;
	}

	/**
	 * Release a sub interrupt handler.
	 * 
	 * @param intno - The interrupt number to register.
	 * @param no    - The sub interrupt handler number (0-15)
	 *
	 * @return < 0 on error.
	 */
	int sceKernelReleaseSubIntrHandler(PspSubInterrupts intno, int no) {
		hleEmulatorState.callbacksHandler.unregister(
			convertPspSubInterruptsToCallbacksHandlerType(intno),
			handlers[intno][no]
		);

		//cpu.interrupts.unregisterCallback(cast(Interrupts.Type)intno, handlers[intno][no]);
		unimplemented_notice();
		return 0;
	}
	
	/**
	 * Queries the status of a sub interrupt handler.
	 * 
	 * @param intno         - The interrupt number to register.
	 * @param sub_intr_code - ?
	 * @param data          -
	 *
	 * @return < 0 on error.
	 */
	int sceKernelQueryIntrHandlerInfo(SceUID intno, SceUID sub_intr_code, PspIntrHandlerOptionParam* data) {
		unimplemented();
		return -1;
	}
}

static this() {
	mixin(ModuleNative.registerModule("InterruptManager"));
}