module pspemu.hle.kd.rtc; // kd/rtc.prx (sceRTC_Service)

import pspemu.hle.Module;

struct pspTime {
	ushort year;
	ushort month;
	ushort day;
	ushort hour;
	ushort minutes;
	ushort seconds;
	uint microseconds;
}


class sceRtc : Module {
	void initNids() {
		mixin(registerd!(0xC41C2853, sceRtcGetTickResolution));
		mixin(registerd!(0x3F7AD767, sceRtcGetCurrentTick));
		mixin(registerd!(0x05EF322C, sceRtcGetDaysInMonth));
		mixin(registerd!(0x57726BC1, sceRtcGetDayOfWeek));
		mixin(registerd!(0x26D25A5D, sceRtcTickAddMicroseconds));

		mixin(registerd!(0x44F45E05, sceRtcTickAddTicks));
		mixin(registerd!(0x6FF40ACC, sceRtcGetTick));
		mixin(registerd!(0x7ED29E40, sceRtcSetTick));
		mixin(registerd!(0xE7C27D1B, sceRtcGetCurrentClockLocalTime));
		
		mixin(registerd!(0x34885E0D, sceRtcConvertUtcToLocalTime));
	}

	/**
	 * Convert a UTC-based tickcount into a local time tick count
	 *
	 * @param tickUTC - pointer to u64 tick in UTC time
	 * @param tickLocal - pointer to u64 to receive tick in local time
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcConvertUtcToLocalTime(u64* tickUTC, u64* tickLocal) {
		unimplemented();
		return -1;
	}

	/**
	 * Add two ticks
	 *
	 * @param destTick - pointer to tick to hold result
	 * @param srcTick - pointer to source tick
	 * @param numTicks - number of ticks to add
	 * @return 0 on success, <0 on error
	 */
	int sceRtcTickAddTicks(ulong* destTick, ulong* srcTick, ulong numTicks) {
		unimplemented();
		return -1;
	}

	/**
	 * Set ticks based on a pspTime struct
	 *
	 * @param date - pointer to pspTime to convert
	 * @param tick - pointer to tick to set
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcGetTick(pspTime* date, ulong* tick) {
		unimplemented();
		return -1;
	}

	/**
	 * Set a pspTime struct based on ticks
	 *
	 * @param date - pointer to pspTime struct to set
	 * @param tick - pointer to ticks to convert
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcSetTick(pspTime* date, ulong* tick) {
		unimplemented();
		return -1;
	}

	/**
	 * Get current local time into a pspTime struct
	 *
	 * @param time - pointer to pspTime struct to receive time
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcGetCurrentClockLocalTime(pspTime *time) {
		unimplemented();
		return -1;
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
	 * Add an amount of ms to a tick
	 *
	 * @param destTick - pointer to tick to hold result
	 * @param srcTick - pointer to source tick
	 * @param numMS - number of ms to add
	 * @return 0 on success, <0 on error
	 */
	int sceRtcTickAddMicroseconds(u64* destTick, const u64* srcTick, u64 numMS) {
		unimplemented();
		return 0;
	}

	/**
	 * Get current tick count
	 *
	 * @param tick - pointer to u64 to receive tick count
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcGetCurrentTick(u64* tick) {
		std.c.windows.windows.QueryPerformanceCounter(cast(long *)tick);
		return 0;
	}

	/**
	 * Get number of days in a specific month
	 *
	 * @param year - year in which to check (accounts for leap year)
	 * @param month - month to get number of days for
	 * @return # of days in month, <0 on error (?)
	 */
	int sceRtcGetDaysInMonth(int year, int month) {
		unimplemented();
		return -1;
	}

	/**
	 * Get day of the week for a date
	 *
	 * @param year - year in which to check (accounts for leap year)
	 * @param month - month that day is in
	 * @param day - day to get day of week for
	 * @return day of week with 0 representing Monday
	 */
	int sceRtcGetDayOfWeek(int year, int month, int day) {
		unimplemented();
		return -1;
	}
}

class sceRtc_driver : sceRtc {
}

static this() {
	mixin(Module.registerModule("sceRtc_driver"));
	mixin(Module.registerModule("sceRtc"));
}
