module pspemu.formats.elf.Elf;

//import pspemu.All;

import pspemu.core.cpu.Instruction;

import pspemu.utils.StructUtils;
import pspemu.utils.StreamUtils;
import pspemu.utils.MathUtils;
//import pspemu.utils.MemoryPartition;
import pspemu.hle.MemoryManager;
//import pspemu.utils.Logger;

import std.stream;
import std.stdio;
import std.math;
import std.conv;

import pspemu.utils.Logger;

//debug = MODULE_LOADER;

// http://hitmen.c02.at/files/yapspd/psp_doc/chap26.html#sec26.2
class Elf {
	// http://advancedpsp.tk/foro_es/viewtopic.php?f=22&t=17
	static struct Header {
		enum Type    : ushort { Executable = 0x0002, Prx = 0xFFA0 }
		enum Machine : ushort { ALLEGREX = 8 }

		// e_ident 16 bytes.
		char[4]  magic = [0x7F, 'E', 'L', 'F'];  /// 
		ubyte    _class;                         ///
		ubyte    data;                           ///
		ubyte    idver;                          ///
		ubyte[9] _0;                             /// Padding.

		Type     type;                           /// Identifies object file type
		Machine  machine = Machine.ALLEGREX;     /// Architecture build
		uint     _version;                       /// Object file version
		uint     entryPoint;                     /// Virtual address of code entry. Module EntryPoint (PC)
		uint     programHeaderOffset;            /// Program header table's file offset in bytes
		uint     sectionHeaderOffset;            /// Section header table's file offset in bytes
		uint     flags;                          /// Processor specific flags
		ushort   ehsize;                         /// ELF header size in bytes

		// Program Header.
		ushort   programHeaderEntrySize;         /// Program header size (all the same size)
		ushort   programHeaderCount;             /// Number of program headers

		// Section Header.
		ushort   sectionHeaderEntrySize;         /// Section header size (all the same size)
		ushort   sectionHeaderCount;             /// Number of section headers
		ushort   sectionHeaderStringTable;       /// Section header table index of the entry associated with the section name string table

		// Check the size of the struct.
		static assert(this.sizeof == 52);
	}
	
	static struct ProgramHeader { // ELF Program Header
		enum Type : uint { NO_LOAD = 0, LOAD = 1 }
		Type type;     /// Type of segment
		uint offset;   /// Offset for segment's first byte in file
		uint vaddr;    /// Virtual address for segment
		uint paddr;    /// Physical address for segment
		uint filesz;   /// Segment image size in file
		uint memsz;    /// Segment image size in memory
		uint flags;    /// Flags
		uint _align;   /// Alignment
		
		string toString() {
			return std.string.format("ProgramHeader(type=%02X, offset=%08X, vaddr=%08X, paddr=%08X, filesz=%08X, memsz=%08X, flags=%02X, align=%02X)", type, offset, vaddr, paddr, filesz, memsz, flags, _align);
		}
		
		static assert (this.sizeof == 32);
	}
	/*
	Example:
		ProgramHeader(type=01, offset=00000080, vaddr=00000000, paddr=001752D0, filesz=001A4E38, memsz=001A4E38, flags=07, align=40)
		ProgramHeader(type=01, offset=001A4EC0, vaddr=001A4E40, paddr=00000000, filesz=0014118C, memsz=00D5F75C, flags=06, align=40)
	*/
	
	static struct SectionHeader { // ELF Section Header
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
		
		string toString() {
			// SHeader(type=00000003, f=00, addr=00000000, off=00080C18, size=0003CF, link=00, info=00, aa=01, esize=00, name=03C5)
			return std.string.format(
				"SHeader(type=%08X, f=%03b, addr=%08X, off=%08X, size=%06X, link=%02X, info=%02X, aa=%02X, esize=%02X, name=%04X)",
				type, flags, address, offset, size, link, info, addralign, entsize, name
			);
		}
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
		enum Type : byte {
			None        = 0,
			Mips16      = 1,
			Mips32      = 2,
			MipsRel32   = 3,
			Mips26      = 4,
			MipsHi16    = 5,
			MipsLo16    = 6,
			MipsGpRel16 = 7, 
			MipsLiteral = 8,
			MipsGot16   = 9,
			MipsPc16    = 10,
			MipsCall16  = 11,
			MipsGpRel32 = 12,
		}
		uint offset;
		union {
			uint _info;
			struct {
				Type type;
				ubyte offsetBase;
				ubyte addressBase;
				ubyte _dummy;
				uint symbolIndex() { return _info >> 8; }
			}
		}
		
