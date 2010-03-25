module pspemu.hle.Loader;

//version = DEBUG_LOADER;

import std.stream, std.stdio, std.string;

import pspemu.utils.Utils;
import pspemu.utils.Expression;

import pspemu.formats.Elf;
import pspemu.formats.ElfDwarf;
import pspemu.formats.Pbp;

import pspemu.hle.Module;
import pspemu.hle.kd.iofilemgr;
import pspemu.hle.kd.sysmem;
import pspemu.hle.kd.threadman;

import pspemu.core.Memory;
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Interrupts;
import pspemu.core.cpu.Assembler;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.InstructionCounter;

import pspemu.models.IDebugSource;

import std.xml;

version (unittest) {
	import pspemu.utils.SparseMemory;
}

static const string psplibdoc_xml = import("psplibdoc.xml");

template LazySingleton() {
	static typeof(this) _singleton;
	static typeof(this) singleton() {
		if (_singleton is null) _singleton = new typeof(this);
		return _singleton;
	}
}

class PspLibdoc {
	mixin LazySingleton;

	protected this() {
		this.parse();
	}

	class LibrarySymbol {
		uint nid;
		string name;
		string comment;
		Library library;

		string toString() {
			return std.string.format(typeof(this).stringof ~ "(nid=0x%08X, name='%s' comment='%s')", nid, name, comment);
		}
	}

	class Function : LibrarySymbol { }
	class Variable : LibrarySymbol { }

	class Library {
		string name;
		uint flags;
		Function[uint] functions;
		Variable[uint] variables;
		LibrarySymbol[uint] symbols;
		Prx prx;

		string toString() {
			string s;
			s ~= std.string.format("  <Library name='%s' flags='0x%08x'>\n", name, flags);
			foreach (func; functions) s ~= std.string.format("    %s\n", func.toString);
			foreach (var ; variables) s ~= std.string.format("    %s\n", var .toString);
			s ~= std.string.format("  </Library>");
			return s;
		}
	}

	class Prx {
		string moduleName, fileName;
		Library[string] libraries;
		
		string toString() {
			string s;
			s ~= std.string.format("<Prx moduleName='%s' fileName='%s'>\n", moduleName, fileName);
			foreach (library; libraries) s ~= std.string.format("%s\n", library.toString);
			s ~= std.string.format("</Prx>");
			return s;
		}
	}

	Library[string] libraries;
	Prx[] prxs;

	LibrarySymbol locate(uint nid, string libraryName) {
		if (libraryName is null) {
			foreach (clibraryName; libraries.keys) if (auto symbol = locate(nid, clibraryName)) return symbol;
			return null;
		}
		if (libraryName !in libraries) return null;
		if (nid !in libraries[libraryName].symbols) return null;
		return libraries[libraryName].symbols[nid];
	}

	string getPrxPath(string libraryName) {
		return onException(libraries[libraryName].prx.fileName, "<unknown path>");
	}
	
	string getPrxName(string libraryName) {
		return onException(libraries[libraryName].prx.moduleName, "<unknown name>");
	}
	
	string getPrxInfo(string libraryName) {
		return std.string.format("%s (%s)", getPrxPath(libraryName), getPrxName(libraryName));
	}

