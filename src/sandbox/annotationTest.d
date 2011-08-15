module test;

import std.conv;
import std.stdio;

uint NID(uint value) {
	return value;
}

uint MIN_FW(uint value) {
	return value;
}

struct HleFunction {
	uint   nid;
	int    requiredFirmwareVersion;
	string methodName;
	
	static HleFunction generate(uint nid, uint requiredFirmwareVersion = 150) {
		HleFunction hleFunction;
		hleFunction.nid = nid;
		hleFunction.requiredFirmwareVersion = requiredFirmwareVersion;
		return hleFunction;
	}

	static string opCall(uint nid, uint requiredFirmwareVersion = 150) {
		return "static const HleFunction __HLEFunction_" ~ to!string(nid) ~ " = HleFunction.generate(" ~ to!string(nid) ~ ", " ~ to!string(requiredFirmwareVersion) ~ ");";
	}
	
	static HleFunction[] getMembers(alias Module)() {
		HleFunction[] list;
		HleFunction currentHleFunction;
		bool nextIsMethod = false;
		foreach (member; __traits(allMembers, Module)) {
			static if (member.length >= 13 && member[0..13] == "__HLEFunction") {
				currentHleFunction.nid = __traits(getMember, Module, member).nid;
				currentHleFunction.requiredFirmwareVersion = __traits(getMember, Module, member).requiredFirmwareVersion;
				
				nextIsMethod = true;
			} else {
				if (nextIsMethod) {
					currentHleFunction.methodName = member;
				
					list ~= currentHleFunction;
					nextIsMethod = false;
				}
			}
		}
		return list;
	}
	
	/*
	static HleFunction[] getMembers(alias Module)() {
		HleFunction[] list;
		HleFunction currentHleFunction;
		bool nextIsMethod = false;
		foreach (member; __traits(allMembers, Module)) {
			static if (member.length >= 13 && member[0..13] == "__HLEFunction") {
				currentHleFunction.nid = __traits(getMember, Module, member).nid;
				currentHleFunction.requiredFirmwareVersion = __traits(getMember, Module, member).requiredFirmwareVersion;
				
				nextIsMethod = true;
			} else {
				if (nextIsMethod) {
					currentHleFunction.methodName = member;
				
					list ~= currentHleFunction;
					nextIsMethod = false;
				}
			}
		}
		return list;
	}
	*/
	
	static string registerNids_RegisterFunction(alias Module, uint nid, uint requiredFirmwareVersion, string moduleMember)() {
		return Module.registerd!(nid, __traits(getMember, Module, moduleMember), requiredFirmwareVersion);
	}
	
	static string registerNids_FindAnnotation(alias Module)() {
		string r;
		HleFunction currentHleFunction;
		foreach (k, member; __traits(allMembers, Module)) {
			static if (member.length >= 13 && member[0..13] == "__HLEFunction") {
				r ~= HleFunction.registerNids_RegisterFunction!(
					Module,
					__traits(getMember, Module, member).nid,
					__traits(getMember, Module, member).requiredFirmwareVersion,
					
					// Next member will be the method.
					__traits(allMembers, Module)[k + 1]
				);
			}
		}
		return r;
	}
	
	static string registerNids() {
		return q{
			HleFunction.registerNids_FindAnnotation!(typeof(this));
		};
	}
	
	string toString() {
		return std.string.format("HleFunction(nid=0x%08X, methodName='%s', requiredFirmwareVersion=%d)", nid, methodName, requiredFirmwareVersion);
	}
}

class BaseModule {
}

class HleModule : BaseModule {
}

class TestModule : HleModule {
	static struct Function {
		HleModule hleModule;
		uint      nid;
		string    name;
		void delegate(CpuThreadBase cpuThread) func;

		string toString() {
			return std.string.format("0x%08X:'%s.%s'", nid, pspModule.baseName, name);
		}
	}

	Function[string] names;

	static string registerd(uint nid, alias func, uint requiredFirmwareVersion = 150)() {
		return "names[\"" ~ FunctionName!(func) ~ "\"] = nids[" ~ to!string(nid) ~ "] = Function(this, " ~ to!string(nid) ~ ", \"" ~ FunctionName!(func) ~ "\", " ~ getModuleMethodDelegate!(func, id) ~ ");";
	}

	void initNids() {
		mixin(HleFunction.registerNids);
	}

	mixin(HleFunction(NID(0x00000001), MIN_FW(150)));
	int c_method1() {
		return 1;
	}

	mixin(HleFunction(NID(0x00000002), MIN_FW(150)));
	int b_method2() {
		return 2;
	}

	mixin(HleFunction(NID(0x00000003), MIN_FW(150)));
	int a_method3() {
		return 3;
	}
}

int main(string[] args) {
	(new TestModule).initNids();

	return 0;
}