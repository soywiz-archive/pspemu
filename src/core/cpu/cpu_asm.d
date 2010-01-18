module pspemu.core.cpu.cpu_asm;

import pspemu.utils.sparse_memory;

import std.stdio, std.string, std.stream;

class AllegrexAssembler {
	uint[string] labels;
}

unittest {
	writefln("Unittesting: core.cpu.cpu_asm...");
}