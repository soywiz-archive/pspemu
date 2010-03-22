module pspemu.formats.Elf;

import pspemu.utils.Utils;

import std.stdio, std.stream, std.string, std.math;

//debug = MODULE_LOADER;

class Elf {
	static struct Header {
		enum Type : ushort {
			Executable = 0x0002,
			Prx        = 0xFFA0,
		}
		enum Machine : ushort {
			ALLEGREX = 8,
		}

		char[4]  magic = [0x7F, 'E', 'L', 'F'];  //
		ubyte    _class;                         //
		ubyte    data;                           //
		ubyte    idver;                          //
		ubyte[9] _0;                             // Padding.
		Type     type;                           // Module type
		Machine  machine = Machine.ALLEGREX;     //
		uint     _version;                       //
		uint     entryPoint;                     // Module EntryPoint (PC)
		uint     programHeaderOffset;            // Program Header Offset
		uint     sectionHeaderOffset;            // Section Header Offset
		uint     flags;                          // Flags
		ushort   ehsize;                         //

		// Program Header.
		ushort   programHeaderEntrySize;         //
		ushort   programHeaderCount;             //

		// Section Header.
		ushort   sectionHeaderEntrySize;         //
		ushort   sectionHeaderCount;             // Section Header Num
		ushort   sectionHeaderStringTable;       // 

		// Check the size of the struct.
		static assert(this.sizeof == 52);
	}
	
	static struct SectionHeader { // ELF Section Header
		static enum Type : uint {
			NULL, PROGBITS, SYMTAB, STRTAB, RELA, HASH, DYNAMIC, NOTE, NOBITS, REL, SHLIB, DYNSYM,

			LOPROC = 0x70000000, HIPROC = 0x7FFFFFFF,
			LOUSER = 0x80000000, HIUSER = 0xFFFFFFFF,

			PRXRELOC = (LOPROC | 0xA0),
		}

		static enum Flags : uint { None = 0, Write = 1, Allocate = 2, Execute = 4 }

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
	}

	enum ModuleNids : uint {
		MODULE_INFO                   = 0xF01D73A7,
		MODULE_BOOTSTART              = 0xD3744BE0,
		MODULE_REBOOT_BEFORE          = 0x2F064FA6,
		MODULE_START                  = 0xD632ACDB,
		MODULE_START_THREAD_PARAMETER = 0x0F7C276C,
		MODULE_STOP                   = 0xCEE8593C,
		MODULE_STOP_THREAD_PARAMETER  = 0xCF0CC697,
	}
	
	static struct Reloc {
		enum Type : byte { None = 0, Mips16, Mips32, MipsRel32, Mips26, MipsHi16, MipsLo16, MipsGpRel16, MipsLiteral, MipsGot16, MipsPc16, MipsCall16, MipsGpRel32 }
		uint _offset;
		union {
			uint _info;
			struct {
				Type type;
				ubyte[3] _dummy;
				uint symbolIndex() { return _info >> 8; }
			}
		}

		// Check the size of the struct.
		static assert(this.sizeof == 8);
	}

	static struct Symbol {
		enum Type : ubyte { NoType = 0, Object = 1, Function = 2, Section = 3, File = 4, LoProc = 13, HiProc = 15 }
		enum Bind : ubyte { Local = 0, Global = 1, Weak = 2, LoProc = 13, HiProc = 15 }

		char[] name;
		uint   value;
		uint   size;
		Type   type;
		Bind   bind;
		ubyte  other;
		ushort index;
	}
	
	struct LoaderResult {
		uint EntryAddress;
		uint GlobalPointer;
		char[] Name;
	}

	Stream stream;
	Header header;
	SectionHeader[] sectionHeaders;
	string[] sectionHeaderNames;
	SectionHeader[string] sectionHeadersNamed;
	char[] stringTable;

	void dumpSections() {
		writefln("SectionHeader(%d):", sectionHeaders.length);
		foreach (n, sectionHeader; sectionHeaders) {
			writefln(
				"  SectionHeader(type=%08X, flags=%08X, mem=0x%08X, file=0x%06X, size=0x%05X) : '%s'",
				sectionHeader.type,
				sectionHeader.flags,
				sectionHeader.address,
				sectionHeader.offset,
				sectionHeader.size,
				sectionHeaderNames[n]
			);
		}
	}

	bool needsRelocation() { return (header.entryPoint < 0x08000000) || (header.type == Header.Type.Prx); }
	Stream SectionStream(SectionHeader sectionHeader) {
		//writefln("SectionStream(Address=%08X, Offset=%08X, Size=%08X, Type=%08X)", sectionHeader.address, sectionHeader.offset, sectionHeader.size, sectionHeader.type);

		switch (sectionHeader.type) {
			case SectionHeader.Type.PROGBITS:
			case SectionHeader.Type.STRTAB:
				//writefln("sectionHeader.offset:%08X", sectionHeader.offset);
				return new SliceStream(stream, sectionHeader.offset, sectionHeader.offset + sectionHeader.size);
			break;
			default:
				return new SliceStream(stream, sectionHeader.offset, sectionHeader.offset + sectionHeader.size);
				//return new SliceStream(stream, sectionHeader.address, sectionHeader.address + sectionHeader.size);
			break;
		}
	}
	Stream SectionStream(string name) {
		if (name !in sectionHeadersNamed) throw(new Exception(std.string.format("SectionHeader('%s') not found.", name)));
		return SectionStream(sectionHeadersNamed[name]);
	}

