module pspemu.hle.kd.utils; // kd/utils.prx (sceKernelUtils)

//debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

import std.random;
import std.c.time;
import std.c.stdio;
import std.c.stdlib;
import std.c.time;

// BUG: Can't aliase directly std.random.Mt19937 because it's a template struct and currently it doesn't work with cast.
alias void SceKernelUtilsMt19937Context;

class UtilsForUser : Module {
	void initNids() {
		mixin(registerd!(0x27CC57F0, sceKernelUtilsMt19937Init));
		mixin(registerd!(0x06FB8A63, sceKernelUtilsMt19937UInt));
		mixin(registerd!(0x27CC57F0, sceKernelLibcTime));
		mixin(registerd!(0x71EC4271, sceKernelLibcGettimeofday));
		mixin(registerd!(0x79D1C3FA, sceKernelDcacheWritebackAll));
		mixin(registerd!(0xBFA98062, sceKernelDcacheInvalidateRange));
		mixin(registerd!(0x34B9FA9E, sceKernelDcacheWritebackInvalidateRange));
	}

	/** 
	 * Write back the data cache to memory
	 */
	void sceKernelDcacheWritebackAll() {
		// http://hitmen.c02.at/files/yapspd/psp_doc/chap4.html#sec4.10
		// Unimplemented cache.
	}

	/**
	 * Invalidate a range of addresses in data cache
	 */
	void sceKernelDcacheInvalidateRange(const void* p, uint size) {
		// Unimplemented cache.	
	}

	/**
	 * Write back and invalidate a range of addresses in data cache
	 */
	void sceKernelDcacheWritebackInvalidateRange(const void *p, uint size) {
		// Unimplemented cache.	
	}

	/** 
	 * Get the current time of time and time zone information
	 */
	int sceKernelLibcGettimeofday(timeval* tp, timezone* tzp) {
		uint ctime = time(null);

		if (tp !is null) {
			tp.tv_sec  = ctime;
			tp.tv_usec = 0; // @TODO
		}

		if (tzp !is null) {
			// @TODO
		}

		return ctime;
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
	u32 sceKernelUtilsMt19937UInt(SceKernelUtilsMt19937Context* ctx) {
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

struct timeval {
	uint tv_sec;
	uint tv_usec;
}

struct timezone {
	int tz_minuteswest;
	int tz_dsttime;
}

static this() {
	mixin(Module.registerModule("UtilsForUser"));
	mixin(Module.registerModule("UtilsForKernel"));
}