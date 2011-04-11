module pspemu.hle.kd.interruptman; // kd/interruptman.prx (sceInterruptManager):

//debug = DEBUG_SYSCALL;
//debug = DEBUG_CONTROLLER;

import pspemu.hle.Module;

import pspemu.core.cpu.Interrupts;
import pspemu.core.Memory;

import pspemu.utils.Utils;
import pspemu.hle.Utils;

// http://forums.ps2dev.org/viewtopic.php?t=5687

// @TODO! Fixme! In which thread should handlers be executed?

class InterruptManager : Module {
	void initNids() {
		mixin(registerd!(0xCA04A2B9, sceKernelRegisterSubIntrHandler));
		mixin(registerd!(0xFB8E22EC, sceKernelEnableSubIntr));
		mixin(registerd!(0xD61E6961, sceKernelReleaseSubIntrHandler));
		mixin(registerd!(0xD2E8363F, sceKernelQueryIntrHandlerInfo)); // QueryIntrHandlerInfo
		mixin(registerd!(0x36B1EF81, sceKernelQueryIntrHandlerInfo));
	}

	Interrupts.Callback[int][int] handlers;

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
	int sceKernelRegisterSubIntrHandler(int intno, int no, uint handler, uint arg) {
		handlers[intno][no] = createUserInterruptCallback(
			moduleManager, cpu,
			cast(Memory.Pointer)handler,
			[no, cast(uint)arg]
		);
		return 0;
	}

	/**
	 * Enable a sub interrupt.
	 * 
	 * @param intno - The sub interrupt to enable.
	 * @param no    - The sub interrupt handler number (0-15)
	 * 
	 * @return < 0 on error.
	 */
	int sceKernelEnableSubIntr(int intno, int no) {
		cpu.interrupts.registerCallback(cast(Interrupts.Type)intno, handlers[intno][no]);
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
	int sceKernelReleaseSubIntrHandler(int intno, int no) {
		cpu.interrupts.unregisterCallback(cast(Interrupts.Type)intno, handlers[intno][no]);
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
		unimplemented(); return -1;
	}
}

// Interrupts.Type
enum PspInterrupts {
	PSP_GPIO_INT      = 4,
	PSP_ATA_INT       = 5,
	PSP_UMD_INT       = 6,
	PSP_MSCM0_INT     = 7,
	PSP_WLAN_INT      = 8,
	PSP_AUDIO_INT     = 10,
	PSP_I2C_INT       = 12,
	PSP_SIRCS_INT     = 14,

	/**
	 * Calls to register or enable on these interrupts always yield 0x80020065 (illegal intr code),
	 * which seems plausible if they are system interrupts. QueryIntrHandlerInfo yields the following interesting information: 
	 */
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

	/**
	 * The vblank interrupt triggers every 1/60 second. Using the following function: 
	 *
	 *     int sceKernelRegisterSubIntrHandler(int intno, int no, void* handler, void* arg);
	 *
	 * up to 16 individual subinterrupt handlers may be installed for the vblank interrupt (intno = PSP_VBLANK_INT, no = 0 - 15).
	 * The prototype for vblank handler functions is: 
	 *
	 *     void vblank_handler(int no, void* arg);
	 */
	PSP_VBLANK_INT    = 30,
	PSP_MECODEC_INT   = 31,
	PSP_HPREMOTE_INT  = 36,
	PSP_MSCM1_INT     = 60,
	PSP_MSCM2_INT     = 61,
	PSP_THREAD1_INT   = 65,
	PSP_INTERRUPT_INT = 66,
}

enum PspSubInterrupts {
	PSP_GPIO_SUBINT     = PspInterrupts.PSP_GPIO_INT,
	PSP_ATA_SUBINT      = PspInterrupts.PSP_ATA_INT,
	PSP_UMD_SUBINT      = PspInterrupts.PSP_UMD_INT,
	PSP_DMACPLUS_SUBINT = PspInterrupts.PSP_DMACPLUS_INT,
	PSP_GE_SUBINT       = PspInterrupts.PSP_GE_INT,
	PSP_DISPLAY_SUBINT  = PspInterrupts.PSP_VBLANK_INT,
}

struct PspIntrHandlerOptionParam {
	int size;
	u32	entry;
	u32	common;
	u32	gp;
	u16	intr_code;
	u16	sub_count;
	u16	intr_level;
	u16	enabled;
	u32	calls;
	u32	field_1C;
	u32	total_clock_lo;
	u32	total_clock_hi;
	u32	min_clock_lo;
	u32	min_clock_hi;
	u32	max_clock_lo;
	u32	max_clock_hi;

	static assert (this.sizeof == 0x38);
}

static this() {
	mixin(Module.registerModule("InterruptManager"));
}