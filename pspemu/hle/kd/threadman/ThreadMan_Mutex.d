module pspemu.hle.kd.threadman.ThreadMan_Mutex;

//import pspemu.hle.kd.threadman_common;

import std.math;
import std.stdio;
import std.c.stdlib;
import core.thread;

import pspemu.utils.MathUtils;

import pspemu.hle.kd.Types;
import pspemu.hle.kd.threadman.Types;

import pspemu.core.EmulatorState;
import pspemu.core.exceptions.HaltException;
import pspemu.core.ThreadState;

import pspemu.hle.HleEmulatorState;

import core.sync.condition;
import core.sync.mutex;

import pspemu.utils.sync.WaitObject;
import pspemu.utils.sync.WaitEvent;
import pspemu.utils.sync.WaitSemaphore;
import pspemu.utils.sync.WaitMutex;
import pspemu.utils.sync.WaitMultipleObjects;

import pspemu.hle.kd.SceKernelErrors;

import std.c.windows.windows;

/*
CreateMutex(
  __in_opt  LPSECURITY_ATTRIBUTES lpMutexAttributes,
  __in      BOOL bInitialOwner,
  __in_opt  LPCTSTR lpName
);
*/

template ThreadManForUser_Mutex() {
	void initModule_Mutex() {
	}

	void initNids_Mutex() {
	    mixin(registerd!(0xB7D098C6, sceKernelCreateMutex));
	    mixin(registerd!(0xB011B11F, sceKernelLockMutex));
	    mixin(registerd!(0x6B30100F, sceKernelUnlockMutex));
	}
	
	SceUID sceKernelCreateMutex(string name, int attr, int count, void* option_addr) {
		PspMutex mutex = new PspMutex(name);
		uint uid = uniqueIdFactory.add(mutex);
		logTrace("sceKernelCreateMutex(%d:'%s') :: %s", uid, name, mutex);
		return uid;
	}
	
	int sceKernelLockMutex(SceUID uid, int count, uint* timeout_addr) {
		PspMutex mutex = uniqueIdFactory.get!PspMutex(uid);
		mutex.lock(count);
		return 0;
	}
	
	int sceKernelUnlockMutex(SceUID uid, int count) {
		PspMutex mutex = uniqueIdFactory.get!PspMutex(uid);
		mutex.unlock(count);
		return 0;
	}
}

class PspMutex {
	string name;
	WaitMutex waitObject;
	
	this(string name) {
		this.name = name;
		waitObject = new WaitMutex(name);
	}
	
	void lock(int count) {
		if (count != 1) throw(new Exception("PspMutex.lock count != 1"));
		waitObject.wait();
	}
	
	void unlock(int count) {
		if (count != 1) throw(new Exception("PspMutex.unlock count != 1"));
		waitObject.release();
	}
}
