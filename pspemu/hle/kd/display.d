module pspemu.hle.kd.display; // kd/display.prx (sceDisplay_Service)

//debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class sceDisplay_driver : Module { // Flags: 0x00010000
	this() {
		mixin(register(0x0E20F177, "sceDisplaySetMode"));
		mixin(register(0x289D82FE, "sceDisplaySetFrameBuf"));
		mixin(register(0x984C27E7, "sceDisplayWaitVblankStart"));
	}

	void sceDisplayWaitVblankStart() {
		cpu.registers.V0 = 0;
		debug (DEBUG_SYSCALL) .writefln("_sceDisplayWaitVblankStart");
	}

	void sceDisplaySetFrameBuf() {
		// int 	sceDisplaySetFrameBuf (void *topaddr, int bufferwidth, int pixelformat, int sync)
		cpu.memory.displayMemory = param(0);
		cpu.registers.V0 = 0;
		debug (DEBUG_SYSCALL) .writefln("_sceDisplaySetFrameBuf (0x%08X, %d, %d, 0x%08X)", param(0), param(1), param(2), param(3));
	}

	void sceDisplaySetMode() {
		// int 	sceDisplaySetMode (int mode, int width, int height)
		cpu.registers.V0 = 0;
		debug (DEBUG_SYSCALL) .writefln("_sceDisplaySetMode (mode=%d, width=%d, height=%d)", param(0), param(1), param(2));
	}
}

class sceDisplay : sceDisplay_driver { // Flags: 0x40010000
}

static this() {
	mixin(Module.registerModule("sceDisplay"));
	mixin(Module.registerModule("sceDisplay_driver"));
}