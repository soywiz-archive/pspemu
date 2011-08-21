module tests.Test;

public import std.stdio;

class TestRun {
	static struct Method {
		void delegate() callback;
		string name;
	}

	public string className;
	public Test test;
	public Method [] methods;
	
	static public TestRun fromClass(T : Test)(T test) {
		TestRun testRun = new TestRun();
		testRun.className = T.stringof;
		testRun.test = test; 
		
	    foreach (i, member; __traits(allMembers, T)) {
	    	static if (member.length > 4 && member[0..4] == "test") {
   				mixin("testRun.methods ~= Method(&test." ~ member ~ ", \"" ~ member ~ "\");");
	    	}
	    }
	    
	    return testRun;
	}
}


class Test {
	template TRegisterTest() {
		static this() {
			__registeredTestRuns ~= TestRun.fromClass(new typeof(this));
			//TestsRunner.run(new typeof(this));
			//__registeredTests ~= new typeof(this);
			//writefln("%s", new typeof(this));
		}
	}
	
	public static TestRun[] __registeredTestRuns;
	
	uint _assertsTotal;
	uint _assertsFailed;
	
	final void __setUp() {
		_assertsTotal = 0;
		_assertsFailed = 0;
	}
	
	final void __tearDown() {
		
	}
	
	void setUp() {
		
	}
	
	void tearDown() {
		
	}
	
	void _assert(bool result, string message = "<assert>", string FILE = __FILE__, int LINE = __LINE__) {
		_assertsTotal++;
		if (!result) {
			writefln("ON %s:%d :: %s", FILE, LINE, message);
			_assertsFailed++;
			throw(new Exception(message));
		}
	}
	
	void assertSuccess(string FILE = __FILE__, int LINE = __LINE__) {
		_assert(true, std.string.format("assertSuccess"), FILE, LINE);
	}

	void assertFail(string FILE = __FILE__, int LINE = __LINE__) {
		_assert(false, std.string.format("assertFail"), FILE, LINE);
	}
	
	void assertTrue(bool a, string FILE = __FILE__, int LINE = __LINE__) {
		_assert(a, std.string.format("assertTrue(%s)", a), FILE, LINE);
	}
	
	void assertEquals(T1, T2)(T1 a, T2 b, string FILE = __FILE__, int LINE = __LINE__) {
		_assert(a == b, std.string.format("assertEquals('%s', '%s')", a, b), FILE, LINE);
	}
	
	void expectException(T : Throwable)(void delegate() code, string FILE = __FILE__, int LINE = __LINE__) {
		try {
			code();
			_assert(false, "exception not throwed", FILE, LINE);
		} catch (T v) {
			_assert(true, "exception throwed", FILE, LINE);
		}
	}
}