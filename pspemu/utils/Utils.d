module pspemu.utils.Utils;

import std.stream, std.stdio;

private import std.c.windows.windows;
private import std.windows.syserror;

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

T min(T)(T l, T r) { return (l < r) ? l : r; }
T max(T)(T l, T r) { return (l > r) ? l : r; }

static pure nothrow string tos(T)(T v, int base = 10) {
	if (v == 0) return "0";
	const digits = "0123456789abdef";
	assert(base <= digits.length);
	string r;
	long vv = cast(long)v;
	bool sign = (vv < 0);
	if (sign) vv = -vv;
	while (vv != 0) {
		r = digits[cast(uint)(vv) % base] ~ r;
		vv /= base;
	}
	if (sign) r = "-" ~ r;
	return r;
}

class CircularList(Type) {
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
		if (count > 0) {
			assert(readAvailable  >= +count);
		} else {
			assert(writeAvailable >= -count);
		}
		headPosition = (headPosition + 1) % list.length;
		readAvailable -= count;
	}

	uint tailPosition;
	void tailPosition__Inc(int count = 1) {
		if (count > 0) {
			assert(writeAvailable >= +count);
		} else {
			assert(readAvailable  >= -count);
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
}

void sleep(uint ms) {
	Sleep(ms);
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
	void waitEmpty() { while (tasks.length) sleep(1); }
	alias executeAll opCall;
}

alias CircularList Queue;

unittest {
	assert(tos(100) == "100");
	assert(tos(-99) == "-99");
}