module pspemu.utils.Event;

struct Event {
	void delegate(...)[] callbacks;
	
	void opAddAssign(void delegate(...) callback) {
		callbacks ~= callback;
	}
	
	void reset() {
		callbacks.length = 0;
	}
	
	void opCall(T...)(T args) {
		foreach (callback; callbacks) {
			callback(args);
		}
	}
}