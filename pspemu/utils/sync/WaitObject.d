module pspemu.utils.sync.WaitObject;

public import std.conv;
public import std.string;

public import std.c.windows.windows;

enum WaitResult {
	TIMEOUT,
	ABANDONED,
	FAILED,
	OBJECT,
}

class WaitObjectException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) { super(msg, file, line, next); }
}

class WaitObjectTimeoutException : WaitObjectException {
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) { super(msg, file, line, next); }
}

class WaitObjectAbandonedException : WaitObjectException {
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) { super(msg, file, line, next); }
}

class WaitObjectFailedException : WaitObjectException {
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) { super(msg, file, line, next); }
}

abstract class WaitObject {
	public string name;
	public HANDLE handle;
	public void delegate(Object) callback;
	
	/**
	 * Object used to
	 * @deprecated 
	 */
	/* deprecated */ public Object object;
	public Object objectParameter;

	public WaitResult result;
	public WaitObject resultObject;
	
	~this() {
		CloseHandle(handle); 
	}
	
	public WaitObject wait(uint timeoutMilliseconds = uint.max) {
		final switch (WaitForSingleObject(handle, timeoutMilliseconds)) {
			case WAIT_ABANDONED: {
				result = WaitResult.ABANDONED;
			} break;
			case WAIT_FAILED: {
				result = WaitResult.FAILED;
			} break;
			case WAIT_TIMEOUT: {
				result = WaitResult.TIMEOUT;
			} break;
			case WAIT_OBJECT_0: {
				result = WaitResult.OBJECT;
				resultObject = this;
				resultObject.callCallback(object);
				return resultObject;
			} break;
		}
		return null;
	}
	
	public void callCallback(Object object) {
		if (callback !is null) callback(object);
	}
}