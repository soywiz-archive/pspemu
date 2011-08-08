module pspemu.core.display.DisplayTest;

import pspemu.interfaces.IDisplay;

import pspemu.core.display.Display;
import pspemu.core.Interrupts;

import tests.Test;
import core.thread;

class DisplayTest : Test {
	Interrupts interrupts;
	IDisplay display;
	
	void setUp() {
		interrupts = new Interrupts();
		display = new Display(interrupts);
	}
	
	void tearDown() {
		display.interrupt();
	}
	
	void testDisplayVblankUpdates() {
		assertTrue(display.currentVblankCount == 0);

		display.start();
		
		Thread.sleep(dur!"msecs"(16 * 2 + 4));
		
		assertTrue(display.currentVblankCount >= 2);
	}

	void testInterrupts() {
		int executedCount_Vblank = 0;
		
		interrupts.addInterruptHandler(Interrupts.Type.Vblank, delegate(Interrupts.Task interruptTask) {
			executedCount_Vblank++;
		});

		display.start();
		
		Thread.sleep(dur!"msecs"(16 * 2 + 4));
		
		interrupts.executeInterrupts(null);
		
		assertTrue(executedCount_Vblank >= 2);
	}
}