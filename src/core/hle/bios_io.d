module psp.bios_io;

import std.stdio;
import std.string;
import std.random;
import std.c.time;
import std.file;
import std.cstream, std.stream;
import std.utf;
import std.date;
import psp.controller;

import dfl.all, dfl.internal.winapi;
import std.c.windows.windows;

import psp.memory;
import psp.disassembler.cpu;
import psp.gpu;
import psp.cpu;
import psp.bios;
import psp.loader;
import glcontrol;

debug = debug_bios_io_simple;
//debug = bios_debug;

class Module_IoFileMgrForUser : Module {
	static this() { BIOS_HLE.addModule("IoFileMgrForUser", Module_IoFileMgrForUser.classinfo); }

	this() {
		list[0x54F5FB11] = &sceIoDevctl;
		list[0x109F50BC] = &sceIoOpen;
		list[0x810C4BC3] = &sceIoClose;
		list[0xACE946E8] = &sceIoGetstat;
		list[0x27EB27B8] = &sceIoLseek;
		list[0x6A638D83] = &sceIoRead;
		list[0x42EC03AC] = &sceIoWrite;
		list[0x06A70004] = &sceIoMkdir;
	}
	
	enum {
		PSP_O_RDONLY  = 0x0001,
		PSP_O_WRONLY  = 0x0002,
		PSP_O_RDWR    = (PSP_O_RDONLY | PSP_O_WRONLY),
		PSP_O_NBLOCK  = 0x0004,
		PSP_O_DIROPEN = 0x0008, // Internal use for dopen
		PSP_O_APPEND  = 0x0100,
		PSP_O_CREAT   = 0x0200,
		PSP_O_TRUNC   = 0x0400,
		PSP_O_EXCL    = 0x0800,
		PSP_O_NOWAIT  = 0x8000,
	}

	enum {
		PSP_SEEK_SET = 0,
		PSP_SEEK_CUR = 1,
		PSP_SEEK_END = 2,
	}
	
	void sceIoDevctl() {
		char[] devName = cpu.mem.readsz(a(0));
		//int sceIoDevctl(const char *dev, unsigned int cmd, void *indata, int inlen, void *outdata, int outlen);
		writefln("sceIoDevctl ('%s', 0x%08X, 0x%08X, %d, 0x%08X, %d)", cpu.mem.readsz8(a(0)), a(1), a(2), a(3), a(4), a(5));
		retval(Device.get(devName).sceIoDevctl(devName, a(1), a(2), a(3), a(4), a(5)));
		writefln("sceIoDevctl ended");
	}
	
	void sceIoOpen() {
		FileMode sflags;
		char[] name = cpu.mem.readsz(a(0));
		int mode = a(2);
		int flags = a(1);
		debug (bios_debug) writefln("sceIoOpen ('%s', 0x%08X, 0x%08X)", cpu.mem.readsz8(a(0)), flags, mode);
		
		if (flags & PSP_O_APPEND) {
			sflags |= FileMode.Append;
		} else if (flags & PSP_O_CREAT) {
			sflags |= FileMode.OutNew;
		}
		
		if (flags & PSP_O_RDONLY) sflags |= FileMode.In;
		if (flags & PSP_O_WRONLY) sflags |= FileMode.Out;
		
		retval(cast(int)cast(void*)Device.openl(name, sflags, flags));
		debug (bios_debug) writefln("-> %08X", cpu.regs.r[Registers.R.v0]);
	}
	
	void sceIoClose() {
		debug (bios_debug) writefln("sceIoClose(%d)", a(0));
		Stream s = cast(Stream)cast(void*)a(0);
		if (s is null) { retval(0); return; }
		Device.close(s);
	}
	
	void sceIoGetstat() {
		char[] name = cpu.mem.readsz(a(0));
		int ptr = a(1);
		debug (bios_debug) writefln("sceIoGetstat('%s', 0x%08X)", cpu.mem.readsz8(a(0)), ptr);
		
		try {
			SceIoStat stat = Device.statl(name);
			SceIoStat* stat_p = cast(SceIoStat*)cpu.mem.gptr(ptr);
			*stat_p = stat;
			retval(1);
		} catch (Exception e) {
			retval(0);
		}
	}
	
	void sceIoLseek() {
		debug (bios_debug) writefln("sceIoLseek(%08X, 0x%08X%08X, %08X)", a(0), a(3), a(2), a(4));
		//throw(new Exception("aaaaaaa"));
		Stream s = cast(Stream)cast(void*)a(0);
		if (s is null) { retval64(0); return; }
		long offset = (a(2) << 32) | a(3);
		int whence = a(4); // Whence equal in Stream
		retval64(s.seek(offset, cast(SeekPos)whence));
	}
	
