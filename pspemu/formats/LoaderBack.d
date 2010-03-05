module pspemu.formats.loader;

import std.stream;
import std.stdio;
import std.c.string;
import std.c.time;
import std.random;

import psp.memory;
import psp.bios;
import psp.cpu;
import psp.disassembler.cpu;

import expression;

debug = module_loader;
debug = module_loader_imports;

ubyte read1(Stream s) { ubyte v; s.read(v); return v; }
ushort read2(Stream s) { ushort v; s.read(v); return v; }
uint read4(Stream s) { uint v; s.read(v); return v; }

class ModuleLoader {	
	align(1) struct PBP_Header {
		ubyte[4] pmagic = x"PBP\0";
		uint pversion = 0x10000;
		uint offset_param_sfo;
		uint offset_icon0_png;
		uint offset_icon1_pmf;
		uint offset_pic0_png;
		uint offset_pic1_png;
		uint offset_snd0_at3;
		uint offset_psp_data;
		uint offset_psar_data;
	}	
	
	enum ElfType : ushort { Executable = 0x0002, Prx = 0xFFA0 } // ELF Header Type
	
	align(1) struct Elf32_Ehdr { // ELF Header
		ubyte[4] _magic = [0x7F, 'E', 'L', 'F'];
		ubyte    _class;     //
		ubyte    _data;      //
		ubyte    _idver;     //
		ubyte[9] _pad;       //
		ElfType  _type;      // Module type
		ushort   _machine = 0x0008;
		uint     _version;   //
		uint     _entry;     // Module EntryPoint
		uint     _phoff;     // Program Header Offset
		uint     _shoff;     // Section Header Offset
		uint     _flags;     // Flags
		ushort   _ehsize;    //
		ushort   _phentsize; //
		ushort   _phnum;     //
		ushort   _shentsize; //
		ushort   _shnum;     // Section Header Num
		ushort   _shstrndx;
		
		void dump() {
			char[][] keys = ["magic", "class", "data", "idver", "pad", "type", "machine", "version", "entry", "phoff", "shoff", "flags", "ehsize", "phentsize", "phnum", "shentsize", "shnum", "shstrndx"];
			writefln("Elf32_Ehdr {");
			foreach (k, v; this.tupleof) {
				writef("  %-10s: ", keys[k]);
				static if (is(typeof(v) == uint)) writefln("%08X", v);
				else if (is(typeof(v) == ushort)) writefln("%04X", v);
				else if (is(typeof(v) == ubyte)) writefln("%02X", v);
				else writefln("%s", v);
			}
			writefln("}");
		}
	}
	
	enum ShType : uint { // SectionHeader Type
		NULL = 0,
		PROGBITS = 1,
		SYMTAB = 2,
		STRTAB = 3,
		RELA = 4,
		HASH = 5,
		DYNAMIC = 6,
		NOTE = 7,
		NOBITS = 8,
		REL = 9,
		SHLIB = 10,
		DYNSYM = 11,

		LOPROC = 0x70000000, HIPROC = 0x7FFFFFFF,
		LOUSER = 0x80000000, HIUSER = 0xFFFFFFFF,

		PRXRELOC = (LOPROC | 0xA0),
	}	
	
	enum ShFlags : uint { None = 0, Write = 1, Allocate = 2, Execute = 4 } // SectionHeader Flags
	
	align(1) struct Elf32_Shdr { // ELF Section Header
		uint    _name;
		ShType  _type;
		ShFlags _flags;
		uint    _addr;
		uint    _offset;
		uint    _size;
		uint    _link;
		uint    _info;
		uint    _addralign;
		uint    _entsize;
		
		void dump() {
			char[][] keys = ["name", "type", "flags", "addr", "offset", "size", "link", "info", "addralign", "entsize"];
			writefln("Elf32_Shdr {");
			foreach (k, v; this.tupleof) {
				writef("  %-10s: ", keys[k]);
				static if (is(typeof(v) == uint)) writefln("%08X", v);
				else if (is(typeof(v) == ushort)) writefln("%04X", v);
				else if (is(typeof(v) == ubyte)) writefln("%02X", v);
				else writefln("%s", v);
			}	
			writefln("}");
		}		
	}
	
