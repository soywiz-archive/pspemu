module pspemu.hle.HleFunctionAttribute;

import std.conv;

uint NID(uint value) {
	return value;
}

uint MIN_FW(uint value) {
	return value;
}

struct HleFunctionAttribute {
	uint   nid;
	int    requiredFirmwareVersion;
	string methodName;
	
	static HleFunctionAttribute generate(uint nid, uint requiredFirmwareVersion = 150) {
		HleFunctionAttribute hleFunction;
		hleFunction.nid = nid;
		hleFunction.requiredFirmwareVersion = requiredFirmwareVersion;
		return hleFunction;
	}

	static string opCall(uint nid, uint requiredFirmwareVersion = 150) {
		return "static const HleFunctionAttribute __HLEFunction_" ~ to!string(nid) ~ " = HleFunctionAttribute.generate(" ~ to!string(nid) ~ ", " ~ to!string(requiredFirmwareVersion) ~ ");";
	}
	
	static string registerNids_RegisterFunction(alias Module, uint nid, uint requiredFirmwareVersion, string moduleMember)() {
		return Module.registerd!(nid, __traits(getMember, Module, moduleMember), requiredFirmwareVersion);
	}
	
	static string registerNids_FindAnnotation(alias Module)() {
		string r;
		HleFunctionAttribute currentHleFunction;
		foreach (k, member; __traits(allMembers, Module)) {
			static if (member.length >= 13 && member[0..13] == "__HLEFunction") {
				r ~= HleFunctionAttribute.registerNids_RegisterFunction!(
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
			HleFunctionAttribute.registerNids_FindAnnotation!(typeof(this));
		};
	}
	
	string toString() {
		return std.string.format("HleFunction(nid=0x%08X, methodName='%s', requiredFirmwareVersion=%d)", nid, methodName, requiredFirmwareVersion);
	}
}
