module pspemu.hle.kd.utils.Types;

// BUG: Can't aliase directly std.random.Mt19937 because it's a template struct and currently it doesn't work with cast.
alias void SceKernelUtilsMt19937Context;
//alias std.random.Mt19937 SceKernelUtilsMt19937Context;

//extern (Windows) ulong GetTickCount64();

struct timeval {
	uint tv_sec;
	uint tv_usec;
}

struct timezone {
	int tz_minuteswest;
	int tz_dsttime;
}
