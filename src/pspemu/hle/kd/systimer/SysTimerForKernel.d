module pspemu.hle.kd.systimer.SysTimerForKernel; // kd/systimer.prx (sceSystimer)

import std.stdio;

import core.thread;

import pspemu.hle.ModuleNative;
import pspemu.hle.HleEmulatorState;
import pspemu.hle.MemoryManager;
import pspemu.core.EmulatorState;
import pspemu.core.ThreadState;

class SysTimer {
	HleEmulatorState hleEmulatorState;
	ThreadState threadState;
	Thread sysTimerThread;
	const uint CYCLES_PER_CSECOND = 4194303;
	int cycles = 4194303;
	uint handler;
	uint delegate() nativeHandler;
	int unk1;
	
	this(HleEmulatorState hleEmulatorState, ThreadState threadState) {
		this.hleEmulatorState = hleEmulatorState;
		this.threadState = threadState.clone();
		this.threadState.registers.SP = hleEmulatorState.memoryManager.allocStack(PspPartition.User, "STACK", 0x8000);
		this.sysTimerThread = new Thread(&run);
	}
	
	protected void run() {
		//while (emulatorState.runningState.running)
		try {
			while (true) {
				//threadState.threadModule.hleEmulatorState.executeGuestCode(threadState, handler);
				hleEmulatorState.callbacksHandler.addToExecuteQueue(handler);
				uint msecsToWait = (cycles * 100) / CYCLES_PER_CSECOND;
				Thread.sleep(dur!("msecs")(msecsToWait));
			}
		} catch (Throwable o) {
			writefln("SysTimer.Exception: %s", o);
		}
	}
	
	public void setHandler(int cycles, uint handler, int unk1) {
		this.cycles = cycles;
		this.handler = handler;
		//this.nativeHandler = threadState.threadModule.hleEmulatorState.createExecuteGuestCode(threadState, handler);
		this.unk1 = unk1;
	}
	
	public void start() {
		sysTimerThread.start();
	}
}

alias int SceSysTimerId;

class SysTimerForKernel : HleModuleHost {
	mixin TRegisterModule;
	
	void initNids() {
		mixin(registerFunction!(0xC99073E3, sceSTimerAlloc));
		mixin(registerFunction!(0x975D8E84, sceSTimerSetHandler));
		mixin(registerFunction!(0xA95143E2, sceSTimerStartCount));
	}

	/**
	 * Allocate a new SysTimer timer instance.
	 *
	 * @return SysTimerId on success, < 0 on error
	 */
	SceSysTimerId sceSTimerAlloc() {
		SceSysTimerId sysTimerId = uniqueIdFactory.add!SysTimer(new SysTimer(hleEmulatorState, currentThreadState));
		logInfo("sceSTimerAlloc() : %d", sysTimerId);
		return sysTimerId;
	}

	/**
	 * Setup a SysTimer handler
	 *
	 * @param timer   - The timer id.
	 * @param cycle   - The timer cycle in microseconds (???). Maximum: 4194303 which represents ~1/10 seconds.
	 * @param handler - The handler function. Has to return -1.
	 * @param unk1    - Unknown. Pass 0.
	 */
	void sceSTimerSetHandler(SceSysTimerId timer, int cycle, uint handler, int unk1) {
		logInfo("sceSTimerSetHandler(%d, %d, %08X, %d)", timer, cycle, handler, unk1);
		SysTimer sysTimer = uniqueIdFactory.get!SysTimer(timer);
		sysTimer.setHandler(cycle, handler, unk1);
	}

	/**
	 * Start the SysTimer timer count.
	 *
	 * @param timer - The timer id.
	 */
	void sceSTimerStartCount(SceSysTimerId timer) {
		logInfo("sceSTimerStartCount(%d)", timer);
		uniqueIdFactory.get!SysTimer(timer).start();
	}
}
