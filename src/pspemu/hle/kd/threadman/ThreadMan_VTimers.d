module pspemu.hle.kd.threadman.ThreadMan_VTimers;

import pspemu.core.exceptions.HaltException;

import pspemu.utils.sync.WaitEvent;
import pspemu.utils.sync.WaitMultipleObjects;

import pspemu.hle.HleEmulatorState;
import pspemu.core.ThreadState;
import pspemu.core.Memory;
import core.thread;

import pspemu.hle.kd.threadman.Types;

import pspemu.utils.Logger;
import pspemu.utils.String;

import std.datetime;
import std.stdio;

HleEmulatorState hleEmulatorState;
@property public Memory currentMemory() { return null; }

/**
 * Events related stuff.
 */
template ThreadManForUser_VTimers() {
	void initModule_VTimers() {
		
	}
	
	void initNids_VTimers() {
	    mixin(registerFunction!(0x20FFF560, sceKernelCreateVTimer));
	    mixin(registerFunction!(0xD2D615EF, sceKernelCancelVTimerHandler));
	    mixin(registerFunction!(0xD8B299AE, sceKernelSetVTimerHandler));
	    mixin(registerFunction!(0xC68D9437, sceKernelStartVTimer));
	    mixin(registerFunction!(0xD0AEEE87, sceKernelStopVTimer));
	    mixin(registerFunction!(0x034A921F, sceKernelGetVTimerTime));
	    mixin(registerFunction!(0xC0B3FFD2, sceKernelGetVTimerTimeWide));
	}
	
	/**
	 * Create a virtual timer
	 *
	 * @param name - Name for the timer.
	 * @param opt  - Pointer to an ::SceKernelVTimerOptParam (pass NULL)
	 *
	 * @return The VTimer's UID or < 0 on error.
	 */
	SceUID sceKernelCreateVTimer(string name, SceKernelVTimerOptParam *opt) {
		VTimer vTimer = new VTimer(name);
		vTimer.info = hleEmulatorState.memoryManager.callocHost!SceKernelVTimerInfo();
		vTimer.info.size = vTimer.info.sizeof; 
		setFixedStringz(vTimer.info.name, name);
		return uniqueIdFactory().add(vTimer);
	}
	
	/**
	 * Cancel the timer handler
	 *
	 * @param uid - The UID of the vtimer
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelCancelVTimerHandler(SceUID uid) {
		VTimer vTimer = uniqueIdFactory().get!VTimer(uid);
		hleEmulatorState.memoryManager.free(currentMemory().getPointerReverseOrNull(vTimer.info));
		return 0;
	}

	/**
	 * Start a virtual timer
	 *
	 * @param uid - The UID of the timer
	 *
	 * @return < 0 on error
	 */
	int sceKernelStartVTimer(SceUID uid) {
		unimplemented_notice();
		VTimer vTimer = uniqueIdFactory().get!VTimer(uid);
		vTimer.start();
		return 0;
	}
	
	/**
	 * Stop a virtual timer
	 *
	 * @param uid - The UID of the timer
	 *
	 * @return < 0 on error
	 */
	int sceKernelStopVTimer(SceUID uid) {
		VTimer vTimer = uniqueIdFactory().get!VTimer(uid);
		vTimer.stop();
		return 0;
	}


	/**
	 * Get the timer time
	 *
	 * @param uid - UID of the vtimer
	 * @param time - Pointer to a ::SceKernelSysClock structure
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelGetVTimerTime(SceUID uid, SceKernelSysClock *time) {
		unimplemented_notice();
		VTimer vTimer = uniqueIdFactory().get!VTimer(uid);
		long v = vTimer.get();
		*time = *(cast(SceKernelSysClock*)&v);
		return 0;
	}
	
	/**
	 * Get the timer time (wide format)
	 *
	 * @param uid - UID of the vtimer
	 *
	 * @return The 64bit timer time
	 */
	SceInt64 sceKernelGetVTimerTimeWide(SceUID uid) {
		unimplemented_notice();
		VTimer vTimer = uniqueIdFactory().get!VTimer(uid);
		return vTimer.get();
	}
	
	/**
	 * Set the timer handler.
	 * Timer handler will be executed once after
	 *
	 * @param uid     - UID of the vtimer
	 * @param time    - Time to call the handler?
	 * @param handler - The timer handler
	 * @param common  - Common pointer
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelSetVTimerHandler(SceUID uid, SceKernelSysClock *time, SceKernelVTimerHandler handler, /*void**/uint common) {
		VTimer vTimer = uniqueIdFactory().get!VTimer(uid);
		
		ulong utime = time.v64;
		vTimer.info.common = cast(void*)common;
		vTimer.info.handler = handler;
		vTimer.info.schedule = *time;
		
		void addToExecute() {
			hleEmulatorState.callbacksHandler.addToExecuteQueue(
				handler,
				[
					uid,
					cast(uint)currentMemory().ptrHostToGuest!SceKernelSysClock(&vTimer.info.schedule),
					cast(uint)currentMemory().ptrHostToGuest!SceKernelSysClock(&vTimer.info.schedule),
					cast(uint)vTimer.info.common
				]
			);
			//writefln("################################################");
		}
		
		addToExecute();
		
		/*
		Thread thread = new Thread({
			// @FAKE!! Implement it properly.
			Thread.sleep(dur!"usecs"(utime));

			hleEmulatorState.callbacksHandler.addToExecuteQueue(
				handler,
				[
					uid,
					cast(uint)currentMemory().ptrHostToGuest!SceKernelSysClock(&vTimer.info.schedule),
					cast(uint)currentMemory().ptrHostToGuest!SceKernelSysClock(&vTimer.info.schedule),
					cast(uint)vTimer.info.common
				]
			);
			
		});
		thread.name = "VTIMER-" ~ vTimer.name;
		thread.start();
		*/
		
		return 0;
	}
	
	/**
	 * Set the timer handler (wide mode)
	 *
	 * @param uid     - UID of the vtimer
	 * @param time    - Time to call the handler?
	 * @param handler - The timer handler
	 * @param common  - Common pointer
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelSetVTimerHandlerWide(SceUID uid, SceInt64 time, SceKernelVTimerHandlerWide handler, void *common) {
		unimplemented();
		return 0;
	}
}

class VTimer {
	string name;
	SceKernelVTimerInfo* info;
	bool running;
	SysTime startTime;
	SysTime _endTime;
	
	this(string name) {
		this.name = name;
		running = false;
		_endTime = startTime = now();
	}
	
	SysTime now() {
		return Clock.currTime();
	}
	
	void start() {
		startTime = now() - (lastTime - startTime);
		running = true;
	}
	
	void stop() {
		running = false;
		_endTime = now();
	}
	
	@property SysTime lastTime() {
		if (running) return now();
		return _endTime;
	}
	
	long get() {
		return (lastTime - startTime).total!"usecs";
	}
}
