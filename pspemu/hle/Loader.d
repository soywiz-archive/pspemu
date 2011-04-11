module pspemu.hle.Loader;

//version = DEBUG_LOADER;
//version = ALLOW_UNIMPLEMENTED_NIDS;
//version = LOAD_DWARF_INFORMATION;

public import pspemu.All;

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
	ExecutionState executionState;
	ModuleManager moduleManager;
	AllegrexAssembler assembler, assemblerExe;
	Memory memory() { return executionState.memory; }
	ModuleInfo moduleInfo;
	ModuleImport[] moduleImports;
	ModuleExport[] moduleExports;
	
	this(ExecutionState executionState, ModuleManager moduleManager) {
		this.executionState = executionState;
		this.moduleManager  = moduleManager;
		this.assembler      = new AllegrexAssembler(memory);
		this.assemblerExe   = new AllegrexAssembler(memory);
	}

	void load(Stream stream, string name = "<unknown>") {
		// Assembler.
		if (name.length >= 4 && name[$ - 4..$] == ".asm") {
			assemblerExe.assembleBlock(cast(string)stream.readString(cast(uint)stream.size));
		}
		// Binary
		else {
			while (true) {
				auto magics = new SliceStream(stream, 0, 4);
				auto magic_data = cast(ubyte[])magics.readString(4);
				switch (cast(string)magic_data) {
					case "\x7FELF":
					break;
					case "~PSP":
						throw(new Exception("Not support compressed/encrypted elf files"));
					break;
					case "\0PBP":
						stream = (new Pbp(stream))["psp.data"];
						continue;
					break;
					default:
						throw(new Exception(std.string.format("Unknown file type '%s' : [%s]", name, magic_data)));
					break;
				}
				break;
			}
			
			this.elf = new Elf(stream);

			version (DEBUG_LOADER) elf.dumpSections();

			try {
				load();
			} catch (Object o) {
				writefln("Loader.load Exception: %s", o);
				throw(o);
			}

			version (DEBUG_LOADER) { count(); moduleManager.dumpLoadedModules(); }

			version (LOAD_DWARF_INFORMATION) loadDwarfInformation();
		}
	}

	string lastLoadedFile;

	void load(string fileName) {
		executionState.reset();
		reset();
		fileName = fileName.replace("\\", "/");

		string path = ".";
		int index = fileName.lastIndexOf('/');
		if (index != -1) path = fileName[0..index];
		moduleManager.get!(IoFileMgrForUser).setVirtualDir(path);

		load(new BufferedFile(lastLoadedFile = fileName, FileMode.In), fileName);
	}

	/*void reloadAndExecute() {
		loadAndExecute(lastLoadedFile);
	}*/

	void reset() {
		moduleManager.reset();
		executionState.interrupts.registerCallback(
			Interrupts.Type.THREAD0,
			&moduleManager.get!(ThreadManForUser).threadManager.switchNextThread
		);
	}

	/*void loadAndExecute(string fileName) {
		load(fileName);
		setRegisters();

		core.memory.GC.collect();

		cpu.gpu.start(); // Start GPU.
		cpu.start();     // Start CPU.
	}*/

	void loadDwarfInformation() {
		try {
			dwarf = new ElfDwarf;
			dwarf.parseDebugLine(elf.SectionStream(".debug_line"));
			dwarf.find(0x089004C8);
			executionState.debugSource = this;
			writefln("Loaded debug information");
		} catch (Object o) {
			writefln("Can't find debug information: '%s'", o);
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
		// Not a Memory supplied.
		if (cast(Memory)this.memory is null) return;

		uint allocateAddress;
		uint allocateSize    = this.elf.requiredBlockSize;
		if (this.elf.relocationAddress) {
			allocateAddress = this.elf.relocationAddress;
		} else {
			allocateAddress = getRelocatedAddress(this.elf.suggestedBlockAddress);
		}

		auto sysMemUserForUser = moduleManager.get!(SysMemUserForUser);
		
		auto blockid = sysMemUserForUser.sceKernelAllocPartitionMemory(2, "Main Program", PspSysMemBlockTypes.PSP_SMEM_Addr, allocateSize, allocateAddress);
		uint blockaddress = sysMemUserForUser.sceKernelGetBlockHeadAddr(blockid);

		Logger.log(Logger.Level.DEBUG, "Loader", "relocationAddress:%08X", this.elf.relocationAddress);
		Logger.log(Logger.Level.DEBUG, "Loader", "suggestedBlockAddress(no reloc):%08X", this.elf.suggestedBlockAddress);
		Logger.log(Logger.Level.DEBUG, "Loader", "allocateAddress:%08X", allocateAddress);
		Logger.log(Logger.Level.DEBUG, "Loader", "allocateSize:%08X", allocateSize);
		Logger.log(Logger.Level.DEBUG, "Loader", "allocatedIn:%08X", blockaddress);
		
		if (this.elf.relocationAddress != 0) {
			this.elf.relocationAddress = blockaddress;
		}
	}

	uint getRelocatedAddress(uint addr) {
		if (addr >= elf.relocationAddress) {
			if (elf.relocationAddress > 0) {
				Logger.log(Logger.Level.WARNING, "Loader", "Trying to get an already relocated address:%08X", addr);
			}
			return addr;
		} else {
			return addr + elf.relocationAddress;
		}
	}

	Stream getMemorySliceRelocated(uint from, uint to) {
		return new SliceStream(memory, getRelocatedAddress(from), getRelocatedAddress(to));
	}

	Stream getMemorySlice(uint from, uint to) {
		return new SliceStream(memory, (from), (to));
	}

	void load() {
		this.elf.preWriteToMemory(memory);
		{
			allocatePartitionBlock();
		}
		try {
			this.elf.writeToMemory(memory);
		} catch (Object o) {
			Logger.log(Logger.Level.CRITICAL, "Loader", "Failed this.elf.writeToMemory : %s", o);
			throw(o);
		}
		readInplace(moduleInfo, elf.SectionStream(".rodata.sceModuleInfo"));

		auto importsStream = getMemorySliceRelocated(moduleInfo.importsStart, moduleInfo.importsEnd);
		auto exportsStream = getMemorySliceRelocated(moduleInfo.exportsStart, moduleInfo.exportsEnd);
		
		// Load Imports.
		version (DEBUG_LOADER) writefln("Imports (0x%08X-0x%08X):", moduleInfo.importsStart, moduleInfo.importsEnd);

		uint[][string] unimplementedNids;
	
		while (!importsStream.eof) {
			auto moduleImport     = read!(ModuleImport)(importsStream);
			//writefln("%08X", moduleImport.name);
			auto moduleImportName = moduleImport.name ? readStringz(memory, moduleImport.name) : "<null>";
			//assert(moduleImport.entry_size == moduleImport.sizeof);
			version (DEBUG_LOADER) {
				writefln("  '%s'", moduleImportName);
				writefln("  {");
			}
			try {
				moduleImports ~= moduleImport;
				auto nidStream  = getMemorySlice(moduleImport.nidAddress , moduleImport.nidAddress  + moduleImport.func_count * 4);
				auto callStream = getMemorySlice(moduleImport.callAddress, moduleImport.callAddress + moduleImport.func_count * 8);
				//writefln("%08X", moduleImport.callAddress);
				
				auto pspModule = nullOnException(moduleManager[moduleImportName]);

				while (!nidStream.eof) {
					uint nid = read!(uint)(nidStream);
					
					if ((pspModule !is null) && (nid in pspModule.nids)) {
						version (DEBUG_LOADER) writefln("    %s", pspModule.nids[nid]);
						callStream.write(cast(uint)(0x0000000C | (0x1000 << 6))); // syscall 0x2307
						callStream.write(cast(uint)cast(void *)&pspModule.nids[nid]);
					} else {
						version (DEBUG_LOADER) writefln("    0x%08X:<unimplemented>", nid);
						//callStream.write(cast(uint)(0x70000000));
						//callStream.write(cast(uint)0);
						unimplementedNids[moduleImportName] ~= nid;
					}
					//writefln("++");
					//writefln("--");
				}
			} catch (Object o) {
				writefln("  ERRROR!: %s", o);
				throw(o);
			}
			version (DEBUG_LOADER) {
				writefln("  }");
			}
		}
		
		if (unimplementedNids.length > 0) {
			int count = 0;
			writefln("unimplementedNids {");
			foreach (moduleName, nids; unimplementedNids) {
				writefln("  %s // %s:", moduleName, DPspLibdoc.singleton.getPrxInfo(moduleName));
				foreach (nid; nids) {
					if (auto symbol = DPspLibdoc.singleton.locate(nid, moduleName)) {
						writefln("    mixin(registerd!(0x%08X, %s));", nid, symbol.name);
					} else {
						writefln("    0x%08X:<Not found!>", nid);
					}
				}
				count += nids.length;
			}
			writefln("}");
			//writefln("%s", DPspLibdoc.singleton.prxs);
			version (ALLOW_UNIMPLEMENTED_NIDS) {
			} else {
				throw(new Exception(std.string.format("Several unimplemented NIds. (%d)", count)));
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

	uint PC() {
		//writefln("assemblertext: %08X", assemblerExe.segments["text"]);
		return elf ? getRelocatedAddress(elf.header.entryPoint) : assemblerExe.segments["text"];
	}
	uint GP() { return elf ? getRelocatedAddress(moduleInfo.gp) : 0; }

	void setRegisters() {
		auto threadManForUser = moduleManager.get!(ThreadManForUser);

		assembler.assembleBlock(import("KernelUtils.asm"));

		auto thid = threadManForUser.sceKernelCreateThread("Main Thread", PC, 32, 0x8000, 0, null);
		auto pspThread = threadManForUser.getThreadFromId(thid);
		with (pspThread) {
			registers.pcSet = PC;
			registers.GP = GP;

			registers.SP -= 4;
			registers.K0 = registers.SP;
			registers.RA = 0x08000000;
		}

		// Write arguments.
		memory.position = 0x08100000;
		memory.write(cast(uint)(memory.position + 4));
		memory.writeString("ms0:/PSP/GAME/virtual/EBOOT.PBP\0");

		threadManForUser.sceKernelStartThread(thid, 1, memory.getPointerOrNull(0x08100004));
		pspThread.switchToThisThread();

		//cpu.traceStep = true; cpu.checkBreakpoints = true;
		Logger.log(Logger.Level.DEBUG, "Loader", "PC: %08X", executionState.registers.PC);
		Logger.log(Logger.Level.DEBUG, "Loader", "GP: %08X", executionState.registers.GP);
		Logger.log(Logger.Level.DEBUG, "Loader", "SP: %08X", executionState.registers.SP);
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
