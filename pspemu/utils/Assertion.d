module pspemu.utils.Assertion;

import std.stdio, std.string;

string assertOnFailFile;
void delegate() assertOnFailCallback;

public void assertOnFail(typeof(assertOnFailCallback) callback = null, string file = __FILE__) {
	assertOnFailCallback = callback;
	assertOnFailFile     = file;
}

protected void assertModule(string file = __FILE__) {
	static string lastFile;
	if (file != lastFile) {
		lastFile = file;
		writefln("Unittesting: %s...", lastFile);
		if (assertOnFailFile != file) assertOnFailCallback = null; // On other module we will reset the assertOnFailCallback.
	}
}

public void assertGroup(string text, string file = __FILE__) {
	assertModule(file);
	writefln(" %s:", text);
}

public void assertTrue(bool expr, lazy string message = "", string file = __FILE__, int line = __LINE__) {
	assertModule(file);
	writef("  Testing (%s:%d) ('%s')... ", file, line, message);
	if (!expr) {
		writefln("FAILED");
		if (assertOnFailCallback !is null) {
			assertOnFailCallback();
		} else {
			assert(0);
		}
	} else {
		writefln("Ok");
	}
}
