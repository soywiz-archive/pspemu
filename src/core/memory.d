module pspemu.core.memory;

import std.stdio;
import std.stream;
import std.string;
import std.ctype;
import std.metastrings;

version = VERSION_CHECK_MEMORY;
version = VERSION_CHECK_ALIGNMENT;

// +----------------------------------+
// | Adress                           |
// | 31.............................0 |
// | ku0hp--------------------------- |
// | k - Kernel (only in kern mode)   |
// | u - Uncached Bit                 |
// | h - Hardware DMA                 |
// | p - Physical main mem            |
// +----------------------------------+

struct MemorySegment { enum Type { PHY, DMA } Type type; uint addressStart, addressMask; string name; }

const PspMemorySegmentsFat = [
	MemorySegment( MemorySegment.Type.PHY, 0x00010000, 0x00003FFF, "Scratchpad"       ), // 16 KB
	MemorySegment( MemorySegment.Type.PHY, 0x04000000, 0x001FFFFF, "Frame Buffer"     ), // 2 MB
	MemorySegment( MemorySegment.Type.PHY, 0x08000000, 0x01FFFFFF, "Main Memory"      ), // FAT: 32 MB | SLIM: 64 MB
	MemorySegment( MemorySegment.Type.DMA, 0x1C000000, 0x03BFFFFF, "Hardware IO 1"    ),
	MemorySegment( MemorySegment.Type.PHY, 0x1FC00000, 0x000FFFFF, "Hardware Vectors" ), // 1 MB
	MemorySegment( MemorySegment.Type.DMA, 0x1FD00000, 0x002FFFFF, "Hardware IO 2"    ),
	MemorySegment( MemorySegment.Type.PHY, 0x88000000, 0x01FFFFFF, "Kernel Memory"    ), // Main Memory
];

class MemoryException : public Exception { this(string s) { super(s); } }

template MemoryStreamTemplate() {
	uint streamPosition = 0;
	
	override size_t readBlock(void *_data, size_t len) {
		u8 *data = cast(u8*)_data; int rlen = len;
		while (len-- > 0) *data++ = read8(streamPosition++);
		return rlen;
	}

	override size_t writeBlock(const void *_data, size_t len) {
		u8 *data = cast(u8*)_data; int rlen = len;
		while (len-- > 0) write8(streamPosition++, *data++);
		return rlen;
	}
	
	override ulong seek(long offset, SeekPos whence) {
		switch (whence) {
			case SeekPos.Current: streamPosition += offset; break;
			case SeekPos.Set: case SeekPos.End: streamPosition = cast(uint)offset; break;
		}
		return streamPosition;
	}
}

class Memory : Stream {
	ubyte[] scratchPad ; static const int scratchPadAddress  = 0x00_010000, scratchPadMask  = 0x00003FFF;
	ubyte[] frameBuffer; static const int frameBufferAddress = 0x04_000000, frameBufferMask = 0x001FFFFF;
	ubyte[] mainMemory ; static const int mainMemoryAddress  = 0x08_000000, mainMemoryMask  = 0x01FFFFFF;

	public this() {
		// +3 for safety.
		scratchPad  = new ubyte[0x_4000    + 3];
		frameBuffer = new ubyte[0x_200000  + 3];
		mainMemory  = new ubyte[0x_2000000 + 3];
		// reset(); // D already sets all the new ubyte arrays to 0.
	}
	
	public void reset() {
		scratchPad [0..$] = 0;
		frameBuffer[0..$] = 0;
		mainMemory [0..$] = 0;
	}

	public ubyte[] opSlice(uint start, uint end) {
		long backPosition = position; scope (exit) position = backPosition;
		position = start;
		return cast(ubyte[])readString(end - start);
	}

	public ubyte[] opSliceAssign(ubyte[] data, uint start, uint end) {
		long backPosition = position; scope (exit) position = backPosition;
		position = start;
		write(data);
		return data;
	}

	public void dump(uint address) {
		for (int row = 0; row < 0x10; row++, address += 0x10) {
			.writef("%08X: ", address);
			foreach (value; this[address + 0x00..address + 0x10]) .writef("%02X ", value);
			.writef("| ");
			foreach (value; this[address + 0x00..address + 0x10]) .writef("%s", isprint(cast(dchar)value) ? cast(dchar)value : cast(dchar)'.');
			.writefln("");
		}
	}

