module pspemu.core.cpu.Table;

import pspemu.core.cpu.Instruction;

import std.stdio;

// Aliases:
alias InstructionDefinition ID;
alias ValueMask VM;

// --------------------------
//  Related implementations:
// --------------------------
// OLD:       http://pspemu.googlecode.com/svn/branches/old/util/gen/tables/cpu_table.php
// PSPPlayer:
// Jpcsp:     http://jpcsp.googlecode.com/svn/trunk/src/jpcsp/Allegrex.isa
// mfzpsp:
// pcsp:

// http://svn.ps2dev.org/filedetails.php?repname=psp&path=/trunk/prxtool/disasm.C&rev=0&sc=0
/* Format codes
 * %d - Rd
 * %t - Rt
 * %s - Rs
 * %i - 16bit signed immediate
 * %I - 16bit unsigned immediate (always printed in hex)
 * %o - 16bit signed offset (rs base)
 * %O - 16bit signed offset (PC relative)
 * %j - 26bit absolute offset
 * %J - Register jump
 * %a - SA
 * %0 - Cop0 register
 * %1 - Cop1 register
 * %2? - Cop2 register (? is (s, d))
 * %p - General cop (i.e. numbered) register
 * %n? - ins/ext size, ? (e, i)
 * %r - Debug register
 * %k - Cache function
 * %D - Fd
 * %T - Ft
 * %S - Fs
 * %x? - Vt (? is (s/scalar, p/pair, t/triple, q/quad, m/matrix pair, n/matrix triple, o/matrix quad)
 * %y? - Vs
 * %z? - Vd
 * %X? - Vo (? is (s, q))
 * %Y - VFPU offset
 * %Z? - VFPU condition code/name (? is (c, n))
 * %v? - VFPU immediate, ? (3, 5, 8, k, i, h, r, p? (? is (0, 1, 2, 3, 4, 5, 6, 7)))
 * %c - code (for break)
 * %C - code (for syscall)
 * %? - Indicates vmmul special exception
*/

