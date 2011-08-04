module tests.TestsRunner;

import tests.Test;

import std.stdio;

class TestsRunner {
	static public void run(T : Test)(T object) {
		writefln("%s:", T.stringof);
	    foreach (i, member; __traits(allMembers, T)) {
	    	static if (member.length > 4 && member[0..4] == "test") {
	    		writef("  %s...", member);
	    		try {
	    			object.setUp();
	    			try {
	    				__traits(getMember, object, member)();
	    			} finally {
	    				object.tearDown();
	    			}
	    			if (object._assertsTotal == 0) {
	    				writefln("NO ASSERTS");
	    			} else {
		    			writefln("OK");
		    		}
	    		} catch (Throwable o) {
	    			writefln("%s", o);
	    			writefln("FAIL");
	    		}
	    	}
	    }
	}
}