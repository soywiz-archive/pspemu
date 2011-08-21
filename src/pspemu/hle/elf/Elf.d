module pspemu.hle.elf.Elf;

public import pspemu.hle.elf.ElfHeader;
public import pspemu.hle.elf.ElfProgramHeader;
public import pspemu.hle.elf.ElfSectionHeader;

//import pspemu.All;

//import pspemu.core.cpu.Instruction;

import pspemu.utils.StructUtils;
import pspemu.utils.StreamUtils;
import pspemu.utils.MathUtils;
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
	
	/*
	enum ModuleNids : uint {
		MODULE_INFO                   = 0xF01D73A7,
		MODULE_BOOTSTART              = 0xD3744BE0,
		MODULE_REBOOT_BEFORE          = 0x2F064FA6,
		MODULE_START                  = 0xD632ACDB,
		MODULE_START_THREAD_PARAMETER = 0x0F7C276C,
		MODULE_STOP                   = 0xCEE8593C,
		MODULE_STOP_THREAD_PARAMETER  = 0xCF0CC697,
	}
	*/
	
	/*
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
	*/
	
	/*
	struct LoaderResult {
		uint EntryAddress;
		uint GlobalPointer;
		char[] Name;
	}
	*/

	Stream stream;
	ElfHeader elfHeader;
	ElfSectionHeader[] sectionHeaders;
	ElfProgramHeader[] programHeaders;
	ElfSectionHeader[string] sectionHeadersNamed;
	string[] sectionHeaderNames;
	uint sectionHeaderTotalSize;
	char[] stringTable;
	
	public this() {
		
	}

	public this(Stream _stream) {
		load(_stream);
	}
	
	public void load(Stream _stream) {
		stream = new SliceStream(_stream, 0);

		// Reader header.
		stream.readExact(&elfHeader, elfHeader.sizeof);

		// Checks that it's an ELF file and that it's a PSP ELF file.
		if (elfHeader.magic   != ElfHeader.init.magic  ) throw(new Exception(std.string.format("Magic '%s' != '%s'", elfHeader.magic, ElfHeader.init.magic)));
		if (elfHeader.machine != ElfHeader.init.machine) throw(new Exception(std.string.format("Machine %d != %d", elfHeader.machine, ElfHeader.init.machine)));
		
		logTrace("It's an Elf file processing...");
		// Program Headers
		extractProgramHeaders();

		// Section Headers
		extractSectionHeaders();
		extractSectionHeaderNames();
	} 
	
	void dumpSections() {
		writefln("ElfProgramHeader(%d):", programHeaders.length);
		foreach (n, elfProgramHeader; programHeaders) {
			writefln("  %s", elfProgramHeader);
		}

		writefln("ElfSectionHeader(%d):", sectionHeaders.length);
		foreach (n, sectionHeader; sectionHeaders) {
			writefln(
				"  ElfSectionHeader(type=%08X, flags=%08X, mem=0x%08X, file=0x%06X, size=0x%05X) : '%s'",
				sectionHeader.type,
				sectionHeader.flags,
				sectionHeader.address,
				sectionHeader.offset,
				sectionHeader.size,
				sectionHeaderNames[n]
			);
		}
	}
	
	Stream ProgramStream(ElfProgramHeader elfProgramHeader) {
		return new SliceStream(stream, elfProgramHeader.offsetOnFile, elfProgramHeader.offsetOnFile + elfProgramHeader.sizeOnFile);
	}

	@property bool needsRelocation() {
		return (elfHeader.entryPoint < 0x08000000) || (elfHeader.type == ElfHeader.Type.Prx);
	}

	Stream SectionStream(ElfSectionHeader sectionHeader) {
		logTrace("SectionStream(Address=%08X, Offset=%08X, Size=%08X, Type=%08X)", sectionHeader.address, sectionHeader.offset, sectionHeader.size, sectionHeader.type);
		
		switch (sectionHeader.type) {
			case ElfSectionHeader.Type.PROGBITS, ElfSectionHeader.Type.STRTAB:
			{
				return new SliceStream(stream, sectionHeader.offset, sectionHeader.offset + sectionHeader.size);
			}
			default:
			{
				return new SliceStream(stream, sectionHeader.address, sectionHeader.address + sectionHeader.size);
			}
		}
	}

	Stream SectionStream(string name) {
		if (name !in sectionHeadersNamed) throw(new Exception(std.string.format("ElfSectionHeader('%s') not found.", name)));
		return SectionStream(sectionHeadersNamed[name]);
	}
	
	void extractSectionHeaders() {
		logTrace("Extracting SectionHeaders...");
		
		sectionHeaders = []; assert(ElfSectionHeader.sizeof >= elfHeader.sectionHeaderEntrySize);
		try {
			//uint offsetLow = 0xFFFFFFFF, offsetHigh = 0;
			uint offsetLow = uint.max, offsetHigh = uint.min;
			foreach (index; 0 .. elfHeader.sectionHeaderCount) {
				auto sectionHeader = read!(ElfSectionHeader)(
					stream,
					elfHeader.sectionHeaderOffset + (index * elfHeader.sectionHeaderEntrySize)
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

	ref ElfSectionHeader sectionHeaderStringTable() {
		//int sectionHeaderIndex = -1;
		foreach (currentSectionHeaderIndex, ref sectionHeader; sectionHeaders) {
			//writefln("sectionHeader.type:%d", sectionHeader.type);
			//writefln("%s", sectionHeader);
			if (sectionHeader.type == ElfSectionHeader.Type.STRTAB) {
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
		
		programHeaders = []; assert(ElfSectionHeader.sizeof >= elfHeader.sectionHeaderEntrySize);
		try {
			foreach (index; 0 .. elfHeader.programHeaderCount) {
				auto elfProgramHeader = read!(ElfProgramHeader)(
					stream,
					elfHeader.programHeaderOffset + (index * elfHeader.programHeaderEntrySize)
				);
				programHeaders ~= elfProgramHeader;
				logTrace("  - %d: %s", index, elfProgramHeader);
			}
		} catch {
		}
	}
	
	ElfSectionHeader[] relocationSectionHeaders() {
		ElfSectionHeader[] list;
		foreach (sectionHeader; sectionHeaders) {
			if ((sectionHeader.type == ElfSectionHeader.Type.PRXRELOC) || (sectionHeader.type == ElfSectionHeader.Type.REL)) {
				list ~= sectionHeader;
			}
		}
		return list;
	}
	
	mixin Logger.DebugLogPerComponent!("Elf");
}
