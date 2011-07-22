module pspemu.utils.sync.WaitSemaphore;

public import pspemu.utils.sync.WaitObject;

class WaitSemaphore : WaitObject {
	this(string name = null, int initialCount = 0, int maxCount = 255) {
		this.name = name;
		this.handle = CreateSemaphoreA(null, initialCount, maxCount, toStringz(name));
	}
	
	int release(int count) {
		int prevCount;
		ReleaseSemaphore(this.handle, count, &prevCount);
		return prevCount;
	}
}