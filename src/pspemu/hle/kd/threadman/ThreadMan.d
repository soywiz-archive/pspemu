module pspemu.hle.kd.threadman.ThreadMan; // kd/threadman.prx (sceThreadManager)

import pspemu.hle.ModuleNative;

import pspemu.hle.ModuleNative;
import pspemu.hle.HleEmulatorState;

import core.thread;

import std.stdio;
import std.math;

import pspemu.hle.kd.threadman.ThreadMan_Threads;
import pspemu.hle.kd.threadman.ThreadMan_Semaphores;
import pspemu.hle.kd.threadman.ThreadMan_Events;
import pspemu.hle.kd.threadman.ThreadMan_Callbacks;
import pspemu.hle.kd.threadman.ThreadMan_VTimers;
import pspemu.hle.kd.threadman.ThreadMan_MsgPipes;
import pspemu.hle.kd.threadman.ThreadMan_Mutex;
import pspemu.hle.kd.threadman.ThreadMan_Mbx;
import pspemu.hle.kd.threadman.Types;
import pspemu.hle.MemoryManager;

import pspemu.utils.Logger;
import pspemu.utils.String;

import pspemu.utils.sync.WaitMultipleObjects;
import pspemu.utils.sync.CriticalSection;

import pspemu.hle.Callbacks;

import std.datetime;

import pspemu.hle.kd.SceKernelErrors;

import pspemu.hle.kd.rtc.Types;
import pspemu.hle.kd.sysmem.SysMem;

//debug = DEBUG_THREADS;
//debug = DEBUG_SYSCALL;

class MemoryPool {
	MemorySegment memorySegment;
	
	public this(MemorySegment memorySegment) {
		this.memorySegment = memorySegment;
	}
	
	string toString() {
		return std.string.format("%s", memorySegment);
	}
}

class VariablePool : MemoryPool {
	public this(MemorySegment memorySegment) {
		super(memorySegment);
	}
}

class FixedPool : MemoryPool {
	int blockSize;
	int numberOfBlocks;
	int currentBlock;

	public this(MemorySegment memorySegment, int blockSize, int numberOfBlocks) {
		this.blockSize = blockSize;
		this.numberOfBlocks = numberOfBlocks;
		super(memorySegment);
	}
	
	uint allocate() {
		scope (exit) currentBlock++;
		if (currentBlock >= numberOfBlocks) throw(new Exception("Can't allocate more blocks"));
		return memorySegment.block.low + currentBlock * blockSize;
	}
}


/**
 * Library imports for the kernel threading library.
 */
class ThreadManForUser : HleModuleHost {
	mixin TRegisterModule;
	
	mixin ThreadManForUser_Threads;
	mixin ThreadManForUser_Semaphores;
	mixin ThreadManForUser_Events;
	mixin ThreadManForUser_Callbacks;
	mixin ThreadManForUser_VTimers;
	mixin ThreadManForUser_MsgPipes;
	mixin ThreadManForUser_Mutex;
	mixin ThreadManForUser_Mbx;

	void initModule() {
		initModule_Threads();
		initModule_Semaphores();
		initModule_Events();
		initModule_Mutex();
		initModule_Callbacks();
		initModule_VTimers();
		initModule_MsgPipes();
		initModule_Mbx();
		//moduleManager.getCurrentThreadName = { return threadManager.currentThread.name; };
	}

	void initNids() {
		initNids_Threads();
		initNids_Semaphores();
		initNids_Events();
		initNids_Mutex();
		initNids_Callbacks();
		initNids_VTimers();
		initNids_MsgPipes();
		initNids_Mbx();
		
		mixin(registerFunction!(0x369ED59D, sceKernelGetSystemTimeLow));
		mixin(registerFunction!(0x82BC5777, sceKernelGetSystemTimeWide));

		mixin(registerFunction!(0xC8CD158C, sceKernelUSec2SysClockWide));

		mixin(registerFunction!(0x56C039B5, sceKernelCreateVpl));
		//mixin(registerFunction!(0xD979E9BF, sceKernelAllocateVpl));
		mixin(registerFunction!(0xAF36D708, sceKernelTryAllocateVpl));
		mixin(registerFunction!(0x39810265, sceKernelReferVplStatus));
		mixin(registerFunction!(0xB736E9FF, sceKernelFreeVpl));

		mixin(registerFunction!(0x64D4540E, sceKernelReferThreadProfiler));
		mixin(registerFunction!(0x8218B4DD, sceKernelReferGlobalProfiler));
		
		mixin(registerFunction!(0xC07BB470, sceKernelCreateFpl));
		mixin(registerFunction!(0x623AE665, sceKernelTryAllocateFpl));
		mixin(registerFunction!(0xD979E9BF, sceKernelAllocateFpl));
		
	    mixin(registerFunction!(0x110DEC9A, sceKernelUSec2SysClock));
	    mixin(registerFunction!(0xC8CD158C, sceKernelUSec2SysClockWide));
	    
	    mixin(registerFunction!(0x912354A7, sceKernelRotateThreadReadyQueue));
	}
	
