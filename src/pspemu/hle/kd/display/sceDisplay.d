module pspemu.hle.kd.display.sceDisplay; // kd/display.prx (sceDisplay_Service)

import pspemu.core.cpu.CpuThreadBase;

import core.thread;
import std.c.windows.windows;

import pspemu.hle.Module;
import pspemu.hle.ModuleNative;

//debug = DEBUG_SYSCALL;

import pspemu.core.cpu.CpuThreadBase;

//import core.thread;
import std.stdio;
import std.c.windows.windows;

import pspemu.hle.Module;
import pspemu.hle.ModuleNative;

import pspemu.hle.kd.display.Types;

import pspemu.hle.HleFunction;

class sceDisplay_driver : ModuleNative { // Flags: 0x00010000
	void initNids() {
		mixin(HleFunction.registerNids);
	}
	
	/* @ */ mixin(HleFunction(NID(0x7ED59BC4), MIN_FW(150)));
	int sceDisplaySetHoldMode() {
		unimplemented_notice();
		return 0;
	}

	// http://forums.ps2dev.org/viewtopic.php?t=9168
	/* @ */ mixin(HleFunction(NID(0xDBA6C4C4), MIN_FW(150)));
	float sceDisplayGetFramePerSec() {
		// (pixel_clk_freq * cycles_per_pixel)/(row_pixels * column_pixel)
		return 9_000_000f * 1 / (525 * 286);
	}

	/**
	 * Get accumlated HSYNC count
	 */
	/* @ */ mixin(HleFunction(NID(0x210EAB3A), MIN_FW(150)));
	int sceDisplayGetAccumulatedHcount() {
		unimplemented();
		return 0;
	}

	void processCallbacks() {
		// @TODO
	}

	/**
	 * Get current HSYNC count
	 */
	/* @ */ mixin(HleFunction(NID(0x773DD3A3), MIN_FW(150)));
	int sceDisplayGetCurrentHcount() {
		return hleEmulatorState.emulatorState.display.CURRENT_HCOUNT;
	}

	/**
	 * Number of vertical blank pulses up to now
	 */
	/* @ */ mixin(HleFunction(NID(0x9C6EAAD7), MIN_FW(150)));
	uint sceDisplayGetVcount() {
		return currentEmulatorState.display.VBLANK_COUNT;
	}
	
	int _sceDisplayWaitVblankStart(bool _processCallbacks) {
		Logger.log(Logger.Level.TRACE, "sceDisplay_driver", "_sceDisplayWaitVblankStart");
		currentEmulatorState.display.waitVblank(_processCallbacks);
		hleEmulatorState.emulatorState.gpu.waitVblank();
		
		return 0;

		/*
		cpu.display.fpsCounter++;
		if (!cpu.display.frameLimiting) return 0;
		
		auto threadManForUser = moduleManager.get!(ThreadManForUser);
		PspThread waitingThread = threadManForUser.threadManager.currentThread;
		cpu.interrupts.registerCallbackSingle(Interrupts.Type.VBLANK, {
			waitingThread.resumeAndReturn(0);
		});

		if (_processCallbacks) {
			return threadManForUser.threadManager.currentThread.pauseAndYield("sceDisplayWaitVblankStart", (PspThread pausedThread) {
				processCallbacks();
			});
		} else {
			return threadManForUser.threadManager.currentThread.pauseAndYield("sceDisplayWaitVblankStart");
		}
		*/
	}

	/**
	 * Wait for vertical blank start
	 */
	/* @ */ mixin(HleFunction(NID(0x984C27E7), MIN_FW(150)));
	int sceDisplayWaitVblankStart() {
		return _sceDisplayWaitVblankStart(false);
	}

	/**
	 * Wait for vertical blank start with callback
	 */
	/* @ */ mixin(HleFunction(NID(0x46F186C3), MIN_FW(150)));
	int sceDisplayWaitVblankStartCB() {
		return _sceDisplayWaitVblankStart(true);
	}

	/**
	 * Wait for vertical blank with callback
	 */
	/* @ */ mixin(HleFunction(NID(0x8EB9EC49), MIN_FW(150)));
	int sceDisplayWaitVblankCB() {
		// @TODO: Fixme!
		//unimplemented_notice();
		return sceDisplayWaitVblankStartCB();
	}

