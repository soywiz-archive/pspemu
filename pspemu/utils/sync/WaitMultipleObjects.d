module pspemu.utils.sync.WaitMultipleObjects;

import pspemu.utils.sync.WaitObject;

import core.thread;

class WaitMultipleObjects {
	WaitObject[] waitObjects;

	/**
	 * Object used to
	 * @deprecated 
	 */
	/* deprecated */ public Object object;
	public Object objectParameter;

	public WaitResult result;
	public WaitObject resultObject;

	
	this(Object object = null) {
		this.object = object;
	}
	
	public void add(WaitObject waitObject) {
		this.waitObjects ~= waitObject;
	}
	
	public WaitObject waitAnyException(uint timeoutMilliseconds = uint.max) {
		WaitObject selectedWaitObject = waitAny(timeoutMilliseconds);
		final switch (this.result) {
			case WaitResult.ABANDONED: throw(new WaitObjectAbandonedException(""));
			case WaitResult.TIMEOUT  : throw(new WaitObjectTimeoutException(""));
			case WaitResult.FAILED   : throw(new WaitObjectFailedException(""));
			case WaitResult.OBJECT   : return selectedWaitObject;
		}
	}
	
	public WaitObject waitAny(uint timeoutMilliseconds = uint.max) {
		if (waitObjects.length) {
			scope handles = new HANDLE[this.waitObjects .length]; 
			foreach (index, waitObject; waitObjects) handles[index] = waitObject.handle;
			uint funcResult;
			switch (funcResult = WaitForMultipleObjects(handles.length, handles.ptr, false, timeoutMilliseconds)) {
				case WAIT_ABANDONED: {
					result = WaitResult.ABANDONED;
				} break;
				case WAIT_TIMEOUT: {
					result = WaitResult.TIMEOUT;
				} break;
				case WAIT_FAILED: {
					result = WaitResult.FAILED;
				} break;
				default: {
					result = WaitResult.OBJECT;
					resultObject = this.waitObjects[funcResult - WAIT_OBJECT_0];
					resultObject.callCallback(object);
					return resultObject;
				} break;
			}
		} else {
			if (timeoutMilliseconds == uint.max) {
				Thread.sleep(long.max);
			} else {
				Thread.sleep(timeoutMilliseconds);
			}
		}
		return null;
	}
}