	this(Stream _stream) {
		stream = new SliceStream(_stream, 0);

		// Reader header.
		stream.readExact(&header, header.sizeof);

		// Checks that it's an ELF file and that it's a PSP ELF file.
		if (header.magic   != Header.init.magic  ) throw(new Exception(std.string.format("Magic '%s' != '%s'", header.magic, Header.init.magic)));
		if (header.machine != Header.init.machine) throw(new Exception(std.string.format("Machine %d != %d", header.machine, Header.init.machine)));

		// Section Headers
		extractSectionHeaders();
		extractSectionHeaderNames();
	}

	void extractSectionHeaderNames() {
		auto stringTableStream = SectionStream(sectionHeaderStringTable);
		stringTable = cast(char[])stringTableStream.readString(cast(uint)stringTableStream.size);
		sectionHeaderNames = [];
		string szToString(char *str) { return cast(string)str[0..std.c.string.strlen(str)]; }
		foreach (sectionHeader; sectionHeaders) {
			auto name = szToString(stringTable.ptr + sectionHeader.name);
			//writefln("---'%s'", sectionHeader.name);
			sectionHeaderNames ~= name;
			sectionHeadersNamed[name] = sectionHeader;
		}
	}

	ref SectionHeader sectionHeaderStringTable() {
		foreach (ref sectionHeader; sectionHeaders) {
			if (sectionHeader.type == SectionHeader.Type.STRTAB) {
				return sectionHeader;
			}
		}
		foreach (ref sectionHeader; sectionHeaders) {
			//writefln("%08X", sectionHeader.offset);
			auto stream = SectionStream(sectionHeader);
			auto text = stream.readString(min(11, cast(int)stream.size));
			//writefln("'%s'", text);
			if (text == "\0.shstrtab\0") {
				return sectionHeader;
			}
		}
		throw(new Exception("Can't find SectionHeaderStringTable."));
	}

	void extractSectionHeaders() {
		sectionHeaders = []; assert(SectionHeader.sizeof >= header.sectionHeaderEntrySize);
		try {
			foreach (index; 0 .. header.sectionHeaderCount) {
				SectionHeader sectionHeader = read!(SectionHeader)(
					stream,
					header.sectionHeaderOffset + (index * header.sectionHeaderEntrySize)
				);
				sectionHeaders ~= sectionHeader;
			}
		} catch {
		}
	}

	void reserveMemory(uint address, uint size) {
		//writefln("reserveMemory(%08X, %d)", address, size);
	}

	void performRelocation() {
		// TODO.
		throw(new Exception("Not implemented relocation yet."));
	}

	void allocateBlockBound(ref uint low, ref uint high) {
		low  = 0xFFFFFFFF;
		high = 0x00000000;
		foreach (sectionHeader; sectionHeaders) {
			if (sectionHeader.flags & SectionHeader.Flags.Allocate) {
				switch (sectionHeader.type) {
					case SectionHeader.Type.PROGBITS, SectionHeader.Type.NOBITS:
						low  = min(low , sectionHeader.address);
						high = max(high, sectionHeader.address + sectionHeader.size);
					break;
					default: break;
				}
			}
		}
	}

	uint requiredBlockSize() {
		uint low, high;
		allocateBlockBound(low, high);
		return high - low;
	}

	uint suggestedBlockAddress() {
		uint low, high;
		allocateBlockBound(low, high);
		return high;
	}

	void writeToMemory(Stream stream, uint baseAddress = 0) {
		if (needsRelocation) baseAddress += 0x08900000;
		foreach (k, sectionHeader; sectionHeaders) {			
			stream.position = baseAddress + sectionHeader.address;
			uint sectionHeaderOffset = cast(uint)stream.position;
			
			string typeString = "None";
			
			// Section to allocate
			if (sectionHeader.flags & SectionHeader.Flags.Allocate) {
				bool reserved = true;
				
				switch (sectionHeader.type) {
					default: reserved = false; typeString = "UNKNOWN"; break;
					case SectionHeader.Type.PROGBITS: typeString = "PROGBITS"; stream.copyFrom(SectionStream(sectionHeader)); break;
					case SectionHeader.Type.NOBITS  : typeString = "NOBITS"  ; writeZero(stream, sectionHeader.size); break;
				}
				
				if (reserved) reserveMemory(sectionHeader.address, sectionHeader.size);
				
				debug (MODULE_LOADER) writefln("%-16s: %08X[%08X] (%s)", typeString, sectionHeaderOffset, sectionHeader.size, sectionHeaderNames[k]);
			}
			// Section not to allocate
			else {
				debug (MODULE_LOADER) writefln("%-16s: %08X[%08X] (%s)", typeString, sectionHeaderOffset, sectionHeader.size, sectionHeaderNames[k]);
			}
		}
		if (needsRelocation) performRelocation();
	}

	SectionHeader[] relocationSectionHeaders() {
		SectionHeader[] list;
		foreach (sectionHeader; sectionHeaders) {
			if ((sectionHeader.type == SectionHeader.Type.PRXRELOC) || (sectionHeader.type == SectionHeader.Type.REL)) {
				list ~= sectionHeader;
			}
		}
		return list;
	}
}

version (unittest) {
	import pspemu.utils.SparseMemory;
}

unittest {
	const testPath = "demos";
	scope memory = new SparseMemoryStream;
	scope elf = new Elf(new BufferedFile(testPath ~ "/controller.elf", FileMode.In));
	elf.writeToMemory(memory);
	//memory.smartDump();

	//assert(0);
	//static void main() { }
}
