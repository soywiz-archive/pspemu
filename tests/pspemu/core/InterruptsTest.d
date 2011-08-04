module pspemu.core.InterruptsTest;

import pspemu.core.Interrupts;

import tests.Test;

class InterruptsTest : Test {
	Interrupts interrupts;
	
	void setUp() {
		interrupts = new Interrupts();
	}
	
	void testInterruptExecution() {
		int executedCount_Thread0 = 0;
		
		interrupts.addInterruptHandler(Interrupts.Type.Thread0, delegate(Interrupts.Task interruptTask) {
			executedCount_Thread0++;
		});
		
		assertEquals(0, interrupts.I_F);
		{
			interrupts.interrupt(Interrupts.Type.Thread0);
			interrupts.interrupt(Interrupts.Type.Gpio);
		}
		assertEquals(1, interrupts.I_F);
		
		interrupts.executeInterrupts(null);
		
		assertEquals(1, executedCount_Thread0);
	}
}