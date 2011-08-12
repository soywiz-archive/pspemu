module pspemu.hle.HleThread;

import pspemu.hle.HleThreadBase;

import pspemu.hle.kd.threadman.Types;
import pspemu.interfaces.ICpu;
import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Cpu;
import core.thread;

import std.stdio;

class HleThread : HleThreadBase {
	static HleThread current;
	
	public SceKernelThreadInfo sceKernelThreadInfo;
	public Registers registers;
	protected ICpu cpu;
	protected Fiber fiber;
	
	this(ICpu cpu) {
		this(cpu, new Registers);
	}
	
	this(ICpu cpu, Registers registers) {
		this.cpu = cpu;
		this.registers = registers;
		this.fiber = new Fiber(&run); 
	}
	
	protected void run() {
		try {
			cpu.execute(registers);
		} catch (Throwable exception) {
			.writefln("Exception on fiber: %s", exception);
		}
	}
	
	public void threadResume() {
		if (current !is null) throw(new Exception("Tried to call threadResume inside the execution of another HleThread"));
		current = this;
		fiber.call();
	}
	
	static public void threadYield() {
		if (current is null) throw(new Exception("Tried to call threadYield outside the execution of a HleThread"));
		current = null;
		Fiber.yield();
	}
	
	public @property int currentPriority() {
		return sceKernelThreadInfo.currentPriority;
	}
	
	public @property bool threadFinished() {
		return fiber.state == Fiber.State.TERM;
	}
}

/+
import core.thread;

import std.stdio;

import pspemu.core.EmulatorState;
import pspemu.core.cpu.Registers;
import pspemu.core.cpu.CpuThreadBase;

import pspemu.hle.kd.Types;
import pspemu.hle.kd.threadman.Types;
import pspemu.hle.Module;

import pspemu.utils.Logger;

import std.c.windows.windows;

public import pspemu.utils.sync.WaitMultipleObjects;
public import pspemu.utils.sync.WaitEvent;
public import pspemu.utils.sync.CriticalSection;

import pspemu.utils.Event;

class HleThreadState {
	public string name;
	public SceUID thid;

	protected Fiber nativeFiber;
	public    EmulatorState emulatorState;

	public string waitType;
	public bool waiting;
	public Registers registers;
	public SceKernelThreadInfo* sceKernelThreadInfo;
	public Module threadModule;
	public Event onDeleteThread;
	int sleepingAwakenCount;
	
	WaitEvent threadEndedEvent;

	template WakeUp_Template() {
		CriticalSection sleepingCriticalSection;
		WaitEvent wakeUpEvent;
		protected int _wakeUpCount;
		
		int getWakeUpCount() {
			synchronized (this) {
				return _wakeUpCount;
			}
		}

		protected void setWakeUpCount(int value) {
			synchronized (this) {
				_wakeUpCount = value;
			}
		}
		
		protected void addWakeUpCount(int increment) {
			//bool signal;
			synchronized (this) {
				int _wakeUpCountPrev = _wakeUpCount; 
				_wakeUpCount += increment;
				Logger.log(
					Logger.Level.INFO, "ThreadState",
					"  Thread.wakeUp(%s) || %d -> %d (sleeping:%s)",
					this, _wakeUpCountPrev, _wakeUpCount, (_wakeUpCount < 0)
				);
				//if (_wakeUpCount >= 0) signal = true;
			}
			/*
			if (increment > 0) {
				wakeUpEvent.signal();
				//Thread.yield();
				//Thread.sleep(dur!"msecs"(10));
				
				// Will enter when sleeping has ended.
				synchronized (sleepingLock) {
					sleepingAwakenCount++;
				}
			}
			*/
		}
		
		void resetWakeUpCount() {
			setWakeUpCount(0);
		}
		
		void decrementWakeUpCount() {
			addWakeUpCount(-1);
		}
		
		void incrementWakeUpCount() {
			addWakeUpCount(+1);
		}
		
		static ThreadState getOneThreadState() {
			foreach (threadState; threadStatePerThread) return threadState;
			return null;
		}
	}
	mixin WakeUp_Template;
	
