module pspemu.hle.kd.sysmem; // kd/sysmem.prx (sceSystemMemoryManager)

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

import std.algorithm;

class SysMemUserForUser : Module {
	MemorySegment allocStack(uint stackSize, string name) {
		stackSize &= ~0xF;
		auto segment = pspMemorySegmentStacks.allocByHigh(stackSize, std.string.format("Stack for %s", name));
		//writefln("allocStack!!! %s Size(%d)", segment, stackSize);
		return segment;
	}

	MemorySegment pspMemorySegment;
	MemorySegment pspMemorySegmentStacks;

	void initModule() {
		pspMemorySegment       = new MemorySegment(0x08000000, 0x0A000000, "PSP Memory");
		pspMemorySegmentStacks = new MemorySegment(0x08000000, 0x08400000 - 0x100, "PSP Memory Stacks");
		
		pspMemorySegment.allocByAddr(0x08000000,  4 * 1024 * 1024, "Kernel Memory 1");
		pspMemorySegment.allocByAddr(0x08400000,  4 * 1024 * 1024, "Kernel Memory 2");
		pspMemorySegment.allocByAddr(0x08800000, 24 * 1024 * 1024, "User Memory");
	}

	void initNids() {
		mixin(registerd!(0xA291F107, sceKernelMaxFreeMemSize));
		mixin(registerd!(0x237DBD4F, sceKernelAllocPartitionMemory));
		mixin(registerd!(0x9D9A5BA1, sceKernelGetBlockHeadAddr));
		mixin(registerd!(0xF919F628, sceKernelTotalFreeMemSize));
		mixin(registerd!(0xB6D61D02, sceKernelFreePartitionMemory));
		mixin(registerd!(0x3FC9AE6A, sceKernelDevkitVersion));
	}

	/**
	 * Get the firmware version.
	 * 
	 * @return The firmware version.
	 * 0x01000300 on v1.00 unit,
	 * 0x01050001 on v1.50 unit,
	 * 0x01050100 on v1.51 unit,
	 * 0x01050200 on v1.52 unit,
	 * 0x02000010 on v2.00/v2.01 unit,
	 * 0x02050010 on v2.50 unit,
	 * 0x02060010 on v2.60 unit,
	 * 0x02070010 on v2.70 unit,
	 * 0x02070110 on v2.71 unit.
	 */
	int sceKernelDevkitVersion() {
		return 0x_02_07_01_10;
	}

	/**
	 * Free a memory block allocated with ::sceKernelAllocPartitionMemory.
	 *
	 * @param blockid - UID of the block to free.
	 *
	 * @return ? on success, less than 0 on error.
	 */
	int sceKernelFreePartitionMemory(SceUID blockid) {
		MemorySegment(blockid).free();
		return 0;
	}

	/**
	 * Get the total amount of free memory.
	 *
	 * @return The total amount of free memory, in bytes.
	 */
	SceSize sceKernelTotalFreeMemSize() {
		return pspMemorySegment[2].getFreeMemory;
	}

	/**
	 * Get the size of the largest free memory block.
	 *
	 * @return The size of the largest free memory block, in bytes.
	 */
	SceSize sceKernelMaxFreeMemSize() {
		return pspMemorySegment[2].getMaxAvailableMemoryBlock;
	}

	/**
	 * Allocate a memory block from a memory partition.
	 *
	 * @param partitionid - The UID of the partition to allocate from.
	 * @param name - Name assigned to the new block.
	 * @param type - Specifies how the block is allocated within the partition.  One of ::PspSysMemBlockTypes.
	 * @param size - Size of the memory block, in bytes.
	 * @param addr - If type is PSP_SMEM_Addr, then addr specifies the lowest address allocate the block from.
	 *
	 * @return The UID of the new block, or if less than 0 an error.
	 */
	SceUID sceKernelAllocPartitionMemory(SceUID partitionid, string name, PspSysMemBlockTypes type, SceSize size, /* void* */uint addr) {
		MemorySegment memorySegment;
		switch (type) {
			case PspSysMemBlockTypes.PSP_SMEM_Low : memorySegment = pspMemorySegment[partitionid].allocByLow (size, name); break;
			case PspSysMemBlockTypes.PSP_SMEM_High: memorySegment = pspMemorySegment[partitionid].allocByHigh(size, name); break;
			case PspSysMemBlockTypes.PSP_SMEM_Addr: memorySegment = pspMemorySegment[partitionid].allocByAddr(addr, size, name); break;
		}
		if (memorySegment is null) return -1;
		return cast(SceUID)cast(void *)memorySegment;
	}

