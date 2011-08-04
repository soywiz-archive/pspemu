module pspemu_tests.utils.MemoryPartitionTests;

import pspemu.utils.MemoryPartition;

import std.stdio;

class MemoryPartitionTests {
	public void test() {
		testAlloc();
	}
	
	public void testAlloc() {
		writef("testAlloc...");
		{
			auto segment = new MemoryPartition(0, 1000);
			auto segment1 = segment.alloc(20);
			auto segment2 = segment.alloc(20);
			auto segment3 = segment.alloc(20);
			assert(segment.toString(), "MemoryManager(0, 1000, false)[MemoryManager(0, 20, true), MemoryManager(20, 40, true), MemoryManager(40, 60, true), MemoryManager(60, 1000, false)]");
			segment.freeByLow(segment2.low);
			assert(segment.toString(), "MemoryManager(0, 1000, false)[MemoryManager(0, 20, true), MemoryManager(20, 40, false), MemoryManager(40, 60, true), MemoryManager(60, 1000, false)]");
			segment2 = segment.alloc(10);
			assert(segment.toString(), "MemoryManager(0, 1000, false)[MemoryManager(0, 20, true), MemoryManager(20, 30, true), MemoryManager(30, 40, false), MemoryManager(40, 60, true), MemoryManager(60, 1000, false)]");
			segment.freeByLow(segment2.low);
			assert(segment.toString(), "MemoryManager(0, 1000, false)[MemoryManager(0, 20, true), MemoryManager(20, 40, false), MemoryManager(40, 60, true), MemoryManager(60, 1000, false)]");
			segment2 = segment.alloc(20);
			assert(segment.toString(), "MemoryManager(0, 1000, false)[MemoryManager(0, 20, true), MemoryManager(20, 40, false), MemoryManager(40, 60, true), MemoryManager(60, 80, true), MemoryManager(80, 1000, false)]");
			try {
				segment2 = segment.alloc(1000);
				assert(false);
			} catch (NotEnoughSpaceException notEnoughSpaceException) {
				//writefln("expected exception");
				assert(true);
			}
		}
		writefln("Ok");
	}
}