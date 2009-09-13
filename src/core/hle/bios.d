module psp.bios;

import std.stdio;
import std.string;
import std.random;
import std.c.time;
import std.file;
import std.cstream, std.stream;
import std.utf;
import psp.controller;

import dfl.all, dfl.internal.winapi;
import std.c.windows.windows;

import psp.memory;
import psp.disassembler.cpu;
import psp.gpu;
import psp.cpu;
import glcontrol;

//version = bios_monothread;
//debug = bios_debug;
//debug = bios_memory;
//debug = bios_threads;

class Module {
	BIOS bios() { return BIOS.bios; }
	
	void delegate()[uint] list;
	
	void delegate() getCallback(uint nid) {
		return (nid in list) ? list[nid] : null;
	}
	
	void retval(uint v) {
		cpu.regs.v0 = v;
	}

	void retval64(ulong v) {
		cpu.regs.r[Registers.R.v0] = (v >>  0) & 0xFFFFFFFF;
		cpu.regs.r[Registers.R.v1] = (v >> 32) & 0xFFFFFFFF;
	}
	
	final uint a(int n) { return cpu.regs.a(n); }
}

class Device {
	static Device[char[]] list;
	static bool[Stream] streams;

	BIOS bios() { return BIOS.bios; }
	
	static Device get(char[] name) {
		while (name.length > 0 && name[name.length - 1] == ':') name = name[0..name.length - 1];
		if ((name in list) is null) throw(new Exception(std.string.format("Unknown device '%s'", name)));
		return list[name];
	}
	
	static void close(Stream s) {
		s.close();
		streams.remove(s);
	}	
	
	static Stream openl(char[] path, FileMode mode, int flags = 0777) {
		char[][] params = std.string.split(path, ":");
		// No device
		Stream s;
		if (params.length == 1) {
			s = get("ms0").open(params[0], mode, flags);
		} else {
			s = get(params[0]).open(params[1], mode, flags);
		}
		streams[s] = true;
		return s;
	}

	static SceIoStat statl(char[] path) {
		char[][] params = std.string.split(path, ":");
		// No device
		if (params.length == 1) {
			return get("ms0").stat(params[0]);
		} else {
			return get(params[0]).stat(params[1]);
		}
	}
	
	static void reset() {
		streams = null;
	}
	
	abstract Stream open(char[] path, FileMode mode, int flags = 0777);
	abstract SceIoStat stat(char[] path);
	abstract uint sceIoDevctl(char[] dev, uint cmd, int indata, int inlen, int outdata, int outlen);
}

struct ScePspDateTime {
	ushort	year;
	ushort 	month;
	ushort 	day;
	ushort 	hour;
	ushort 	minute;
	ushort 	second;
	uint 	microsecond;
}		

struct SceIoStat {
	int            st_mode;
	uint           st_attr;
	ulong          st_size;
	ScePspDateTime st_ctime;
	ScePspDateTime st_atime;
	ScePspDateTime st_mtime;
	uint[6]        st_private;
}

struct Semaphore {
	int attr;
	int current;
	int max;
	int option;
}

class psp_Thread {
	static psp_Thread _current;
	static psp_Thread[char[]] list;
	static psp_Thread[] listCircular;
	static int listCircularCurrent;

	int waiting_value;
	Semaphore *wakeup;
	
	Registers regs;
	CPU cpu;
	char[] name;
	uint callback;
	uint priority;
	uint stacksize;
	uint attr;
	uint options;
	bool sleeping = true;
	
	static psp_Thread getNext() {
		listCircularCurrent = (listCircularCurrent + 1) % listCircular.length;
		return listCircular[listCircularCurrent];
	}
	
	static void updatePriorities() {
		listCircular = [];
		listCircularCurrent = 0;
		// TODO: FAKE: Ignoring priorities
		foreach (t; list.values) listCircular ~= t;
	}
	
	this(BIOS bios, char[] name, uint callback, uint priority, uint stacksize, uint attr, uint options) {
		regs = new Registers;
		
		this.cpu = cpu;
		this.name = name;
		this.callback = callback;
		this.priority = priority;
		this.stacksize = stacksize;
		this.attr = attr;
		this.options = options;
		//this.v[0..4] = vl;

		regs.copy(cpu.regs);
		
		regs._PC = callback;
		regs.r[Registers.R.sp] = bios.mman.allocStack(stacksize) + stacksize - 4;
		
		regs.r[Registers.R.ra] = 0x08000004;
		
		writefln("Stack: 0x%08X", regs.r[Registers.R.sp]);
		
		list[name] = this;
		
		updatePriorities();
	}
	
	void start(uint a0, uint a1) {
		printf("Thread started ('%s')\n", std.string.toStringz(name));
		//writefln("%08X", cpu.regs.PC);
		
		version (bios_monothread) {
			cpu.regs.r[Registers.R.a0] = a0;
			cpu.regs.r[Registers.R.a1] = a1;
			cpu.regs._PC = callback;
		} else {
			regs.r[Registers.R.a0] = a0;
			regs.r[Registers.R.a1] = a1;
			
			sleeping = false;
		}
		
		//writefln("%08X", cpu.regs.PC);
	}
	
	void suspend() {
		debug (bios_threads) writefln("Thread.suspend %d (%s)", sleeping, name);
		regs.copy(cpu.regs);
	}
	
