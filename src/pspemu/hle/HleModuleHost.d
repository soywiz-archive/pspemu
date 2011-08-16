module pspemu.hle.HleModuleHost;

import std.string;

static struct HleFunction {
	HleModuleHost pspModule;
	uint nid;
	string name;
	void delegate() func;

	string toString() { return std.string.format("0x%08X:'%s.%s'", nid, pspModule, name); }
}

abstract class HleModuleHost : HleModule {
	string name;
	alias uint Nid;
	
	HleFunction[Nid   ] hleFunctionsByNid;
	HleFunction[string] hleFunctionsByName;
	
	__gshared ClassInfo[] registeredModules;

	static string registerFunction(uint id, alias func, uint requiredFirmwareVersion)() {
		return (""
			~ "hleFunctionsByName[\"" ~ FunctionName!(func) ~ "\"] = "
			~ "hleFunctionsByNid[" ~ to!string(id) ~ "] = "
			~ "HleFunction("
				~ "this, "
				~ to!string(id) ~ ", "
				~ "\"" ~ FunctionName!(func) ~ "\", "
				~ HleModuleMethodBridgeGenerator.getDelegate!(func, id)
			~ ");"
		);
	}

	/**
	 * Statically register a module in order to be able to use.
	 */
	static string registerModule(string moduleName) {
		return "HleModuleHost.registeredModules ~= " ~ moduleName ~ ".classinfo;";
	}

	static string registerModule(TypeInfo_Class moduleClass) {
		//writefln("%s", moduleClass);
		assert(0);
		return "";
	}

	/// deprecated
	static alias registerFunction register;
	/// deprecated
	static alias registerFunction registerd;
}

/+
public import std.stdio;
public import std.conv;
public import std.traits;

public import pspemu.utils.MathUtils;
public import pspemu.utils.MemoryPartition;
public import pspemu.utils.UniqueIdFactory;
public import pspemu.utils.Logger;

public import pspemu.core.exceptions.HaltException;
public import pspemu.core.exceptions.NotImplementedException;

public import pspemu.hle.kd.Types;
public import pspemu.hle.Module;
public import pspemu.core.cpu.CpuThreadBase;
public import pspemu.core.cpu.Registers;
public import pspemu.core.ThreadState;
public import pspemu.core.EmulatorState;
public import pspemu.hle.HleEmulatorState;

public import pspemu.hle.kd.SceKernelErrors;


/**
 * Thread Local Storage (TLS) variable. Each thread using it will have it's own value.
 */
static Module.Nid currentExecutingNid;

abstract class HleModuleNative : Module {
	public Object moduleLock;
	
	override public bool isNative() {
		return true;
	}
	
	// Will avoid obtaining the value from function.
	/*
	void returnValue(uint value) {
		currentRegisters.V0 = value;
	}
	*/
	
	this() {
		//Logger.log(Logger.Level.DEBUG, "Module", "Loading '%s'...", typeid(this));
		moduleLock = new Object();
	}
	
	/*
	public uint executeGuestCode(ThreadState threadState, uint pointer) {
		return hleEmulatorState.executeGuestCode(threadState, pointer);
	}
	*/
	
	string dupStr(string str) {
		return cast(string)((cast(char[])str).dup);
	}
	
	@property public UniqueIdFactory uniqueIdFactory() {
		return hleEmulatorState.uniqueIdFactory;
	}

	template Registration() {
		__gshared ClassInfo[] registeredModules;

		static string register(uint id, string name) {
			return "names[\"" ~ name ~ "\"] = nids[" ~ to!string(id) ~ "] = Function(this, " ~ to!string(id) ~ ", \"" ~ name ~ "\", &this." ~ name ~ ");";
		}

		static string registerd(uint id, alias func)() {
			debug (DEBUG_MODULE_DELEGATE) {
				pragma(msg, "{{{{");
				pragma(msg, "");
				pragma(msg, getModuleMethodDelegate!(func)());
				pragma(msg, "");
				pragma(msg, "}}}}");
			}

			return "names[\"" ~ FunctionName!(func) ~ "\"] = nids[" ~ to!string(id) ~ "] = Function(this, " ~ to!string(id) ~ ", \"" ~ FunctionName!(func) ~ "\", " ~ getModuleMethodDelegate!(func, id, options) ~ ");";
		}

		static string registerModule(string moduleName) {
			return "ModuleNative.registeredModules ~= " ~ moduleName ~ ".classinfo;";
		}

		static string registerModule(TypeInfo_Class moduleClass) {
			//writefln("%s", moduleClass);
			assert(0);
			return "";
		}

		static void dumpRegisteredModules() {
			writefln("RegisteredModules {");
			foreach (_module; registeredModules) {
				writefln("  '%s'", classInfoBaseName(_module));
			}
			writefln("}");
		}

		static ClassInfo getModule(string moduleName) {
			foreach (_module; registeredModules) if (classInfoBaseName(_module) == moduleName) return _module;
			throw(new Exception(std.string.format("Can't find module '%s'", moduleName)));
		}
	}
	
	mixin Parameters;
	mixin Registration;

	/*void opDispatch(string s)() {
		writefln("Module.opDispatch('%s.%s')", this.baseName, s);
		throw(new Exception(std.string.format("Not implemented %s.%s", this.baseName, s)));
	}*/
	
	string baseName() { return classInfoBaseName(typeid(this)); }
	string toString() { return std.string.format("Module(%s)", baseName); }
	
	string getNidName(uint nid) {
		return onException(nids[nid].name, "<unknown>");
	}

	void unimplemented(string file = __FILE__, int line = __LINE__)() {
		throw(new Exception(std.string.format("Unimplemented '%s' at '%s:%d'", getNidName(currentExecutingNid), file, line)));
	}
	
	void unimplemented_notice(string file = __FILE__, int line = __LINE__)() {
		logWarning("Unimplemented '%s' at '%s:%d'", getNidName(currentExecutingNid), file, line);
	}
	
	void logLevel(T...)(Logger.Level level, T args) {
		try {
			Logger.log(level, this.baseName, "nPC(%08X) :: Thread(%d:%s) :: %s", currentThreadState().registers.RA, currentThreadState().thid, currentThreadState().name, std.string.format(args));
		} catch (Throwable o) {
			Logger.log(Logger.Level.ERROR, "FORMAT_ERROR", "There was an error formating a logLevel for ('%s'.'%s')", this.baseName, getNidName(currentExecutingNid));
		}
	}
	mixin Logger.LogPerComponent;
}
+/
