module tests.TestsRunner;

import tests.Test;

import std.stdio;

class TestsRunner {
	static int testsTotal;
	static int testsFailed;
	static int testsIncomplete;
	
	static int assertsTotal;
	static int assertsFailed;
	static int assertsIncomplete;
	
	static public void suite(void delegate() callback) {
		assertsTotal = 0;
		assertsFailed = 0;
		{
			callback();
		}
		writefln("");
		writefln("Asserts: Total(%d) / Failed(%d) / Incomplete(%d)", assertsTotal, assertsFailed, assertsIncomplete);
		writefln("Tests: Total(%d) / Failed(%d) / Incomplete(%d)", testsTotal, testsFailed, testsIncomplete);
		writefln("");
		if (testsFailed) {
			writefln("ERRORS FOUND!");
		} else {
			writefln("ALL OK");
		}
	}
	
	static public void run(T : Test)(T object) {
		writefln("%s:", T.stringof);
		
		int totalCount;
		int incompleteCount;
		int failedCount;
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
	    			
	    			totalCount += object._assertsTotal; 
	    			
	    			if (object._assertsTotal == 0) {
	    				incompleteCount++;
	    				writefln("NO ASSERTS");
	    			} else {
		    			writefln("OK");
		    		}
	    		} catch (Throwable o) {
	    			failedCount++;

	    			writefln("%s", o);
	    			writefln("FAIL");
	    		}
	    	}
	    }

		if (totalCount) {
	    	testsTotal++;
	    	assertsTotal += totalCount;
	    }

	    if (failedCount) {
	    	testsFailed++;
	    	assertsFailed += failedCount;
	    }
	    if (incompleteCount) {
	    	testsIncomplete++;
	    	assertsIncomplete += incompleteCount;
	    }
	}
}