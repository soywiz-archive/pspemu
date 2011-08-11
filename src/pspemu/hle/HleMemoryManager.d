module pspemu.hle.HleMemoryManager;

public import pspemu.hle.kd.sysmem.Types;
public import pspemu.core.Memory;
public import pspemu.utils.memory.MemorySegment;

class HleMemoryManager {
	protected Memory memory;
	protected MemorySegment rootMemorySegment;
	protected MemorySegment rootMemorySegmentStacks;
	
	public this(Memory memory) {
		this.memory = memory;
		init();
	}
	
	protected void init() {
		uint ramSize = 32 * 1024 * 1024;
		
		uint ramAddrLow  = 0x08000000;
		uint ramAddrHigh = ramAddrLow + ramSize;
		
		this.rootMemorySegment       = new MemorySegment(ramAddrLow, ramAddrHigh, "PSP Memory");
		this.rootMemorySegmentStacks = new MemorySegment(ramAddrLow, ramAddrHigh, "PSP Memory Stacks");
		
		this.rootMemorySegment.allocByAddr(0x08000000,  4 * 1024 * 1024, "Kernel Memory 1");
		this.rootMemorySegment.allocByAddr(0x08400000,  4 * 1024 * 1024, "Kernel Memory 2");
		this.rootMemorySegment.allocByAddr(0x08800000, ramSize - (4 + 4) * 1024 * 1024, "User Memory");
		
		rootMemorySegment[PspPartition.User].allocByLow(0x4000, "unknown");
	}

	/**
	 * Returns total free memory on User's partition.  
	 */
	public @property uint userFreeMemory() {
		return rootMemorySegment[PspPartition.User].getFreeMemory;
	}

	/**
	 * Returns maximum contiguous free memory on User's partition.  
	 */
	public @property uint userMaxFreeMemoryBlock() {
		return rootMemorySegment[PspPartition.User].getMaxAvailableMemoryBlock();
	}

	/**
	 * Allocs a stack.
	 *
	 * @param  partition  - Partition to alloc from
	 * @param  name       - Name of the stack to alloc
	 * @param  stackSize  - Size of the stack
	 * @param  fillFF     - Should we fill the stack with FF?
	 *
	 * @return The allocated MemorySegment for the stack
	 */
	public MemorySegment allocStack(PspPartition partition, string name, uint stackSize, bool fillFF = true) {
		if (stackSize & 0xF) {
			stackSize = (stackSize + 0x10) & ~0xF;
		}
		auto segment = rootMemorySegmentStacks.allocByHigh(stackSize, std.string.format("Stack for %s", name));
		if (fillFF) this.memory[segment.block.low..segment.block.high][] = 0xFF;
		return segment;
	}
	
	/+
	public void free(uint ptr) {
		//memorySegment.free();
		//return this.sysMemUserForUser.sce
	}
	
	public uint malloc(uint size) {
		return alloc(PspPartition.Kernel0, "malloc", PspSysMemBlockTypes.PSP_SMEM_Low, size);
	}

	public T* callocHost(T)(int count = 1) {
		return cast(T*)memory.getPointer(alloc(PspPartition.Kernel0, "malloc", PspSysMemBlockTypes.PSP_SMEM_Low, T.sizeof * count));
	}
	
	public uint alloc(PspPartition partition, string name, PspSysMemBlockTypes type, uint size, uint addr = 0) {
		return this.sysMemUserForUser.sceKernelGetBlockHeadAddr(
			this.sysMemUserForUser.sceKernelAllocPartitionMemory(partition, name, type, size, addr)
		);
	}
	
	public uint allocAt(PspPartition partition, string name, uint size, uint addr) {
		return alloc(partition, name, PspSysMemBlockTypes.PSP_SMEM_Addr, size, addr);
	}
	
	public uint allocHeap(PspPartition partition, string name, uint size) {
		return alloc(partition, name, PspSysMemBlockTypes.PSP_SMEM_Low, size);
	}
	
	/*
	public uint allocBytes(ubyte[] bytes) {
		allocHeap();
		auto allocPartition = memoryPartition.allocLow(bytes.length, 8);
		emulatorState.memory.twrite(allocPartition.low, bytes); 
		return allocPartition.low;
	}
	*/
	+/
}