	void parse() {
		auto xml = new Document(psplibdoc_xml);
		Function func;
		Variable var;
		Library library;
		Prx prx;

		void parseFunction(Element xml) {
			func = new Function();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "NID" : func.nid  = cast(uint)parseString(node.text); break;
					case "NAME": func.name = node.text; break;
					case "COMMENT": func.comment = node.text; break;
				}
			}
			func.library = library;
			library.functions[func.nid] = func;
			library.symbols[func.nid] = func;
		}

		void parseVariable(Element xml) {
			var = new Variable();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "NID" : var.nid  = cast(uint)parseString(node.text); break;
					case "NAME": var.name = node.text; break;
					case "COMMENT": var.comment = node.text; break;
				}
			}
			var.library = library;
			library.variables[var.nid] = var;
			library.symbols[var.nid] = var;
		}

		void parseLibrary(Element xml) {
			library = new Library();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "NAME"     : library.name  = node.text; break;
					case "FLAGS"    : library.flags = cast(uint)parseString(node.text); break;
					case "FUNCTIONS": foreach (snode; node.elements) if (snode.tag.name == "FUNCTION") parseFunction(snode); break;
					case "VARIABLES": foreach (snode; node.elements) if (snode.tag.name == "VARIABLE") parseVariable(snode); break;
				}
			}
			library.prx = prx;
			prx.libraries[library.name] = library;
		}

		void parsePrxFile(Element xml) {
			prx = new Prx();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "PRX"    : prx.fileName   = node.text; break;
					case "PRXNAME": prx.moduleName = node.text; break;
					case "LIBRARIES": foreach (snode; node.elements) if (snode.tag.name == "LIBRARY") parseLibrary(snode); break;
				}
			}
			foreach (library; prx.libraries) libraries[library.name] = library;
			prxs ~= prx;
		}

		foreach (node; xml.elements) if (node.tag.name == "PRXFILES") foreach (snode; node.elements) if (snode.tag.name == "PRXFILE") parsePrxFile(snode);

		//foreach (cprx; prxs) writefln("%s", cprx);
	}
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
	Cpu cpu;
	ModuleManager moduleManager;
	AllegrexAssembler assembler;
	Memory memory() { return cpu.memory; }
	ModuleInfo moduleInfo;
	ModuleImport[] moduleImports;
	ModuleExport[] moduleExports;
	
	this(Cpu cpu, ModuleManager moduleManager) {
		this.cpu           = cpu;
		this.moduleManager = moduleManager;
		this.assembler     = new AllegrexAssembler(memory);

		cpu.interrupts.callbacks[Interrupts.Type.THREAD0] ~= &moduleManager.get!(ThreadManForUser).threadManager.switchNextThread;
	}

	void load(Stream stream) {
		while (true) {
			auto magics = new SliceStream(stream, 0, 4);
			switch (magics.readString(4)) {
				case "\x7FELF":
				break;
				case "~PSP":
					throw(new Exception("Not support compressed elf files"));
				break;
				case "\0PBP":
					stream = (new Pbp(stream))["psp.data"];
					continue;
				break;
				default:
					throw(new Exception("Unknown file type"));
				break;
			}
			break;
		}
		
		this.elf = new Elf(stream);

		/*
		version (DEBUG_LOADER) {
			elf.dumpSections();
		}
		*/

		try {
			load();
		} catch (Object o) {
			writefln("Loader.load Exception: %s", o);
			throw(o);
		}

		/*
		version (DEBUG_LOADER) {
			count();
			moduleManager.dumpLoadedModules();
		}
		*/

		//checkDebug();
	}

	void load(string fileName) {
		fileName = fileName.replace("\\", "/");
		string path = ".";
		int index = fileName.lastIndexOf("/");
		if (index != -1) path = fileName[0..index];
		moduleManager.get!(IoFileMgrForUser).setVirtualDir(path);
		load(new BufferedFile(fileName, FileMode.In));
	}
	
	void checkDebug() {
		try {
			dwarf = new ElfDwarf;
			dwarf.parseDebugLine(elf.SectionStream(".debug_line"));
			dwarf.find(0x089004C8);
			cpu.debugSource = this;
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

	void allocatePartitionBlock() {
		Memory memory = cast(Memory)this.memory;

		// Not a Memory supplied.
		if (memory is null) {
			return;
		}

		auto sysMemUserForUser = moduleManager.get!(SysMemUserForUser);
		//writefln("%08X", memory.getPointer(this.elf.suggestedBlockAddress));
		auto blockid = sysMemUserForUser.sceKernelAllocPartitionMemory(2, "Main Program", PspSysMemBlockTypes.PSP_SMEM_Addr, this.elf.requiredBlockSize, this.elf.suggestedBlockAddress);
		uint blockaddress = sysMemUserForUser.sceKernelGetBlockHeadAddr(blockid);

		writefln("suggestedBlockAddress:%08X", this.elf.suggestedBlockAddress);
		writefln("requiredBlockSize:%08X", this.elf.requiredBlockSize);
		writefln("allocatedIn:%08X", blockaddress);
	}

	void load() {
		allocatePartitionBlock();

		this.elf.writeToMemory(memory);
		readInplace(moduleInfo, elf.SectionStream(".rodata.sceModuleInfo"));
		
		auto importsStream = new SliceStream(memory, moduleInfo.importsStart, moduleInfo.importsEnd);
		auto exportsStream = new SliceStream(memory, moduleInfo.exportsStart, moduleInfo.exportsEnd);
		
		// Load Imports.
		version (DEBUG_LOADER) writefln("Imports (0x%08X-0x%08X):", moduleInfo.importsStart, moduleInfo.importsEnd);

		uint[][string] unimplementedNids;
		
		while (!importsStream.eof) {
			auto moduleImport     = read!(ModuleImport)(importsStream);
			auto moduleImportName = moduleImport.name ? readStringz(memory, moduleImport.name) : "<null>";
			//assert(moduleImport.entry_size == moduleImport.sizeof);
			version (DEBUG_LOADER) writefln("  '%s'", moduleImportName);
			moduleImports ~= moduleImport;
			auto nidStream  = new SliceStream(memory, moduleImport.nidAddress , moduleImport.nidAddress  + moduleImport.func_count * 4);
			auto callStream = new SliceStream(memory, moduleImport.callAddress, moduleImport.callAddress + moduleImport.func_count * 8);
			//writefln("%08X", moduleImport.callAddress);
			
			auto pspModule = nullOnException(moduleManager[moduleImportName]);

			while (!nidStream.eof) {
				uint nid = read!(uint)(nidStream);
				
				if ((pspModule !is null) && (nid in pspModule.nids)) {
					version (DEBUG_LOADER) writefln("    %s", pspModule.nids[nid]);
					callStream.write(cast(uint)(0x0000000C | (0x2307 << 6)));
					callStream.write(cast(uint)cast(void *)&pspModule.nids[nid]);
				} else {
					version (DEBUG_LOADER) writefln("    0x%08X:<unimplemented>", nid);
					callStream.write(cast(uint)(0x70000000));
					callStream.write(cast(uint)0);
					unimplementedNids[moduleImportName] ~= nid;
				}
				//writefln("++");
				//writefln("--");
			}
		}
		
		if (unimplementedNids.length > 0) {
			int count = 0;
			writefln("unimplementedNids:");
			foreach (moduleName, nids; unimplementedNids) {
				writefln("  %s // %s:", moduleName, PspLibdoc.singleton.getPrxInfo(moduleName));
				foreach (nid; nids) {
					if (auto symbol = PspLibdoc.singleton.locate(nid, moduleName)) {
						writefln("    mixin(registerd!(0x%08X, %s));", symbol.nid, symbol.name);
					} else {
						writefln("    0x%08X:<Not found!>");
					}
				}
				count += nids.length;
			}
			//writefln("%s", PspLibdoc.singleton.prxs);
			throw(new Exception(std.string.format("Several unimplemented NIds. (%d)", count)));
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

	uint PC() { return elf.header.entryPoint; }
	uint GP() { return moduleInfo.gp; }

	void setRegisters() {
		auto threadManForUser = moduleManager.get!(ThreadManForUser);

		
		assembler.assembleBlock(r"
			.text 0x08000000
			syscall 0x2015   ; ThreadManForUser.sceKernelSleepThreadCB
			
			.text 0x08000010
			ininite_loop: j ininite_loop
			nop
		");

		auto pspThread = reinterpret!(PspThread)(threadManForUser.sceKernelCreateThread("Main Thread", PC, 32, 0x8000, 0, null));
		with (pspThread) {
			registers.pcSet = PC;
			registers.GP = GP;
			registers.K0 = pspThread.registers.SP;
			registers.RA = 0x08000000;
			registers.A0 = 0; // argumentsLength.
			registers.A1 = 0; // argumentsPointer
		}
		threadManForUser.sceKernelStartThread(reinterpret!(SceUID)(pspThread), 0, null);
		pspThread.switchToThisThread();

		writefln("PC: %08X", cpu.registers.PC);
		writefln("GP: %08X", cpu.registers.GP);
		writefln("SP: %08X", cpu.registers.SP);
	}
}

/*
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
*/
