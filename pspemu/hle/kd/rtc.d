module pspemu.hle.kd.rtc; // kd/rtc.prx (sceRTC_Service)

import pspemu.hle.Module;

import std.date;

// d_time has milliseconds resolution.

static const ulong rtcResolution = 1_000_000; // microseconds

// std.date.getUTCtime has milliseconds resolution. milliseconds -> microseconds
d_time tick_to_dtime(ulong  tick) { return cast(d_time)(tick / 1_000); }
ulong  dtime_to_tick(d_time tick) { return (tick * 1_000); }

struct pspTime {
	ushort year;
	ushort month;
	ushort day;
	ushort hour;
	ushort minutes;
	ushort seconds;
	uint   microseconds;

	ulong tick() {
		auto dtime = std.date.parse(std.string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minutes, seconds));
		return (cast(ulong)dtime * 1_000) + microseconds;
	}

	bool parse(ulong tick) {
		std.date.Date date;
		
		date.parse(toUTCString(tick_to_dtime(tick)));
		
		year    = cast(ushort)date.year;
		month   = cast(ushort)date.month;
		day     = cast(ushort)date.day;
		hour    = cast(ushort)date.hour;
		minutes = cast(ushort)date.minute;
		seconds = cast(ushort)date.second;
		microseconds = cast(uint)(tick % 1_000_000);

		return true;
	}
	
	static assert (this.sizeof == 16);
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
		*tickLocal = dtime_to_tick(std.date.UTCtoLocalTime(tick_to_dtime(*tickUTC)));
		return 0;
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
		*destTick = *srcTick + numTicks;
		return 0;
	}

	/**
	 * Set ticks based on a pspTime struct
	 *
	 * @param date - pointer to pspTime to convert
	 * @param tick - pointer to tick to set
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcGetTick(pspTime* date, ulong* tick) {
		*tick = date.tick;
		return 0;
	}

	/**
	 * Set a pspTime struct based on ticks
	 *
	 * @param date - pointer to pspTime struct to set
	 * @param tick - pointer to ticks to convert
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcSetTick(pspTime* date, ulong* tick) {
		date.parse(*tick);
		return 0;
	}

	/**
	 * Get current local time into a pspTime struct
	 *
	 * @param time - pointer to pspTime struct to receive time
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcGetCurrentClockLocalTime(pspTime *time) {
		ulong currentTick;
		sceRtcGetCurrentTick(&currentTick);
		sceRtcSetTick(time, &currentTick);
		return 0;
	}

	/**
	 * Get the resolution of the tick counter
	 *
	 * @return # of ticks per second
	 */
	u32 sceRtcGetTickResolution() {
		return 1_000_000;
	}

	/**
	 * Add an amount of ms to a tick
	 *
	 * @param destTick - pointer to tick to hold result
	 * @param srcTick - pointer to source tick
	 * @param numMS - number of ms to add
	 * @return 0 on success, <0 on error
	 */
	int sceRtcTickAddMicroseconds(ulong* destTick, ulong* srcTick, ulong numMS) {
		return sceRtcTickAddTicks(destTick, srcTick, numMS);
	}

	/**
	 * Get current tick count
	 *
	 * @param tick - pointer to u64 to receive tick count
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcGetCurrentTick(ulong* tick) {
		*tick = dtime_to_tick(std.date.getUTCtime);
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
		return std.date.daysInMonth(year, month);
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
		// std.date.weekDay 0-Sunday
		//std.date.weekDay
		
		auto dtime = std.date.parse(std.string.format("%04d-%02d-%02d", year, month, day));
		return (std.date.weekDay(dtime) + 6) % 7;
	}
}

class sceRtc_driver : sceRtc {
}

static this() {
	mixin(Module.registerModule("sceRtc_driver"));
	mixin(Module.registerModule("sceRtc"));
}