	enum ModuleNids : uint {
		MODULE_INFO = 0xF01D73A7,
		MODULE_BOOTSTART = 0xD3744BE0,
		MODULE_REBOOT_BEFORE = 0x2F064FA6,
		MODULE_START = 0xD632ACDB,
		MODULE_START_THREAD_PARAMETER = 0x0F7C276C,
		MODULE_STOP = 0xCEE8593C,
		MODULE_STOP_THREAD_PARAMETER = 0xCF0CC697,
	}

	enum PspModuleFlags : ushort {
		User = 0x0000,
		Kernel = 0x1000,
	}

	enum PspLibFlags : ushort {
		SysLib = 0x8000,
		DirectJump = 0x0001,
		Syscall = 0x4000,
	}

	align(1) struct PspModuleExport {
		uint   name;
		ushort _version;
		ushort flags;
		byte   entry_size;
		byte   var_count;
		ushort func_count;
		uint   exports;
	}

	align(1) struct PspModuleImport {
		uint   name;
		ushort _version;
		ushort flags;
		byte   entry_size;
		byte   var_count;
		ushort func_count;
		uint   nids;
		uint   funcs;
	}
	
	align(1) struct PspModuleInfo {
		uint flags;

		char[28] name;

		uint gp;
		uint exports;
		uint exp_end;
		uint imports;
		uint imp_end;
	}
	
	align(1) struct Reloc {
		enum Type : byte { None = 0, Mips16, Mips32, MipsRel32, Mips26, MipsHi16, MipsLo16, MipsGpRel16, MipsLiteral, MipsGot16, MipsPc16, MipsCall16, MipsGpRel32 }
		
		uint _offset;
		uint _info;
	}
	
	static Symbol[][uint] symbols;
	
	struct Symbol {
		enum Type : ubyte { NoType = 0, Object = 1, Function = 2, Section = 3, File = 4, LoProc = 13, HiProc = 15 }
		enum Bind : ubyte { Local = 0, Global = 1, Weak = 2, LoProc = 13, HiProc = 15 }

		char[] name;
		uint   value;
		uint   size;
		Type   type;
		Bind   bind;
		ubyte  other;
		ushort index;
		
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
	}
	
	struct LoaderResult {
		uint EntryAddress;
		uint GlobalPointer;
		char[] Name;
		
		void dump() {
			writefln("LoaderResult {");
			writefln("  EntryAddress : %08X", EntryAddress);
			writefln("  GlobalPointer: %08X", GlobalPointer);
			writefln("  ModuleName:    %s"  , Name);
			writefln("}");
		}
	}
	
	static char[] _appPath;
	
	static char[] appPath() {
		return _appPath;
	}

	static char[] appPath(char[] s) {
		writefln("appPath: %s", s);
		return _appPath = s;
	}
	
	static LoaderResult LoadModule(BIOS bios, Stream i) {
		PBP_Header header_i, header = void;
		i.read(TA(header));
		
		// Parece un PBP
		if (header.pmagic == header_i.pmagic) {
			// Obtenemos el stream del elf
			i = new SliceStream(i, header.offset_psp_data);
		}
		// No es un pbp
		else {
			i.position = 0;
		}
				
		return _LoadModule(bios, i);
	}
	
	static char[] extractStringz(Stream s, int position) {
		uint backPosition;
		scope(exit) { s.position = backPosition; }
		backPosition = s.position;
		s.position = position;
		return extractStringz(s);
	}
	
	static char[] extractStringz(Stream s) {
		char[] r;
		while (!s.eof) {
			char c; s.read(c);
			if (c == 0) break;
			r ~= c;
		}
		return r;
	}
	
