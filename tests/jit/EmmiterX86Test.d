module jit.EmmiterX86Test;

import jit.EmmiterX86;

import tests.Test;

class EmmiterX86Test : Test {
	EmmiterX86 emmiter;
	
	void setUp() {
		emmiter = new EmmiterX86();
	}
	
	void testRet() {
		emmiter.MOV(Gpr32.EAX, 999);
		emmiter.RET();
		assertEquals(999, emmiter.execute());
	}
	
	void testCall() {
		extern (C) static int test(int SUB) {
			return 888 - SUB;
		}
		
		//emmiter.DEBUGGER_BREAK();
		emmiter.PUSH(111);
		emmiter.CALL(&test);
		emmiter.STACK_LEAVE(4);
		emmiter.RET();
		assertEquals(777, emmiter.execute());
	}
}