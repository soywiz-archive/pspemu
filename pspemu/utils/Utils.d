module pspemu.utils.Utils;

import std.stream, std.stdio, std.path, std.typecons;

private import std.c.windows.windows;
private import std.windows.syserror;

private import core.thread;

// Signed?
enum : bool { Unsigned, Signed }	
enum Sign : bool { Unsigned, Signed }	

alias ulong  u64;
alias uint   u32;
alias ushort u16;
alias ubyte  u8;
alias long   s64;
alias int    s32;
alias short  s16;
alias byte   s8;

// Reinterpret.
// float -> int
int   F_I(float v) { return *cast(int   *)&v; }
// int -> float
float I_F(int   v) { return *cast(float *)&v; }

struct InfiniteLoop(int maxCount = 512/*, string file = __FILE__, int line = __LINE__*/) {
	uint count = maxCount;
	void increment(void delegate() callback = null, string file = __FILE__, int line = __LINE__) {
		count--;
		if (count <= 0) {
			count = maxCount;
			writefln("Infinite loop detected at '%s':%d", file, line);
			if (callback !is null) callback();
		}
	}
}

void changeAfter(T)(T* var, int microseconds, T value) {
	(new Thread({
		static if (true) {
			sleep(microseconds / 1000);
		} else {
			long frequency; QueryPerformanceFrequency(&frequency);
			long counter() {
				long value = void;
				QueryPerformanceCounter(&value);
				return value;
			}
			long startCounter = counter;
			while ((((counter - startCounter) * 1000 * 1000) / frequency) < cast(long)microseconds) {
				sleep(0);
			}
		}
		*var = value;
	})).start();
}

static const changeAfterTimerPausedMicroseconds = "bool paused = true; changeAfter(&paused, delay, false);";

T onException(T)(lazy T t, T errorValue) { try { return t(); } catch { return errorValue; } }
T nullOnException(T)(lazy T t) { return onException!(T)(t, null); }

T1 reinterpret(T1, T2)(T2 v) { return *cast(T1 *)&v; }

ubyte[] TA(T)(ref T v) {
	return cast(ubyte[])((&v)[0..1]);
}

T read(T)(Stream stream, long position = -1) {
	T t;
	if (position >= 0) stream = new SliceStream(stream, position, position + (1 << 24));
	stream.read(TA(t));
	return t;
}

T readInplace(T)(ref T t, Stream stream, long position = -1) {
	if (position >= 0) stream.position = position;
	stream.read(TA(t));
	return t;
}

void writeZero(Stream stream, uint count) {
	ubyte[1024] block;
	while (count > 0) {
		int w = min(count, block.length);
		stream.write(block[0..w]);
		count -= w;
	}
}

string readStringz(Stream stream, long position = -1) {
	string s;
	char c;
	if (position >= 0) {
		//writefln("SetPosition:%08X", position);
		stream = new SliceStream(stream, position, position + (1 << 24));
	}
	while (!stream.eof) {
		stream.read(c);
		if (c == 0) break;
		s ~= c;
	} 
	return s;
}

ulong readVarInt(Stream stream) {
	ulong v;
	ubyte b;
	while (!stream.eof) {
		stream.read(b);
		v <<= 7;
		v |= (b & 0x7F);
		if (!(b & 0x80)) break;
	}
	return v;
}

void swap(T)(ref T a, ref T b) { auto c = a; a = b; b = c; }
T min(T)(T l, T r) { return (l < r) ? l : r; }
T max(T)(T l, T r) { return (l > r) ? l : r; }

static pure nothrow string tos(T)(T v, int base = 10, int pad = 0) {
	if (v == 0) return "0";
	const digits = "0123456789abcdef";
	assert(base <= digits.length);
	string r;
	long vv = cast(long)v;
	bool sign = (vv < 0);
	if (sign) vv = -vv;
	while (vv != 0) {
		r = digits[cast(uint)(vv) % base] ~ r;
		vv /= base;
	}
	while (r.length < pad) r = '0' ~ r;
	if (sign) r = "-" ~ r;
	return r;
}

unittest {
	assert(tos(100) == "100");
	assert(tos(-99) == "-99");
}

class CircularList(Type, bool CheckAvailable = true) {
	/*
	struct Node {
		Type value;
		Node* next;
	}

	Node* head;
	Node* tail;
	Type[] pool;
	*/

	Type[] list;

	this(uint capacity = 1024) {
		list = new Type[capacity];
	}

	uint readAvailable;
	uint writeAvailable() { return list.length - readAvailable; }

	uint headPosition;
	void headPosition__Inc(int count = 1) {
		static if (CheckAvailable) {
			if (count > 0) {
				assert(readAvailable  >= +count);
			} else {
				assert(writeAvailable >= -count);
			}
		}
		headPosition = (headPosition + 1) % list.length;
		readAvailable -= count;
	}

	uint tailPosition;
	void tailPosition__Inc(int count = 1) {
		static if (CheckAvailable) {
			if (count > 0) {
				assert(writeAvailable >= +count);
			} else {
				assert(readAvailable  >= -count);
			}
		}
		tailPosition = (tailPosition + count) % list.length;
		readAvailable += count;
	}

	ref Type consume() {
		scope (exit) headPosition__Inc(1);
		return list[headPosition];
	}

	ref Type queue(Type value) {
		scope (exit) tailPosition__Inc(1);
		list[tailPosition] = value;
		return list[tailPosition];
	}