	static LoaderResult _LoadModule(BIOS bios, Stream i) {
		Memory mem = cpu.mem;
		Elf32_Shdr[] shdrs;
		Elf32_Shdr[char[]] shdrs_n;
		Stream shstrtab_s;		
		LoaderResult result;
		uint baseAddress = 0;
		
		Elf32_Ehdr header_i, header = void;
		i.read(TA(header));
		
		debug (module_loader) header.dump();
		
		Elf32_Shdr GetModuleInfoHeader(char[] name) {
			try {
				return shdrs_n[name];
			} catch {
				throw(new Exception(std.string.format("Section '%s' not found", name)));
			}
		}
		
		Stream GetSectionStream(Elf32_Shdr shdr) {
			return new SliceStream(i, shdr._offset, shdr._offset + shdr._size);		
		}
		
		// Comprueba que sea un ELF y que sea de PSP
		if (header_i._magic   != header._magic  ) throw(new Exception(std.string.format("Not an elf file (%s)" , header._magic  )));
		if (header_i._machine != header._machine) throw(new Exception(std.string.format("Not an psp elf (%04X)", header._machine)));
		
		// Reseteamos el estado de la bios
		bios.reset();
		
		// Determina si el ejecutable tiene que ser relocalizado
		bool needsRelocation = header._entry < 0x08000000 || header._type == ElfType.Prx;
		uint defaultLoad = 0x08900000;
		
		if (needsRelocation) baseAddress = 0x08900000;

		// Section Header STRing TABle
		Stream GetShStrTab() {
            foreach (shdr; shdrs) {
                Stream sheader_stream = GetSectionStream(shdr);
                if (extractStringz(sheader_stream, shdr._name) == ".shstrtab") return sheader_stream;
            }
            
            throw(new Exception("Couldn't find the .shstrtab!"));
        }

		// Section Headers		
		for (int n = 0; n < header._shnum; n++) {
			i.position = header._shoff + (header._shentsize * n);
			Elf32_Shdr shdr = void; i.read(TA(shdr)); shdrs ~= shdr;
			
			// Obtiene los nombres de los headers
			//if (shdr._type == ShType.STRTAB) shstrtab_s = new SliceStream(i, shdr._offset, shdr._offset + shdr._size);
		}
		
		shstrtab_s = GetShStrTab();
		
		// Asociamos los nombres del STRTAB
		foreach (shdr; shdrs) {
			char[] name = extractStringz(shstrtab_s, shdr._name);
			if (!name.length) continue;
			shdrs_n[name] = shdr;	
		}
		
		// Reservamso espacio en memoria para las secciones
		foreach (shdr; shdrs) {			
			try {
				char[] stype = "Unknown Section";
				shdr._addr += baseAddress;
				if (shdr._flags & ShFlags.Allocate) {
					bool reserved = true;
					switch (shdr._type) {
						case ShType.PROGBITS:	
							stype = "Reserve PROGBITS";
							mem.writed(shdr._addr, GetSectionStream(shdr));
						break;
						case ShType.NOBITS:
							stype = "Reserve NOBITS";
							mem.zero(shdr._addr, shdr._size);
						break;
						default: reserved = false; break;
					}
					
					if (reserved) {
						bios.mman.use(shdr._addr, shdr._size);
					}
					
					debug (module_loader) writefln("%-16s: %08X[%08X] (%s)", stype, shdr._addr, shdr._size, extractStringz(shstrtab_s, shdr._name));
				} else {
					//stype = "Other";
					//debug (module_loader) writefln("%-16s: %08X[%08X] (%s)", stype, shdr._addr, shdr._size, extractStringz(shstrtab_s, shdr._name));
					writefln("%-16s: %08X[%08X] (%s)", stype, shdr._offset, shdr._size, extractStringz(shstrtab_s, shdr._name));
				}
			} catch (Exception e) {
				writefln("Warning: %s", e.toString);
			}		
		}		

		// Relocalizamos el ejecutable
		if (needsRelocation == true) {
			// TODO
			writefln("needsRelocation!!!");
			//Elf32_Shdr relocHeader = GetModuleInfoHeader(".symtab");
			foreach (shdr; shdrs) {	
				if ((shdr._type != ShType.REL) && (shdr._type != ShType.PRXRELOC)) continue;
				char[] name = extractStringz(shstrtab_s, shdr._name);
				
				uint count = shdr._size / Reloc.sizeof;
				
				Stream rel_s = GetSectionStream(shdr);
				
				uint[][32] regs;
				
				while (!rel_s.eof) {
					Reloc reloc;
					rel_s.read(TA(reloc));

					Reloc.Type rtype = cast(Reloc.Type)(reloc._info & 0xFF);
					uint symbolIndex = (reloc._info >> 8);
					uint basea = baseAddress;
					uint offset = reloc._offset + baseAddress;
					
					if (rtype == Reloc.Type.None) continue;
					
					uint DATA = mem.read4(offset);
					
					switch (rtype) {
						case Reloc.Type.MipsHi16: { // LUI
							uint reg = (DATA >> 16) & 0x1F;
							regs[reg] ~= offset;
						} break;
						case Reloc.Type.MipsLo16: { // ADDI, ORI ...
							uint reg = (DATA >> 21) & 0x1F;
							uint vallo = ((DATA & 0x0000FFFF) ^ 0x00008000) - 0x00008000;
							
							foreach (hiaddr; regs[reg]) {
								uint DATA2 = mem.read4(hiaddr);

								uint temp = ((DATA2 & 0x0000FFFF) << 16) + vallo + basea;
								
								temp = ((temp >> 16) + (((temp & 0x00008000) != 0) ? 1 : 0)) & 0x0000FFFF;
								DATA2 = (DATA2 & ~0x0000FFFF) | temp;

								mem.write4(hiaddr, DATA2);
							}
							
							regs[reg].length = 0;
							
							DATA = (DATA & ~0x0000FFFF) | ((basea + vallo) & 0x0000FFFF);
						} break;
						case Reloc.Type.Mips26: // J
							uint backa = (DATA & 0x03FFFFFF) << 2;
							DATA &= ~0x03FFFFFF;
							DATA |= (basea + backa) >> 2;
						break;						
						case Reloc.Type.Mips32: // *POINTER*							
							DATA = DATA;
						break;
						default:
							throw(new Exception(std.string.format("RELOC: unknown reloc type '%02X'", rtype)));
						break;
					}
					
					mem.write4(offset, DATA);
					
					//writefln("%08X", reloc._offset);
				}
			}
		}
		
		// Obtenemos la info del modulo
		Elf32_Shdr moduleInfoShdr = GetModuleInfoHeader(".rodata.sceModuleInfo");
		
		PspModuleInfo moduleInfo = void;
		i.position = moduleInfoShdr._offset;
		i.read(TA(moduleInfo));
		result.GlobalPointer = moduleInfo.gp;
		result.Name = std.string.toString(cast(char *)moduleInfo.name.ptr);

		// Exports	
		mem.position = moduleInfo.exports;
		while (mem.position < moduleInfo.exp_end) {
			char[] name;
			PspModuleExport ex;
			mem.read(TA(ex));
			
			if (ex.name) name = extractStringz(mem, ex.name);

			debug (module_loader) writefln("ModuleExport: %08X FUNCS: %08X", ex.name, ex.exports);

			Stream f_s = new SliceStream(mem, baseAddress + ex.exports + (ex.func_count + ex.var_count) * 4);
			Stream n_s = new SliceStream(mem, baseAddress + ex.exports);
			
			uint func_rest = ex.func_count;

			while (func_rest--) {
				uint uid, func;
				n_s.read(uid);	
				f_s.read(func);
				writefln("  %08X : %08X", uid, func);
			}
		}

		// Imports	
		mem.position = baseAddress + moduleInfo.imports;
		while (mem.position < baseAddress + moduleInfo.imp_end) {
			char[] name;
			PspModuleImport im;
			mem.read(TA(im));
			
			if (im.name) name = extractStringz(mem, baseAddress + im.name);
			
			debug (module_loader_imports) writefln("ModuleImport: [%08X] F:%2d, V:%2d (%s)", im.name, im.func_count, im.var_count, name);
			
			Stream f_s = new SliceStream(mem, baseAddress + im.funcs);
			Stream n_s = new SliceStream(mem, baseAddress + im.nids);
			
			uint func_rest = im.func_count;

			void func_break(uint id) {
				// break XXX
				// jr ra
				f_s.write(cast(uint)(0b_001101 | ((id & 0xFFFFF) << 6)));
				f_s.write(cast(uint)(0x03E00008)); // JR RA
			}
			
			void func_syscall(uint id) {
				// syscall XXX
				// jr ra
				f_s.write(cast(uint)(0b_001100 | ((id & 0xFFFFF) << 6)));
				f_s.write(cast(uint)(0x03E00008)); // JR RA
			}
			
			void func_jump(uint addr) {
				// j {target}
				// nop
				f_s.write(cast(uint)((0b_000010 << 26) | ((addr >> 2) & 0x03FFFFFF)));
				f_s.write(cast(uint)0x00000000); // NOP				
			}
			
			debug (module_loader_imports) writefln("{");
			while (func_rest--) {
				uint nid;
				n_s.read(nid);

				//writefln("  %08X", nid);
				
				uint caddr = f_s.position + im.funcs + baseAddress;
				
				char[] impName = getImportName(caddr, name, nid);
				
				debug (module_loader_imports) writefln("  %08X: %s", nid, impName);
				
				mem.setComment(caddr, std.string.format("%s :: %s (%08X)", name, impName, nid));
				
				bios.setImpNative(caddr, name, nid, impName);
				
				func_jump(0);
				//func_syscall(0);
				//func_break(0);
			}
			debug (module_loader_imports) writefln("}");
		}
		
		result.EntryAddress = header._entry + baseAddress;
		
		result.dump();
		
		symbols = null;
		Elf32_Shdr symtab, strtab;
		try {
			symtab = GetModuleInfoHeader(".symtab"); Stream symtab_s = GetSectionStream(symtab);
			strtab = GetModuleInfoHeader(".strtab"); Stream strtab_s = GetSectionStream(strtab);
			
			while (!symtab_s.eof) {
				auto symbol = Symbol(symtab_s, strtab_s);
				symbols[symbol.value] ~= symbol;
			}
			
		} catch {
			writefln("No 'symtab' nor 'strtab' found");
		}
		
		writefln("-------------------------------------------------------------------------------");
		
		
		cpu.mem.write4(0x08000000, 0x7000003F); // dbreak
		cpu.mem.write4(0x08000004, cast(uint)(0b_001100 | ((0x00002 & 0xFFFFF) << 6))); // syscall
		cpu.mem.write4(0x08000008, cast(uint)((0b_000010 << 26) | ((0x08000008 >> 2) & 0x03FFFFFF))); // j self
		cpu.mem.write4(0x0800000C, cast(uint)(0b_001100 | ((0x00000 & 0xFFFFF) << 6))); // syscall 0
		//cpu.mem.write4(0x08000010, cast(uint)(0x00000000)); // nop
		
		return result;
	}	
	
	static char[][uint][char[]] librariesInfo;
	
	static void loadLibraryInfo(Stream stream) {
		char[] _module = "unknown";
		
		while (!stream.eof) {
			char[] l = stream.readLine;
			char[] rl = std.string.strip(l);
			
			if (l.length >= 2 && l[0..2] == "  ") {
				char[][] toks = std.string.split(rl, ",");
				librariesInfo[_module.dup][Expression.number(std.string.strip(toks[0]))] = std.string.strip(toks[1]).dup;
			}
			else if (rl.length) {
				_module = rl;
			}			
		}
	}

	static char[] getImportName(uint addr, char[] name, uint nid) {
		if (name in librariesInfo) {
			if (nid in librariesInfo[name]) {
				return librariesInfo[name][nid];
			}
		}
		return std.string.format("%s_%08X", name, nid);
	}	
}
