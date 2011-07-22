module pspemu.utils.MemorySegment;

import std.string, std.stdio;
import std.algorithm;

import pspemu.utils.MathUtils;

class MemorySegment {
	static struct Block {
		uint low, high;
		bool valid() { return low <= high; }
		uint size() in { assert(low <= high); } body { return high - low; }
		bool overlap(Block that) { return (this.high > that.low) && (that.high > this.low); }
		bool inside(Block that) { return (this.low >= that.low) && (this.high <= that.high); }
		
		string toString() { return std.string.format("Block(%08X-%08X)", low, high); }
	}
	
	MemorySegment parent;
	MemorySegment[] childs;

	string name;
	Block block;
	
	string nameFull() { return parent ? (parent.name ~ "/" ~ name) : name; }
	
	string toString() {
		string ret = "";
		/*
		if (parent) {
			ret ~= parent.toString;
			ret ~= " :: ";
		}
		*/
		ret ~= std.string.format("MemorySegment('%s', %08X-%08X)", name, block.low, block.high);
		return ret;
	}

	this(uint low, uint high, string name = "<unknown>") {
		if (!(low <= high)) throw(new Exception("Invalid MemorySegment low <= high"));
		block.low  = low;
		block.high = high;
		this.name  = name;
	}

	protected Block[] usedBlocks() {
		Block[] blocks;
		foreach (child; childs) blocks ~= child.block;
		sort!((ref Block a, ref Block b){ return a.low < b.low; })(blocks);
		return blocks;
	}

	protected Block[] availableBlocks() {
		Block[] usedBlocks = this.usedBlocks;
		Block[] blocks;

		if (usedBlocks.length) {			
			void emitBlock(ref Block block) { if (block.size > 0) blocks ~= block; }

			// Before used blocks.
			emitBlock(Block(block.low, usedBlocks[0].low));

			// After used blocks.
			emitBlock(Block(usedBlocks[$ - 1].high, block.high));

			for (int n = 1; n < usedBlocks.length; n++) {
				// Between blocks.
				emitBlock(Block(usedBlocks[n - 1].high, usedBlocks[n - 0].low));
			}
		}
		// No used blocks.
		else {
			blocks = [block];
		}
		
		return blocks;
	}

	MemorySegment opAddAssign(MemorySegment child) {
		childs ~= child;
		child.parent = this;
		debug (DEBUG_MEMORY_ALLOCS) writefln("ALLOC: %s", child.toString);
		return child;
	}
	
	MemorySegment addNewMemorySegment(MemorySegment newMemorySegment) {
		this += newMemorySegment;
		return newMemorySegment;
	}

	/**
	 * Allocs a stack.
	 *
	 * @param  size       Size of the stack to alloc.
	 * @param  name       Name of the stack.
	 * @param  alignment  Bytes to align the stack to.
	 *
	 * @return  A segment
	 */
	MemorySegment allocByHigh(uint size, string name = "<unknown>", uint alignment = 1) {
		synchronized (this) {
			foreach (block; availableBlocks.reverse) {
				uint decrement = previousAlignedDecrement(block.high, alignment);
				if (block.size >= size + decrement) {
					return addNewMemorySegment(new MemorySegment(block.high - size - decrement, block.high - decrement, name));
				}
			}
			throw(new Exception(std.string.format("Can't allocByHigh size=%d on %s", size, this)));
		}
	}
	
	/**
	 * Allocs a heap.
	 *
	 * @param
	 */
	MemorySegment allocByLow(uint size, string name = "<unknown>", uint maxDesiredAddress = 0, uint alignment = 1) {
		synchronized (this) {
			foreach (block; availableBlocks) {
				if (block.low < maxDesiredAddress) continue;
				uint increment = nextAlignedIncrement(block.low, alignment);
				if (block.size >= size + increment) {
					return addNewMemorySegment(new MemorySegment(block.low + increment, block.low + increment + size, name));
				}
			}
	
			// Ok. We didn't find an available segment. But we will try without the min check.
			if (maxDesiredAddress != 0) {
				return allocByLow(size, name, 0, alignment);
			}
			throw(new Exception(std.string.format("Can't allocByLow size=%d on %s", size, this)));
		}
	}

	MemorySegment allocByAddr(uint base, uint size, string name = "<unknown>") {
		synchronized (this) {
			auto idealBlock = Block(base, base + size);
	
			// Not even inside. Check other address.
			if (!idealBlock.inside(this.block)) {
				return allocByLow(size, name);
			}
	
			foreach (block; usedBlocks) {
				// Overlaps with other segment. Can't use this address.
				if (idealBlock.overlap(block)) {
					return allocByLow(size, name, base);
				}
			}
			// Ok. Doesn't overlap with any address.
			return addNewMemorySegment(new MemorySegment(idealBlock.low, idealBlock.high, name));
		}
	}

	uint getFreeMemory() {
		synchronized (this) {
			uint size;
			foreach (block; availableBlocks) {
				if (!block.valid) continue;
				size += block.size;
			}
			return size;
		}
	}

	uint getMaxAvailableMemoryBlock() {
		synchronized (this) {
			uint size = 0;
			foreach (block; availableBlocks) {
				if (!block.valid) continue;
				size = std.algorithm.max(size, block.size);
				//writefln("getMaxAvailableMemoryBlock(%s): %d", block, block.size);
			}
			return size;
		}
	}

	MemorySegment opIndex(int index) {
		return childs[index];
	}

	void free() {
		synchronized (this) {
			try {
				if (parent !is null) {
					synchronized (parent) {
						foreach (index, child; parent.childs) {
							if (child is this) {
								parent.childs = parent.childs[0..index] ~ parent.childs[index + 1..$];
								parent = null;
								return;
							}
						}
					}
				}
			} catch (Throwable o) {
				writefln("MemorySegment.free: %s", o);
			}
		}
	}
}

/*
unittest {
	// overlap
	assert(Block(10, 20).overlap(Block(10, 20)) == true );
	assert(Block(10, 20).overlap(Block( 5, 15)) == true );
	assert(Block(10, 20).overlap(Block(15, 25)) == true );
	assert(Block(10, 20).overlap(Block( 0,  9)) == false);
	assert(Block(10, 20).overlap(Block(21, 22)) == false);
	assert(Block(10, 20).overlap(Block( 0, 10)) == false);
	assert(Block(10, 20).overlap(Block(20, 22)) == false);

	// inside
	assert(Block( 0, 15).inside(Block(10, 20)) == false);
	assert(Block(15, 25).inside(Block(10, 20)) == false);
	assert(Block( 5, 20).inside(Block(10, 20)) == false);
	assert(Block(10, 25).inside(Block(10, 20)) == false);
	assert(Block(10, 20).inside(Block(10, 20)) == true );
	assert(Block(10, 15).inside(Block(10, 20)) == true );
	assert(Block(15, 20).inside(Block(10, 20)) == true );
	assert(Block(11, 19).inside(Block(10, 20)) == true );
}
*/