// @TODO: ADDR_TYPE could be induced from INSTR_TYPE plus format and could be removed when all the instructions use the Allegrex.isa format.
// (if an instruction is a B, JUMP or J type, we can check at compile time wether the format has an imm16, imm26 or if it only uses registers)
const PspInstructions_ALU = [
	// Arithmetic operations.
	ID( "add",    VM("000000:rs:rt:rd:00000:100000"), "%d, %s, %t", ADDR_TYPE_NONE, 0 ),
	ID( "addu",   VM("000000:rs:rt:rd:00000:100001"), "%d, %s, %t", ADDR_TYPE_NONE, 0 ),
	ID( "addi",   VM("001000:rs:rt:imm16"          ), "%t, %s, %i", ADDR_TYPE_NONE, 0 ),
	ID( "addiu",  VM("001001:rs:rt:imm16"          ), "%t, %s, %i", ADDR_TYPE_NONE, 0 ),
	ID( "sub",    VM("000000:rs:rt:rd:00000:100010"), "%d, %s, %t", ADDR_TYPE_NONE, 0 ),
	ID( "subu",   VM("000000:rs:rt:rd:00000:100011"), "%d, %s, %t", ADDR_TYPE_NONE, 0 ),

	// Logical Operations.
	ID( "and",    VM("000000:rs:rt:rd:00000:100100"), "%d, %s, %t", ADDR_TYPE_NONE, 0 ),
	ID( "andi",   VM("001100:rs:rt:imm16"          ), "%t, %s, %I", ADDR_TYPE_NONE, 0 ),
	ID( "nor",    VM("000000:rs:rt:rd:00000:100111"), "%d, %s, %t", ADDR_TYPE_NONE, 0 ),
	ID( "or",     VM("000000:rs:rt:rd:00000:100101"), "%d, %s, %t", ADDR_TYPE_NONE, 0 ),
	ID( "ori",    VM("001101:rs:rt:imm16"          ), "%t, %s, %I", ADDR_TYPE_NONE, 0 ),
	ID( "xor",    VM("000000:rs:rt:rd:00000:100110"), "%d, %s, %t", ADDR_TYPE_NONE, 0 ),
	ID( "xori",   VM("001110:rs:rt:imm16"          ), "%t, %s, %I", ADDR_TYPE_NONE, 0 ),

	// Shift Left/Right Logical/Arithmethic (Variable).
	ID( "sll",    VM("000000:00000:rt:rd:sa:000000"), "%d, %t, %a", ADDR_TYPE_NONE, 0 ),
	ID( "sllv",   VM("000000:rs:rt:rd:00000:000100"), "%d, %t, %s", ADDR_TYPE_NONE, 0 ),
	ID( "sra",    VM("000000:00000:rt:rd:sa:000011"), "%d, %t, %a", ADDR_TYPE_NONE, 0 ),
	ID( "srav",   VM("000000:rs:rt:rd:00000:000111"), "%d, %t, %s", ADDR_TYPE_NONE, 0 ),
	ID( "srl",    VM("000000:00000:rt:rd:sa:000010"), "%d, %t, %a", ADDR_TYPE_NONE, 0 ),
	ID( "srlv",   VM("000000:rs:rt:rd:00000:000110"), "%d, %t, %s", ADDR_TYPE_NONE, 0 ),
	ID( "rotr",   VM("000000:00001:rt:rd:sa:000010"), "%d, %t, %a", ADDR_TYPE_NONE, 0 ),
	ID( "rotrv",  VM("000000:rs:rt:rd:00001:000110"), "%d, %t, %s", ADDR_TYPE_NONE, 0 ),

	// Set Less Than (Immediate) (Unsigned).
	ID( "slt",    VM("000000:rs:rt:rd:00000:101010"), "%d, %s, %t", ADDR_TYPE_NONE, 0 ),
	ID( "slti",   VM("001010:rs:rt:imm16"          ), "%t, %s, %i", ADDR_TYPE_NONE, 0 ),
	ID( "sltu",   VM("000000:rs:rt:rd:00000:101011"), "%d, %s, %t", ADDR_TYPE_NONE, 0 ),
	ID( "sltiu",  VM("001011:rs:rt:imm16"          ), "%t, %s, %i", ADDR_TYPE_NONE, 0 ),

	// Load Upper Immediate.
	ID( "lui",    VM("001111:00000:rt:imm16"       ), "%t, %I",     ADDR_TYPE_NONE, 0 ),

	// Sign Extend (Byte/Half word)
	ID( "seb",    VM("011111:00000:rt:rd:10000:100000"), "%d, %t", ADDR_TYPE_NONE, 0 ),
	ID( "seh",    VM("011111:00000:rt:rd:11000:100000"), "%d, %t", ADDR_TYPE_NONE, 0 ),
	
	// Bit Reverse.
	ID( "bitrev", VM("011111:00000:rt:rd:10100:100000"), "%d, %t", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),

	ID( "max",    VM("000000:rs:rt:rd:00000:101100"), "%d, %s, %t", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "min",    VM("000000:rs:rt:rd:00000:101101"), "%d, %s, %t", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),

	// DIVide (Unsigned)
	ID( "div",    VM("000000:rs:rt:00000:00000:011010"), "%s, %t", ADDR_TYPE_NONE, 0 ),
	ID( "divu",   VM("000000:rs:rt:00000:00000:011011"), "%s, %t", ADDR_TYPE_NONE, 0 ),

	// MULTiply (Unsigned)
	ID( "mult",   VM("000000:rs:rt:00000:00000:011000"), "%s, %t", ADDR_TYPE_NONE, 0 ),
	ID( "multu",  VM("000000:rs:rt:00000:00000:011001"), "%s, %t", ADDR_TYPE_NONE, 0 ),

	// Multiply ADD/SUBstract (Unsigned)
	ID( "madd",   VM("000000:rs:rt:00000:00000:011100"), "%s, %t", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "maddu",  VM("000000:rs:rt:00000:00000:011101"), "%s, %t", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "msub",   VM("000000:rs:rt:00000:00000:101110"), "%s, %t", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "msubu",  VM("000000:rs:rt:00000:00000:101111"), "%s, %t", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),

	// Move To/From HI/LO
	ID( "mfhi",   VM("000000:00000:00000:rd:00000:010000"), "%d",  ADDR_TYPE_NONE, 0 ),
	ID( "mflo",   VM("000000:00000:00000:rd:00000:010010"), "%d",  ADDR_TYPE_NONE, 0 ),
	ID( "mthi",   VM("000000:rs:00000:00000:00000:010001"), "%s",  ADDR_TYPE_NONE, 0 ),
	ID( "mtlo",   VM("000000:rs:00000:00000:00000:010011"), "%s",  ADDR_TYPE_NONE, 0 ),

	// Move if Zero/Number
	ID( "movz",   VM("000000:rs:rt:rd:00000:001010"), "%d, %s, %t", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "movn",   VM("000000:rs:rt:rd:00000:001011"), "%d, %s, %t", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),

	// EXTract/INSert
	ID( "ext",    VM("011111:rs:rt:msb:lsb:000000"), "%t, %s, %a, %ne", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "ins",    VM("011111:rs:rt:msb:lsb:000100"), "%t, %s, %a, %ni", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),

	// Count Leading Ones/Zeros in word
	ID( "clz",    VM("000000:rs:00000:rd:00000:010110"), "%d, %s", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "clo",    VM("000000:rs:00000:rd:00000:010111"), "%d, %s", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),

	// WSBH -- Word Swap Bytes Within Halfwords/Words
	ID( "wsbh",   VM("011111:00000:rt:rd:00010:100000"), "%d, %t", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "wsbw",   VM("011111:00000:rt:rd:00011:100000"), "%d, %t", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
];

const PspInstructions_BCU = [
	// Branch on EQuals (Likely)
	ID( "beq",     VM("000100:rs:rt:imm16"   ), "%s, %t, %O", ADDR_TYPE_16,  INSTR_TYPE_B ),
	ID( "beql",    VM("010100:rs:rt:imm16"   ), "%s, %t, %O", ADDR_TYPE_16,  INSTR_TYPE_B ),

	// Branch on Greater Equal Zero (And Link) (Likely)
	ID( "bgez",    VM("000001:rs:00001:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_B ),
	ID( "bgezl",   VM("000001:rs:00011:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_B ),
	ID( "bgezal",  VM("000001:rs:10001:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_JAL ),
	ID( "bgezall", VM("000001:rs:10011:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_JAL ),

	// Branch on Less Than Zero (And Link) (Likely)
	ID( "bltz",    VM("000001:rs:00000:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_B ),
	ID( "bltzl",   VM("000001:rs:00010:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_B ),
	ID( "bltzal",  VM("000001:rs:10000:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_JAL ),
	ID( "bltzall", VM("000001:rs:10010:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_JAL ),

	// Branch on Less Or Equals than Zero (Likely)
	ID( "blez",    VM("000110:rs:00000:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_B ),
	ID( "blezl",   VM("010110:rs:00000:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_B ),

	// Branch on Great Or Equals than Zero (Likely)
	ID( "bgtz",    VM("000111:rs:00000:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_B ),
	ID( "bgtzl",   VM("010111:rs:00000:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_B ),

	// Branch on Not Equals (Likely)
	ID( "bne",     VM("000101:rs:rt:imm16"   ), "%s, %t, %O", ADDR_TYPE_16,  INSTR_TYPE_B ),
	ID( "bnel",    VM("010101:rs:rt:imm16"   ), "%s, %t, %O", ADDR_TYPE_16,  INSTR_TYPE_B ),

	// Jump (And Link) (Register)
	ID( "j",       VM("000010:imm26"         ), "%j",                ADDR_TYPE_26,  INSTR_TYPE_JUMP ),
	ID( "jr",      VM("000000:rs:00000:00000:00000:001000"), "%J",   ADDR_TYPE_REG, INSTR_TYPE_JUMP ),
	ID( "jalr",    VM("000000:rs:00000:rd:00000:001001"), "%J, %d",  ADDR_TYPE_REG, INSTR_TYPE_JAL ),
	ID( "jal",     VM("000011:imm26"         ), "%j",                ADDR_TYPE_26,  INSTR_TYPE_JAL ),

	// Branch on C1 (False/True) (Likely)
	ID( "bc1f",    VM("010001:01000:00000:imm16"), "%O",      ADDR_TYPE_16,  INSTR_TYPE_B ),
	ID( "bc1t",    VM("010001:01000:00001:imm16"), "%O",      ADDR_TYPE_16,  INSTR_TYPE_B ),
	ID( "bc1fl",   VM("010001:01000:00010:imm16"), "%O",      ADDR_TYPE_16,  INSTR_TYPE_B ),
	ID( "bc1tl",   VM("010001:01000:00011:imm16"), "%O",      ADDR_TYPE_16,  INSTR_TYPE_B ),
];

const PspInstructions_LSU = [
	// Load (Byte/Half word/Word) (Left/Right/Unsigned)
	ID( "lb",   VM("100000:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),
	ID( "lh",   VM("100001:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),
	ID( "lw",   VM("100011:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),
	ID( "lwl",  VM("100010:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),
	ID( "lwr",  VM("100110:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),
	ID( "lbu",  VM("100100:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),
	ID( "lhu",  VM("100101:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),

	// Store (Byte/Half word/Word) (Left/Right)
	ID( "sb",   VM("101000:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),
	ID( "sh",   VM("101001:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),
	ID( "sw",   VM("101011:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),
	ID( "swl",  VM("101010:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),
	ID( "swr",  VM("101110:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0 ),

	// Load Linked Word
	// Store Conditional Word
	ID( "ll",   VM("110000:rs:rt:imm16"), "%t, %O", ADDR_TYPE_NONE, 0 ),
	ID( "sc",   VM("111000:rs:rt:imm16"), "%t, %O", ADDR_TYPE_NONE, 0 ),

	// Load Word to Floating Point
	// Store Word from Floating Point
	ID( "lwc1", VM("110001:rs:ft:imm16"), "%T, %o", ADDR_TYPE_NONE, 0 ),
	ID( "swc1", VM("111001:rs:ft:imm16"), "%T, %o", ADDR_TYPE_NONE, 0 ),
];

const PspInstructions_FPU = [
	// Binary Floating Point Unit Operations
	ID( "add.s",       VM("010001:10000:ft:fs:fd:000000"   ), "%D, %S, %T", ADDR_TYPE_NONE, 0 ),
	ID( "sub.s",       VM("010001:10000:ft:fs:fd:000001"   ), "%D, %S, %T", ADDR_TYPE_NONE, 0 ),
	ID( "mul.s",       VM("010001:10000:ft:fs:fd:000010"   ), "%D, %S, %T", ADDR_TYPE_NONE, 0 ),
	ID( "div.s",       VM("010001:10000:ft:fs:fd:000011"   ), "%D, %S, %T", ADDR_TYPE_NONE, 0 ),

	// Unary Floating Point Unit Operations
	ID( "sqrt.s",      VM("010001:10000:00000:fs:fd:000100"), "%D, %S",     ADDR_TYPE_NONE, 0 ),
	ID( "abs.s",       VM("010001:10000:00000:fs:fd:000101"), "%D, %S",     ADDR_TYPE_NONE, 0 ),
	ID( "mov.s",       VM("010001:10000:00000:fs:fd:000110"), "%D, %S",     ADDR_TYPE_NONE, 0 ),
	ID( "neg.s",       VM("010001:10000:00000:fs:fd:000111"), "%D, %S",     ADDR_TYPE_NONE, 0 ),
	ID( "round.w.s",   VM("010001:10000:00000:fs:fd:001100"), "%D, %S",     ADDR_TYPE_NONE, 0 ),
	ID( "trunc.w.s",   VM("010001:10000:00000:fs:fd:001101"), "%D, %S",     ADDR_TYPE_NONE, 0 ),
	ID( "ceil.w.s",    VM("010001:10000:00000:fs:fd:001110"), "%D, %S",     ADDR_TYPE_NONE, 0 ),
	ID( "floor.w.s",   VM("010001:10000:00000:fs:fd:001111"), "%D, %S",     ADDR_TYPE_NONE, 0 ),

	// Convert
	ID( "cvt.s.w",     VM("010001:10100:00000:fs:fd:100000"), "%D, %S",     ADDR_TYPE_NONE, 0 ),
	ID( "cvt.w.s",     VM("010001:10000:00000:fs:fd:100100"), "%D, %S",     ADDR_TYPE_NONE, 0 ),

	// Move float point registers
	ID( "mfc1",        VM("010001:00000:rt:c1dr:00000:000000"), "%t, %1",   ADDR_TYPE_NONE, 0 ),
	ID( "cfc1",        VM("010001:00010:rt:c1cr:00000:000000"), "%t, %p",   ADDR_TYPE_NONE, 0 ),
	ID( "mtc1",        VM("010001:00100:rt:c1dr:00000:000000"), "%t, %1",   ADDR_TYPE_NONE, 0 ),
	ID( "ctc1",        VM("010001:00110:rt:c1cr:00000:000000"), "%t, %p",   ADDR_TYPE_NONE, 0 ),

	// Compare <condition>
	ID( "c.f.s",       VM("010001:10000:ft:fs:00000:11:0000"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.un.s",      VM("010001:10000:ft:fs:00000:11:0001"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.eq.s",      VM("010001:10000:ft:fs:00000:11:0010"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.ueq.s",     VM("010001:10000:ft:fs:00000:11:0011"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.olt.s",     VM("010001:10000:ft:fs:00000:11:0100"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.ult.s",     VM("010001:10000:ft:fs:00000:11:0101"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.ole.s",     VM("010001:10000:ft:fs:00000:11:0110"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.ule.s",     VM("010001:10000:ft:fs:00000:11:0111"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.sf.s",      VM("010001:10000:ft:fs:00000:11:1000"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.ngle.s",    VM("010001:10000:ft:fs:00000:11:1001"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.seq.s",     VM("010001:10000:ft:fs:00000:11:1010"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.ngl.s",     VM("010001:10000:ft:fs:00000:11:1011"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.lt.s",      VM("010001:10000:ft:fs:00000:11:1100"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.nge.s",     VM("010001:10000:ft:fs:00000:11:1101"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.le.s",      VM("010001:10000:ft:fs:00000:11:1110"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
	ID( "c.ngt.s",     VM("010001:10000:ft:fs:00000:11:1111"), "%S, %T",    ADDR_TYPE_NONE, 0 ),
];

const PspInstructions_SPECIAL = [
	ID( "syscall",     VM("000000:imm20:001100" ), "%C",     ADDR_TYPE_NONE, 0 ),

	ID( "cache",       VM(0xbc000000, 0xfc000000), "%k, %o", ADDR_TYPE_NONE, 0 ),
	ID( "sync",        VM("00000000000000000000000000001111"), "", ADDR_TYPE_NONE, 0 ),

	ID( "break",       VM("000000:imm20:001101" ), "%c",     ADDR_TYPE_NONE, 0 ),
	ID( "dbreak",      VM(0x7000003F, 0xFFFFFFFF), "",       ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "halt",        VM("011100:00000:00000:00000:00000:000000"), "" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),

	ID( "dret",        VM(0x7000003E, 0xFFFFFFFF), "",       ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "eret",        VM("010000:10000:00000:00000:00000:011000"), "",       ADDR_TYPE_NONE, 0 ),

	ID( "mfic",        VM("011100:rt:00000:00000:00000:100100"), "%t, %p", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "mtic",        VM("011100:rt:00000:00000:00000:100110"), "%t, %p", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),

	ID( "mfdr",        VM(0x7000003D, 0xFFE007FF), "%t, %r", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "mtdr",        VM(0x7080003D, 0xFFE007FF), "%t, %r", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
];

const PspInstructions_COP0 = [
	ID( "cfc0",        VM(0x40400000, 0xFFE007FF), "%t, %p", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "ctc0",        VM(0x40C00000, 0xFFE007FF), "%t, %p", ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "mfc0",        VM(0x40000000, 0xFFE007FF), "%t, %0", ADDR_TYPE_NONE, 0 ),
	ID( "mtc0",        VM(0x40800000, 0xFFE007FF), "%t, %0", ADDR_TYPE_NONE, 0 ),
];

const PspInstructions_VFPU = [
	ID( "bvf",         VM(0x49000000, 0xFFE30000), "%Zc, %O" , ADDR_TYPE_16, INSTR_TYPE_PSP | INSTR_TYPE_B ),
	ID( "bvfl",        VM(0x49020000, 0xFFE30000), "%Zc, %O" , ADDR_TYPE_16, INSTR_TYPE_PSP | INSTR_TYPE_B ),
	ID( "bvt",         VM(0x49010000, 0xFFE30000), "%Zc, %O" , ADDR_TYPE_16, INSTR_TYPE_PSP | INSTR_TYPE_B ),
	ID( "bvtl",        VM(0x49030000, 0xFFE30000), "%Zc, %O" , ADDR_TYPE_16, INSTR_TYPE_PSP | INSTR_TYPE_B ),
	ID( "lv.q",        VM(0xD8000000, 0xFC000002), "%Xq, %Y" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "lv.s",        VM(0xC8000000, 0xFC000000), "%Xs, %Y" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "lvl.q",       VM(0xD4000000, 0xFC000002), "%Xq, %Y" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "lvr.q",       VM(0xD4000002, 0xFC000002), "%Xq, %Y" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),

	// prxtool had problems with that.
	ID( "mfv",         VM(0x48600000, 0xFFE0FF80), "%t, %zs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "mfvc",        VM(0x48600080, 0xFFE0FF80), "%t, %2d" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "mtv",         VM(0x48E00000, 0xFFE0FF80), "%t, %zs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "mtvc",        VM(0x48E00080, 0xFFE0FF80), "%t, %2d" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),

	ID( "sv.q",        VM(0xF8000000, 0xFC000002), "%Xq, %Y" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "sv.s",        VM(0xE8000000, 0xFC000000), "%Xs, %Y" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "svl.q",       VM(0xF4000000, 0xFC000002), "%Xq, %Y" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "svr.q",       VM(0xF4000002, 0xFC000002), "%Xq, %Y" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vabs.p",      VM(0xD0010080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vabs.q",      VM(0xD0018080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vabs.s",      VM(0xD0010000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vabs.t",      VM(0xD0018000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vadd.p",      VM(0x60000080, 0xFF808080), "%zp, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vadd.q",      VM(0x60008080, 0xFF808080), "%zq, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vadd.s",      VM(0x60000000, 0xFF808080), "%zs, %ys, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vadd.t",      VM(0x60008000, 0xFF808080), "%zt, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vasin.p",     VM(0xD0170080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vasin.q",     VM(0xD0178080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vasin.s",     VM(0xD0170000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vasin.t",     VM(0xD0178000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vavg.p",      VM(0xD0470080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vavg.q",      VM(0xD0478080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vavg.t",      VM(0xD0478000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vbfy1.p",     VM(0xD0420080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vbfy1.q",     VM(0xD0428080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vbfy2.q",     VM(0xD0438080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmovf.p",    VM(0xD2A80080, 0xFFF88080), "%zp, %yp, %v3" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmovf.q",    VM(0xD2A88080, 0xFFF88080), "%zq, %yq, %v3" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmovf.s",    VM(0xD2A80000, 0xFFF88080), "%zs, %ys, %v3" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmovf.t",    VM(0xD2A88000, 0xFFF88080), "%zt, %yt, %v3" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmovt.p",    VM(0xD2A00080, 0xFFF88080), "%zp, %yp, %v3" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmovt.q",    VM(0xD2A08080, 0xFFF88080), "%zq, %yq, %v3" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmovt.s",    VM(0xD2A00000, 0xFFF88080), "%zs, %ys, %v3" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmovt.t",    VM(0xD2A08000, 0xFFF88080), "%zt, %yt, %v3" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	
	// Problems.
	/+
	ID( "vcmp.p",      VM(0x6C000080, 0xFF8080F0), "%Zn, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmp.p",      VM(0x6C000080, 0xFFFF80F0), "%Zn, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmp.p",      VM(0x6C000080, 0xFFFFFFF0), "%Zn" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmp.q",      VM(0x6C008080, 0xFF8080F0), "%Zn, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmp.q",      VM(0x6C008080, 0xFFFF80F0), "%Zn, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmp.q",      VM(0x6C008080, 0xFFFFFFF0), "%Zn" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmp.s",      VM(0x6C000000, 0xFF8080F0), "%Zn, %ys, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmp.s",      VM(0x6C000000, 0xFFFF80F0), "%Zn, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmp.s",      VM(0x6C000000, 0xFFFFFFF0), "%Zn" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmp.t",      VM(0x6C008000, 0xFF8080F0), "%Zn, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmp.t",      VM(0x6C008000, 0xFFFF80F0), "%Zn, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcmp.t",      VM(0x6C008000, 0xFFFFFFF0), "%Zn" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	+/
	ID( "vcos.p",      VM(0xD0130080, 0xFFFF8080), "%zp, %yp" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcos.q",      VM(0xD0138080, 0xFFFF8080), "%zq, %yq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcos.s",      VM(0xD0130000, 0xFFFF8080), "%zs, %ys" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcos.t",      VM(0xD0138000, 0xFFFF8080), "%zt, %yt" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcrs.t",      VM(0x66808000, 0xFF808080), "%zt, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcrsp.t",     VM(0xF2808000, 0xFF808080), "%zt, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcst.p",      VM(0xD0600080, 0xFFE0FF80), "%zp, %vk" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcst.q",      VM(0xD0608080, 0xFFE0FF80), "%zq, %vk" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcst.s",      VM(0xD0600000, 0xFFE0FF80), "%zs, %vk" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vcst.t",      VM(0xD0608000, 0xFFE0FF80), "%zt, %vk" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vdet.p",      VM(0x67000080, 0xFF808080), "%zs, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vdiv.p",      VM(0x63800080, 0xFF808080), "%zp, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vdiv.q",      VM(0x63808080, 0xFF808080), "%zq, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vdiv.s",      VM(0x63800000, 0xFF808080), "%zs, %ys, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vdiv.t",      VM(0x63808000, 0xFF808080), "%zt, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vdot.p",      VM(0x64800080, 0xFF808080), "%zs, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vdot.q",      VM(0x64808080, 0xFF808080), "%zs, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vdot.t",      VM(0x64808000, 0xFF808080), "%zs, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vexp2.p",     VM(0xD0140080, 0xFFFF8080), "%zp, %yp" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vexp2.q",     VM(0xD0148080, 0xFFFF8080), "%zq, %yq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vexp2.s",     VM(0xD0140000, 0xFFFF8080), "%zs, %ys" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vexp2.t",     VM(0xD0148000, 0xFFFF8080), "%zt, %yt" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2h.p",      VM(0xD0320080, 0xFFFF8080), "%zs, %yp" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2h.q",      VM(0xD0328080, 0xFFFF8080), "%zp, %yq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2id.p",     VM(0xD2600080, 0xFFE08080), "%zp, %yp, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2id.q",     VM(0xD2608080, 0xFFE08080), "%zq, %yq, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2id.s",     VM(0xD2600000, 0xFFE08080), "%zs, %ys, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2id.t",     VM(0xD2608000, 0xFFE08080), "%zt, %yt, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2in.p",     VM(0xD2000080, 0xFFE08080), "%zp, %yp, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2in.q",     VM(0xD2008080, 0xFFE08080), "%zq, %yq, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2in.s",     VM(0xD2000000, 0xFFE08080), "%zs, %ys, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2in.t",     VM(0xD2008000, 0xFFE08080), "%zt, %yt, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2iu.p",     VM(0xD2400080, 0xFFE08080), "%zp, %yp, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2iu.q",     VM(0xD2408080, 0xFFE08080), "%zq, %yq, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2iu.s",     VM(0xD2400000, 0xFFE08080), "%zs, %ys, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2iu.t",     VM(0xD2408000, 0xFFE08080), "%zt, %yt, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2iz.p",     VM(0xD2200080, 0xFFE08080), "%zp, %yp, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2iz.q",     VM(0xD2208080, 0xFFE08080), "%zq, %yq, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2iz.s",     VM(0xD2200000, 0xFFE08080), "%zs, %ys, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vf2iz.t",     VM(0xD2208000, 0xFFE08080), "%zt, %yt, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vfad.p",      VM(0xD0460080, 0xFFFF8080), "%zp, %yp" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vfad.q",      VM(0xD0468080, 0xFFFF8080), "%zq, %yq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vfad.t",      VM(0xD0468000, 0xFFFF8080), "%zt, %yt" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vfim.s",      VM(0xDF800000, 0xFF800000), "%xs, %vh" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vflush",      VM(0xFFFF040D, 0xFFFFFFFF), "" ,              ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vh2f.p",      VM(0xD0330080, 0xFFFF8080), "%zq, %yp" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vh2f.s",      VM(0xD0330000, 0xFFFF8080), "%zp, %ys" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vhdp.p",      VM(0x66000080, 0xFF808080), "%zs, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vhdp.q",      VM(0x66008080, 0xFF808080), "%zs, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vhdp.t",      VM(0x66008000, 0xFF808080), "%zs, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vhtfm2.p",    VM(0xF0800000, 0xFF808080), "%zp, %ym, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vhtfm3.t",    VM(0xF1000080, 0xFF808080), "%zt, %yn, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vhtfm4.q",    VM(0xF1808000, 0xFF808080), "%zq, %yo, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vi2c.q",      VM(0xD03D8080, 0xFFFF8080), "%zs, %yq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vi2f.p",      VM(0xD2800080, 0xFFE08080), "%zp, %yp, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vi2f.q",      VM(0xD2808080, 0xFFE08080), "%zq, %yq, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vi2f.s",      VM(0xD2800000, 0xFFE08080), "%zs, %ys, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vi2f.t",      VM(0xD2808000, 0xFFE08080), "%zt, %yt, %v5" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vi2s.p",      VM(0xD03F0080, 0xFFFF8080), "%zs, %yp" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vi2s.q",      VM(0xD03F8080, 0xFFFF8080), "%zp, %yq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vi2uc.q",     VM(0xD03C8080, 0xFFFF8080), "%zq, %yq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vi2us.p",     VM(0xD03E0080, 0xFFFF8080), "%zq, %yq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vi2us.q",     VM(0xD03E8080, 0xFFFF8080), "%zq, %yq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vidt.p",      VM(0xD0030080, 0xFFFFFF80), "%zp" ,           ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vidt.q",      VM(0xD0038080, 0xFFFFFF80), "%zq" ,           ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "viim.s",      VM(0xDF000000, 0xFF800000), "%xs, %vi" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vlgb.s",      VM(0xD0370000, 0xFFFF8080), "%zs, %ys" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vlog2.p",     VM(0xD0150080, 0xFFFF8080), "%zp, %yp" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vlog2.q",     VM(0xD0158080, 0xFFFF8080), "%zq, %yq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vlog2.s",     VM(0xD0150000, 0xFFFF8080), "%zs, %ys" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vlog2.t",     VM(0xD0158000, 0xFFFF8080), "%zt, %yt" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmax.p",      VM(0x6D800080, 0xFF808080), "%zp, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmax.q",      VM(0x6D808080, 0xFF808080), "%zq, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmax.s",      VM(0x6D800000, 0xFF808080), "%zs, %ys, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmax.t",      VM(0x6D808000, 0xFF808080), "%zt, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmfvc",       VM(0xD0500000, 0xFFFF0080), "%zs, %2s" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmidt.p",     VM(0xF3830080, 0xFFFFFF80), "%zm" ,           ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmidt.q",     VM(0xF3838080, 0xFFFFFF80), "%zo" ,           ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmidt.t",     VM(0xF3838000, 0xFFFFFF80), "%zn" ,           ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmin.p",      VM(0x6D000080, 0xFF808080), "%zp, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmin.q",      VM(0x6D008080, 0xFF808080), "%zq, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmin.s",      VM(0x6D000000, 0xFF808080), "%zs, %ys, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmin.t",      VM(0x6D008000, 0xFF808080), "%zt, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmmov.p",     VM(0xF3800080, 0xFFFF8080), "%zm, %ym" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmmov.q",     VM(0xF3808080, 0xFFFF8080), "%zo, %yo" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmmov.t",     VM(0xF3808000, 0xFFFF8080), "%zn, %yn" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmmul.p",     VM(0xF0000080, 0xFF808080), "%?%zm, %ym, %xm" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmmul.q",     VM(0xF0008080, 0xFF808080), "%?%zo, %yo, %xo" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmmul.t",     VM(0xF0008000, 0xFF808080), "%?%zn, %yn, %xn" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmone.p",     VM(0xF3870080, 0xFFFFFF80), "%zp" ,           ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmone.q",     VM(0xF3878080, 0xFFFFFF80), "%zq" ,           ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmone.t",     VM(0xF3878000, 0xFFFFFF80), "%zt" ,           ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmov.p",      VM(0xD0000080, 0xFFFF8080), "%zp, %yp" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmov.q",      VM(0xD0008080, 0xFFFF8080), "%zq, %yq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmov.s",      VM(0xD0000000, 0xFFFF8080), "%zs, %ys" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmov.t",      VM(0xD0008000, 0xFFFF8080), "%zt, %yt" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmscl.p",     VM(0xF2000080, 0xFF808080), "%zm, %ym, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmscl.q",     VM(0xF2008080, 0xFF808080), "%zo, %yo, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmscl.t",     VM(0xF2008000, 0xFF808080), "%zn, %yn, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmtvc",       VM(0xD0510000, 0xFFFF8000), "%2d, %ys" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmul.p",      VM(0x64000080, 0xFF808080), "%zp, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmul.q",      VM(0x64008080, 0xFF808080), "%zq, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmul.s",      VM(0x64000000, 0xFF808080), "%zs, %ys, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmul.t",      VM(0x64008000, 0xFF808080), "%zt, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmzero.p",    VM(0xF3860080, 0xFFFFFF80), "%zm" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmzero.q",    VM(0xF3868080, 0xFFFFFF80), "%zo" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vmzero.t",    VM(0xF3868000, 0xFFFFFF80), "%zn" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vneg.p",      VM(0xD0020080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vneg.q",      VM(0xD0028080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vneg.s",      VM(0xD0020000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vneg.t",      VM(0xD0028000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vnop",        VM(0xFFFF0000, 0xFFFFFFFF), "" ,         ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vnrcp.p",     VM(0xD0180080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vnrcp.q",     VM(0xD0188080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vnrcp.s",     VM(0xD0180000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vnrcp.t",     VM(0xD0188000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vnsin.p",     VM(0xD01A0080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vnsin.q",     VM(0xD01A8080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vnsin.s",     VM(0xD01A0000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vnsin.t",     VM(0xD01A8000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vocp.p",      VM(0xD0440080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vocp.q",      VM(0xD0448080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vocp.s",      VM(0xD0440000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vocp.t",      VM(0xD0448000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vone.p",      VM(0xD0070080, 0xFFFFFF80), "%zp" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vone.q",      VM(0xD0078080, 0xFFFFFF80), "%zq" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vone.s",      VM(0xD0070000, 0xFFFFFF80), "%zs" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vone.t",      VM(0xD0078000, 0xFFFFFF80), "%zt" ,      ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vpfxd",       VM(0xDE000000, 0xFF000000), "[%vp4, %vp5, %vp6, %vp7]" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vpfxs",       VM(0xDC000000, 0xFF000000), "[%vp0, %vp1, %vp2, %vp3]" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vpfxt",       VM(0xDD000000, 0xFF000000), "[%vp0, %vp1, %vp2, %vp3]" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vqmul.q",     VM(0xF2808080, 0xFF808080), "%zq, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrcp.p",      VM(0xD0100080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrcp.q",      VM(0xD0108080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrcp.s",      VM(0xD0100000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrcp.t",      VM(0xD0108000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrexp2.p",    VM(0xD01C0080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrexp2.q",    VM(0xD01C8080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrexp2.s",    VM(0xD01C0000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrexp2.t",    VM(0xD01C8000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndf1.p",    VM(0xD0220080, 0xFFFFFF80), "%zp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndf1.q",    VM(0xD0228080, 0xFFFFFF80), "%zq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndf1.s",    VM(0xD0220000, 0xFFFFFF80), "%zs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndf1.t",    VM(0xD0228000, 0xFFFFFF80), "%zt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndf2.p",    VM(0xD0230080, 0xFFFFFF80), "%zp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndf2.q",    VM(0xD0238080, 0xFFFFFF80), "%zq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndf2.s",    VM(0xD0230000, 0xFFFFFF80), "%zs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndf2.t",    VM(0xD0238000, 0xFFFFFF80), "%zt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndi.p",     VM(0xD0210080, 0xFFFFFF80), "%zp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndi.q",     VM(0xD0218080, 0xFFFFFF80), "%zq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndi.s",     VM(0xD0210000, 0xFFFFFF80), "%zs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrndi.t",     VM(0xD0218000, 0xFFFFFF80), "%zt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrnds.s",     VM(0xD0200000, 0xFFFF80FF), "%ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrot.p",      VM(0xF3A00080, 0xFFE08080), "%zp, %ys, %vr" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrot.q",      VM(0xF3A08080, 0xFFE08080), "%zq, %ys, %vr" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrot.t",      VM(0xF3A08000, 0xFFE08080), "%zt, %ys, %vr" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrsq.p",      VM(0xD0110080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrsq.q",      VM(0xD0118080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrsq.s",      VM(0xD0110000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vrsq.t",      VM(0xD0118000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vs2i.p",      VM(0xD03B0080, 0xFFFF8080), "%zq, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vs2i.s",      VM(0xD03B0000, 0xFFFF8080), "%zp, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsat0.p",     VM(0xD0040080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsat0.q",     VM(0xD0048080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsat0.s",     VM(0xD0040000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsat0.t",     VM(0xD0048000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsat1.p",     VM(0xD0050080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsat1.q",     VM(0xD0058080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsat1.s",     VM(0xD0050000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsat1.t",     VM(0xD0058000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsbn.s",      VM(0x61000000, 0xFF808080), "%zs, %ys, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsbz.s",      VM(0xD0360000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vscl.p",      VM(0x65000080, 0xFF808080), "%zp, %yp, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vscl.q",      VM(0x65008080, 0xFF808080), "%zq, %yq, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vscl.t",      VM(0x65008000, 0xFF808080), "%zt, %yt, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vscmp.p",     VM(0x6E800080, 0xFF808080), "%zp, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vscmp.q",     VM(0x6E808080, 0xFF808080), "%zq, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vscmp.s",     VM(0x6E800000, 0xFF808080), "%zs, %ys, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vscmp.t",     VM(0x6E808000, 0xFF808080), "%zt, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsge.p",      VM(0x6F000080, 0xFF808080), "%zp, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsge.q",      VM(0x6F008080, 0xFF808080), "%zq, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsge.s",      VM(0x6F000000, 0xFF808080), "%zs, %ys, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsge.t",      VM(0x6F008000, 0xFF808080), "%zt, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsgn.p",      VM(0xD04A0080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsgn.q",      VM(0xD04A8080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsgn.s",      VM(0xD04A0000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsgn.t",      VM(0xD04A8000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsin.p",      VM(0xD0120080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsin.q",      VM(0xD0128080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsin.s",      VM(0xD0120000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsin.t",      VM(0xD0128000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vslt.p",      VM(0x6F800080, 0xFF808080), "%zp, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vslt.q",      VM(0x6F808080, 0xFF808080), "%zq, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vslt.s",      VM(0x6F800000, 0xFF808080), "%zs, %ys, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vslt.t",      VM(0x6F808000, 0xFF808080), "%zt, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsocp.p",     VM(0xD0450080, 0xFFFF8080), "%zq, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsocp.s",     VM(0xD0450000, 0xFFFF8080), "%zp, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsqrt.p",     VM(0xD0160080, 0xFFFF8080), "%zp, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsqrt.q",     VM(0xD0168080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsqrt.s",     VM(0xD0160000, 0xFFFF8080), "%zs, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsqrt.t",     VM(0xD0168000, 0xFFFF8080), "%zt, %yt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsrt1.q",     VM(0xD0408080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsrt2.q",     VM(0xD0418080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsrt3.q",     VM(0xD0488080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsrt4.q",     VM(0xD0498080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsub.p",      VM(0x60800080, 0xFF808080), "%zp, %yp, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsub.q",      VM(0x60808080, 0xFF808080), "%zq, %yq, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsub.s",      VM(0x60800000, 0xFF808080), "%zs, %ys, %xs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsub.t",      VM(0x60808000, 0xFF808080), "%zt, %yt, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vsync",       VM(0xFFFF0320, 0xFFFFFFFF), "" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vt4444.q",    VM(0xD0598080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vt5551.q",    VM(0xD05A8080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vt5650.q",    VM(0xD05B8080, 0xFFFF8080), "%zq, %yq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vtfm2.p",     VM(0xF0800080, 0xFF808080), "%zp, %ym, %xp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vtfm3.t",     VM(0xF1008000, 0xFF808080), "%zt, %yn, %xt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vtfm4.q",     VM(0xF1808080, 0xFF808080), "%zq, %yo, %xq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vus2i.p",     VM(0xD03A0080, 0xFFFF8080), "%zq, %yp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vus2i.s",     VM(0xD03A0000, 0xFFFF8080), "%zp, %ys" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vwb.q",       VM(0xF8000002, 0xFC000002), "%Xq, %Y" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vwbn.s",      VM(0xD3000000, 0xFF008080), "%zs, %xs, %I" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vzero.p",     VM(0xD0060080, 0xFFFFFF80), "%zp" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vzero.q",     VM(0xD0068080, 0xFFFFFF80), "%zq" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vzero.s",     VM(0xD0060000, 0xFFFFFF80), "%zs" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "vzero.t",     VM(0xD0068000, 0xFFFFFF80), "%zt" , ADDR_TYPE_NONE, INSTR_TYPE_PSP ),
	ID( "mfvme",       VM(0x68000000, 0xFC000000), "%t, %i", ADDR_TYPE_NONE, 0 ),
	ID( "mtvme",       VM(0xb0000000, 0xFC000000), "%t, %i", ADDR_TYPE_NONE, 0 ),
];

ID[] PspInstructions() {
	return (
		PspInstructions_ALU ~
		PspInstructions_BCU ~
		PspInstructions_LSU ~
		PspInstructions_FPU ~
		PspInstructions_COP0 ~
		//PspInstructions_VFPU ~
		PspInstructions_SPECIAL
	);
}

/*
struct IsaEntry {
	string name;
	string format;
}

const AllegrexIsa = [
	IsaEntry("VIDT", "110100:00:000:0:0011:two:0000000:one:vd"),
];

import pspemu.core.cpu.Switch;
//pragma(msg, genSwitch(PspInstructions));
*/