module pspemu.hle.kd.interruptman; // kd/interruptman.prx (sceInterruptManager):

debug = DEBUG_SYSCALL;
//debug = DEBUG_CONTROLLER;

import pspemu.hle.Module;

import pspemu.utils.Utils;

class InterruptManager : Module {
	void initNids() {
		mixin(registerd!(0xCA04A2B9, sceKernelRegisterSubIntrHandler));
		mixin(registerd!(0xFB8E22EC, sceKernelEnableSubIntr));
	}

	/** 
	 * Register a sub interrupt handler.
	 * 
	 * @param intno - The interrupt number to register.
	 * @param no - The sub interrupt handler number (user controlled)
	 * @param handler - The interrupt handler
	 * @param arg - An argument passed to the interrupt handler
	 *
	 * @return < 0 on error.
	 */
	int sceKernelRegisterSubIntrHandler(int intno, int no, void *handler, void *arg) {
		unimplemented();
		return -1;
	}

	/**
	 * Enable a sub interrupt.
	 * 
	 * @param intno - The sub interrupt to enable.
	 * @param no - The sub interrupt handler number
	 * 
	 * @return < 0 on error.
	 */
	int sceKernelEnableSubIntr(int intno, int no) {
		unimplemented();
		return -1;
	}
}

enum PspInterrupts {
	PSP_GPIO_INT = 4,
	PSP_ATA_INT  = 5,
	PSP_UMD_INT  = 6,
	PSP_MSCM0_INT = 7,
	PSP_WLAN_INT  = 8,
	PSP_AUDIO_INT = 10,
	PSP_I2C_INT   = 12,
	PSP_SIRCS_INT = 14,
	PSP_SYSTIMER0_INT = 15,
	PSP_SYSTIMER1_INT = 16,
	PSP_SYSTIMER2_INT = 17,
	PSP_SYSTIMER3_INT = 18,
	PSP_THREAD0_INT   = 19,
	PSP_NAND_INT      = 20,
	PSP_DMACPLUS_INT  = 21,
	PSP_DMA0_INT      = 22,
	PSP_DMA1_INT      = 23,
	PSP_MEMLMD_INT    = 24,
	PSP_GE_INT        = 25,
	PSP_VBLANK_INT = 30,
	PSP_MECODEC_INT  = 31,
	PSP_HPREMOTE_INT = 36,
	PSP_MSCM1_INT    = 60,
	PSP_MSCM2_INT    = 61,
	PSP_THREAD1_INT  = 65,
	PSP_INTERRUPT_INT = 66,
}

enum PspSubInterrupts {
	PSP_GPIO_SUBINT = PspInterrupts.PSP_GPIO_INT,
	PSP_ATA_SUBINT  = PspInterrupts.PSP_ATA_INT,
	PSP_UMD_SUBINT  = PspInterrupts.PSP_UMD_INT,
	PSP_DMACPLUS_SUBINT = PspInterrupts.PSP_DMACPLUS_INT,
	PSP_GE_SUBINT = PspInterrupts.PSP_GE_INT,
	PSP_DISPLAY_SUBINT = PspInterrupts.PSP_VBLANK_INT,
}

static this() {
	mixin(Module.registerModule("InterruptManager"));
}