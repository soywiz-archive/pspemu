module pspemu.hle.ModuleNative;

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

enum FunctionOptions {
	None               = 0,
	
	/// Functions that doesn't write anything and doesn't need any atomic operation.
	/// Or functions that will take some time to execute. 
	NoSynchronized     = 0,

	/// Functions that write values only in that module. And don't allocate any external memory.
	SynchronizedModule = 1,
	
	/// Functions that write external values, allocate external memory or so.
	SynchronizedGlobal = 3,
}

abstract class ModuleNative : Module {
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
	
	void logLevel(T...)(Logger.Level level, T args) {
		try {
			Logger.log(level, this.baseName, "nPC(%08X) :: Thread(%d:%s) :: %s", currentThreadState().registers.RA, currentThreadState().thid, currentThreadState().name, std.string.format(args));
		} catch (Throwable o) {
			Logger.log(Logger.Level.ERROR, "FORMAT_ERROR", "There was an error formating a logLevel for ('%s'.'%s')", this.baseName, getNidName(currentExecutingNid));
		}
	}
	mixin Logger.LogPerComponent;

	@property public UniqueIdFactory uniqueIdFactory() {
		return hleEmulatorState.uniqueIdFactory;
	}

	template Parameters() {
		void* vparam_ptr(T)(int n) {
			if (n >= 8) {
				return currentEmulatorState.memory.getPointer(currentRegisters.SP + (n - 8) * 4);
			} else {
				return &currentRegisters.R[4 + n];
			}
		}
		T vparam_value(T)(int n) {
			static if (is(T == string)) {
				uint v = vparam_value!(uint)(n);
				//writefln("---------%08X(%d)", v, n);
				auto ptr = cast(char*)currentEmulatorState.memory.getPointer(v);
				return cast(string)ptr[0..std.c.string.strlen(ptr)];
			} else {
				return *cast(T *)vparam_ptr!(T)(n);
			}
		}
		ulong param64(int n) { return vparam_value!(ulong)(n); }
		uint  param  (int n) { return vparam_value!(uint )(n); }
		float paramf (int n) { return vparam_value!(float)(n); }
		
		int current_vparam = 0;
		T readparam(T)(int set = -1) {
			int _align = T.sizeof / 4;
			static if (is(T == string)) _align = 1;
			if (set >= 0) current_vparam = set;
			while (current_vparam % _align) current_vparam++;
			auto ret = vparam_value!(T)(current_vparam);
			current_vparam += _align;
			return ret;
		}
		
		void* param_p(int n) {
			uint v = param(n);
			if (v != 0) {
				try {
					return currentEmulatorState.memory.getPointer(v);
				} catch (Throwable o) {
					// @TODO: Reenable?
					throw(o);
					return null;
				}
			} else {
				return null;
			}
		}
		char* paramszp(int n) { return cast(char *)param_p(n); }
		//string paramsz(int n) { auto ptr = paramszp(n); return cast(string)ptr[0..std.c.string.strlen(ptr)]; }
		string paramsz(int n) { return vparam_value!(string)(n); }
	}
	
