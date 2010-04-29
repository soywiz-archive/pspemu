module pspemu.hle.kd.ctrl; // kd/ctrl.prx (sceController_Service)

//debug = DEBUG_SYSCALL;
//debug = DEBUG_CONTROLLER;

import pspemu.hle.Module;

import pspemu.models.IController;
import pspemu.utils.Utils;

// http://forums.qj.net/psp-development-forum/141207-using-analog-stick-c-question.html

class sceCtrl_driver : Module {
	void initNids() {
		mixin(registerd!(0x6A2774F3, sceCtrlSetSamplingCycle));
		mixin(registerd!(0x1F4011E6, sceCtrlSetSamplingMode));
		mixin(registerd!(0x1F803938, sceCtrlReadBufferPositive));
		mixin(registerd!(0x3A622550, sceCtrlPeekBufferPositive));
		mixin(registerd!(0x0B588501, sceCtrlReadLatch));
		mixin(registerd!(0xA7144800, sceCtrlSetIdleCancelThresholdFunction));
	}

	void readBufferedFrames(SceCtrlData* pad_data, int count = 1, bool positive = true) {
		for (int n = 0; n < count; n++) {
			pad_data[n] = cpu.controller.frameRead(n);

			debug (DEBUG_CONTROLLER) {
				writefln("readBufferedFrames: %s", pad_data[n]);
			}

			// Negate.
			if (!positive) pad_data[n].Buttons = ~pad_data[n].Buttons;
		}
	}

	/**
	 * Read buffer positive
	 *
	 * @par Example:
	 * <code>
	 *     SceCtrlData pad;
	 *
	 *     sceCtrlSetSamplingCycle(0);
	 *     sceCtrlSetSamplingMode(1);
	 *     sceCtrlReadBufferPositive(&pad, 1);
	 *     // Do something with the read controller data
	 * </code>
	 *
	 * @param pad_data - Pointer to a ::SceCtrlData structure used hold the returned pad data.
	 * @param count    - Number of ::SceCtrlData buffers to read.
	 *
	 * @return Count?
	 */
	// sceCtrlReadBufferPositive () is blocking and waits for vblank (slower).
	int sceCtrlReadBufferPositive(SceCtrlData* pad_data, int count) {
		readBufferedFrames(pad_data, count, true);
		// @TODO: Wait for vblank.
		return count;
	}

	// sceCtrlPeekBufferPositive () is non-blocking (faster)
	int sceCtrlPeekBufferPositive(SceCtrlData* pad_data, int count) {
		readBufferedFrames(pad_data, count, true);
		return count;
	}

	/**
	 * Set the controller cycle setting.
	 *
	 * @param cycle - Cycle. Normally set to 0.
	 *
	 * @TODO Unknown what this means exactly.
	 *
	 * @return The previous cycle setting.
	 */
	int sceCtrlSetSamplingCycle(int cycle) {
		int previousCycle = cpu.controller.samplingCycle;
		cpu.controller.samplingCycle = cycle;
		if (cycle != 0) writefln("sceCtrlSetSamplingCycle != 0! :: %d", cycle);
		return previousCycle;
	}

	/**
	 * Set the controller mode.
	 *
	 * @param mode - One of ::PspCtrlMode.
	 *             - PSP_CTRL_MODE_DIGITAL = 0
	 *             - PSP_CTRL_MODE_ANALOG  = 1
	 *
	 * PSP_CTRL_MODE_DIGITAL is the same as PSP_CTRL_MODE_ANALOG
	 * except that doesn't update Lx and Ly values. Setting them to 0x80.
	 *
	 * @return The previous mode.
	 */
	int sceCtrlSetSamplingMode(int mode) {
		uint previouseMode = cast(int)cpu.controller.samplingMode;
		cpu.controller.samplingMode = cast(Controller.Mode)mode;
		return previouseMode;
	}
	
	SceCtrlLatch lastLatch;
	
