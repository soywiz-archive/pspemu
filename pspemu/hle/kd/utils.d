module pspemu.hle.kd.utils; // kd/utils.prx (sceKernelUtils)

//debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

import std.random;

class UtilsForUser : Module {
	this() {
		mixin(register(0xE860E75E, "sceKernelUtilsMt19937Init"));
		mixin(register(0x06FB8A63, "sceKernelUtilsMt19937UInt"));
	}

	void sceKernelUtilsMt19937Init() {
		// int 	sceKernelUtilsMt19937Init (SceKernelUtilsMt19937Context *ctx, u32 seed)
		auto mt = cast(std.random.Mt19937 *)param_p(0);
		mt.seed(param(1));
		debug (DEBUG_SYSCALL) .writefln("_sceKernelUtilsMt19937Init(ctx=0x%08X, seed=0x%08X)", param(0), param(1));
		cpu.registers.V0 = 0;
	}

	void sceKernelUtilsMt19937UInt() {
		auto mt = cast(std.random.Mt19937 *)param_p(0);
		// u32 	sceKernelUtilsMt19937UInt (SceKernelUtilsMt19937Context *ctx)
		cpu.registers.V0 = mt.front;
		mt.popFront();
		debug (DEBUG_SYSCALL) .writefln("_sceKernelUtilsMt19937UInt(ctx=0x%08X) == 0x%08X", param(0), cpu.registers.V0);
	}
}

class UtilsForKernel : UtilsForUser {
}

static this() {
	mixin(Module.registerModule("UtilsForUser"));
	mixin(Module.registerModule("UtilsForKernel"));
}