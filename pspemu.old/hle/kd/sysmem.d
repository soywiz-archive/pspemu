module pspemu.hle.kd.sysmem; // kd/sysmem.prx (sceSystemMemoryManager)

//debug = DEBUG_SYSCALL;
//debug = DEBUG_MEMORY_ALLOCS;

import pspemu.hle.Module;
public import pspemu.utils.MemorySegment;

import pspemu.utils.Logger;

class SysMemUserForUser : Module {
	MemorySegment allocStack(uint stackSize, string name, bool fillFF = true) {
		stackSize &= ~0xF;
		stackSize += 0x600;
		auto segment = pspMemorySegmentStacks.allocByHigh(stackSize, std.string.format("Stack for %s", name));
		//writefln("allocStack!!! %s Size(%d)", segment, stackSize);
		if (fillFF) executionState.memory[segment.block.low..segment.block.high][] = 0xFF;
		return segment;
	}

	MemorySegment pspMemorySegment;
	MemorySegment pspMemorySegmentStacks;

	void initModule() {
		pspMemorySegment       = new MemorySegment(0x08000000, 0x0A000000, "PSP Memory");
		//pspMemorySegmentStacks = new MemorySegment(0x08000000, 0x08400000 - 0x100, "PSP Memory Stacks");
		pspMemorySegmentStacks = new MemorySegment(0x08000000, 0x0A000000, "PSP Memory Stacks");
		
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
		mixin(registerd!(0x13A5ABEF, sceKernelPrintf));
		mixin(registerd!(0x7591C7DB, sceKernelSetCompiledSdkVersion));
		mixin(registerd!(0xF77D77CB, sceKernelSetCompilerVersion));
	}

	// @TODO: Unknown.
	void sceKernelSetCompiledSdkVersion(uint param) {
		writefln("sceKernelSetCompiledSdkVersion: 0x%08X", param);
	}

	// @TODO: Unknown.
	void sceKernelSetCompilerVersion(uint param) {
		writefln("sceKernelSetCompilerVersion: 0x%08X", param);
	}

	// @TODO: Unknown.
	void sceKernelPrintf(char* text) {
		unimplemented();
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
		reinterpret!(MemorySegment)(blockid).free();
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
		
		Logger.log(Logger.Level.DEBUG, "sysmem", "sceKernelAllocPartitionMemory -> (%08X-%08X)", memorySegment.block.low, memorySegment.block.high);

		return reinterpret!(SceUID)(memorySegment);
	}

	/**
	 * Get the address of a memory block.
	 *
	 * @param blockid - UID of the memory block.
	 *
	 * @return The lowest address belonging to the memory block.
	 */
	uint sceKernelGetBlockHeadAddr(SceUID blockid) {
		return reinterpret!(MemorySegment)(blockid).block.low;
	}
}

class SysMemForKernel : Module {
}

class sceSysEventForKernel : Module {
}

class sceSuspendForKernel : Module {
	void initNids() {
		mixin(registerd!(0xEADB1BD7, sceKernelPowerLock));
		mixin(registerd!(0x3AEE7261, sceKernelPowerUnlock));
		mixin(registerd!(0x090CCB3F, sceKernelPowerTick));
	}

	// @TODO: Unknown.
	void sceKernelPowerLock() {
		unimplemented();
	}

	// @TODO: Unknown.
	void sceKernelPowerUnlock() {
		unimplemented();
	}

	// @TODO: Unknown.
	void sceKernelPowerTick() {
		unimplemented();
	}
}

class sceSuspendForUser : sceSuspendForKernel {
}

class KDebugForKernel : Module {
	void initNids() {
		mixin(registerd!(0x7CEB2C09, sceKernelRegisterKprintfHandler));
		mixin(registerd!(0x84F370BC, Kprintf));
	}

	void sceKernelRegisterKprintfHandler() { unimplemented(); }
	void Kprintf(string format, ...) {
		string outstr = "";
		void output(string s) {
			outstr ~= s;
			//writef("%s", s);
		}
		int parampos = 0;
		bool hasfloat = false;
		//int paramposf = 0;
		current_vparam = 1;
		for (int n = 0; n < format.length; n++) {
			if (format[n] == '%') {
				int longcount = 0;
				int m = n;
				while (++n < format.length) {
					switch (format[n]) {
						case 's':
							output(std.string.format(format[m..n + 1], readparam!(string)));
							goto endwhile;
						break;
						case 'u', 'x', 'X':
							if (longcount >= 2) {
								output(std.string.format(format[m..n + 1], readparam!(ulong)));
							} else {
								output(std.string.format(format[m..n + 1], readparam!(uint)));
							}
							goto endwhile;
						break;
						case 'd':
							if (longcount >= 2) {
								output(std.string.format(format[m..n + 1], readparam!(long)));
							} else {
								output(std.string.format(format[m..n + 1], readparam!(int)));
							}
							goto endwhile;
						break;
						case 'f': {
							//if (longcount >= 2) {
							if (true) {
								output(std.string.format(format[m..n + 1], readparam!(double))); 
							} else {
								output(std.string.format(format[m..n + 1], readparam!(float))); 
							}
							goto endwhile;
						} break;
						case 'l':
							longcount++;
						break;
						default:
						break;
					}
				}
				endwhile:;
			} else {
				output(format[n..n + 1]);
			}
		}
		writef("%s", outstr);
		//unimplemented();
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