	/// @TODO!!! It should be static. It should be a method of EmulatorState.
	/// Being static disallows having several emulators running at once.
	static void suspendAllCpuThreadsButThis() {
		HANDLE thisNativeThreadHandle = GetCurrentThread();
		foreach (threadState; threadStatePerThread) {
			//writefln("suspendAllCpuThreadsButThis: %08X %08X", thisNativeThreadHandle, threadState.nativeThreadHandle);
			if (threadState.nativeThreadHandle != thisNativeThreadHandle) {
				SuspendThread(threadState.nativeThreadHandle);
			}
		}
	}
	
	static void resumeAllCpuThreadsButThis() {
		HANDLE thisNativeThreadHandle = GetCurrentThread();
		foreach (threadState; threadStatePerThread) {
			//writefln("resumeAllCpuThreadsButThis: %08X %08X", thisNativeThreadHandle, threadState.nativeThreadHandle);
			if (threadState.nativeThreadHandle != thisNativeThreadHandle) {
				ResumeThread(threadState.nativeThreadHandle);
			}
		}
	}

	public this(string name, EmulatorState emulatorState, Registers registers) {
		//this.onDeleteThread = new Event();
		this.name = name;
		this.emulatorState = emulatorState;
		this.registers = registers;
		wakeUpEvent      = new WaitEvent("WakeUpEvent");
		threadEndedEvent = new WaitEvent("ThreadEndedEvent", true);
		sleepingCriticalSection = new CriticalSection();
		
		this.sceKernelThreadInfo.status |= PspThreadStatus.PSP_THREAD_STOPPED;
		this.sceKernelThreadInfo.status |= PspThreadStatus.PSP_THREAD_READY;
	}

	public this(string name, EmulatorState emulatorState) {
		this(name, emulatorState, new Registers());
	}
	
	
	public void nativeThreadSet(void delegate() run, string name = "<unknown thread>") {
		nativeThread = new Thread(delegate() {
			nativeThreadHandle = GetCurrentThread();
			sceKernelThreadInfo.status &= ~PspThreadStatus.PSP_THREAD_STOPPED;
			sceKernelThreadInfo.status |= PspThreadStatus.PSP_THREAD_RUNNING;
			

			/*
			final switch (sceKernelThreadInfo.currentPriority) {
				case 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15:
					SetThreadPriority(nativeThreadHandle, THREAD_PRIORITY_ABOVE_NORMAL);
				break;
				case 16, 17, 18, 19:
					SetThreadPriority(nativeThreadHandle, THREAD_PRIORITY_NORMAL);
				break;
				case 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32:
					SetThreadPriority(nativeThreadHandle, THREAD_PRIORITY_BELOW_NORMAL);
				break;
			}
			*/
			
			run();
		});
		nativeThread.name = name;
	}
	
	public void nativeThreadStart() {
		nativeThread.start();
	}
	
	@property public bool nativeThreadIsRunning() {
		return nativeThread.isRunning();
	}
	
	static ThreadState getFromThread(Thread thread = null) {
		if (thread is null) thread = Thread.getThis();
		return threadStatePerThread[thread];
	}
	
	void setInCurrentThread(Thread thread = null) {
		if (thread is null) thread = Thread.getThis();
		threadStatePerThread[thread] = this;
	}
	
	ThreadState clone() {
		ThreadState threadState = new ThreadState(name, emulatorState, new Registers());
		{
			threadState.waiting = waiting;
			threadState.registers.copyFrom(registers);
			threadState.nativeThread = Thread.getThis;
			threadState.thid = -1;
			threadState.threadModule = threadModule;
			threadState.sceKernelThreadInfo = sceKernelThreadInfo;
		}
		return threadState;
	}
	
	public void waitingBlock(string waitType, void delegate() callback) {
		this.waitType = waitType;
		this.waiting = true;
		this.sceKernelThreadInfo.status |= PspThreadStatus.PSP_THREAD_WAITING;

		scope (exit) {
			this.waitType = "";
			this.waiting = false;
			this.sceKernelThreadInfo.status &= ~PspThreadStatus.PSP_THREAD_WAITING;
		}

		callback();
	}
	
	string toString() {
		return std.string.format("ThreadState(thid=%d:'%s', PC:%08X, waiting:%s'%s')", thid, name, registers.PC, waiting, waitType);
	}
}
+/