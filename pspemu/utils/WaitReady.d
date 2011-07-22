module pspemu.utils.WaitReady;

import core.sync.mutex;
import core.sync.condition;

class WaitReady {
	protected bool ready = false;
	protected Condition condition;
	
	this() {
		this.condition = new Condition(new Mutex);		
	}
	
	public void setReady() {
		ready = true;
		condition.notifyAll();
	}
	
	public void waitReady() {
		while (!ready) condition.wait();
	}
}

class WaitReadySet {
	WaitReady[] waitReadyList;
	
	public void add(WaitReady waitReady) {
		waitReadyList ~= waitReady;
	}
	
	public void waitAll() {
		foreach (waitReady; waitReadyList) {
			waitReady.waitReady();
		}
	}
}