	void resume() {
		cpu.regs.copy(regs);
		
		debug (bios_threads) writefln("Thread.resume %d (%s) PC: 0x%08X ; 0x%08X", sleeping, name, cpu.regs.PC, cpu.regs.nPC);
		
		_current = this;
		
		//cpu.pauseAt = 0;
		//cpu.interrupt = true;
		//throw(new Exception("test"));
		//writefln("%08X", cpu.regs.PC);
	}

	static void sleep() {
		writefln("Thread.sleep ('%s')", _current.name);
		_current.sleeping = true;
		next();
	}
	
	static void next() {
		version (bios_monothread) return;
		
		//writefln("Thread.next()");

		if (_current is null) return;
		
		int len = listCircular.length;
		
		for (int n = 0; n < len; n++) {
			psp_Thread _next = getNext;
			
			//writefln("N[%d]: %s(%d)", n, _next.name, _next.sleeping);

			if (_next.sleeping && _next.wakeup) {
				if (_next.waiting_value == _next.wakeup.current) {
					_next.sleeping = false;
				}
			}
			
			if (_next.sleeping) continue;
			
			if (_next != _current) {
				//writefln("change");
				_current.suspend();
				_next.resume();
			}
			
			//writefln("continue");
			return;
		}
		
		//writefln("no threads (%d)", listCircular.length);
		_current.cpu.regs.PC = 0x08000008;
		//throw(new Exception(std.string.format("Can't switch any thread (%d)", list.length)));
	}
	
	static void reset() {
		_current = null;
		foreach (k; list.keys) list.remove(k);
		listCircular = [];
		listCircularCurrent = 0;
	}
	
	static void remove(psp_Thread *t) {
		t.sleeping = true;
	}
}

bool insertedUmd = true;

class Module_sceUmdUser : Module {
	static this() { BIOS_HLE.addModule("sceUmdUser", Module_sceUmdUser.classinfo); }

	this() {
		list[0x46EBB729] = &sceUmdCheckMedium;
		list[0xC6183D47] = &sceUmdActivate;
		list[0x4A9E5E29] = &sceUmdWaitDriveStatCB;
	}
	
	void sceUmdCheckMedium() {
		debug (bios_debug) writefln("sceUmdCheckMedium");
		cpu.regs[Registers.R.v0] = insertedUmd;
	}
	
	void sceUmdActivate() {
		debug (bios_debug) writefln("sceUmdActivate (%d, %s)", cpu.regs[Registers.R.a0], cpu.mem.readsz8(cpu.regs[Registers.R.a1]));
		cpu.regs[Registers.R.v0] = 0;
		insertedUmd = true;
	}
	
	void sceUmdWaitDriveStatCB() {
		writefln("sceUmdWaitDriveStatCB (%08X,%08X,%08X)", cpu.regs[Registers.R.a0], cpu.regs[Registers.R.a1], cpu.regs[Registers.R.a2]);
	}
}

class Module_sceImpose : Module {
	static this() { BIOS_HLE.addModule("sceImpose", Module_sceImpose.classinfo); }

	this() {
		list[0x8C943191] = &sceImposeGetBatteryIconStatus;
	}
	
	void sceImposeGetBatteryIconStatus() {
		writefln("sceImposeGetBatteryIconStatus");
	}
}

class Module_sceCtrl : Module {
	static this() { BIOS_HLE.addModule("sceCtrl", Module_sceCtrl.classinfo); }

	this() {
		list[0x6A2774F3] = &sceCtrlSetSamplingCycle;
		list[0x1F4011E6] = &sceCtrlSetSamplingMode;
		list[0x1F803938] = &sceCtrlPeekBufferPositive;
		list[0x3A622550] = &sceCtrlPeekBufferPositive;
	}
	
	void sceCtrlSetSamplingCycle() {
		writefln("sceCtrlSetSamplingCycle (%d)", a(0));
		cpu.regs[Registers.R.v0] = 0;
		cpu.ctrl.sampCycle = a(0);
	}
	
	void sceCtrlSetSamplingMode() {
		writefln("sceCtrlSetSamplingMode (%d)",  a(0));
		cpu.regs[Registers.R.v0] = cast(int)cpu.ctrl.sampMode;
		cpu.ctrl.sampMode = cast(Controller.Mode)a(0);
	}
	
	void sceCtrlPeekBufferPositive() {
		debug (bios_debug) writefln("sceCtrlPeekBufferPositive (%08X, %08X)", cpu.regs[Registers.R.a0], cpu.regs[Registers.R.a1]);
		Controller.Data data = cpu.ctrl.data;
		
		cpu.mem.writed(a(0), TA(data));
		cpu.regs[Registers.R.v0] = 1;
	}
}

alias uint  SceUInt;
alias uint  SceUID;
alias ulong SceSize;
alias uint  SceKernelThreadEntry; // ?
alias ulong SceKernelSysClock; // ?

struct SceKernelThreadInfo {
	SceSize     size;
	char[32]    name;
	SceUInt     attr;
	int     	status;
	SceKernelThreadEntry    entry;
	void *  	stack;
	int     	stackSize;
	void *  	gpReg;
	int     	initPriority;
	int     	currentPriority;
	int     	waitType;
	SceUID  	waitId;
	int     	wakeupCount;
	int     	exitStatus;
	SceKernelSysClock   runClocks;
	SceUInt     intrPreemptCount;
	SceUInt     threadPreemptCount;
	SceUInt     releaseCount;
}

