module pspemu.hle.kd.utils.UtilsForKernel; // kd/utils.prx (sceKernelUtils)

//debug = DEBUG_SYSCALL;

import pspemu.hle.ModuleNative;

//debug = DEBUG_SYSCALL;

import pspemu.core.cpu.CpuThreadBase;

import pspemu.hle.Module;
import pspemu.hle.ModuleNative;

import pspemu.hle.kd.Types;

import std.random;
import std.c.time;
import std.c.stdio;
import std.c.stdlib;
import std.c.time;
import std.md5;
import std.c.windows.windows;

import std.datetime;
import core.time;

public import pspemu.hle.kd.utils.Types;

class UtilsForUser : HleModuleHost {
	mixin TRegisterModule;

	void initNids() {
		mixin(registerFunction!(0x27CC57F0, sceKernelUtilsMt19937Init));
		mixin(registerFunction!(0xE860E75E, sceKernelUtilsMt19937Init));
		mixin(registerFunction!(0x06FB8A63, sceKernelUtilsMt19937UInt));
		mixin(registerFunction!(0x27CC57F0, sceKernelLibcTime));
		mixin(registerFunction!(0x71EC4271, sceKernelLibcGettimeofday));
		mixin(registerFunction!(0x79D1C3FA, sceKernelDcacheWritebackAll));
		mixin(registerFunction!(0xBFA98062, sceKernelDcacheInvalidateRange));
		mixin(registerFunction!(0x34B9FA9E, sceKernelDcacheWritebackInvalidateRange));
		mixin(registerFunction!(0xB435DEC5, sceKernelDcacheWritebackInvalidateAll));
		mixin(registerFunction!(0x3EE30821, sceKernelDcacheWritebackRange));
		mixin(registerFunction!(0x91E4F6A7, sceKernelLibcClock));
		mixin(registerFunction!(0xC8186A58, sceKernelUtilsMd5Digest));
		mixin(registerFunction!(0x840259F1, sceKernelUtilsSha1Digest));
		mixin(registerFunction!(0x920F104A, sceKernelIcacheInvalidateAll));
		mixin(registerFunction!(0xC2DF770E, sceKernelIcacheInvalidateRange));
		
	    mixin(registerFunction!(0x6AD345D7, sceKernelSetGPO));
	    mixin(registerFunction!(0x37FB5C42, sceKernelGetGPI));
	}
	
	int sceKernelSetGPO(int value) {
		logWarning("sceKernelSetGPO(%d)", value);
		return 0;
	}

	int sceKernelGetGPI() {
		logWarning("sceKernelGetGPI()");
		return 0;
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
	void sceKernelDcacheInvalidateRange(/*const*/ void* p, uint size) {
		// Unimplemented cache.	
	}

	/**
	 * Write back and invalidate a range of addresses in data cache
	 */
	void sceKernelDcacheWritebackInvalidateRange(/*const*/ void* p, uint size) {
		// Unimplemented cache.
	}

	/**
	 * Write back a range of addresses from data cache to memory
	 */
	void sceKernelDcacheWritebackRange(/*const*/ void* p, uint size) {
		// Unimplemented cache.
	}

	/**
	 * Write back and invalidate the data cache
	 */
	void sceKernelDcacheWritebackInvalidateAll() {
		// Unimplemented cache.
	}

	/** 
	 * Get the current time of time and time zone information
	 */
	int sceKernelLibcGettimeofday(timeval* tp, timezone* tzp) {
		// Used in: SDL/src/timer/psp/SDL_systimer.c
	
		if (tp !is null) {
			//auto ms = GetTickCount64();
			auto ms = GetTickCount();
			tp.tv_sec  = cast(uint)(ms / 1000);
			tp.tv_usec = cast(uint)((ms % 1000) * 1000);
		}

		if (tzp !is null) {
			// @TODO
			unimplemented_notice();
		}
		
		//writefln("sceKernelLibcGettimeofday(%d, %d)", tp.tv_sec, tp.tv_usec);

		return 0;
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

	/** 
	 * Get the processor clock used since the start of the process
	 */
	clock_t sceKernelLibcClock() {
		// @TODO: It's the thread CLOCK not the global CLOCK!
		//auto result = cast(uint)currentCpuThread().registers.EXECUTED_INSTRUCTION_COUNT_THIS_THREAD;
		Duration duration = (Clock.currTime - hleEmulatorState.emulatorState.startTime);
		//clock_t result = cast(clock_t)duration.total!"msecs";
		//clock_t result = cast(clock_t)duration.total!"usecs" / 10;
		clock_t result = cast(clock_t)duration.total!"usecs";
		//Logger.log(Logger.Level.WARNING, "UtilsForUser", "Not fully implemented sceKernelLibcClock(%d)", result);
		return result;
	}

	/**
	  * Function to perform an MD5 digest of a data block.
	  *
	  * @param data - Pointer to a data block to make a digest of.
	  * @param size - Size of the data block.
	  * @param digest - Pointer to a 16byte buffer to store the resulting digest
	  *
	  * @return < 0 on error.
	  */
	int sceKernelUtilsMd5Digest(u8 *data, u32 size, u8 *digest) {
		if (data   is null) return -1;
		if (digest is null) return -1;
		MD5_CTX context;
		ubyte[16] _digest;
		context.start();
		context.update(data[0..size]);
		context.finish(_digest);
		digest[0..16] = _digest;
		return 0;
	}

	/**
	 * Function to SHA1 hash a data block.
	 * 
	 * @param data - The data to hash.
	 * @param size - The size of the data.
	 * @param digest - Pointer to a 20 byte array for storing the digest
	 *
	 * @return < 0 on error.
	 */
	int sceKernelUtilsSha1Digest(u8* data, u32 size, u8* digest) {
		unimplemented();
		return -1;
	}
	
	/** 
	 * Invalidate the instruction cache
	 */
	void sceKernelIcacheInvalidateAll() {
		// Here dynarec should check functions.
		unimplemented();
	}

	/**
	 * Invalidate a instruction cache range.
	
	 * @param addr - The start address of the range.
	 * @param size - The size in bytes
	 */
	void sceKernelIcacheInvalidateRange(void *addr, uint size) {
		unimplemented_notice();
	}
}

class UtilsForKernel : UtilsForUser {
	mixin TRegisterModule;
}
