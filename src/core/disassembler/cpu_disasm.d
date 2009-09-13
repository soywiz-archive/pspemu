module psp.disassembler.cpu;

import std.stdio;
import std.string;

class CPU_Disasm {
	static bool reg_raw = false;
	static bool use_macro = true;
	//static bool use_macro = false;

	static const char[] regName[0x20] = [
		"zr", "at", "v0", "v1", "a0", "a1", "a2", "a3",
		"t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7", 
		"s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7",
		"t8", "t9", "k0", "k1", "gp", "sp", "fp", "ra"
	];	
	
	static const char[] cop0_regs[32] = [
		null, null, null, null, null, null, null, null, 
		"BadVaddr", "Count", null, "Compare", "Status", "Cause", "EPC", "PrID",
		"Config", null, null, null, null, null, null, null,
		null, "EBase", null, null, "TagLo", "TagHi", "ErrorPC", null
	];

	static const char[] dr_regs[16] = [	
		"DRCNTL", "DEPC", "DDATA0", "DDATA1", "IBC", "DBC", null, null, 
		"IBA", "IBAM", null, null, "DBA", "DBAM", "DBD", "DBDM"
	];	
	
	static Instruction getins(uint i) {
		foreach (ins_l; use_macro ? [g_macro, g_inst] : [g_inst])		
		foreach (ins; ins_l) if ((i & ins.mask) == ins.opcode) return ins;		
		throw(new Exception(std.string.format("Invalid instruction 0x%08X", i)));
	}	

	static struct Instruction {
		const char[] name;
		uint   opcode;
		uint   mask;
		const char[] fmt;
		int    addrtype;
		int    type;
	}
	
	static struct RInstruction {
		char[] text;
		Instruction ins;
		uint[] params;
	}
	
	static enum ADDR_TYPE {
		NUL = 0,
		T16 = 1,
		T26 = 2,
		REG = 3,
	}

	static enum INSTR_TYPE {
		PSP  = 1,
		B    = 2,
		JUMP = 4,
		JAL  = 8,
	}
	
	// Tables grabbed from prxtool (TyRaNiD) from ps2dev

	static const Instruction g_macro[] = [
		/* Macro instructions */
		{ "nop",0x00000000, 0xFFFFFFFF,"", ADDR_TYPE.NUL, 0 },
		{ "li",0x24000000, 0xFFE00000,"%t, %i", ADDR_TYPE.NUL, 0 },
		{ "li",0x34000000, 0xFFE00000,"%t, %I", ADDR_TYPE.NUL, 0 },
		{ "move",0x00000021, 0xFC1F07FF,"%d, %s", ADDR_TYPE.NUL, 0 },
		{ "move",0x00000025, 0xFC1F07FF,"%d, %s", ADDR_TYPE.NUL, 0 },
		{ "b",0x10000000, 0xFFFF0000,"%O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "b",0x04010000, 0xFFFF0000,"%O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "bal",0x04110000, 0xFFFF0000,"%O", ADDR_TYPE.T16, INSTR_TYPE.JAL },
		{ "bnez",0x14000000, 0xFC1F0000,"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "bnezl",0x54000000, 0xFC1F0000,"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "beqz",0x10000000, 0xFC1F0000,"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "beqzl",0x50000000, 0xFC1F0000,"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "neg",0x00000022, 0xFFE007FF,"%d, %t"	, ADDR_TYPE.NUL, 0 },
		{ "negu",0x00000023, 0xFFE007FF,"%d, %t", ADDR_TYPE.NUL, 0 },
		{ "not",0x00000027, 0xFC1F07FF,"%d, %s", ADDR_TYPE.NUL, 0 },
		{ "jalr",0x0000F809, 0xFC1FFFFF,"%J", ADDR_TYPE.REG, INSTR_TYPE.JAL },
	];
	
