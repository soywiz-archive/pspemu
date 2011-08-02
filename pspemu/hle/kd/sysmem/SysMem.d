module pspemu.hle.kd.sysmem.SysMem; // kd/sysmem.prx (sceSystemMemoryManager)

import pspemu.hle.ModuleNative;

import std.conv;
import std.stdio;

public import pspemu.utils.MemorySegment;
public import pspemu.hle.kd.sysmem.Types;


import pspemu.utils.Logger;

class SysMemUserForUser : ModuleNative {
	MemorySegment allocStack(uint stackSize, string name, bool fillFF = true) {
		stackSize &= ~0xF;
		stackSize += 0x600;
		auto segment = pspMemorySegmentStacks.allocByHigh(stackSize, std.string.format("Stack for %s", name));
		//writefln("allocStack!!! %s Size(%d)", segment, stackSize);
		if (fillFF) currentEmulatorState.memory[segment.block.low..segment.block.high][] = 0xFF;
		return segment;
	}

	MemorySegment pspMemorySegment;
	MemorySegment pspMemorySegmentStacks;

	void initModule() {
		uint ramAddrLow  = 0x08000000;
		uint ramAddrHigh = ramAddrLow + 64 * 1024 * 1024;
		
		pspMemorySegment       = new MemorySegment(ramAddrLow, ramAddrHigh, "PSP Memory");
		pspMemorySegmentStacks = new MemorySegment(ramAddrLow, ramAddrHigh, "PSP Memory Stacks");
		
		pspMemorySegment.allocByAddr(0x08000000,  4 * 1024 * 1024, "Kernel Memory 1");
		pspMemorySegment.allocByAddr(0x08400000,  4 * 1024 * 1024, "Kernel Memory 2");
		pspMemorySegment.allocByAddr(0x08800000, (64 - 4 - 4) * 1024 * 1024, "User Memory");
		
		logTrace("pspMemorySegment.allocByAddr:: %s", pspMemorySegment.toString);
	}

	void initNids() {
		mixin(registerd!(0xA291F107, sceKernelMaxFreeMemSize));
		mixin(registerd!(0x237DBD4F, sceKernelAllocPartitionMemory));
		mixin(registerd!(0x9D9A5BA1, sceKernelGetBlockHeadAddr));
		mixin(registerd!(0xF919F628, sceKernelTotalFreeMemSize));
		mixin(registerd!(0xB6D61D02, sceKernelFreePartitionMemory));
		mixin(registerd!(0x3FC9AE6A, sceKernelDevkitVersion));
		mixin(registerd!(0x13A5ABEF, sceKernelPrintf));
		mixin(registerd!(0xF77D77CB, sceKernelSetCompilerVersion));
		mixin(registerd!(0x7591C7DB, sceKernelSetCompiledSdkVersion));
		mixin(registerd!(0x342061E5, sceKernelSetCompiledSdkVersion370));
		mixin(registerd!(0x315AD3A0, sceKernelSetCompiledSdkVersion380_390));
		mixin(registerd!(0xEBD5C3E6, sceKernelSetCompiledSdkVersion395));
	}

	// @TODO: Unknown.
	void sceKernelSetCompiledSdkVersion(uint param) {
		Logger.log(Logger.Level.TRACE, "SysMemUserForUser", "sceKernelSetCompiledSdkVersion: 0x%08X", param);
	}

	// @TODO: Unknown.
	void sceKernelSetCompilerVersion(uint param) {
		logInfo("sceKernelSetCompilerVersion: 0x%08X", param);
	}

	void sceKernelSetCompiledSdkVersion370(uint param) {
		logInfo("sceKernelSetCompiledSdkVersion370: 0x%08X", param);
	}
	
	void sceKernelSetCompiledSdkVersion380_390(uint param) {
		logInfo("sceKernelSetCompiledSdkVersion370: 0x%08X", param);
	}
	
	void sceKernelSetCompiledSdkVersion395(uint param) {
		logInfo("sceKernelSetCompiledSdkVersion395: 0x%08X", param);
	}

	// @TODO: Unknown.
	void sceKernelPrintf(char* text) {
		Logger.log(Logger.Level.TRACE, "SysMemUserForUser", "sceKernelPrintf");
		unimplemented();
	}

	/**
	 * Get the firmware version.
	 * 
	 * 0x01000300 on v1.00 unit,
	 * 0x01050001 on v1.50 unit,
	 * 0x01050100 on v1.51 unit,
	 * 0x01050200 on v1.52 unit,
	 * 0x02000010 on v2.00/v2.01 unit,
	 * 0x02050010 on v2.50 unit,
	 * 0x02060010 on v2.60 unit,
	 * 0x02070010 on v2.70 unit,
	 * 0x02070110 on v2.71 unit.
	 *
	 * @return The firmware version.
	 */
	int sceKernelDevkitVersion() {
		Logger.log(Logger.Level.TRACE, "SysMemUserForUser", "sceKernelDevkitVersion");
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
		Logger.log(Logger.Level.INFO, "SysMemUserForUser", "sceKernelFreePartitionMemory(%d)", blockid);
		MemorySegment memorySegment = uniqueIdFactory.get!(MemorySegment)(blockid);
		memorySegment.free();
		uniqueIdFactory.remove!(MemorySegment)(blockid);
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
		//writefln("%s", pspMemorySegment[2]);
		SceSize maxFreeMemSize = pspMemorySegment[2].getMaxAvailableMemoryBlock();
		Logger.log(Logger.Level.INFO, "sysmem", "maxFreeMemSize(%d, %.2f MB)", maxFreeMemSize, (cast(real)maxFreeMemSize) / 1024 / 1024);
		// maxFreeMemSize
		// @TODO Maybe game allocates all the memory, but alloc an stack can overlap the memory. Check this.
		//return maxFreeMemSize - 20000;
		//return maxFreeMemSize - 1 * 1024 * 1024;
		return maxFreeMemSize;
		//return 5 * 1024 * 1024;
	}
	
