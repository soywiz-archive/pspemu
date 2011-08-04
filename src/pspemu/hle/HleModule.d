module pspemu.hle.HleModule;

//public import pspemu.All;
debug = DEBUG_SYSCALL;
//debug = DEBUG_ALL_SYSCALLS;

import std.stdio;
import std.string;
import core.thread;

import pspemu.core.cpu.CpuThreadBase;
import pspemu.core.cpu.Registers;
import pspemu.core.ThreadState;
import pspemu.core.EmulatorState;
import pspemu.core.Memory;

import pspemu.utils.Logger;

import pspemu.formats.elf.ElfDwarf;

import pspemu.hle.HleEmulatorState;

import pspemu.hle.kd.loadcore.Types;

static string classInfoBaseName(ClassInfo ci) {
	auto index = ci.name.lastIndexOf('.');
	if (index == -1) index = 0; else index++;
	return ci.name[index..$];
	//return std.string.split(ci.name, ".")[$ - 1];
}

abstract class HleModule {
	static struct Function {
		Module pspModule;
		uint nid;
		string name;
		void delegate(CpuThreadBase cpuThread) func;
		string toString() {
			return std.string.format("0x%08X:'%s.%s'", nid, pspModule.baseName, name);
		}
	}

	alias uint Nid;
	ImportLibrary[string] importLibraries;
	ExportLibrary[string] exportLibraries;
	Function[Nid] nids;
	Function[string] names;
	bool setReturnValue;

	uint modid;
	uint entryPoint;
	
	bool dummyModule = false;
	public SceModule *sceModule;
	public ElfDwarf dwarf;
	
	abstract public bool isNative();

	class ImportLibrary {
		string name;
		uint[uint] funcImports;
		uint[uint] varImports;

		this(string name) {
			this.name = name;
		}
		
		public void fillImportsWithExports(Memory memory, ExportLibrary exportLibrary) {
			//writefln("%s", currentEmulatorState());
			//writefln("%s", currentMemory());
			logInfo("    FUNCS:");
			foreach (nid, importAddr; funcImports) {
				uint funcAddr = exportLibrary.funcExports[nid];
				
				logInfo("      (%08X) %s:%08X <- %s:%08X", nid, this.name, importAddr, exportLibrary.name, funcAddr);
				
				memory.twrite!(uint)(importAddr + 0, 0x_08000000 | ((funcAddr >> 2) & 0x3FFFFFF));
				memory.twrite!(uint)(importAddr + 4, 0x_00000000);
				logInfo("           %08X:%08X", memory.tread!(uint)(importAddr + 0), memory.tread!(uint)(importAddr + 4));
			}

			logInfo("    VARS:");
			foreach (nid, importAddr; varImports) {
				uint varAddr = exportLibrary.varExports[nid];
				
				logInfo("      (%08X) %s:%08X <- %s:%08X", nid, this.name, importAddr, exportLibrary.name, varAddr);
				memory.twrite(importAddr + 0, varAddr);
			}
		}
	}
	
	void logInfo(T...)(T args) {
		Logger.log(Logger.Level.INFO, "Module", "nPC(%08X) :: Thread(%d:%s) :: %s", currentThreadState().registers.RA, currentThreadState().thid, currentThreadState().name, std.string.format(args));
	}
	
	class ExportLibrary {
		string name;
		uint[uint] funcExports;
		uint[uint] varExports;
		
		this(string name) {
			this.name = name;
		}
	}
	
	public void fillImportsWithExports(Memory memory, Module moduleWithExports) {
		foreach (importLibrary; moduleWithExports.importLibraries) {
			logInfo("Import library '%s'", importLibrary.name);
		}
		foreach (exportLibrary; moduleWithExports.exportLibraries) {
			if (exportLibrary.name is null) continue;
			if (exportLibrary.name == "<null>") continue;
			logInfo("Trying to inject '%s'...", exportLibrary.name);
			if (exportLibrary.name in this.importLibraries) {
				logInfo("   Injecting '%s'...", exportLibrary.name);
				this.importLibraries[exportLibrary.name].fillImportsWithExports(memory, exportLibrary);
			}
		}
	}
	
	public ExportLibrary addExportLibrary(string name) {
		return exportLibraries[name] = new ExportLibrary(name);
	}

	public ImportLibrary addImportLibrary(string name) {
		return importLibraries[name] = new ImportLibrary(name);
	}
	
	public HleEmulatorState hleEmulatorState;

	@property static public CpuThreadBase currentCpuThread() {
		return thisThreadCpuThreadBase;
	}

	@property static public ThreadState currentThreadState() {
		return currentCpuThread.threadState;
	}
	
	@property public EmulatorState currentEmulatorState() {
		//return currentThreadState.emulatorState;
		return hleEmulatorState.emulatorState;
	}

	@property public Memory currentMemory() {
		return currentEmulatorState().memory;
	}

	@property static public Registers currentRegisters() {
		return currentThreadState.registers;
	}
	
	static public uint executeGuestCode(HleEmulatorState hleEmulatorState, uint pointer, uint[] arguments = null) {
		return hleEmulatorState.executeGuestCode(currentThreadState, pointer, arguments);
	}
	
	/*
	void logLevel(T...)(Logger.Level level, T args) {
		try {
			Logger.log(level, this.baseName, "nPC(%08X) :: Thread(%d:%s) :: %s", currentThreadState().registers.RA, currentThreadState().thid, currentThreadState().name, std.string.format(args));
		} catch (Throwable o) {
			Logger.log(Logger.Level.ERROR, "FORMAT_ERROR", "There was an error formating a logInfo for ('%s')", this.baseName);
		}
	}
	mixin Logger.LogPerComponent;
	*/
	
	/*
	static public void writefln(T...)(T args) {
		Logger.log(Logger.Level.TRACE, "Module", std.string.format("PC(0x%08X) :: %s ::%s", currentRegisters.PC, Thread.getThis.name, std.string.format(args)));
	}
	*/

	/*
	public HleEmulatorState currentHleEmulatorState() {
		return currentEmulatorState;
	}
	*/
	
	Function* getFunctionByName(string functionName) {
		return functionName in names;
	}
	
	final void init() {
		try {
			initNids();
			initModule();
		} catch (Throwable o) {
			.writefln("Error initializing module: '%s'", o);
			throw(o);
		}
	}

	abstract void initNids();
	
	void initModule() { }
	void shutdownModule() { }
	
	string baseName() { return classInfoBaseName(typeid(this)); }
	string toString() { return std.string.format("Module(%s)", baseName); }
	
	string name() { return baseName; }
}
