module pspemu.hle.MemoryManager;

import pspemu.hle.ModuleManager;
public import pspemu.hle.kd.sysmem.Types;
import pspemu.hle.kd.sysmem.SysMem;
import pspemu.core.Memory;

class MemoryManager {
	Memory memory;
	ModuleManager moduleManager;
	SysMemUserForUser sysMemUserForUser;
	
	public this(Memory memory, ModuleManager moduleManager) {
		this.memory = memory;
		this.moduleManager = moduleManager;		
		this.sysMemUserForUser = moduleManager.get!(SysMemUserForUser);
	}
	
	public void free(uint ptr) {
		//return this.sysMemUserForUser.sce
	}
	
	public uint malloc(uint size) {
		return alloc(PspPartition.Kernel0, "malloc", PspSysMemBlockTypes.PSP_SMEM_Low, size);
	}

	public T* callocHost(T)(int count = 1) {
		return cast(T*)memory.getPointer(alloc(PspPartition.Kernel0, "malloc", PspSysMemBlockTypes.PSP_SMEM_Low, T.sizeof * count));
	}
	
	public uint alloc(PspPartition partition, string name, PspSysMemBlockTypes type, uint size, uint addr = 0) {
		SceUID mem = this.sysMemUserForUser.sceKernelAllocPartitionMemory(partition, name, type, size, addr);
		return this.sysMemUserForUser.sceKernelGetBlockHeadAddr(mem);
	}
	
	public uint allocAt(PspPartition partition, string name, uint size, uint addr) {
		return alloc(partition, name, PspSysMemBlockTypes.PSP_SMEM_Addr, size, addr);
	}
	
	public uint allocHeap(PspPartition partition, string name, uint size) {
		return alloc(partition, name, PspSysMemBlockTypes.PSP_SMEM_Low, size);
	}
	
	public uint allocStack(PspPartition partition, string name, uint size) {
		//auto segment = hleEmulatorState.moduleManager.get!SysMemUserForUser().allocStack(stackSize, std.string.format("stack for thread '%s'", name), true);
		//newThreadState.registers.SP = segment.block.high; 

		return this.sysMemUserForUser.allocStack(size, name, true).block.high - 0x10;
		//return alloc(partition, name, PspSysMemBlockTypes.PSP_SMEM_High, size) + size;
	}

	
	/*
	public uint allocBytes(ubyte[] bytes) {
		allocHeap();
		auto allocPartition = memoryPartition.allocLow(bytes.length, 8);
		emulatorState.memory.twrite(allocPartition.low, bytes); 
		return allocPartition.low;
	}
	*/
}