	void sceKernelRotateThreadReadyQueue() {
		unimplemented_notice();
	}
	
	/**
	 * Converts microseconds to system clock and writes it to the specified pointer.
	 */
	int sceKernelUSec2SysClock(uint usec, ulong* sysclock) {
		*sysclock = cast(ulong)usec;
		return 0;
	}

	/**
	 * Converts microseconds to system clock and returns it.
	 */
	ulong sceKernelUSec2SysClockWide(ulong usec) {
		return usec;
	}
	
	/**
	 * Create a fixed pool
	 *
	 * @param name   - Name of the pool
	 * @param part   - The memory partition ID
	 * @param attr   - Attributes
	 * @param size   - Size of pool block
	 * @param blocks - Number of blocks to allocate
	 * @param opt    - Options (set to NULL)
	 *
	 * @return The UID of the created pool, < 0 on error.
	 */
	//int sceKernelCreateFpl(const char *name, int part, int attr, uint size, uint blocks, SceKernelFplOptParam *opt) {
	SceUID sceKernelCreateFpl(string name, int part, int attr, uint size, uint blocks, void *opt) {
		//new MemorySegment
		logWarning("sceKernelCreateFpl('%s', %d, %d, %d, %d)", name, part, attr, size, blocks);
		FixedPool fixedPool;
		fixedPool = new FixedPool(
			hleEmulatorState.moduleManager.get!SysMemUserForUser()._allocateMemorySegmentLow(part, dupStr(name), size * blocks),
			size,
			blocks
		);
		logWarning("%s", fixedPool);
		return uniqueIdFactory.add(fixedPool);
	}
	
	/**
	 * Allocate from the pool. It will wait for a free block to be available the specified time.
	 *
	 * @param uid     - The UID of the pool
	 * @param data**  - Receives the address of the allocated data
	 * @param timeout - Amount of time to wait for allocation?
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelAllocateFpl(SceUID uid, uint dataPtr, uint *timeout) {
		logWarning("sceKernelAllocateFpl(%d, %08X, %08X) @TODO Not waiting", uid, dataPtr, cast(uint)timeout);
		return sceKernelTryAllocateFpl(uid, dataPtr);
	}
	
	/**
	 * Try to allocate from the pool immediately.
	 *
	 * @param uid    - The UID of the pool
	 * @param data** - Receives the address of the allocated data
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelTryAllocateFpl(SceUID uid, uint dataPtr) {
		logWarning("sceKernelTryAllocateFpl(%d, %08X)", uid, dataPtr);
		FixedPool fixedPool = uniqueIdFactory.get!FixedPool(uid);
		try {
			currentMemory().twrite(dataPtr, cast(uint)fixedPool.allocate());
			return 0;
		} catch (Exception e) {
			return SceKernelErrors.ERROR_KERNEL_NO_MEMORY;
		}
		//return sceKernelTryAllocateVpl(uid, data);
	}

	/**
	 * Get the thread profiler registers.
	 * @return Pointer to the registers, NULL on error
	 */
	PspDebugProfilerRegs* sceKernelReferThreadProfiler() {
		unimplemented();
		return null;
	}

	/**
	 * Get the globile profiler registers.
	 * @return Pointer to the registers, NULL on error
	 */
	PspDebugProfilerRegs *sceKernelReferGlobalProfiler() {
		unimplemented();
		return null;
	}

	/**
	 * Free a block
	 *
	 * @param uid - The UID of the pool
	 * @param data - The data block to deallocate
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelFreeVpl(SceUID uid, void* data) {
		unimplemented();
		return -1;
	}

	/**
	 * Create a variable pool
	 *
	 * @param name - Name of the pool
	 * @param part - The memory partition ID
	 * @param attr - Attributes
	 * @param size - Size of pool
	 * @param opt  - Options (set to NULL)
	 *
	 * @return The UID of the created pool, < 0 on error.
	 */
	//SceUID sceKernelCreateVpl(string name, int part, int attr, uint size, SceKernelVplOptParam* opt) {
	SceUID sceKernelCreateVpl(string name, int part, int attr, uint size, void* opt) {
	    const PSP_VPL_ATTR_MASK      = 0x41FF;  // Anything outside this mask is an illegal attr.
	    const PSP_VPL_ATTR_ADDR_HIGH = 0x4000;  // Create the vpl in high memory.
	    const PSP_VPL_ATTR_EXT       = 0x8000;  // Extend the vpl memory area (exact purpose is unknown).
		//new MemorySegment
		logWarning("sceKernelCreateVpl('%s', %d, %d, %d)", name, part, attr, size);
		VariablePool variablePool;
		if (attr & PSP_VPL_ATTR_ADDR_HIGH) {
			variablePool = new VariablePool(hleEmulatorState.moduleManager.get!SysMemUserForUser()._allocateMemorySegmentHigh(part, dupStr(name), size));
		} else {
			variablePool = new VariablePool(hleEmulatorState.moduleManager.get!SysMemUserForUser()._allocateMemorySegmentLow(part, dupStr(name), size));
		}
		logWarning("%s", variablePool);
		return uniqueIdFactory.add(variablePool);
	}
	