	/**
	 * Obtains information about 
	 *
	 * @param currentLatch - Pointer to SceCtrlLatch to store the result.
	 *
	 * @return 
	 */
	int sceCtrlReadLatch(SceCtrlLatch* currentLatch) {
		SceCtrlData pad;
		readBufferedFrames(&pad, 1, true);
		
		currentLatch.uiPress   = cast(PspCtrlButtons)pad.Buttons;
		currentLatch.uiRelease = cast(PspCtrlButtons)~pad.Buttons;
		currentLatch.uiMake    = (lastLatch.uiRelease ^ currentLatch.uiRelease) & lastLatch.uiRelease;
		currentLatch.uiBreak   = (lastLatch.uiPress   ^ currentLatch.uiPress  ) & lastLatch.uiPress;

		//unimplemented_notice();
		lastLatch = *currentLatch;

		return 0;
	}

	void sceCtrlSetIdleCancelThresholdFunction() {
		unimplemented();
	}
}

class sceCtrl : sceCtrl_driver {
}

/**
 * Enumeration for the digital controller buttons.
 *
 * @note PSP_CTRL_HOME, PSP_CTRL_NOTE, PSP_CTRL_SCREEN, PSP_CTRL_VOLUP, PSP_CTRL_VOLDOWN, PSP_CTRL_DISC, PSP_CTRL_WLAN_UP, PSP_CTRL_REMOTE, PSP_CTRL_MS can only be read in kernel mode
 */
enum PspCtrlButtons { // Set
	PSP_CTRL_NONE      = 0x_0000000,
	PSP_CTRL_SELECT    = 0x_0000001, /// Select button.
	PSP_CTRL_START     = 0x_0000008, /// Start button.
	PSP_CTRL_UP        = 0x_0000010, /// Up D-Pad button.
	PSP_CTRL_RIGHT     = 0x_0000020, /// Right D-Pad button.
	PSP_CTRL_DOWN      = 0x_0000040, /// Down D-Pad button.
	PSP_CTRL_LEFT      = 0x_0000080, /// Left D-Pad button.
	PSP_CTRL_LTRIGGER  = 0x_0000100, /// Left trigger.
	PSP_CTRL_RTRIGGER  = 0x_0000200, /// Right trigger.
	PSP_CTRL_TRIANGLE  = 0x_0001000, /// Triangle button.
	PSP_CTRL_CIRCLE    = 0x_0002000, /// Circle button.
	PSP_CTRL_CROSS     = 0x_0004000, /// Cross button.
	PSP_CTRL_SQUARE    = 0x_0008000, /// Square button.
	PSP_CTRL_HOME      = 0x_0010000, /// Home button. In user mode this bit is set if the exit dialog is visible.
	PSP_CTRL_HOLD      = 0x_0020000, /// Hold button.
	PSP_CTRL_WLAN_UP   = 0x_0040000, /// Wlan switch up.
	PSP_CTRL_REMOTE    = 0x_0080000, /// Remote hold position.
	PSP_CTRL_VOLUP     = 0x_0100000, /// Volume up button.
	PSP_CTRL_VOLDOWN   = 0x_0200000, /// Volume down button.
	PSP_CTRL_SCREEN    = 0x_0400000, /// Screen button.
	PSP_CTRL_NOTE      = 0x_0800000, /// Music Note button.
	PSP_CTRL_DISC      = 0x_1000000, /// Disc present.
	PSP_CTRL_MS        = 0x_2000000, /// Memory stick present.
}

/**
 * Controller mode.
 */
enum PspCtrlMode {
	PSP_CTRL_MODE_DIGITAL = 0, /// Digitial.
	PSP_CTRL_MODE_ANALOG  = 1, /// Analog.
}

/**
 * Controller latch.
 */
struct SceCtrlLatch {
	PspCtrlButtons uiMake;    /// A bit fields of buttons just pressed (since last call?)
	PspCtrlButtons uiBreak;   /// A bit fields of buttons just released (since last call?)
	PspCtrlButtons uiPress;   /// Same has SceCtrlData.Buttons?
	PspCtrlButtons uiRelease; /// A bit field of buttons released 
}

/+
/** Returned controller data */
struct SceCtrlData {
	uint 	TimeStamp; /// The current read frame.
	uint 	Buttons;   /// Bit mask containing zero or more of ::PspCtrlButtons.
	ubyte 	Lx;        /// Analogue stick, X axis.
	ubyte 	Ly;        /// Analogue stick, Y axis.
	ubyte 	Rsrv[6];   /// Reserved.

	static assert(this.sizeof == 16);
}
+/

static this() {
	mixin(Module.registerModule("sceCtrl"));
	mixin(Module.registerModule("sceCtrl_driver"));
}