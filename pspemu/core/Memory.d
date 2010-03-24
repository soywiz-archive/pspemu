module pspemu.core.Memory;

// --------------------------
//  Related implementations:
// --------------------------
// OLD:       http://pspemu.googlecode.com/svn/branches/old/src/core/memory.d
// PSPPlayer: http://pspplayer.googlecode.com/svn/trunk/Noxa.Emulation.Psp.Cpu.R4000Ultra/R4000Memory.cpp
// Jpcsp:     http://jpcsp.googlecode.com/svn/trunk/src/jpcsp/memory/StandardMemory.java
// mfzpsp:    http://mfzpsp.googlecode.com/svn/c/mfzpsp/src/core/memory.c
// pcsp:      http://pcsp.googlecode.com/svn/trunk/pcsp-dbg/src/memory.h

import std.stdio, std.stream, std.string, std.ctype, std.metastrings;

import pspemu.utils.Utils;

version = VERSION_CHECK_MEMORY;    /// Check more memory positions.
version = VERSION_CHECK_ALIGNMENT; /// Check that read and writes are aligned.

/**--------------------------------+
| Adress                           |
| 31.............................0 |
| ku0hp--------------------------- |
| k - Kernel (only in kern mode)   |
| u - Uncached Bit                 |
| h - Hardware DMA                 |
| p - Physical main mem            |
+--------------------------------**/

/**
 * Exception class for memory exceptions.
 */
class MemoryException : public Exception { this(string s) { super(s); } }

/**
 * Exception class for an invalid memory address.
 */
class InvalidAddressException : public MemoryException {
	this(uint address) {
		super(std.string.format("Invalid address 0x%08X", address));
	}
}

/**
 * Exception class for an invalid alignment memory address.
 */
class InvalidAlignmentException : public MemoryException {
	this(uint address, uint alignment = 4) {
		super(std.string.format("Address 0x%08X not aligned to %d bytes.", address, alignment));
	}
}

/**
 * Class to handle the memory of the psp.
 * It can be used as a stream too.
 */
class Memory : Stream {
	/// Several physical memory segments.

	/// Psp Pointer.
	alias uint Pointer;

	/// Scartch Pad is a small memory segment of 16KB that has a very fast access.
	ubyte[] scratchPad ; static const int scratchPadAddress  = 0x00_010000, scratchPadMask  = 0x00003FFF;

	/// Frame Buffer is a integrated memory segment of 2MB for the GPU.
	/// GPU can also access main memory, but slowly.
	ubyte[] frameBuffer; static const int frameBufferAddress = 0x04_000000, frameBufferMask = 0x001FFFFF;

	/// Main Memory is a big physical memory of 16MB for fat and 32MB for slim.
	/// Currently it only supports fat 16MB.
	ubyte[] mainMemory ; static const int mainMemoryAddress  = 0x08_000000, mainMemoryMask  = 0x01FFFFFF;

	/**
	 * Constructor.
	 * It allocates all the physical memory segments and set the stream properties of the memory.
	 */
	public this() {
		// +3 for safety.
		this.scratchPad  = new ubyte[0x_4000    + 3];
		this.frameBuffer = new ubyte[0x_200000  + 3];
		this.mainMemory  = new ubyte[0x_2000000 + 3];
		// reset(); // D already sets all the new ubyte arrays to 0.

		this.streamInit();
	}

	/**
	 * Sets to zero all the physical memory.
	 */
	public void reset() {
		scratchPad [] = 0;
		frameBuffer[] = 0;
		mainMemory [] = 0;
	}

	/**
	 * HexDumps a slice of the memory.
	 *
	 * @param  address  Psp memory address.
	 * @param  nrows    Number of rows to show starting from address.
	 */
	public void dump(uint address, uint nrows = 0x10) {
		for (int row = 0; row < nrows; row++, address += 0x10) {
			.writef("%08X: ", address);
			foreach (value; this[address + 0x00..address + 0x10]) .writef("%02X ", value);
			.writef("| ");
			foreach (value; this[address + 0x00..address + 0x10]) .writef("%s", isprint(cast(dchar)value) ? cast(dchar)value : cast(dchar)'.');
			.writefln("");
		}
	}

