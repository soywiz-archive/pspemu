module pspemu.core.cpu.interpreted.ops.VFpu;
import pspemu.core.cpu.interpreted.Utils;

import std.math;

//debug = DEBUG_VFPU_I;

// http://forums.ps2dev.org/viewtopic.php?t=6929 
// http://wiki.fx-world.org/doku.php?do=index
// http://mrmrice.fx-world.org/vfpu.html
// http://hitmen.c02.at/files/yapspd/psp_doc/chap4.html
// pspgl_codegen.h
// 
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

/**
   The VFPU contains 32 registers (128bits each, 4x32bits).

   VFPU Registers can get accessed as Matrices, Vectors or single words.
   All registers are overlayed and enumerated in 3 digits (Matrix/Column/Row):

	M000 | C000   C010   C020   C030	M100 | C110   C110   C120   C130
	-----+--------------------------	-----+--------------------------
	R000 | S000   S010   S020   S030	R100 | S100   S110   S120   S130
	R001 | S001   S011   S021   S031	R101 | S101   S111   S121   S131
	R002 | S002   S012   S022   S032	R102 | S102   S112   S122   S132
	R003 | S003   S013   S023   S033	R103 | S103   S113   S123   S133

  same for matrices starting at M200 - M700.
  Subvectors can get addressed as singles/pairs/triplets/quads.
  Submatrices can get addressed 2x2 pairs, 3x3 triplets or 4x4 quads.

  So Q_C010 specifies the Quad Column starting at S010, T_C011 the triple Column starting at S011.
*/

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
		cast(float)(LN10),                          /// VFPU_LN10     - ln(10)
		cast(float)(2.0 * PI),                      /// VFPU_2PI      - 2 * pi
		cast(float)(PI / 6.0),                      /// VFPU_PI_6     - pi / 6
		cast(float)(LOG2),                          /// VFPU_LOG10TWO - log10(2)
		cast(float)(LOG2T),                         /// VFPU_LOG2TEN  - log2(10) = log(10) / log(2)
		cast(float)(sqrt(3.0) / 2.0)                /// VFPU_SQRT3_2  - sqrt(3) / 2
	];

	/*
	+------------------------+------------------+----+--------+---+--------------+ 
	|31                   21 | 20            16 | 15 | 14   8 | 7 | 6         0  | 
	+------------------------+------------------+----+--------+---+--------------+ 
	| opcode 0xd06 (s)       | constant (0-31)  |  0 |   0    | 0 | vfpu_rd[6-0] | 
	| opcode 0xd06 (p)       | constant (0-31)  |  0 |   0    | 1 | vfpu_rd[6-0] | 
	| opcode 0xd06 (t)       | constant (0-31)  |  1 |   0    | 0 | vfpu_rd[6-0] | 
	| opcode 0xd06 (q)       | constant (0-31)  |  1 |   0    | 1 | vfpu_rd[6-0] | 
	+------------------------+------------------+----+--------+---+--------------+ 

	   StoreConstant.Single/Pair/Triple/Quad 

	   vcst.s %vfpu_rd, %a ; store constant into single 
	   vcst.p %vfpu_rd, %a ; store constant into pair 
	   vcst.t %vfpu_rd, %a ; store constant into triple 
	   vcst.q %vfpu_rd, %a ; store constant into quad 

		  %vfpu_rd:   VFPU Vector Destination Register ([s|p|t|q]reg 0..127) 
		  %a:         VFPU Constant ID     Value 
					  ================     ========================================== 
					  0  = ZERO            0 
					  1  = HUGE            340282346638528859811704183484516925440.0 
					  2  = sqrt(2)         1.41421 
					  3  = 1.0 / sqrt(2.0) 0.70711 
					  4  = 2.0 / sqrt(PI)  1.12838 
					  5  = 2.0 / PI        0.63662 
					  6  = 1.0 / PI        0.31831 
					  7  = PI/4.0          0.78540 
					  8  = PI/2.0          1.57080 
					  9  = PI              3.14159 
					  10 = E               2,71828 
					  11 = log2(E)         1.44270 
					  12 = log10(E)        0.43429 
					  13 = log2(2.0)       0.69315 
					  14 = log2(10.0)      2.30259 
					  15 = 2 * PI          6.28319 
					  16 = PI / 6.0        0.52360 
					  17 = log10(2)        0.30103 
					  18 = log2(10.0)      3.32193 
					  19 = sqrt(3.0) / 2.0 0.86603 
					  20-31 = n/a          0 

	   vfpu_regs[%vfpu_rd] <- constants[%a]   ; one of the VFPU_XXX constants below
	*/
	void OP_VCST() {
		auto vsize = instruction.ONE_TWO;
        float constant = (instruction.IMM5 >= 0 && instruction.IMM5 < vfpu_constant.length) ? vfpu_constant[instruction.IMM5] : 0.0f;

		foreach (ref cell; VD[0..vsize]) cell = constant;
		saveVd(vsize);

		debug (DEBUG_VFPU_I) writefln("OP_VCST(%f)", constant);

		registers.pcAdvance(4);
	}

	void _OP_VIDT_x(int vsize, int vd) {
		int id = vd & 3;
		foreach (n, ref cell; VD[0..vsize]) cell = (n == id) ? 1.0f : 0.0f;;
		saveVd(vsize, vd);
	}

	// Vector IDenTity
	/* 
	+-------------------------------------------------------------+--------------+ 
	|31                                   16 | 15 | 14     8  | 7 | 6         0  | 
	+-------------------------------------------------------------+--------------+ 
	| opcode 0xd003 (p)                      |  0 |      0    | 1 | vfpu_rd[6-0] | 
	| opcode 0xd003 (t)                      |  1 |      0    | 0 | vfpu_rd[6-0] | 
	| opcode 0xd003 (q)                      |  1 |      0    | 1 | vfpu_rd[6-0] | 
	+-------------------------------------------------------------+--------------+ 
		
	   VectorLoadIdentity.Pair/Triple/Quad 

		vidt.p %vfpu_rd   ; Set 2x1 Vector in 2x2 Matrix to Identity 
		vidt.t %vfpu_rd   ; Set 3x1 Vector in 3x3 Matrix to Identity 
		vidt.q %vfpu_rd   ; Set 4x1 Vector in 4x4 Matrix to Identity 

			%vfpu_rd:   VFPU Vector Destination Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- identity vector (the matching row/column from the identity matrix for this index)
	*/
	void OP_VIDT() {
		auto vsize = instruction.ONE_TWO;
		
		debug (DEBUG_VFPU_I) writefln("OP_VIDT");
		
		_OP_VIDT_x(vsize, instruction.VD);
		registers.pcAdvance(4);
	}

	// Vector Matrix IDenTity quad aligned?
	// VMIDT(111100:111:00:00011:two:0000000:one:vd)
	/*
	+-------------------------------------------------------------+--------------+
	|31                                                         7 | 6         0  |
	+-------------------------------------------------------------+--------------+
	|              opcode 0xf3838080                              | vfpu_rd[6-0] |
	+-------------------------------------------------------------+--------------+

		vmidt.p %vfpu_rd	; Set 2x2 Submatrix to Identity
		vmidt.t %vfpu_rd	; Set 3x3 Submatrix to Identity
		vmidt.q %vfpu_rd	; Set 4x4 Matrix to Identity

		%vfpu_rd:	VFPU Matrix Destination Register ([s|p|t|q]reg 0..127)

		vfpu_mtx[%vfpu_rd] <- identity matrix
	*/
	void OP_VMIDT() {
		auto vsize = instruction.ONE_TWO;
		int vd = instruction.VD;
		foreach (n; 0..vsize) _OP_VIDT_x(vsize, vd + n);

		debug (DEBUG_VFPU_I) writefln("OP_VMIDT(%d)(%d)", vsize, vd);

		registers.pcAdvance(4);
	}

	/*
	+------------------------------------------+--------------+---+--------------+
	|31                                     15 | 14         8 | 7 | 6          0 |
	+------------------------------------------+--------------+---+--------------+
	|              opcode 0xd0000000           | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] |
	+------------------------------------------+--------------+---+--------------+

	  Copy/Move Matrix to new Register

		vmmov.p %vfpu_rd, %vfpu_rs    ; Move 2x2
		vmmov.t %vfpu_rd, %vfpu_rs    ; Move 3x3
		vmmov.q %vfpu_rd, %vfpu_rs    ; Move 4x4

		%vfpu_rd:	VFPU Matrix Destination Register (m[p|t|q]reg 0..127)
		%vfpu_rs:	VFPU Matrix Source Register (m[p|t|q]reg 0..127)

		vfpu_mtx[%vfpu_rd] <- vfpu_mtx[%vfpu_rs]
	*/
	void OP_VMMOV() {
		auto vsize = instruction.ONE_TWO;

		foreach (y; 0..vsize) {
			loadVs(vsize, instruction.VS + y);
			{
				VD[0..vsize] = VS[0..vsize];
			}
			saveVd(vsize, instruction.VD + y);
		}

		debug (DEBUG_VFPU_I) writefln("OP_VMMOV(%d)(%d->%d)", vsize, instruction.VT, instruction.VD);

		registers.pcAdvance(4);
	}

	void _OP_VMSET(float value) {
		auto vsize = instruction.ONE_TWO;

		debug (DEBUG_VFPU_I) writefln("_OP_VMSET(%d)(%f->%d)", vsize, value, instruction.VD);

		VD[0..vsize] = value;
		foreach (y; 0..vsize) saveVd(vsize, instruction.VD + y);

		registers.pcAdvance(4);
	}

	/*
	+-------------------------------------------------------------+--------------+
	|31                                                         7 | 6         0  |
	+-------------------------------------------------------------+--------------+
	|              opcode 0xf3868080                              | vfpu_rd[6-0] |
	+-------------------------------------------------------------+--------------+

	  SetMatrixZero.Single/Pair/Triple/Quad

		vmzero.p %vfpu_rd	; Set 2x2 Submatrix to 0.0f
		vmzero.t %vfpu_rd	; Set 3x3 Submatrix to 0.0f
		vmzero.q %vfpu_rd	; Set 4x4 Matrix to 0.0f

		%vfpu_rd:	VFPU Matrix Destination Register ([p|t|q]reg 0..127)

		vfpu_mtx[%vfpu_rd] <- 0.0f
	*/
	void OP_VMZERO() {
		_OP_VMSET(0);
	}
	
	/*
	+-------------------------------------------------------------+--------------+
	|31                                                         7 | 6         0  |
	+-------------------------------------------------------------+--------------+
	|              opcode 0xf3870080                              | vfpu_rd[6-0] |
	+-------------------------------------------------------------+--------------+

	  SetMatrixOne.Single/Pair/Triple/Quad

		vmone.p %vfpu_rd	; Set 2x2 Submatrix to 1.0f
		vmone.t %vfpu_rd	; Set 3x3 Submatrix to 1.0f
		vmone.q %vfpu_rd	; Set 4x4 Matrix to 1.0f

		%vfpu_rd:	VFPU Matrix Destination Register ([p|t|q]reg 0..127)

		vfpu_mtx[%vfpu_rd] <- 1.0f
	*/
	void OP_VMONE() {
		_OP_VMSET(1);
	}

	/*
	+----------------------+--------------+----+--------------+---+--------------+
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  |
	+----------------------+--------------+----+--------------+---+--------------+
	|  opcode 0x65008080   | vfpu_rt[6-0] |    | vfpu_rs[6-0] |   | vfpu_rd[6-0] |
	+----------------------+--------------+----+--------------+---+--------------+

	  MatrixScale.Pair/Triple/Quad, multiply all components by scale factor

		vmscl.p %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Scale 2x2 Matrix by %vfpu_rt
		vmscl.t %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Scale 3x3 Matrix by %vfpu_rt
		vmscl.q %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Scale 4x4 Matrix by %vfpu_rt

		%vfpu_rt:	VFPU Vector Source Register, Scale (sreg 0..127)
		%vfpu_rs:	VFPU Vector Source Register, Matrix ([p|t|q]reg 0..127)
		%vfpu_rd:	VFPU Vector Destination Register, Matrix ([s|p|t|q]reg 0..127)

		vfpu_mtx[%vfpu_rd] <- vfpu_mtx[%vfpu_rs] * vfpu_reg[%vfpu_rt]
	*/
	//void OP_MSCL() { }

	/*
	+------------------------------------+---------------------------------------+
	|31              23|22             16|15                                   0 |
	+------------------+-----------------+---------------------------------------+
	|    opcode 0xdf   |  vfpu_rd[6-0]   |              immediate                |
	+------------------+-----------------+---------------------------------------+

	  Set Single Vector Component to Immediate Integer

		vimm.s %vfpu_rd, immediate   ; Set Vector Component to immediate Integer

		immediate:	Integer, converted to Float before loading into sreg
		%vfpu_rd:	VFPU Vector Destination Register (sreg 0..127)

		vfpu_regs[%vfpu_rd] <- (float) immediate
	*/
	// Vfpu load Integer IMmediate
	void OP_VIIM() {
		VD[0] = cast(float)instruction.IMM;
		saveVd(1, instruction.EXT(16, 7));
		debug (DEBUG_VFPU_I) writefln("OP_VIIM(%d)<-(%f)", instruction.EXT(16, 7), VD[0]);
		registers.pcAdvance(4);
	}

	/*
	+-------------+-----------+---------+----------------------------+-----+-----+
	|31         26|25       21|20     16|15                        2 |  1  |  0  |
	+-------------+-----------+---------+----------------------------+-----+-----+
	| opcode 0xd8 | base[4-0] | rd[4-0] |         offset[15-2]       |  0  |rd[5]|
	+-------------+-----------+---------+----------------------------+-----+-----+

	  LoadVector.Single/Quadword Relative to Address in General Purpose Register
	  Final Address needs to be 16-byte aligned.

		lv.s %vfpu_rd, offset(%base)
		lv.q %vfpu_rd, offset(%base)

		%vfpu_rd:	VFPU Vector Destination Register ([s|q]reg)
		%base:		GPR, specifies Source Address Base
		offset:		signed Offset added to Source Address Base

		vfpu_regs[%vfpu_rd] <- vector_at_address (offset + %gpr)
	*/	
	// Load 4 Vfpu (Quad) regs from 16 byte aligned memory
	// LVQ(110110:rs:vt5:imm14:0:vt1)
	void OP_LV_Q() {
		uint address = cpu.registers.R[instruction.RS] + instruction.IMM14 * 4;
		foreach (n, ref value; VD[0..4]) value = cpu.memory.tread!(float)(address + n * 4);
		saveVd(4, instruction.VT5_1);
		
		debug (DEBUG_VFPU_I) writefln("OP_LV_Q(%s)", VD[0..4]);
		
		registers.pcAdvance(4);
	}

	/*
	+-------------+-----------+---------+----------------------------+-----+-----+
	|31         26|25       21|20     16|15                        2 |  1  |  0  |
	+-------------+-----------+---------+----------------------------+-----+-----+
	| opcode 0xd4 | base[4-0] | rd[4-0] |         offset[15-2]       |  0  |rd[5]|
	| opcode 0xd4 | base[4-0] | rd[4-0] |         offset[15-2]       |  1  |rd[5]|
	+-------------+-----------+---------+----------------------------+-----+-----+

	  LoadVectorLeft/Right.Quadword Relative to Address in General Purpose Register
	  Load unaligned Quadwords. lvl.q contains address of lower part, lvr.q the high one.

		lvl.q %vfpu_rd, offset(%base)
		lvr.q %vfpu_rd, offset(%base)

		%vfpu_rd:	VFPU Vector Destination Register ([s|q]reg)
		%base:		GPR, specifies Source Address Base
		offset:		signed Offset added to Source Address Base

		vfpu_regs[%vfpu_rd] <- vector_at_address (offset + %gpr)
	*/
	void OP_LVL_Q() {
		int vt = instruction.VT5;
        int m  = (vt >> 2) & 7;
        int i  = (vt >> 0) & 3;
		
		uint address = cpu.registers.R[instruction.RS] + instruction.IMM14 * 4 - 12;
		int k = 4 - ((address >> 2) & 3);
		debug (DEBUG_VFPU_I) float[] rows_d = new float[4];
		uint address_start = address;
		
        if ((vt & 32) != 0) {
            for (int j = 0; j < k; ++j) {
				auto value = cpu.memory.tread!(float)(address);
				debug (DEBUG_VFPU_I) rows_d[j] = value;
                cpu.registers.VF_CELLS[m][j][i] = value;
				address += 4;
            }
        } else {
            for (int j = 0; j < k; ++j) {
				auto value = cpu.memory.tread!(float)(address);
                debug (DEBUG_VFPU_I) rows_d[j] = value;
				cpu.registers.VF_CELLS[m][i][j] = value;
				address += 4;
            }
        }

		debug (DEBUG_VFPU_I) writefln("OP_LVL_Q(0x%08X)(%s)(%s)", address_start, rows_d, cpu.memory.tread!(float[10])(address_start - 8));

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
		debug (DEBUG_VFPU_I) float[] rows_d = new float[4];
		uint address_start = address;

        if ((vt & 32) != 0) {
            for (int j = 4 - k; j < 4; ++j) {
				auto value = cpu.memory.tread!(float)(address);
				debug (DEBUG_VFPU_I) rows_d[j] = value;
                cpu.registers.VF_CELLS[m][j][i] = value;
				address += 4;
            }
        } else {
            for (int j = 4 - k; j < 4; ++j) {
				auto value = cpu.memory.tread!(float)(address);
				debug (DEBUG_VFPU_I) rows_d[j] = value;
				cpu.registers.VF_CELLS[m][i][j] = value;
				address += 4;
            }
        }

		debug (DEBUG_VFPU_I) writefln("OP_LVR_Q(0x%08X)(%s)(%s)", address_start, rows_d, cpu.memory.tread!(float[10])(address_start - 8));

		registers.pcAdvance(4);
	}

	/*
	+-------------+-----------+---------+----------------------------+-----+-----+
	|31         26|25       21|20     16|15                        2 |  1  |  0  |
	+-------------+-----------+---------+----------------------------+-----+-----+
	| opcode 0xf8 | base[4-0] | rs[4-0] |         offset[15-2]       | c_p |rs[5]|
	+-------------+-----------+---------+----------------------------+-----+-----+

	  StoreVector.Quadword Relative to Address in General Purpose Register
	  Final Address needs to be 16-byte aligned.

		sv.s %vfpu_rs, offset(%base), cache_policy
		sv.q %vfpu_rs, offset(%base), cache_policy

		%vfpu_rs:	VFPU Vector Register ([s|q]reg)
		%base:		specifies Source Address Base
		offset:		signed Offset added to Source Address Base
		cache_policy:	0 = write-through, 1 = write-back

		vector_at_address (offset + %gpr) <- vfpu_regs[%vfpu_rs]
	*/
	// Store 4 Vfpu (Quad) regs from 16 byte aligned memory
	// SVQ(111110:rs:vt5:imm14:0:vt1)
	void OP_SV_Q() {
		loadVt(4, instruction.VT5_1);
		uint address = cpu.registers.R[instruction.RS] + instruction.IMM14 * 4;

		foreach (n, value; VT[0..4]) cpu.memory.twrite!(float)(address + n * 4, value);

		debug (DEBUG_VFPU_I) writefln("OP_SV_Q(%d,%d)(%s)", instruction.VT5, instruction.VT1, VT[0..4]);

		registers.pcAdvance(4);
	}

	/*
	+-------------+-----------+---------+----------------------------+-----+-----+
	|31         26|25       21|20     16|15                        2 |  1  |  0  |
	+-------------+-----------+---------+----------------------------+-----+-----+
	| opcode 0xf4 | base[4-0] | rs[4-0] |         offset[15-2]       |  0  |rs[5]|
	| opcode 0xf4 | base[4-0] | rs[4-0] |         offset[15-2]       |  1  |rs[5]|
	+-------------+-----------+---------+----------------------------+-----+-----+

	  StoreVectorLeft/Right.Quadword Relative to Address in General Purpose Register
	  Store unaligned Quadwords. svl.q contains address of lower part, svr.q the high one.

		svl.q %vfpu_rs, offset(%base), cache_policy
		svr.q %vfpu_rs, offset(%base), cache_policy

		%vfpu_rs:	VFPU Vector Register ([s|q]reg)
		%base:		specifies Source Address Base
		offset:		signed Offset added to Source Address Base

		vector_at_address (offset + %gpr) <- vfpu_regs[%vfpu_rs]
	*/
	//void OP_SVL() { }
	//void OP_SVR() { }
	
	/* 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  | 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|  opcode 0x648 (p)    | vfpu_rt[6-0] | 0  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	|  opcode 0x648 (t)    | vfpu_rt[6-0] | 1  | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	|  opcode 0x648 (q)    | vfpu_rt[6-0] | 1  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+----------------------+--------------+----+--------------+---+--------------+ 

	   VectorDotProduct.Pair/Triple/Quad 

		vdot.p %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Dot Product Pair 
		vdot.t %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Dot Product Triple 
		vdot.q %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Dot Product Quad 

			%vfpu_rt:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 
			%vfpu_rd:   VFPU Vector Destination Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- dotproduct(vfpu_regs[%vfpu_rs], vfpu_regs[%vfpu_rt]) 
	*/ 
	void OP_VDOT() {
		auto vsize = instruction.ONE_TWO;
		if (vsize == 1) OP_UNK();
		
		debug (DEBUG_VFPU_I) writefln("OP_VDOT");
		
		loadVs(vsize);
		loadVt(vsize);
		{
			VD[0] = 0.0;
			foreach (n; 0..vsize) VD[0] += VS[n] * VT[n];
		}
		saveVd(1);
		
		registers.pcAdvance(4);
	}

	/* 
	+-------------------------------------+----+--------------+---+--------------+ 
	|31                                16 | 15 | 14         8 | 7 | 6         0  | 
	+-------------------------------------+----+--------------+---+--------------+ 
	|        opcode 0xd046 (p)            | 0  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	|        opcode 0xd046 (t)            | 1  | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	|        opcode 0xd046 (q)            | 1  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+-------------------------------------+----+--------------+---+--------------+ 

	  Float ADD?.Pair/Triple/Quad  --  Accumulate Components of Vector into Single Float

		vfad.p %vfpu_rd, %vfpu_rs  ; Accumulate Components of Pair 
		vfad.t %vfpu_rd, %vfpu_rs  ; Accumulate Components of Triple 
		vfad.q %vfpu_rd, %vfpu_rs  ; Accumulate Components of Quad 

			%vfpu_rs:   VFPU Vector Source Register ([p|t|q]reg 0..127) 
			%vfpu_rd:   VFPU Vector Destination Register (sreg 0..127) 

		vfpu_regs[%vfpu_rd] <- Sum_Of_Components(vfpu_regs[%vfpu_rs]) 
	*/
	void OP_VFAD() {
		OP_V_EXTERNAL_IN_N!(1, "", "result += v;", "");
	}

	/* 
	+-------------------------------------+----+--------------+---+--------------+ 
	|31                                16 | 15 | 14         8 | 7 | 6         0  | 
	+-------------------------------------+----+--------------+---+--------------+ 
	|        opcode 0xd047 (p)            | 0  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	|        opcode 0xd047 (t)            | 1  | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	|        opcode 0xd047 (q)            | 1  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+-------------------------------------+----+--------------+---+--------------+ 

	  VectorAverage.Pair/Triple/Quad  --  Average Components of Vector into Single Float

		vavg.p %vfpu_rd, %vfpu_rs  ; Accumulate Components of Pair 
		vavg.t %vfpu_rd, %vfpu_rs  ; Accumulate Components of Triple 
		vavg.q %vfpu_rd, %vfpu_rs  ; Accumulate Components of Quad 

			%vfpu_rs:   VFPU Vector Source Register ([p|t|q]reg 0..127) 
			%vfpu_rd:   VFPU Vector Destination Register (sreg 0..127) 

		vfpu_regs[%vfpu_rd] <- Average_Of_Components(vfpu_regs[%vfpu_rs]) 
	*/ 
	void OP_VAVG() {
		OP_V_EXTERNAL_IN_N!(1, "", "result += v;", "result /= cast(float)vsize;");
	}

	// Move From Vfpu (C?)
	// MFV(010010:00:011:rt:0:0000000:0:vd)
	void OP_MFV() {
		loadVd(1); cpu.registers.R[instruction.RT] = F_I(VD[0]);

		debug (DEBUG_VFPU_I) writefln("OP_MFV(%f)", VD[0]);

		registers.pcAdvance(4);
	}
	void OP_MFVC() {
		assert(0, "Unimplemented");
	}

	// Move To Vfpu (C?)
	// MTV(010010:00:111:rt:0:0000000:0:vd)
	void OP_MTV() {
		VD[0] = I_F(cpu.registers.R[instruction.RT]);
		saveVd(1);

		debug (DEBUG_VFPU_I) writefln("OP_MTV(%f)", VD[0]);
		registers.pcAdvance(4);
	}
	void OP_MTVC() {
		assert(0, "Unimplemented");
	}
	
	/*
	+----------------------+--------------+----+--------------+---+--------------+
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  |
	+----------------------+--------------+----+--------------+---+--------------+
	|  opcode 0x65008080   | vfpu_rt[6-0] |    | vfpu_rs[6-0] |   | vfpu_rd[6-0] |
	+----------------------+--------------+----+--------------+---+--------------+

	  VectorScale.Pair/Triple/Quad

		vscl.p %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Scale Pair by %vfpu_rt
		vscl.t %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Scale Triple by %vfpu_rt
		vscl.q %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Scale Quad by %vfpu_rt

		%vfpu_rt:	VFPU Scalar Source Register (sreg 0..127)
		%vfpu_rs:	VFPU Vector Source Register ([p|t|q]reg 0..127)
		%vfpu_rd:	VFPU Vector Destination Register ([s|p|t|q]reg 0..127)

		vfpu_regs[%vfpu_rd] <- vfpu_regs[%vfpu_rs] * vfpu_reg[%vfpu_rt]
	*/
	void OP_VSCL() {
		auto vsize = instruction.ONE_TWO;
		if (vsize == 1) OP_UNK();

		loadVs(vsize);
		loadVt(1);
		{
			auto scale = VT[0];
			foreach (n, ref value; VD[0..vsize]) value = VS[n] * scale;
		}
		saveVd(vsize);

		debug (DEBUG_VFPU_I) writefln("OP_VSCL(%s) * %f -> (%s)", VS[0..vsize], VT[0], VD[0..vsize]);

		registers.pcAdvance(4);
	}

	// Vfpu ROTate
	// VSCL(011001:010:vt:two:vs:one:vd)
	void OP_VROT() {
		auto vsize = instruction.ONE_TWO;
		if (vsize == 1) OP_UNK();

		loadVs(1);
		double a  = PI_2 * VS[0];
		double ca = std.math.cos(a);
		double sa = std.math.sin(a);

		uint imm5 = instruction.IMM5;
        uint si = (imm5 >> 2) & 3;
        uint ci = (imm5 >> 0) & 3;
		if (imm5 & 16) sa = -sa;
		
        if (si == ci) {
            for (int n = 0; n < vsize; n++) VD[n] = cast(float)sa;
        } else {
            for (int n = 0; n < vsize; n++) VD[n] = cast(float)0.0;
            VD[si] = cast(float)sa;
        }
        VD[ci] = cast(float)ca;
		saveVd(vsize);

		debug (DEBUG_VFPU_I) writefln("OP_VROT(%f) -> (%s)", a, VD[0..vsize]);

		registers.pcAdvance(4);
	}

	void OP_V_INTERNAL_IN_N(int N, string op)() {
		static assert((N >= 0) && (N <= 2));
		
		auto vsize = instruction.ONE_TWO;

		static if (N >= 1) loadVs(vsize);
		static if (N >= 2) loadVt(vsize);

		for (int n = 0; n < vsize; n++) {
			static if (N >= 1) { float l = VS[n]; alias l v; }
			static if (N >= 2) { float r = VT[n]; }
			mixin("VD[n] = (" ~ op ~ ");");
		}
		
		saveVd(vsize);

		debug (DEBUG_VFPU_I) {
			writef("OP_V_INTERNAL_IN_N(%d, %s) -> (%s) <- ", N, op, VD[0..vsize]);
			static if (N >= 1) writef("(%s)", VS[0..vsize]);
			static if (N >= 2) writef("(%s)", VT[0..vsize]);
			writefln("");
		}

		registers.pcAdvance(4);
	}

	void OP_V_EXTERNAL_IN_N(int N, string pre = "", string iter = "", string post = "")() {
		static assert((N >= 0) && (N <= 2));
		
		auto vsize = instruction.ONE_TWO;

		static if (N >= 1) loadVs(vsize);
		static if (N >= 2) loadVt(vsize);

		float result = 0.0;
		mixin(pre);
		for (int n = 0; n < vsize; n++) {
			static if (N >= 1) { float l = VS[n]; alias l v; }
			static if (N >= 2) { float r = VT[n]; }
			mixin(iter);
		}
		mixin(post);
		VD[0] = result;
		saveVd(1);

		debug (DEBUG_VFPU_I) {
			writef("OP_V_EXTERNAL_IN_N(%d, %s, %s, %s) (%s) <- ", N, pre, iter, post, VD[0..vsize]);
			static if (N >= 1) writef("(%s)", VS[0..vsize]);
			static if (N >= 2) writef("(%s)", VT[0..vsize]);
			writefln("");
		}

		registers.pcAdvance(4);
	}

	/*
	+-------------------------------------------------------------+--------------+
	|31                                                         7 | 6         0  |
	+-------------------------------------------------------------+--------------+
	|              opcode 0xd0060000                              | vfpu_rd[6-0] |
	+-------------------------------------------------------------+--------------+

	  SetVectorZero.Single/Pair/Triple/Quad

		vzero.s %vfpu_rd	; Set 1 Vector Component to 0.0f
		vzero.p %vfpu_rd	; Set 2 Vector Components to 0.0f
		vzero.t %vfpu_rd	; Set 3 Vector Components to 0.0f
		vzero.q %vfpu_rd	; Set 4 Vector Components to 0.0f

		%vfpu_rd:	VFPU Vector Destination Register ([s|p|t|q]reg 0..127)

		vfpu_regs[%vfpu_rd] <- 0.0f
	*/
	void OP_VZERO()  { OP_V_INTERNAL_IN_N!(0, "0.0f"); }
	
	/*
	+-------------------------------------------------------------+--------------+
	|31                                                         7 | 6         0  |
	+-------------------------------------------------------------+--------------+
	|              opcode 0xd0070000                              | vfpu_rd[6-0] |
	+-------------------------------------------------------------+--------------+

	  SetVectorOne.Single/Pair/Triple/Quad

		vone.s %vfpu_rd	; Set 1 Vector Component to 1.0f
		vone.p %vfpu_rd	; Set 2 Vector Components to 1.0f
		vone.t %vfpu_rd	; Set 3 Vector Components to 1.0f
		vone.q %vfpu_rd	; Set 4 Vector Components to 1.0f

		%vfpu_rd:	VFPU Vector Destination Register ([s|p|t|q]reg 0..127)

		vfpu_regs[%vfpu_rd] <- 0.0f
	*/
	void OP_VONE()  { OP_V_INTERNAL_IN_N!(0, "1.0f"); }
	
	// Vfpu ABSolute/COSine/MOVe/Reverse SQuare root/LOG2/EXP2/NEGate/ReCiProcal
	/*
	+------------------------------------------+--------------+---+--------------+
	|31                                     15 | 14         8 | 7 | 6          0 |
	+------------------------------------------+--------------+---+--------------+
	|              opcode 0xd0000000           | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] |
	+------------------------------------------+--------------+---+--------------+

	  Move Vector

		vmov.s %vfpu_rd, %vfpu_rs    ; Move Single
		vmov.p %vfpu_rd, %vfpu_rs    ; Move Pair
		vmov.t %vfpu_rd, %vfpu_rs    ; Move Triple
		vmov.q %vfpu_rd, %vfpu_rs    ; Move Quad

		%vfpu_rd:	VFPU Vector Destination Register ([s|p|t|q]reg 0..127)
		%vfpu_rs:	VFPU Vector Source Register ([s|p|t|q]reg 0..127)

		vfpu_regs[%vfpu_rd] <- vfpu_regs[%vfpu_rs]
	*/
	void OP_VMOV()  { OP_V_INTERNAL_IN_N!(1, "v"); }

	/* 
	+-------------------------------------+----+--------------+---+--------------+ 
	|31                                16 | 15 | 14         8 | 7 | 6          0 | 
	+-------------------------------------+----+--------------+---+--------------+ 
	| opcode 0xd04a (s)                   |  0 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xd04a (p)                   |  0 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	| opcode 0xd04a (t)                   |  1 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xd04a (q)                   |  1 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+-------------------------------------+----+--------------+---+--------------+ 

	  Sign.Single/Pair/Triple/Quad 

		vsgn.s %vfpu_rd, %vfpu_rs    ; Get Sign Single 
		vsgn.p %vfpu_rd, %vfpu_rs    ; Get Sign Pair 
		vsgn.t %vfpu_rd, %vfpu_rs    ; Get Sign Triple 
		vsgn.q %vfpu_rd, %vfpu_rs    ; Get Sign Quad 

			%vfpu_rd:   VFPU Vector Destination Register (m[p|t|q]reg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register (m[p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- sign(vfpu_regs[%vfpu_rs]) 

		this will set rd values to 1 or -1, depending on sign of input values 
	*/ 
	void OP_VSGN()  { OP_V_INTERNAL_IN_N!(1, "sign(v)"); }

	/* 
	+-------------------------------------+----+--------------+---+--------------+ 
	|31                                16 | 15 | 14         8 | 7 | 6          0 | 
	+-------------------------------------+----+--------------+---+--------------+ 
	| opcode 0xd0010000 (s)               |  0 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xd0010080 (p)               |  0 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	| opcode 0xd0018000 (t)               |  1 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xd0018080 (q)               |  1 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+-------------------------------------+----+--------------+---+--------------+ 

	  AbsoluteValue.Single/Pair/Triple/Quad 

		vabs.s %vfpu_rd, %vfpu_rs    ; Absolute Value Single 
		vabs.p %vfpu_rd, %vfpu_rs    ; Absolute Value Pair 
		vabs.t %vfpu_rd, %vfpu_rs    ; Absolute Value Triple 
		vabs.q %vfpu_rd, %vfpu_rs    ; Absolute Value Quad 

			%vfpu_rd:   VFPU Vector Destination Register (m[p|t|q]reg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register (m[p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- abs(vfpu_regs[%vfpu_rs]) 
	*/ 
	void OP_VABS()  { OP_V_INTERNAL_IN_N!(1, "abs(v)"); }

	/* 
	+-----------------------------------------+--+--------------+-+--------------+ 
	|31                                    16 |15| 14         8 |7| 6         0  | 
	+-----------------------------------------+--+--------------+-+--------------+ 
	| opcode 0xd0130000 (s)                   | 0| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0130080 (p)                   | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	| opcode 0xd0138000 (t)                   | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0138080 (q)                   | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	+-----------------------------------------+--+--------------+-+--------------+ 

	  Cosine.Single/Pair/Triple/Quad 

		vcos.s  %vfpu_rd, %vfpu_rs   ; calculate cos on single 
		vcos.p  %vfpu_rd, %vfpu_rs   ; calculate cos on pair 
		vcos.t  %vfpu_rd, %vfpu_rs   ; calculate cos on triple 
		vcos.q  %vfpu_rd, %vfpu_rs   ; calculate cos on quad 

		%vfpu_rd:   VFPU Vector Target Register ([s|p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- cos(vfpu_regs[%vfpu_rs]) 

	  NOTE: the argument period range is scaled from 0.0 to 2.0 for numerical precisision.
			Multiply input values by 2.0/pi to get into 0 ... 2pi range.
			Multiply input values by 1.0/90.0 to get into 0deg ... 360deg range.
	*/ 
	void OP_VCOS()  { OP_V_INTERNAL_IN_N!(1, "cos(PI_2 * v)"); }

	/* 
	+-----------------------------------------+--+--------------+-+--------------+ 
	|31                                    16 |15| 14         8 |7| 6         0  | 
	+-----------------------------------------+--+--------------+-+--------------+ 
	| opcode 0xd0120000 (s)                   | 0| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0120080 (p)                   | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	| opcode 0xd0128000 (t)                   | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0128080 (q)                   | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	+-----------------------------------------+--+--------------+-+--------------+ 

	  Sinus.Single/Pair/Triple/Quad 

		vsin.s  %vfpu_rd, %vfpu_rs   ; calculate sin on single 
		vsin.p  %vfpu_rd, %vfpu_rs   ; calculate sin on pair 
		vsin.t  %vfpu_rd, %vfpu_rs   ; calculate sin on triple 
		vsin.q  %vfpu_rd, %vfpu_rs   ; calculate sin on quad 

		%vfpu_rd:   VFPU Vector Target Register ([s|p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- sin(vfpu_regs[%vfpu_rs]) 

	  NOTE: the argument period range is scaled from 0.0 to 2.0 for numerical precisision.
			Multiply input values by 2.0/pi to get into 0 ... 2pi range.
			Multiply input values by 1.0/90.0 to get into 0deg ... 360deg range.
	*/
	void OP_VSIN()  { OP_V_INTERNAL_IN_N!(1, "sin(PI_2 * v)"); }
	
	/* 
	+-----------------------------------------+--+--------------+-+--------------+ 
	|31                                    16 |15| 14         8 |7| 6         0  | 
	+-----------------------------------------+--+--------------+-+--------------+ 
	| opcode 0xd01a0000 (s)                   | 0| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd01a0080 (p)                   | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	| opcode 0xd01a8000 (t)                   | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd01a8080 (q)                   | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	+-----------------------------------------+--+--------------+-+--------------+ 

	  NegativeSin.Single/Pair/Triple/Quad 

		vnsin.s  %vfpu_rd, %vfpu_rs   ; calculate negative sin 
		vnsin.p  %vfpu_rd, %vfpu_rs   ; calculate negative sin 
		vnsin.t  %vfpu_rd, %vfpu_rs   ; calculate negative sin 
		vnsin.q  %vfpu_rd, %vfpu_rs   ; calculate negative sin 

		%vfpu_rd:   VFPU Vector Target Register ([s|p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- -sin(vfpu_regs[%vfpu_rs]) 
	*/
	void OP_VNSIN()  { OP_V_INTERNAL_IN_N!(1, "-sin(PI_2 * v)"); }

	/* 
	+-----------------------------------------+--+--------------+-+--------------+ 
	|31                                    16 |15| 14         8 |7| 6         0  | 
	+-----------------------------------------+--+--------------+-+--------------+ 
	| opcode 0xd0180000 (s)                   | 0| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0180080 (p)                   | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	| opcode 0xd0188000 (t)                   | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0188080 (q)                   | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	+-----------------------------------------+--+--------------+-+--------------+ 

	  NegativeReciprocal.Single/Pair/Triple/Quad 

		vnrcp.s  %vfpu_rd, %vfpu_rs   ; calculate negative reciprocal 
		vnrcp.p  %vfpu_rd, %vfpu_rs   ; calculate negative reciprocal 
		vnrcp.t  %vfpu_rd, %vfpu_rs   ; calculate negative reciprocal 
		vnrcp.q  %vfpu_rd, %vfpu_rs   ; calculate negative reciprocal 

		%vfpu_rd:   VFPU Vector Target Register ([s|p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- -1.0 / vfpu_regs[%vfpu_rs] 
	*/ 
	void OP_VNRCP()  { OP_V_INTERNAL_IN_N!(1, "-1.0 / v"); }

	/* 
	+-----------------------------------------+--+--------------+-+--------------+ 
	|31                                    16 |15| 14         8 |7| 6         0  | 
	+-----------------------------------------+--+--------------+-+--------------+ 
	| opcode 0xd01c0000 (s)                   | 0| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd01c0080 (p)                   | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	| opcode 0xd01c8000 (t)                   | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd01c8080 (q)                   | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	+-----------------------------------------+--+--------------+-+--------------+ 

	  ReciprocalExp2.Single/Pair/Triple/Quad 

		vrexp2.s  %vfpu_rd, %vfpu_rs   ; calculate 1/(2^y) 
		vrexp2.p  %vfpu_rd, %vfpu_rs   ; calculate 1/(2^y) 
		vrexp2.t  %vfpu_rd, %vfpu_rs   ; calculate 1/(2^y) 
		vrexp2.q  %vfpu_rd, %vfpu_rs   ; calculate 1/(2^y) 

		%vfpu_rd:   VFPU Vector Target Register ([s|p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- 1/exp2(vfpu_regs[%vfpu_rs]) 
	*/ 
	void OP_VREXP2() { OP_V_INTERNAL_IN_N!(1, "1.0 / exp2(v)"); }

	/* 
	+-----------------------------------------+--+--------------+-+--------------+ 
	|31                                    16 |15| 14         8 |7| 6         0  | 
	+-----------------------------------------+--+--------------+-+--------------+ 
	| opcode 0xd0170000 (s)                   | 0| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0170080 (p)                   | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	| opcode 0xd0178000 (t)                   | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0178080 (q)                   | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	+-----------------------------------------+--+--------------+-+--------------+ 

	  ArcSin.Single/Pair/Triple/Quad 

		vasin.s  %vfpu_rd, %vfpu_rs   ; calculate arcsin 
		vasin.p  %vfpu_rd, %vfpu_rs   ; calculate arcsin 
		vasin.t  %vfpu_rd, %vfpu_rs   ; calculate arcsin 
		vasin.q  %vfpu_rd, %vfpu_rs   ; calculate arcsin 

		%vfpu_rd:   VFPU Vector Target Register ([s|p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- arcsin(vfpu_regs[%vfpu_rs]) 

	  NOTE: the argument period range is scaled from 0.0 to 2.0 for numerical precisision.
			Multiply input values by 2.0/pi to get into 0 ... 2pi range.
			Multiply input values by 1.0/90.0 to get into 0deg ... 360deg range.
	*/ 
	void OP_VASIN() { OP_V_INTERNAL_IN_N!(1, "asin(v) * M_2_PI"); }

	/* 
	+-----------------------------------------+--+--------------+-+--------------+ 
	|31                                    16 |15| 14         8 |7| 6         0  | 
	+-----------------------------------------+--+--------------+-+--------------+ 
	| opcode 0xd0110000 (s)                   | 0| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0110080 (p)                   | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	| opcode 0xd0118000 (t)                   | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0118080 (q)                   | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	+-----------------------------------------+--+--------------+-+--------------+ 

	  ReciprocalSquareRoot.Single/Pair/Triple/Quad 

		vrsq.s  %vfpu_rd, %vfpu_rs   ; calculate reciprocal sqrt (1/sqrt(x)) on single 
		vrsq.p  %vfpu_rd, %vfpu_rs   ; calculate reciprocal sqrt (1/sqrt(x)) on pair 
		vrsq.t  %vfpu_rd, %vfpu_rs   ; calculate reciprocal sqrt (1/sqrt(x)) on triple 
		vrsq.q  %vfpu_rd, %vfpu_rs   ; calculate reciprocal sqrt (1/sqrt(x)) on quad 

		%vfpu_rd:   VFPU Vector Target Register ([s|p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- 1.0 / sqrt(vfpu_regs[%vfpu_rs]) 
	*/
	void OP_VRSQ()  { OP_V_INTERNAL_IN_N!(1, "1.0f / sqrt(v)"); }

	/* 
	+-----------------------------------------+--+--------------+-+--------------+ 
	|31                                    16 |15| 14         8 |7| 6         0  | 
	+-----------------------------------------+--+--------------+-+--------------+ 
	| opcode 0xd0160000 (s)                   | 0| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0160080 (p)                   | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	| opcode 0xd0168000 (t)                   | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0168080 (q)                   | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	+-----------------------------------------+--+--------------+-+--------------+ 

	  SquareRoot.Single/Pair/Triple/Quad 

		vsqrt.s  %vfpu_rd, %vfpu_rs   ; calculate square root 
		vsqrt.p  %vfpu_rd, %vfpu_rs   ; calculate square root 
		vsqrt.t  %vfpu_rd, %vfpu_rs   ; calculate square root 
		vsqrt.q  %vfpu_rd, %vfpu_rs   ; calculate square root 

		%vfpu_rd:   VFPU Vector Target Register ([s|p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- sqrt(vfpu_regs[%vfpu_rs]) 
	*/ 
	void OP_VSQRT()  { OP_V_INTERNAL_IN_N!(1, "sqrt(v)"); }

	/* 
	+-----------------------------------------+--+--------------+-+--------------+ 
	|31                                    16 |15| 14         8 |7| 6         0  | 
	+-----------------------------------------+--+--------------+-+--------------+ 
	| opcode 0xd0150000 (s)                   | 0| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0150080 (p)                   | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	| opcode 0xd0158000 (t)                   | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0158080 (q)                   | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	+-----------------------------------------+--+--------------+-+--------------+ 

	  Log2.Single/Pair/Triple/Quad (calculate logarithm base 2 of the specified real number) 

		vlog2.s  %vfpu_rd, %vfpu_rs 
		vlog2.p  %vfpu_rd, %vfpu_rs 
		vlog2.t  %vfpu_rd, %vfpu_rs 
		vlog2.q  %vfpu_rd, %vfpu_rs 

		%vfpu_rd:   VFPU Vector Target Register ([s|p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- log2(vfpu_regs[%vfpu_rs]) 
	*/ 
	void OP_VLOG2() { OP_V_INTERNAL_IN_N!(1, "log2(v)"); }

	/* 
	+-----------------------------------------+--+--------------+-+--------------+ 
	|31                                    16 |15| 14         8 |7| 6         0  | 
	+-----------------------------------------+--+--------------+-+--------------+ 
	| opcode 0xd0140000 (s)                   | 0| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0140080 (p)                   | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	| opcode 0xd0148000 (t)                   | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0148080 (q)                   | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	+-----------------------------------------+--+--------------+-+--------------+ 

	  Exp2.Single/Pair/Triple/Quad (calculate 2 raised to the specified real number) 

		vexp2.s  %vfpu_rd, %vfpu_rs   ; calculate 2^y 
		vexp2.p  %vfpu_rd, %vfpu_rs   ; calculate 2^y 
		vexp2.t  %vfpu_rd, %vfpu_rs   ; calculate 2^y 
		vexp2.q  %vfpu_rd, %vfpu_rs   ; calculate 2^y 

		%vfpu_rd:   VFPU Vector Target Register ([s|p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 

	   vfpu_regs[%vfpu_rd] <- 2^(vfpu_regs[%vfpu_rs]) 
	*/ 
	void OP_VEXP2() { OP_V_INTERNAL_IN_N!(1, "exp2(v)"); }

	/* 
	+-------------------------------------+----+--------------+---+--------------+ 
	|31                                16 | 15 | 14         8 | 7 | 6          0 | 
	+-------------------------------------+----+--------------+---+--------------+ 
	| opcode 0xd002 (s)                   |  0 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xd002 (p)                   |  0 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	| opcode 0xd002 (t)                   |  1 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xd002 (q)                   |  1 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+-------------------------------------+----+--------------+---+--------------+ 

	  Negate.Single/Pair/Triple/Quad 

		vneg.s %vfpu_rd, %vfpu_rs    ; Negate Single 
		vneg.p %vfpu_rd, %vfpu_rs    ; Negate Pair 
		vneg.t %vfpu_rd, %vfpu_rs    ; Negate Triple 
		vneg.q %vfpu_rd, %vfpu_rs    ; Negate Quad 

			%vfpu_rd:   VFPU Vector Destination Register (m[p|t|q]reg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register (m[p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- -vfpu_regs[%vfpu_rs] 
	*/
	void OP_VNEG()  { OP_V_INTERNAL_IN_N!(1, "-v"); }
	void OP_VOCP()  { OP_V_INTERNAL_IN_N!(1, "1.0 - v"); }

	/* 
	+-----------------------------------------+--+--------------+-+--------------+ 
	|31                                    16 |15| 14         8 |7| 6         0  | 
	+-----------------------------------------+--+--------------+-+--------------+ 
	| opcode 0xd0100000 (s)                   | 0| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0100080 (p)                   | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	| opcode 0xd0108000 (t)                   | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] | 
	| opcode 0xd0108080 (q)                   | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] | 
	+-----------------------------------------+--+--------------+-+--------------+ 

	  Reciprocal.Single/Pair/Triple/Quad 

		vrcp.s  %vfpu_rd, %vfpu_rs   ; calculate reciprocal (1/z) on single 
		vrcp.p  %vfpu_rd, %vfpu_rs   ; calculate reciprocal (1/z) on pair 
		vrcp.t  %vfpu_rd, %vfpu_rs   ; calculate reciprocal (1/z) on triple 
		vrcp.q  %vfpu_rd, %vfpu_rs   ; calculate reciprocal (1/z) on quad 

		%vfpu_rd:   VFPU Vector Target Register ([s|p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 

	   vfpu_regs[%vfpu_rd] <- 1.0 / vfpu_regs[%vfpu_rs] 
	*/ 
	void OP_VRCP()  { OP_V_INTERNAL_IN_N!(1, "1.0f / v"); }

	// Vfpu MINimum/MAXimum/ADD
	/*
	+----------------------+--------------+----+--------------+---+--------------+
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  |
	+----------------------+--------------+----+--------------+---+--------------+
	| opcode 0x6d0 (s)     | vfpu_rt[6-0] |  0 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] |
	| opcode 0x6d0 (p)     | vfpu_rt[6-0] |  0 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] |
	| opcode 0x6d0 (t)     | vfpu_rt[6-0] |  1 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] |
	| opcode 0x6d0 (q)     | vfpu_rt[6-0] |  1 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] |
	+----------------------+--------------+----+--------------+---+--------------+

	  VectorMin.Single/Pair/Triple/Quad

		vmin.s %vfpu_rd, %vfpu_rs, %vfpu_rt ; Get Minimum Value Single 
		vmin.p %vfpu_rd, %vfpu_rs, %vfpu_rt ; Get Minimum Value Pair 
		vmin.t %vfpu_rd, %vfpu_rs, %vfpu_rt ; Get Minimum Value Triple 
		vmin.q %vfpu_rd, %vfpu_rs, %vfpu_rt ; Get Minimum Value Quad 

			%vfpu_rt:   VFPU Vector Source Register (sreg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register ([p|t|q]reg 0..127) 
			%vfpu_rd:   VFPU Vector Destination Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- min(vfpu_regs[%vfpu_rs], vfpu_reg[%vfpu_rt]) 
	*/ 
	void OP_VMIN() { OP_V_INTERNAL_IN_N!(2, "min(l, r)"); }
	
	void OP_VSGE() { OP_V_INTERNAL_IN_N!(2, "(l >= r) ? 1.0 : 0.0"); }
	void OP_VSLT() { OP_V_INTERNAL_IN_N!(2, "(l <  r) ? 1.0 : 0.0"); }

	/* 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  | 
	+----------------------+--------------+----+--------------+---+--------------+ 
	| opcode 0x6d8 (s)     | vfpu_rt[6-0] |  0 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0x6d8 (p)     | vfpu_rt[6-0] |  0 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	| opcode 0x6d8 (t)     | vfpu_rt[6-0] |  1 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0x6d8 (q)     | vfpu_rt[6-0] |  1 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+----------------------+--------------+----+--------------+---+--------------+ 

	  VectorMax.Single/Pair/Triple/Quad 

		vmax.s %vfpu_rd, %vfpu_rs, %vfpu_rt ; Get Maximum Value Single 
		vmax.p %vfpu_rd, %vfpu_rs, %vfpu_rt ; Get Maximum Value Pair 
		vmax.t %vfpu_rd, %vfpu_rs, %vfpu_rt ; Get Maximum Value Triple 
		vmax.q %vfpu_rd, %vfpu_rs, %vfpu_rt ; Get Maximum Value Quad 

			%vfpu_rt:   VFPU Vector Source Register (sreg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register ([p|t|q]reg 0..127) 
			%vfpu_rd:   VFPU Vector Destination Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- max(vfpu_regs[%vfpu_rs], vfpu_reg[%vfpu_rt]) 
	*/
	void OP_VMAX() { OP_V_INTERNAL_IN_N!(2, "max(l, r)"); }

	/* 
	+-------------------------------------+----+--------------+---+--------------+ 
	|31                                16 | 15 | 14         8 | 7 | 6          0 | 
	+-------------------------------------+----+--------------+---+--------------+ 
	| opcode 0xd0040000 (s)               |  0 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xd0040080 (p)               |  0 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	| opcode 0xd0048000 (t)               |  1 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xd0048080 (q)               |  1 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+-------------------------------------+----+--------------+---+--------------+ 

	  SaturateValue0.Single/Pair/Triple/Quad 

		vsat0.s %vfpu_rd, %vfpu_rs    ; Clamp Value Single in Range 0.0...1.0
		vsat0.p %vfpu_rd, %vfpu_rs    ; Clamp Value Pair in Range 0.0...1.0
		vsat0.t %vfpu_rd, %vfpu_rs    ; Clamp Value Triple in Range 0.0...1.0
		vsat0.q %vfpu_rd, %vfpu_rs    ; Clamp Value Quad in Range 0.0...1.0

			%vfpu_rd:   VFPU Vector Destination Register (m[p|t|q]reg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register (m[p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- vfpu_regs[%vfpu_rs] < 0.0 ? 0.0 : vfpu_regs[%vfpu_rs] > 1.0 ? 1.0 : vfpu_regs[%vfpu_rs]
	*/ 
	void OP_VSAT0() { OP_V_INTERNAL_IN_N!(1, "clamp!(float)(v, 0.0, 1.0)"); }

	/* 
	+-------------------------------------+----+--------------+---+--------------+ 
	|31                                16 | 15 | 14         8 | 7 | 6          0 | 
	+-------------------------------------+----+--------------+---+--------------+ 
	| opcode 0xd0050000 (s)               |  0 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xd0050080 (p)               |  0 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	| opcode 0xd0058000 (t)               |  1 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xd0058080 (q)               |  1 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+-------------------------------------+----+--------------+---+--------------+ 

	  SaturateValue1.Single/Pair/Triple/Quad 

		vsat1.s %vfpu_rd, %vfpu_rs    ; Clamp Value Single in Range -1.0...1.0
		vsat1.p %vfpu_rd, %vfpu_rs    ; Clamp Value Pair in Range -1.0...1.0
		vsat1.t %vfpu_rd, %vfpu_rs    ; Clamp Value Triple in Range -1.0...1.0
		vsat1.q %vfpu_rd, %vfpu_rs    ; Clamp Value Quad in Range -1.0...1.0

			%vfpu_rd:   VFPU Vector Destination Register (m[p|t|q]reg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register (m[p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- vfpu_regs[%vfpu_rs] < -1.0 ? -1.0 : vfpu_regs[%vfpu_rs] > 1.0 ? 1.0 : vfpu_regs[%vfpu_rs]
	*/ 
	void OP_VSAT1() { OP_V_INTERNAL_IN_N!(1, "clamp!(float)(v, -1.0, 1.0)"); }

	/*
	+------------------------------------+--------------------+---+--------------+
	|31                               16 | 15 | 14          8 | 7 | 6          0 |
	+------------------------------------+--------------------+---+--------------+
	|    opcode 0xd03a0000               |    | vfpu_rs[6-0]  |   | vfpu_rd[6-0] |
	+------------------------------------+--------------------+---+--------------+

	  Convert Unsigned Short to Integer

		vus2i.s %vfpu_rd, %vfpu_rs   ; convert [sreg] vfpu_rs -> [preg] vfpu_rd
		vus2i.p %vfpu_rd, %vfpu_rs   ; convert [preg] vfpu_rs -> [qreg] vfpu_rd 

		%vfpu_rs:	VFPU Vector Source Register ([s|p]reg 0..127)
		%vfpu_rd:	VFPU Vector Destination Register ([p|q]reg 0..127)

	  vus2i.s:
		vfpu_regs[%vfpu_rd_p[0]] <- (int) low_16(vfpu_regs[%vfpu_rs]) / 2
		vfpu_regs[%vfpu_rd_p[1]] <- (int) high_16(vfpu_regs[%vfpu_rs]) / 2

	  vus2i.p:
		vfpu_regs[%vfpu_rd_q[0]] <- (int) low_16(vfpu_regs[%vfpu_rs_p[0]]) / 2
		vfpu_regs[%vfpu_rd_q[1]] <- (int) high_16(vfpu_regs[%vfpu_rs_p[0]]) / 2
		vfpu_regs[%vfpu_rd_q[2]] <- (int) low_16(vfpu_regs[%vfpu_rs_p[1]]) / 2
		vfpu_regs[%vfpu_rd_q[3]] <- (int) high_16(vfpu_regs[%vfpu_rs_p[1]]) / 2
	*/
	//void OP_VUS2I() { }

	/*
	+------------------------------------+--------------------+---+--------------+
	|31                               16 | 15 | 14          8 | 7 | 6          0 |
	+------------------------------------+--------------------+---+--------------+
	|    opcode 0xd03b0000               |    | vfpu_rs[6-0]  |   | vfpu_rd[6-0] |
	+------------------------------------+--------------------+---+--------------+

	  Convert Short to Integer

		vs2i.s %vfpu_rd, %vfpu_rs   ; convert [sreg] vfpu_rs -> [preg] vfpu_rd
		vs2i.p %vfpu_rd, %vfpu_rs   ; convert [preg] vfpu_rs -> [qreg] vfpu_rd 

		%vfpu_rs:	VFPU Vector Source Register ([s|p]reg 0..127)
		%vfpu_rd:	VFPU Vector Destination Register ([p|q]reg 0..127)

	  vs2i.s:
		vfpu_regs[%vfpu_rd_p[0]] <- (int) low_16(vfpu_regs[%vfpu_rs])
		vfpu_regs[%vfpu_rd_p[1]] <- (int) high_16(vfpu_regs[%vfpu_rs])

	  vs2i.p:
		vfpu_regs[%vfpu_rd_q[0]] <- (int) low_16(vfpu_regs[%vfpu_rs_p[0]])
		vfpu_regs[%vfpu_rd_q[1]] <- (int) high_16(vfpu_regs[%vfpu_rs_p[0]])
		vfpu_regs[%vfpu_rd_q[2]] <- (int) low_16(vfpu_regs[%vfpu_rs_p[1]])
		vfpu_regs[%vfpu_rd_q[3]] <- (int) high_16(vfpu_regs[%vfpu_rs_p[1]])
	*/
	//void OP_VS2I() { }

	/*
	+----------------------+-------------+----+---------------+---+--------------+
	|31                 21 | 20       16 | 15 | 14          8 | 7 | 6          0 |
	+----------------------+-------------+----+---------------+---+--------------+
	|  opcode 0xd2200000   |  scale[4-1] |    | vfpu_rs[6-0]  |   | vfpu_rd[6-0] |
	+----------------------+-------------+----+---------------+---+--------------+

	  Float to Int, Truncated

		vf2iz.s %vfpu_rd, %vfpu_rs, scale   ; Truncate and Convert Float to Integer (Single)
		vf2iz.p %vfpu_rd, %vfpu_rs, scale   ; Truncate and Convert Float to Integer (Pair)
		vf2iz.t %vfpu_rd, %vfpu_rs, scale   ; Truncate and Convert Float to Integer (Triple)
		vf2iz.q %vfpu_rd, %vfpu_rs, scale   ; Truncate and Convert Float to Integer (Quad)

		%vfpu_rs:	VFPU Vector Source Register ([s|p|t|q]reg 0..127)
		%vfpu_rd:	VFPU Vector Destination Register ([s|p|t|q]reg 0..127)
		scale:		Multiply by (2^scale) before converting to Float

		vfpu_regs[%vfpu_rd] <- (int) (2^scale * vfpu_regs[%vfpu_rs])
	*/
	//void OP_VF2IZ() { }

	/*
	+----------------------+--------------+----+--------------+---+--------------+
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  |
	+----------------------+--------------+----+--------------+---+--------------+
	|  opcode 0x60000000   | vfpu_rt[6-0] |    | vfpu_rs[6-0] |   | vfpu_rd[6-0] |
	+----------------------+--------------+----+--------------+---+--------------+

	  VectorAdd.Single/Pair/Triple/Quad

		vadd.s %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Add Single
		vadd.p %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Add Pair
		vadd.t %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Add Triple
		vadd.q %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Add Quad

		%vfpu_rt:	VFPU Vector Source Register ([s|p|t|q]reg 0..127)
		%vfpu_rs:	VFPU Vector Source Register ([s|p|t|q]reg 0..127)
		%vfpu_rd:	VFPU Vector Destination Register ([s|p|t|q]reg 0..127)

		vfpu_regs[%vfpu_rd] <- vfpu_regs[%vfpu_rs] + vfpu_regs[%vfpu_rt]
	*/
	void OP_VADD() { OP_V_INTERNAL_IN_N!(2, "l + r"); }

	/* 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  | 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|  opcode 0x608 (s)    | vfpu_rt[6-0] | 0  | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	|  opcode 0x608 (p)    | vfpu_rt[6-0] | 0  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	|  opcode 0x608 (t)    | vfpu_rt[6-0] | 1  | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	|  opcode 0x608 (q)    | vfpu_rt[6-0] | 1  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+----------------------+--------------+----+--------------+---+--------------+ 

	   VectorSub.Single/Pair/Triple/Quad 

		vsub.s %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Single 
		vsub.p %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Pair 
		vsub.t %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Triple 
		vsub.q %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Quad 

			%vfpu_rt:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 
			%vfpu_rd:   VFPU Vector Destination Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- vfpu_regs[%vfpu_rs] - vfpu_regs[%vfpu_rt] 
	*/ 
	void OP_VSUB() { OP_V_INTERNAL_IN_N!(2, "l - r"); }

	/* 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  | 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|  opcode 0x638 (s)    | vfpu_rt[6-0] | 0  | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	|  opcode 0x638 (p)    | vfpu_rt[6-0] | 0  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	|  opcode 0x638 (t)    | vfpu_rt[6-0] | 1  | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	|  opcode 0x638 (q)    | vfpu_rt[6-0] | 1  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+----------------------+--------------+----+--------------+---+--------------+ 

	   VectorDiv.Single/Pair/Triple/Quad 

		vdiv.s %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Single 
		vdiv.p %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Pair 
		vdiv.t %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Triple 
		vdiv.q %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Quad 

			%vfpu_rt:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 
			%vfpu_rd:   VFPU Vector Destination Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- vfpu_regs[%vfpu_rs] / vfpu_regs[%vfpu_rt] 
	*/ 
	void OP_VDIV() { OP_V_INTERNAL_IN_N!(2, "l / r"); }

	/* 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  | 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|  opcode 0x640 (s)    | vfpu_rt[6-0] | 0  | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	|  opcode 0x640 (p)    | vfpu_rt[6-0] | 0  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	|  opcode 0x640 (t)    | vfpu_rt[6-0] | 1  | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	|  opcode 0x640 (q)    | vfpu_rt[6-0] | 1  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+----------------------+--------------+----+--------------+---+--------------+ 

	   VectorMul.Single/Pair/Triple/Quad 

		vmul.s %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Single 
		vmul.p %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Pair 
		vmul.t %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Triple 
		vmul.q %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Sub Quad 

			%vfpu_rt:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 
			%vfpu_rd:   VFPU Vector Destination Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- vfpu_regs[%vfpu_rs] * vfpu_regs[%vfpu_rt] 
	*/ 
	void OP_VMUL() { OP_V_INTERNAL_IN_N!(2, "l * r"); }
	
	/* 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  | 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|  opcode 0x660 (p)    | vfpu_rt[6-0] | 0  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	|  opcode 0x660 (t)    | vfpu_rt[6-0] | 1  | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	|  opcode 0x660 (q)    | vfpu_rt[6-0] | 1  | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+----------------------+--------------+----+--------------+---+--------------+ 

	   VectorHomogenousDotProduct.Pair/Triple/Quad 

		vhdp.p %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Dot Product Pair 
		vhdp.t %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Dot Product Triple 
		vhdp.q %vfpu_rd, %vfpu_rs, %vfpu_rt   ; Dot Product Quad 

			%vfpu_rt:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 
			%vfpu_rs:   VFPU Vector Source Register ([s|p|t|q]reg 0..127) 
			%vfpu_rd:   VFPU Vector Destination Register ([s|p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- homogenousdotproduct(vfpu_regs[%vfpu_rs], vfpu_regs[%vfpu_rt]) 
	*/ 
	void OP_VHDP() {
		OP_V_EXTERNAL_IN_N!(2, "VS[vsize - 1] = 1.0;", "result += l * r;", "");
	}
	
	void OP_VCRSP_T() {
		loadVs(3);
		loadVt(3);
		{
			VD[0] = (VS[1] * VT[2]) - (VS[2] * VT[1]);
			VD[1] = (VS[2] * VT[0]) - (VS[0] * VT[2]);
			VD[2] = (VS[0] * VT[1]) - (VS[1] * VT[0]);
		}
		saveVd(3);

		debug (DEBUG_VFPU_I) writefln("OP_VCRSP_T");
		
		registers.pcAdvance(4);
	}

	void OP_VCRS_T() {
		loadVs(3);
		loadVt(3);
		{
			VD[0] = VS[1] * VT[2];
			VD[1] = VS[2] * VT[0];
			VD[2] = VS[0] * VT[1];
		}
		saveVd(3);

		debug (DEBUG_VFPU_I) writefln("OP_VCRSP_T");
		
		registers.pcAdvance(4);
	}

	void OP_VI2C() {
		loadVs(4);
		{
			foreach (n; 0..4) {
				auto VS_V = cast(ubyte[4]*)&VS;
				auto VD_V = cast(ubyte[4]*)&VD;
				VD_V[0][n] = VS_V[n][3];
			}
		}
		saveVd(1);

		debug (DEBUG_VFPU_I) writefln("OP_VI2C");
		registers.pcAdvance(4);
	}

	void OP_VI2UC() {
		loadVs(4);
		{
			foreach (n; 0..4) {
				int value = *(cast(uint*)&VS[n]);
				auto VD_V = cast(ubyte[4]*)&VD;
				//writefln("%s", *row_s[n]);
				VD_V[0][n] = cast(ubyte)((value < 0) ? 0 : (value >> 23));
			}
		}
		saveVd(1);

		debug (DEBUG_VFPU_I) writefln("OP_VI2UC");
		registers.pcAdvance(4);
	}
	
	void _OP_VTFM_x(int vsize, bool half)() {
		loadVt(vsize - half);
		{
			if (half) VT[vsize - 1] = 1.0;
			foreach (y; 0..vsize) {
				loadVs(vsize, instruction.VS + y);
				VD[y] = 0.0f; foreach (x; 0..vsize) VD[y] += VS[x] * VT[x];
			}
		}
		saveVd(vsize);
		debug (DEBUG_VFPU_I) writefln("_OP_VTFM_x(%d, %d)", vsize, half);
		registers.pcAdvance(4);
	}

	/* 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  | 
	+----------------------+--------------+----+--------------+---+--------------+ 
	| opcode 0xf08  (p)    | vfpu_rt[6-0] |  0 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	| opcode 0xf10  (t)    | vfpu_rt[6-0] |  1 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xf18  (q)    | vfpu_rt[6-0] |  1 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	+----------------------+--------------+----+--------------+---+--------------+ 

	  VectorTransform.Pair/Triple/Quad (Matrix-Vector product)

		vtfm2.p %vfpu_rd, %vfpu_rs, %vfpu_rt ; Transform pair vector by 2x2 matrix 
		vtfm3.t %vfpu_rd, %vfpu_rs, %vfpu_rt ; Transform triple vector by 3x3 matrix 
		vtfm4.q %vfpu_rd, %vfpu_rs, %vfpu_rt ; Transform quad vector by 4x4 matrix 

		%vfpu_rt:   VFPU Vector Source Register ([p|t|q]reg 0..127) 
		%vfpu_rs:   VFPU Matrix Source Register ([p|t|q]matrix 0..127) 
		%vfpu_rd:   VFPU Vector Destination Register ([p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- transform(vfpu_matrix[%vfpu_rs], vfpu_vector[%vfpu_rt]) 
	*/
	void OP_VTFM2() { _OP_VTFM_x!(2, false)(); }
	void OP_VTFM3() { _OP_VTFM_x!(3, false)(); }
	void OP_VTFM4() { _OP_VTFM_x!(4, false)(); }

	/* 
	+----------------------+--------------+----+--------------+---+--------------+ 
	|31                 23 | 22        16 | 15 | 14         8 | 7 | 6         0  | 
	+----------------------+--------------+----+--------------+---+--------------+ 
	| opcode 0xf08 (p)     | vfpu_rt[6-0] |  0 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	| opcode 0xf10 (t)     | vfpu_rt[6-0] |  0 | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] | 
	| opcode 0xf18 (q)     | vfpu_rt[6-0] |  1 | vfpu_rs[6-0] | 0 | vfpu_rd[6-0] | 
	+----------------------+--------------+----+--------------+---+--------------+ 

	  VectorHomogeneousTransform.Pair/Triple/Quad 

		vhtfm2.p %vfpu_rd, %vfpu_rs, %vfpu_rt ; Homogeneous transform pair vector by 2x2 matrix 
		vhtfm3.t %vfpu_rd, %vfpu_rs, %vfpu_rt ; Homogeneous transform triple vector by 3x3 matrix 
		vhtfm4.q %vfpu_rd, %vfpu_rs, %vfpu_rt ; Homogeneous transform quad vector by 4x4 matrix 

			%vfpu_rt:   VFPU Vector Source Register ([p|t|q]reg 0..127) 
			%vfpu_rs:   VFPU Matrix Source Register ([p|t|q]matrix 0..127) 
			%vfpu_rd:   VFPU Vector Destination Register ([p|t|q]reg 0..127) 

		vfpu_regs[%vfpu_rd] <- homeogenoustransform(vfpu_matrix[%vfpu_rs], vfpu_vector[%vfpu_rt]) 
	*/
	void OP_VHTFM2() { _OP_VTFM_x!(2, true)(); }
	void OP_VHTFM3() { _OP_VTFM_x!(3, true)(); }
	void OP_VHTFM4() { _OP_VTFM_x!(4, true)(); }

	/*
	+--------------------------+--------------+--+--------------+-+--------------+
	|31                     23 | 22        16 |15| 14         8 |7| 6         0  |
	+--------------------------+--------------+--+--------------+-+--------------+
	| opcode 0xf0000080 (p)    | vfpu_rt[6-0] | 0| vfpu_rs[6-0] |1| vfpu_rd[6-0] |
	| opcode 0xf0008000 (t)    | vfpu_rt[6-0] | 1| vfpu_rs[6-0] |0| vfpu_rd[6-0] |
	| opcode 0xf0008080 (q)    | vfpu_rt[6-0] | 1| vfpu_rs[6-0] |1| vfpu_rd[6-0] |
	+--------------------------+--------------+--+--------------+-+--------------+

	  MatrixMultiply.Pair/Triple/Quad

		vmmul.p %vfpu_rd, %vfpu_rs, %vfpu_rt   ; multiply 2 2x2 Submatrices
		vmmul.t %vfpu_rd, %vfpu_rs, %vfpu_rt   ; multiply 2 3x3 Submatrices
		vmmul.q %vfpu_rd, %vfpu_rs, %vfpu_rt   ; multiply 2 4x4 Matrices

		%vfpu_rd:	VFPU Matrix Destination Register ([p|t|q]reg 0..127)
		%vfpu_rs:	VFPU Matrix Source Register ([p|t|q]reg 0..127)
		%vfpu_rt:	VFPU Matrix Source Register ([p|t|q]reg 0..127)

		vfpu_mtx[%vfpu_rd] <- vfpu_mtx[%vfpu_rt] * vfpu_mtx[%vfpu_rs]
	*/
	void OP_VMMUL() {
		auto vsize = instruction.ONE_TWO;
		if (vsize == 1) OP_UNK();

		debug (DEBUG_VFPU_I) {
			foreach (i; 0..vsize) {
				loadVt(vsize, instruction.VT + i);
				writefln("OP_VMMUL.VT(%d)(%s)", instruction.VT + i, VT);
			}

			foreach (i; 0..vsize) {
				loadVs(vsize, instruction.VS + i);
				writefln("OP_VMMUL.VS(%d)(%s)", instruction.VS + i, VS);
			}
		}

		foreach (i; 0..vsize) {
			loadVt(vsize, instruction.VT + i);
            foreach (j; 0..vsize) {
				loadVs(vsize, instruction.VS + j);
				VD[j] = 0.0f; foreach (k; 0..vsize) VD[j] += VS[k] * VT[k];
            }
			saveVd(vsize, instruction.VD + i);
        }

		debug (DEBUG_VFPU_I) {
			foreach (i; 0..vsize) {
				loadVd(vsize, instruction.VD + i);
				writefln("OP_VMMUL.VD(%d)(%s)", instruction.VD + i, VD);
			}
		}

		registers.pcAdvance(4);
	}

	/*
	+------------------------------------------+--------------+---+--------------+
	|31                                     15 | 14         8 | 7 | 6          0 |
	+------------------------------------------+--------------+---+--------------+
	|              opcode 0xd0598080           | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] |
	+------------------------------------------+--------------+---+--------------+

		vt4444.q %vfpu_rd, %vfpu_rs    ; ?????? color conversion ????????????

		%vfpu_rd:	VFPU Vector Destination Register (qreg 0..127)
		%vfpu_rs:	VFPU Vector Source Register (qreg 0..127)

		???????????????????
	*/
	//void OP_VT4444() { }

	/*
	+------------------------------------------+--------------+---+--------------+
	|31                                     15 | 14         8 | 7 | 6          0 |
	+------------------------------------------+--------------+---+--------------+
	|              opcode 0xd05a8080           | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] |
	+------------------------------------------+--------------+---+--------------+

		vt5551.q %vfpu_rd, %vfpu_rs    ; ?????? color conversion ????????????

		%vfpu_rd:	VFPU Vector Destination Register (qreg 0..127)
		%vfpu_rs:	VFPU Vector Source Register (qreg 0..127)

		???????????????????
	*/
	//void OP_VT5551() { }

	/*
	+------------------------------------------+--------------+---+--------------+
	|31                                     15 | 14         8 | 7 | 6          0 |
	+------------------------------------------+--------------+---+--------------+
	|              opcode 0xd05b8080           | vfpu_rs[6-0] | 1 | vfpu_rd[6-0] |
	+------------------------------------------+--------------+---+--------------+

		vt5650.q %vfpu_rd, %vfpu_rs    ; ?????? color conversion ????????????

		%vfpu_rd:	VFPU Vector Destination Register (qreg 0..127)
		%vfpu_rs:	VFPU Vector Source Register (qreg 0..127)

		???????????????????
	*/
	//void OP_VT5650() { }

    void OP_VSRT3() {
		auto vsize = instruction.ONE_TWO;
        if (vsize != 4) {
			Logger.log(Logger.Level.WARNING, "Vfpu", "Only supported VSRT3.Q (vsize=%d)", vsize);
			// The instruction is somehow supported on the PSP (see VfpuTest),
			// but leave the error message here to help debugging the Decoder.
        } else {
			loadVs(4);
			{
				float x = VS[0], y = VS[1];
				float z = VS[2], w = VS[3];
				VD[0] = max(x, y);
				VD[1] = min(x, y);
				VD[2] = max(z, w);
				VD[3] = min(z, w);
			}
			saveVd(4);
		}
		debug (DEBUG_VFPU_I) writefln("OP_VSRT3");
		registers.pcAdvance(4);
    }
	
	// DETerminant
	void OP_VDET() {
		auto vsize = instruction.ONE_TWO;
		if (vsize != 2) OP_UNK(); // Only supported M2x2

		loadVs(2);
		loadVt(2);
		{
			VD[0] = (VS[0] * VT[1]) - (VS[1] * VT[0]);
		}
		saveVd(1);
		
		debug (DEBUG_VFPU_I) writefln("OP_VDET");	
		registers.pcAdvance(4);
	}

	void OP_VPFXD() {
		cpu.registers.vfpu_prefix_d = Prefix(instruction.v, true);
		debug (DEBUG_VFPU_I) writefln("OP_VPFXD(%020b)", (instruction.v & ((1 << 20) - 1)));
		registers.pcAdvance(4);
	}
	void OP_VPFXT() {
		cpu.registers.vfpu_prefix_t = Prefix(instruction.v, true);
		debug (DEBUG_VFPU_I) writefln("OP_VPFXT(%020b)", (instruction.v & ((1 << 20) - 1)));
		registers.pcAdvance(4);
	}
	void OP_VPFXS() {
		cpu.registers.vfpu_prefix_s = Prefix(instruction.v, true);
		debug (DEBUG_VFPU_I) writefln("OP_VPFXS(%020b)", (instruction.v & ((1 << 20) - 1)));
		registers.pcAdvance(4);
	}
	
	void OP_VRNDS() {
		registers.pcAdvance(4);
		debug (DEBUG_VFPU_I) writefln("OP_VRNDS");
		throw(new Exception("OP_VRNDS")); assert(0);
	}
	void OP_VRNDI() {
		registers.pcAdvance(4);
		debug (DEBUG_VFPU_I) writefln("OP_VRNDI");
		throw(new Exception("OP_VRNDI")); assert(0);
	}
	void OP_VRNDF1() {
		registers.pcAdvance(4);
		debug (DEBUG_VFPU_I) writefln("OP_VRNDF1");
		throw(new Exception("OP_VRNDF1")); assert(0);
	}
	void OP_VRNDF2() {
		registers.pcAdvance(4);
		debug (DEBUG_VFPU_I) writefln("OP_VRNDF2");
		throw(new Exception("OP_VRNDF1")); assert(0);
	}

	void OP_NOP() { registers.pcAdvance(4); }
	void OP_VFLUSH() { registers.pcAdvance(4); }
	void OP_VSYNC() { registers.pcAdvance(4); }
}