class Module_ThreadManForUser : Module {
	static this() { BIOS_HLE.addModule("ThreadManForUser", Module_ThreadManForUser.classinfo); }
		
	this() {
		list[0x446D8DE6] = &sceKernelCreateThread;
		list[0xF475845D] = &sceKernelStartThread;
		list[0xE81CAF8F] = &sceKernelCreateCallback;
		list[0x82826F70] = &sceKernelSleepThreadCB;
		list[0x55C20A00] = &sceKernelCreateEventFlag;
		list[0x68DA9E36] = &sceKernelDelayThreadCB;
		list[0x9ACE131E] = &sceKernelSleepThread;
		list[0x9FA03CD3] = &sceKernelDeleteThread;
		list[0x293B45B8] = &sceKernelGetThreadId;
		
		list[0x4E3A1105] = &sceKernelWaitSema;
		list[0xD6DA4BA1] = &sceKernelCreateSema;
		list[0x3F53E640] = &sceKernelSignalSema;
		list[0x17C1684E] = &sceKernelReferThreadStatus;
	}

	psp_Thread[char[]] threads;
	Semaphore[char[]] sems;
	
	void sceKernelReferThreadStatus() {
		// int sceKernelReferThreadStatus(SceUID thid, SceKernelThreadInfo *info);
		writefln("sceKernelReferThreadStatus(0x%08X, 0x%08X)", a(0), a(1));
		
		SceKernelThreadInfo* info = cast(SceKernelThreadInfo*)cpu.mem.gptr(a(1));
		psp_Thread *thread = cast(psp_Thread *)cast(void*)a(0);
		
		info.size = SceKernelThreadInfo.sizeof;
		info.name[0..thread.name.length] = thread.name;
		info.name[thread.name.length] = 0;
		//info.attr = 0x999;
		
		retval = 0;
	}
	
	void sceKernelSignalSema() {
		/// 0 on success
		// int sceKernelSignalSema(SceUID semaid, int signal);
		writefln("sceKernelSignalSema(0x%08X, %d)", a(0), a(1));
		(cast(Semaphore *)cast(void *)a(0)).current = a(1);
	}
	
	void sceKernelGetThreadId() {
		// int sceKernelGetThreadId();
		writefln("sceKernelGetThreadId() : 0x%08X", cast(int)cast(void *)psp_Thread._current);
		retval = cast(int)cast(void *)&psp_Thread._current;
	}
	
	void sceKernelCreateSema() {
		char[] name = cpu.mem.readsz8(a(0));
		// SceUID sceKernelCreateSema(const char *name, SceUInt attr, int initVal, int maxVal, SceKernelSemaOptParam *option);
		sems[name] = Semaphore(a(1), a(2), a(3), a(4));
		retval = cast(int)&sems[name];
		writefln("sceKernelCreateSema('%s', %d, %d, %d, %d) : 0x%08X", name, a(1), a(2), a(3), a(4), cast(int)&sems[name]);
	}
	
	void sceKernelWaitSema() {
		// int sceKernelWaitSema(SceUID semaid, int signal, SceUInt *timeout);
		writefln("sceKernelWaitSema(0x%08X, %d, %d)", a(0), a(1), a(2));
		psp_Thread._current.wakeup = cast(Semaphore *)cast(void *)a(0);
		psp_Thread._current.waiting_value = a(1);
		psp_Thread.sleep();
		//cpu.regs.nPC = cpu.regs.PC;
		/*while (true) {
			Sleep(1);
		}*/
	}

	void sceKernelCreateThread() {
		char[] name = cpu.mem.readsz(a(0));
		threads[name] = new psp_Thread(bios, name, a(1), a(2), a(3), a(4), a(5));
		retval(cast(uint)&threads[name]);
		writefln("sceKernelCreateThread('%s', 0x%08X, %d, 0x%04X, 0x%02X, 0x%02X) : 0x%08X", cpu.mem.readsz8(a(0)), a(1), a(2), a(3), a(4), a(5), cast(uint)&threads[name]);
	}
	
	void sceKernelStartThread() {
		writefln("sceKernelStartThread(0x%08X)", a(0));
		psp_Thread thread = (*(cast(psp_Thread *)a(0)));

		cpu.regs[Registers.R.v0] = cpu.regs[Registers.R.a0];

		thread.start(a(1), a(2));
		
		//cpu.regs[Registers.R.a0] = cpu.regs[Registers.R.a1];
		//cpu.regs[Registers.R.a1] = cpu.regs[Registers.R.a2];
	}
	
	void sceKernelCreateCallback() {
		writefln("sceKernelCreateCallback ('%s',%08X,%08X) : %08X", cpu.mem.readsz8(a(0)), a(1), a(2), cpu.regs[Registers.R.v0]);
		Callback cb = bios.callbacks.create(cpu.mem.readsz8(a(0)), a(1), a(2));
		retval(cb.id);
	}
	
	void sceKernelSleepThread() {
		writefln("sceKernelSleepThread()");
		psp_Thread.sleep();
	}
	
