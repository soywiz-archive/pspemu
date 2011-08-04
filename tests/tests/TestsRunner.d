module tests.TestsRunner;

import std.stdio;

class TestsRunner {
	static public void run(T)(T object) {
		writefln("%s:", T.stringof);
	    foreach (i, member; __traits(allMembers, T)) {
	    	static if (member.length > 4 && member[0..4] == "test") {
	    		writef("  %s...", member);
	    		try {
	    			object.setUp();
	    			__traits(getMember, object, member)();
		    		writefln("OK");
	    		} catch (Throwable o) {
	    			writefln("%s", o);
	    			writefln("FAIL");
	    		}
	    	}
	    }
	}
}