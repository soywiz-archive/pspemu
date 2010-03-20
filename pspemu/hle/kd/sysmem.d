module pspemu.hle.kd.sysmem; // kd/sysmem.prx (sceSystemMemoryManager)

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class SysMemUserForUser : Module {
	this() {
		mixin(registerd!(0xA291F107, sceKernelMaxFreeMemSize));
		mixin(registerd!(0x237DBD4F, sceKernelAllocPartitionMemory));
		mixin(registerd!(0x9D9A5BA1, sceKernelGetBlockHeadAddr));

		mixin(register(0xF919F628, "sceKernelTotalFreeMemSize"));
		mixin(register(0xB6D61D02, "sceKernelFreePartitionMemory"));
		mixin(register(0x3FC9AE6A, "sceKernelDevkitVersion"));
	}

	/**
	 * Get the size of the largest free memory block.
	 *
	 * @return The size of the largest free memory block, in bytes.
	 */
	SceSize sceKernelMaxFreeMemSize() {
		return 8 * 1024 * 1024; // 8 MB
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
	SceUID sceKernelAllocPartitionMemory(SceUID partitionid, const char* name, int type, SceSize size, void* addr) {
		return 1;
	}

	/**
	 * Get the address of a memory block.
	 *
	 * @param blockid - UID of the memory block.
	 *
	 * @return The lowest address belonging to the memory block.
	 */
	uint sceKernelGetBlockHeadAddr(SceUID blockid) {
		return 0x08_000000;
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

static this() {
	mixin(Module.registerModule("SysMemForKernel"));
	mixin(Module.registerModule("SysMemUserForUser"));
	mixin(Module.registerModule("sceSysEventForKernel"));
	mixin(Module.registerModule("sceSuspendForKernel"));
	mixin(Module.registerModule("sceSuspendForUser"));
	mixin(Module.registerModule("KDebugForKernel"));
}