	void sceKernelSleepThreadCB() {
		writefln("sceKernelSleepThreadCB()");
		psp_Thread.sleep();
	}
	
	void sceKernelCreateEventFlag() {
		writefln("sceKernelCreateEventFlag");
	}
	
	void sceKernelDelayThreadCB() {
		debug (debug_bios) writefln("sceKernelDelayThreadCB");
	}
	
	void sceKernelDeleteThread() {
		writefln("sceKernelDeleteThread(%d)", a(0));
		psp_Thread.remove(cast(psp_Thread*)cast(void*)a(0));
	}
}

class Module_sceSuspendForUser : Module {
	static this() { BIOS_HLE.addModule("sceSuspendForUser", Module_sceSuspendForUser.classinfo); }

	this() {
		list[0xEADB1BD7] = &sceKernelPowerLock;
		list[0x3AEE7261] = &sceKernelPowerUnlock;
	}
	
	void sceKernelPowerLock() {
		debug (bios_debug) writefln("sceKernelPowerLock");
	}

	void sceKernelPowerUnlock() {
		debug (bios_debug) writefln("sceKernelPowerUnlock");
	}
}

class Module_StdioForUser : Module { // Stdio
	static this() { BIOS_HLE.addModule("StdioForUser", Module_StdioForUser.classinfo); }

	this() {
		list[0x172D316E] = &sceKernelStdin;
		list[0xA6BAB2E9] = &sceKernelStdout;
		list[0xF78BA90A] = &sceKernelStderr;
	}

	void sceKernelStdin() {
		writefln("sceKernelStdin");
		retval(cast(int)cast(void*)std.cstream.din);
	}
	void sceKernelStdout() {
		writefln("sceKernelStdout");
		retval(cast(int)cast(void*)std.cstream.dout);
	}
	
	void sceKernelStderr() {
		writefln("sceKernelStderr");
		retval(cast(int)cast(void*)std.cstream.derr);
	}
}

class Module_LoadExecForUser : Module {
	static this() { BIOS_HLE.addModule("LoadExecForUser", Module_LoadExecForUser.classinfo); }

	this() {
		list[0x4AC57943] = &sceKernelRegisterExitCallback;
	}
	
	void sceKernelRegisterExitCallback() {
		writefln("sceKernelRegisterExitCallback (%08X)", a(0));
	}
}

class Module_Kernel_Library : Module {
	static this() { BIOS_HLE.addModule("Kernel_Library", Module_Kernel_Library.classinfo); }

	this() {
		list[0x092968F4] = &sceKernelCpuSuspendIntr;
		list[0x5F10D406] = &sceKernelCpuResumeIntr;
		//list[0x092968F4] = &sceKernelRegisterIntrHandler;
	}

	void sceKernelCpuSuspendIntr() {
		writefln("sceKernelCpuSuspendIntr");
		retval = cpu.regs.IC;
		cpu.regs.IC = 0;
		//mfic $v0, $0 # Copy state of INTC to $v0 for return
		//mtic $0, $0 # Set INTC status to 0
	}

	void sceKernelCpuResumeIntr() {
		writefln("sceKernelCpuResumeIntr");
		cpu.regs.IC = a(0);
		// mtic $a0, $0 # Set previous state
	}
	
	void sceKernelRegisterIntrHandler() {
		//writefln("sceKernelRegisterIntrHandler (%d, %d, 0x%08X, 0x%08X, 0x%08X)", a(0), a(1), a(2), a(3), a(4));
		//throw(new Exception("lawl"));
	}
}

class Module_ModuleMgrForUser : Module {
	static this() { BIOS_HLE.addModule("ModuleMgrForUser", Module_ModuleMgrForUser.classinfo); }
	
	this() {
		list[0xD675EBB8] = &sceKernelSelfStopUnloadModule;
	}
	
	void sceKernelSelfStopUnloadModule() {
		writefln("sceKernelSelfStopUnloadModule()");
		throw(new ExitException());
	}
}

class Module_UtilsForUser : Module { // Utils
	static this() { BIOS_HLE.addModule("UtilsForUser", Module_UtilsForUser.classinfo); }

	this() {
		list[0x79D1C3FA] = &sceKernelDcacheWritebackAll;
		list[0x71EC4271] = &sceKernelLibcGettimeofday;
		list[0x27CC57F0] = &sceKernelLibcTime;
		list[0xE860E75E] = &sceKernelUtilsMt19937Init;
		list[0x06FB8A63] = &sceKernelUtilsMt19937UInt;
	}
	
	/**
	 * Mersenne twister number stuff
	 * http://en.wikipedia.org/wiki/Mersenne_twister
	 
	   A C-program for MT19937, with initialization improved 2002/1/26.
	   Coded by Takuji Nishimura and Makoto Matsumoto.

	   Before using, initialize the state by using init_genrand(seed)  
	   or init_by_array(init_key, key_length).

	   Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
	   All rights reserved.                          

	   Redistribution and use in source and binary forms, with or without
	   modification, are permitted provided that the following conditions
	   are met:

		 1. Redistributions of source code must retain the above copyright
			notice, this list of conditions and the following disclaimer.

		 2. Redistributions in binary form must reproduce the above copyright
			notice, this list of conditions and the following disclaimer in the
			documentation and/or other materials provided with the distribution.

		 3. The names of its contributors may not be used to endorse or promote 
			products derived from this software without specific prior written 
			permission.

	   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
	   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
	   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
	   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


	   Any feedback is very welcome.
	   http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
	   email: m-mat @ math.sci.hiroshima-u.ac.jp (remove space)
	 */
	private
	{
		const int N = 624;
		const int M = 397;
		const uint MATRIX_A = 0x9908b0df;	// constant vector a
		const uint UPPER_MASK = 0x80000000;	// most significant w-r bits
		const uint LOWER_MASK = 0x7fffffff;	// least significant r bits
		
		static uint []mag01 = [ 0, MATRIX_A ];
	}

