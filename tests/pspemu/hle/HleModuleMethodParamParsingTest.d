module pspemu.hle.HleModuleMethodParamParsingTest;

import pspemu.hle.HleModuleMethodParamParsing;
import pspemu.MemoryInstance;
import pspemu.core.Memory;
import pspemu.core.cpu.Registers;

import tests.Test;

class HleModuleMethodParamParsingTest : Test {
	mixin TRegisterTest;
	
	Memory memory;
	PspMemoryStream memoryStream;
	Registers registers;
	HleModuleMethodParamParsing hleModuleMethodParamParsing;
	
	void setUp() {
		hleModuleMethodParamParsing = hleModuleMethodParamParsing.init;
		hleModuleMethodParamParsing.memory = memory = MemoryInstance.instance;
		hleModuleMethodParamParsing.registers = registers = new Registers();
		memoryStream = new PspMemoryStream(memory);
	}
	
	void testStringExtraction() {
		registers.A0 = 0x08900000;

		memoryStream.position = registers.A0;
		memoryStream.writef("Hello World!\0");
		
		assertEquals("Hello World!", hleModuleMethodParamParsing.getNextParameter!string);
	}

	void testResetNextParameter() {
		registers.A0 = 0x08900000;
		registers.A1 = -1;

		foreach (n; 0..2) {
			hleModuleMethodParamParsing.resetNextParameter();
			assertEquals(registers.A0, hleModuleMethodParamParsing.getNextParameter!uint);
			assertEquals(registers.A1, hleModuleMethodParamParsing.getNextParameter!uint);
		}
	}

	void testGetParameterDoesnotMoveCursor() {
		registers.A0 = 0x08900000;
		registers.A1 = -1;
		
		assertEquals(registers.A1, hleModuleMethodParamParsing.getParameter!int(1));
		assertEquals(registers.A0, hleModuleMethodParamParsing.getNextParameter!uint);
	}
		
	void testLongAlignment() {
		registers.R[4 + 0] = 11;
		registers.R[4 + 1] = 33;
		*cast(long *)&registers.R[4 + 2] = -2;
		assertEquals(11, hleModuleMethodParamParsing.getNextParameter!uint);
		assertEquals(-2, hleModuleMethodParamParsing.getNextParameter!long);
	}
}