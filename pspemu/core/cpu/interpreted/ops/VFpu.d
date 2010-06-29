module pspemu.core.cpu.interpreted.ops.VFpu;
import pspemu.core.cpu.interpreted.Utils;

import std.math;

// http://forums.ps2dev.org/viewtopic.php?t=6929 
// http://wiki.fx-world.org/doku.php?do=index
// http://mrmrice.fx-world.org/vfpu.html
/**
 * Before you begin messing with the vfpu, you need to do one thing in your project:
 * PSP_MAIN_THREAD_ATTR(PSP_THREAD_ATTR_VFPU);
 * Almost all psp applications define this in the projects main c file. It sets a value that tells the psp how to handle your applications thread
 * in case the kernel needs to switch to another thread and back to yours. You need to add PSP_THREAD_ATTR_VFPU to this so the psp's kernel will
 * properly save/restore the vfpu state on thread switch, otherwise bad things might happen if another thread uses the vfpu and stomps on whatever was in there.
 *
 * Before diving into the more exciting bits, first you need to know how the VFPU registers are configured.
 * The vfpu contains 128 32-bit floating point registers (same format as the float type in C).
 * These registers can be accessed individually or in groups of 2, 3, 4, 9 or 16 in one instruction.
 * They are organized as 8 blocks of registers, 16 per block.When you write code to access these registers, there is a naming convention you must use.
 * 
 * Every register name has 4 characters: Xbcr
 * 
 * X can be one of:
 *   M - this identifies a matrix block of 4, 9 or 16 registers
 *   E - this identifies a transposed matrix block of 4, 9 or 16 registers
 *   C - this identifies a column of 2, 3 or 4 registers
 *   R - this identifies a row of 2, 3, or 4 registers
 *   S - this identifies a single register
 *
 * b can be one of:
 *   0 - register block 0
 *   1 - register block 1
 *   2 - register block 2
 *   3 - register block 3
 *   4 - register block 4
 *   5 - register block 5
 *   6 - register block 6
 *   7 - register block 7
 *
 * c can be one of:
 *   0 - column 0
 *   1 - column 1
 *   2 - column 2
 *   3 - column 3
 *
 * r can be one of:
 *   0 - row 0
 *   1 - row 1
 *   2 - row 2
 *   3 - row 3
 *
 * So for example, the register name S132 would be a single register in column 3, row 2 in register block 1.
 * M500 would be a matrix of registers in register block 5.
 *
 * Almost every vfpu instruction will end with one of the following extensions:
 *   .s - instruction works on a single register
 *   .p - instruction works on a 2 register vector or 2x2 matrix
 *   .t - instruction works on a 3 register vector or 3x3 matrix
 *   .q - instruction works on a 4 register vector or 4x4 matrix
 * 
 * http://wiki.fx-world.org/doku.php?id=general:vfpu_registers
 *
 * This is something you need to know about how to transfer data in or out of the vfpu. First lets show the instructions used to load/store data from the vfpu:
 *   lv.s (load 1 vfpu reg from unaligned memory)
 *   lv.q (load 4 vfpu regs from 16 byte aligned memory)
 *   sv.s (write 1 vfpu reg to unaligned memory)
 *   sv.q (write 4 vfpu regs to 16 byte aligned memory)
 *
 * There are limitations with these instructions. You can only transfer to or from column or row registers in the vfpu.
 *
 * You can also load values into the vfpu from a MIPS register, this will work with all single registers:
 *   mtv (move MIPS register to vfpu register)
 *   mfv (move from vfpu register to MIPS register)
 *
 * There are 2 instructions, ulv.q and usv.q, that perform unaligned ran transfers to/from the vfpu. These have been found to be faulty so it is not recommended to use them.
 *
 * The vfpu performs a few trig functions, but they dont behave like the normal C functions we are used to.
 * Normally we would pass in the angle in radians from -pi/2 to +pi/2, but the vfpu wants the input value in the range of -1 to 1.
 *
 * vcst.[s | p | t | q] vd, VFPU_CST
 * vd = vfpu_constant[VFPU_CST], where VFPU_CST is one of:
 *   VFPU_HUGE      infinity
 *   VFPU_SQRT2     sqrt(2)
 *   VFPU_SQRT1_2   sqrt(1/2)
 *   VFPU_2_SQRTPI  2/sqrt(pi)
 *   VFPU_PI        pi
 *   VFPU_2_PI      2/pi
 *   VFPU_1_PI      1/pi
 *   VFPU_PI_4      pi/4
 *   VFPU_PI_2      pi/2
 *   VFPU_E         e
 *   VFPU_LOG2E     log2(e)
 *   VFPU_LOG10E    log10(e)
 *   VFPU_LN2       ln(2)
 *   VFPU_LN10      ln(10)
 *   VFPU_2PI       2*pi
 *   VFPU_PI_6      pi/6
 *   VFPU_LOG10TWO  log10(2)
 *   VFPU_LOG2TEN   log2(10)
 *   VFPU_SQRT3_2   sqrt(3)/2
**/
template TemplateCpu_VFPU() {
	// http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/Allegrex/Common.java?spec=svn819&r=819
	// http://code.google.com/p/pspe4all/source/browse/trunk/emulator/allegrex.cpp
	// S, P, T, Q
	
	mixin TemplateCpu_VFPU_Utils;
	
	const float[] vfpu_constant = [
		0.0f,                                       /// VFPU_ZERO     - 0
		float.infinity,                             /// VFPU_HUGE     - infinity
		cast(float)(SQRT2),                         /// VFPU_SQRT2    - sqrt(2)
		cast(float)(SQRT1_2),                       /// VFPU_SQRT1_2  - sqrt(1 / 2)
		cast(float)(M_2_SQRTPI),                    /// VFPU_2_SQRTPI - 2 / sqrt(pi)
		cast(float)(M_2_PI),                        /// VFPU_2_PI     - 2 / pi
		cast(float)(M_1_PI),                        /// VFPU_1_PI     - 1 / pi
		cast(float)(PI_4),                          /// VFPU_PI_4     - pi / 4
		cast(float)(PI_2),                          /// VFPU_PI_2     - pi / 2
		cast(float)(PI),                            /// VFPU_PI       - pi
		cast(float)(E),                             /// VFPU_E        - e
		cast(float)(LOG2E),                         /// VFPU_LOG2E    - log2(E) = log(E) / log(2)
		cast(float)(LOG10E),                        /// VFPU_LOG10E   - log10(E)
		cast(float)(LN2),                           /// VFPU_LN2      - ln(2)
		cast(float)(LN10),                          /// VFPU_LN2      - ln(10)
		cast(float)(2.0 * PI),                      /// VFPU_2PI      - 2 * pi
		cast(float)(PI / 6.0),                      /// VFPU_PI_6     - pi / 6
		cast(float)(LOG2),                          /// VFPU_LOG10TWO - log10(2)
		cast(float)(LOG2T),                         /// VFPU_LOG2TEN  - log2(10) = log(10) / log(2)
		cast(float)(sqrt(3.0) / 2.0)                /// VFPU_SQRT3_2  - sqrt(3) / 2
	];
	
	void OP_VCST() {
		auto vsize = instruction.ONE_TWO;
        float constant = 0.0f;
		auto row_d = vfpuVectorPointer(vsize, instruction.VD);

        if (instruction.IMM5 >= 0 && instruction.IMM5 < vfpu_constant.length) {
            constant = vfpu_constant[instruction.IMM5];
        }

        for (int n = 0; n < vsize; n++) *row_d[n] = constant;
		registers.pcAdvance(4);
	}

	void OP_VIDT_x(int vsize, int vd) {
		auto row_d = vfpuVectorPointer(vsize, vd);
		int id = vd & 3;
		//writef("%d(%d):", vd, vsize);
		for (int n = 0; n < vsize; n++) {
			*row_d[n] = (n == id) ? 1.0f : 0.0f;
			//writef("%f,", *row_d[n]);
		}
		//writef(": %s", row_d);
		//writefln("");
	}
	
	// Vector Matrix IDenTity quad aligned?
	// VMIDT(111100:111:00:00011:two:0000000:one:vd)
	void OP_VMIDT() {
		auto vsize = instruction.ONE_TWO;
		int vd = instruction.VD;
		for (int n = 0; n < vsize; n++) OP_VIDT_x(vsize, vd + n);
		//writefln("%s", cpu.registers.VF);
		registers.pcAdvance(4);
	}

	// Vector IDenTity quad aligned?
	void OP_VIDT() {
		auto vsize = instruction.ONE_TWO;
		OP_VIDT_x(vsize, instruction.VD);
		registers.pcAdvance(4);
	}

	// Vfpu load Integer IMmediate
	void OP_VIIM() {
		*vfpuVectorPointer(1, instruction.VD)[0] = cast(float)instruction.IMM;
		registers.pcAdvance(4);
	}
	
	// Load 4 Vfpu (Quad) regs from 16 byte aligned memory
	// LVQ(110110:rs:vt5:imm14:0:vt1)
	void OP_LV_Q() {
		//writefln("OP_LV_Q: %032b : %d, %d", instruction.v, instruction.VT5, instruction.VT1);
	
		auto row = vfpuVectorPointer2(4, instruction.VT5, instruction.VT1);
		uint address = cpu.registers.R[instruction.RS] + instruction.IMM14 * 4;
		
		for (int n = 0; n < 4; n++) {
			*row[n] = cpu.memory.tread!(float)(address + n * 4);
			//writefln("LV: %f", *row[n]);
		}
		
		registers.pcAdvance(4);
	}
	void OP_LVL_Q() {
		int vt = instruction.VT5;
        int m  = (vt >> 2) & 7;
        int i  = (vt >> 0) & 3;

		uint address = cpu.registers.R[instruction.RS] + instruction.IMM14 * 4 - 12;
		int k = 4 - ((address >> 2) & 3);
		
        if ((vt & 32) != 0) {
            for (int j = 0; j < k; ++j) {
                cpu.registers.VF_CELLS[m][j][i] = cpu.memory.tread!(float)(address);
				address += 4;
            }
        } else {
            for (int j = 0; j < k; ++j) {
                cpu.registers.VF_CELLS[m][i][j] = cpu.memory.tread!(float)(address);
				address += 4;
            }
        }

		//Logger.log(Logger.Level.WARNING, "Vfpu", "LVL.Q");
		registers.pcAdvance(4);
	}

	void OP_LVR_Q() {
		int vt = instruction.VT5;
        int m = (vt >> 2) & 7;
        int i = (vt >> 0) & 3;

        uint address = cpu.registers.R[instruction.RS] + instruction.IMM14 * 4;
        int k = (address >> 2) & 3;
        address += (4 - k) << 2;

        if ((vt & 32) != 0) {
            for (int j = 4 - k; j < 4; ++j) {
                cpu.registers.VF_CELLS[m][j][i] = cpu.memory.tread!(float)(address);
				address += 4;
            }
        } else {
            for (int j = 4 - k; j < 4; ++j) {
                cpu.registers.VF_CELLS[m][i][j] = cpu.memory.tread!(float)(address);
				address += 4;
            }
        }

		registers.pcAdvance(4);
	}

	// Store 4 Vfpu (Quad) regs from 16 byte aligned memory
	// SVQ(111110:rs:vt5:imm14:0:vt1)
	void OP_SV_Q() {
		auto row = vfpuVectorPointer2(4, instruction.VT5, instruction.VT1);
		uint address = cpu.registers.R[instruction.RS] + instruction.IMM14 * 4;
		
		for (int n = 0; n < 4; n++) {
			cpu.memory.twrite!(float)(address + n * 4, *row[n]);
			//writefln("SV: %f", *row[n]);
		}
		registers.pcAdvance(4);
	}

	// Vfpu Dot
	// VDOT(011001:001:vt:two:vs:one:vd)
	// VDOT.Q(011001:001:vt:1:vs:1:vd)
	// VDOT.T(011001:001:vt:1:vs:0:vd)
	// VDOT.P(011001:001:vt:0:vs:1:vd)
	// 011001:001:0001000:1:0000100:1:0000000
	void OP_VDOT() {
		auto vsize = instruction.ONE_TWO;
		if (vsize == 1) OP_UNK();
		
		//writefln("%032b", instruction.v);
		//writefln("vsize:%d", vsize);
		auto row_t = vfpuVectorPointer(vsize, instruction.VT);
		auto row_s = vfpuVectorPointer(vsize, instruction.VS);
		auto row_d = vfpuVectorPointer(1,    instruction.VD);
		*row_d[0] = 0.0;
		//writefln("%s", cpu.registers.VF);
		for (int n = 0; n < vsize; n++) {
			//writefln("%f * %f", *row_s[n], *row_t[n]);
			*row_d[0] += (*row_s[n]) * (*row_t[n]);
		}
		
		registers.pcAdvance(4);
	}

	// Move From Vfpu (C?)
	// MFV(010010:00:011:rt:0:0000000:0:imm7)
	void OP_MFV() {
		cpu.registers.R[instruction.RT] = F_I(cpu.registers.VF[instruction.IMM7]);
		registers.pcAdvance(4);
	}
	void OP_MFVC() {
		assert(0, "Unimplemented");
	}

	// Move To Vfpu (C?)
	// MTV(010010:00:111:rt:0:0000000:0:imm7)
	void OP_MTV() {
		cpu.registers.VF[instruction.IMM7] = I_F(cpu.registers.R[instruction.RT]);
		registers.pcAdvance(4);
	}
	void OP_MTVC() {
		assert(0, "Unimplemented");
	}
	
	// Vfpu SCaLe
	// VSCL(011001:010:vt:two:vs:one:vd)
	void OP_VSCL() {
		auto vsize = instruction.ONE_TWO;
		if (vsize == 1) OP_UNK();

		auto row_s = vfpuVectorPointer(vsize, instruction.VS);
		auto row_t = vfpuVectorPointer(1    , instruction.VT);
		auto row_d = vfpuVectorPointer(vsize, instruction.VD);
		auto scale = *row_t[0];
		for (int n = 0; n < vsize; n++) {
			*row_d[n] = *row_s[n] * scale;
		}
		registers.pcAdvance(4);
	}

	void OP_V_INTERNAL_IN_N(int N, string op)() {
		static assert((N >= 0) && (N <= 2));
		auto vsize = instruction.ONE_TWO;
		static if (N >= 1) auto row_s = vfpuVectorPointer(vsize, instruction.VS);
		static if (N >= 2) auto row_t = vfpuVectorPointer(vsize, instruction.VT);
		auto row_d = vfpuVectorPointer(vsize, instruction.VD);
		for (int n = 0; n < vsize; n++) {
			static if (N >= 1) { float l = *row_s[n]; alias l v; }
			static if (N >= 2) { float r = *row_t[n]; }
			mixin("*row_d[n] = (" ~ op ~ ");");
		}
		registers.pcAdvance(4);
	}

	// Vfpu ONE
	void OP_VONE()  { OP_V_INTERNAL_IN_N!(0, "1.0f"); }
	
	// Vfpu ABSolute/COSine/MOVe/Reverse SQuare root/LOG2/EXP2/NEGate/ReCiProcal
	void OP_VMOV()  { OP_V_INTERNAL_IN_N!(1, "v"); }
	void OP_VSGN()  { OP_V_INTERNAL_IN_N!(1, "sign(v)"); }
	void OP_VABS()  { OP_V_INTERNAL_IN_N!(1, "abs(v)"); }
	void OP_VCOS()  { OP_V_INTERNAL_IN_N!(1, "cos(PI_2 * v)"); }
	void OP_VASIN() { OP_V_INTERNAL_IN_N!(1, "asin(v) * M_2_PI"); }
	void OP_VRSQ()  { OP_V_INTERNAL_IN_N!(1, "1.0f / sqrt(v)"); }
	void OP_VLOG2() { OP_V_INTERNAL_IN_N!(1, "log2(v)"); }
	void OP_VEXP2() { OP_V_INTERNAL_IN_N!(1, "exp2(v)"); }
	void OP_VNEG()  { OP_V_INTERNAL_IN_N!(1, "-v"); }
	void OP_VRCP()  { OP_V_INTERNAL_IN_N!(1, "1.0f / v"); }

	// Vfpu MINimum/MAXimum/ADD
	void OP_VMIN() { OP_V_INTERNAL_IN_N!(2, "min(l, r)"); }
	void OP_VMAX() { OP_V_INTERNAL_IN_N!(2, "max(l, r)"); }
	void OP_VADD() { OP_V_INTERNAL_IN_N!(2, "l + r"); }
	void OP_VSUB() { OP_V_INTERNAL_IN_N!(2, "l - r"); }
	void OP_VDIV() { OP_V_INTERNAL_IN_N!(2, "l / r"); }
	void OP_VMUL() { OP_V_INTERNAL_IN_N!(2, "l * r"); }
	
	// Vfpu ??
	void OP_VHDP() {
		auto vsize = instruction.ONE_TWO;
		if (vsize == 1) OP_UNK();
		
		//writefln("%032b", instruction.v);
		//writefln("vsize:%d", vsize);
		auto row_t = vfpuVectorPointer(vsize, instruction.VT);
		auto row_s = vfpuVectorPointer(vsize, instruction.VS);
		auto row_d = vfpuVectorPointer(1,    instruction.VD);
		row_s[vsize - 1] = &vfpu_one;
		*row_d[0] = 0.0;
		//writefln("%s", cpu.registers.VF);
		for (int n = 0; n < vsize; n++) {
			//writefln("%f * %f", *row_s[n], *row_t[n]);
			*row_d[0] += (*row_s[n]) * (*row_t[n]);
		}
		
		registers.pcAdvance(4);
	}
	
	void OP_VCRSP_T() {
		auto row_s = vfpuVectorPointer(3, instruction.VS);
		auto row_t = vfpuVectorPointer(3, instruction.VT);
		auto row_d = vfpuVectorPointer(3, instruction.VD);

		*row_d[0] = +*row_s[1] * *row_t[2] - *row_s[2] * *row_t[1];
		*row_d[1] = +*row_s[2] * *row_t[0] - *row_s[0] * *row_t[2];
		*row_d[2] = +*row_s[0] * *row_t[1] - *row_s[1] * *row_t[0];
		
		registers.pcAdvance(4);
	}

	void OP_VI2C() {
		// auto vsize = instruction.ONE_TWO;
		auto row_s = vfpuVectorPointer!(ubyte[4])(4, instruction.VS);
		auto row_d = vfpuVectorPointer!(ubyte[4])(1, instruction.VD);
		for (int n = 0; n < 4; n++) {
			//writefln("%s", *row_s[n]);
			(*row_d[0])[n] = (*row_s[n])[3];
		}
		registers.pcAdvance(4);
	}

	void OP_VI2UC() {
		// auto vsize = instruction.ONE_TWO;
		auto row_s = vfpuVectorPointer!(int)(4, instruction.VS);
		auto row_d = vfpuVectorPointer!(ubyte[4])(1, instruction.VD);
		for (int n = 0; n < 4; n++) {
			int value = *row_s[n];
			//writefln("%s", *row_s[n]);
			(*row_d[0])[n] = cast(ubyte)((value < 0) ? 0 : (value >> 23));
		}
		registers.pcAdvance(4);
	}
	
	void OP_VTFM_X(int vsize, bool half)() {
		auto row_t = vfpuVectorPointer(vsize - cast(int)half, instruction.VT);
		float*[4] row_s;
		auto row_d = vfpuVectorPointer(vsize, instruction.VD);
		if (half) row_t[vsize - 1] = &vfpu_one;
		
		for (int n = 0; n < vsize; n++) {
			row_s = vfpuVectorPointer(vsize, instruction.VS + n);
			*row_d[n] = summult_ptr(row_s[0..vsize], row_t[0..vsize]);
		}
		registers.pcAdvance(4);
	}

	void OP_VTFM2() { OP_VTFM_X!(2, false)(); }
	void OP_VTFM3() { OP_VTFM_X!(3, false)(); }
	void OP_VTFM4() { OP_VTFM_X!(4, false)(); }

	void OP_VHTFM2() { OP_VTFM_X!(2, true)(); }
	void OP_VHTFM3() { OP_VTFM_X!(3, true)(); }
	void OP_VHTFM4() { OP_VTFM_X!(4, true)(); }
	
	void OP_VMMUL() {
		auto vsize = instruction.ONE_TWO;
		if (vsize == 1) OP_UNK();

        for (int i = 0; i < vsize; ++i) {
			auto row_t = vfpuVectorPointer(vsize, instruction.VT + i);
			auto row_d = vfpuVectorPointer(vsize, instruction.VD + i);
            for (int j = 0; j < vsize; ++j) {
				auto row_s = vfpuVectorPointer(vsize, instruction.VS + j);
				*row_d[j] = summult_ptr(row_s[0..vsize], row_t[0..vsize]);
            }
        }
		registers.pcAdvance(4);
	}

    void OP_VSRT3() {
		registers.pcAdvance(4);

		auto vsize = instruction.ONE_TWO;
        if (vsize != 4) {
			Logger.log(Logger.Level.WARNING, "Vfpu", "Only supported VSRT3.Q (vsize=%d)", vsize);
			// The instruction is somehow supported on the PSP (see VfpuTest),
			// but leave the error message here to help debugging the Decoder.
			return;
        }

		auto row_s = vfpuVectorPointer(4, instruction.VS);
		auto row_d = vfpuVectorPointer(4, instruction.VD);
        float x = *row_s[0], y = *row_s[1];
        float z = *row_s[2], w = *row_s[3];
        *row_d[0] = max(x, y);
        *row_d[1] = min(x, y);
        *row_d[2] = max(z, w);
        *row_d[3] = min(z, w);
    }
}

