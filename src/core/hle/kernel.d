module kernel;

public import std.string, std.stream, std.stdio;

public import psp.cpu;

class UnimplementedFunctionException : Exception {
	this(uint id, char[] name) {
		super(std.string.format("0x%08X: %s", id, name));
	}
}

class KLibrary {
	static uint argi(uint p) {
		return cpu.regs.a(p);
	}
	
	static char[] args(uint p) {
		return "";
	}

	static void reti(uint v) {
		cpu.regs.v0 = v;
	}
	
	static void function()[uint][char[]] libraries;
	static void function()[uint] currentLibrary;
	static char[] currentLibraryName;
	
	static void reset() {
		libraries = libraries.init;
	}

	static void sceExportLibraryStart(char[] name) {
		currentLibraryName = name;
		//writefln("sceExportLibrary: %s", name);
	}

	static void sceExportLibraryEnd() {
		libraries[currentLibraryName] = currentLibrary;
		currentLibrary = currentLibrary.init;
	}

	static void sceExportFunction(uint shaId, void function() func) {
		//writefln("sceExportFunction: 0x%08X", shaId);
		currentLibrary[shaId] = func;
	}		
}

static void sceExportModule(char[] name) {
	//writefln("sceExportModule: %s", name);
}
