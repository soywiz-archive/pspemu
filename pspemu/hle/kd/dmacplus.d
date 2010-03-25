module pspemu.hle.kd.dmacplus; // kd/dmacplus.prx (sceDMACPLUS_Driver)

import pspemu.hle.Module;

class sceDmac : Module {
	void initNids() {
		mixin(registerd!(0x617F3FE6, sceDmacMemcpy));
		mixin(registerd!(0xD97F94D8, sceDmacTryMemcpy));
	}

	// @TODO: Unknown prototype
	void sceDmacMemcpy() {
		unimplemented();
	}

	// @TODO: Unknown prototype
	void sceDmacTryMemcpy() {
		unimplemented();
	}
}

static this() {
	mixin(Module.registerModule("sceDmac"));
}
