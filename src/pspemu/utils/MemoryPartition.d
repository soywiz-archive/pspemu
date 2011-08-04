module pspemu.utils.MemoryPartition;

import std.stdio;
import std.string;

class NotEnoughSpaceException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    	super(msg, file, line, next);
    }
}

class MemoryPartition {
	
	/**
	 * Low address.
	 */
	protected uint _low;

	/**
	 * High address.
	 */
	protected uint _high;
	
	public uint low() {
		return _low;
	}

	public uint high() {
		return _high;
	}

	public void low(uint value) {
		if (parent !is null) parent.childsByLow.remove(this._low);
		this._low = value;
		if (parent !is null) parent.childsByLow[this._low] = this;
	}

	public void high(uint value) {
		if (parent !is null) parent.childsByHigh.remove(this._high);
		this._high = value;
		if (parent !is null) parent.childsByHigh[this._high] = this;
	}

	public uint length() {
		return high - low;
	}
	
	public bool used;

	MemoryPartition parent;
	MemoryPartition[uint] childsByLow;
	MemoryPartition[uint] childsByHigh;
	
	this(uint low, uint high, MemoryPartition parent = null) {
		this.low = low;
		this.high = high;
		this.parent = parent;
		this.used = false;
	}
	
	protected MemoryPartition createChild(uint low, uint high) {
		return childsByHigh[high] = childsByLow[low] = new MemoryPartition(low, high, this);
	}
	
	protected void removeMemoryPartition(MemoryPartition memoryManager) {
		childsByLow.remove(memoryManager.low);
		childsByHigh.remove(memoryManager.high);
	}

	public void freeByLow(uint low) {
		auto childToFree = low in childsByLow;
		if (childToFree is null) throw(new Exception("Segment not used"));
		free(*childToFree);
	}
	
	public void free(MemoryPartition childToFree) {
		if (!childToFree.used) throw(new Exception("Segment not used"));
		childToFree.used = false; 
		
		auto leftChildToFree = childToFree.low in childsByHigh;
		auto rightChildToFree = childToFree.high in childsByLow;
		
		// Combine with left
		if (leftChildToFree !is null && !leftChildToFree.used) {
			uint leftChildToFreeLow = leftChildToFree.low;
			removeMemoryPartition(*leftChildToFree);
			childToFree.low = leftChildToFreeLow;
		}

		// Combine with right
		if (rightChildToFree !is null && !rightChildToFree.used) {
			uint rightChildToFreeHigh = rightChildToFree.high;
			removeMemoryPartition(*rightChildToFree);
			childToFree.high = rightChildToFreeHigh;
		}
	}
	
	protected void prepareChilds() {
		if (childsByLow.length == 0) {
			createChild(low, high);
		}
	}
	
	public MemoryPartition use(uint low, uint high) {
		prepareChilds();
		
		MemoryPartition[] insideChilds;
		foreach (child; childsByLow) {
			if (child.used) continue;
			
			if (child.low <= low && child.high >= high) {
				insideChilds ~= child;
			}
			//writefln("::%s", child);
		}
		if (insideChilds.length != 1) {
			//writefln("%s", this);
			throw(new Exception(std.string.format("Invalid segment 0x%08X-0x%08X (inside:%d)", low, high, insideChilds.length)));
		}
		auto insideChild = insideChilds[0];
		auto insideChildHigh = insideChild.high;
		insideChild.high = low;
		auto usedChild = createChild(low, high);
		usedChild.used = true;
		createChild(high, insideChildHigh);
		return usedChild;
	}
	
	alias allocLow alloc;
	
	public MemoryPartition allocLow(uint size, uint alignment = 1) {
		prepareChilds();

		foreach (childKey; childsByLow.keys.sort) {
			auto child = childsByLow[childKey];
			if (!child.used && child.length > size) {
				uint childLow = child.low;
				child.low = childLow + size;
				uint padsize = (alignment - (childLow % alignment)) % alignment;
				if (padsize > 0) {
					createChild(childLow, childLow + padsize);
					childLow += padsize;
				}
				
				auto allocatedChild = createChild(childLow, childLow + size);
				allocatedChild.used = true;
				return allocatedChild; 
			}			
		}
		throw(new NotEnoughSpaceException("allocLow:: No available space"));
	}
	
	public MemoryPartition allocHigh(uint size, uint alignment = 1) {
		prepareChilds();

		foreach (childKey; childsByHigh.keys.sort.reverse) {
			auto child = childsByHigh[childKey];
			if (!child.used && child.length > size) {
				uint childHigh = child.high;
				child.high = childHigh - size;
				uint padsize = (alignment - (childHigh % alignment)) % alignment;
				if (padsize > 0) {
					createChild(childHigh - padsize, childHigh);
					childHigh += padsize;
				}
				
				auto allocatedChild = createChild(childHigh - size, childHigh);
				allocatedChild.used = true;
				return allocatedChild; 
			}			
		}
		throw(new NotEnoughSpaceException("allocHigh:: No available space"));
	}
	
	public string toString() {
		string ret = "";
		ret ~= std.string.format("MemoryPartition(0x%08X-0x%08X, %s)", low(), high(), used);
		if (childsByLow.length) {
			ret ~= "[";
			bool first = true;
			foreach (childLow; childsByLow.keys.sort) {
				auto child = childsByLow[childLow];
				if (first) {
					first = false;
				} else {
					ret ~= ", ";
				}
				ret ~= child.toString();
			}
			ret ~= "]";
		}
		return ret;		
	}
}