template TemplateCpu_VFPU_Utils() {
	float vfpu_dummy_address;
	float vfpu_one = 1.0;
	
	alias Registers.VfpuPrefix Prefix;
	float[4] VS, VT, VD;
	float*[4] vfpu_ptrlist;
	
	void applyPrefixSrc(ref Prefix prefix, float*[] src, float[] dst, bool enabled = true) {
		if (enabled && prefix.enabled) {
			foreach (i, ref value; dst) {
				// Constant.
				if (prefix.constant(i)) {
					switch (prefix.index(i)) {
						case 0: value = prefix.absolute(i) ? (3.0f       ) : (0.0f); break;
						case 1: value = prefix.absolute(i) ? (1.0f / 3.0f) : (1.0f); break;
						case 2: value = prefix.absolute(i) ? (1.0f / 4.0f) : (2.0f); break;
						case 3: value = prefix.absolute(i) ? (1.0f / 6.0f) : (0.5f); break;
					}
				}
				// Value
				else {
					value = *src[prefix.index(i)];
				}
				
				if (prefix.absolute(i)) value = abs(value);
				if (prefix.negate  (i)) value = -value;
			}
			prefix.enabled = false;
		} else {
			foreach (i, ref value; dst) value = *src[i];
		}
	}
	
	void applyPrefixDst(ref Prefix prefix, float[] src, float*[] dst, bool enabled = true) {
		if (enabled && prefix.enabled) {
			foreach (i, value; src) {
				if (prefix.mask(i)) continue;

				switch (prefix.saturation(i)) {
					case 1: value = clamp!(float)(value,  0.0, 1.0); break;
					case 3: value = clamp!(float)(value, -1.0, 1.0); break;
					default: break;
				}

				*dst[i] = value;
			}
			prefix.enabled = false;
		} else {
			foreach (i, value; src) *dst[i] = value;
		}
	}
	
	void loadVs(uint vsize, int vx) {
		vfpuVectorGetPointer(vfpu_ptrlist[0..vsize], vx);
		applyPrefixSrc(cpu.registers.vfpu_prefix_s, vfpu_ptrlist[0..vsize], VS[0..vsize], true);
	}

	void loadVt(uint vsize, int vx) {
		vfpuVectorGetPointer(vfpu_ptrlist[0..vsize], vx);
		applyPrefixSrc(cpu.registers.vfpu_prefix_t, vfpu_ptrlist[0..vsize], VT[0..vsize], true);
	}

	void loadVd(uint vsize, uint vx) {
		vfpuVectorGetPointer(vfpu_ptrlist[0..vsize], vx);
		applyPrefixSrc(cpu.registers.vfpu_prefix_d, vfpu_ptrlist[0..vsize], VD[0..vsize], false);
	}
	
	void saveVd(uint vsize, uint vx) {
		vfpuVectorGetPointer(vfpu_ptrlist[0..vsize], vx);
		applyPrefixDst(cpu.registers.vfpu_prefix_d, VD[0..vsize], vfpu_ptrlist[0..vsize], true);
	}
	
	void loadVs(uint vsize) { loadVs(vsize, instruction.VS); }
	void loadVt(uint vsize) { loadVt(vsize, instruction.VT); }
	void loadVd(uint vsize) { loadVd(vsize, instruction.VD); }
	void saveVd(uint vsize) { saveVd(vsize, instruction.VD); }
	
	void vfpuVectorGetPointer(float*[] row, uint vx) {
		uint line   = (vx >> 0) & 3; // 0-3
		uint matrix = (vx >> 2) & 7; // 0-7
		uint offset = void;
		bool order  = void;

		if (row.length == 1) {
			offset = (vx >> 5) & 3;
			order  = false;
		} else {
			offset = (vx & 64) >> (3 + row.length);
			order = ((vx & 32) != 0);
		}
		
		if (order) foreach (n, ref value; row) value = &cpu.registers.VF_CELLS[matrix][offset + n][line];
		else       foreach (n, ref value; row) value = &cpu.registers.VF_CELLS[matrix][line][offset + n];
	}
}