	static const Instruction g_inst[] = [
		/* MIPS instructions */
		{ "add",		0x00000020, 0xFC0007FF, "%d, %s, %t", ADDR_TYPE.NUL, 0 },
		{ "addi",		0x20000000, 0xFC000000, "%t, %s, %i", ADDR_TYPE.NUL, 0 },
		{ "addiu",		0x24000000, 0xFC000000, "%t, %s, %i", ADDR_TYPE.NUL, 0 },
		{ "addu",		0x00000021, 0xFC0007FF, "%d, %s, %t", ADDR_TYPE.NUL, 0 },
		{ "and",		0x00000024, 0xFC0007FF,	"%d, %s, %t", ADDR_TYPE.NUL, 0 },
		{ "andi",		0x30000000, 0xFC000000,	"%t, %s, %I", ADDR_TYPE.NUL, 0 },
		{ "beq",		0x10000000, 0xFC000000,	"%s, %t, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "beql",		0x50000000, 0xFC000000,	"%s, %t, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "bgez",		0x04010000, 0xFC1F0000,	"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "bgezal",		0x04110000, 0xFC1F0000,	"%s, %0", ADDR_TYPE.T16, INSTR_TYPE.JAL },
		{ "bgezl",		0x04030000, 0xFC1F0000,	"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "bgtz",		0x1C000000, 0xFC1F0000,	"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "bgtzl",		0x5C000000, 0xFC1F0000,	"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "bitrev",		0x7C000520, 0xFFE007FF, "%d, %t", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "blez",		0x18000000, 0xFC1F0000,	"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "blezl",		0x58000000, 0xFC1F0000,	"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "bltz",		0x04000000, 0xFC1F0000,	"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "bltzl",		0x04020000, 0xFC1F0000,	"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "bltzal",		0x04100000, 0xFC1F0000,	"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.JAL },
		{ "bltzall",	0x04120000, 0xFC1F0000,	"%s, %O", ADDR_TYPE.T16, INSTR_TYPE.JAL },
		{ "bne",		0x14000000, 0xFC000000,	"%s, %t, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "bnel",		0x54000000, 0xFC000000,	"%s, %t, %O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{ "break",		0x0000000D, 0xFC00003F,	"%c", ADDR_TYPE.NUL, 0 },
		{ "cache",		0xbc000000, 0xfc000000, "%k, %o", ADDR_TYPE.NUL, 0 },
		{ "cfc0",		0x40400000, 0xFFE007FF,	"%t, %p", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "clo",		0x00000017, 0xFC1F07FF, "%d, %s", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "clz",		0x00000016, 0xFC1F07FF, "%d, %s", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "ctc0",		0x40C00000, 0xFFE007FF,	"%t, %p", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "max",		0x0000002C, 0xFC0007FF, "%d, %s, %t", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "min",		0x0000002D, 0xFC0007FF, "%d, %s, %t", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "dbreak",		0x7000003F, 0xFFFFFFFF,	"", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "div",		0x0000001A, 0xFC00FFFF, "%s, %t", ADDR_TYPE.NUL, 0 },
		{ "divu",		0x0000001B, 0xFC00FFFF, "%s, %t", ADDR_TYPE.NUL, 0 },
		{ "dret",		0x7000003E, 0xFFFFFFFF,	"", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "eret",		0x42000018, 0xFFFFFFFF, "", ADDR_TYPE.NUL, 0 },
		{ "ext",		0x7C000000, 0xFC00003F, "%t, %s, %a, %ne", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "ins",		0x7C000004, 0xFC00003F, "%t, %s, %a, %ni", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "j",			0x08000000, 0xFC000000,	"%j", ADDR_TYPE.T26, INSTR_TYPE.JUMP },
		{ "jr",			0x00000008, 0xFC1FFFFF,	"%J", ADDR_TYPE.REG, INSTR_TYPE.JUMP },
		{ "jalr",		0x00000009, 0xFC1F07FF,	"%J, %d", ADDR_TYPE.REG, INSTR_TYPE.JAL },
		{ "jal",		0x0C000000, 0xFC000000,	"%j", ADDR_TYPE.T26, INSTR_TYPE.JAL },
		{ "lb",			0x80000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "lbu",		0x90000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "lh",			0x84000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "lhu",		0x94000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "ll",			0xC0000000, 0xFC000000,	"%t, %O", ADDR_TYPE.NUL, 0 },
		{ "lui",		0x3C000000, 0xFFE00000,	"%t, %I", ADDR_TYPE.NUL, 0 },
		{ "lw",			0x8C000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "lwl",		0x88000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "lwr",		0x98000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "madd",		0x0000001C, 0xFC00FFFF, "%s, %t", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "maddu",		0x0000001D, 0xFC00FFFF, "%s, %t", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "mfc0",		0x40000000, 0xFFE007FF,	"%t, %0", ADDR_TYPE.NUL, 0 },
		{ "mfdr",		0x7000003D, 0xFFE007FF,	"%t, %r", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "mfhi",		0x00000010, 0xFFFF07FF, "%d", ADDR_TYPE.NUL, 0 },
		{ "mfic",		0x70000024, 0xFFE007FF, "%t, %p", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "mflo",		0x00000012, 0xFFFF07FF, "%d", ADDR_TYPE.NUL, 0 },
		{ "movn",		0x0000000B, 0xFC0007FF, "%d, %s, %t", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "movz",		0x0000000A, 0xFC0007FF, "%d, %s, %t", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "msub",		0x0000002e, 0xfc00ffff, "%d, %t", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "msubu",		0x0000002f, 0xfc00ffff, "%d, %t", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "mtc0",		0x40800000, 0xFFE007FF,	"%t, %0", ADDR_TYPE.NUL, 0 },
		{ "mtdr",		0x7080003D, 0xFFE007FF,	"%t, %r", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "mtic",		0x70000026, 0xFFE007FF, "%t, %p", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "halt",       0x70000000, 0xFFFFFFFF, "" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "mthi",		0x00000011, 0xFC1FFFFF,	"%s", ADDR_TYPE.NUL, 0 },
		{ "mtlo",		0x00000013, 0xFC1FFFFF,	"%s", ADDR_TYPE.NUL, 0 },
		{ "mult",		0x00000018, 0xFC00FFFF, "%s, %t", ADDR_TYPE.NUL, 0 },
		{ "multu",		0x00000019, 0xFC0007FF, "%s, %t", ADDR_TYPE.NUL, 0 },
		{ "nor",		0x00000027, 0xFC0007FF,	"%d, %s, %t", ADDR_TYPE.NUL, 0 },
		{ "or",			0x00000025, 0xFC0007FF,	"%d, %s, %t", ADDR_TYPE.NUL, 0 },
		{ "ori",		0x34000000, 0xFC000000,	"%t, %s, %I", ADDR_TYPE.NUL, 0 },
		{ "rotr",		0x00200002, 0xFFE0003F, "%d, %t, %a", ADDR_TYPE.NUL, 0 },
		{ "rotv",		0x00000046, 0xFC0007FF, "%d, %t, %s", ADDR_TYPE.NUL, 0 },
		{ "seb",		0x7C000420, 0xFFE007FF,	"%d, %t", ADDR_TYPE.NUL, 0 },
		{ "seh",		0x7C000620, 0xFFE007FF,	"%d, %t", ADDR_TYPE.NUL, 0 },
		{ "sb",			0xA0000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "sh",			0xA4000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "sllv",		0x00000004, 0xFC0007FF,	"%d, %t, %s", ADDR_TYPE.NUL, 0 },
		{ "sll",		0x00000000, 0xFFE0003F,	"%d, %t, %a", ADDR_TYPE.NUL, 0 },
		{ "slt",		0x0000002A, 0xFC0007FF,	"%d, %s, %t", ADDR_TYPE.NUL, 0 },
		{ "slti",		0x28000000, 0xFC000000,	"%t, %s, %i", ADDR_TYPE.NUL, 0 },
		{ "sltiu",		0x2C000000, 0xFC000000,	"%t, %s, %i", ADDR_TYPE.NUL, 0 },
		{ "sltu",		0x0000002B, 0xFC0007FF,	"%d, %s, %t", ADDR_TYPE.NUL, 0 },
		{ "sra",		0x00000003, 0xFFE0003F,	"%d, %t, %a", ADDR_TYPE.NUL, 0 },
		{ "srav",		0x00000007, 0xFC0007FF,	"%d, %t, %s", ADDR_TYPE.NUL, 0 },
		{ "srlv",		0x00000006, 0xFC0007FF,	"%d, %t, %s", ADDR_TYPE.NUL, 0 },
		{ "srl",		0x00000002, 0xFFE0003F,	"%d, %t, %a", ADDR_TYPE.NUL, 0 },
		{ "sw",			0xAC000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "swl",		0xA8000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "swr",		0xB8000000, 0xFC000000,	"%t, %o", ADDR_TYPE.NUL, 0 },
		{ "sub",		0x00000022, 0xFC0007FF,	"%d, %s, %t", ADDR_TYPE.NUL, 0 },
		{ "subu",		0x00000023, 0xFC0007FF,	"%d, %s, %t", ADDR_TYPE.NUL, 0 },
		{ "sync",		0x0000000F, 0xFFFFFFFF,	"", ADDR_TYPE.NUL, 0 },
		{ "syscall",	0x0000000C, 0xFC00003F,	"%C", ADDR_TYPE.NUL, 0 },
		{ "xor",		0x00000026, 0xFC0007FF,	"%d, %s, %t", ADDR_TYPE.NUL, 0 },
		{ "xori",		0x38000000, 0xFC000000,	"%t, %s, %I", ADDR_TYPE.NUL, 0 },
		{ "wsbh",		0x7C0000A0, 0xFFE007FF,	"%d, %t", ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "wsbw",		0x7C0000E0, 0xFFE007FF, "%d, %t", ADDR_TYPE.NUL, INSTR_TYPE.PSP }, 

		/* FPU instructions */
		{"abs.s",	0x46000005, 0xFFFF003F, "%D, %S", ADDR_TYPE.NUL, 0 },
		{"add.s",	0x46000000, 0xFFE0003F,	"%D, %S, %T", ADDR_TYPE.NUL, 0 },
		{"bc1f",	0x45000000, 0xFFFF0000,	"%O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{"bc1fl",	0x45020000, 0xFFFF0000,	"%O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{"bc1t",	0x45010000, 0xFFFF0000,	"%O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{"bc1tl",	0x45030000, 0xFFFF0000,	"%O", ADDR_TYPE.T16, INSTR_TYPE.B },
		{"c.f.s",	0x46000030, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.un.s",	0x46000031, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.eq.s",	0x46000032, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.ueq.s",	0x46000033, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.olt.s",	0x46000034, 0xFFE007FF,	"%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.ult.s",	0x46000035, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.ole.s",	0x46000036, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.ule.s",	0x46000037, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.sf.s",	0x46000038, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.ngle.s",0x46000039, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.seq.s",	0x4600003A, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.ngl.s",	0x4600003B, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.lt.s",	0x4600003C, 0xFFE007FF,	"%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.nge.s",	0x4600003D, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.le.s",	0x4600003E, 0xFFE007FF,	"%S, %T", ADDR_TYPE.NUL, 0 },
		{"c.ngt.s",	0x4600003F, 0xFFE007FF, "%S, %T", ADDR_TYPE.NUL, 0 },
		{"ceil.w.s",0x4600000E, 0xFFFF003F, "%D, %S", ADDR_TYPE.NUL, 0 },
		{"cfc1",	0x44400000, 0xFFE007FF, "%t, %p", ADDR_TYPE.NUL, 0 },
		{"ctc1",	0x44c00000, 0xFFE007FF, "%t, %p", ADDR_TYPE.NUL, 0 },
		{"cvt.s.w",	0x46800020, 0xFFFF003F, "%D, %S", ADDR_TYPE.NUL, 0 },
		{"cvt.w.s",	0x46000024, 0xFFFF003F, "%D, %S", ADDR_TYPE.NUL, 0 },
		{"div.s",	0x46000003, 0xFFE0003F, "%D, %S, %T", ADDR_TYPE.NUL, 0 },
		{"floor.w.s",0x4600000F, 0xFFFF003F,"%D, %S", ADDR_TYPE.NUL, 0 },
		{"lwc1",	0xc4000000, 0xFC000000, "%T, %o", ADDR_TYPE.NUL, 0 },
		{"mfc1",	0x44000000, 0xFFE007FF, "%t, %1", ADDR_TYPE.NUL, 0 },
		{"mov.s",	0x46000006, 0xFFFF003F, "%D, %S", ADDR_TYPE.NUL, 0 },
		{"mtc1",	0x44800000, 0xFFE007FF, "%t, %1", ADDR_TYPE.NUL, 0 },
		{"mul.s",	0x46000002, 0xFFE0003F, "%D, %S, %T", ADDR_TYPE.NUL, 0 },
		{"neg.s",	0x46000007, 0xFFFF003F, "%D, %S", ADDR_TYPE.NUL, 0 },
		{"round.w.s",0x4600000C, 0xFFFF003F,"%D, %S", ADDR_TYPE.NUL, 0 },
		{"sqrt.s",	0x46000004, 0xFFFF003F, "%D, %S", ADDR_TYPE.NUL, 0 },
		{"sub.s",	0x46000001, 0xFFE0003F, "%D, %S, %T", ADDR_TYPE.NUL, 0 },
		{"swc1",	0xe4000000, 0xFC000000, "%T, %o", ADDR_TYPE.NUL, 0 },
		{"trunc.w.s",0x4600000D, 0xFFFF003F,"%D, %S", ADDR_TYPE.NUL, 0 },

		/* VPU instructions */
		{ "bvf",	 0x49000000, 0xFFE30000, "%Zc, %O" , ADDR_TYPE.T16, INSTR_TYPE.PSP | INSTR_TYPE.B }, // [hlide] %Z -> %Zc
		{ "bvfl",	 0x49020000, 0xFFE30000, "%Zc, %O" , ADDR_TYPE.T16, INSTR_TYPE.PSP | INSTR_TYPE.B }, // [hlide] %Z -> %Zc
		{ "bvt",	 0x49010000, 0xFFE30000, "%Zc, %O" , ADDR_TYPE.T16, INSTR_TYPE.PSP | INSTR_TYPE.B }, // [hlide] %Z -> %Zc
		{ "bvtl",	 0x49030000, 0xFFE30000, "%Zc, %O" , ADDR_TYPE.T16, INSTR_TYPE.PSP | INSTR_TYPE.B }, // [hlide] %Z -> %Zc
		{ "lv.q",	 0xD8000000, 0xFC000002, "%Xq, %Y" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "lv.s",	 0xC8000000, 0xFC000000, "%Xs, %Y" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "lvl.q",	 0xD4000000, 0xFC000002, "%Xq, %Y" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "lvr.q",	 0xD4000002, 0xFC000002, "%Xq, %Y" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "mfv",	 0x48600000, 0xFFE0FF80, "%t, %zs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%t, %zs"
		{ "mfvc",	 0x48600000, 0xFFE0FF00, "%t, %2d" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%t, %2d"
		{ "mtv",	 0x48E00000, 0xFFE0FF80, "%t, %zs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%t, %zs"
		{ "mtvc",	 0x48E00000, 0xFFE0FF00, "%t, %2d" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%t, %2d"
		{ "sv.q",	 0xF8000000, 0xFC000002, "%Xq, %Y" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "sv.s",	 0xE8000000, 0xFC000000, "%Xs, %Y" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "svl.q",	 0xF4000000, 0xFC000002, "%Xq, %Y" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "svr.q",	 0xF4000002, 0xFC000002, "%Xq, %Y" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vabs.p",	 0xD0010080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vabs.q",	 0xD0018080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vabs.s",	 0xD0010000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vabs.t",	 0xD0018000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vadd.p",	 0x60000080, 0xFF808080, "%zp, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vadd.q",	 0x60008080, 0xFF808080, "%zq, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vadd.s",	 0x60000000, 0xFF808080, "%zs, %ys, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %yz -> %ys
		{ "vadd.t",	 0x60008000, 0xFF808080, "%zt, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vasin.p", 0xD0170080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vasin.q", 0xD0178080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vasin.s", 0xD0170000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vasin.t", 0xD0178000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vavg.p",	 0xD0470080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vavg.q",	 0xD0478080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vavg.t",	 0xD0478000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vbfy1.p", 0xD0420080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vbfy1.q", 0xD0428080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vbfy2.q", 0xD0438080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vcmovf.p", 0xD2A80080, 0xFFF88080, "%zp, %yp, %v3" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %yp, %v3"
		{ "vcmovf.q",0xD2A88080, 0xFFF88080, "%zq, %yq, %v3" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %yq, %v3"
		{ "vcmovf.s", 0xD2A80000, 0xFFF88080, "%zs, %ys, %v3" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %ys, %v3"
		{ "vcmovf.t",0xD2A88000, 0xFFF88080, "%zt, %yt, %v3" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zt, %yt, %v3"
		{ "vcmovt.p", 0xD2A00080, 0xFFF88080, "%zp, %yp, %v3" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %yp, %v3"
		{ "vcmovt.q",0xD2A08080, 0xFFF88080, "%zq, %yq, %v3" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %yq, %v3"
		{ "vcmovt.s", 0xD2A00000, 0xFFF88080, "%zs, %ys, %v3" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %ys, %v3"
		{ "vcmovt.t",0xD2A08000, 0xFFF88080, "%zt, %yt, %v3" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zt, %yt, %v3"
		{ "vcmp.p",	 0x6C000080, 0xFF8080F0, "%Zn, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%Zn, %zp, %xp"
		{ "vcmp.p",	 0x6C000080, 0xFFFF80F0, "%Zn, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%Zn, %xp"
		{ "vcmp.p",	 0x6C000080, 0xFFFFFFF0, "%Zn" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%Zn"
		{ "vcmp.q",	 0x6C008080, 0xFF8080F0, "%Zn, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%Zn, %yq, %xq"
		{ "vcmp.q",	 0x6C008080, 0xFFFF80F0, "%Zn, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%Zn, %yq"
		{ "vcmp.q",	 0x6C008080, 0xFFFFFFF0, "%Zn" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%Zn"
		{ "vcmp.s",	 0x6C000000, 0xFF8080F0, "%Zn, %ys, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%Zn, %ys, %xs"
		{ "vcmp.s",	 0x6C000000, 0xFFFF80F0, "%Zn, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%Zn, %ys"
		{ "vcmp.s",	 0x6C000000, 0xFFFFFFF0, "%Zn" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%Zn"
		{ "vcmp.t",	 0x6C008000, 0xFF8080F0, "%Zn, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%Zn, %yt, %xt"
		{ "vcmp.t",	 0x6C008000, 0xFFFF80F0, "%Zn, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%Zn, %yt"
		{ "vcmp.t",	 0x6C008000, 0xFFFFFFF0, "%Zn" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp"
		{ "vcos.p",	 0xD0130080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vcos.q",	 0xD0138080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vcos.s",	 0xD0130000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vcos.t",	 0xD0138000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vcrs.t",	 0x66808000, 0xFF808080, "%zt, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vcrsp.t", 0xF2808000, 0xFF808080, "%zt, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vcst.p",	 0xD0600080, 0xFFE0FF80, "%zp, %vk" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] "%zp, %yp, %xp" -> "%zp, %vk"
		{ "vcst.q",	 0xD0608080, 0xFFE0FF80, "%zq, %vk" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] "%zq, %yq, %xq" -> "%zq, %vk"
		{ "vcst.s",	 0xD0600000, 0xFFE0FF80, "%zs, %vk" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] "%zs, %ys, %xs" -> "%zs, %vk"
		{ "vcst.t",	 0xD0608000, 0xFFE0FF80, "%zt, %vk" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] "%zt, %yt, %xt" -> "%zt, %vk"
		{ "vdet.p",	 0x67000080, 0xFF808080, "%zs, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vdiv.p",	 0x63800080, 0xFF808080, "%zp, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vdiv.q",	 0x63808080, 0xFF808080, "%zq, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vdiv.s",	 0x63800000, 0xFF808080, "%zs, %ys, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %yz -> %ys
		{ "vdiv.t",	 0x63808000, 0xFF808080, "%zt, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vdot.p",	 0x64800080, 0xFF808080, "%zs, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vdot.q",	 0x64808080, 0xFF808080, "%zs, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vdot.t",	 0x64808000, 0xFF808080, "%zs, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vexp2.p", 0xD0140080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vexp2.q", 0xD0148080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vexp2.s", 0xD0140000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vexp2.t", 0xD0148000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vf2h.p",	 0xD0320080, 0xFFFF8080, "%zs, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zp -> %zs
		{ "vf2h.q",	 0xD0328080, 0xFFFF8080, "%zp, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zq -> %zp
		{ "vf2id.p", 0xD2600080, 0xFFE08080, "%zp, %yp, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %yp, %v5"
		{ "vf2id.q", 0xD2608080, 0xFFE08080, "%zq, %yq, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %yq, %v5"
		{ "vf2id.s", 0xD2600000, 0xFFE08080, "%zs, %ys, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %ys, %v5"
		{ "vf2id.t", 0xD2608000, 0xFFE08080, "%zt, %yt, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zt, %yt, %v5"
		{ "vf2in.p", 0xD2000080, 0xFFE08080, "%zp, %yp, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %yp, %v5"
		{ "vf2in.q", 0xD2008080, 0xFFE08080, "%zq, %yq, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %yq, %v5"
		{ "vf2in.s", 0xD2000000, 0xFFE08080, "%zs, %ys, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %ys, %v5"
		{ "vf2in.t", 0xD2008000, 0xFFE08080, "%zt, %yt, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zt, %yt, %v5"
		{ "vf2iu.p", 0xD2400080, 0xFFE08080, "%zp, %yp, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %yp, %v5"
		{ "vf2iu.q", 0xD2408080, 0xFFE08080, "%zq, %yq, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %yq, %v5"
		{ "vf2iu.s", 0xD2400000, 0xFFE08080, "%zs, %ys, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %ys, %v5"
		{ "vf2iu.t", 0xD2408000, 0xFFE08080, "%zt, %yt, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zt, %yt, %v5"
		{ "vf2iz.p", 0xD2200080, 0xFFE08080, "%zp, %yp, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %yp, %v5"
		{ "vf2iz.q", 0xD2208080, 0xFFE08080, "%zq, %yq, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %yq, %v5"
		{ "vf2iz.s", 0xD2200000, 0xFFE08080, "%zs, %ys, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %ys, %v5"
		{ "vf2iz.t", 0xD2208000, 0xFFE08080, "%zt, %yt, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zt, %yt, %v5"
		{ "vfad.p",	 0xD0460080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vfad.q",	 0xD0468080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vfad.t",	 0xD0468000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vfim.s",	 0xDF800000, 0xFF800000, "%xs, %vh" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%xs, %vh"
		{ "vflush",	 0xFFFF040D, 0xFFFFFFFF, "" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vh2f.p",	 0xD0330080, 0xFFFF8080, "%zq, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zp -> %zq
		{ "vh2f.s",	 0xD0330000, 0xFFFF8080, "%zp, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zs -> %zp
		{ "vhdp.p",	 0x66000080, 0xFF808080, "%zs, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %yp, %xp"
		{ "vhdp.q",	 0x66008080, 0xFF808080, "%zs, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %yq, %xq"
		{ "vhdp.t",	 0x66008000, 0xFF808080, "%zs, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %yt, %xt"
		{ "vhtfm2.p", 0xF0800000, 0xFF808080, "%zp, %ym, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %ym, %xp"
		{ "vhtfm3.t",0xF1000080, 0xFF808080, "%zt, %yn, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zt, %yn, %xt"
		{ "vhtfm4.q",0xF1808000, 0xFF808080, "%zq, %yo, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %yo, %xq"
		{ "vi2c.q",	 0xD03D8080, 0xFFFF8080, "%zs, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %yq"
		{ "vi2f.p",	 0xD2800080, 0xFFE08080, "%zp, %yp, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %yp, %v5"
		{ "vi2f.q",	 0xD2808080, 0xFFE08080, "%zq, %yq, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %yq, %v5"
		{ "vi2f.s",	 0xD2800000, 0xFFE08080, "%zs, %ys, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %ys, %v5"
		{ "vi2f.t",	 0xD2808000, 0xFFE08080, "%zt, %yt, %v5" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zt, %yt, %v5"
		{ "vi2s.p",	 0xD03F0080, 0xFFFF8080, "%zs, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %yp"
		{ "vi2s.q",	 0xD03F8080, 0xFFFF8080, "%zp, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %yq"
		{ "vi2uc.q", 0xD03C8080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zp -> %zq
		{ "vi2us.p", 0xD03E0080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zp -> %zq
		{ "vi2us.q", 0xD03E8080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zp -> %zq
		{ "vidt.p",	 0xD0030080, 0xFFFFFF80, "%zp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vidt.q",	 0xD0038080, 0xFFFFFF80, "%zq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "viim.s",	 0xDF000000, 0xFF800000, "%xs, %vi" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%xs, %vi"
		{ "vlgb.s",	 0xD0370000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vlog2.p", 0xD0150080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vlog2.q", 0xD0158080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vlog2.s", 0xD0150000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vlog2.t", 0xD0158000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmax.p",	 0x6D800080, 0xFF808080, "%zp, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmax.q",	 0x6D808080, 0xFF808080, "%zq, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmax.s",	 0x6D800000, 0xFF808080, "%zs, %ys, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmax.t",	 0x6D808000, 0xFF808080, "%zt, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmfvc",	 0xD0500000, 0xFFFF0080, "%zs, %2s" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zs, %2s"
		{ "vmidt.p", 0xF3830080, 0xFFFFFF80, "%zm" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zp -> %zm
		{ "vmidt.q", 0xF3838080, 0xFFFFFF80, "%zo" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zq -> %zo
		{ "vmidt.t", 0xF3838000, 0xFFFFFF80, "%zn" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zt -> %zn
		{ "vmin.p",	 0x6D000080, 0xFF808080, "%zp, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmin.q",	 0x6D008080, 0xFF808080, "%zq, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmin.s",	 0x6D000000, 0xFF808080, "%zs, %ys, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmin.t",	 0x6D008000, 0xFF808080, "%zt, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmmov.p", 0xF3800080, 0xFFFF8080, "%zm, %ym" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zm, %ym"
		{ "vmmov.q", 0xF3808080, 0xFFFF8080, "%zo, %yo" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmmov.t", 0xF3808000, 0xFFFF8080, "%zn, %yn" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zn, %yn"
		{ "vmmul.p", 0xF0000080, 0xFF808080, "%?%zm, %ym, %xm" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%?%zm, %ym, %xm"
		{ "vmmul.q", 0xF0008080, 0xFF808080, "%?%zo, %yo, %xo" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmmul.t", 0xF0008000, 0xFF808080, "%?%zn, %yn, %xn" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%?%zn, %yn, %xn"
		{ "vmone.p", 0xF3870080, 0xFFFFFF80, "%zp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmone.q", 0xF3878080, 0xFFFFFF80, "%zq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmone.t", 0xF3878000, 0xFFFFFF80, "%zt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmov.p",	 0xD0000080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmov.q",	 0xD0008080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmov.s",	 0xD0000000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmov.t",	 0xD0008000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmscl.p", 0xF2000080, 0xFF808080, "%zm, %ym, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zp, %yp, %xp -> %zm, %ym, %xs
		{ "vmscl.q", 0xF2008080, 0xFF808080, "%zo, %yo, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zq, %yq, %xp -> %zo, %yo, %xs
		{ "vmscl.t", 0xF2008000, 0xFF808080, "%zn, %yn, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zt, %yt, %xp -> %zn, %yn, %xs
		{ "vmtvc",	 0xD0510000, 0xFFFF8000, "%2d, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%2d, %ys"
		{ "vmul.p",	 0x64000080, 0xFF808080, "%zp, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmul.q",	 0x64008080, 0xFF808080, "%zq, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmul.s",	 0x64000000, 0xFF808080, "%zs, %ys, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmul.t",	 0x64008000, 0xFF808080, "%zt, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vmzero.p", 0xF3860080, 0xFFFFFF80, "%zm" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zp -> %zm
		{ "vmzero.q",0xF3868080, 0xFFFFFF80, "%zo" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zq -> %zo
		{ "vmzero.t",0xF3868000, 0xFFFFFF80, "%zn" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zt -> %zn
		{ "vneg.p",	 0xD0020080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vneg.q",	 0xD0028080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vneg.s",	 0xD0020000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vneg.t",	 0xD0028000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vnop",	 0xFFFF0000, 0xFFFFFFFF, "" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vnrcp.p", 0xD0180080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vnrcp.q", 0xD0188080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vnrcp.s", 0xD0180000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vnrcp.t", 0xD0188000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vnsin.p", 0xD01A0080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vnsin.q", 0xD01A8080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vnsin.s", 0xD01A0000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vnsin.t", 0xD01A8000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vocp.p",	 0xD0440080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vocp.q",	 0xD0448080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vocp.s",	 0xD0440000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vocp.t",	 0xD0448000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vone.p",	 0xD0070080, 0xFFFFFF80, "%zp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vone.q",	 0xD0078080, 0xFFFFFF80, "%zq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vone.s",	 0xD0070000, 0xFFFFFF80, "%zs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vone.t",	 0xD0078000, 0xFFFFFF80, "%zt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vpfxd",	 0xDE000000, 0xFF000000, "[%vp4, %vp5, %vp6, %vp7]" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "[%vp4, %vp5, %vp6, %vp7]"
		{ "vpfxs",	 0xDC000000, 0xFF000000, "[%vp0, %vp1, %vp2, %vp3]" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "[%vp0, %vp1, %vp2, %vp3]"
		{ "vpfxt",	 0xDD000000, 0xFF000000, "[%vp0, %vp1, %vp2, %vp3]" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "[%vp0, %vp1, %vp2, %vp3]"
		{ "vqmul.q", 0xF2808080, 0xFF808080, "%zq, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %yq, %xq"
		{ "vrcp.p",	 0xD0100080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrcp.q",	 0xD0108080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrcp.s",	 0xD0100000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrcp.t",	 0xD0108000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrexp2.p",0xD01C0080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrexp2.q",0xD01C8080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrexp2.s", 0xD01C0000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrexp2.t",0xD01C8000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndf1.p", 0xD0220080, 0xFFFFFF80, "%zp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndf1.q",0xD0228080, 0xFFFFFF80, "%zq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndf1.s", 0xD0220000, 0xFFFFFF80, "%zs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndf1.t",0xD0228000, 0xFFFFFF80, "%zt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndf2.p", 0xD0230080, 0xFFFFFF80, "%zp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndf2.q",0xD0238080, 0xFFFFFF80, "%zq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndf2.s", 0xD0230000, 0xFFFFFF80, "%zs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndf2.t",0xD0238000, 0xFFFFFF80, "%zt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndi.p", 0xD0210080, 0xFFFFFF80, "%zp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndi.q", 0xD0218080, 0xFFFFFF80, "%zq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndi.s", 0xD0210000, 0xFFFFFF80, "%zs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrndi.t", 0xD0218000, 0xFFFFFF80, "%zt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrnds.s", 0xD0200000, 0xFFFF80FF, "%ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrot.p",	 0xF3A00080, 0xFFE08080, "%zp, %ys, %vr" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %ys, %vr"
		{ "vrot.q",	 0xF3A08080, 0xFFE08080, "%zq, %ys, %vr" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %ys, %vr"
		{ "vrot.t",	 0xF3A08000, 0xFFE08080, "%zt, %ys, %vr" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zt, %ys, %vr"
		{ "vrsq.p",	 0xD0110080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrsq.q",	 0xD0118080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrsq.s",	 0xD0110000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vrsq.t",	 0xD0118000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vs2i.p",	 0xD03B0080, 0xFFFF8080, "%zq, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zp -> %zq
		{ "vs2i.s",	 0xD03B0000, 0xFFFF8080, "%zp, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zs -> %zp
		{ "vsat0.p", 0xD0040080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsat0.q", 0xD0048080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsat0.s", 0xD0040000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsat0.t", 0xD0048000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsat1.p", 0xD0050080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsat1.q", 0xD0058080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsat1.s", 0xD0050000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsat1.t", 0xD0058000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsbn.s",	 0x61000000, 0xFF808080, "%zs, %ys, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsbz.s",	 0xD0360000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vscl.p",	 0x65000080, 0xFF808080, "%zp, %yp, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %xp -> %xs
		{ "vscl.q",	 0x65008080, 0xFF808080, "%zq, %yq, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %xq -> %xs
		{ "vscl.t",	 0x65008000, 0xFF808080, "%zt, %yt, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %xt -> %xs
		{ "vscmp.p", 0x6E800080, 0xFF808080, "%zp, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vscmp.q", 0x6E808080, 0xFF808080, "%zq, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vscmp.s", 0x6E800000, 0xFF808080, "%zs, %ys, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vscmp.t", 0x6E808000, 0xFF808080, "%zt, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsge.p",	 0x6F000080, 0xFF808080, "%zp, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsge.q",	 0x6F008080, 0xFF808080, "%zq, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsge.s",	 0x6F000000, 0xFF808080, "%zs, %ys, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsge.t",	 0x6F008000, 0xFF808080, "%zt, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsgn.p",	 0xD04A0080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsgn.q",	 0xD04A8080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsgn.s",	 0xD04A0000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsgn.t",	 0xD04A8000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsin.p",	 0xD0120080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsin.q",	 0xD0128080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsin.s",	 0xD0120000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsin.t",	 0xD0128000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vslt.p",	 0x6F800080, 0xFF808080, "%zp, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vslt.q",	 0x6F808080, 0xFF808080, "%zq, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vslt.s",	 0x6F800000, 0xFF808080, "%zs, %ys, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vslt.t",	 0x6F808000, 0xFF808080, "%zt, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsocp.p", 0xD0450080, 0xFFFF8080, "%zq, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zp -> %zq
		{ "vsocp.s", 0xD0450000, 0xFFFF8080, "%zp, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zs -> %zp
		{ "vsqrt.p", 0xD0160080, 0xFFFF8080, "%zp, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsqrt.q", 0xD0168080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsqrt.s", 0xD0160000, 0xFFFF8080, "%zs, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsqrt.t", 0xD0168000, 0xFFFF8080, "%zt, %yt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsrt1.q", 0xD0408080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsrt2.q", 0xD0418080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsrt3.q", 0xD0488080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsrt4.q", 0xD0498080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsub.p",	 0x60800080, 0xFF808080, "%zp, %yp, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsub.q",	 0x60808080, 0xFF808080, "%zq, %yq, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsub.s",	 0x60800000, 0xFF808080, "%zs, %ys, %xs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsub.t",	 0x60808000, 0xFF808080, "%zt, %yt, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsync",	 0xFFFF0000, 0xFFFF0000, "%I" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vsync",	 0xFFFF0320, 0xFFFFFFFF, "" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vt4444.q",0xD0598080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zq -> %zp
		{ "vt5551.q",0xD05A8080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zq -> %zp
		{ "vt5650.q",0xD05B8080, 0xFFFF8080, "%zq, %yq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] %zq -> %zp
		{ "vtfm2.p", 0xF0800080, 0xFF808080, "%zp, %ym, %xp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %ym, %xp"
		{ "vtfm3.t", 0xF1008000, 0xFF808080, "%zt, %yn, %xt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zt, %yn, %xt"
		{ "vtfm4.q", 0xF1808080, 0xFF808080, "%zq, %yo, %xq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %yo, %xq"
		{ "vus2i.p", 0xD03A0080, 0xFFFF8080, "%zq, %yp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zq, %yp"
		{ "vus2i.s", 0xD03A0000, 0xFFFF8080, "%zp, %ys" , ADDR_TYPE.NUL, INSTR_TYPE.PSP }, // [hlide] added "%zp, %ys"
		{ "vwb.q",	 0xF8000002, 0xFC000002, "%Xq, %Y" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vwbn.s",	 0xD3000000, 0xFF008080, "%zs, %xs, %I" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vzero.p", 0xD0060080, 0xFFFFFF80, "%zp" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vzero.q", 0xD0068080, 0xFFFFFF80, "%zq" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vzero.s", 0xD0060000, 0xFFFFFF80, "%zs" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "vzero.t", 0xD0068000, 0xFFFFFF80, "%zt" , ADDR_TYPE.NUL, INSTR_TYPE.PSP },
		{ "mfvme", 0x68000000, 0xFC000000, "%t, %i", ADDR_TYPE.NUL, 0 },
		{ "mtvme", 0xb0000000, 0xFC000000, "%t, %i", ADDR_TYPE.NUL, 0 },
	];
	
	static const char[][0x3000] s_break = [
		0x0007 : "divide by zero",
		0x1C00 : "divide by zero",
	];

	static const char[][0x3000] s_syscall = [
		0x2000 : "_sceKernelRegisterSubIntrHandler",
		0x2001 : "_sceKernelReleaseSubIntrHandler",
		0x2002 : "_sceKernelEnableSubIntr",
		0x2003 : "_sceKernelDisableSubIntr",
		0x2004 : "_sceKernelSuspendSubIntr",
		0x2005 : "_sceKernelResumeSubIntr",
		0x2006 : "_sceKernelIsSubInterruptOccurred",
		0x2007 : "_QueryIntrHandlerInfo",
		0x2008 : "_sceKernelRegisterUserSpaceIntrStack",
		0x2009 : "__sceKernelReturnFromCallback",
		0x200a : "_sceKernelRegisterThreadEventHandler",
		0x200b : "_sceKernelReleaseThreadEventHandler",
		0x200c : "_sceKernelReferThreadEventHandlerStatus",
		0x200d : "_sceKernelCreateCallback",
		0x200e : "_sceKernelDeleteCallback",
		0x200f : "_sceKernelNotifyCallback",
		0x2010 : "_sceKernelCancelCallback",
		0x2011 : "_sceKernelGetCallbackCount",
		0x2012 : "_sceKernelCheckCallback",
		0x2013 : "_sceKernelReferCallbackStatus",
		0x2014 : "_sceKernelSleepThread",
		0x2015 : "_sceKernelSleepThreadCB",
		0x2016 : "_sceKernelWakeupThread",
		0x2017 : "_sceKernelCancelWakeupThread",
		0x2018 : "_sceKernelSuspendThread",
		0x2019 : "_sceKernelResumeThread",
		0x201a : "_sceKernelWaitThreadEnd",
		0x201b : "_sceKernelWaitThreadEndCB",
		0x201c : "_sceKernelDelayThread",
		0x201d : "_sceKernelDelayThreadCB",
		0x201e : "_sceKernelDelaySysClockThread",
		0x201f : "_sceKernelDelaySysClockThreadCB",
		0x2020 : "_sceKernelCreateSema",
		0x2021 : "_sceKernelDeleteSema",
		0x2022 : "_sceKernelSignalSema",
		0x2023 : "_sceKernelWaitSema",
		0x2024 : "_sceKernelWaitSemaCB",
		0x2025 : "_sceKernelPollSema",
		0x2026 : "_sceKernelCancelSema",
		0x2027 : "_sceKernelReferSemaStatus",
		0x2028 : "_sceKernelCreateEventFlag",
		0x2029 : "_sceKernelDeleteEventFlag",
		0x202a : "_sceKernelSetEventFlag",
		0x202b : "_sceKernelClearEventFlag",
		0x202c : "_sceKernelWaitEventFlag",
		0x202d : "_sceKernelWaitEventFlagCB",
		0x202e : "_sceKernelPollEventFlag",
		0x202f : "_sceKernelCancelEventFlag",
		0x2030 : "_sceKernelReferEventFlagStatus",
		0x2031 : "_sceKernelCreateMbx",
		0x2032 : "_sceKernelDeleteMbx",
		0x2033 : "_sceKernelSendMbx",
		0x2034 : "_sceKernelReceiveMbx",
		0x2035 : "_sceKernelReceiveMbxCB",
		0x2036 : "_sceKernelPollMbx",
		0x2037 : "_sceKernelCancelReceiveMbx",
		0x2038 : "_sceKernelReferMbxStatus",
		0x2039 : "_sceKernelCreateMsgPipe",
		0x203a : "_sceKernelDeleteMsgPipe",
		0x203b : "_sceKernelSendMsgPipe",
		0x203c : "_sceKernelSendMsgPipeCB",
		0x203d : "_sceKernelTrySendMsgPipe",
		0x203e : "_sceKernelReceiveMsgPipe",
		0x203f : "_sceKernelReceiveMsgPipeCB",
		0x2040 : "_sceKernelTryReceiveMsgPipe",
		0x2041 : "_sceKernelCancelMsgPipe",
		0x2042 : "_sceKernelReferMsgPipeStatus",
		0x2043 : "_sceKernelCreateVpl",
		0x2044 : "_sceKernelDeleteVpl",
		0x2045 : "_sceKernelAllocateVpl",
		0x2046 : "_sceKernelAllocateVplCB",
		0x2047 : "_sceKernelTryAllocateVpl",
		0x2048 : "_sceKernelFreeVpl",
		0x2049 : "_sceKernelCancelVpl",
		0x204a : "_sceKernelReferVplStatus",
		0x204b : "_sceKernelCreateFpl",
		0x204c : "_sceKernelDeleteFpl",
		0x204d : "_sceKernelAllocateFpl",
		0x204e : "_sceKernelAllocateFplCB",
		0x204f : "_sceKernelTryAllocateFpl",
		0x2050 : "_sceKernelFreeFpl",
		0x2051 : "_sceKernelCancelFpl",
		0x2052 : "_sceKernelReferFplStatus",
		0x2053 : "_ThreadManForUser_0E927AED",
		0x2054 : "_sceKernelUSec2SysClock",
		0x2055 : "_sceKernelUSec2SysClockWide",
		0x2056 : "_sceKernelSysClock2USec",
		0x2057 : "_sceKernelSysClock2USecWide",
		0x2058 : "_sceKernelGetSystemTime",
		0x2059 : "_sceKernelGetSystemTimeWide",
		0x205a : "_sceKernelGetSystemTimeLow",
		0x205b : "_sceKernelSetAlarm",
		0x205c : "_sceKernelSetSysClockAlarm",
		0x205d : "_sceKernelCancelAlarm",
		0x205e : "_sceKernelReferAlarmStatus",
		0x205f : "_sceKernelCreateVTimer",
		0x2060 : "_sceKernelDeleteVTimer",
		0x2061 : "_sceKernelGetVTimerBase",
		0x2062 : "_sceKernelGetVTimerBaseWide",
		0x2063 : "_sceKernelGetVTimerTime",
		0x2064 : "_sceKernelGetVTimerTimeWide",
		0x2065 : "_sceKernelSetVTimerTime",
		0x2066 : "_sceKernelSetVTimerTimeWide",
		0x2067 : "_sceKernelStartVTimer",
		0x2068 : "_sceKernelStopVTimer",
		0x2069 : "_sceKernelSetVTimerHandler",
		0x206a : "_sceKernelSetVTimerHandlerWide",
		0x206b : "_sceKernelCancelVTimerHandler",
		0x206c : "_sceKernelReferVTimerStatus",
		0x206d : "_sceKernelCreateThread",
		0x206e : "_sceKernelDeleteThread",
		0x206f : "_sceKernelStartThread",
		0x2070 : "__sceKernelExitThread",
		0x2071 : "_sceKernelExitThread",
		0x2072 : "_sceKernelExitDeleteThread",
		0x2073 : "_sceKernelTerminateThread",
		0x2074 : "_sceKernelTerminateDeleteThread",
		0x2075 : "_sceKernelSuspendDispatchThread",
		0x2076 : "_sceKernelResumeDispatchThread",
		0x2077 : "_sceKernelChangeCurrentThreadAttr",
		0x2078 : "_sceKernelChangeThreadPriority",
		0x2079 : "_sceKernelRotateThreadReadyQueue",
		0x207a : "_sceKernelReleaseWaitThread",
		0x207b : "_sceKernelGetThreadId",
		0x207c : "_sceKernelGetThreadCurrentPriority",
		0x207d : "_sceKernelGetThreadExitStatus",
		0x207e : "_sceKernelCheckThreadStack",
		0x207f : "_sceKernelGetThreadStackFreeSize",
		0x2080 : "_sceKernelReferThreadStatus",
		0x2081 : "_sceKernelReferThreadRunStatus",
		0x2082 : "_sceKernelReferSystemStatus",
		0x2083 : "_sceKernelGetThreadmanIdList",
		0x2084 : "_sceKernelGetThreadmanIdType",
		0x2085 : "_sceKernelReferThreadProfiler",
		0x2086 : "_sceKernelReferGlobalProfiler",
		0x2087 : "_sceIoPollAsync",
		0x2088 : "_sceIoWaitAsync",
		0x2089 : "_sceIoWaitAsyncCB",
		0x208a : "_sceIoGetAsyncStat",
		0x208b : "_sceIoChangeAsyncPriority",
		0x208c : "_sceIoSetAsyncCallback",
		0x208d : "_sceIoClose",
		0x208e : "_sceIoCloseAsync",
		0x208f : "_sceIoOpen",
		0x2090 : "_sceIoOpenAsync",
		0x2091 : "_sceIoRead",
		0x2092 : "_sceIoReadAsync",
		0x2093 : "_sceIoWrite",
		0x2094 : "_sceIoWriteAsync",
		0x2095 : "_sceIoLseek",
		0x2096 : "_sceIoLseekAsync",
		0x2097 : "_sceIoLseek32",
		0x2098 : "_sceIoLseek32Async",
		0x2099 : "_sceIoIoctl",
		0x209a : "_sceIoIoctlAsync",
		0x209b : "_sceIoDopen",
		0x209c : "_sceIoDread",
		0x209d : "_sceIoDclose",
		0x209e : "_sceIoRemove",
		0x209f : "_sceIoMkdir",
		0x20a0 : "_sceIoRmdir",
		0x20a1 : "_sceIoChdir",
		0x20a2 : "_sceIoSync",
		0x20a3 : "_sceIoGetstat",
		0x20a4 : "_sceIoChstat",
		0x20a5 : "_sceIoRename",
		0x20a6 : "_sceIoDevctl",
		0x20a7 : "_sceIoGetDevType",
		0x20a8 : "_sceIoAssign",
		0x20a9 : "_sceIoUnassign",
		0x20aa : "_sceIoCancel",
		0x20ab : "_IoFileMgrForUser_5C2BE2CC",
		0x20ac : "_sceKernelStdioRead",
		0x20ad : "_sceKernelStdioLseek",
		0x20ae : "_sceKernelStdioSendChar",
		0x20af : "_sceKernelStdioWrite",
		0x20b0 : "_sceKernelStdioClose",
		0x20b1 : "_sceKernelStdioOpen",
		0x20b2 : "_sceKernelStdin",
		0x20b3 : "_sceKernelStdout",
		0x20b4 : "_sceKernelStderr",
		0x20b5 : "_sceKernelDcacheInvalidateRange",
		0x20b6 : "_sceKernelIcacheInvalidateRange",
		0x20b7 : "_sceKernelUtilsMd5Digest",
		0x20b8 : "_sceKernelUtilsMd5BlockInit",
		0x20b9 : "_sceKernelUtilsMd5BlockUpdate",
		0x20ba : "_sceKernelUtilsMd5BlockResult",
		0x20bb : "_sceKernelUtilsSha1Digest",
		0x20bc : "_sceKernelUtilsSha1BlockInit",
		0x20bd : "_sceKernelUtilsSha1BlockUpdate",
		0x20be : "_sceKernelUtilsSha1BlockResult",
		0x20bf : "_sceKernelUtilsMt19937Init",
		0x20c0 : "_sceKernelUtilsMt19937UInt",
		0x20c1 : "_sceKernelGetGPI",
		0x20c2 : "_sceKernelSetGPO",
		0x20c3 : "_sceKernelLibcClock",
		0x20c4 : "_sceKernelLibcTime",
		0x20c5 : "_sceKernelLibcGettimeofday",
		0x20c6 : "_sceKernelDcacheWritebackAll",
		0x20c7 : "_sceKernelDcacheWritebackInvalidateAll",
		0x20c8 : "_sceKernelDcacheWritebackRange",
		0x20c9 : "_sceKernelDcacheWritebackInvalidateRange",
		0x20ca : "_sceKernelDcacheProbe",
		0x20cb : "_sceKernelDcacheReadTag",
		0x20cc : "_sceKernelIcacheInvalidateAll",
		0x20cd : "_sceKernelIcacheProbe",
		0x20ce : "_sceKernelIcacheReadTag",
		0x20cf : "_sceKernelLoadModule",
		0x20d0 : "_sceKernelLoadModuleByID",
		0x20d1 : "_sceKernelLoadModuleMs",
		0x20d2 : "_sceKernelLoadModuleBufferUsbWlan",
		0x20d3 : "_sceKernelStartModule",
		0x20d4 : "_sceKernelStopModule",
		0x20d5 : "_sceKernelUnloadModule",
		0x20d6 : "_sceKernelSelfStopUnloadModule",
		0x20d7 : "_sceKernelStopUnloadSelfModule",
		0x20d8 : "_sceKernelGetModuleIdList",
		0x20d9 : "_sceKernelQueryModuleInfo",
		0x20da : "_ModuleMgrForUser_F0A26395",
		0x20db : "_ModuleMgrForUser_D8B73127",
		0x20dc : "_sceKernelMaxFreeMemSize",
		0x20dd : "_sceKernelTotalFreeMemSize",
		0x20de : "_sceKernelAllocPartitionMemory",
		0x20df : "_sceKernelFreePartitionMemory",
		0x20e0 : "_sceKernelGetBlockHeadAddr",
		0x20e1 : "_SysMemUserForUser_13A5ABEF",
		0x20e2 : "_sceKernelDevkitVersion",
		0x20e3 : "_sceKernelPowerLock",
		0x20e4 : "_sceKernelPowerUnlock",
		0x20e5 : "_sceKernelPowerTick",
		0x20e6 : "_sceSuspendForUser_3E0271D3",
		0x20e7 : "_sceSuspendForUser_A14F40B2",
		0x20e8 : "_sceSuspendForUser_A569E425",
		0x20e9 : "_sceKernelLoadExec",
		0x20ea : "_sceKernelExitGameWithStatus",
		0x20eb : "_sceKernelExitGame",
		0x20ec : "_sceKernelRegisterExitCallback",
		0x20ed : "_sceDmacMemcpy",
		0x20ee : "_sceDmacTryMemcpy",
		0x20ef : "_sceGeEdramGetSize",
		0x20f0 : "_sceGeEdramGetAddr",
		0x20f1 : "_sceGeEdramSetAddrTranslation",
		0x20f2 : "_sceGeGetCmd",
		0x20f3 : "_sceGeGetMtx",
		0x20f4 : "_sceGeSaveContext",
		0x20f5 : "_sceGeRestoreContext",
		0x20f6 : "_sceGeListEnQueue",
		0x20f7 : "_sceGeListEnQueueHead",
		0x20f8 : "_sceGeListDeQueue",
		0x20f9 : "_sceGeListUpdateStallAddr",
		0x20fa : "_sceGeListSync",
		0x20fb : "_sceGeDrawSync",
		0x20fc : "_sceGeBreak",
		0x20fd : "_sceGeContinue",
		0x20fe : "_sceGeSetCallback",
		0x20ff : "_sceGeUnsetCallback",
		0x2100 : "_sceRtcGetTickResolution",
		0x2101 : "_sceRtcGetCurrentTick",
		0x2102 : "_sceRtc_011F03C1",
		0x2103 : "_sceRtc_029CA3B3",
		0x2104 : "_sceRtcGetCurrentClock",
		0x2105 : "_sceRtcGetCurrentClockLocalTime",
		0x2106 : "_sceRtcConvertUtcToLocalTime",
		0x2107 : "_sceRtcConvertLocalTimeToUTC",
		0x2108 : "_sceRtcIsLeapYear",
		0x2109 : "_sceRtcGetDaysInMonth",
		0x210a : "_sceRtcGetDayOfWeek",
		0x210b : "_sceRtcCheckValid",
		0x210c : "_sceRtcSetTime_t",
		0x210d : "_sceRtcGetTime_t",
		0x210e : "_sceRtcSetDosTime",
		0x210f : "_sceRtcGetDosTime",
		0x2110 : "_sceRtcSetWin32FileTime",
		0x2111 : "_sceRtcGetWin32FileTime",
		0x2112 : "_sceRtcSetTick",
		0x2113 : "_sceRtcGetTick",
		0x2114 : "_sceRtcCompareTick",
		0x2115 : "_sceRtcTickAddTicks",
		0x2116 : "_sceRtcTickAddMicroseconds",
		0x2117 : "_sceRtcTickAddSeconds",
		0x2118 : "_sceRtcTickAddMinutes",
		0x2119 : "_sceRtcTickAddHours",
		0x211a : "_sceRtcTickAddDays",
		0x211b : "_sceRtcTickAddWeeks",
		0x211c : "_sceRtcTickAddMonths",
		0x211d : "_sceRtcTickAddYears",
		0x211e : "_sceRtcFormatRFC2822",
		0x211f : "_sceRtcFormatRFC2822LocalTime",
		0x2120 : "_sceRtcFormatRFC3339",
		0x2121 : "_sceRtcFormatRFC3339LocalTime",
		0x2122 : "_sceRtcParseDateTime",
		0x2123 : "_sceRtcParseRFC3339",
		0x2124 : "_sceAudioOutput",
		0x2125 : "_sceAudioOutputBlocking",
		0x2126 : "_sceAudioOutputPanned",
		0x2127 : "_sceAudioOutputPannedBlocking",
		0x2128 : "_sceAudioChReserve",
		0x2129 : "_sceAudioOneshotOutput",
		0x212a : "_sceAudioChRelease",
		0x212b : "_sceAudio_B011922F",
		0x212c : "_sceAudioSetChannelDataLen",
		0x212d : "_sceAudioChangeChannelConfig",
		0x212e : "_sceAudioChangeChannelVolume",
		0x212f : "_sceAudio_38553111",
		0x2130 : "_sceAudio_5C37C0AE",
		0x2131 : "_sceAudio_E0727056",
		0x2132 : "_sceAudioInputBlocking",
		0x2133 : "_sceAudioInput",
		0x2134 : "_sceAudioGetInputLength",
		0x2135 : "_sceAudioWaitInputEnd",
		0x2136 : "_sceAudioInputInit",
		0x2137 : "_sceAudio_E926D3FB",
		0x2138 : "_sceAudio_A633048E",
		0x2139 : "_sceAudioGetChannelRestLen",
		0x213a : "_sceDisplaySetMode",
		0x213b : "_sceDisplayGetMode",
		0x213c : "_sceDisplayGetFramePerSec",
		0x213d : "_sceDisplaySetHoldMode",
		0x213e : "_sceDisplaySetResumeMode",
		0x213f : "_sceDisplaySetFrameBuf",
		0x2140 : "_sceDisplayGetFrameBuf",
		0x2141 : "_sceDisplayIsForeground",
		0x2142 : "_sceDisplayGetBrightness",
		0x2143 : "_sceDisplayGetVcount",
		0x2144 : "_sceDisplayIsVblank",
		0x2145 : "_sceDisplayWaitVblank",
		0x2146 : "_sceDisplayWaitVblankCB",
		0x2147 : "_sceDisplayWaitVblankStart",
		0x2148 : "_sceDisplayWaitVblankStartCB",
		0x2149 : "_sceDisplayGetCurrentHcount",
		0x214a : "_sceDisplayGetAccumulatedHcount",
		0x214b : "_sceDisplay_A83EF139",
		0x214c : "_sceCtrlSetSamplingCycle",
		0x214d : "_sceCtrlGetSamplingCycle",
		0x214e : "_sceCtrlSetSamplingMode",
		0x214f : "_sceCtrlGetSamplingMode",
		0x2150 : "_sceCtrlPeekBufferPositive",
		0x2151 : "_sceCtrlPeekBufferNegative",
		0x2152 : "_sceCtrlReadBufferPositive",
		0x2153 : "_sceCtrlReadBufferNegative",
		0x2154 : "_sceCtrlPeekLatch",
		0x2155 : "_sceCtrlReadLatch",
		0x2156 : "_sceCtrl_A7144800",
		0x2157 : "_sceCtrl_687660FA",
		0x2158 : "_sceCtrl_348D99D4",
		0x2159 : "_sceCtrl_AF5960F3",
		0x215a : "_sceCtrl_A68FD260",
		0x215b : "_sceCtrl_6841BE1A",
		0x215c : "_sceHprmRegisterCallback",
		0x215d : "_sceHprmUnregisterCallback",
		0x215e : "_sceHprm_71B5FB67",
		0x215f : "_sceHprmIsRemoteExist",
		0x2160 : "_sceHprmIsHeadphoneExist",
		0x2161 : "_sceHprmIsMicrophoneExist",
		0x2162 : "_sceHprmPeekCurrentKey",
		0x2163 : "_sceHprmPeekLatch",
		0x2164 : "_sceHprmReadLatch",
		0x2165 : "_scePower_2B51FE2F",
		0x2166 : "_scePower_442BFBAC",
		0x2167 : "_scePowerTick",
		0x2168 : "_scePowerGetIdleTimer",
		0x2169 : "_scePowerIdleTimerEnable",
		0x216a : "_scePowerIdleTimerDisable",
		0x216b : "_scePowerBatteryUpdateInfo",
		0x216c : "_scePower_E8E4E204",
		0x216d : "_scePowerGetLowBatteryCapacity",
		0x216e : "_scePowerIsPowerOnline",
		0x216f : "_scePowerIsBatteryExist",
		0x2170 : "_scePowerIsBatteryCharging",
		0x2171 : "_scePowerGetBatteryChargingStatus",
		0x2172 : "_scePowerIsLowBattery",
		0x2173 : "_scePower_78A1A796",
		0x2174 : "_scePowerGetBatteryRemainCapacity",
		0x2175 : "_scePower_FD18A0FF",
		0x2176 : "_scePowerGetBatteryLifePercent",
		0x2177 : "_scePowerGetBatteryLifeTime",
		0x2178 : "_scePowerGetBatteryTemp",
		0x2179 : "_scePowerGetBatteryElec",
		0x217a : "_scePowerGetBatteryVolt",
		0x217b : "_scePower_23436A4A",
		0x217c : "_scePower_0CD21B1F",
		0x217d : "_scePower_165CE085",
		0x217e : "_scePower_23C31FFE",
		0x217f : "_scePower_FA97A599",
		0x2180 : "_scePower_B3EDD801",
		0x2181 : "_scePowerLock",
		0x2182 : "_scePowerUnlock",
		0x2183 : "_scePowerCancelRequest",
		0x2184 : "_scePowerIsRequest",
		0x2185 : "_scePowerRequestStandby",
		0x2186 : "_scePowerRequestSuspend",
		0x2187 : "_scePower_2875994B",
		0x2188 : "_scePowerEncodeUBattery",
		0x2189 : "_scePowerGetResumeCount",
		0x218a : "_scePowerRegisterCallback",
		0x218b : "_scePowerUnregisterCallback",
		0x218c : "_scePowerUnregitserCallback",
		0x218d : "_scePowerSetCpuClockFrequency",
		0x218e : "_scePowerSetBusClockFrequency",
		0x218f : "_scePowerGetCpuClockFrequency",
		0x2190 : "_scePowerGetBusClockFrequency",
		0x2191 : "_scePowerGetCpuClockFrequencyInt",
		0x2192 : "_scePowerGetBusClockFrequencyInt",
		0x2193 : "_scePower_34F9C463",
		0x2194 : "_scePowerGetCpuClockFrequencyFloat",
		0x2195 : "_scePowerGetBusClockFrequencyFloat",
		0x2196 : "_scePower_EA382A27",
		0x2197 : "_scePowerSetClockFrequency",
		0x2198 : "_sceUsbStart",
		0x2199 : "_sceUsbStop",
		0x219a : "_sceUsbGetState",
		0x219b : "_sceUsbGetDrvList",
		0x219c : "_sceUsbGetDrvState",
		0x219d : "_sceUsbActivate",
		0x219e : "_sceUsbDeactivate",
		0x219f : "_sceUsbWaitState",
		0x21a0 : "_sceUsbWaitCancel",
		0x21a1 : "_sceOpenPSIDGetOpenPSID",
		0x21a2 : "_sceSircsSend",
		0x21a3 : "_sceUmdCheckMedium",
		0x21a4 : "_sceUmdActivate",
		0x21a5 : "_sceUmdDeactivate",
		0x21a6 : "_sceUmdWaitDriveStat",
		0x21a7 : "_sceUmdWaitDriveStatWithTimer",
		0x21a8 : "_sceUmdWaitDriveStatCB",
		0x21a9 : "_sceUmdCancelWaitDriveStat",
		0x21aa : "_sceUmdGetDriveStat",
		0x21ab : "_sceUmdGetErrorStat",
		0x21ac : "_sceUmdGetDiscInfo",
		0x21ad : "_sceUmdRegisterUMDCallBack",
		0x21ae : "_sceUmdUnRegisterUMDCallBack",
		0x21af : "_sceWlanDevIsPowerOn",
		0x21b0 : "_sceWlanGetSwitchState",
		0x21b1 : "_sceWlanGetEtherAddr",
		0x21b2 : "_sceWlanDevAttach",
		0x21b3 : "_sceWlanDevDetach",
		0x21b4 : "_sceWlanDrv_lib_19E51F54",
		0x21b5 : "_sceWlanDevIsGameMode",
		0x21b6 : "_sceWlanGPPrevEstablishActive",
		0x21b7 : "_sceWlanGPSend",
		0x21b8 : "_sceWlanGPRecv",
		0x21b9 : "_sceWlanGPRegisterCallback",
		0x21ba : "_sceWlanGPUnRegisterCallback",
		0x21bb : "_sceWlanDrv_lib_81579D36",
		0x21bc : "_sceWlanDrv_lib_5BAA1FE5",
		0x21bd : "_sceWlanDrv_lib_4C14BACA",
		0x21be : "_sceWlanDrv_lib_2D0FAE4E",
		0x21bf : "_sceWlanDrv_lib_56F467CA",
		0x21c0 : "_sceWlanDrv_lib_FE8A0B46",
		0x21c1 : "_sceWlanDrv_lib_40B0AA4A",
		0x21c2 : "_sceWlanDevSetGPIO",
		0x21c3 : "_sceWlanDevGetStateGPIO",
		0x21c4 : "_sceWlanDrv_lib_8D5F551B",
		0x21c5 : "_sceVaudioOutputBlocking",
		0x21c6 : "_sceVaudioChReserve",
		0x21c7 : "_sceVaudioChRelease",
		0x21c8 : "_sceVaudio_346FBE94",
		0x21c9 : "_sceRegExit",
		0x21ca : "_sceRegOpenRegistry",
		0x21cb : "_sceRegCloseRegistry",
		0x21cc : "_sceRegRemoveRegistry",
		0x21cd : "_sceReg_1D8A762E",
		0x21ce : "_sceReg_0CAE832B",
		0x21cf : "_sceRegFlushRegistry",
		0x21d0 : "_sceReg_0D69BF40",
		0x21d1 : "_sceRegCreateKey",
		0x21d2 : "_sceRegSetKeyValue",
		0x21d3 : "_sceRegGetKeyInfo",
		0x21d4 : "_sceRegGetKeyValue",
		0x21d5 : "_sceRegGetKeysNum",
		0x21d6 : "_sceRegGetKeys",
		0x21d7 : "_sceReg_4CA16893",
		0x21d8 : "_sceRegRemoveKey",
		0x21d9 : "_sceRegKickBackDiscover",
		0x21da : "_sceRegGetKeyValueByName",
		0x21db : "_sceUtilityGameSharingInitStart",
		0x21dc : "_sceUtilityGameSharingShutdownStart",
		0x21dd : "_sceUtilityGameSharingUpdate",
		0x21de : "_sceUtilityGameSharingGetStatus",
		0x21df : "_sceNetplayDialogInitStart",
		0x21e0 : "_sceNetplayDialogShutdownStart",
		0x21e1 : "_sceNetplayDialogUpdate",
		0x21e2 : "_sceNetplayDialogGetStatus",
		0x21e3 : "_sceUtilityNetconfInitStart",
		0x21e4 : "_sceUtilityNetconfShutdownStart",
		0x21e5 : "_sceUtilityNetconfUpdate",
		0x21e6 : "_sceUtilityNetconfGetStatus",
		0x21e7 : "_sceUtilitySavedataInitStart",
		0x21e8 : "_sceUtilitySavedataShutdownStart",
		0x21e9 : "_sceUtilitySavedataUpdate",
		0x21ea : "_sceUtilitySavedataGetStatus",
		0x21eb : "_sceUtility_2995D020",
		0x21ec : "_sceUtility_B62A4061",
		0x21ed : "_sceUtility_ED0FAD38",
		0x21ee : "_sceUtility_88BC7406",
		0x21ef : "_sceUtilityMsgDialogInitStart",
		0x21f0 : "_sceUtilityMsgDialogShutdownStart",
		0x21f1 : "_sceUtilityMsgDialogUpdate",
		0x21f2 : "_sceUtilityMsgDialogGetStatus",
		0x21f3 : "_sceUtilityOskInitStart",
		0x21f4 : "_sceUtilityOskShutdownStart",
		0x21f5 : "_sceUtilityOskUpdate",
		0x21f6 : "_sceUtilityOskGetStatus",
		0x21f7 : "_sceUtilitySetSystemParamInt",
		0x21f8 : "_sceUtilitySetSystemParamString",
		0x21f9 : "_sceUtilityGetSystemParamInt",
		0x21fa : "_sceUtilityGetSystemParamString",
		0x21fb : "_sceUtilityCheckNetParam",
		0x21fc : "_sceUtilityGetNetParam",
		0x21fd : "_sceUtility_private_17CB4D96",
		0x21fe : "_sceUtility_private_EE7AC503",
		0x21ff : "_sceUtility_private_5FF96ED3",
		0x2200 : "_sceUtility_private_9C9DD5BC",
		0x2201 : "_sceUtility_private_4405BA38",
		0x2202 : "_sceUtility_private_1DFA62EF",
		0x2203 : "_sceUtilityDialogSetStatus",
		0x2204 : "_sceUtilityDialogGetType",
		0x2205 : "_sceUtilityDialogGetParam",
		0x2206 : "_sceUtility_private_EF5BC2D1",
		0x2207 : "_sceUtilityDialogGetSpeed",
		0x2208 : "_sceUtility_private_19461966",
		0x2209 : "_sceUtilityDialogSetThreadId",
		0x220a : "_sceUtilityDialogLoadModule",
		0x220b : "_sceUtilityDialogPowerLock",
		0x220c : "_sceUtilityDialogPowerUnlock",
		0x220d : "_sceUtilityCreateNetParam",
		0x220e : "_sceUtilityDeleteNetParam",
		0x220f : "_sceUtilityCopyNetParam",
		0x2210 : "_sceUtilitySetNetParam",
	];	

	/*static const char[][uint] test = {
		10 : 1,
	};*/
	
/*
 * Format codes
 * %V - 16bit signed offset (rs base)
 * %0 - Cop0 register
 * %2? - Cop2 register (? is (s, d))
 * %p - General cop (i.e. numbered) register
 * %r - Debug register
 * %k - Cache function
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
 
	static char[] reg(uint r) {
		if (reg_raw) return std.string.format("r%d", r);
		return regName[r];
	}

	static char[] fpreg(uint r) {
		return std.string.format("f%d", r);		
	}

	static char[] sbreak(uint r) {
		if (s_break[r] == null) return "_unknown";
		return s_break[r];
	}
	
	static char[] syscall(uint r) {
		if (s_syscall[r] == null) return "_unknown";
		return s_syscall[r];
	}
	
	static RInstruction disasm(uint PC, uint OP) {
		PC += 4;
	
		Instruction ins = getins(OP);
		char[] params, fmt = ins.fmt;

		uint RT() { return ((OP >> 16) & 0x1F); }
		uint RS() { return ((OP >> 21) & 0x1F); }
		uint RD() { return ((OP >> 11) & 0x1F); }
		
		uint FT() { return ((OP >> 16) & 0x1F); }
		uint FS() { return ((OP >> 11) & 0x1F); }
		uint FD() { return ((OP >> 6)  & 0x1F); }
		
		uint SA() { return ((OP >> 6)  & 0x1F); }
		
		short IMM() { return (cast(short) (OP & 0xFFFF)); }
		ushort IMMU() { return (cast(ushort) (OP & 0xFFFF)); }
		uint JUMP() { return ((PC & 0xF0000000) | ((OP & 0x3FFFFFF) << 2)); }
		uint CODE() { return ((OP >> 6) & 0xFFFFF); }
		uint SIZE() { return ((OP >> 11) & 0x1F); }
		uint POS()  { return ((OP >> 6) & 0x1F); }
		uint VO()   { return (((OP & 3) << 5) | ((OP >> 16) & 0x1F)); }
		uint VCC()  { return ((OP >> 18) & 7); }
		uint VD()   { return (OP & 0x7F); }
		uint VS()   { return ((OP >> 8) & 0x7F); }
		uint VT()   { return ((OP >> 16) & 0x7F); }

		// [hlide] new #defines
		uint VED()  { return (OP & 0xFF); }
		uint VES()  { return ((OP >> 8) & 0xFF); }
		uint VCN()  { return (OP & 0x0F); }
		uint VI3()  { return ((OP >> 16) & 0x07); }
		uint VI5()  { return ((OP >> 16) & 0x1F); }
		uint VI8()  { return ((OP >> 16) & 0xFF); }
		
		//reg_raw = true;
		
		uint[] i_params;
		
		for (int n = 0; n < fmt.length; n++) {
			char c = fmt[n];
			
			if (c != '%') { params ~= c; continue; }
			
			switch (c = fmt[++n]) {
				// "%t, %s, %a, %ne"
				
				// Registers
				case 'd': params ~= reg(RD); i_params ~= RD; break;
				case 't': params ~= reg(RT); i_params ~= RT; break;
				case 's': params ~= reg(RS); i_params ~= RS; break;

				// FP Registers
				case 'D': params ~= fpreg(FD); i_params ~= RD; break;
				case 'T': params ~= fpreg(FT); i_params ~= RT; break;
				case 'S': params ~= fpreg(FS); i_params ~= RS; break;
				
				case '1': params ~= fpreg(FS); i_params ~= FS; break;
				
				case 'i': params ~= std.string.format("%d", IMM); i_params ~= IMM; break;
				case 'I': params ~= std.string.format("0x%04X", IMMU); i_params ~= IMMU; break;
				case 'a': params ~= std.string.format("%d", SA); i_params ~= SA; break;
				case 'c': params ~= std.string.format("0x%05X ; %s", CODE, sbreak(CODE)); i_params ~= CODE; break;
				case 'C': params ~= std.string.format("0x%05X ; %s", CODE, syscall(CODE)); i_params ~= CODE; break;
				case 'o': params ~= std.string.format("%s[%d]", reg(RS), IMM); i_params ~= RS; i_params ~= IMM; break;
				case 'O': params ~= std.string.format("0x%08X", PC + (IMM << 2)); i_params ~= PC + (IMM << 2); break;
				case 'j': params ~= std.string.format("0x%08X", JUMP()); i_params ~= JUMP; break;
				case 'J': params ~= reg(RS); i_params ~= RS; break;
				case 'n': // [hlide] completed %n? (? is e, i)
					switch (fmt[++n]) {
						case 'e' : params ~= std.string.format("%d", RD + 1); break;
						case 'i' : params ~= std.string.format("%d", RD - SA + 1); break;
						default: n--; break;
					}
					break;
					
				default:
					params ~= "%";
					params ~= c;
				break;
			}
		}
	
		return RInstruction(std.string.stripr(ins.name ~ " " ~ params), ins, i_params);
	}	
}