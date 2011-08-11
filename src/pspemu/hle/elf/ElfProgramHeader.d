module pspemu.hle.elf.ElfProgramHeader;

import std.string;

static struct ElfProgramHeader {
	enum Type : uint {
		NO_LOAD = 0,
		LOAD    = 1,
	}
	
	enum Flags : uint {
		NONE = 0,
	}

	/**
	 * Type of segment
	 */
	Type type;
	
	/**
	 * Offset for segment's first byte in file
	 */
	uint offsetOnFile;
	
	/**
	 * Virtual address for segment
	 */
	uint virtualAddress;
	
	/**
	 * Physical address for segment
	 */
	uint physicalAddress;
	
	/**
	 * Segment image size in file
	 */
	uint sizeOnFile;
	
	/**
	 * Segment image size in memory
	 */
	uint sizeOnMemory;
	
	/**
	 * Flags
	 */
	Flags flags;
	
	/**
	 * Alignment
	 */
	uint alignment; 
	
	string toString() {
		return std.string.format(
			"ProgramHeader(type=%02X, offset=%08X, vaddr=%08X, paddr=%08X, filesz=%08X, memsz=%08X, flags=%02X, align=%02X)",
			type, offsetOnFile, virtualAddress, physicalAddress, sizeOnFile, sizeOnMemory, flags, alignment
		);
	}
	
	static assert (this.sizeof == 8 * uint.sizeof);
}
/*
Example:
	ProgramHeader(type=01, offset=00000080, vaddr=00000000, paddr=001752D0, filesz=001A4E38, memsz=001A4E38, flags=07, align=40)
	ProgramHeader(type=01, offset=001A4EC0, vaddr=001A4E40, paddr=00000000, filesz=0014118C, memsz=00D5F75C, flags=06, align=40)
*/