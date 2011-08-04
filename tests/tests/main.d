module tests.main;

import std.stdio;
import tests.TestsRunner;

import pspemu.utils.memory.MemoryPartitionTest;
import pspemu.core.cpu.RegistersTest;
import pspemu.core.cpu.tables.SwitchGenTest;
import pspemu.core.cpu.assembler.CpuAssemblerTest;

int main(string[] args) {
	//TestsRunner.run(new MemoryPartitionTest);
	//TestsRunner.run(new RegistersTest);
	//TestsRunner.run(new SwitchGenTest);
	TestsRunner.run(new CpuAssemblerTest);

	return 0;
}