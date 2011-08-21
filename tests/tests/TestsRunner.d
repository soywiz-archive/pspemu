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
	
	static public void runRegisteredTests() {
		TestsRunner.suite({
			foreach (testRun; Test.__registeredTestRuns) {
				TestsRunner.run(testRun);
			}
		});
	}
	
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
	
	static public void run(TestRun testRun) {
		writefln("%s:", testRun.className);
		
		int totalCount;
		int incompleteCount;
		int failedCount;

	    foreach (i, method; testRun.methods) {
    		writef("  %s...", method.name);
    		try {
    			testRun.test.__setUp();
    			testRun.test.setUp();
    			try {
    				method.callback();
    			} finally {
    				testRun.test.tearDown();
    				testRun.test.__tearDown();
    			}
    			
    			totalCount += testRun.test._assertsTotal; 
    			
    			if (testRun.test._assertsTotal == 0) {
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