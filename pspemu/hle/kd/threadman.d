module pspemu.hle.kd.threadman; // kd/threadman.prx (sceThreadManager)

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class ThreadManForUser : Module {
	this() {
		mixin(register(0xE81CAF8F, "sceKernelCreateCallback"));
		mixin(register(0x82826F70, "sceKernelSleepThreadCB"));
		mixin(register(0x446D8DE6, "sceKernelCreateThread"));
		mixin(register(0xF475845D, "sceKernelStartThread"));
		mixin(register(0xAA73C935, "sceKernelExitThread"));
		mixin(register(0x55C20A00, "sceKernelCreateEventFlag"));
		mixin(register(0x1FB15A32, "sceKernelSetEventFlag"));
	}

	void sceKernelCreateEventFlag() {
		// SceUID sceKernelCreateEventFlag( const char *name, int attr, int bits, SceKernelEventFlagOptParam *opt )
		cpu.registers.V0 = 0;
	}

	void sceKernelSleepThreadCB() {
		cpu.registers.V0 = 0;
		debug (DEBUG_SYSCALL) .writefln("sceKernelSleepThreadCB()");
		//while (true) std.c.windows.windows.Sleep(100);
	}
	
	void sceKernelExitThread() {
		cpu.registers.V0 = 0;
		debug (DEBUG_SYSCALL) .writefln("_sceKernelExitThread(status=%d) == %d", param(0), cpu.registers.V0);
	}

	void sceKernelCreateThread() {
		//cpu.registers.V0 = 9999;
		cpu.registers.V0 = param(1);
		debug (DEBUG_SYSCALL) .writefln("_sceKernelCreateThread(name='%s', entry=0x%08X, initPriority=%d, stackSize=%d, attr=0x%08X, option=0x%08X)", paramsz(0), param(1), param(2), param(3), param(4), param(5));
	}

	void sceKernelStartThread() {
		cpu.registers.V0 = 0;
		debug (DEBUG_SYSCALL) .writefln("_sceKernelStartThread(thid=0x%08X, arglen=%d, argp=0x%08X)", param(0), param(1), param(2));
		cpu.registers.pcSet(param(0));
		cpu.registers.A0 = 0;
		cpu.registers.A1 = 0;
	}
	
	void sceKernelCreateCallback() {
		debug (DEBUG_SYSCALL) .writefln("sceKernelCreateCallback(name='%s', func=0x%08X, arg=0x%08X)", paramsz(0), param(1), param(2));
	}
}

class ThreadManForKernel : ThreadManForUser {
}


static this() {
	mixin(Module.registerModule("ThreadManForUser"));
	mixin(Module.registerModule("ThreadManForKernel"));
}