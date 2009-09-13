module kernel.loader.elf;

class ELF {
	enum Type           : ushort { Executable = 0x0002, Prx = 0xFFA0 } // ELF Header Type
	enum PspModuleFlags : ushort { User = 0x0000, Kernel = 0x1000 }
	enum PspLibFlags    : ushort { SysLib = 0x8000, DirectJump = 0x0001, Syscall = 0x4000 }
	
	align(1) struct Header { // ELF Header
		char[4]  magic;     // +00 : [0x7F, 'E', 'L', 'F']
		ubyte    _class;    // +00 : 
		ubyte    data;      // +00 : 
		ubyte    idver;     // +00 : 
		ubyte[9] pad;       // +00 : Padding
		Type     type;      // +00 : Module type
		ushort   machine;   // +00 : MachineId : 0x0008
		uint     ver;       // +00 : Version
		uint     entry;     // +00 : Module EntryPoint
		uint     phoff;     // +00 : Program Header Offset
		uint     shoff;     // +00 : Section Header Offset
		uint     flags;     // +00 : Flags
		ushort   ehsize;    // +00 : 
		ushort   phentsize; // +00 : Program Header ENTry SIZE
		ushort   phnum;     // +00 : Program Header NUMber (count)
		ushort   shentsize; // +00 : Section Header ENTtry SIZE
		ushort   shnum;     // +00 : Section Header Num
		ushort   shstrndx;  // +00 : Section Header STRing iNDeX
		
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

	struct SectionHeader { // ELF Section Header
		enum Flags : uint { None = 0, Write = 1, Allocate = 2, Execute = 4 } // SectionHeader Flags
		enum Type : uint { // SectionHeader Type
			NULL = 0, PROGBITS, SYMTAB, STRTAB, RELA, HASH, DYNAMIC, NOTE, NOBITS, REL, SHLIB, DYNSYM,
			LOPROC = 0x70000000, HIPROC = 0x7FFFFFFF,
			LOUSER = 0x80000000, HIUSER = 0xFFFFFFFF,
			PRXRELOC = (LOPROC | 0xA0),
		}

		align(1) struct BIN {
			uint   name;
			Type   type;
			Flags  flags;
			uint   addr;
			uint   offs, size;
			uint   link;
			uint   info;
			uint   addralign;
			uint   entsize;
		}
		
		char[] name;
		Type   type;
		Flags  flags;
		uint   addr;
		uint   offs, size;
		uint   link;
		uint   info;
		uint   addralign;
		uint   entsize;
		Stream stream;
		BIN    bin;
		
		void setName(Stream shstrtab_s) {
			name = extractStringz(shstrtab_s, bin.name);
		}
		
		static SectionHeader opCall(Stream s) {
			alias bin r.bin;
			SectionHeader r; s.readExact(&bin, bin.sizeof);
			r.name  = "";
			r.type  = bin.type;
			r.flags = bin.flags;
			r.addr  = bin.addr;
			r.offs  = bin.offs;
			r.size  = bin.size;
			r.link  = bin.link;
			r.info  = bin.info;
			r.addralign = bin.info;
			r.entsize = bin.entsize;
			r.stream = new SliceStream(s, bin.offs, bin.offs + bin.size);
			return r;
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
	
	struct PspModuleInfo {
		align(1) struct BIN {
			uint flags;
			char[28] name;
			uint gp;
			uint exports;
			uint exp_end;
			uint imports;
			uint imp_end;
		}
		
		uint flags;
		char[] name;
		uint gp;
		uint exports;
		uint exp_end;
		uint imports;
		uint imp_end;
		uint entry;
		BIN  bin;

		static PspModuleInfo opCall(Stream s) {
			alias bin r.bin;
			PspModuleInfo r; s.readExact(&bin, bin.sizeof);
			r.flags   = bin.flags;
			r.name    = toString(cast(char *)bin.ptr);
			r.gp      = bin.gp;
			r.exports = bin.exports;
			r.exp_end = bin.exp_end;
			r.imports = bin.imports;
			r.imp_end = bin.imp_end;
			return r;
		}
	}
	
	struct Reloc {
		enum Type : byte { None = 0, Mips16, Mips32, MipsRel32, Mips26, MipsHi16, MipsLo16, MipsGpRel16, MipsLiteral, MipsGot16, MipsPc16, MipsCall16, MipsGpRel32 }

		align(1) struct BIN {
			uint offset;
			uint info;
		}
		
		uint offset;
		Type type;
		uint sindex;
		BIN bin;
		
		static Reloc opCall(Stream s) {
			Reloc r; s.readExact(&r.bin, r.bin.sizeof);

			r.offset  = r.bin.offset;
			r.type    = cast(Reloc.Type)((r.bin.info >> 0) & 0xFF);
			r.sindex  = (r.bin.info >> 8) & 0xFFFFFF;
			
			return r;
		}
	}
	
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
	
	Symbol[][uint] symbols;
	Header header;
	Stream elfs;
	Stream shstrtab_s;
	SectionHeader[] sHeaders;
	SectionHeader[char[]] sHeadersNamed;
	uint baseAddress;
	PspModuleInfo ModuleInfo;
	
	bool needsRelocation() { return (header._entry < 0x08000000 || header._type == Type.Prx); }
	
	static char[] extractStringz(Stream s, int position) {
		uint backPosition;
		scope(exit) { s.position = backPosition; }
		backPosition = s.position;
		s.position = position;
		return extractStringz(s);
	}
	
	SectionHeader GetSectionHeader(char[] name) {
		if ((name in sHeaders) is null) throw(new Exception(std.string.format("Section '%s' not found", name)));
		return sHeaders[name];	
	}
	
	static Stream SectionStream(SectionHeader sh) {
		return new SliceStream(i, sh.offs, sh.offs + sh.size);
	}
	
	void PerformRelocation() {
		foreach (sh; sHeaders) {
			// Filtra las secciones que no hay que relocalizar
			if ((sh.type != SectionHeader.Type.REL) && (sh.type != SectionHeader.Type.PRXRELOC)) continue;
			
			// Obtiene el nombre de la secci󮊉			char[] name = extractStringz(shstrtab_s, sh.name);
			uint[][32] regs;
			
			auto s = SectionStream(sh);
			
			while (!s.eof) {
				auto reloc = Reloc(s);
				// Filtra las relocalizaciones nulas
				if (reloc.type == Reloc.Type.None) continue;

				// Obtiene el offset real a relocalizar 
				uint offset = reloc.offset + baseAddress;
				
				// Lee la palabra original
				uint DATA = mem.read4(offset);
				
				// Modifica la palabra según el tipo de relocalización
				switch (reloc.type) { default: throw(new Exception(std.string.format("RELOC: unknown reloc type '%02X'", rtype)));
					// LUI
					case Reloc.Type.MipsHi16: { 
						uint reg = (DATA >> 16) & 0x1F;
						regs[reg] ~= offset;
					} break;
					
					// ADDI, ORI ...
					case Reloc.Type.MipsLo16: {
						uint reg = ((DATA >> 21) & 0x1F);
						uint vlo = ((DATA & 0x0000FFFF) ^ 0x00008000) - 0x00008000;
						
						foreach (hiaddr; regs[reg]) {
							uint DATA2 = mem.read4(hiaddr);

							uint temp = ((DATA2 & 0x0000FFFF) << 16) + vlo + baseAddress;
							
							temp = ((temp >> 16) + (((temp & 0x00008000) != 0) ? 1 : 0)) & 0x0000FFFF;
							DATA2 = (DATA2 & ~0x0000FFFF) | temp;

							mem.write4(hiaddr, DATA2);
						}
						
						regs[reg].length = 0;
						
						DATA = (DATA & ~0x0000FFFF) | ((baseAddress + vlo) & 0x0000FFFF);
					} break;
					
					// J, JAL
					case Reloc.Type.Mips26:
						uint backa = (DATA & 0x03FFFFFF) << 2;
						DATA &= ~0x03FFFFFF;
						DATA |= (baseAddress + backa) >> 2;
					break;		
		
					// *POINTER*
					case Reloc.Type.Mips32:
						DATA = DATA;
					break;
				} // switch
				
				// Escribe la palabra modificada
				mem.write4(offset, DATA);
				
			} // while
			
		} // foreach
	}
	
	void CreateSections() {
		foreach (sh; sHeaders) {			
			try {
				char[] stype = "Unknown Section";
				sh.addr += baseAddress;
				
				// Section to allocate
				if (sh.flags & SectionHeader.Flags.Allocate) {
					bool reserved = true;
					
					switch (sh.type) {
						default:
							reserved = false;
						break;
						case ShType.PROGBITS:	
							stype = "Reserve PROGBITS";
							mem.writed(sh.addr, SectionStream(sh));
						break;
						case ShType.NOBITS:
							stype = "Reserve NOBITS";
							mem.zero(sh.addr, sh.size);
						break;
					}
					
					if (reserved) MemoryManager.Reserve(sh.addr, sh.size);
					
					debug (module_loader) writefln("%-16s: %08X[%08X] (%s)", stype, sh.addr, sh.size, extractStringz(shstrtab_s, sh.name));
				}
				// Section not to allocate
				else {
					debug (module_loader) writefln("%-16s: %08X[%08X] (%s)", stype, sh.offset, sh.size, extractStringz(shstrtab_s, sh.name));
				}
			} catch (Exception e) {
				writefln("Warning: '%s'", e.toString);
			}		
		}	
	}
	
	void ProcessDebug() {
		symbols = null;
		Header symtab, strtab;
		try {
			symtab = GetSectionHeader(".symtab"); auto symtab_s = SectionStream(symtab);
			strtab = GetSectionHeader(".strtab"); auto strtab_s = SectionStream(strtab);
			
			while (!symtab_s.eof) {
				auto symbol = Symbol(symtab_s, strtab_s);
				symbols[symbol.value] ~= symbol;
			}
			
		} catch {
			writefln("No 'symtab' nor 'strtab' found");
		}	
	}

	this(Stream elfs) {
		this.elfs = (elfs = new SliceStream(elfs));
		elfs.readExact(&elfs, elfs.sizeof);
		
		// Comprobamos el ELF
		if (header.magic   != "\x7FELF") throw(new Exception(std.string.format("Not an elf file (%s)" , cast(ubyte[])header.magic)));
		if (header.machine != 0x0008   ) throw(new Exception(std.string.format("Not an psp elf (0x%04X)", header.machine)));
		
		// Determina si el ejecutable tiene que ser relocalizado
		if (needsRelocation) baseAddress = MemoryManager.GetAvailable(0x08900000);
		
		// Section Headers		
		for (int n = 0; n < header.shnum; n++) {
			i.position = header.shoff + (header.shentsize * n);
			SectionHeader sh;
			i.readExact(&sh, sh.sizeof);
			sHeaders ~= sh;
		}
		
		// Find Section Header STRing TABle (.shstrtab)
		shstrtab_s = null;
		foreach (sh; sHeaders) {
			auto s = SectionStream(sh);
			if (extractStringz(s, sh.name) == ".shstrtab") {
				shstrtab_s = s;
				break;
			}
		}
		if (shstrtab_s is null) throw(new Exception("Couldn't find the .shstrtab!"));
		
		// Asociamos los nombres del STRTAB
		foreach (sh; sHeaders) {
			auto name = extractStringz(shstrtab_s, sh._name);
			if (name.length) sHeadersNamed[name] = sh;	
		}
		
		// Reservamos espacio en memoria para las secciones
		CreateSections();
		
		// Relocalizamos el ejecutable
		if (needsRelocation) PerformRelocation();
		
		
		// Obtenemos la info del modulo
		ModuleInfo = PspModuleInfo(SectionStream(GetSectionHeader(".rodata.sceModuleInfo")));
		ModuleInfo.entry = header.entry + baseAddress;
		
		// Exports	
		for (mem.position = moduleInfo.exports; mem.position < moduleInfo.exp_end;) {
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
		
		// Debug
		ProcessDebug();
	}
}