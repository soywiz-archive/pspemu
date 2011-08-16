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
	
	void dumpBuffer(ubyte[] buffer) {
		foreach (c; buffer) writef("%02X ", c); writefln("");
	}
	
	void testAsmAssist() {
		static void func1() {
			// EAX = 0, ECX = 1, EDX = 2, EBX = 3, ESP = 4, EBP = 5, ESI = 6, EDI = 7
			asm {
				naked;
				cmp EAX, 0x77777777;
				cmp ECX, 0x77777777;
				cmp EDX, 0x77777777;
				cmp EBX, 0x77777777;
				cmp ESP, 0x77777777;
				cmp EBP, 0x77777777;
				cmp EDI, 0x77777777;
			}
		}
		static void func2() {  }
		ubyte[] data = (cast(ubyte *)&func1)[0..(cast(ubyte *)&func2 - cast(ubyte *)&func1)];
		
		// dumpBuffer(data);
	}
	
	void testLoop() {
		Emmiter.Label loopLabel;

		emmiter.DEBUGGER_BREAK();

		emmiter.MOV(Gpr32.EAX, 0);
		emmiter.MOV(Gpr32.ECX, 17);

		emmiter.setLabelHere(loopLabel);
		{
			emmiter.ADD(Gpr32.EAX, 2);
			emmiter.ADD(Gpr32.ECX, -1);
			emmiter.CMP(Gpr32.ECX, 0);
			emmiter.JNE(loopLabel);
		}
		
		emmiter.RET();
		
		//dumpBuffer(emmiter.finalize());
		
		assertEquals(17 * 2, emmiter.execute());
	}
}