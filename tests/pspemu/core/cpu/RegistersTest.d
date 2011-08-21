module pspemu.core.cpu.RegistersTest;

import tests.Test;

import pspemu.core.cpu.Registers;

class RegistersTest : Test {
	mixin TRegisterTest;
	
	Registers registers;

	void setUp() {
		registers = new Registers();
	}

	void testCantModify0() {
		registers[0] = 1;
		assertEquals(registers[0], 0);
	}

	void testCanModifyAllRegistersExcept0() {
		foreach (valueToSet; [0x_F0_12_EE_03, 0x_11_22_33_44]) {
			for (int n = 1; n < 32; n++) {
				registers[n] = valueToSet;
				assertEquals(registers[n], valueToSet);
			}
		}
	}
	
	void testRestoreBlock() {
		registers[10] = 10;
		registers[11] = 11;
		registers.restoreBlock({
			registers[10] = 20;
			registers[11] = 21;
		});
		assertEquals(registers[10], 10);
		assertEquals(registers[11], 11);
	}
}