module pspemu.exe.Test;

import std.stdio;

static do_unittest = false;

unittest { do_unittest = true; }

void main() {
	if (do_unittest) {
		writefln("Unittesting: END");
		return;
	}
	writefln("main");
}
