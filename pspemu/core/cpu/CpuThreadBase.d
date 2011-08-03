module pspemu.core.cpu.CpuThreadBase;

import std.stdio;
import core.thread;
import core.time;
import std.datetime;

import pspemu.core.ThreadState;
import pspemu.core.Memory;
import pspemu.core.exceptions.HaltException;
import pspemu.core.exceptions.NotImplementedException;

import pspemu.core.cpu.tables.Table;
import pspemu.core.cpu.tables.SwitchGen;
import pspemu.core.cpu.tables.DummyGen;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Registers;

import pspemu.utils.Logger;

import pspemu.core.cpu.InstructionHandler;
import pspemu.hle.kd.threadman.Types;

public CpuThreadBase thisThreadCpuThreadBase;
__gshared CpuThreadBase[Thread] cpuThreadBasePerThread;

static CpuThreadBase getOneCpuThreadBase() {
	foreach (cpuThread; cpuThreadBasePerThread) return cpuThread;
	return null;
}

abstract class CpuThreadBase : InstructionHandler {
	CpuThreadBase cpuThread;
	Instruction instruction;
	ThreadState threadState;
	Memory memory;
	Registers registers;
	bool running = true;
	bool trace = false;
	
	//ulong executedInstructionsCount;
	__gshared long lastThreadId = 0;
	
	public this(ThreadState threadState) {
		this.cpuThread = this;
		this.threadState = threadState;
		this.memory = this.threadState.emulatorState.memory;
		this.registers = this.threadState.registers;
		this.threadState.nativeThreadSet(&run, std.string.format("PspCpuThread#%d('%s')", lastThreadId++, threadState.name));
		
		threadState.emulatorState.runningState.onStopCpu += delegate(...) {
			running = false;
		};
		
		threadState.onDeleteThread += delegate(...) {
			running = false;
		};
	}

	public void start() {
		this.threadState.nativeThreadStart();
	}
	
	public CpuThreadBase createCpuThread() {
		return createCpuThread(threadState.clone);
	}

	abstract public CpuThreadBase createCpuThread(ThreadState threadState);
	
	protected void run() {
		thisThreadCpuThreadBase = this;
		cpuThreadBasePerThread[Thread.getThis] = this;

		try {
			threadState.emulatorState.cpuThreads[this] = true;
			{
				threadState.emulatorState.cpuThreadRunningBlock({
					execute(trace);
				});
			}
		} finally {
			threadState.emulatorState.cpuThreads.remove(this);
			running = false;
			threadState.sceKernelThreadInfo.status = PspThreadStatus.PSP_THREAD_STOPPED;
			cpuThreadBasePerThread.remove(Thread.getThis);
		}
	}
	
    void execute(bool trace = false) {
	    throw(new NotImplementedException("Implemented by CpuThreadInterpreted"));
    }

    string toString() {
    	return "CpuBase(" ~ threadState.toString() ~ ")";
    }
}