	void sceIoRead() {
		//int sceIoRead(SceUID fd, void *data, SceSize size);
		debug (bios_debug) writefln("sceIoRead(0x%08X, 0x%08X, 0x%08X)", a(0), a(1), a(2));
		Stream s;
		try {
			s = cast(Stream)cast(void*)a(0);
		} catch { throw(new Exception("read:0")); }
		if (s is null) { retval(0); return; }
		ubyte[] data;
		try {
			data = (cast(ubyte *)cpu.mem.gptr(a(1)))[0..a(2)];
		} catch { throw(new Exception(std.string.format("read:1 : %08X,%d", a(1), a(2)))); }
		try {
			retval(s.read(data));
		} catch { throw(new Exception(std.string.format("read:2 %08X", a(0)))); }
	}
	
	void sceIoWrite() {
		debug (bios_debug) writefln("sceIoWrite(0x%08X, 0x%08X, 0x%08X)", a(0), a(1), a(2));
		Stream s = cast(Stream)cast(void*)a(0);
		if (s is null) { retval(0); return; }
		retval(s.write((cast(ubyte *)cpu.mem.gptr(a(1)))[0..a(2)]));
	}
	
	void sceIoMkdir() {
		writefln("sceIoMkdir(%s, %d)", cpu.mem.readsz(a(0)), a(1));
	}		
}

void dumpTime(ScePspDateTime t) {
	writefln("%d-%d-%d %d:%d:%d.%d", t.year, t.month, t.day, t.hour, t.minute, t.second, t.microsecond);
}

ScePspDateTime fromTime(long t) {
	ScePspDateTime dt = void;
	
	dt.year  = YearFromTime(t);
	dt.month = MonthFromTime(t);
	dt.day   = DateFromTime(t);
	
	long day_t = t % (3600 * 24 * TicksPerSecond);
	long rest = day_t / TicksPerSecond;
	
	long doRest(int div) {
		long r = rest / div;
		rest %= div;
		return r;
	}
	
	dt.hour    = doRest(3600);
	dt.minute  = doRest(60);
	dt.second  = doRest(60);
	dt.microsecond = ((day_t % TicksPerSecond) * 1000000) / TicksPerSecond;
	
	return dt;
}

class Device_MemoryStick : Device {
	static uint callback;
	bool inserted;

	static Device_MemoryStick singleton;
	
	static this() {
		BIOS_HLE.addDevice(["ms0", "fatms0"], new Device_MemoryStick);
	}

	this() {
		singleton = this;
	}
	
	uint sceIoDevctl(char[] dev, uint cmd, int indata, int inlen, int outdata, int outlen) {
		switch (cmd) {
			case 0x02415821: callback = cpu.mem.read4(indata); break; // Register Ejection/Insert MS
			default: writefln("Unknown Device_MemoryStick.sceIoDevctl command (0x%08x)", cmd); break;
		}
		return 0;
	}
	
	static char[] realFile(char[] path) {
		char[] rfile = ModuleLoader.appPath ~ "/" ~ path;;
		debug (bios_debug) writefln("Opening '%s' %s", rfile, std.file.exists(rfile) ? "found" : "NOT found");
		return rfile;
	}
	
	Stream open(char[] path, FileMode mode, int flags = 0777) {
		char[] file = realFile(path);
		debug (debug_bios_io_simple) writefln("Opening '%s'", file);
		try {
			return new File(file, mode);
		} catch (Exception e) {
			return null;
		}
	}
	
	SceIoStat stat(char[] path) {
		SceIoStat r;
		char[] file = realFile(path);
		long ftc, fta, ftm;
		r.st_mode = 0777;
		r.st_attr = 0;
		r.st_size = std.file.getSize(file);
		std.file.getTimes(file, ftc, fta, ftm);
		
		r.st_ctime = fromTime(ftc);
		r.st_atime = fromTime(fta);
		r.st_mtime = fromTime(ftm);
		
		debug (bios_debug) { writef("Creation time: "); dumpTime(r.st_mtime); }
		
		for (int n = 0; n < 6; n++) r.st_private[n] = 0;
		return r;
	}
	
	void changeState(bool inserted) {
		debug (bios_debug) writefln("Memory Stick: %s", inserted ? "inserted" : "ejected");
		this.inserted = inserted;
		cpu.mem.interrupts.callbacks[INTS.MSCM0] = &call;
		cpu.mem.interrupts.queueHead(INTS.MSCM0);
	}
	
	void call() {
		bios.callbacks.call(callback, [0, this.inserted ? 1 : 2, 0]);
		//cpu.
	}
}
