module pspemu.hle.kd.threadman.ThreadMan_Semaphores;

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
import pspemu.utils.sync.WaitMultipleObjects;

import pspemu.hle.kd.SceKernelErrors;

import std.c.windows.windows;

template ThreadManForUser_Semaphores() {
	//PspSemaphoreManager semaphoreManager;

	void initModule_Semaphores() {
		//threadManager = new PspThreadManager(this);
		//semaphoreManager = new PspSemaphoreManager(this);
	}

	void initNids_Semaphores() {
		mixin(registerFunction!(0xD6DA4BA1, sceKernelCreateSema));
		mixin(registerFunction!(0x3F53E640, sceKernelSignalSema));
		mixin(registerFunction!(0x28B6489C, sceKernelDeleteSema));
		mixin(registerFunction!(0x4E3A1105, sceKernelWaitSema));
		mixin(registerFunction!(0x58B1F937, sceKernelPollSema));
		mixin(registerFunction!(0x6D212BAC, sceKernelWaitSemaCB));
		mixin(registerFunction!(0xBC6FEBC5, sceKernelReferSemaStatus));
		mixin(registerFunction!(0x8FFDF9A2, sceKernelCancelSema));
	}
	
	enum SemaphoreAttribute : uint {
	    PSP_SEMA_ATTR_FIFO     = 0,       // Signal waiting threads with a FIFO iterator.
	    PSP_SEMA_ATTR_PRIORITY = 0x100,   // Signal waiting threads with a priority based iterator.
	}
	
	/**
	 * Creates a new semaphore
	 *
	 * @par Example:
	 * @code
	 * int semaid;
	 * semaid = sceKernelCreateSema("MyMutex", 0, 1, 1, 0);
	 * @endcode
	 *
	 * @param name      - Specifies the name of the sema
	 * @param attr      - Sema attribute flags (normally set to 0)
	 * @param initCount - Sema initial value 
	 * @param maxCount  - Sema maximum value
	 * @param option    - Sema options (normally set to 0)
	 *
	 * @return A semaphore id
	 */
	SceUID sceKernelCreateSema(string name, SemaphoreAttribute attr, int initCount, int maxCount, SceKernelSemaOptParam* option) {
		auto semaphore = new PspSemaphore(name, attr, initCount, maxCount);
		uint uid = uniqueIdFactory.add(semaphore);
		logTrace("sceKernelCreateSema(%d:'%s') :: %s", uid, name, semaphore);
		return uid;
	}
	
	/**
	 * Send a signal to a semaphore
	 *
	 * @par Example:
	 * @code
	 * // Signal the sema
	 * sceKernelSignalSema(semaid, 1);
	 * @endcode
	 *
	 * @param semaid - The sema id returned from sceKernelCreateSema
	 * @param signal - The amount to signal the sema (i.e. if 2 then increment the sema by 2)
	 *
	 * @return < 0 On error.
	 */
	int sceKernelSignalSema(SceUID semaid, int signal) {
		try {
			auto semaphore = uniqueIdFactory.get!PspSemaphore(semaid); 
			logInfo("sceKernelSignalSema(%d:'%s', %d) :: %s", semaid, semaphore.name, signal, semaphore);
			semaphore.incrementCount(signal);
			return 0;
		} catch (UniqueIdNotFoundException) {
			logWarning("Semaphore(semaid=%d) Not Found!", semaid);
			return SceKernelErrors.ERROR_KERNEL_NOT_FOUND_SEMAPHORE;
		}
	}
	
	/**
	 * Destroy a semaphore
	 *
	 * @param semaid - The semaid returned from a previous create call.
	 *
	 * @return Returns the value 0 if its succesful otherwise -1
	 */
	int sceKernelDeleteSema(SceUID semaid) {
		try {
			PspSemaphore pspSemaphore = uniqueIdFactory.get!PspSemaphore(semaid);
			logTrace("sceKernelDeleteSema(%d:'%s')", semaid, pspSemaphore.name);
			
			while (pspSemaphore.info.numWaitThreads > 0) {
				pspSemaphore.incrementCount(pspSemaphore.info.maxCount);
				Thread.yield();
			}
			
			uniqueIdFactory.remove!PspSemaphore(semaid);
			return 0;
		} catch (UniqueIdNotFoundException) {
			logWarning("Semaphore(semaid=%d) Not Found!", semaid);
			return SceKernelErrors.ERROR_KERNEL_NOT_FOUND_SEMAPHORE;
		}
	}
	
	int _sceKernelWaitSemaCB(SceUID semaid, int signal, SceUInt *timeout, bool callback) {
		try {
			PspSemaphore pspSemaphore = uniqueIdFactory.get!PspSemaphore(semaid);
			logInfo("sceKernelWaitSema%s(%d:'%s', %d, %d) :: %s", callback ? "CB" : "", semaid, pspSemaphore.name, signal, (timeout is null) ? 0 : *timeout, pspSemaphore);
	
			currentCpuThread.threadState.waitingBlock(std.string.format("_sceKernelWaitSemaCB(%d)", semaid), {
				pspSemaphore.waitSignal(hleEmulatorState, currentThreadState, signal, (timeout !is null) ? *timeout : uint.max, callback);
			});
			return 0;
		} catch (UniqueIdNotFoundException) {
			return SceKernelErrors.ERROR_KERNEL_NOT_FOUND_SEMAPHORE;
		}
	}
	
	/**
	 * Lock a semaphore
	 *
	 * @par Example:
	 * @code
	 * sceKernelWaitSema(semaid, 1, 0);
	 * @endcode
	 *
	 * @param semaid  - The sema id returned from sceKernelCreateSema
	 * @param signal  - The value to wait for (i.e. if 1 then wait till reaches a signal state of 1 or greater)
	 * @param timeout - Timeout in microseconds (assumed).
	 *
	 * @return < 0 on error.
	 */
	int sceKernelWaitSema(SceUID semaid, int signal, SceUInt* timeout) {
		return _sceKernelWaitSemaCB(semaid, signal, timeout, /* callback = */ false);
	}
	
	/**
	 * Lock a semaphore a handle callbacks if necessary.
	 *
	 * @par Example:
	 * @code
	 * sceKernelWaitSemaCB(semaid, 1, 0);
	 * @endcode
	 *
	 * @param semaid  - The sema id returned from sceKernelCreateSema
	 * @param signal  - The value to wait for (i.e. if 1 then wait till reaches a signal state of 1)
	 * @param timeout - Timeout in microseconds (assumed).
	 *
	 * @return < 0 on error.
	 */
	int sceKernelWaitSemaCB(SceUID semaid, int signal, SceUInt *timeout) {
		return _sceKernelWaitSemaCB(semaid, signal, timeout, /* callback = */ true);
	}


	/**
	 * Poll a sempahore.
	 *
	 * @param semaid - UID of the semaphore to poll.
	 * @param signal - The value to test for.
	 *
	 * @return < 0 on error.
	 */
	int sceKernelPollSema(SceUID semaid, int signal) {
		if (signal <= 0) return SceKernelErrors.ERROR_KERNEL_ILLEGAL_COUNT;

		try {
			PspSemaphore pspSemaphore = uniqueIdFactory.get!PspSemaphore(semaid);
			
			if (pspSemaphore.info.currentCount - signal < 0) return SceKernelErrors.ERROR_KERNEL_SEMA_ZERO;

			pspSemaphore.info.currentCount -= signal;
			return 0;
		} catch (UniqueIdNotFoundException) {
			return SceKernelErrors.ERROR_KERNEL_NOT_FOUND_SEMAPHORE;
		}
	}

	/**
	 * Retrieve information about a semaphore.
	 *
	 * @param semaid - UID of the semaphore to retrieve info for.
	 * @param info   - Pointer to a ::SceKernelSemaInfo struct to receive the info.
	 *
	 * @return < 0 on error.
	 */
	int sceKernelReferSemaStatus(SceUID semaid, SceKernelSemaInfo* info) {
		auto semaphore = uniqueIdFactory.get!PspSemaphore(semaid);
		*info = semaphore.info;
		return 0;
	}
	
	void sceKernelCancelSema() {
		unimplemented();
	}
}