	void sceKernelDcacheWritebackAll() {
		debug (bios_debug) writefln("sceKernelDcacheWritebackAll");
	}
	
	void sceKernelLibcGettimeofday() {
		struct timeval {
			long tv_sec;
			long tv_usec;
		}
		timeval* tv = cast(timeval*)cpu.mem.gptr(a(0));
		tv.tv_sec = time(null);
		cpu.regs.v0 = tv.tv_sec;
		
		debug (bios_debug) writefln("sceKernelLibcGettimeofday (%d)", tv.tv_sec);
	}
	
	void sceKernelLibcTime() {
		debug (bios_debug) writefln("sceKernelLibcTime(0x%08X)", a(0));
		int* ptr;
		if (a(0)) ptr = cast(int*)cpu.mem.gptr(a(0));
		retval64(time(ptr));
	}
	
	/**
	 * Initializes the Mersenne twister number
	 */
	int sceKernelUtilsMt19937Init(int ctx, int seed)
	{
		debug (bios_debug) writefln("sceKernelUtilsMt19937Init(%d, %d)", ctx, seed);
		
		byte* pctx = cast(byte*)cpu.mem.gptr( cast( uint )ctx );
		uint* mt = cast( uint* )( pctx + 4 );
		int mti = *( cast( int* )pctx );
		
		mt[ 0 ] = cast( uint )seed & 0xffffffffU;
		for( mti = 1; mti < N; mti++ )
		{
			mt[ mti ] = cast( uint )( 1812433253U * ( mt[ mti - 1 ] ^ ( mt[ mti - 1 ] >> 30 ) ) + mti );
			/* See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier. */
			/* In the previous versions, MSBs of the seed affect   */
			/* only MSBs of the array mt[].                        */
			/* 2002/01/09 modified by Makoto Matsumoto             */
			mt[ mti ] &= 0xffffffffU;
			/* for >32 bit machines */
		}
		
		*( cast( int* )pctx ) = mti;
		
		return 0;
	}
	
	void sceKernelUtilsMt19937Init()
	{
		retval(sceKernelUtilsMt19937Init(a(0), a(1)));
	}
	
	/**
	 * Returns a new pseudo random number
	 */
	void sceKernelUtilsMt19937UInt()
	{
		int ctx = a(0);
		
		byte* pctx = cast(byte*)cpu.mem.gptr( cast( uint )ctx );
		uint* mt = cast( uint* )( pctx + 4 );
		int mti = *( cast( int* )pctx );
		
		// generates a random number on [0,0xffffffff]-interval
		uint y;
		/* mag01[x] = x * MATRIX_A  for x=0,1 */
		
		if( mti >= N )
		{
			// generate N words at one time
			int kk;
			
			if( mti == N + 1 )	   /* if init_genrand() has not been called, */
			{
				sceKernelUtilsMt19937Init( ctx, 5489 ); /* a default initial seed is used */
			}
			
			for( kk = 0; kk < N - M; kk++ )
			{
				y = ( mt[kk] & UPPER_MASK ) | ( mt[ kk + 1 ] & LOWER_MASK );
				mt[kk] = mt[ kk + M ] ^ ( y >> 1 ) ^ mag01[ y & 0x1UL ];
			}
			for( ; kk < N - 1; kk++ )
			{
				y = ( mt[kk] & UPPER_MASK ) | ( mt[ kk + 1 ] & LOWER_MASK );
				mt[kk] = mt[ kk + ( M - N ) ] ^ ( y >> 1 ) ^ mag01[ y & 0x1UL ];
			}
			y = ( mt[ N - 1 ] & UPPER_MASK ) | ( mt[0] & LOWER_MASK );
			mt[ N - 1 ] = mt[ M - 1 ] ^ ( y >> 1 ) ^ mag01[ y & 0x1UL ];
			
			mti = 0;
		}
		
		y = mt[ mti++ ];
		
		*( cast( int* )pctx ) = mti;
		
		/* Tempering */
		y ^= (y >> 11);
		y ^= (y << 7) & 0x9d2c5680U;
		y ^= (y << 15) & 0xefc60000U;
		y ^= (y >> 18);
		
		//return cast( int )y;
		retval((cast(int)y));
	}
}

class Module_scePower : Module { // POWER control
	static this() { BIOS_HLE.addModule("scePower", Module_scePower.classinfo); }
	
	this() {
		list[0x737486F2] = &scePowerSetClockFrequency;
	}
	
	void scePowerSetClockFrequency() {
		writefln("scePowerSetClockFrequency (%d, %d, %d)", a(0), a(1), a(2));
	}
}


class Module_sceReg : Module { // Registry
	static this() { BIOS_HLE.addModule("sceReg", Module_sceReg.classinfo); }

