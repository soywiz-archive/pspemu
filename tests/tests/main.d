module tests.main;

import std.stdio;
import tests.TestsRunner;

import pspemu.hle.elf.ElfTest;
import pspemu.hle.HleMemoryManagerTest;
//import pspemu.hle.elf.HleElfLoaderTest;

version(ALL_TESTS) {
	import pspemu.core.cpu.assembler.CpuDisassemblerTest;
	//import pspemu.utils.memory.MemoryPartitionTest;
	import pspemu.core.cpu.RegistersTest;
	import pspemu.core.cpu.tables.SwitchGenTest;
	import pspemu.core.cpu.assembler.CpuAssemblerTest;
	import pspemu.core.crypto.KirkTest;
	import pspemu.core.display.DisplayTest;
	import pspemu.core.InterruptsTest;
	import pspemu.core.audio.AudioTest;
	import pspemu.core.cpu.interpreter.CpuInterpreterTest;
	import pspemu.core.gpu.GpuTest;
	import pspemu.core.battery.BatteryTest;
	import pspemu.core.controller.ControllerTest;
	import pspemu.hle.vfs.VirtualFileSystemTest;
	import pspemu.hle.vfs.ZipFileSystemTest;
}

void testSuiteCurrent() {
	TestsRunner.suite({
		TestsRunner.run(new ElfTest);
		TestsRunner.run(new HleMemoryManagerTest);
		//TestsRunner.run(new HleElfLoaderTest());
	});
}

version(ALL_TESTS) {
	void testSuiteAll() {
		TestsRunner.suite({
			TestsRunner.run(new ElfTest);
			TestsRunner.run(new CpuDisassemblerTest);
			TestsRunner.run(new CpuInterpreterTest);
			TestsRunner.run(new CpuAssemblerTest);
			//TestsRunner.run(new MemoryPartitionTest);
			TestsRunner.run(new RegistersTest);
			TestsRunner.run(new SwitchGenTest);
			TestsRunner.run(new KirkTest);
			TestsRunner.run(new DisplayTest);
			TestsRunner.run(new InterruptsTest);
			TestsRunner.run(new AudioTest);
			TestsRunner.run(new BatteryTest);
			TestsRunner.run(new ControllerTest);
			TestsRunner.run(new GpuTest);
			TestsRunner.run(new VirtualFileSystemTest);
			TestsRunner.run(new ZipFileSystemTest);
		});
	}
}

int main(string[] args) {
	version (ALL_TESTS) {
		testSuiteAll();
	} else {
		testSuiteCurrent();
	}

	return 0;
}