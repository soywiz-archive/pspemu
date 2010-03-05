module pspemu.core.cpu.cpu_ops_fpu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.cpu.cpu_utils;
import pspemu.core.cpu.cpu_ops_branch;
import pspemu.core.memory;

import std.stdio;
import std.traits;
import std.math;

template TemplateCpu_FPU() {
	// Branch.
	static pure nothrow string BRANCH_S(Likely likely, string condition) { return BRANCH(likely, Link.NO, condition); }
	auto OP_BC1F () { mixin(BRANCH_S(Likely.NO,  "!registers.CC")); }
	auto OP_BC1FL() { mixin(BRANCH_S(Likely.YES, "!registers.CC")); }
	auto OP_BC1T () { mixin(BRANCH_S(Likely.NO,  "registers.CC")); }
	auto OP_BC1TL() { mixin(BRANCH_S(Likely.YES, "registers.CC")); }
	
	// Unary operations.
	auto OP_ABS_S()  { mixin(CE("$fd = fabs($fs);")); }
	auto OP_NEG_S()  { mixin(CE("$fd = -($fs);")); }
	auto OP_SQRT_S() { mixin(CE("$fd = sqrt($fs);")); }

	// Binary operations.
	auto OP_ADD_S() { mixin(CE("$fd = $fs + $ft;")); }
	auto OP_SUB_S() { mixin(CE("$fd = $fs - $ft;")); }
	auto OP_MUL_S() { mixin(CE("$fd = $fs * $ft;")); }
	auto OP_DIV_S() { mixin(CE("$fd = $fs / $ft;")); }

	// CC ops
	static const QNAN = "isnan($fs) || isnan($ft)";
	auto OP_C_F_S()   { mixin(CE("$cc = (false);")); }
	auto OP_C_UN_S()  { mixin(CE("$cc = (" ~ QNAN ~ ");")); }
	auto OP_C_EQ_S()  { mixin(CE("$cc = ($fs == $ft);")); }
	auto OP_C_UEQ_S() { mixin(CE("$cc = ($fs != $ft);")); }
	auto OP_C_LT_S()  { mixin(CE("$cc = ($fs <  $ft); if (" ~ QNAN ~ ") $cc = !$cc;")); }
	auto OP_C_LE_S()  { mixin(CE("$cc = ($fs <= $ft); if (" ~ QNAN ~ ") $cc = !$cc;")); }

	// http://jpcsp.googlecode.com/svn/trunk/src/jpcsp/Allegrex/FpuState.java
	// http://pspemu.googlecode.com/svn/branches/old/libdoc/MipsInstructionSetReference.pdf
	// CFC1 -- Move Control Word from/to Floating Point
	// FIXME! 
	auto OP_CFC1() { mixin(CE("$rt = cast(uint)$cc;")); }
	auto OP_CTC1() { mixin(CE("$cc = cast(bool)$rt;")); }

	// Floating Point Ceiling Convert to Word Fixed Point
	auto OP_CEIL_W_S () { mixin(CE("$Fd = cast(int)ceil($fs);")); }
	auto OP_FLOOR_W_S() { mixin(CE("$Fd = cast(int)($fs);")); }
	auto OP_ROUND_W_S() { mixin(CE("$Fd = cast(int)round($fs);")); }

	auto OP_CVT_W_S() {
		// From: http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/Allegrex.isa
		switch (registers.FCSR) {
			default:
			case Registers.Fcsr.Rint : mixin(CE("$Fd = cast(int)rint($fs);"));  break;
			case Registers.Fcsr.Cast : mixin(CE("$Fd = cast(int)($fs);"));      break;
			case Registers.Fcsr.Ceil : mixin(CE("$Fd = cast(int)ceil($fs);"));  break;
			case Registers.Fcsr.Floor: mixin(CE("$Fd = cast(int)floor($fs);")); break;
		}
	}

	// Memory transfer.
	auto OP_LWC1() { mixin(CE("$Ft = memory.read32($rs + #im);")); }
	auto OP_SWC1() { mixin(CE("memory.write32($rs + #im, $Ft);")); }
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