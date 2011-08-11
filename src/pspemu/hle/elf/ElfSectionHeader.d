module pspemu.hle.elf.ElfSectionHeader;

import std.string;

static struct ElfSectionHeader {
	static enum Type : uint {
		NULL      = 0,
		PROGBITS  = 1,
		SYMTAB    = 2,
		STRTAB    = 3,
		RELA      = 4,
		HASH      = 5,
		DYNAMIC   = 6,
		NOTE      = 7,
		NOBITS    = 8,
		REL       = 9,
		SHLIB     = 0xA,
		DYNSYM    = 0xB,

		LOPROC = 0x70000000, HIPROC = 0x7FFFFFFF,
		LOUSER = 0x80000000, HIUSER = 0xFFFFFFFF,

		PRXRELOC     = (LOPROC | 0xA0),
		PRXRELOC_FW5 = (LOPROC | 0xA1),
	}

	static enum Flags : uint {
		None     = 0,
		Write    = 1,
		Allocate = 2,
		Execute  = 4,
	}

	uint  name;       /// Position relative to .shstrtab of a stringz with the name.
	Type  type;       /// Type of this section header.
	Flags flags;      /// Flags associated to this section header.
	uint  address;    /// Memory address where it should be stored.
	uint  offset;     /// File position where is the data related to this section header.
	uint  size;       /// Size of the section header.
	uint  link;       ///
	uint  info;       ///
	uint  addralign;  ///
	uint  entsize;    ///

	// Check the size of the struct.
	static assert(this.sizeof == 10 * 4);
	
	string toString() {
		// SHeader(type=00000003, f=00, addr=00000000, off=00080C18, size=0003CF, link=00, info=00, aa=01, esize=00, name=03C5)
		return std.string.format(
			"SHeader(type=%08X, f=%03b, addr=%08X, off=%08X, size=%06X, link=%02X, info=%02X, aa=%02X, esize=%02X, name=%04X)",
			type, flags, address, offset, size, link, info, addralign, entsize, name
		);
	}
}
