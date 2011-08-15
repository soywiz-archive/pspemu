module test;

import std.conv;
import std.stdio;

struct HLEFunctionAnnotation {
	uint NID;
	int  requiredFirmwareVersion;
}

string HLEFunction(uint NID, uint requiredFirmwareVersion = 150) {
	return "static const auto __annotation_" ~ to!string(NID) ~ " = HLEFunctionAnnotation(" ~ to!string(NID) ~ ", " ~ to!string(requiredFirmwareVersion) ~ ");";
}

class Module {
	mixin(HLEFunction(0x00000001, 150));
	int c_method1() {
		return 1;
	}

	mixin(HLEFunction(0x00000002, 150));
	int b_method2() {
		return 2;
	}

	mixin(HLEFunction(0x00000003, 150));
	int a_method3() {
		return 3;
	}
}

int main(string[] args) {
	foreach (member; __traits(allMembers, Module)) {
		writefln("%s", member);
	}

	return 0;
}