	ref Type dequeue() {
		tailPosition__Inc(-1);
		return list[tailPosition];
	}

	ref Type readFromTail(int pos = -1) {
		return list[(tailPosition + pos) % list.length];
	}

	alias consume consumeHead;
}

alias CircularList Queue;

extern (Windows) BOOL SwitchToThread();

void sleep(uint ms) {
	static if (true) {
		Sleep(ms);
	} else {
		if (ms == 0) {
			SwitchToThread();
		} else {
			Sleep(ms);
		}
	}
}

class TaskQueue {
	alias void delegate() Task;
	Task[] tasks;
	Object lock;
	
	this() {
		lock = new Object;
	}
	
	void add(Task task) { synchronized (lock) { tasks ~= task; } }
	void executeAll() { synchronized (lock) { foreach (task; tasks) task(); tasks.length = 0; } }
	void addAndWait(Task task) { add(task); waitExecuted(task); }
	void waitExecuted(Task task) {
		bool inList;
		do {
			synchronized (lock) {
				inList = false;
				foreach (ctask; tasks) if (ctask == task) { inList = true; break; }
			}
			if (!inList) sleep(1);
		} while (inList);
	}
	void waitEmpty() { while (tasks.length) sleep(1); }
	alias executeAll opCall;
}

mixin(defineEnum!("RunningState", uint,
	"RUNNING", 0,
	"PAUSED" , 1,
	"STOPPED", 2
));

class HaltException : Exception { this(string type = "HALT") { super(type); } }

abstract class PspHardwareComponent {
	Thread thread;
	RunningState runningState = RunningState.STOPPED;
	bool componentInitialized = false;

	void start() {
		if ((thread !is null) && thread.isRunning) return;

		componentInitialized = false;
		runningState = RunningState.RUNNING;
		thread = new Thread(&run);
		thread.start();
		waitStart();
	}
	
	abstract void run();

	/**
	 * Pauses emulation.
	 */
	void pause() {
		runningState = RunningState.PAUSED;
	}

	/**
	 * Resumes emulation.
	 */
	void resume() {
		runningState = RunningState.RUNNING;
	}

	/**
	 * Stops emulation.
	 */
	void stop() {
		runningState = RunningState.STOPPED;
	}

	void stopAndWait() {
		stop();
		while (running) sleep(1);
	}

	void init() {
	}

	void reset() {
	}

	bool running() {
		return (runningState == RunningState.RUNNING) && (thread && thread.isRunning);
	}

	void waitStart() {
		InfiniteLoop!(1024) loop;
		while (!componentInitialized && (runningState == RunningState.RUNNING)) {
			loop.increment();
			sleep(1);
		}
	}

	void waitUntilResume() {
		while (runningState != RunningState.RUNNING) {
			if (runningState == RunningState.STOPPED) throw(new HaltException("RunningState.STOPPED"));
			sleep(1);
		}
	}

	void waitEnd() {
		while (runningState == RunningState.RUNNING) {
			sleep(1);
		}
	}
}

import dfl.all;

class ApplicationPaths {
	static string exe() { return cast(string)std.path.dirname(Application.executablePath); }
	static string current() { return cast(string)std.path.curdir; }
	static string startup() { return cast(string)Application.startupPath; }
	static string userAppData() { return cast(string)Application.userAppDataBasePath; }
}

void writeBmp8(string fileName, void* data, int width, int height) {
	static struct BITMAPFILEHEADER { align(1):
		char[2] bfType = "BM";
		uint    bfSize;
		ushort  bfReserved1;
		ushort  bfReserved2;
		uint    bfOffBits;
	}
	
	static struct BITMAPINFOHEADER { align(1):
		uint   biSize;
		int    biWidth;
		int    biHeight;
		ushort biPlanes;
		ushort biBitCount;
		uint   biCompression;
		uint   biSizeImage;
		int    biXPelsPerMeter;
		int    biYPelsPerMeter;
		uint   biClrUsed;
		uint   biClrImportant;
	}

	static struct RGBQUAD {
		ubyte rgbBlue;
		ubyte rgbGreen;
		ubyte rgbRed;
		ubyte rgbReserved;
	}

	BITMAPFILEHEADER h;
	BITMAPINFOHEADER ih;
	
	ih.biSize = ih.sizeof;
	ih.biWidth = width;
	ih.biHeight = height;
	ih.biPlanes = 1;
	ih.biBitCount = 8;
	ih.biCompression = 0;
	ih.biSizeImage = ubyte.sizeof * width * height;
	ih.biXPelsPerMeter = 0;
	ih.biYPelsPerMeter = 0;
	ih.biClrUsed = 256;
	ih.biClrImportant = 0;

	h.bfOffBits = h.sizeof + ih.sizeof;
	
	h.bfSize = h.sizeof + ih.sizeof + RGBQUAD.sizeof * 0x100 + ubyte.sizeof * width * height;

	scope file = new std.stream.File(fileName, FileMode.OutNew);
	file.write(TA(h));
	file.write(TA(ih));
	for (int n = 0; n < 0x100; n++) {
		RGBQUAD rgba;
		rgba.rgbRed = rgba.rgbGreen = rgba.rgbBlue = cast(ubyte)n;
		rgba.rgbReserved = 0xFF;
		file.write(TA(rgba));
	}
	file.write((cast(ubyte*)data)[0..width * height]);
	file.close();
}