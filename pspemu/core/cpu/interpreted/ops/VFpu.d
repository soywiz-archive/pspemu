module pspemu.core.cpu.interpreted.ops.VFpu;
import pspemu.core.cpu.interpreted.Utils;

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

	// Vector Matrix IDenTity Quad aligned?
	// VMIDT(111100:111:00:00011:two:0000000:one:vd)
	void OP_VMIDT_Q() {
		uint vd = instruction.v & 0x7F;
		uint matrix = vd / 4;
		if (matrix >= 8) throw(new Exception("VMIDT_Q matrix >= 8"));
		cpu.registers.VF_MATRIX[matrix] = [
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1
		];
		registers.pcAdvance(4);
	}

	// Load 4 Vfpu (Quad) regs from 16 byte aligned memory
	// LVQ(110110:rs:vt5:imm14:0:vt1)
	void OP_LV_Q() {
		
	}
}
