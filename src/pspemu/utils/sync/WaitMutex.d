module pspemu.utils.sync.WaitMutex;

public import pspemu.utils.sync.WaitObject;

extern (System) {
	HANDLE CreateMutexA(LPSECURITY_ATTRIBUTES lpMutexAttributes, BOOL bInitialOwner, LPCTSTR lpName);
	BOOL ReleaseMutex(HANDLE hMutex);
}


class WaitMutex : WaitObject {
	this(string name = null) {
		this.name = name;
		this.handle = CreateMutexA(null, false, toStringz(name));
	}
	
	void release() {
		ReleaseMutex(this.handle);
	}
}