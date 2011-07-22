module pspemu.utils.sync.CriticalSection;

import std.c.windows.windows;

class CriticalSection {
	protected CRITICAL_SECTION criticalSection;
	
	this() {
		InitializeCriticalSection(&criticalSection);
	} 
	
	~this() {
		DeleteCriticalSection(&criticalSection);
	}
	
	public void lock(void delegate() lockedDelegate = null) {
		EnterCriticalSection(&criticalSection);
		scope (exit) LeaveCriticalSection(&criticalSection);
		if (lockedDelegate !is null) lockedDelegate();
	}
	
	public void waitEnded() {
		lock();
	}
	
	public void tryLock(void delegate() lockedDelegate, void delegate() alreadyLockedDelegate) {
		if (TryEnterCriticalSection(&criticalSection)) {
			scope (exit) LeaveCriticalSection(&criticalSection);
			lockedDelegate();
		} else {
			alreadyLockedDelegate();
		}
	}
}