module pspemu.utils.sync.WaitEvent;

public import pspemu.utils.sync.WaitObject;
import std.exception;

extern (System) {
	HANDLE CreateEventA(LPSECURITY_ATTRIBUTES lpEventAttributes, BOOL bManualReset, BOOL bInitialState, LPCTSTR lpName);
	void SetEvent(HANDLE event);
	void ResetEvent(HANDLE event);
}

class WaitEvent : WaitObject {
	this(string name = null, bool manuallyResetSignal = false, bool initiallySignaled = false) {
		this.name = name;
		this.handle = enforce(CreateEventA(null, manuallyResetSignal, initiallySignaled, toStringz(name)));
	}

	public void signal() {
		SetEvent(handle);
	}

	public void reset() {
		ResetEvent(handle);
	}
}