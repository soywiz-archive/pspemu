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
import pspemu.hle.kd.threadman.Types;
import pspemu.hle.MemoryManager;

import pspemu.utils.Logger;
import pspemu.utils.String;

import pspemu.utils.sync.WaitMultipleObjects;
import pspemu.utils.sync.CriticalSection;

import pspemu.hle.Callbacks;

import std.datetime;

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
class ThreadManForUser : ModuleNative {
	mixin ThreadManForUser_Threads;
	mixin ThreadManForUser_Semaphores;
	mixin ThreadManForUser_Events;
	mixin ThreadManForUser_Callbacks;
	mixin ThreadManForUser_VTimers;
	mixin ThreadManForUser_MsgPipes;

	void initModule() {
		initModule_Threads();
		initModule_Semaphores();
		initModule_Events();
		initModule_Callbacks();
		initModule_VTimers();
		initModule_MsgPipes();
		//moduleManager.getCurrentThreadName = { return threadManager.currentThread.name; };
	}

	void initNids() {
		initNids_Threads();
		initNids_Semaphores();
		initNids_Events();
		initNids_Callbacks();
		initNids_VTimers();
		initNids_MsgPipes();
		
		mixin(registerd!(0x369ED59D, sceKernelGetSystemTimeLow));
		mixin(registerd!(0x82BC5777, sceKernelGetSystemTimeWide));

		mixin(registerd!(0x8125221D, sceKernelCreateMbx));
		mixin(registerd!(0x86255ADA, sceKernelDeleteMbx));
		mixin(registerd!(0xE9B3061E, sceKernelSendMbx));
		mixin(registerd!(0x18260574, sceKernelReceiveMbx));
		mixin(registerd!(0x0D81716A, sceKernelPollMbx));
		mixin(registerd!(0x87D4DD36, sceKernelCancelReceiveMbx));
		mixin(registerd!(0xA8E8C846, sceKernelReferMbxStatus));

		mixin(registerd!(0xC8CD158C, sceKernelUSec2SysClockWide));

		mixin(registerd!(0x56C039B5, sceKernelCreateVpl));
		//mixin(registerd!(0xD979E9BF, sceKernelAllocateVpl));
		mixin(registerd!(0xAF36D708, sceKernelTryAllocateVpl));
		mixin(registerd!(0x39810265, sceKernelReferVplStatus));
		mixin(registerd!(0xB736E9FF, sceKernelFreeVpl));

		mixin(registerd!(0x64D4540E, sceKernelReferThreadProfiler));
		mixin(registerd!(0x8218B4DD, sceKernelReferGlobalProfiler));
		
		mixin(registerd!(0xC07BB470, sceKernelCreateFpl));
		mixin(registerd!(0x623AE665, sceKernelTryAllocateFpl));
		mixin(registerd!(0xD979E9BF, sceKernelAllocateFpl));
		
	    mixin(registerd!(0x110DEC9A, sceKernelUSec2SysClock));
	    mixin(registerd!(0xC8CD158C, sceKernelUSec2SysClockWide));
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
	 * Allocate from the pool
	 *
	 * @param uid     - The UID of the pool
	 * @param data    - Receives the address of the allocated data
	 * @param timeout - Amount of time to wait for allocation?
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelAllocateFpl(SceUID uid, uint** data, uint *timeout) {
		logWarning("sceKernelAllocateFpl(%d, %08X, %08X) @TODO Not waiting", uid, cast(uint)data, cast(uint)timeout);
		return sceKernelTryAllocateFpl(uid, data);
	}
	
	/**
	 * Try to allocate from the pool 
	 *
	 * @param uid  - The UID of the pool
	 * @param data - Receives the address of the allocated data
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceKernelTryAllocateFpl(SceUID uid, uint** data) {
		logWarning("sceKernelTryAllocateFpl(%d, %08X)", uid, cast(uint)data);
		FixedPool fixedPool = uniqueIdFactory.get!FixedPool(uid);
		try {
			*data = cast(uint *)fixedPool.allocate();
			return 0;
		} catch (Exception e) {
			return -1;
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
	 * Creates a new messagebox
	 *
	 * @par Example:
	 * @code
	 * int mbxid;
	 * mbxid = sceKernelCreateMbx("MyMessagebox", 0, NULL);
	 * @endcode
	 *
	 * @param name - Specifies the name of the mbx
	 * @param attr - Mbx attribute flags (normally set to 0)
	 * @param option - Mbx options (normally set to NULL)
	 * @return A messagebox id
	 */
	SceUID sceKernelCreateMbx(string name, SceUInt attr, SceKernelMbxOptParam* option) {
		unimplemented();
		return -1;
	}

	/**
	 * Destroy a messagebox
	 *
	 * @param mbxid - The mbxid returned from a previous create call.
	 * @return Returns the value 0 if its succesful otherwise an error code
	 */
	int sceKernelDeleteMbx(SceUID mbxid) {
		unimplemented();
		return -1;
	}

	/**
	 * Send a message to a messagebox
	 *
	 * @par Example:
	 * @code
	 * struct MyMessage {
	 * 	SceKernelMsgPacket header;
	 * 	char text[8];
	 * };
	 *
	 * struct MyMessage msg = { {0}, "Hello" };
	 * // Send the message
	 * sceKernelSendMbx(mbxid, (void*) &msg);
	 * @endcode
	 *
	 * @param mbxid - The mbx id returned from sceKernelCreateMbx
	 * @param message - A message to be forwarded to the receiver.
	 * 					The start of the message should be the 
	 * 					::SceKernelMsgPacket structure, the rest
	 *
	 * @return < 0 On error.
	 */
	int sceKernelSendMbx(SceUID mbxid, void *message) {
		unimplemented();
		return -1;
	}

	/**
	 * Wait for a message to arrive in a messagebox
	 *
	 * @par Example:
	 * @code
	 * void *msg;
	 * sceKernelReceiveMbx(mbxid, &msg, NULL);
	 * @endcode
	 *
	 * @param mbxid - The mbx id returned from sceKernelCreateMbx
	 * @param pmessage - A pointer to where a pointer to the
	 *                   received message should be stored
	 * @param timeout - Timeout in microseconds
	 *
	 * @return < 0 on error.
	 */
	int sceKernelReceiveMbx(SceUID mbxid, void **pmessage, SceUInt *timeout) {
		unimplemented();
		return -1;
	}

	/**
	 * Check if a message has arrived in a messagebox
	 *
	 * @par Example:
	 * @code
	 * void *msg;
	 * sceKernelPollMbx(mbxid, &msg);
	 * @endcode
	 *
	 * @param mbxid - The mbx id returned from sceKernelCreateMbx
	 * @param pmessage - A pointer to where a pointer to the
	 *                   received message should be stored
	 *
	 * @return < 0 on error (SCE_KERNEL_ERROR_MBOX_NOMSG if the mbx is empty).
	 */
	int sceKernelPollMbx(SceUID mbxid, void **pmessage) {
		unimplemented();
		return -1;
	}

	/**
	 * Abort all wait operations on a messagebox
	 *
	 * @par Example:
	 * @code
	 * sceKernelCancelReceiveMbx(mbxid, NULL);
	 * @endcode
	 *
	 * @param mbxid - The mbx id returned from sceKernelCreateMbx
	 * @param pnum  - A pointer to where the number of threads which
	 *                were waiting on the mbx should be stored (NULL
	 *                if you don't care)
	 *
	 * @return < 0 on error
	 */
	int sceKernelCancelReceiveMbx(SceUID mbxid, int *pnum) {
		unimplemented();
		return -1;
	}

	/**
	 * Retrieve information about a messagebox.
	 *
	 * @param mbxid - UID of the messagebox to retrieve info for.
	 * @param info - Pointer to a ::SceKernelMbxInfo struct to receive the info.
	 *
	 * @return < 0 on error.
	 */
	int sceKernelReferMbxStatus(SceUID mbxid, SceKernelMbxInfo *info) {
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
