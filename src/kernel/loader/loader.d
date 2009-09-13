module kernel.loader.loader;

import kernel.loader.pbp;
import kernel.loader.elf;
import kernel.common;

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

class ModuleLoader {	
	
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
		
		// Comprobamos si es un pbp
		try {
			auto pbp = new PBP(i);
			return _LoadModule(bios, pbp.streams[PBP.Files.psp_data]);
		}
		// No es un pbp
		catch {
			return _LoadModule(bios, i);
		}
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
			if ((name in shdrs_n) is null) throw(new Exception(std.string.format("Section '%s' not found", name)));
			return shdrs_n[name];
		}
		
		Stream GetSectionStream(Elf32_Shdr shdr) {
			return new SliceStream(i, shdr._offset, shdr._offset + shdr._size);		
		}
		
		// Reseteamos el estado de la bios
		bios.reset();
	
		
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
		
		result.dump();
		

		
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