module tests.main;

import std.stdio;
import tests.TestsRunner;

import pspemu.utils.memory.MemoryPartitionTest;
import pspemu.core.cpu.RegistersTest;
import pspemu.core.cpu.tables.SwitchGenTest;
import pspemu.core.cpu.assembler.CpuAssemblerTest;
import pspemu.core.crypto.KirkTest;
import pspemu.core.display.DisplayTest;
import pspemu.core.InterruptsTest;
import pspemu.core.audio.AudioTest;
import pspemu.core.cpu.interpreter.CpuInterpreterTest;

int main(string[] args) {
	TestsRunner.run(new CpuInterpreterTest);
	TestsRunner.run(new CpuAssemblerTest);
	TestsRunner.run(new MemoryPartitionTest);
	TestsRunner.run(new RegistersTest);
	TestsRunner.run(new SwitchGenTest);
	TestsRunner.run(new KirkTest);
	TestsRunner.run(new DisplayTest);
	TestsRunner.run(new InterruptsTest);
	TestsRunner.run(new AudioTest);

	return 0;
}