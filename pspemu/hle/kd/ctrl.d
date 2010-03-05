module pspemu.hle.kd.ctrl; // kd/ctrl.prx (sceController_Service)

import pspemu.hle.Module;

class sceCtrl_driver : Module {
	this() {
		mixin(register(0x6A2774F3, "sceCtrlSetSamplingCycle"));
		mixin(register(0x1F4011E6, "sceCtrlSetSamplingMode"));
		mixin(register(0x1F803938, "sceCtrlReadBufferPositive"));
	}
}

class sceCtrl : sceCtrl_driver {
	/*
	void sceCtrlSetSamplingCycle() {
	}

	void sceCtrlSetSamplingMode() {
	}
	*/
}

static this() {
	mixin(Module.registerModule("sceCtrl"));
	mixin(Module.registerModule("sceCtrl_driver"));
}