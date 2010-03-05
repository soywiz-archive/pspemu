module pspemu.hle.Module;

import std.stdio;

import pspemu.utils.Utils;

import pspemu.core.cpu.Cpu;

abstract class Module {
	alias void delegate() Function;
	struct FunctionName { uint nid; string name; Function func; string toString() { return std.string.format("0x%08X:'%s'", nid, name); } }
	alias uint Nid;
	Cpu cpu;
	FunctionName[Nid] nids;
	abstract void init();
	static ClassInfo[] knownModules;
	static Module[string] knownModulesByName;

	static string register(uint id, string name) {
		return "nids[" ~ tos(id) ~ "] = FunctionName(" ~ tos(id) ~ ", \"" ~ name ~ "\", &this." ~ name ~ ");";
	}
	static string registerModule(string moduleName) {
		return "Module.knownModules ~= " ~ moduleName ~ ".classinfo;";
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

	void opDispatch(string s)()
	{
		writefln("Module.opDispatch('%s')", s);
	}
}