class PspSemaphore {
	string name;
	SceKernelSemaInfo info;
	WaitEvent waitEvent;
	
	this(string name, int attr, int initCount, int maxCount) {
		this.waitEvent = new WaitEvent(name);

		this.name = name;

		this.info.size = this.info.sizeof; 
		this.info.name[] = 0;
		this.info.name[0..name.length] = name[0..$];
		this.info.attr           = attr;
		this.info.initCount      = initCount;
		this.info.currentCount   = initCount;
		this.info.maxCount       = maxCount;
		this.info.numWaitThreads = 0;
	}

	public void incrementCount(int count) {
		this.info.currentCount = min(this.info.maxCount, this.info.currentCount + count);
		//writefln("Currentcount: %d", );
		this.waitEvent.signal();
	}
	
	public void waitSignal(HleEmulatorState hleEmulatorState, ThreadState threadState, int signal, uint timeoutMicroseconds, bool handleCallbacks) {
		uint timeoutMilliseconds = uint.max;
		if (timeoutMicroseconds != uint.max) {
			timeoutMilliseconds = timeoutMicroseconds / 1000; 
		}
		// @TODO: ignored timeout
		info.numWaitThreads++; scope (exit) info.numWaitThreads--;
		
		WaitMultipleObjects waitMultipleObjects = new WaitMultipleObjects(threadState);
		waitMultipleObjects.add(this.waitEvent);
		waitMultipleObjects.add(threadState.emulatorState.runningState.stopEventCpu);
		if (handleCallbacks) waitMultipleObjects.add(hleEmulatorState.callbacksHandler.waitEvent);
		
		while (this.info.currentCount < signal) {
			waitMultipleObjects.waitAny(timeoutMilliseconds);
		}
		info.currentCount -= signal;
		//writefln("*** %d", info.currentCount);
	}
	
	public string toString() {
		return std.string.format("PspSemaphore(init:%d, current:%d, max:%d)", info.initCount, info.currentCount, info.maxCount);
	}
}