template TemplateCpu_VFPU_Utils() {
	float vfpu_dummy_address;
	float vfpu_one = 1.0;

	T*[4] vfpuVectorPointer(T = float)(uint vsize, uint vs, bool readonly = false) {
		T*[4] vector;
		uint line   = (vs >> 0) & 3; // 0-3
		uint matrix = (vs >> 2) & 7; // 0-7
		uint offset = void;
		bool order  = void;

		if (vsize == 1) {
			offset = (vs >> 5) & 3;
			order  = false;
		} else {
			offset = (vs & 64) >> (3 + vsize);
			order = ((vs & 32) != 0);
		}
		
		//writefln("SIZE:%d, DATA:%08b, ORDER:%d, MATRIX:%d, OFFSET:%d, LINE:%d", vsize, vs, order, matrix, offset, line);

		//writefln("vfpuVectorPointer(%d, %d, %d) : matrix(%d) line(%d) order(%d)", vsize, vs, readonly, matrix, line, order);

		if (order) {
			for (int n = 0; n < vsize; n++) vector[n] = cast(T*)&cpu.registers.VF_CELLS[matrix][offset + n][line];
		} else {
			for (int n = 0; n < vsize; n++) vector[n] = cast(T*)&cpu.registers.VF_CELLS[matrix][line][offset + n];
		}

		// @TODO: Implement prefixes.
		/*if (prefix) {
			// if (readonly) &vfpu_dummy_address
		}*/
		
		return vector;
	}
	
	T*[4] vfpuVectorPointer2(T = float)(uint vsize, uint v5, uint v1) {
		return vfpuVectorPointer!(T)(vsize, v5 | (v1 << 5));
	}

	T summult_ptr(T)(T*[] a, T*[] b) {
		assert(a.length);
		T result = 0;
		for (int n = 0; n < a.length; n++) result += *a[n] * *b[n];
		return result;
	}
}