	this() {
		list[0x92E41280] = &sceRegOpenRegistry;
	}
	
	void sceRegOpenRegistry() {
		writefln("sceRegOpenRegistry()");
		retval = -1;
	}
}

class Module_SysMemUserForUser : Module {
	static this() { BIOS_HLE.addModule("SysMemUserForUser", Module_SysMemUserForUser.classinfo); }

	this() {
		list[0xA291F107] = &sceKernelMaxFreeMemSize;
		list[0x237DBD4F] = &sceKernelAllocPartitionMemory;
		list[0x9D9A5BA1] = &sceKernelGetBlockHeadAddr;
		list[0xB6D61D02] = &sceKernelFreePartitionMemory;
	}
	
	void sceKernelMaxFreeMemSize() {
		retval(bios.mman.getAvailable);
		writefln("sceKernelMaxFreeMemSize (%d)", cpu.regs[Registers.R.v0]);
	}

	void sceKernelAllocPartitionMemory() {
		// SceUID sceKernelAllocPartitionMemory(SceUID partitionid, const char *name, int type, SceSize size, void *addr);
		writefln("sceKernelAllocPartitionMemory (%d, '%s', %d, %d, %d)", a(0), cpu.mem.readsz8(a(1)), a(2), a(3), a(4));
		retval(bios.mman.partitionCreate(a(0), cpu.mem.readsz(a(1)), a(2), a(3), a(4)));
	}
	
	void sceKernelFreePartitionMemory() {
		writefln("sceKernelFreePartitionMemory (%d)", a(0));
		bios.mman.partitionRemove(a(0));
		retval(0);
	}
	
	void sceKernelGetBlockHeadAddr() {
		uint pos = bios.mman.partitions[a(0)].addr;
		writefln("sceKernelGetBlockHeadAddr(%d) : 0x%08X", a(0), pos);
		retval(pos);
	}
}

class Module_sceRtc : Module { // Real Time Clock
	static this() { BIOS_HLE.addModule("sceRtc", Module_sceRtc.classinfo); }

	this() {
		list[0xC41C2853] = &sceRtcGetTickResolution;
		list[0x3F7AD767] = &sceRtcGetCurrentTick;
	}
	
	void sceRtcGetTickResolution() {
		long frequency;
		std.c.windows.windows.QueryPerformanceFrequency(&frequency);
		retval(frequency);
	}
	
	void sceRtcGetCurrentTick() {
		int addr = a(0);
		if (addr != 0) {
			std.c.windows.windows.QueryPerformanceCounter(cast(long*)cpu.mem.gptr(addr));
		}
	}
}

class Module_sceAudio : Module {
	static this() { BIOS_HLE.addModule("sceAudio", Module_sceAudio.classinfo); }

	this() {
		list[0x5EC81C55] = &sceAudioChReserve;
		list[0x13F592BC] = &sceAudioOutputPannedBlocking;
	}
	
	void sceAudioChReserve() {
		// int sceAudioChReserve(int channel, int samplecount, int format);
		writefln("sceAudioChReserve");
		retval(a(0));
	}
	
	
	void sceAudioOutputPannedBlocking() {
		writefln("sceAudioOutputPannedBlocking");
		retval(0);
	}
}

// BIOS HLE (High Level Emulation)
class BIOS : IBIOS {
	static BIOS bios;

	struct IMP_Info {
		char[] name;
		uint nid;
		char[] impName;
	}

	psp_Thread[char[]] threads;
	bool vblank = false;
	bool waitVBlank = false;
	Module[char[]] modules;
	void delegate()[uint] jump0_list;
	IMP_Info[uint] imp_list;
	MemoryManager mman;
	Callbacks callbacks;
	
	static ClassInfo[char[]] modulesInfo;
	
	char[] addInfo(uint addr) {
		if (addr in imp_list) {
			return imp_list[addr].impName;
		}
		return std.string.format("addr_%08X", addr);
	}

	static void addModule(char[] name, ClassInfo classinfo) {
		modulesInfo[name] = classinfo;
	}
	
	static void addDevice(char[][] names, Device device) {
		foreach (name; names) Device.list[name] = device;
	}

	Module getModule(char[] name) {
		if (name in modules) return modules[name];
		if ((name in modulesInfo) is null) return null;
		Module _module = cast(Module)Object.factory(modulesInfo[name].name);
		return modules[name] = _module;
	}

	this() {
		writefln("BIOS.this()");
		bios = this;
	}
	
	void init() {
		writefln("BIOS.init()");
		mman = new MemoryManager();
		callbacks = new Callbacks();
		
		cpu.mem.interrupts.callbacks[INTS.THREAD0] = &threadTick;
	}
	
	void start() {
		(psp_Thread._current = new psp_Thread(bios, "Main Thread", 0, 0, 0x1000, 0, 0)).sleeping = false;
	}
	
	void threadTick() {
		//writefln("threadTick");
		psp_Thread.next();
	}
	
	void reset() {
		writefln("BIOS.reset");
		foreach (id; modules.keys) modules.remove(id);
		foreach (id; jump0_list.keys) jump0_list.remove(id);
		foreach (id; imp_list.keys) imp_list.remove(id);
		mman.reset();
		psp_Thread.reset();
		callbacks.reset();
		Device.reset();
	}
	
