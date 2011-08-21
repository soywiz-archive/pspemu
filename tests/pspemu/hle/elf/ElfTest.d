module pspemu.hle.elf.ElfTest;

import pspemu.hle.elf.Elf;
import std.stream;

import tests.Test;

class ElfTest : Test {
	mixin TRegisterTest;
	
	Stream elfStream;
	Elf elf;
	
	void setUp() {
		elfStream = new std.stream.File("../import/tests/test.elf"); 
		elf = new Elf();
		elf.load(elfStream);
	}
	
	void tearDown() {
		elfStream.close();
	}
	
	void testLoad() {
		assertTrue((".rodata.sceModuleInfo" in elf.sectionHeadersNamed) !is null);
		//foreach (name, sectionHeader; elf.sectionHeadersNamed) writefln("%s", name);
	}
}