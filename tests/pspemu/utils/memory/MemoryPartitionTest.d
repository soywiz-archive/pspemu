module pspemu.utils.memory.MemoryPartitionTest;

import pspemu.utils.memory.MemoryPartition;
import tests.Test;

class MemoryPartitionTest : Test {
	MemoryPartition segment, segment1, segment2, segment3;

	public void testAlloc() {
		segment = new MemoryPartition(0, 1000);
		segment1 = segment.alloc(20);
		segment2 = segment.alloc(20);
		segment3 = segment.alloc(20);

		assertEquals(segment.toString2(), "MemoryPartition(0, 1000, false)[MemoryPartition(0, 20, true), MemoryPartition(20, 40, true), MemoryPartition(40, 60, true), MemoryPartition(60, 1000, false)]");

		segment.freeByLow(segment2.low);
		assertEquals(segment.toString2(), "MemoryPartition(0, 1000, false)[MemoryPartition(0, 20, true), MemoryPartition(20, 40, false), MemoryPartition(40, 60, true), MemoryPartition(60, 1000, false)]");

		segment2 = segment.alloc(10);
		assertEquals(segment.toString2(), "MemoryPartition(0, 1000, false)[MemoryPartition(0, 20, true), MemoryPartition(20, 30, true), MemoryPartition(30, 40, false), MemoryPartition(40, 60, true), MemoryPartition(60, 1000, false)]");

		segment.freeByLow(segment2.low);
		assertEquals(segment.toString2(), "MemoryPartition(0, 1000, false)[MemoryPartition(0, 20, true), MemoryPartition(20, 40, false), MemoryPartition(40, 60, true), MemoryPartition(60, 1000, false)]");

		segment2 = segment.alloc(20);
		assertEquals(segment.toString2(), "MemoryPartition(0, 1000, false)[MemoryPartition(0, 20, true), MemoryPartition(20, 40, false), MemoryPartition(40, 60, true), MemoryPartition(60, 80, true), MemoryPartition(80, 1000, false)]");

		expectException!NotEnoughSpaceException({
			segment2 = segment.alloc(1000);
		});
	}
}
