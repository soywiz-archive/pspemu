module pspemu.hle.HleThreadManager;

import pspemu.utils.MathUtils;
import pspemu.utils.ArrayUtils;
import pspemu.hle.HleThreadBase;

import std.stdio;

/**
 * Class that will handle cpu thread switching.
 */
final class HleThreadManager {
	protected HleThreadBase[] hleThreads;
	protected HleThreadBase currentExecutingThread;
	
	public this() {
	}


	public void add(HleThreadBase hleThread) {
		//hleThread.waitCount = calculateMinWaitCount() - 1;
		hleThreads ~= hleThread;
	}

	/**
	 * Execute this thread until no threads left.
	 */
	public void executionLoop() {
		while (hleThreads.length > 0) {
			switchToNext();
		}
	}
	
	public void reset() {
		hleThreads.length = 0;
	}
	
	private void executeCurrent() {
		this.currentExecutingThread.threadResume();
	}
	
	private void switchTo(HleThreadBase hleThread) {
		this.currentExecutingThread = hleThread; 
		{
			executeCurrent();
		}
		hleThread.waitCount += hleThread.currentPriority;
	}
	
	private int calculateMinWaitCount() {
		int hleThreadMinWait = int.max;
		
		// Calculate the minimum waitCount, and also remove finished threads.
		foreach (ref hleThread; this.hleThreads) {
			hleThreadMinWait = min(hleThread.waitCount, hleThreadMinWait);
		}

		return hleThreadMinWait;
	}
	
	private void removeFinishedThreads() {
		bool rebuildThreadList = false;
		
		foreach (ref hleThread; this.hleThreads) {
			if (hleThread.threadFinished) {
				hleThread = null;
				rebuildThreadList = true;				
			}
		}

		if (rebuildThreadList) {
			removeNullsInplace(this.hleThreads);
		}
	}
	
	private void switchToNext() {
		removeFinishedThreads();
		int hleThreadMinWait = calculateMinWaitCount();
		
		foreach (ref hleThread; this.hleThreads) {
			hleThread.waitCount -= hleThreadMinWait;
		}
		
		// First the last added. (reverse)
		foreach_reverse (hleThread; this.hleThreads) {
			if (hleThread.waitCount == 0) {
				switchTo(hleThread);
				return;
			}
		}
		
		if (hleThreads.length > 0) {
			throw(new Exception("Unexpected error not synchronized hleThreadMinWait"));
		}
		
		// No threads left.
	}
	
	/+
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
	+/
}