	/**
	 * Wait for vertical blank
	 */
	/* @ */ mixin(HleFunction(NID(0x36CDFADE), MIN_FW(150)));
	int sceDisplayWaitVblank() {
		// @TODO: Fixme!
		//unimplemented_notice();
		return sceDisplayWaitVblankStart();
	}

	/**
	 * Turn display on or off
	 *
	 * Available states are:
	 *   - GU_TRUE (1) - Turns display on
	 *   - GU_FALSE (0) - Turns display off
	 *
	 * @param state - Turn display on or off
	 * @return State of the display prior to this call
	**/
	// sceDisplaySetFrameBuf(0, 0, 0, PSP_DISPLAY_SETBUF_NEXTFRAME);

	/**
	 * Display set framebuf
	 *
	 * @param topaddr     - address of start of framebuffer
	 * @param bufferwidth - buffer width (must be power of 2)
	 * @param pixelformat - One of ::PspDisplayPixelFormats.
	 * @param sync        - One of ::PspDisplaySetBufSync
	 *
	 * @return 0 on success
	 */
	/* @ */ mixin(HleFunction(NID(0x289D82FE), MIN_FW(150)));
	int sceDisplaySetFrameBuf(uint topaddr, int bufferwidth, PspDisplayPixelFormats pixelformat, PspDisplaySetBufSync sync) {
		Logger.log(Logger.Level.TRACE, "sceDisplay_driver", "sceDisplaySetFrameBuf");
		currentEmulatorState.display.sceDisplaySetFrameBuf(topaddr, bufferwidth, pixelformat, sync);
		return 0;
	}

	/**
	 * Get Display Framebuffer information
	 *
	 * @param topaddr     - pointer to void* to receive address of start of framebuffer
	 * @param bufferwidth - pointer to int to receive buffer width (must be power of 2)
	 * @param pixelformat - pointer to int to receive one of ::PspDisplayPixelFormats.
	 * @param sync        - One of ::PspDisplaySetBufSync
	 *
	 * @return 0 on success
	 */
	/* @ */ mixin(HleFunction(NID(0xEEDA2E54), MIN_FW(150)));
	int sceDisplayGetFrameBuf(uint* topaddr, int* bufferwidth, PspDisplayPixelFormats* pixelformat, PspDisplaySetBufSync sync) {
		Logger.log(Logger.Level.TRACE, "sceDisplay_driver", "sceDisplayGetFrameBuf");
		*topaddr     = currentEmulatorState.display.topaddr;
		*bufferwidth = currentEmulatorState.display.bufferwidth;
		*pixelformat = currentEmulatorState.display.pixelformat;
		return 0;
	}

	/**
	 * Set display mode
	 *
	 * @par Example1:
	 * @code
	 * @endcode
	 *
	 * @param mode   - Display mode, normally 0.
	 * @param width  - Width of screen in pixels.
	 * @param height - Height of screen in pixels.
	 *
	 * @return ???
	 */
	/* @ */ mixin(HleFunction(NID(0x0E20F177), MIN_FW(150)));
	int sceDisplaySetMode(int mode, int width, int height) {
		Logger.log(Logger.Level.TRACE, "sceDisplay_driver", "sceDisplaySetMode");
		currentEmulatorState.display.mode   = mode;
		currentEmulatorState.display.width  = width;
		currentEmulatorState.display.height = height;
		return 0;
	}

	/**
	 * Get display mode
	 *
	 * @param pmode   - Pointer to an integer to receive the current mode.
	 * @param pwidth  - Pointer to an integer to receive the current width.
	 * @param pheight - Pointer to an integer to receive the current height,
	 * 
	 * @return 0 on success
	 */
	/* @ */ mixin(HleFunction(NID(0xDEA197D4), MIN_FW(150)));
	int sceDisplayGetMode(int* pmode, int* pwidth, int* pheight) {
		Logger.log(Logger.Level.TRACE, "sceDisplay_driver", "sceDisplayGetMode");
		*pmode   = currentEmulatorState.display.mode;
		*pwidth  = currentEmulatorState.display.width;
		*pheight = currentEmulatorState.display.height;
		return 0;
	}
}

class sceDisplay : sceDisplay_driver { // Flags: 0x40010000
}

static this() {
	mixin(ModuleNative.registerModule("sceDisplay"));
	mixin(ModuleNative.registerModule("sceDisplay_driver"));
}
