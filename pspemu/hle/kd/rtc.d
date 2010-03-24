module pspemu.hle.kd.rtc; // kd/rtc.prx (sceRTC_Service)

import pspemu.hle.Module;

class sceRtc : Module {
	void initNids() {
		mixin(registerd!(0xC41C2853, sceRtcGetTickResolution));
		mixin(registerd!(0x3F7AD767, sceRtcGetCurrentTick));
	}
	
	
	/**
	 * Get the resolution of the tick counter
	 *
	 * @return # of ticks per second
	 */
	u32 sceRtcGetTickResolution() {
		long frequency;
		std.c.windows.windows.QueryPerformanceFrequency(&frequency);
		return cast(uint)frequency;
	}

	/**
	 * Get current tick count
	 *
	 * @param tick - pointer to u64 to receive tick count
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcGetCurrentTick(u64 *tick) {
		std.c.windows.windows.QueryPerformanceCounter(cast(long *)tick);
		return 0;
	}
}

class sceRtc_driver : sceRtc {
}

static this() {
	mixin(Module.registerModule("sceRtc_driver"));
	mixin(Module.registerModule("sceRtc"));
}
