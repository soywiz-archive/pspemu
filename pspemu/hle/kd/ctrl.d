module pspemu.hle.kd.ctrl; // kd/ctrl.prx (sceController_Service)

//debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class sceCtrl_driver : Module {
	this() {
		mixin(register(0x6A2774F3, "sceCtrlSetSamplingCycle"));
		mixin(register(0x1F4011E6, "sceCtrlSetSamplingMode"));
		mixin(register(0x1F803938, "sceCtrlReadBufferPositive"));
		mixin(register(0x3A622550, "sceCtrlPeekBufferPositive"));
	}

	void sceCtrlReadBufferPositive() {
		cpu.registers.V0 = 0x00000000;
		debug (DEBUG_SYSCALL) .writefln("sceCtrlReadBufferPositive()");
	}

	void sceCtrlPeekBufferPositive() {
		cpu.registers.V0 = 0xFFFFFFFF;
		debug (DEBUG_SYSCALL) .writefln("sceCtrlPeekBufferPositive()");
	}

	void sceCtrlSetSamplingCycle() {
		cpu.registers.V0 = 0;
		debug (DEBUG_SYSCALL) .writefln("sceCtrlSetSamplingCycle()");
	}

	void sceCtrlSetSamplingMode() {
		cpu.registers.V0 = 0;
		debug (DEBUG_SYSCALL) .writefln("sceCtrlSetSamplingMode()");
	}
}

class sceCtrl : sceCtrl_driver {
}

static this() {
	mixin(Module.registerModule("sceCtrl"));
	mixin(Module.registerModule("sceCtrl_driver"));
}