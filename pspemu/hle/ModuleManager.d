module pspemu.hle.ModuleManager;

public import pspemu.All;

class ModuleManager {
	/**
	 * A list of modules loaded.
	 */
	private Module[string] loadedModules;

	Cpu cpu;

	this(Cpu cpu) {
		this.cpu = cpu;
	}
	
	string delegate() getCurrentThreadName;

	void reset() {
		Logger.log(Logger.Level.DEBUG, "ModuleManager", "reset()");
		foreach (loadedModule; loadedModules) loadedModule.shutdownModule();
		loadedModules = null;
		getCurrentThreadName = null;
	}
	
	string currentThreadName() {
		string s = getCurrentThreadName ? getCurrentThreadName() : "<unknown>";
		return std.string.format("Thread('%-12s')", s);
	}

	/**
	 * Obtains a singleton instance of the module by a given name.
	 */
	Module getName(string moduleName) {
		if (moduleName !in loadedModules) {
			auto loadedModule = cast(Module)(Module.getModule(moduleName).create);
			loadedModule.cpu = cpu;
			loadedModule.moduleManager = this;
			loadedModule.init();
			loadedModules[moduleName] = loadedModule;
		}
		return loadedModules[moduleName];
	}

	void dumpLoadedModules() {
		writefln("LoadedModules {");
		foreach (_module; loadedModules) writefln("  '%s'", _module);
		writefln("}");
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