	template Registration() {
		__gshared ClassInfo[] registeredModules;

		static string register(uint id, string name) {
			return "names[\"" ~ name ~ "\"] = nids[" ~ to!string(id) ~ "] = Function(this, " ~ to!string(id) ~ ", \"" ~ name ~ "\", &this." ~ name ~ ");";
		}

		static string registerd(uint id, alias func, FunctionOptions options = FunctionOptions.None)() {
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
		//logError("Unimplemented '%s' at '%s:%d'", getNidName(currentExecutingNid), file, line);
		//hleEmulatorState.emulatorState.runningState.stopCpu();
		throw(new Exception(std.string.format("Unimplemented '%s' at '%s:%d'", getNidName(currentExecutingNid), file, line)));
	}
	
	void unimplemented_notice(string file = __FILE__, int line = __LINE__)() {
		logWarning("Unimplemented '%s' at '%s:%d'", getNidName(currentExecutingNid), file, line);
	}
}

T onException(T)(lazy T t, T errorValue) { try { return t(); } catch { return errorValue; } }
T nullOnException(T)(lazy T t) { return onException!(T)(t, null); }

void putStringz(T)(ref T ptr, string s) {
	ptr[0..s.length] = s;
	ptr[s.length] = 0;
}

bool isArrayType(alias T)() { return is(typeof(T[0])) && is(typeof(T.sort)); }
bool isPointerType(alias T)() { return is(typeof(*T)) && !isArrayType!(T); }
bool isArrayType(T)() { return is(typeof(T[0])) && is(typeof(T.sort)); }
bool isPointerType(T)() { static if (is(T == void*)) return true; return is(typeof(*T)) && !isArrayType!(T); }
bool isClassType(T)() { return is(T == class); }
bool isString(T)() { return is(T == string); }
string FunctionName(alias f)() { return (&f).stringof[2 .. $]; }
string FunctionName(T)() { return T.stringof[2 .. $]; }
string stringOf(T)() { return T.stringof; }

string getModuleMethodDelegate(alias func, uint nid = 0, FunctionOptions options = FunctionOptions.None)() {
	string functionName = FunctionName!(func);
	string r = "";
	alias ReturnType!(func) return_type;
	bool return_value = !is(ReturnType!(func) == void);
	string _parametersString() {
		string r = "";
		int paramIndex = 0;
		foreach (param; ParameterTypeTuple!(func)) {
			if (paramIndex > 0) r ~= ", ";
			if (isString!(param)) {
				r ~= "paramsz(" ~ to!string(paramIndex) ~ ")";
			} else if (isPointerType!(param)) {
				r ~= "cast(" ~ param.stringof ~ ")param_p(" ~ to!string(paramIndex) ~ ")";
			} else if (isClassType!(param)) {
				r ~= "cast(" ~ param.stringof ~ ")param_p(" ~ to!string(paramIndex) ~ ")";
				//pragma(msg, "class!");
			} else if (param.sizeof == 8) {
				// TODO. FIXME!
				if (paramIndex % 2) paramIndex++; // PADDING
				r ~= "cast(" ~ param.stringof ~ ")param64(" ~ to!string(paramIndex) ~ ")";
				paramIndex++; // extra incremnt
			} else {
				r ~= "cast(" ~ param.stringof ~ ")param(" ~ to!string(paramIndex) ~ ")";
			}
			paramIndex++;
		}
		return r;
	}
	string _parametersPrototypeString() {
		string r = "";
		int paramIndex = 0;
		foreach (param; ParameterTypeTuple!(func)) {
			if (paramIndex > 0) r ~= ", ";
			if (isString!(param)) {
				r ~= "\\\"%s\\\"";
			} else {
				r ~= "%s";
			}
			paramIndex++;
		}
		return r;
	}
	r ~= "delegate void(CpuThreadBase cpuThread) { ";
	{
		if (options & FunctionOptions.SynchronizedGlobal) r ~= "synchronized (hleEmulatorState.globalLock)";
		if (options & FunctionOptions.SynchronizedModule) r ~= "synchronized (hleEmulatorState.moduleLock)";
		r ~= "{";
		{
			r ~= "currentExecutingNid = " ~ to!string(nid) ~ ";";
			//r ~= "Logger.log(Logger.Level.TRACE, \"Module\", std.string.format(\"%s\", \"" ~ functionName ~ "\"));";
			r ~= "logLevel(Logger.Level.TRACE, std.string.format(\"%s\", \"" ~ functionName ~ "\"));";
			r ~= "setReturnValue = true;";
			r ~= "current_vparam = 0;";
			string parametersString = _parametersString;
			string parametersPrototypeString = _parametersPrototypeString;
			debug (DEBUG_ALL_SYSCALLS) { } else { r ~= "debug (DEBUG_SYSCALL)"; }
			r ~= "{";
			r ~= ".writef(\"%s; PC=%08X; \", moduleManager.currentThreadName, currentRegisters.PC);";
			debug (DEBUG_ALL_SYSCALLS) {
				r ~= ".writef(\"" ~ functionName ~ "()\"); ";
			} else {
				if (parametersPrototypeString.length) {
					r ~= ".writef(\"" ~ functionName ~ "(" ~ _parametersPrototypeString ~ ")\", " ~ parametersString ~ "); ";
				} else {
					r ~= ".writef(\"" ~ functionName ~ "()\"); ";
				}
			}
			r ~= "}";
			if (return_value) r ~= "auto retval = ";
			r ~= "this." ~ functionName ~ "(" ~ parametersString ~ ");";
			if (return_value) {
				r ~= "if (setReturnValue) {";
				if (isPointerType!(ReturnType!(func))) {
					r ~= "currentRegisters.V0 = currentEmulatorState.memory.getPointerReverseOrNull(cast(void *)retval);";
				} else {
					r ~= "currentRegisters.V0 = (cast(uint *)&retval)[0];";
					if (ReturnType!(func).sizeof == 8) {
						r ~= "currentRegisters.V1 = (cast(uint *)&retval)[1];";
					}
				}
				r ~= "}";
			}
			debug (DEBUG_ALL_SYSCALLS) { } else { r ~= "debug (DEBUG_SYSCALL)"; }
			r ~= "{";
			if (return_value) {
				if (isPointerType!(ReturnType!(func)) || isClassType!(ReturnType!(func))) {
					r ~= ".writefln(\" = 0x%08X\", currentRegisters.V0); ";
				} else {
					r ~= ".writefln(\" = %s\", retval); ";
				}
			} else {
				r ~= ".writefln(\" = <void>\"); ";
			}
			r ~= "}";
		}
		r ~= "}";
	}
	r ~= " }";
	return r;
}