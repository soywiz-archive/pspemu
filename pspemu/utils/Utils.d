module pspemu.utils.Utils;

import std.stream, std.stdio, std.path, std.typecons;

private import std.c.windows.windows;
private import std.windows.syserror;

public import pspemu.utils.String;

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
		microsleep(microseconds);
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
T clamp(T)(T v, T l = 1.0, T r = 1.0) {
	if (v < l) v = l;
	if (v > r) v = r;
	return v;
}
T xabs(T)(T v) { return (v >= 0) ? v : -v; }
T sign(T)(T v) { if (v == 0) return 0; return (v > 0) ? 1 : -1; }

static pure string bitslice(string v, T, string name, uint start, uint count, bool asserts = false)() {
	string r;
	bool signed = (T.min < 0);

	static if (T.min < 0) {
		long  minVal = -(1uL << (count - 1));
		ulong maxVal = (1uL << (count - 1)) - 1;
	} else {
		ulong minVal = 0;
		ulong maxVal = (1uL << count) - 1;
	}
	
	auto mask = (1 << count) - 1;

	// Getter
	{
		r ~= T.stringof ~ " " ~ name ~ "() {";
		{
			//static if (is(T == bool))
			r ~= "" ~ T.stringof ~ " result = (" ~ v ~ " >> " ~ tos(start) ~ ") & " ~ tos(mask) ~ ";";
			if (signed) {
				r ~= "if (result & " ~ tos(1 << (count - 1)) ~ ") result |= ~(" ~ tos(mask) ~ ");";
			}
			r ~= "return result;";
		}
		r ~= "}";
	}
	// Setter
	{
		r ~= "void " ~ name ~ "(" ~ T.stringof ~ " ___v) {";
		{
			if (asserts) {
				r ~= "assert(___v >= " ~ tos(minVal) ~ ");";
				r ~= "assert(___v <= " ~ tos(maxVal) ~ ");";
				r ~= v ~ " = (" ~ v ~ " & ~" ~ tos(mask << start) ~ ") | (___v << " ~ tos(start) ~ ");";
			} else {
				r ~= v ~ " = (" ~ v ~ " & ~" ~ tos(mask << start) ~ ") | ((___v & " ~ tos(mask) ~ ") << " ~ tos(start) ~ ");";
			}
		}
		r ~= "}";
	}
	return r;
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
	microsleep(ms * 1000);
}

/**
 * Return a microsecond tick.
 */
ulong microSecondsTick() {
	ulong count, frequency;
	QueryPerformanceCounter(cast(long *)&count);
	QueryPerformanceFrequency(cast(long *)&frequency);
	return (count * 1_000_000) / frequency;
}

/*string lowerPriorityForThisScope() { return q{
	int lastPriority = Thread.getThis.priority;
	Thread.getThis.priority = PRIORITY_MIN;
	scope (exit) Thread.getThis.priority = lastPriority;
} }*/

void microsleep(uint microSeconds) {
	if (microSeconds == 0) {
		Sleep(0);
	} else {
		int lastPriority = Thread.getThis.priority; Thread.getThis.priority = Thread.PRIORITY_MIN; scope (exit) Thread.getThis.priority = lastPriority;
		ulong start = microSecondsTick;
		Sleep(microSeconds / 1000);
		while ((microSecondsTick - start) < microSeconds) SwitchToThread();
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

enum RunningState {
	RUNNING = 0,
	PAUSED  = 1,
	STOPPED = 2,
}

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
