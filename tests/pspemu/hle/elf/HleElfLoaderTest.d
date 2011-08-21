module pspemu.hle.elf.HleElfLoaderTest;

import pspemu.hle.elf.Elf;
import pspemu.hle.elf.HleElfLoader;
import pspemu.hle.HleMemoryManager;

import pspemu.core.Memory;

import std.stream;

import tests.Test;

class HleElfLoaderTest : Test {
	mixin TRegisterTest;
	
	ubyte[] elfData;
	Stream elfStream;
	Elf elf;
	Memory memory;
	HleMemoryManager hleMemoryManager;
	HleElfLoader hleElfLoader;
	
	this() {
		elfData = cast(ubyte[])std.file.read("../import/tests/test.elf");
	}
	
	void setUp() {
		memory = new Memory();
		hleElfLoader = new HleElfLoader(
			elf = new Elf(elfStream = new MemoryStream(elfData)),
			hleMemoryManager = new HleMemoryManager(memory),
		);
	}
	
	void tearDown() {
		elfStream.close();
	}

	void testLoadWithoutRelocation() {
		hleElfLoader.writeToMemory(new PspMemoryStream(memory));
		assertEquals(false, elf.needsRelocation);
		assertEquals(0x00000000, hleElfLoader.relocationAddress);
		
		auto dataInFile   = elfData[0x1000..0x1000 + 0xC97C];
		auto dataInMemory = memory[0x08900000..0x08900000 + 0xC97C];
		
		assertTrue(dataInFile == dataInMemory);
		
		//std.file.write("memory.dump", memory.mainMemory);
	}
	
	void testLoadWithRelocation() {
		
	}
	
	void testLoadWithSeveralProgramHeaders() {
		
	}
}