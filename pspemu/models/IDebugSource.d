module pspemu.models.IDebugSource;

import std.string;

struct DebugSourceLine {
	string file;
	uint address;
	uint line;
	string toString() {
		return std.string.format("'%s':%d", file, line);
	}
}

struct DebugSymbol {
	uint address;
	string name;
}

interface IDebugSource {
	bool lookupDebugSourceLine(ref DebugSourceLine debugSourceLine, uint address);
	bool lookupDebugSymbol    (ref DebugSymbol debugSymbol, uint address);
}

template DebugSourceProxy() {
	IDebugSource debugSource;

	bool lookupDebugSourceLine(ref DebugSourceLine debugSourceLine, uint address) {
		if (!debugSource) return false;
		return debugSource.lookupDebugSourceLine(debugSourceLine, address);
	}

	bool lookupDebugSymbol(ref DebugSymbol debugSymbol, uint address) {
		if (!debugSource) return false;
		return debugSource.lookupDebugSymbol(debugSymbol, address);
	}
}