	/**
	 * Allocate from the pool
	 *
	 * @param uid     - The UID of the pool
	 * @param size    - The size to allocate
	 * @param data    - Receives the address of the allocated data
	 * @param timeout - Amount of time to wait for allocation?
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelAllocateVpl(SceUID uid, uint size, uint** data, uint *timeout) {
		logWarning("sceKernelAllocateVpl(%d, %d, %08X) @TODO Not waiting", uid, size, cast(uint)data);
		return sceKernelTryAllocateVpl(uid, size, data);
	}

	/**
	 * Try to allocate from the pool 
	 *
	 * @param uid  - The UID of the pool
	 * @param size - The size to allocate
	 * @param data - Receives the address of the allocated data
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelTryAllocateVpl(SceUID uid, uint size, uint** data) {
		logWarning("sceKernelTryAllocateVpl(%d, %d, %08X)", uid, size, cast(uint)data);
		VariablePool variablePool = uniqueIdFactory.get!VariablePool(uid);
		*data = cast(uint *)variablePool.memorySegment.allocByLow(size).block.low;
		logWarning(" <<<---", *data);
		//unimplemented();
		return 0;
	}

	/**
	 * Convert a number of microseconds to a wide time
	 * 
	 * @param usec - Number of microseconds.
	 *
	 * @return The time
	 */
	SceInt64 sceKernelUSec2SysClockWide(uint usec) {
		unimplemented();
		return 0;
	}

	/**
	 * Get the status of an VPL
	 *
	 * @param uid - The uid of the VPL
	 * @param info - Pointer to a ::SceKernelVplInfo structure
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelReferVplStatus(SceUID uid, SceKernelVplInfo* info) {
		unimplemented();
		return -1;
	}

	/**
	 * Get the system time (wide version)
	 *
	 * @return The system time
	 */
	SceInt64 sceKernelGetSystemTimeWide() {
		return cast(ulong)systime_to_tick(Clock.currTime(UTC()));
	}

	/**
	 * Get the low 32bits of the current system time
	 *
	 * @return The low 32bits of the system time
	 */
	uint sceKernelGetSystemTimeLow() {
		return cast(uint)sceKernelGetSystemTimeWide();
	}
}


struct SceKernelMbxOptParam {
	/** Size of the ::SceKernelMbxOptParam structure. */
	SceSize 	size;
}

struct SceKernelMbxInfo {
	SceSize 	size;     // Size of the ::SceKernelMbxInfo structure.
	char 		name[32]; // NUL-terminated name of the messagebox.
	SceUInt 	attr;     // Attributes
	int 		numWaitThreads; // The number of threads waiting on the messagebox.
	int 		numMessages; // Number of messages currently in the messagebox.
	void		*firstMessage; // The message currently at the head of the queue.
}

struct PspDebugProfilerRegs {
	//volatile:
	u32 enable;
	u32 systemck;
	u32 cpuck;
	u32 internal;
	u32 memory;
	u32 copz;
	u32 vfpu;
	u32 sleep;
	u32 bus_access;
	u32 uncached_load;
	u32 uncached_store;
	u32 cached_load;
	u32 cached_store;
	u32 i_miss;
	u32 d_miss;
	u32 d_writeback;
	u32 cop0_inst;
	u32 fpu_inst;
	u32 vfpu_inst;
	u32 local_bus;
}

struct SceKernelVplOptParam {
	SceSize size;
}

struct SceKernelVplInfo {
	SceSize  size;
	char[32] name;
	SceUInt  attr;
	int      poolSize;
	int      freeSize;
	int      numWaitThreads;
}

/**
 * Library imports for the kernel threading library.
 */
class ThreadManForKernel : ThreadManForUser {
}

static this() {
	mixin(ModuleNative.registerModule("ThreadManForKernel"));
	mixin(ModuleNative.registerModule("ThreadManForUser"));
}
