module pspemu.hle.kd.impose; // kd/impose.prx (sceImpose_Driver):

import pspemu.hle.Module;

class sceImpose : Module {
	void initNids() {
		mixin(registerd!(0x8C943191, sceImposeGetBatteryIconStatusFunction));
	}

	// @TODO: Unknown.
	void sceImposeGetBatteryIconStatusFunction() {
		unimplemented();
	}
}

static this() {
	mixin(Module.registerModule("sceImpose"));
}