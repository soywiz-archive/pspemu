module tests.main;

import std.stdio;
import tests.TestsRunner;



version(ALL_TESTS) {
	import pspemu.hle.HleModuleMethodBridgeGeneratorTest;
	import pspemu.hle.HleFunctionAttributeTest;
	import pspemu.hle.HleModuleMethodParamParsingTest;
	import pspemu.hle.HleThreadTest;
	import pspemu.hle.HleThreadManagerTest;
	import pspemu.hle.elf.ElfTest;
	import pspemu.hle.HleMemoryManagerTest;
	import pspemu.hle.elf.HleElfLoaderTest;
	import pspemu.core.cpu.assembler.CpuAssemblerTest;
	import pspemu.core.cpu.assembler.CpuDisassemblerTest;
	import pspemu.core.cpu.RegistersTest;
	import pspemu.core.cpu.tables.SwitchGenTest;
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

string testSuiteCurrent() { return q{
	
}; }

version(ALL_TESTS) {
	string testSuiteAll() { return q{
		TestsRunner.run(new HleModuleMethodBridgeGeneratorTest);
		TestsRunner.run(new HleFunctionAttributeTest);
		TestsRunner.run(new HleModuleMethodParamParsingTest);
		TestsRunner.run(new HleThreadTest);
		TestsRunner.run(new HleThreadManagerTest);
		TestsRunner.run(new ElfTest);
		TestsRunner.run(new HleMemoryManagerTest);
		TestsRunner.run(new HleElfLoaderTest());
		TestsRunner.run(new CpuAssemblerTest);
		TestsRunner.run(new CpuDisassemblerTest);
		TestsRunner.run(new CpuInterpreterTest);
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
	}; }
}

int main(string[] args) {
	version (ALL_TESTS) {
		TestsRunner.suite({
			mixin(testSuiteCurrent);
			mixin(testSuiteAll);
		});
	} else {
		mixin(testSuiteCurrent);
	}

	return 0;
}