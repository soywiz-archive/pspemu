module pspemu.core.cpu.cpu_ops_fpu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.cpu.cpu_utils;
import pspemu.core.memory;

import std.stdio;
import std.traits;
import std.math : fabs;

template TemplateCpu_FPU() {
	// ABSolute Single.
	void OP_ABS_S() { mixin(CpuExpression("$fd = fabs($fs);")); }

	// ADD Single.
	void OP_ADD_S() { mixin(CpuExpression("$fd = $fs + $ft;")); }
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope memory    = new Memory;
	scope registers = new Registers;
	Instruction instruction = void;

	mixin TemplateCpu_FPU;
	
	// ABS.S
	{
		registers.F[1] = -5.0;
		instruction.FS = 1;
		instruction.FD = 0;
		OP_ABS_S();
		assert(registers.F[0] == 5.0);
	}
}