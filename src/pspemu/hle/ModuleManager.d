module pspemu.hle.ModuleManager;

import std.stdio;
import std.stream;

import pspemu.hle.Module;
import pspemu.hle.ModulePsp;
import pspemu.hle.ModuleNative;

import pspemu.hle.HleEmulatorState;

import pspemu.hle.vfs.VirtualFileSystem;
import pspemu.hle.vfs.MountableVirtualFileSystem;
import pspemu.hle.kd.sysmem.Types;

//public import pspemu.All;
class ModuleManager {
	const uint CODE_PTR_EXIT_THREAD  = 0x08000000;
	const uint CODE_PTR_END_CALLBACK = 0x08000004;
	const uint CODE_PTR_ARGUMENTS    = 0x08000100;

	/**
	 * A list of modules loaded.
	 */
	private Module[string] loadedModules;

	string delegate() getCurrentThreadName;
	
	HleEmulatorState hleEmulatorState;
	
	public this(HleEmulatorState hleEmulatorState) {
		this.hleEmulatorState = hleEmulatorState;
	}

	void reset() {
		//Logger.log(Logger.Level.DEBUG, "ModuleManager", "reset()");
		foreach (loadedModule; loadedModules) loadedModule.shutdownModule();
		loadedModules = null;
		getCurrentThreadName = null;
	}
	
	string currentThreadName() {
		string s = getCurrentThreadName ? getCurrentThreadName() : "<unknown>";
		return std.string.format("Thread('%-12s')", s);
	}
	
	ModulePsp createDummyModule() {
		ModulePsp loadedModule = new ModulePsp();
		loadedModule.dummyModule = true;
		loadedModule.modid = hleEmulatorState.uniqueIdFactory.add!Module(loadedModule);
		return loadedModule;
	}
	
	public ModulePsp loadModuleFromVfs(string fsProgramPath, uint argc, uint argv, string pspModulePath = null) {
		if (thisThreadCpuThreadBase is null) throw(new Exception("thisThreadCpuThreadBase is null"));
		return loadModuleFromVfs(thisThreadCpuThreadBase.createCpuThread(), fsProgramPath, argc, argv, pspModulePath);
	}

	/**
	 * Loads a specified module by its vfsPath and set the registers to the specified thread that must be already created.  
	 *
	 * @param  thread         Thread to set the registers to
	 * @param  fsProgramPath  Path in the guest file system
	 * @param  argc           Number of arguments
	 * @param  argv           Pointer to a list of char pointers
	 * @param  pspModulePath  Path in the host file system
	 */
	public ModulePsp loadModuleFromVfs(CpuThreadBase thread, string fsProgramPath, uint argc, uint argv, string pspModulePath = null) {
		auto rootFileSystem = hleEmulatorState.rootFileSystem;
		
		ModulePsp modulePsp = hleEmulatorState.moduleManager.loadPspModule(
			rootFileSystem.fsroot.open(fsProgramPath, FileOpenMode.In, FileAccessMode.All),
			fsProgramPath
		);
		
		with (thread) {
			registers.pcSet = modulePsp.sceModule.entry_addr; 
		
			registers.GP = modulePsp.sceModule.gp_value;
			registers.SP = hleEmulatorState.memoryManager.allocStack(PspPartition.User, "Stack for main thread", 0x4000) - 0x10;
			registers.K0 = registers.SP;
			registers.RA = ModuleManager.CODE_PTR_EXIT_THREAD;
			registers.A0 = argc;
			registers.A1 = argv;
		}
		
		//emulator.emulatorState.memory.twrite(0x08810D62, cast(ubyte)0);
		
		Logger.log(Logger.Level.INFO, "ModuleLoader", "Module '%s':'%s' loaded successfully", fsProgramPath, pspModulePath);
		//logInfo("Module '%s' loaded successfully", pspModulePath);
		
		return modulePsp;
	}
	
	ModulePsp loadPspModule(Stream stream, string fileName = "?unknownFileName?") {
		//writefln("[1]");
		ModulePsp loadedModule = hleEmulatorState.moduleLoader.load(stream, fileName);
		//writefln("[2]");
		loadedModule.modid = hleEmulatorState.uniqueIdFactory.add!Module(loadedModule);
		//writefln("[3]");
		if (fileName in loadedModules) throw(new Exception("Module already loaded"));
		loadedModules[fileName] = loadedModule; 
		//writefln("[4]");
		return loadedModule;
	}

	/**
	 * Obtains a singleton instance of the module by a given name.
	 */
	Module getName(string moduleName) {
		if (moduleName !in loadedModules) {
			Logger.log(Logger.Level.INFO, "ModuleManager", "%08X :: Loading module '%s'", cast(uint)cast(void *)this, moduleName);
			Module loadedModule = cast(Module)(ModuleNative.getModule(moduleName).create);
			loadedModule.hleEmulatorState = this.hleEmulatorState;
			//loadedModule.cpu = cpu;
			//loadedModule.moduleManager = this;
			loadedModule.init();
			loadedModules[moduleName] = loadedModule;

			loadedModule.modid = hleEmulatorState.uniqueIdFactory.add!Module(loadedModule);
		}
		return loadedModules[moduleName];
	}

	void dumpLoadedModules() {
		writefln("LoadedModules {");
		foreach (_module; loadedModules) writefln("  '%s'", _module);
		writefln("}");
	}
	
	Module getModuleByAddress(uint addr) {
		foreach (loadedModule; loadedModules) {
			if (addr == loadedModule.entryPoint) return loadedModule; 
		}
		throw(new Exception("Not implemented getModuleByAddress"));
		return null;
	}

	/**
	 * Obtains a singleton instance of the module by a given type.
	 */
	Type get(alias Type)() {
		return cast(Type)getName(Type.stringof);
	}

	/**
	 * Alias for getting a module.
	 */
	alias getName opIndex;
}
