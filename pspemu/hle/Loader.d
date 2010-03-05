module pspemu.hle.Loader;

import std.stream, std.stdio, std.string;

import pspemu.utils.Utils;

import pspemu.formats.Elf;
import pspemu.formats.Pbp;

import pspemu.hle.Module;

import std.xml;

version (unittest) {
	import pspemu.utils.SparseMemory;
}

class Loader {
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
	Stream memory;
	ModuleInfo moduleInfo;
	ModuleImport[] moduleImports;
	ModuleExport[] moduleExports;
	
	uint PC() { return elf.header.entryPoint; }
	uint GP() { return moduleInfo.gp; }

	this(Stream stream, Stream memory) {
		this.elf    = new Elf(stream);
		this.memory = memory;
		load();
		Module.dumpKnownModules();
	}

	void load() {
		this.elf.writeToMemory(memory);
		readInplace(moduleInfo, elf.SectionStream(".rodata.sceModuleInfo"));
		
		auto importsStream = new SliceStream(memory, moduleInfo.importsStart, moduleInfo.importsEnd);
		auto exportsStream = new SliceStream(memory, moduleInfo.exportsStart, moduleInfo.exportsEnd);

		// Load Imports.
		writefln("Imports:");
		while (!importsStream.eof) {
			auto moduleImport = read!(ModuleImport)(importsStream);
			auto moduleImportName = moduleImport.name ? readStringz(memory, moduleImport.name) : "<null>";
			//assert(moduleImport.entry_size == moduleImport.sizeof);
			writefln("  '%s'", moduleImportName);
			moduleImports ~= moduleImport;
			auto nidStream = new SliceStream(memory, moduleImport.nidAddress, moduleImport.nidAddress + moduleImport.func_count * 4);
			auto pspModule = Module.loadModule(moduleImportName);
			while (!nidStream.eof) {
				uint nid = read!(uint)(nidStream);
				
				if (nid in pspModule.nids) {
					writefln("    %s", pspModule.nids[nid]);
				} else {
					writefln("    0x%08X", nid);
				}
			}
		}
		// Load Exports.
		writefln("Exports:");
		while (!exportsStream.eof) {
			auto moduleExport = read!(ModuleExport)(exportsStream);
			auto moduleExportName = moduleExport.name ? readStringz(memory, moduleExport.name) : "<null>";
			writefln("  '%s'", moduleExportName);
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
