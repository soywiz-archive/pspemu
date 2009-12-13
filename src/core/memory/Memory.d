module core.memory.Memory;

struct MemorySegment {
	enum Type { PHY, DMA }
	Type   type;
	uint   memoryFrom;
	uint   memoryTo;
	string name;
}

// +----------------------------------+
// | Adress                           |
// | 31.............................0 |
// | ku0hp--------------------------- |
// | k - Kernel (only in kern mode)   |
// | u - Uncached Bit                 |
// | h - Hardware DMA                 |
// | p - Physical main mem            |
// +----------------------------------+

const PspMemorySegmentsFat = [
	MemorySegment( MemorySegment.Type.PHY, 0x00010000, 0x00003FFF, "Scratchpad"       ),
	MemorySegment( MemorySegment.Type.PHY, 0x04000000, 0x001FFFFF, "Frame Buffer"     ),
	MemorySegment( MemorySegment.Type.PHY, 0x08000000, 0x01FFFFFF, "Main Memory"      ), // 32 MB
	MemorySegment( MemorySegment.Type.DMA, 0x1C000000, 0x03BFFFFF, "Hardware IO 1"    ),
	MemorySegment( MemorySegment.Type.PHY, 0x1FC00000, 0x000FFFFF, "Hardware Vectors" ),
	MemorySegment( MemorySegment.Type.DMA, 0x1FD00000, 0x002FFFFF, "Hardware IO 2"    ),
	MemorySegment( MemorySegment.Type.PHY, 0x88000000, 0x01FFFFFF, "Kernel Memory"    ), // Main Memory
];

const PspMemorySegmentsSlim = [
	MemorySegment( MemorySegment.Type.PHY, 0x00010000, 0x00003FFF, "Scratchpad"       ),
	MemorySegment( MemorySegment.Type.PHY, 0x04000000, 0x001FFFFF, "Frame Buffer"     ),
	MemorySegment( MemorySegment.Type.PHY, 0x08000000, 0x03FFFFFF, "Main Memory"      ), // 64 MB
	MemorySegment( MemorySegment.Type.DMA, 0x1C000000, 0x03BFFFFF, "Hardware IO 1"    ),
	MemorySegment( MemorySegment.Type.PHY, 0x1FC00000, 0x000FFFFF, "Hardware Vectors" ),
	MemorySegment( MemorySegment.Type.DMA, 0x1FD00000, 0x002FFFFF, "Hardware IO 2"    ),
	MemorySegment( MemorySegment.Type.PHY, 0x88000000, 0x03FFFFFF, "Kernel Memory"    ), // Main Memory
];

class Memory {

}