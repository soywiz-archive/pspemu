module pspemu.hle.kd.rtc.Types;

import std.stdio;

import pspemu.hle.kd.Types;
import std.datetime;

// d_time has milliseconds resolution.

alias uint time_t;

alias ScePspDateTime pspTime;

struct SceKernelVTimerOptParam {
	SceSize 	size;
}

//alias ulong pspTick;

