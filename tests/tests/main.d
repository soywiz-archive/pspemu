module tests.main;

import std.stdio;
import tests.TestsRunner;

import pspemu.hle.HleFunctionAttributeTest;

version (ALL_TESTS) {
	import pspemu.hle.kd.wlan.sceWlanTest;

	import gdb.GdbServerTest;
	import jit.EmmiterTest;
	import jit.EmmiterX86Test;
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

int main(string[] args) {
	TestsRunner.runRegisteredTests();

	return 0;
}