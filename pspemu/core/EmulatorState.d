module pspemu.core.EmulatorState;

import std.stdio;
import std.datetime;
import core.thread;
import core.time;

import pspemu.core.Memory;
import pspemu.core.cpu.ISyscall;
import pspemu.core.cpu.CpuThreadBase;
import pspemu.core.gpu.Gpu;
import pspemu.core.gpu.impl.gl.GpuOpengl;
import pspemu.core.display.Display;
import pspemu.core.controller.Controller;
import pspemu.core.RunningState;

import pspemu.core.ThreadState;

//import pspemu.EmulatorHelper;

import core.sync.condition;
import core.sync.mutex;
import pspemu.core.battery.Battery;

import pspemu.utils.sync.WaitEvent;

class EmulatorState {
	public SysTime       startTime; 
	public Memory        memory;
	public Battery       battery;
	public Display       display;
	public Controller    controller;
	public Gpu           gpu;
	public ISyscall      syscall;
	public RunningState  runningState;
	WaitEvent            threadStartedCondition;
	WaitEvent            threadEndedCondition;
	uint                 threadsRunning = 0;
	bool[CpuThreadBase]  cpuThreads;
	bool                 unittesting = false;
	bool                 enabledInterrupts = true;

	CpuThreadBase[] getCpuThreadsDup() {
		return cpuThreads.keys.dup;
	}
	
	this() {
		this.runningState           = new RunningState();
		this.threadStartedCondition = new WaitEvent("EmulatorState.threadStartedCondition");
		this.threadEndedCondition   = new WaitEvent("EmulatorState.threadEndedCondition");
		this.memory                 = new Memory();
		this.battery                = new Battery();
		this.display                = new Display(this.runningState, this.memory);
		this.controller             = new Controller();
		this.gpu                    = new Gpu(this, new GpuOpengl());
		this.startTime              = Clock.currTime;
	}
	
	public void reset() {
		this.cpuThreads = null;
		this.memory.reset();
		this.display.reset();
		this.controller.reset();
		this.gpu.reset();
		this.runningState.reset();
		this.threadsRunning = 0;
		this.enabledInterrupts = true;
		this.startTime = Clock.currTime;
	}
	
	public void cpuThreadRunningBlock(void delegate() callback) {
		threadsRunning++;
		threadStartedCondition.signal();

		scope (exit) {
			threadsRunning--;
			threadEndedCondition.signal();
		}

		callback();
	}

    public void waitSomeCpuThreadsToStart() {
    	while (this.threadsRunning == 0) {
    		this.threadStartedCondition.wait();
    	}
    }
	
    public void waitForAllCpuThreadsToTerminate() {
    	//waitSomeCpuThreadsToStart();
    	while (this.threadsRunning > 0) {
    		this.threadEndedCondition.wait();
    	}
    }
    
    void dumpDisplayMode() {
    	writefln("DISPLAY: %s", display);
    }
    
	void dumpThreads() {
		try {
			writefln("Threads(%d):", Thread.getAll.length);
			foreach (thread; Thread.getAll) {
				writefln("  - Thread: '%s', running:%d, priority:%d", thread.name, thread.isRunning, thread.priority);
			}
			auto cpuThreadList = this.getCpuThreadsDup;
			writefln("CpuThreads(%d):", cpuThreadList.length);
			foreach (CpuThreadBase cpuThread; cpuThreadList) {
				writef("  - CpuThread:");
				try {
					writef("%s", cpuThread);
				} catch {
					
				}
				writefln("");
				//int callStackPosEnd   = min(cast(int)cpuThread.threadState.registers.CallStackPos, cast(int)cpuThread.threadState.registers.CallStack.length);
				//int callStackPosStart = max(0, callStackPosEnd - 10);

				try {								
					//foreach (k, pc; cpuThread.threadState.registers.CallStack[callStackPosStart..callStackPosEnd])
					foreach (k, pc; cpuThread.threadState.registers.CallStack[0..cpuThread.threadState.registers.CallStackPos]) {
						writefln("    - %d - 0x%08X", k, pc);
					}
				} catch (Throwable o) {
					
				}
			}
		} catch (Throwable o) {
			
		}
	}
}