	/**
	 * Obtains a pointer to a physical memory position.
	 *
	 * @param  address  Psp memory address.
	 *
	 * @return A physical PC pointer.
	 */
	public void* getPointer(Pointer address) {
		// Throws a MemoryException for an invalid address.
		static pure string InvalidAddress() {
			return "throw(new InvalidAddressException(address));";
		}

		// If version(VERSION_CHECK_MEMORY), check that the address is in a specified segment or throws an InvalidAddressException.
		static pure string CheckAddress(string segmentName) {
			return "version (VERSION_CHECK_MEMORY) if ((address < " ~ segmentName ~ "Address) || (address > (" ~ segmentName ~ "Address | " ~ segmentName ~ "Mask))) " ~ InvalidAddress ~ ";";
		}

		// Returns 
		static pure string ReturnSegment(string segmentName) {
			return "return &" ~ segmentName ~ "[address & " ~ segmentName ~ "Mask];";
		}

		// Check the address in this segment if version(VERSION_CHECK_MEMORY) and returns the host pointer.
		static pure string CheckAndReturnSegment(string segmentName) {
			return CheckAddress(segmentName) ~ ReturnSegment(segmentName);
		}
		
		//.writefln("Memory.getPointer(0x%08X)", address);

		address &= 0x1FFFFFFF; // Ignore last 3 bits (cache / kernel)
		switch (address >> 24) {
			/////// hp
			case 0b_00000: mixin(CheckAndReturnSegment("scratchPad")); break;
			/////// hp
			case 0b_00100: mixin(CheckAndReturnSegment("frameBuffer")); break;
			/////// hp
			case 0b_01000:
			case 0b_01001:
			case 0b_01010: // SLIM ONLY
			case 0b_01011: // SLIM ONLY
				mixin(CheckAndReturnSegment("mainMemory"));
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

	/**
	 * Obtains a guest address from a physical memory address.
	 *
	 * @param  ptr  A physical PC pointer.
	 *
	 * @return Psp memory address.
	 */
	public Pointer getPointerReverse(void *_ptr) {
		Pointer retval = getPointerReverseOrNull(_ptr);
		if (retval == 0) throw(new Exception(std.string.format("Can't find original pointer of address 0x%08X", cast(uint)_ptr)));
		return retval;
	}

	/**
	 * Obtains a guest address from a physical memory address.
	 *
	 * @param  ptr  A physical PC pointer.
	 *
	 * @return Psp memory address.
	 */
	public Pointer getPointerReverseOrNull(void *_ptr) {
		auto ptr = cast(ubyte *)_ptr;

		bool between(ubyte[] buffer) { return (ptr >= &buffer[0]) && (ptr < &buffer[$]); }

		string checkMap(string name, uint mapStart) {
			return "if (between(" ~ name ~ ")) return (ptr - " ~ name ~ ".ptr) + " ~ tos(mapStart) ~ ";";
		}
		
		mixin(checkMap("scratchPad",  0x00010000));
		mixin(checkMap("frameBuffer", 0x04000000));
		mixin(checkMap("mainMemory",  0x08000000));
		return 0;
	}

	/**
	 * Implementation of the read/write functions with several memory sizes.
	 */
	template ReadWriteTemplate() {
		private static pure string checkAlignment(string size) {
			return "version (VERSION_CHECK_ALIGNMENT) assert(((address & ((" ~ size ~ " >> 3) - 1)) == 0), std.string.format(\"Address 0x%08X not aligned to %d bytes.\", address, (" ~ size ~ " >> 3)));";
		}
		
		private static pure string writeGen(string size) {
			string r, type = "u" ~ size;
			{
				r ~= "void write" ~ size ~ "(uint address, " ~ type ~ " value) {";
				r ~= "    " ~ checkAlignment(size);
				r ~= "    *cast(" ~ type ~ "*)getPointer(address) = value;";
				r ~= "}";
			}
			return r;
		}

		private static pure string readGen(string size) {
			string r, type = "u" ~ size;
			{
				r ~= type ~ " read" ~ size ~ "(uint address) {";
				r ~= "    " ~ checkAlignment(size);
				r ~= "    return *cast(" ~ type ~ "*)getPointer(address);";
				r ~= "}";
			}
			return r;
		}

		/// Write functions.
		mixin(writeGen("8" ));
		mixin(writeGen("16"));
		mixin(writeGen("32"));
		mixin(writeGen("64"));

		/// Read functions.
		mixin(readGen("8" ));
		mixin(readGen("16"));
		mixin(readGen("32"));
		mixin(readGen("64"));
	}

	/**
	 * Implementation of opSlice and opIndex functions.
	 */
	template ArrayTemplate() {
		/**
		 * Obtains a mutable slice of the memory.
		 * @param  start  Memory address where the slice start.
		 * @param  end    Memory address where the slice end.
		 *
		 * @return Array slice with the data read.
		 */
		public ubyte[] opSlice(uint start, uint end) {
			assert(start <= end);

			// Implementation using stream. (Returns an immutable copy and it's safer)
			static if (0) {
				long backPosition = position; scope (exit) position = backPosition;
				position = start;
				return cast(ubyte[])readString(end - start);
			}
			// Implementation using getPointer. (Mutable and unsafe).
			else {
				assert((getPointer(end) - getPointer(start)) == end - start);
				return (cast(ubyte *)getPointer(start))[0..end - start];
			}
		}

		/**
		 * Sets a slice of the memory.
		 *
		 * @param  data   Array slice with the data to write.
		 * @param  start  Memory address where the slice start.
		 * @param  end    Memory address where the slice end.
		 *
		 * @return Array slice with the data written.
		 *
		 * <code>
		 * memory[0..10] = 0;
		 * </code>
		 */
		public ubyte[] opSliceAssign(ubyte[] data, uint start, uint end) {
			assert(start <= end);
			assert(data.length == end - start);

			// Implementation using stream. (Returns an immutable copy and it's safer)
			static if (0) {
				long backPosition = position; scope (exit) position = backPosition;
				position = start;
				write(data);
				return data;
			}
			// Implementation using getPointer. (Mutable and unsafe).
			else {
				assert((getPointer(end) - getPointer(start)) == end - start);
				auto slice = (cast(ubyte *)getPointer(start))[0..end - start];
				slice[] = data[];
				return slice;
			}
		}

		/**
		 * Obtains a single byte from memory.
		 *
		 * @param  address  Memory address to load from.
		 *
		 * @return A single byte with the data in that memory address.
		 */
		ubyte opIndex(uint address) { return read8(address); }

		/**
		 * Sets a single byte on memory.
		 *
		 * @param  address  Memory address to write to.
		 *
		 * @return A single byte with the data set in that memory address.
		 */
		ubyte opIndexAssign(ubyte value, uint address) { write8(address, value); return read8(address); }
	}

	/**
	 * Implementation of the Stream abstract methids.
	 */
	template StreamTemplate() {
		/// Position of the stream.
		uint streamPosition = 0;

		/**
		 * Initializes the stream.
		 */
		void streamInit() {
			this.seekable  = true;
			this.readable  = true;
			this.writeable = true;
		}

		override {
			/**
			 * Reads a block of memory from this stream.
			 *
			 * @param  _data  Pointer of an array that will store the contents of the stream.
			 * @param  _len   Number of bytes that will be readed.
			 *
			 * @return Number of bytes readed. Will always be the number of requested bytes to read.
			 */
			size_t readBlock(void *_data, size_t len) {
				u8 *data = cast(u8*)_data; int rlen = len;
				while (len-- > 0) *data++ = read8(streamPosition++);
				return rlen;
			}

			/**
			 * Writes a block of memory in this tream.
			 *
			 * @param  _data  Pointer of an array that contains the data to write.
			 * @param  _len   Number of bytes that will be written.
			 *
			 * @return Number of bytes written. Will always be the number of requested bytes to write.
			 */
			size_t writeBlock(const void *_data, size_t len) {
				u8 *data = cast(u8*)_data; int rlen = len;
				while (len-- > 0) write8(streamPosition++, *data++);
				return rlen;
			}

			/**
			 * Seeks the stream.
			 *
			 * @param  offset  Offset data.
			 * @param  whence  Type of seeking.
			 *
			 * @return Current position in the stream.
			 */
			ulong seek(long offset, SeekPos whence) {
				switch (whence) {
					case SeekPos.Current: streamPosition += offset; break;
					case SeekPos.Set, SeekPos.End: streamPosition = cast(uint)offset; break;
				}
				return streamPosition;
			}

			/**
			 * Determines wheter the stream reached the end or not.
			 *
			 * @return Always false, because never will get to the end of the stream.
			 */
			bool eof() { return false; }
		}
	}

	mixin ReadWriteTemplate;
	mixin StreamTemplate;
	mixin ArrayTemplate;
}

/+
// http://hitmen.c02.at/files/yapspd/psp_doc/chap4.html#sec4.10
class Cache {
	struct Row {
		ubyte data[64];
	}

	union {
		Row rows[512];
		ubyte data[0x8000]; // 32 KB
	}

	short cached[0x80000]; // 32MB of memory in 64byte segments.
}
+/

/*
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
*/

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");

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

	// Check opSlice, opSliceAssign.
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
