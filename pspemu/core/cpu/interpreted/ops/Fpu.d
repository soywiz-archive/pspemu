module pspemu.core.cpu.interpreted.ops.Fpu;

import pspemu.All;

import pspemu.core.cpu.interpreted.ops.Branch;

template TemplateCpu_FPU() {
	// Branch.
	static pure nothrow string BRANCH_S(Likely likely, string condition) { return BRANCH(likely, Link.NO, condition); }
	auto OP_BC1F () { mixin(BRANCH_S(Likely.NO,  "!registers.FCR31.C")); }
	auto OP_BC1FL() { mixin(BRANCH_S(Likely.YES, "!registers.FCR31.C")); }
	auto OP_BC1T () { mixin(BRANCH_S(Likely.NO,  "registers.FCR31.C")); }
	auto OP_BC1TL() { mixin(BRANCH_S(Likely.YES, "registers.FCR31.C")); }
	
	// Unary operations.
	auto OP_MOV_S()  { mixin(CE("$fd = $fs;")); }
	auto OP_ABS_S()  { mixin(CE("$fd = fabs($fs);")); }
	auto OP_NEG_S()  { mixin(CE("$fd = -($fs);")); }
	auto OP_SQRT_S() { mixin(CE("$fd = sqrt($fs);")); }

	// Binary operations.
	auto OP_ADD_S() { mixin(CE("$fd = $fs + $ft;")); }
	auto OP_SUB_S() { mixin(CE("$fd = $fs - $ft;")); }
	auto OP_MUL_S() { mixin(CE("$fd = $fs * $ft;")); }
	auto OP_DIV_S() { mixin(CE("$fd = $fs / $ft;")); }

	// CC ops
	// Based on: http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/Allegrex/FpuState.java
	string COND_S(int fc02, int fc3) {
		string r;

		bool fc_unordererd = ((fc02 & 1) != 0);
		bool fc_equal      = ((fc02 & 2) != 0);
		bool fc_less       = ((fc02 & 4) != 0);
		bool fc_inv_qnan   = (fc3 != 0); // @TODO? -- Only used for detecting invalid operations?
		
		r ~= "auto s = $fs;";
		r ~= "auto t = $ft;";
		r ~= "if (isnan(s) || isnan(t)) {";
			r ~= "$cc = " ~ (fc_unordererd ? "true" : "false") ~ ";";
		r ~= "} else {";
			r ~= "$cc = false";
			if (fc_equal) r ~= " || (s == t)";
			if (fc_less ) r ~= " || (s <  t)";
			r ~= ";";
		r ~= "}";

		return CE(r);
	}
	
	auto OP_C_F_S()    { mixin(COND_S(0, 0)); }
	auto OP_C_UN_S()   { mixin(COND_S(1, 0)); }
	auto OP_C_EQ_S()   { mixin(COND_S(2, 0)); }
	auto OP_C_UEQ_S()  { mixin(COND_S(3, 0)); }
	auto OP_C_OLT_S()  { mixin(COND_S(4, 0)); }
	auto OP_C_ULT_S()  { mixin(COND_S(5, 0)); }
	auto OP_C_OLE_S()  { mixin(COND_S(6, 0)); }
	auto OP_C_ULE_S()  { mixin(COND_S(7, 0)); }
	auto OP_C_SF_S()   { mixin(COND_S(0, 1)); }
	auto OP_C_NGLE_S() { mixin(COND_S(1, 1)); }
	auto OP_C_SEQ_S()  { mixin(COND_S(2, 1)); }
	auto OP_C_NGL_S()  { mixin(COND_S(3, 1)); }
	auto OP_C_LT_S()   { mixin(COND_S(4, 1)); }
	auto OP_C_NGE_S()  { mixin(COND_S(5, 1)); }
	auto OP_C_LE_S()   { mixin(COND_S(6, 1)); }
	auto OP_C_NGT_S()  { mixin(COND_S(7, 1)); }

	// http://jpcsp.googlecode.com/svn/trunk/src/jpcsp/Allegrex/FpuState.java
	// http://pspemu.googlecode.com/svn/branches/old/libdoc/MipsInstructionSetReference.pdf
	// CFC1 -- move Control word from/to floating point (C1)
	auto OP_CFC1() {
		switch (instruction.RD) {
			case  0: mixin(CE("$rt = $00;")); break; // readonly?
			case 31: mixin(CE("$rt = $31;")); break;
			default: throw(new Exception(std.string.format("Unsupported CFC1(%d)", instruction.RD)));
		}
	}
	auto OP_CTC1() {
		switch (instruction.RD) {
			case 31: mixin(CE("$31 = $rt;")); break;
			default: throw(new Exception(std.string.format("Unsupported CTC1(%d)", instruction.RD)));
		}
	}

	// MTC1 -- Move word To/From floating point (C1)
	auto OP_MTC1() { mixin(CE("$Fs = cast(float)$rt;")); }
	auto OP_MFC1() { mixin(CE("$rt = cast(int  )$Fs;")); }
	
	// Floating Point Ceiling Convert to Word Fixed Point
	auto OP_CEIL_W_S () { mixin(CE("$Fd = cast(int)ceil($fs);")); }
	auto OP_FLOOR_W_S() { mixin(CE("$Fd = cast(int)($fs);")); }
	auto OP_ROUND_W_S() { mixin(CE("$Fd = cast(int)round($fs);")); }
	auto OP_TRUNC_W_S() { mixin(CE("$Fd = cast(int)($fs);")); }

	auto OP_CVT_W_S() {
		// From: http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/Allegrex.isa
		// enum Fcsr { Rint = 0, Cast = 1, Ceil = 2, Floor = 3 }
		switch (registers.FCR31.RM) {
			//default:
			case Registers.Fcr31.Type.Rint : mixin(CE("$Fd = cast(int)rint($fs);"));  break;
			case Registers.Fcr31.Type.Cast : mixin(CE("$Fd = cast(int)($fs);"));      break;
			case Registers.Fcr31.Type.Ceil : mixin(CE("$Fd = cast(int)ceil($fs);")); break;
			case Registers.Fcr31.Type.Floor: mixin(CE("$Fd = cast(int)floor($fs);")); break;
		}
	}

	// Convert FS register (stored as an int) to float and stores the result on FD.
	auto OP_CVT_S_W() { mixin(CE("$fd = cast(float)reinterpret!(int)($fs);")); }

	// Memory transfer.
	auto OP_LWC1() { mixin(CE("$Ft = memory.tread!(uint)($rs + #im);")); }
	auto OP_SWC1() { mixin(CE("memory.twrite!(uint)($rs + #im, $Ft);")); }
}
