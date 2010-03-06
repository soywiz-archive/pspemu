module pspemu.hle.Module;

public import std.stdio, std.string, std.stream;
public import pspemu.utils.Utils;
public import pspemu.core.cpu.Cpu;

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

	uint param(int n) { return cpu.registers[4 + n]; }
	void* param_p(int n) { return cpu.memory.getPointer(cpu.registers[4 + n]); }
	char* paramszp(int n) { return cast(char *)param_p(n); }
	char[] paramsz(int n) { auto ptr = paramszp(n); return ptr[0..std.c.string.strlen(ptr)]; }

	static string register(uint id, string name) {
		return "names[\"" ~ name ~ "\"] = nids[" ~ tos(id) ~ "] = Function(this, " ~ tos(id) ~ ", \"" ~ name ~ "\", &this." ~ name ~ ");";
	}
	static string registerModule(string moduleName) {
		return "Module.knownModules ~= " ~ moduleName ~ ".classinfo;";
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
		assert(0, std.string.format("Can't find module '%s'", moduleName));
	}
	static Module loadModule(string moduleName) {
		if ((moduleName in knownModulesByName) is null) {
			knownModulesByName[moduleName] = cast(Module)getModule(moduleName).create;
		}
		return knownModulesByName[moduleName];
	}
	static Module opIndex(string moduleName) {
		return loadModule(moduleName);
	}

	void opDispatch(string s)() {
		writefln("Module.opDispatch('%s.%s')", this.baseName, s);
		assert(0, std.string.format("Not implemented %s.%s", this.baseName, s));
	}
}