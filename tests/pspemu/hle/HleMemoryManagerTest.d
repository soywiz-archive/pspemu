module pspemu.hle.HleMemoryManagerTest;

import pspemu.core.Memory;
import pspemu.hle.HleMemoryManager;

import tests.Test;

class HleMemoryManagerTest : Test {
	mixin TRegisterTest;
	
	Memory memory;
	HleMemoryManager hleMemoryManager;
	
	this() {
		memory = new Memory();
	}
	
	void setUp() {
		hleMemoryManager = new HleMemoryManager(memory); 
	}
	
	void testAllocStackAlignedTo_0x10() {
		foreach (expectedStackSize; [23, 32, 111, 0]) {
			MemorySegment memorySegment = hleMemoryManager.allocStack(PspPartition.User, "Test1", expectedStackSize, true);
			assertTrue(memorySegment.block.size >= expectedStackSize);
			assertTrue((memorySegment.block.size % 0x10) == 0);
		}
	}
	
	void testAllocStackFilledWith_0xFF() {
		uint expectedStackSize = 23;
		MemorySegment memorySegment = hleMemoryManager.allocStack(PspPartition.User, "Test1", expectedStackSize, true);
		foreach (c; memory[memorySegment.block.low..memorySegment.block.high]) {
			if (c != 0xFF) {
				assertFail();
				return;
			}
		}
		assertSuccess();
	}
}