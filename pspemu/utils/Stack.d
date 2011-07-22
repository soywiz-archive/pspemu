module pspemu.utils.Stack;

class Stack(T) {
	protected T[] _values;
	protected uint cursor = 0;
	
	this(int maxSize = 1024) {
		_values.length = maxSize;
	}
	
	T[] values() {
		return _values[0..cursor];
	}
	
	void push(T value) {
		_values[cursor++] = value;
	}
	
	T pop() {
		return _values[--cursor];		
	}
}