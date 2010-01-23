module pspemu.utils.assertion;

import std.stdio, std.string;

void assertTrue(bool expr, lazy string message = "", string file = __FILE__, int line = __LINE__) {
	writef("  Testing (%s:%d) ('%s')... ", file, line, message);
	if (!expr) {
		writefln("FAILED");
		assert(0);
	} else {
		writefln("Ok");
	}
}