	// call local imp
	void jump0(uint addr) {
		cpu._return();
	
		if ((addr in jump0_list) is null) {
			char[] error;
			cpu.regs.nPC = cpu.regs[cpu.regs.R.ra];
			if (addr in imp_list) {
				IMP_Info info = imp_list[addr];
				error = std.string.format("JUMP0 %08X unimplemented\n%s\n%08X: %s", addr, info.name, info.nid, info.impName);
			} else {
				error = std.string.format("JUMP0 %08X unimplemented", addr);
			}
			throw(new InterruptException(error));
			writefln("%s", error);
		}
		
		jump0_list[addr]();
	}
	
	void setImpNative(uint addr, char[] name, uint nid, char[] impName) {
		imp_list[addr] = IMP_Info(name, nid, impName);
	
		Module _module = getModule(name);		
		
		if (_module) {
			auto callback = _module.getCallback(nid);
			if (callback) jump0_list[addr] = callback;
		} else {
			//writefln("Can't locate module '%s'", name);
		}
	}	

	void syscall(uint code) {
		Memory mem = cpu.mem;
		Registers regs = cpu.regs;
		
		//writefln("syscall: %08X", code);
		
		switch (code) {
			case 0x00000: //
				usleep(1000);
			break;
			case 0x00001: // TEST specific print
				writefln("STDOUT: %s", mem.readsz(regs.a(0)));
			break;
			case 0x00002: // sceKernelSleepThread
				writefln("sceKernelSleepThread");
				psp_Thread.sleep();
			break;
			case 0x0206D: // _sceKernelCreateThread
				char[] name = mem.readsz(regs.a(0));
				threads[name] = new psp_Thread(bios, name, regs.a(1), regs.a(2), regs.a(3), regs.a(4), regs.a(5));
				regs.v0 = cast(uint)&threads[name];	
			break;
			case 0x0206F: // _sceKernelStartThread
				(*(cast(psp_Thread *)regs.a(0))).start(regs.a(1), regs.a(2));
			break;
			case 0x02071: // _sceKernelExitThread
				writefln("Thread terminated (_sceKernelExitThread)");
				psp_Thread.sleep();
				//throw(new ExitException());
			break;
			case 0x020EB: // _sceKernelExitGame
				writefln("%08X", regs.PC - 4);
				writefln("Thread terminated (_sceKernelExitGame)");
				throw(new ExitException());
			break;
			case 0x020BF: // _sceKernelUtilsMt19937Init
				// PTR
				//regs.a(0)
			break;
			case 0x020C0: // _sceKernelUtilsMt19937UInt
				// PTR
				//regs.a(0)
				regs.v0 = rand();				
				//regs.v0 = 0x_7F_83_45_F1;
				//writefln("SetMode (%d,%d,%d)", regs.a(0), regs.a(1), regs.a(2));
			break;
			case 0x0213A: // _sceDisplaySetMode
				writefln("SetMode (%d,%d,%d)", regs.a(0), regs.a(1), regs.a(2));
			break;
			case 0x02150: // _sceCtrlPeekBufferPositive
				// SceCtrlData 
				Controller.Data data = cpu.ctrl.data;
				//data.Buttons = !data.Buttons;
				//writefln("%032b : %08X, %08X", data.Buttons, regs.a(0), regs.a(1));
				mem.writed(regs.a(0), TA(data));

				//writefln("%08X", ptr);
				//writefln("%08X", regs.a(0));
				//regs[8] = 1;
			break;
			case 0x0213F: // _sceDisplaySetFrameBuf - void sceDisplaySetFrameBuf(void *topaddr, int bufferwidth, int pixelformat, int sync);
				cpu.gpu.drawBuffer.ptr = regs.a(0);				
				//writefln("%08X", );
				// no espera
			break;
			case 0x02147: // _sceDisplayWaitVblankStart
				//printf("#");
				//printf("*");
				while (!vblank) usleep(1000);
				vblank = false;
			break;
			default:
				writefln("Unknown syscall!! 0x%05X: // %s", code, CPU_Disasm.syscall(code));
			break;
		}
		
		//regs.dump();
	}	
}

struct Callback {
	uint id;
	char[] name;
	uint ptr;
	uint arg;
}

class Callbacks {
	static private Callback[uint] list_i;
	static private uint nextId = 1;
	
	this() {
	}
	
	Callback get(uint id) {
		return list_i[id];
	}
	
	Callback create(char[] _name, uint _ptr, uint _arg) {
		Callback callback;
		with (callback) {
			id   = nextId++;
			name = _name;
			ptr  = _ptr;
			arg  = _arg;
		}
		list_i[callback.id] = callback;
		return callback;
	}
	
	bool remove(uint id) {
		if (!(id in list_i)) return false;
		list_i.remove(id);
		return true;
	}

	void call(uint id, uint[] params) {
		Callback callback = get(id);
		writefln("Calling (%s, 0x%08X, 0x%08X)", callback.name, callback.ptr, callback.arg);
		// TODO: save arguments
		foreach (k, v; params) cpu.regs.r[Registers.R.a0 + k] = v;
		cpu.regs.r[31] = cpu.regs.PC;
		cpu.regs._PC = callback.ptr;
	}
	
