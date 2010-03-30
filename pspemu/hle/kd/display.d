module pspemu.hle.kd.display; // kd/display.prx (sceDisplay_Service)

//debug = DEBUG_SYSCALL;

import core.thread;
import std.c.windows.windows;

import pspemu.hle.Module;

import pspemu.models.IDisplay;
import pspemu.core.cpu.Interrupts;

import pspemu.hle.kd.threadman;

class sceDisplay_driver : Module { // Flags: 0x00010000
	void initNids() {
		mixin(registerd!(0x0E20F177, sceDisplaySetMode));
		mixin(registerd!(0x289D82FE, sceDisplaySetFrameBuf));
		mixin(registerd!(0xEEDA2E54, sceDisplayGetFrameBuf));
		mixin(registerd!(0x9C6EAAD7, sceDisplayGetVcount));
		mixin(registerd!(0x984C27E7, sceDisplayWaitVblankStart));
		mixin(registerd!(0x8EB9EC49, sceDisplayWaitVblankCB));
		mixin(registerd!(0x36CDFADE, sceDisplayWaitVblank));
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
		cpu.display.fpsCounter++;
		if (!cpu.display.frameLimiting) return 0;
		
		auto threadManForUser = moduleManager.get!(ThreadManForUser);
		PspThread waitingThread = threadManForUser.threadManager.currentThread;
		cpu.interrupts.registerCallbackSingle(Interrupts.Type.VBLANK, {
			waitingThread.resumeAndReturn(0);
		});

		return threadManForUser.threadManager.currentThread.pauseAndYield("sceDisplayWaitVblankStart");
	}

	/**
	 * Wait for vertical blank with callback
	 */
	int sceDisplayWaitVblankCB() {
		return sceDisplayWaitVblankStart();
		/*bool vblank = false;

		void changeVblank() {
			vblank = true;
			cpu.interrupts.unregisterCallback(Interrupts.Type.VBLANK, &changeVblank);
		}

		cpu.interrupts.registerCallback(Interrupts.Type.VBLANK, &changeVblank);
	
		return threadManForUser.threadManager.currentThread.pauseAndYield("sceDisplayWaitVblankStart", (PspThread pausedThread) {
			if (vblank) {
				pausedThread.resumeAndReturn(0);
			}
		});*/
	}

	/**
	 * Wait for vertical blank
	 */
	int sceDisplayWaitVblank() {
		unimplemented();
		return sceDisplayWaitVblankStart();
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
		cpu.display.info = Display.Info(topaddr, bufferwidth, pixelformat, sync);
		return 0;
	}

	/**
	 * Get Display Framebuffer information
	 *
	 * @param topaddr - pointer to void* to receive address of start of framebuffer
	 * @param bufferwidth - pointer to int to receive buffer width (must be power of 2)
	 * @param pixelformat - pointer to int to receive one of ::PspDisplayPixelFormats.
	 * @param sync - One of ::PspDisplaySetBufSync
	 *
	 * @return 0 on success
	 */
	int sceDisplayGetFrameBuf(uint* topaddr, int* bufferwidth, int* pixelformat, int sync) {
		*topaddr     = cpu.display.info.topaddr;
		*bufferwidth = cpu.display.info.bufferwidth;
		*pixelformat = cpu.display.info.pixelformat;
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