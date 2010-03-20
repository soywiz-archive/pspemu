module pspemu.hle.kd.utils; // kd/utils.prx (sceKernelUtils)

//debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

import std.random;
import std.c.time;

// BUG: Can't aliase directly std.random.Mt19937 because it's a template struct and currently it doesn't work with cast.
alias void SceKernelUtilsMt19937Context;

class UtilsForUser : Module {
	this() {
		mixin(registerd!(0x27CC57F0, sceKernelUtilsMt19937Init));
		mixin(registerd!(0x06FB8A63, sceKernelUtilsMt19937UInt));
		mixin(registerd!(0x27CC57F0, sceKernelLibcTime));
	}

	/** 
	 * Function to initialise a mersenne twister context.
	 *
	 * @param ctx - Pointer to a context
	 * @param seed - A seed for the random function.
	 *
	 * @par Example:
	 * @code
	 * SceKernelUtilsMt19937Context ctx;
	 * sceKernelUtilsMt19937Init(&ctx, time(NULL));
	 * u23 rand_val = sceKernelUtilsMt19937UInt(&ctx);
	 * @endcode
	 *
	 * @return < 0 on error.
	 */
	int sceKernelUtilsMt19937Init(SceKernelUtilsMt19937Context* ctx, uint seed) {
		if (ctx is null) return -1;
		(cast(std.random.Mt19937 *)ctx).seed(seed);
		return 0;
	}

	/**
	 * Function to return a new psuedo random number.
	 *
	 * @param ctx - Pointer to a pre-initialised context.
	 * @return A pseudo random number (between 0 and MAX_INT).
	 */
	u32 sceKernelUtilsMt19937UInt(SceKernelUtilsMt19937Context *ctx) {
		auto mt = cast(std.random.Mt19937 *)ctx;
		scope (exit) mt.popFront();
		return mt.front;
	}

	/**
	 * Get the time in seconds since the epoc (1st Jan 1970)
	 *
	 */
	time_t sceKernelLibcTime(time_t* t) { 
		return time(t);
	}
}

class UtilsForKernel : UtilsForUser {
}

static this() {
	mixin(Module.registerModule("UtilsForUser"));
	mixin(Module.registerModule("UtilsForKernel"));
}