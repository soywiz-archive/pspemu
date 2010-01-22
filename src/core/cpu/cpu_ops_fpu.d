module pspemu.core.cpu.cpu_ops_fpu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.cpu.cpu_utils;
import pspemu.core.memory;

import std.stdio;
import std.traits;
import std.math;

template TemplateCpu_FPU() {
	// ABSolute Single.
	void OP_ABS_S() { mixin(CpuExpression("$fd = fabs($fs);")); }

	// ADD Single.
	void OP_ADD_S() { mixin(CpuExpression("$fd = $fs + $ft;")); }

	// Floating Point Ceiling Convert to Word Fixed Point
	void OP_CEIL_W_S () { mixin(CpuExpression("$Fd = cast(int)ceil($fs);")); }
	void OP_FLOOR_W_S() { mixin(CpuExpression("$Fd = cast(int)($fs);")); }
	void OP_ROUND_W_S() { mixin(CpuExpression("$Fd = cast(int)round($fs);")); }

	void OP_CVT_W_S() {
		// From: http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/Allegrex.isa
		switch (registers.FCSR) {
			default:
			case Registers.Fcsr.Rint : mixin(CpuExpression("$Fd = cast(int)rint($fs);"));  break;
			case Registers.Fcsr.Cast : mixin(CpuExpression("$Fd = cast(int)($fs);"));      break;
			case Registers.Fcsr.Ceil : mixin(CpuExpression("$Fd = cast(int)ceil($fs);"));  break;
			case Registers.Fcsr.Floor: mixin(CpuExpression("$Fd = cast(int)floor($fs);")); break;
		}
	}

	void OP_LWC1() { mixin(CpuExpression("$Ft = memory.read32($rs + $im);")); }
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