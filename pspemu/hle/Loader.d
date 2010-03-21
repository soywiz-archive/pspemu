module pspemu.hle.Loader;

//version = DEBUG_LOADER;

import std.stream, std.stdio, std.string;

import pspemu.utils.Utils;

import pspemu.formats.Elf;
import pspemu.formats.ElfDwarf;
import pspemu.formats.Pbp;

import pspemu.hle.Module;

import pspemu.core.Memory;
import pspemu.core.cpu.Assembler;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.InstructionCounter;

import pspemu.models.IDebugSource;

import std.xml;

version (unittest) {
	import pspemu.utils.SparseMemory;
}

class Loader : IDebugSource {
	enum ModuleFlags : ushort {
		User   = 0x0000,
		Kernel = 0x1000,
	}

	enum LibFlags : ushort {
		DirectJump = 0x0001,
		Syscall    = 0x4000,
		SysLib     = 0x8000,
	}

	static struct ModuleExport {
		uint   name;         /// Address to a stringz with the module.
		ushort _version;     ///
		ushort flags;        ///
		byte   entry_size;   ///
		byte   var_count;    ///
		ushort func_count;   ///
		uint   exports;      ///

		// Check the size of the struct.
		static assert(this.sizeof == 16);
	}

	static struct ModuleImport {
		uint   name;           /// Address to a stringz with the module.
		ushort _version;       /// Version of the module?
		ushort flags;          /// Flags for the module.
		byte   entry_size;     /// ???
		byte   var_count;      /// 
		ushort func_count;     /// 
		uint   nidAddress;     /// Address to the nid pointer. (Read)
		uint   callAddress;    /// Address to the function table. (Write 16 bits. jump/syscall)

		// Check the size of the struct.
		static assert(this.sizeof == 20);
	}
	
	static struct ModuleInfo {
		uint flags;     ///
		char[28] name;      /// Name of the module.
		uint gp;            /// Global Pointer initial value.
		uint exportsStart;  ///
		uint exportsEnd;    ///
		uint importsStart;  ///
		uint importsEnd;    ///

		// Check the size of the struct.
		static assert(this.sizeof == 52);
	}

	Elf elf;
	ElfDwarf dwarf;
	Stream memory;
	ModuleInfo moduleInfo;
	ModuleImport[] moduleImports;
	ModuleExport[] moduleExports;
	
	uint PC() { return elf.header.entryPoint; }
	uint GP() { return moduleInfo.gp; }

	this(string file, Stream memory) {
		this(new BufferedFile(file, FileMode.In), memory);
	}

	this(Stream stream, Stream memory) {
		while (true) {
			auto magics = new SliceStream(stream, 0, 4);
			switch (magics.readString(4)) {
				case "\x7FELF":
				break;
				case "~PSP":
					assert(0, "Not support compressed elf files");
				break;
				case "\0PBP":
					stream = (new Pbp(stream))["psp.data"];
					continue;
				break;
				default:
					assert(0, "Unknown file");
				break;
			}
			break;
		}

		this.elf    = new Elf(stream);
		this.memory = memory;
		version (DEBUG_LOADER) {
			elf.dumpSections();
		}
		try {
			load();
		} catch (Object o) {
			writefln("Loader.load Exception: %s", o);
			throw(o);
		}
		version (DEBUG_LOADER) {
			count();
			Module.dumpKnownModules();
		}
		checkDebug();
		//(new std.stream.File("debug_str", FileMode.OutNew)).copyFrom(elf.SectionStream(".debug_str"));
	}
	
	void checkDebug() {
		try {
			dwarf = new ElfDwarf;
			dwarf.parseDebugLine(elf.SectionStream(".debug_line"));
			dwarf.find(0x089004C8);
		} catch (Object o) {
			writefln("Can't find debug information: '%s'", o.toString);
		}
	}

	bool lookupDebugSourceLine(ref DebugSourceLine debugSourceLine, uint address) {
		if (dwarf is null) return false;
		auto state = dwarf.find(address);
		if (state is null) return false;
		debugSourceLine.file    = state.file_full_path;
		debugSourceLine.address = state.address;
		debugSourceLine.line    = state.line;
		return true;
	}

	bool lookupDebugSymbol(ref DebugSymbol debugSymbol, uint address) {
		return false;
	}

	void count() {
		try {
			auto counter = new InstructionCounter;
			counter.count(elf.SectionStream(".text"));
			counter.dump();
		} catch (Object o) {
			writefln("Can't count instructions: '%s'", o.toString);
		}
	}

	void load() {
		this.elf.writeToMemory(memory);
		readInplace(moduleInfo, elf.SectionStream(".rodata.sceModuleInfo"));
		
		auto importsStream = new SliceStream(memory, moduleInfo.importsStart, moduleInfo.importsEnd);
		auto exportsStream = new SliceStream(memory, moduleInfo.exportsStart, moduleInfo.exportsEnd);
		
		// Load Imports.
		version (DEBUG_LOADER) writefln("Imports (0x%08X-0x%08X):", moduleInfo.importsStart, moduleInfo.importsEnd);
		auto assembler = new AllegrexAssembler(memory);
		while (!importsStream.eof) {
			auto moduleImport = read!(ModuleImport)(importsStream);
			auto moduleImportName = moduleImport.name ? readStringz(memory, moduleImport.name) : "<null>";
			//assert(moduleImport.entry_size == moduleImport.sizeof);
			version (DEBUG_LOADER) writefln("  '%s'", moduleImportName);
			moduleImports ~= moduleImport;
			auto nidStream  = new SliceStream(memory, moduleImport.nidAddress , moduleImport.nidAddress  + moduleImport.func_count * 4);
			auto callStream = new SliceStream(memory, moduleImport.callAddress, moduleImport.callAddress + moduleImport.func_count * 8);
			//writefln("%08X", moduleImport.callAddress);
			auto pspModule = Module.loadModule(moduleImportName);
			while (!nidStream.eof) {
				uint nid = read!(uint)(nidStream);
				
				if (nid in pspModule.nids) {
					version (DEBUG_LOADER) writefln("    %s", pspModule.nids[nid]);
					callStream.write(cast(uint)(0x0000000C | (0x2307 << 6)));
					callStream.write(cast(uint)cast(void *)&pspModule.nids[nid]);
				} else {
					version (DEBUG_LOADER) writefln("    0x%08X", nid);
					callStream.write(cast(uint)(0x70000000));
					callStream.write(cast(uint)0);
				}
				//writefln("++");
				//writefln("--");
			}
		}
		// Load Exports.
		version (DEBUG_LOADER) writefln("Exports (0x%08X-0x%08X):", moduleInfo.exportsStart, moduleInfo.exportsEnd);
		while (!exportsStream.eof) {
			auto moduleExport = read!(ModuleExport)(exportsStream);
			auto moduleExportName = moduleExport.name ? readStringz(memory, moduleExport.name) : "<null>";
			version (DEBUG_LOADER) writefln("  '%s'", moduleExportName);
			moduleExports ~= moduleExport;
		}
	}
}

unittest {
	const testPath = "demos";
	auto memory = new SparseMemoryStream;
	try {
		auto loader = new Loader(
			new BufferedFile(testPath ~ "/controller.elf", FileMode.In),
			memory
		);
	} finally {
		//memory.smartDump();
	}

	//assert(0);
}
