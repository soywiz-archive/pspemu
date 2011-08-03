module pspemu.hle.ThreadManager;

import pspemu.utils.MathUtils;
import pspemu.core.ThreadState;

class ThreadManager {
	public ThreadState currentExecutingThread;
	protected ThreadState[] threads;
	protected int threadMinWait;
	
	void reset() {
		threads.length = 0;
	}
	
	void add(ThreadState thread) {
		this.threads ~= thread;
	}
	
	void switchTo(ThreadState thread) {
		this.currentExecutingThread = thread; 
		thread.continueFiber();
		thread.waitCount += thread.sceKernelThreadInfo.currentPriority;
		
		this.threadMinWait = min(thread.waitCount, threadMinWait);
	}
	
	void switchToNext() {
		foreach (thread; this.threads) {
			thread.waitCount -= this.threadMinWait;
		}
		
		foreach (thread; this.threads) {
			if (thread.waitCount == 0) {
				switchTo(thread);
				return;
			}
		}
		
		if (threads.length > 0) {
			throw(new Exception("Unexpected error not synchronized threadMinWait"));
		}
		
		// No threads left.
	}
	
	void executionLoop() {
		while (threads.length) {
			switchToNext();
		}
	}
}