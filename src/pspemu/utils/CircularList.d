module pspemu.utils.CircularList;

import pspemu.utils.sync.WaitEvent;

class CircularList(Type, bool CheckAvailable = true) {
	/*
	struct Node {
		Type value;
		Node* next;
	}

	Node* head;
	Node* tail;
	Type[] pool;
	*/

	Type[] list;
	WaitEvent readAvailableEvent;
	WaitEvent writeAvailableEvent;

	this(uint capacity = 1024) {
		list = new Type[capacity];
		readAvailableEvent  = new WaitEvent("CircularList.readAvailableEvent");
		writeAvailableEvent = new WaitEvent("CircularList.writeAvailableEvent");
	}
	
	public void clear() {
		this.readAvailable = 0;
		this.headPosition = 0;
		this.tailPosition = 0;
	}

	uint readAvailable;
	uint writeAvailable() { return list.length - readAvailable; }

	uint headPosition;
	void headPosition__Inc(int count = 1) {
		static if (CheckAvailable) {
			if (count > 0) {
				assert(readAvailable  >= +count);
			} else {
				assert(writeAvailable >= -count);
			}
		}
		headPosition = (headPosition + 1) % list.length;
		readAvailable -= count;
	}

	uint tailPosition;
	void tailPosition__Inc(int count = 1) {
		static if (CheckAvailable) {
			if (count > 0) {
				assert(writeAvailable >= +count);
			} else {
				assert(readAvailable  >= -count);
			}
		}
		tailPosition = (tailPosition + count) % list.length;
		readAvailable += count;
	}

	ref Type consume() {
		scope (exit) headPosition__Inc(1);
		return list[headPosition];
	}

	ref Type enqueue(Type value) {
		scope (exit) tailPosition__Inc(1);
		list[tailPosition] = value;
		return list[tailPosition];
	}

	ref Type dequeue() {
		tailPosition__Inc(-1);
		return list[tailPosition];
	}

	ref Type readFromTail(int pos = -1) {
		return list[(tailPosition + pos) % list.length];
	}

	alias consume consumeHead;
}

alias CircularList Queue;