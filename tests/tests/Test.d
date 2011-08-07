module tests.Test;

public import std.stdio;

class Test {
	uint _assertsTotal;
	uint _assertsFailed;
	
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