	public void* getPointer(uint address) {
		static pure string InvalidAddress() { return "throw(new MemoryException(std.string.format(\"Invalid address 0x%08X\", address)));"; }
		static pure string CheckAddress(string name) { return "if ((address < " ~ name ~ "Address) || (address > (" ~ name ~ "Address | " ~ name ~ "Mask))) " ~ InvalidAddress ~ ";"; }
		static pure string ReturnSegment(string name) { return "return &" ~ name ~ "[address & " ~ name ~ "Mask];"; }

		address &= 0x1FFFFFFF; // Ignore last 3 bits (cache / kernel)
		switch (address >> 24) {
			/////// hp
			case 0b_00000:
				// Scratch Pad-
				version (VERSION_CHECK_MEMORY) mixin(CheckAddress("scratchPad"));
				mixin(ReturnSegment("scratchPad"));
			break;
			/////// hp
			case 0b_00100:
				// Frame Buffer.
				version (VERSION_CHECK_MEMORY) mixin(CheckAddress("frameBuffer"));
				mixin(ReturnSegment("frameBuffer"));
			break;
			/////// hp
			case 0b_01000:
			case 0b_01001:
			case 0b_01010: // SLIM ONLY
			case 0b_01011: // SLIM ONLY
				// Main Memory.
				version (VERSION_CHECK_MEMORY) mixin(CheckAddress("mainMemory"));
				mixin(ReturnSegment("mainMemory"));
			break;
			/////// hp
			case 0b_11100: // HW IO1
			case 0b_11111: // HO IO2
				mixin(InvalidAddress);
				//return null;
			break;
			default:
				mixin(InvalidAddress);
			break;
		}
	}

	private static pure string checkAlignment(string size) {
		return "assert(((address & ((" ~ size ~ " >> 3) - 1)) == 0), std.string.format(\"Address 0x%08X not aligned to %d bytes.\", address, (" ~ size ~ " >> 3)));";
	}
	
	private static pure string writeGen(string size) {
		string r, type = "u" ~ size;
		{
			r ~= "void write" ~ size ~ "(uint address, " ~ type ~ " value) {";
			version (VERSION_CHECK_ALIGNMENT) r ~= checkAlignment(size);
			r ~= "    auto pointer = cast(" ~ type ~ "*)getPointer(address);";
			r ~= "    *pointer = value;";
			r ~= "}";
		}
		return r;
	}

	private static pure string readGen(string size) {
		string r, type = "u" ~ size;
		{
			r ~= type ~ " read" ~ size ~ "(uint address) {";
			version (VERSION_CHECK_ALIGNMENT) r ~= checkAlignment(size);
			r ~= "    auto pointer = cast(" ~ type ~ "*)getPointer(address);";
			r ~= "    return *pointer;";
			r ~= "}";
		}
		return r;
	}

	alias uint   u32;
	alias ushort u16;
	alias ubyte  u8;

	mixin(writeGen("8" ));
	mixin(writeGen("16"));
	mixin(writeGen("32"));

	mixin(readGen("8" ));
	mixin(readGen("16"));
	mixin(readGen("32"));

	alias read8 opIndex;
	//alias write8 opIndexAssign;
	ubyte opIndexAssign(ubyte value, uint address) { write8(address, value); return read8(address); }
	
	mixin MemoryStreamTemplate;
}

unittest {
	writefln("Unittesting: Memory...");

	const int pos = Memory.frameBufferAddress;

	scope memory = new Memory();

	// Check physical memory.
	foreach (value; [0x10, 0xFF, 'a']) {
		foreach (address; [Memory.scratchPadAddress, Memory.frameBufferAddress, Memory.frameBufferAddress]) {
			memory.write32(address + 4, cast(uint)  value); assert(memory.read32(address + 4) == value);
			memory.write16(address + 2, cast(ushort)value); assert(memory.read16(address + 2) == value);
			memory.write8 (address + 1, cast(ubyte) value); assert(memory.read8 (address + 1) == value);
		}
	}

	// Check it's little endian.
	memory.write32(pos, 0x_12_34_56_78);
	foreach (n, v; x"78 56 34 12") assert(memory.read8(pos + n) == v);

	// Check Stream interface.
	memory.position = pos;
	memory.writef("%s", "Hola, esto es una prueba.");
	memory.writefln(" Indeed %03d.", 23);
	memory.position = pos;
	assert(memory.readString(25 + 12) == "Hola, esto es una prueba. Indeed 023.");

	// Check Slicing.
	memory[pos + 4..pos + 8] = memory[pos + 0..pos + 4];
	assert(memory[pos + 0..pos + 8] == cast(ubyte[])"HolaHola");

	// Check opIndex, opIndexAssign.
	memory[pos] = 1U;
	assert(memory[pos] == 1U);

	// Reset memory should set all positions to 0.
	memory.reset();
	assert(memory[pos] == 0);

	//static void main() { }
}
