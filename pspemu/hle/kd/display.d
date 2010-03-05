module pspemu.hle.kd.display; // kd/display.prx (sceDisplay_Service)

import pspemu.hle.Module;

class sceDisplay_driver : Module { // Flags: 0x00010000
	this() {
		mixin(register(0x0E20F177, "sceDisplaySetMode"));
		mixin(register(0x289D82FE, "sceDisplaySetFrameBuf"));
	}

	/*
	void sceDisplaySetMode() {
	}

	void sceDisplaySetFrameBuf() {
	}
	*/
}

class sceDisplay : sceDisplay_driver { // Flags: 0x40010000
}

static this() {
	mixin(Module.registerModule("sceDisplay"));
	mixin(Module.registerModule("sceDisplay_driver"));
}