module pspemu.utils.MemorySegment;

import std.string, std.stdio;
import std.algorithm;

class MemorySegment {
	static struct Block {
		uint low, high;
		uint size() in { assert(low <= high); } body { return high - low; }
		bool overlap(Block that) { return (this.high > that.low) && (that.high > this.low); }
		bool inside(Block that) { return (this.low >= that.low) && (this.high <= that.high); }
	}
	
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

	MemorySegment parent;
	MemorySegment[] childs;

	string name;
	Block block;
	
	string nameFull() { return parent ? (parent.name ~ "/" ~ name) : name; }
	
	string toString() {
		string ret = "";
		if (parent) {
			ret ~= parent.toString;
			ret ~= " :: ";
		}
		ret ~= std.string.format("MemorySegment('%s', %08X-%08X)", name, block.low, block.high);
		return ret;
	}

	this(uint low, uint high, string name = "<unknown>") {
		block.low  = low;
		block.high = high;
		this.name  = name;
	}

	Block[] usedBlocks() {
		Block[] blocks;
		foreach (child; childs) blocks ~= child.block;
		sort!((ref Block a, ref Block b){ return a.low < b.low; })(blocks);
		return blocks;
	}

	Block[] availableBlocks() {
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

	MemorySegment allocByHigh(uint size, string name = "<unknown>") {
		foreach (block; availableBlocks.reverse) {
			if (block.size >= size) return (this += new MemorySegment(block.high - size, block.high, name));
		}
		throw(new Exception(std.string.format("Can't alloc size=%d on %s", size, this)));
	}

	MemorySegment allocByLow(uint size, string name = "<unknown>", uint min = 0) {
		foreach (block; availableBlocks) {
			if (block.low < min) continue;
			if (block.size >= size) return (this += new MemorySegment(block.low, block.low + size, name));
		}

		// Ok. We didn't find an available segment. But we will try without the min check.
		if (min != 0) {
			return allocByLow(size, name, 0);
		}
		// Too bad.
		else {
			throw(new Exception(std.string.format("Can't alloc size=%d on %s", size, this)));
		}
	}

	MemorySegment allocByAddr(uint base, uint size, string name = "<unknown>") {
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
		return (this += new MemorySegment(idealBlock.low, idealBlock.high, name));
	}

	uint getFreeMemory() {
		uint size;
		foreach (block; availableBlocks) size += block.size;
		return size;
	}

	uint getMaxAvailableMemoryBlock() {
		uint size = 0;
		foreach (block; availableBlocks) size = pspemu.utils.Utils.max(size, block.size);
		return size;
	}

	MemorySegment opIndex(int index) {
		return childs[index];
	}

	void free() {
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
		} catch (Object o) {
			writefln("MemorySegment.free: %s", o);
		}
	}
}
