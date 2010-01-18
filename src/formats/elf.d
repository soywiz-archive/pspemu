module pspemu.formats.elf;

import std.stdio, std.stream, std.string;

class ELF {
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
		uint     entry;                          // Module EntryPoint
		uint     programHeaderOffset;            // Program Header Offset
		uint     sectionHeaderOffset;            // Section Header Offset
		uint     flags;                          // Flags
		ushort   ehsize;                         //

		// Program Header.
		ushort   phentsize;                      //
		ushort   phnum;                          //

		// Section Header.
		ushort   shentsize;                      //
		ushort   shnum;                          // Section Header Num
		ushort   shstrndx;                       // 

		static assert(Header.sizeof == 52);
	}
	
	static struct SectionHeader { // ELF Section Header
		static enum Type : uint {
			NULL     = 0,
			PROGBITS = 1,
			SYMTAB   = 2,
			STRTAB   = 3,
			RELA     = 4,
			HASH     = 5,
			DYNAMIC  = 6,
			NOTE     = 7,
			NOBITS   = 8,
			REL      = 9,
			SHLIB    = 10,
			DYNSYM   = 11,

			LOPROC = 0x70000000, HIPROC = 0x7FFFFFFF,
			LOUSER = 0x80000000, HIUSER = 0xFFFFFFFF,

			PRXRELOC = (LOPROC | 0xA0),
		}

		static enum Flags : uint {
			None     = 0,
			Write    = 1,
			Allocate = 2,
			Execute  = 4,
		}

		uint  _name;
		Type  _type;
		Flags _flags;
		uint  _addr;
		uint  _offset;
		uint  _size;
		uint  _link;
		uint  _info;
		uint  _addralign;
		uint  _entsize;

		static assert(SectionHeader.sizeof == 10 * 4);
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

	enum PspModuleFlags : ushort {
		User = 0x0000,
		Kernel = 0x1000,
	}

	enum PspLibFlags : ushort {
		DirectJump = 0x0001,
		Syscall    = 0x4000,
		SysLib     = 0x8000,
	}

	static struct PspModuleExport {
		uint   name;
		ushort _version;
		ushort flags;
		byte   entry_size;
		byte   var_count;
		ushort func_count;
		uint   exports;

		static assert(PspModuleExport.sizeof == 4 + 2 + 2 + 1 + 1 + 2 + 4);
	}

	static struct PspModuleImport {
		uint   name;
		ushort _version;
		ushort flags;
		byte   entry_size;
		byte   var_count;
		ushort func_count;
		uint   nids;
		uint   funcs;
	}
	
	static struct PspModuleInfo {
		uint flags;

		char[28] name;

		uint gp;
		uint exports;
		uint exp_end;
		uint imports;
		uint imp_end;
	}
	
	static struct Reloc {
		enum Type : byte { None = 0, Mips16, Mips32, MipsRel32, Mips26, MipsHi16, MipsLo16, MipsGpRel16, MipsLiteral, MipsGot16, MipsPc16, MipsCall16, MipsGpRel32 }
		uint _offset;
		uint _info;

		// Check size.
		static assert(Reloc.sizeof == 8);
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
		
		/*
		static Symbol opCall(Stream symbol_s, Stream string_s) {
			Symbol symbol;
			symbol.name  = extractStringz(string_s, read4(symbol_s));
			symbol.value = read4(symbol_s);
			symbol.size  = read4(symbol_s);
			ubyte info   = read1(symbol_s);
			symbol.type  = cast(Type)((info >> 0) & 0xF);
			symbol.bind  = cast(Bind)((info >> 4) & 0xF);
			symbol.other = read1(symbol_s);
			symbol.index = read2(symbol_s);
			return symbol;
		}
		*/
	}
	
	struct LoaderResult {
		uint EntryAddress;
		uint GlobalPointer;
		char[] Name;
		
		/*
		void dump() {
			writefln("LoaderResult {");
			writefln("  EntryAddress : %08X", EntryAddress);
			writefln("  GlobalPointer: %08X", GlobalPointer);
			writefln("  ModuleName:    %s"  , Name);
			writefln("}");
		}
		*/
	}

	Stream stream;
	Header header;

	bool needsRelocation() { return (header.entry < 0x08000000) || (header.type == Header.Type.Prx); }
	
	this(Stream _stream) {
		stream = new SliceStream(_stream, 0);

		// Reader header.
		stream.readExact(&header, header.sizeof);

		// Comprueba que sea un ELF y que sea de PSP
		assert(header.magic   == Header.init.magic  );
		assert(header.machine == Header.init.machine);
	}
}

unittest {
	writefln("Unittesting: formats.elf...");

	const testPath = "demos";
	scope elf = new ELF(new BufferedFile(testPath ~ "/controller.elf", FileMode.In));

	//static void main() { }
}