	/**
	 * Get the address of a memory block.
	 *
	 * @param blockid - UID of the memory block.
	 *
	 * @return The lowest address belonging to the memory block.
	 */
	uint sceKernelGetBlockHeadAddr(SceUID blockid) {
		return MemorySegment(blockid).block.low;
	}
}

class SysMemForKernel : Module {
}

class sceSysEventForKernel : Module {
}

class sceSuspendForKernel : Module {
}

class sceSuspendForUser : sceSuspendForKernel {
}

class KDebugForKernel : Module {
}

class MemorySegment {
	static struct Block {
		uint low, high;
		uint size() in { assert(low <= high); } body { return high - low; }
		bool overlap(Block that) { return (this.high > that.low) && (that.high > this.low); }
		bool inside(Block that) { return (this.low >= that.low) && (this.high <= that.high); }
	}
	
	unittest {
		// overlap
		assert(Block(10, 20).overlap(10, 20) == true );
		assert(Block(10, 20).overlap( 5, 15) == true );
		assert(Block(10, 20).overlap(15, 25) == true );
		assert(Block(10, 20).overlap( 0,  9) == false);
		assert(Block(10, 20).overlap(21, 22) == false);
		assert(Block(10, 20).overlap( 0, 10) == false);
		assert(Block(10, 20).overlap(20, 22) == false);

		// inside
		assert(Block( 0, 15).inside(10, 20) == false);
		assert(Block(15, 25).inside(10, 20) == false);
		assert(Block( 5, 20).inside(10, 20) == false);
		assert(Block(10, 25).inside(10, 20) == false);
		assert(Block(10, 20).inside(10, 20) == true );
		assert(Block(10, 15).inside(10, 20) == true );
		assert(Block(15, 20).inside(10, 20) == true );
		assert(Block(11, 19).inside(10, 20) == true );
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
		writefln("ALLOC: %s", child.toString);
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
		foreach (index, child; parent.childs) {
			if (child is this) {
				parent.childs = parent.childs[0..index] ~ parent.childs[index + 1..$];
				parent = null;
				return;
			}
		}
	}
	
	static MemorySegment opCall(SceUID blockid) {
		assert(blockid > 0, std.string.format("Invalid blockid %d", blockid));
		return cast(MemorySegment)cast(void *)blockid;
	}
}

/** Specifies the type of allocation used for memory blocks. */
enum PspSysMemBlockTypes {
	/** Allocate from the lowest available address. */
	PSP_SMEM_Low = 0,
	/** Allocate from the highest available address. */
	PSP_SMEM_High,
	/** Allocate from the specified address. */
	PSP_SMEM_Addr
}

struct PspSysmemPartitionInfo {
	SceSize size;
	uint startaddr;
	uint memsize;
	uint attr;
}

/** Structure of a UID control block */
struct uidControlBlock {
    uidControlBlock* parent;
    uidControlBlock* nextChild;
    uidControlBlock* type;   //(0x8)
    u32 UID;                 //(0xC)
    char* name;              //(0x10)
	ubyte unk;
	ubyte size;              // Size in words
    short attribute;
    uidControlBlock* nextEntry;
}

static this() {
	mixin(Module.registerModule("SysMemForKernel"));
	mixin(Module.registerModule("SysMemUserForUser"));
	mixin(Module.registerModule("sceSysEventForKernel"));
	mixin(Module.registerModule("sceSuspendForKernel"));
	mixin(Module.registerModule("sceSuspendForUser"));
	mixin(Module.registerModule("KDebugForKernel"));
}