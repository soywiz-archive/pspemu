module pspemu.hle.kd.ge; // kd/ge.prx (sceGE_Manager)

import pspemu.hle.Module;

class sceGe_driver : Module {
	this() {
		mixin(register(0xE47E40E4, "sceGeEdramGetAddr"));
	}
	/*
	void sceGeEdramGetAddr() {
	}
	*/
}

class sceGe_user : sceGe_driver {
}

static this() {
	mixin(Module.registerModule("sceGe_driver"));
	mixin(Module.registerModule("sceGe_user"));
}