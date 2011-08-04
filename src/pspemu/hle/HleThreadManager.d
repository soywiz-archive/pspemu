module pspemu.hle.HleThreadManager;

import pspemu.utils.MathUtils;
import pspemu.core.ThreadState;

/**
 * Class that will handle cpu thread switching.
 */
final class HleThreadManager {
	/**
	 * Cpu that will handle execution of the threads. 
	 */
	public Cpu cpu;

	protected HleThreadState[] hleThreadStates;

	protected int threadMinWait;
	
	public this(Cpu cpu) {
		this.cpu = cpu;		
	}


	public void add(HleThreadState hleThreadState) {
		this.hleThreadStates ~= hleThreadState;
	}

	/**
	 * Execute this thread until no threads left.
	 */
	public void executionLoop() {
		while (threads.length) {
			switchToNext();
		}
	}
	
	public void reset() {
		threads.length = 0;
	}
	
	private void executeCurrent() {
		this.currentExecutingThread.continueFiber();
	}
	
	private void switchTo(CpuThreadBase thread) {
		this.currentExecutingThread = thread; 
		executeCurrent();
		thread.threadState.waitCount += thread.sceKernelThreadInfo.currentPriority;
		
		this.threadMinWait = min(thread.waitCount, threadMinWait);
	}
	
	private void switchToNext() {
		foreach (thread; this.threads) {
			thread.threadState.waitCount -= this.threadMinWait;
		}
		
		foreach (thread; this.threads) {
			if (thread.threadState.waitCount == 0) {
				switchTo(thread);
				return;
			}
		}
		
		if (threads.length > 0) {
			throw(new Exception("Unexpected error not synchronized threadMinWait"));
		}
		
		// No threads left.
	}
}