	void reset() {
		foreach (k; list_i.keys) list_i.remove(k);
		nextId = 1;
	}
}

// -----------------------
//  KERNEL MEMORY MANAGER
// -----------------------

class MemoryManager {
	struct Segment {
		uint from;
		uint length;
		uint to() { return from + length; }
		static Segment create(uint from, uint to) {
			Segment s = void;
			s.from = from;
			s.length = cast(ulong)to - cast(ulong)from;
			return s;
		}
		static void add(inout Segment[] list, int from, int to) {
			if (from >= to) return;
			list ~= create(from, to);
		}
	}

	int[int] alloc_segments;
	
	Segment[] used() {
		Segment[] r;
		foreach (ptr; alloc_segments.keys.sort) r ~= Segment(ptr, alloc_segments[ptr]);
		return r;
	}

	Segment[] unused() {
		Segment[] u = used;
		Segment[] r;
		int m_s = Memory.main_addr + 0x800000; // 8MB kernel
		int m_e = Memory.main_addr + (Memory.main_mask + 1) - 4;
		int u_s, u_e;
		
		if (!u.length) {	
			r ~= Segment.create(m_s, m_e);
			return r;
		}
		
		u_s = u[0].from;
		u_e = u[u.length - 1].to;
		
		// First segment
		Segment.add(r, m_s, u_s);

		// Middle segments
		for (int n = 0, count1 = u.length - 1; n < count1; n++) Segment.add(r, u[n].to, u[n + 1].from);

		// Last segment
		Segment.add(r, u_e, m_e);
		
		return r;
	}
	
	// Use a memory segment
	uint use(uint ptr, uint len) {
		alloc_segments[ptr] = len;
		//debug(bios_memory) writefln("MemoryManager.use(0x%08X, %d);", ptr, length);
		debug(bios_memory) writefln("MemoryManager.use(0x%08X, 0x%08X);", ptr, len);
		return ptr;
	}
	
	// Alloc a segment of length
	uint allocHeap(uint length) {
		foreach (s; unused) if (s.length >= length) return use(s.from, length);
		throw(new Exception(std.string.format("Can't alloc %d", length)));
		return 0;
	}
	
	alias allocHeap alloc;
	
	uint allocStack(uint length) {
		foreach (s; unused.reverse) if (s.length >= length) return use(s.from + s.length - length, length);
		throw(new Exception(std.string.format("Can't alloc %d", length)));
		return 0;		
	}

	// Free memory pointer
	void free(uint ptr) {
		alloc_segments.remove(ptr);
		debug(bios_memory) writefln("MemoryManager.free(0x%08X)", ptr);
	}

	// Memory stats
	
	// Total memory in ram
	int getTotal() {
		return Memory.main_mask + 1;
	}
	
	// Memory used
	int getUsed() {
		int used;
		foreach (len; alloc_segments) used += len;
		return used;
	}
	
	// Memory available
	int getTotalAvailable() {
		return getTotal - getUsed;
	}

	// Memory available
	int getAvailable() {
		int max = 0;
		foreach (s; unused) {
			//writefln("FREE: %d", s.length);
			if (s.length > max) max = s.length;
		}
		return max;
	}
	
	///////////////////////////////////////////////////////////////////////////////	
	// PARTITIONS                                                                //
	///////////////////////////////////////////////////////////////////////////////
	/*
		http://wiki.ps2dev.org/psp:memory_map
	
		The following table is based on results from calling sceKernelQueryMemoryPartitionInfo.
		Partition 	Start Address 	Size 	Unknown 	Description
		1 	0×88000000	0×00300000 (3 MiB)	0xC 	Kernel 1
		2 	0×08000000	0×01800000 (24 MiB)	0xF 	User
		3 	0×88000000	0×00300000 (3 MiB)	0xC 	Kernel 1
		4 	0×88300000	0×00100000 (1 MiB)	0xC 	Kernel 2
		5 	0×88400000	0×00400000 (4 MiB)	0xF 	Kernel 3
		6 	0×08800000	0×01800000 (24 MiB)	0xF 	User
	*/	
	
	struct MemoryPartition {
		uint id;
		char[] name;
		int addr;
		int raddr;
		int size;
		int type;
	}

	MemoryPartition[uint] partitions;
	
	void partitionRemove(uint id) {
		if ((id in partitions) is null) throw(new Exception("Invalid Memory Partition"));
		free(partitions[id].addr);
		partitions.remove(id);
	}
	
	uint partitionCreate(uint id, char[] name, int type, int size, int addr) {
		if ((id in partitions)) throw(new Exception("Recreating Memory Partition"));
		MemoryPartition mp;
		mp.id = id + 1;
		mp.name = name;
		mp.raddr = addr;
		mp.type = type;
		//mp.addr = alloc(mp.size = size);
		mp.addr = 0x08_800000;
		partitions[id] = mp;
		return id;
	}

	// Reset allocs
	void reset() {
		writefln("MemoryManager.reset");
		foreach (k; alloc_segments.keys) alloc_segments.remove(k);
		foreach (k; partitions.keys) partitions.remove(k);
		
		partitionCreate(1, "kernel", 0, 0x800000, 0x08_000000);
		//partitionCreate(2, "user", 0, 0x200000, 0x08_800000);
	}	
}

alias BIOS BIOS_HLE;