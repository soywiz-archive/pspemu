module pspemu.hle.Module;

public import std.stdio, std.string, std.stream;
public import pspemu.utils.Utils;
public import pspemu.core.cpu.Cpu;

public import pspemu.hle.Types;

import std.traits;

//debug = DEBUG_MODULE_DELEGATE;

// http://dsource.org/projects/minid/browser/trunk/minid/bind.d

bool isArrayType(alias T)() { return is(typeof(T[0])) && is(typeof(T.sort)); }
bool isPointerType(alias T)() { return is(typeof(*T)) && !isArrayType!(T); }
bool isArrayType(T)() { return is(typeof(T[0])) && is(typeof(T.sort)); }
bool isPointerType(T)() { static if (is(T == void*)) return true; return is(typeof(*T)) && !isArrayType!(T); }
bool isClassType(T)() { return is(T == class); }
bool isString(T)() { return is(T == string); }
string FunctionName(alias f)() { return (&f).stringof[2 .. $]; }
string FunctionName(T)() { return T.stringof[2 .. $]; }
string stringOf(T)() { return T.stringof; }
static string classInfoBaseName(ClassInfo ci) {
	auto index = std.string.lastIndexOf(ci.name, ".");
	if (index == -1) index = 0; else index++;
	return ci.name[index..$];
	//return std.string.split(ci.name, ".")[$ - 1];
}

string getModuleMethodDelegate(alias func, uint nid = 0)() {
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
				r ~= "paramsz(" ~ tos(paramIndex) ~ ")";
			} else if (isPointerType!(param)) {
				r ~= "cast(" ~ param.stringof ~ ")param_p(" ~ tos(paramIndex) ~ ")";
			} else if (isClassType!(param)) {
				r ~= "cast(" ~ param.stringof ~ ")param_p(" ~ tos(paramIndex) ~ ")";
				//pragma(msg, "class!");
			} else if (param.sizeof == 8) {
				// TODO. FIXME!
				if (paramIndex % 2) paramIndex++; // PADDING
				r ~= "cast(" ~ param.stringof ~ ")param64(" ~ tos(paramIndex) ~ ")";
				paramIndex++; // extra incremnt
			} else {
				r ~= "cast(" ~ param.stringof ~ ")param(" ~ tos(paramIndex) ~ ")";
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
	r ~= "delegate void() { ";
	{
		r ~= "currentExecutingNid = " ~ tos(nid) ~ ";";
		r ~= "setReturnValue = true;";
		string parametersString = _parametersString;
		string parametersPrototypeString = _parametersPrototypeString;
		if (parametersPrototypeString.length) {
			r ~= "debug (DEBUG_SYSCALL) .writef(\"" ~ functionName ~ "(" ~ _parametersPrototypeString ~ ")\", " ~ parametersString ~ "); ";
		} else {
			r ~= "debug (DEBUG_SYSCALL) .writef(\"" ~ functionName ~ "()\"); ";
		}
		if (return_value) r ~= "auto retval = ";
		r ~= "this." ~ functionName ~ "(" ~ parametersString ~ ");";
		r ~= "if (setReturnValue) {";
		if (return_value) {
			if (isPointerType!(ReturnType!(func))) {
				r ~= "cpu.registers.V0 = cpu.memory.getPointerReverseOrNull(cast(void *)retval);";
			} else {
				r ~= "cpu.registers.V0 = (cast(uint *)&retval)[0];";
				if (ReturnType!(func).sizeof == 8) {
					r ~= "cpu.registers.V1 = (cast(uint *)&retval)[1];";
				}
			}
		}
		r ~= "}";
		if (return_value) {
			if (isPointerType!(ReturnType!(func)) || isClassType!(ReturnType!(func))) {
				r ~= "debug (DEBUG_SYSCALL) .writefln(\" = 0x%08X\", cpu.registers.V0); ";
			} else {
				r ~= "debug (DEBUG_SYSCALL) .writefln(\" = %s\", retval); ";
			}
		} else {
			r ~= "debug (DEBUG_SYSCALL) .writefln(\" = <void>\"); ";
		}
	}
	r ~= " }";
	return r;
}

abstract class Module {
	static struct Function {
		Module pspModule;
		uint nid;
		string name;
		void delegate() func;
		string toString() {
			return std.string.format("0x%08X:'%s.%s'", nid, pspModule.baseName, name);
		}
	}
	alias uint Nid;
	Cpu cpu;
	Function[Nid] nids;
	Function[string] names;
	ModuleManager moduleManager;
	Nid currentExecutingNid;
	bool setReturnValue;
	
	this() {
		initNids();
		initModule();
	}
	
	abstract void initNids();
	void initModule() { }
	
	template Parameters() {
		ulong param64(int n) { return cpu.registers[4 + n + 0] | (cpu.registers[4 + n + 1] << 32); }
		uint  param(int n) { return cpu.registers[4 + n]; }
		void* param_p(int n) {
			uint v = cpu.registers[4 + n];
			if (v != 0) {
				return cpu.memory.getPointer(v);
			} else {
				return null;
			}
		}
		char* paramszp(int n) { return cast(char *)param_p(n); }
		string paramsz(int n) { auto ptr = paramszp(n); return cast(string)ptr[0..std.c.string.strlen(ptr)]; }
	}
	
	template Registration() {
		__gshared static ClassInfo[] registeredModules;

		static string register(uint id, string name) {
			return "names[\"" ~ name ~ "\"] = nids[" ~ tos(id) ~ "] = Function(this, " ~ tos(id) ~ ", \"" ~ name ~ "\", &this." ~ name ~ ");";
		}

		static string registerd(uint id, alias func)() {
			debug (DEBUG_MODULE_DELEGATE) {
				pragma(msg, "{{{{");
				pragma(msg, "");
				pragma(msg, getModuleMethodDelegate!(func)());
				pragma(msg, "");
				pragma(msg, "}}}}");
			}

			return "names[\"" ~ FunctionName!(func) ~ "\"] = nids[" ~ tos(id) ~ "] = Function(this, " ~ tos(id) ~ ", \"" ~ FunctionName!(func) ~ "\", " ~ getModuleMethodDelegate!(func, id) ~ ");";
		}

		static string registerModule(string moduleName) {
			return "Module.registeredModules ~= " ~ moduleName ~ ".classinfo;";
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

	Function getFunctionByName(string functionName) {
		return names[functionName];
	}

	void opDispatch(string s)() {
		writefln("Module.opDispatch('%s.%s')", this.baseName, s);
		throw(new Exception(std.string.format("Not implemented %s.%s", this.baseName, s)));
	}
	
	string baseName() { return classInfoBaseName(typeid(this)); }
	string toString() { return std.string.format("Module(%s)", baseName); }

	void unimplemented(string file = __FILE__, int line = __LINE__)() {
		throw(new Exception(std.string.format("Unimplemented '%s' at '%s:%d'", onException(nids[currentExecutingNid].name, "<unknown>"), file, line)));
	}
}

class ModuleManager {
	/**
	 * A list of modules loaded.
	 */
	private Module[string] loadedModules;

	Cpu cpu;

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	/**
	 * Obtains a singleton instance of the module by a given name.
	 */
	Module getName(string moduleName) {
		if (moduleName !in loadedModules) {
			auto loadedModule = cast(Module)(Module.getModule(moduleName).create);
			loadedModule.cpu = cpu;
			loadedModule.moduleManager = this;
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
