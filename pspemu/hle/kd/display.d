module pspemu.hle.kd.display; // kd/display.prx (sceDisplay_Service)

//debug = DEBUG_SYSCALL;

import core.thread;
import std.c.windows.windows;

import pspemu.hle.Module;

import pspemu.models.IDisplay;

class sceDisplay_driver : Module { // Flags: 0x00010000
	void initNids() {
		mixin(registerd!(0x0E20F177, sceDisplaySetMode));
		mixin(registerd!(0x289D82FE, sceDisplaySetFrameBuf));
		mixin(registerd!(0x984C27E7, sceDisplayWaitVblankStart));
		mixin(registerd!(0x9C6EAAD7, sceDisplayGetVcount));
	}

	/**
	 * Number of vertical blank pulses up to now
	 */
	uint sceDisplayGetVcount() {
		unimplemented();
		return 0;
	}

	/**
	 * Wait for vertical blank start
	 */
	int sceDisplayWaitVblankStart() {
		cpu.display.waitVblank();
		return 0;
	}

	/**
	 * Display set framebuf
	 *
	 * @param topaddr - address of start of framebuffer
	 * @param bufferwidth - buffer width (must be power of 2)
	 * @param pixelformat - One of ::PspDisplayPixelFormats.
	 * @param sync - One of ::PspDisplaySetBufSync
	 *
	 * @return 0 on success
	 */
	int sceDisplaySetFrameBuf(uint topaddr, int bufferwidth, int pixelformat, int sync) {
		cpu.display.info = IDisplay.Info(topaddr, bufferwidth, pixelformat, sync);
		return 0;
	}

	/**
	 * Set display mode
	 *
	 * @par Example1:
	 * @code
	 * @endcode
	 *
	 * @param mode - Display mode, normally 0.
	 * @param width - Width of screen in pixels.
	 * @param height - Height of screen in pixels.
	 *
	 * @return ???
	 */
	int sceDisplaySetMode(int mode, int width, int height) {
		with (cpu.display) {
			info.mode   = mode;
			info.width  = width;
			info.height = height;
		}
		return 0;
	}
}

class sceDisplay : sceDisplay_driver { // Flags: 0x40010000
}

static this() {
	mixin(Module.registerModule("sceDisplay"));
	mixin(Module.registerModule("sceDisplay_driver"));
}