		uint sindex() { return (_info >> 8); }

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
	uint sectionHeaderTotalSize;
	SectionHeader[] sectionHeaders;
	ProgramHeader[] programHeaders;
	string[] sectionHeaderNames;
	SectionHeader[string] sectionHeadersNamed;
	char[] stringTable;

	void dumpSections() {
		writefln("ProgramHeader(%d):", programHeaders.length);
		foreach (n, programHeader; programHeaders) {
			writefln("  %s", programHeader);
		}

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
	
	Stream ProgramStream(ProgramHeader programHeader) {
		return new SliceStream(stream, programHeader.offset, programHeader.offset + programHeader.filesz);
	}

	bool needsRelocation() { return (header.entryPoint < 0x08000000) || (header.type == Header.Type.Prx); }
	Stream SectionStream(SectionHeader sectionHeader) {
		logTrace("SectionStream(Address=%08X, Offset=%08X, Size=%08X, Type=%08X)", sectionHeader.address, sectionHeader.offset, sectionHeader.size, sectionHeader.type);
		
		return new SliceStream(stream, sectionHeader.offset, sectionHeader.offset + sectionHeader.size);

		/*
		switch (sectionHeader.type) {
			case SectionHeader.Type.PROGBITS:
			case SectionHeader.Type.STRTAB:
				//writefln("sectionHeader.offset:%08X", sectionHeader.offset);
				return new SliceStream(stream, sectionHeader.offset, sectionHeader.offset + sectionHeader.size);
			break;
			default:
				//return new SliceStream(stream, sectionHeader.offset, sectionHeader.offset + sectionHeader.size);
				return new SliceStream(stream, sectionHeader.address, sectionHeader.address + sectionHeader.size);
			break;
		}
		*/
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
		
		logTrace("It's an Elf file processing...");
		
		// Program Headers
		extractProgramHeaders();

		// Section Headers
		extractSectionHeaders();
		extractSectionHeaderNames();
	}
	
	void extractSectionHeaders() {
		logTrace("Extracting SectionHeaders...");
		
		sectionHeaders = []; assert(SectionHeader.sizeof >= header.sectionHeaderEntrySize);
		try {
			//uint offsetLow = 0xFFFFFFFF, offsetHigh = 0;
			uint offsetLow = uint.max, offsetHigh = uint.min;
			foreach (index; 0 .. header.sectionHeaderCount) {
				auto sectionHeader = read!(SectionHeader)(
					stream,
					header.sectionHeaderOffset + (index * header.sectionHeaderEntrySize)
				);
				offsetLow  = min(offsetLow, sectionHeader.offset);
				offsetHigh = max(offsetHigh, sectionHeader.offset + sectionHeader.size);

				sectionHeaders ~= sectionHeader;
				logTrace("  - %d: %s", index, sectionHeader);
			}
			this.sectionHeaderTotalSize = offsetHigh - offsetLow;
		} catch {
		}
	}

	void extractSectionHeaderNames() {
		logTrace("Extracting SectionHeaderNames...");
		
		auto stringTableStream = SectionStream(sectionHeaderStringTable);
		//foreach (sectionHeader; sectionHeaders) writefln("%s", sectionHeader);
		stringTable = cast(char[])stringTableStream.readString(cast(uint)stringTableStream.size);
		sectionHeaderNames = [];
		string szToString(char *str) { return cast(string)str[0..std.c.string.strlen(str)]; }
		foreach (index, sectionHeader; sectionHeaders) {
			auto name = szToString(stringTable.ptr + sectionHeader.name);
			//writefln("---'%08X'", sectionHeader.name);
			sectionHeaderNames ~= name;
			sectionHeadersNamed[name] = sectionHeader;
			logTrace("  - %d: %s", index, name);
		}
	}

	ref SectionHeader sectionHeaderStringTable() {
		//int sectionHeaderIndex = -1;
		foreach (currentSectionHeaderIndex, ref sectionHeader; sectionHeaders) {
			//writefln("sectionHeader.type:%d", sectionHeader.type);
			//writefln("%s", sectionHeader);
			if (sectionHeader.type == SectionHeader.Type.STRTAB) {
				if (sectionHeader.name < sectionHeader.size) {
					return sectionHeader;
				}
				//sectionHeaderIndex = currentSectionHeaderIndex;
				//writefln("--------");
			}
		}
		//if (sectionHeaderIndex != -1) return sectionHeaders[sectionHeaderIndex];
		
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

	void extractProgramHeaders() {
		logTrace("Extracting ProgramHeaders...");
		
		programHeaders = []; assert(SectionHeader.sizeof >= header.sectionHeaderEntrySize);
		try {
			foreach (index; 0 .. header.programHeaderCount) {
				auto programHeader = read!(ProgramHeader)(
					stream,
					header.programHeaderOffset + (index * header.programHeaderEntrySize)
				);
				programHeaders ~= programHeader;
				logTrace("  - %d: %s", index, programHeader);
			}
		} catch {
		}
	}
	
	void relocateFromStream(Stream stream, Stream memoryStream) {
		uint memory_read32(uint position) {
			try {
				memoryStream.position = position;
				return read!(uint)(memoryStream);
			} catch (Throwable o) {
				logError("memory_read32: %s", o);
				throw(new Exception(std.string.format("Error on memory_read32 %08X", position)));
				return -1;
			}
		}

		uint memory_write32(uint position, uint data) {
			try {
				memoryStream.position = position;
				memoryStream.write(data);
				return data;
			} catch (Throwable o) {
				logError("memory_write32: %s", o);
				throw(new Exception(std.string.format("memory_write32: %08X", position)));
				return data;
			}
		}

		uint[][32] regs;
		
		uint RelocCount = cast(uint)stream.size / Reloc.sizeof;
		
		uint AHL = 0; // (AHI << 16) | (ALO & 0xFFFF)
		
		scope uint[] deferredHi16;
		
		bool onceGp = false;
		
		for (int n = 0; n < RelocCount; n++) {
			auto reloc = read!(Reloc)(stream);
			// Filtra las relocalizaciones nulas
			if (reloc.type == Reloc.Type.None) continue;
			
			// Program header offset of the reference we want to relocate. 
			int phOffset     = programHeaders[reloc.offsetBase].vaddr;
			
			// Program header offset of the program header referenced by this relocation.
        	int phBaseOffset = programHeaders[reloc.addressBase].vaddr;

			// Obtiene el offset real a relocalizar 
			uint data_addr = relocationAddress + reloc.offset + phOffset;
			
			int A = 0; // addend
			int S = relocationAddress + phBaseOffset;
			int GP_ADDR = relocationAddress + reloc.offset;
			int GP_OFFSET = GP_ADDR - (relocationAddress & 0xFFFF0000);
			
			long result = 0; // Used to hold the result of relocation, OR this back into data
			
			// Lee la palabra original
			Instruction instruction = Instruction(memory_read32(data_addr));
			
			//writefln("Patching offset: %08X, type:%d", offset, reloc.type);

			uint prev_data = instruction.v;
			
			Elf elf = this;
			
			void logAsJpcsp(T...)(T args) {
				//writefln("TRACE   memory - GUI - %s", std.string.format(args));
				elf.logTrace(args);
			}

			logAsJpcsp("Relocation #%d type=%d,base=%08X,addr=%08X", n, reloc.type, reloc.offsetBase, reloc.addressBase);

			// Modifica la palabra según el tipo de relocalización
			switch (reloc.type) {
				default: throw(new Exception(std.string.format("RELOC: unknown reloc type '%02X'", reloc.type)));
				//case Reloc.Type.MipsNone:
				// LUI
				case Reloc.Type.MipsHi16: { 
					//regs[instruction.RT] ~= offset;
					//instruction.IMMU = instruction.IMMU + (baseAddress >> 16);

					A = instruction.IMMU;
					AHL = A << 16;
					deferredHi16 ~= data_addr;

                    logAsJpcsp(std.string.format("R_MIPS_HI16 addr=%08X", data_addr));
				} break;
				
				// ADDI, ORI ...
				case Reloc.Type.MipsLo16: {
					A = instruction.IMMU;
					AHL &= ~0x0000FFFF; // delete lower bits, since many R_MIPS_LO16 can follow one R_MIPS_HI16
					AHL |= A & 0x0000FFFF;
					result = AHL + S;
					instruction.v &= ~0x0000FFFF;
					instruction.v |= result & 0x0000FFFF; // truncate
					// Process deferred R_MIPS_HI16
					foreach (data_addr2; deferredHi16) {
						int data2 = memory_read32(data_addr2);
						result = ((data2 & 0x0000FFFF) << 16) + A + S;
						// The low order 16 bits are always treated as a signed
						// value. Therefore, a negative value in the low order bits
						// requires an adjustment in the high order bits. We need
						// to make this adjustment in two ways: once for the bits we
						// took from the data, and once for the bits we are putting
						// back in to the data.
						if ((A & 0x8000) != 0) {
						    result -= 0x10000;
						}
						if ((result & 0x8000) != 0) {
						     result += 0x10000;
						}
						data2 &= ~0x0000FFFF;
						data2 |= (result >> 16) & 0x0000FFFF; // truncate
						logAsJpcsp(std.string.format("R_MIPS_HILO16 addr=%08X before=%08X after=%08X", data_addr2, memory_read32(data_addr2), data2));
					    memory_write32(data_addr2, data2);
					}
				    deferredHi16.length = 0;

					logAsJpcsp(std.string.format("R_MIPS_LO16 addr=%08X before=%08X after=%08X", data_addr, prev_data, instruction.v));
				} break;
				
				// J, JAL
				case Reloc.Type.Mips26:
					instruction.JUMP2 = instruction.JUMP2 + S;
					
					logAsJpcsp(std.string.format("R_MIPS_26 addr=%08X before=%08X after=%08X", data_addr, prev_data, instruction.v));
				break;
	
				// *POINTER*
				case Reloc.Type.Mips32:
					//instruction.v = instruction.v + baseAddress;
					instruction.v += S;
					logAsJpcsp(std.string.format("R_MIPS_32 addr=%08X before=%08X after=%08X", data_addr, prev_data, instruction.v));
				break;
				
				case Reloc.Type.MipsGpRel16: {
					/*
					A = instruction.IMMU;
                    if (A == 0) {
                        result = S - GP_ADDR;
                    } else {
                        result = S + GP_OFFSET + (((A & 0x00008000) != 0) ? (((A & 0x00003FFF) + 0x4000) | 0xFFFF0000) : A) - GP_ADDR;
                    }
                    if ((result > 32768) || (result < -32768)) {
						logError("GP_ADDR:%08X, GP_OFFSET:%08X", GP_ADDR, GP_OFFSET);
                        logError("Relocation overflow (R_MIPS_GPREL16) %d", result);
                    }
                    instruction.IMMU = cast(uint)result;
                    */
                    
                    if (!onceGp) {
                    	logWarning("Reloc.Type.MipsGpRel16");
                    	onceGp = true;
                    }
					
					logAsJpcsp(std.string.format("R_MIPS_GPREL16 addr=%08X before=%08X after=%08X", data_addr, prev_data, instruction.v));
				} break;
			} // switch

			//logTrace("%s addr=%08X before=%08X after=%08X", to!string(reloc.type), offset, prev_data, instruction.v);
			//writefln("TRACE   memory - GUI - %s addr=%08X before=%08X after=%08X", to!string(cast(Reloc.Type2)reloc.type), offset, prev_data, instruction.v);
			
			// Escribe la palabra modificada
			memory_write32(data_addr, instruction.v);
			
		} // while
	}

	void relocateFromHeaders(Stream memoryStream) {
		if ((relocationAddress & 0xFFFF) != 0) {
			//throw(new Exception("Relocation base address not aligned to 64K"));
			logWarning("Relocation base address not aligned to 64K");
		}
		
        foreach (programHeader; programHeaders) {
        	// @TODO
        	// ProgramStream();
        	//ProgramStream
        	/*
            if (phdr.getP_type() == 0x700000A0L) {
                int RelCount = (int)phdr.getP_filesz() / Elf32Relocate.sizeof();
                Memory.log.debug("PH#" + i + ": relocating " + RelCount + " entries");

                f.position((int)(elfOffset + phdr.getP_offset()));
                relocateFromBuffer(f, module, baseAddress, elf, RelCount);
                return;
            } else if (phdr.getP_type() == 0x700000A1L) {
                Memory.log.warn("Unimplemented:PH#" + i + ": relocate type 0x700000A1");
            }
            i++;
            */
        }

		foreach (sectionHeader; sectionHeaders) {
			switch (sectionHeader.type) {
				case SectionHeader.Type.PRXRELOC:
					relocateFromStream(SectionStream(sectionHeader), memoryStream);
				break;
				case SectionHeader.Type.REL:
					logWarning("Not relocating SectionHeader.Type.REL");
				break;
				case SectionHeader.Type.PRXRELOC_FW5:
					// http://forums.ps2dev.org/viewtopic.php?p=80416#80416
					throw(new Exception("Not implemented SectionHeader.Type.PRXRELOC2"));
				break;
				default:
				break;
			}
		}
		
		
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
	
	uint relocationAddress;
	
	void allocateMemory(MemoryManager memoryManager) {
		if (needsRelocation) {
			relocationAddress = memoryManager.allocHeap(PspPartition.User, "ModuleMemory", sectionHeaderTotalSize);
		} else {
			relocationAddress = 0;
			foreach (k, sectionHeader; sectionHeaders) {			
				uint sectionHeaderOffset = cast(uint)(relocationAddress + sectionHeader.address);

				// Section to allocate
				if (sectionHeader.flags & SectionHeader.Flags.Allocate) {
					memoryManager.allocAt(PspPartition.User, "ModuleMemory", sectionHeader.size, sectionHeaderOffset);
				}
			}
		}
	}

	void writeToMemory(Stream memoryStream) {
		foreach (k, sectionHeader; sectionHeaders) {			
			uint sectionHeaderOffset = cast(uint)(relocationAddress + sectionHeader.address);
			
			string typeString = "None";
			
			// Section to allocate
			if (sectionHeader.flags & SectionHeader.Flags.Allocate) {
				//Logger.log(Logger.Level.DEBUG, "Loader", "Starting to write to: %08X. SectionHeader: %s", sectionHeaderOffset, sectionHeader);

				bool reserved = true;
				
				memoryStream.position = sectionHeaderOffset;
				switch (sectionHeader.type) {
					default: reserved = false; typeString = "UNKNOWN"; break;
					case SectionHeader.Type.PROGBITS: typeString = "PROGBITS"; memoryStream.copyFrom(SectionStream(sectionHeader)); break;
					case SectionHeader.Type.NOBITS  : typeString = "NOBITS"  ; writeZero(memoryStream, sectionHeader.size); break;
				}
				
				debug (MODULE_LOADER) writefln("%-16s: %08X[%08X] (%s)", typeString, sectionHeaderOffset, sectionHeader.size, sectionHeaderNames[k]);
			}
			// Section not to allocate
			else {
				debug (MODULE_LOADER) writefln("%-16s: %08X[%08X] (%s)", typeString, sectionHeaderOffset, sectionHeader.size, sectionHeaderNames[k]);
			}
		}
		if (needsRelocation) {
			//throw(new Exception("Relocation not implemented yet!"));
			try {
				relocateFromHeaders(memoryStream);
			} catch (Throwable o) {
				writefln("Error relocating: %s", o.toString);
				throw(o);
			}
		}
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
	
	mixin Logger.DebugLogPerComponent!("ElfLoader");
}
