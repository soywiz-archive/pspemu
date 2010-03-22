module pspemu.hle.Module;

public import std.stdio, std.string, std.stream;
public import pspemu.utils.Utils;
public import pspemu.core.cpu.Cpu;

public import pspemu.hle.kd.types;

import std.traits;

//debug = DEBUG_MODULE_DELEGATE;

string FunctionName(alias f)() { return (&f).stringof[2 .. $]; }
bool isArrayType(alias T)() { return is(typeof(T[0])) && is(typeof(T.sort)); }
bool isPointerType(alias T)() { return is(typeof(*T)) && !isArrayType!(T); }

string FunctionName(T)() { return T.stringof[2 .. $]; }
bool isArrayType(T)() { return is(typeof(T[0])) && is(typeof(T.sort)); }
bool isPointerType(T)() {
	if (is(T == void*)) return true;
	return is(typeof(*T)) && !isArrayType!(T);
}
bool isString(T)() {
	return is(T == string);
}

string stringOf(T)() {
	return T.stringof;
}
string getModuleMethodDelegate(alias func)() {
	string functionName = FunctionName!(func);
	string r = "";
	//alias ReturnType!(func) return_type;
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
		string parametersString = _parametersString;
		string parametersPrototypeString = _parametersPrototypeString;
		if (parametersPrototypeString.length) {
			r ~= "debug (DEBUG_SYSCALL) .writef(\"" ~ functionName ~ "(" ~ _parametersPrototypeString ~ ")\", " ~ parametersString ~ "); ";
		} else {
			r ~= "debug (DEBUG_SYSCALL) .writef(\"" ~ functionName ~ "()\"); ";
		}
		if (return_value) r ~= "auto retval = ";
		r ~= "this." ~ functionName ~ "(" ~ parametersString ~ ");";
		if (return_value) {
			if (isPointerType!(ReturnType!(func))) {
				r ~= "cpu.registers.V0 = cpu.memory.getPointerReverse(cast(void *)retval);";
			} else {
				r ~= "cpu.registers.V0 = (cast(uint *)&retval)[0];";
				if (ReturnType!(func).sizeof == 8) {
					r ~= "cpu.registers.V1 = (cast(uint *)&retval)[1];";
				}
			}
		}
		if (return_value) {
			if (isPointerType!(ReturnType!(func))) {
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
	abstract void init();
	static ClassInfo[] knownModules;
	static Module[string] knownModulesByName;

	ulong param64(int n) { return cpu.registers[4 + n + 0] | (cpu.registers[4 + n + 1] << 32); }
	uint param(int n) { return cpu.registers[4 + n]; }
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

		return "names[\"" ~ FunctionName!(func) ~ "\"] = nids[" ~ tos(id) ~ "] = Function(this, " ~ tos(id) ~ ", \"" ~ FunctionName!(func) ~ "\", " ~ getModuleMethodDelegate!(func) ~ ");";
	}
	static string registerModule(string moduleName) {
		return "Module.knownModules ~= " ~ moduleName ~ ".classinfo;";
	}
	static string registerModule(TypeInfo_Class moduleClass) {
		//writefln("%s", moduleClass);
		assert(0);
		return "";
	}
	string baseName() {
		return classInfoBaseName(typeid(this));
	}
	static string classInfoBaseName(ClassInfo ci) {
		auto index = std.string.lastIndexOf(ci.name, ".");
		if (index == -1) index = 0; else index++;
		return ci.name[index..$];
		//return std.string.split(ci.name, ".")[$ - 1];
	}
	static void dumpKnownModules() {
		writefln("knownModules {");
		foreach (knownModule; knownModules) {
			writefln("  '%s'", classInfoBaseName(knownModule));
			//writefln("  '%s'", knownModule.name);
		}
		writefln("}");
	}
	static ClassInfo getModule(string moduleName) {
		foreach (knownModule; knownModules) {
			if (classInfoBaseName(knownModule) == moduleName) {
				return knownModule;
			}
		}
		throw(new Exception(std.string.format("Can't find module '%s'", moduleName)));
	}
	static Module loadModule(string moduleName) {
		if ((moduleName in knownModulesByName) is null) {
			knownModulesByName[moduleName] = cast(Module)getModule(moduleName).create;
		}
		return knownModulesByName[moduleName];
	}
	static Type loadModuleEx(alias Type)() {
		return cast(Type)loadModule(Type.stringof);
	}
	static Module opIndex(string moduleName) {
		return loadModule(moduleName);
	}

	void opDispatch(string s)() {
		writefln("Module.opDispatch('%s.%s')", this.baseName, s);
		throw(new Exception(std.string.format("Not implemented %s.%s", this.baseName, s)));
	}
}