	MemorySegment _allocateMemorySegmentLow(SceUID partitionid, string name, uint size) {
		//return pspMemorySegment[partitionid].allocByHigh(size, dupStr(name));
		return pspMemorySegment[partitionid].allocByLow(size, dupStr(name));
	}

	MemorySegment _allocateMemorySegmentHigh(SceUID partitionid, string name, uint size) {
		return pspMemorySegment[partitionid].allocByHigh(size, dupStr(name));
	}

	/**
	 * Allocate a memory block from a memory partition.
	 *
	 * @param partitionid - The UID of the partition to allocate from.
	 * @param name - Name assigned to the new block.
	 * @param type - Specifies how the block is allocated within the partition.  One of ::PspSysMemBlockTypes.
	 * @param size - Size of the memory block, in bytes.
	 * @param addr - If type is PSP_SMEM_Addr, then addr specifies the lowest address allocate the block from. If not, the alignment size.
	 *
	 * @return The UID of the new block, or if less than 0 an error.
	 */
	SceUID sceKernelAllocPartitionMemory(SceUID partitionid, string name, PspSysMemBlockTypes type, SceSize size, /* void* */uint addr) {
		const uint ERROR_KERNEL_ILLEGAL_MEMBLOCK_ALLOC_TYPE = 0x800200d8;
		const uint ERROR_KERNEL_FAILED_ALLOC_MEMBLOCK       = 0x800200d9;

		try {
			MemorySegment memorySegment;
			
			Logger.log(Logger.Level.INFO, "SysMemUserForUser", "sceKernelAllocPartitionMemory(%d:'%s':%s:%d,0x%08X)", partitionid, name, std.conv.to!string(type), size, addr);
			//Logger.log(Logger.Level.INFO, "SysMemUserForUser", "sceKernelAllocPartitionMemory(%d:'%s':%d:%d)", partitionid, name, (type), size);
			
			int alignment = 1;
			if ((type == PspSysMemBlockTypes.PSP_SMEM_Low_Aligned) || (type == PspSysMemBlockTypes.PSP_SMEM_High_Aligned)) {
				alignment = addr;
			}
	
			switch (type) {
				default: return ERROR_KERNEL_ILLEGAL_MEMBLOCK_ALLOC_TYPE;
				case PspSysMemBlockTypes.PSP_SMEM_Low_Aligned:
				case PspSysMemBlockTypes.PSP_SMEM_Low : memorySegment = pspMemorySegment[partitionid].allocByLow (size, dupStr(name), 0, alignment); break;
				case PspSysMemBlockTypes.PSP_SMEM_High_Aligned:
				case PspSysMemBlockTypes.PSP_SMEM_High: memorySegment = pspMemorySegment[partitionid].allocByHigh(size, dupStr(name), alignment); break;
				case PspSysMemBlockTypes.PSP_SMEM_Addr: memorySegment = pspMemorySegment[partitionid].allocByAddr(addr, size, dupStr(name)); break;
			}
	
			if (memorySegment is null) return ERROR_KERNEL_FAILED_ALLOC_MEMBLOCK;
			
			SceUID sceUid = uniqueIdFactory.add(memorySegment);
			
			Logger.log(Logger.Level.INFO, "SysMemUserForUser", "sceKernelAllocPartitionMemory(%d:'%s':%s:%d) :: (%d) -> %s", partitionid, name, std.conv.to!string(type), size, sceUid, memorySegment.block);
			//Logger.log(Logger.Level.INFO, "SysMemUserForUser", "sceKernelAllocPartitionMemory(%d:'%s':%d:%d) :: (%d) -> %s", partitionid, name, (type), size, sceUid, memorySegment.block);

			return sceUid;
		} catch (Throwable o) {
			logError("ERROR: %s", o);
			return ERROR_KERNEL_FAILED_ALLOC_MEMBLOCK;
		}
	}

	/**
	 * Get the address of a memory block.
	 *
	 * @param blockid - UID of the memory block.
	 *
	 * @return The lowest address belonging to the memory block.
	 */
	uint sceKernelGetBlockHeadAddr(SceUID blockid) {
		MemorySegment memorySegment = uniqueIdFactory.get!(MemorySegment)(blockid);
		return memorySegment.block.low;
	}
}

class SysMemForKernel : ModuleNative {
}

static this() {
	mixin(ModuleNative.registerModule("SysMemForKernel"));
	mixin(ModuleNative.registerModule("SysMemUserForUser"));
}
