module pspemu.hle.kd.Types;

import std.datetime;

alias void* ScePVoid;

alias ubyte  u8;
alias ushort u16;
alias uint   u32;
alias ulong  u64;

alias long d_time;

alias char  SceChar8;
alias short SceShort16;
alias int   SceInt32;
alias long  SceInt64;
alias long  SceLong64;

alias ushort SceUShort16;
alias uint   SceUInt32;
alias ulong  SceUInt64;

/** UIDs are used to describe many different kernel objects. */
alias uint SceUID;

/* Misc. kernel types. */
alias uint SceSize;
alias int SceSSize;

alias ubyte SceUChar;
alias uint SceUInt;

/* File I/O types. */
alias int SceMode;
alias SceInt64 SceOff;
alias SceInt64 SceIores;

alias uint SceKernelThreadEntry;
alias uint SceKernelCallbackFunction;

//alias int function(SceSize args, void* argp) SceKernelThreadEntry;
//alias int function(int arg1, int arg2, void* arg) SceKernelCallbackFunction;

/** Structure to hold the event flag information */
struct SceKernelEventFlagInfo {
	SceSize 	size;
	char 		name[32];
	SceUInt 	attr;
	SceUInt 	initPattern;
	SceUInt 	currentPattern;
	int 		numWaitThreads;
}

struct SceKernelEventFlagOptParam {
	SceSize 	size;
}

struct SceKernelMppInfo {
	SceSize  size;
	char[32] name;
	SceUInt  attr;
	int      bufSize;
	int      freeSize;
	int      numSendWaitThreads;
	int      numReceiveWaitThreads;
}

/** 64-bit system clock type. */
struct SceKernelSysClock {
	SceUInt32   low;
	SceUInt32   hi;
}

ulong systime_to_tick(SysTime systime) {
	return convert!("hnsecs", "usecs")(systime.stdTime - unixTimeToStdTime(0));
}

SysTime tick_to_systime(ulong ticks) {
	return SysTime(convert!("usecs", "hnsecs")(ticks) + unixTimeToStdTime(0), UTC());
}

/* Date and time. */
struct ScePspDateTime {
	ushort	year;
	ushort 	month;
	ushort 	day;
	ushort 	hour;
	ushort 	minute;
	ushort 	second;
	uint 	microsecond;

	ulong tick() {
		return systime_to_tick(SysTime(DateTime(year, month, day, hour, minute, second), UTC())) + microsecond;
	}

	bool parse(DateTime datetime) {
		return parse(SysTime(datetime));
	}
	
	bool parse(SysTime systime) {
		year        = cast(ushort)systime.year;
		month       = cast(ushort)systime.month;
		day         = cast(ushort)systime.day;
		hour        = cast(ushort)systime.hour;
		minute      = cast(ushort)systime.minute;
		second      = cast(ushort)systime.second;
		microsecond = cast(uint  )systime.fracSec.usecs;

		return true;
	}

	bool parse(ulong tick) {
		return parse(tick_to_systime(tick));
	}
	
	static assert (this.sizeof == 16);
}
