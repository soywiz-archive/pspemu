switch (OP >> 26) { // MASK[FC000000]
	// +-------------------------------+
	// |  FC000000 - Determined by CO  |
	// +-------------------------------+
	/* ADDI         */ case 0x20000000 >> 26: sRT = (RS + IMM ); PC = nPC; nPC += 4; continue; // ADD Immediate
	/* ADDIU        */ case 0x24000000 >> 26: sRT = (RS + IMM ); PC = nPC; nPC += 4; continue; // ADD Immediate Unsigned
	/* ANDI         */ case 0x30000000 >> 26: sRT = (RS & IMMU); PC = nPC; nPC += 4; continue; // AND Immediate
	/* BEQ          */ case 0x10000000 >> 26: PC = nPC; nPC += ((cast(int)RS) == cast(int)RT) ? (IMM << 2) : 4; continue; // Branch on Equal
	/* BEQL         */ case 0x50000000 >> 26: if (cast(int)RS == cast(int)RT) { PC = nPC; nPC += (IMM << 2); } else { PC = nPC + 4; nPC = PC + 4; } continue; // Branch on Equal Likely
	/* BNE          */ case 0x14000000 >> 26: PC = nPC; nPC += ((cast(int)RS) != cast(int)RT) ? (IMM << 2) : 4; continue; // Branch on Not Equal
	/* BNEL         */ case 0x54000000 >> 26: if (cast(int)RS != cast(int)RT) { PC = nPC; nPC += (IMM << 2); } else { PC = nPC + 4; nPC = PC + 4; } continue; // Branch on Not Equal Likely
	/* CACHE        */ case 0xbc000000 >> 26: UNI_OP(); continue; // Cache
	/* JAL          */ case 0x0C000000 >> 26: callstack[callstack_length++] = nPC; sRA = nPC + 4; PC = nPC; nPC = JUMP; continue; // Jump And Link
	/* LB           */ case 0x80000000 >> 26: sRT = cast(int )mem.read1(RS + IMM); PC = nPC; nPC += 4; continue; // Load Byte
	/* LH           */ case 0x84000000 >> 26: sRT = cast(int )mem.read2(RS + IMM); PC = nPC; nPC += 4; continue; // Load Half
	/* LBU          */ case 0x90000000 >> 26: sRT = cast(uint)mem.read1(RS + IMM); PC = nPC; nPC += 4; continue; // Load Byte Unsigned
	/* LHU          */ case 0x94000000 >> 26: sRT = cast(uint)mem.read2(RS + IMM); PC = nPC; nPC += 4; continue; // Load Half Unsigned
	/* LL           */ case 0xC0000000 >> 26: UNI_OP(); continue; // Load ????
	/* LW           */ case 0x8C000000 >> 26: sRT = cast(uint)mem.read4(RS + IMM); PC = nPC; nPC += 4; continue; // Load Word
	
	/* LWL          */ case 0x88000000 >> 26: sRT = (RT & 0x0000FFFF) | ((mem.read2(RS + IMM - 1) << 16) & 0xFFFF0000); PC = nPC; nPC += 4; continue; // Load Word Left
	/* LWR          */ case 0x98000000 >> 26: sRT = (RT & 0xFFFF0000) | ((mem.read2(RS + IMM - 0) <<  0) & 0x0000FFFF); PC = nPC; nPC += 4; continue; // Load Word Right

	/* SWL          */ case 0xA8000000 >> 26: mem.write2(RS + IMM - 1, (RT >> 16) & 0xFFFF); PC = nPC; nPC += 4; continue; // Store Word Left
	/* SWR          */ case 0xB8000000 >> 26: mem.write2(RS + IMM - 0, (RT >>  0) & 0xFFFF); PC = nPC; nPC += 4; continue; // Store Word Right
	
	/* J            */ case 0x08000000 >> 26: PC = nPC; nPC = JUMP(); if (nPC == 0x_00000000) { nPC = PC + 4; sync_out(); bios.jump0(PC - 4); sync_in(); } continue; // Jump
	/* ORI          */ case 0x34000000 >> 26: sRT = (RS | IMMU); PC = nPC; nPC += 4; continue; // OR Immediate
	/* SLTI         */ case 0x28000000 >> 26: sRT = (cast(int) RSU < IMM ); PC = nPC; nPC += 4; continue; // Set Less Than Immediate
	/* SLTIU        */ case 0x2C000000 >> 26: sRT = (cast(uint)RSU < IMMU); PC = nPC; nPC += 4; continue; // Set Less Than Unsigned Immediate
	/* SB           */ case 0xA0000000 >> 26: mem.write1(RS + IMM, RT); PC = nPC; nPC += 4; continue; // Store Byte
	/* SH           */ case 0xA4000000 >> 26: mem.write2(RS + IMM, RT); PC = nPC; nPC += 4; continue; // Store Halfword
	/* SW           */ case 0xAC000000 >> 26: mem.write4(RS + IMM, RT); PC = nPC; nPC += 4; continue; // Store Word
	/* XORI         */ case 0x38000000 >> 26: sRT = (RS ^ IMMU); PC = nPC; nPC += 4; continue; // eXclusive OR Immediate
	/* SWC1         */ case 0xe4000000 >> 26: mem.write4(RS + IMM, F_I(FT)); PC = nPC; nPC += 4; continue; // Store Word Cop1
	/* LWC1         */ case 0xc4000000 >> 26: sFT = I_F(mem.read4(RS + IMM)); PC = nPC; nPC += 4; continue; // Load Word Cop1
	// +-------------------------------+
	// |                               |
	// +-------------------------------+
	/* LUI          */ case 0x3C000000 >> 26: sRT = (IMM << 16 ); PC = nPC; nPC += 4; continue; // MASK[0xFFE00000]
	/* BLEZ         */ case 0x18000000 >> 26: PC = nPC; nPC += ((cast(int)RS) <= 0) ? (IMM << 2) : 4; continue; // MASK[0xFC1F0000]
	/* BGTZ         */ case 0x1C000000 >> 26: PC = nPC; nPC += ((cast(int)RS) >  0) ? (IMM << 2) : 4; continue; // MASK[0xFC1F0000]
	/* BLEZL        */ case 0x58000000 >> 26: if (cast(int)RS <= 0) { PC = nPC; nPC += (IMM << 2); } else { PC = nPC + 4; nPC = PC + 4; } continue; // MASK[0xFC1F0000] // Branch on Less Equal Zero Likely
	/* BGTZL        */ case 0x5C000000 >> 26: if (cast(int)RS >  0) { PC = nPC; nPC += (IMM << 2); } else { PC = nPC + 4; nPC = PC + 4; } continue; // MASK[0xFC1F0000] // Branch on Greater Than Zero Likely
	// +-------------------------------+
	// |                               |
	// +-------------------------------+
	/* ####         */ case 0x7C000000 >> 26: switch (OP & 0xFC00003F) { // MASK[FC00003F]
		/* EXT          */ case 0x7C000000: EXT(); PC = nPC; nPC += 4; continue; // EXTract bit field
		/* INS          */ case 0x7C000004: INS(); PC = nPC; nPC += 4; continue; // INSert bit field
		/* ####         */ case 0x7C000020: switch (OP & 0xFFE007FF) { // MASK[FC0007FF]
			/* WSBH         */ case 0x7C0000A0: UNI_OP(); continue;
			/* WSBW         */ case 0x7C0000E0: UNI_OP(); continue;
			/* BITREV       */ case 0x7C000520: UNI_OP(); continue;
			/* SEB          */ case 0x7C000420: sRD = SEB(RT); PC = nPC; nPC += 4; continue; // Sign Extend Byte
			/* SEH          */ case 0x7C000620: sRD = SEB(RT); PC = nPC; nPC += 4; continue; // Sign-Extend Halfword
			/* ----         */ default:         UNK_OP(); continue; // ----
		} continue;
		/* ----         */ default:         UNK_OP_P(0x7C000000); continue; // ----
	} continue;
	// +-------------------------------+
	// |                               |
	// +-------------------------------+
	/* B*****       */ case 0x04000000 >> 26: switch (OP & 0xFC1F0000) {
		/* BGEZ         */ case 0x04010000: PC = nPC; nPC += ((cast(int)RS) >= 0) ? (IMM << 2) : 4; continue; // Branch on Greater Equal Zero
		/* BGEZAL       */ case 0x04110000: UNI_OP(); continue; // Branch on Greater Equal Zero And Link
		/* BGEZL        */ case 0x04030000: if (cast(int)RS >= 0) { PC = nPC; nPC += (IMM << 2); } else { PC = nPC + 4; nPC = PC + 4; } continue; // Branch on Greater Equal Likely
		/* BLTZ         */ case 0x04000000: PC = nPC; nPC += ((cast(int)RS) <  0) ? (IMM << 2) : 4; continue; // Branch on Lesser Than Zero
		/* BLTZL        */ case 0x04020000: if (cast(int)RS < 0) { PC = nPC; nPC += (IMM << 2); } else { PC = nPC + 4; nPC = PC + 4; } continue; // Branch on Lesser Than Zero Likely
		/* BLTZAL       */ case 0x04100000: UNI_OP(); continue; // Branch on Lesser Than Zero And Link
		/* BLTZALL      */ case 0x04120000: UNI_OP(); continue; // Branch on Lesser Than Zero And Link ????
		/* ----         */ default:         UNK_OP_P(0x04000000); continue; // ----
	} continue;
	// +-------------------------------+
	// |                               |
	// +-------------------------------+
	/* ####         */ case 0x70000000 >> 26: switch (OP & 0xFFE007FF) {
		/* DBREAK       */ case 0x7000003F: sync_out(); throw(new InterruptException("CPU DEBUG BREAK")); continue;
		/* DRET         */ case 0x7000003E: UNI_OP(); continue;
		/* MFDR         */ case 0x7000003D: UNI_OP(); continue;
		/* MFIC         */ case 0x70000024: sRT = regs.IC; PC = nPC; nPC += 4; continue;
		/* MTIC         */ case 0x70000026: regs.IC  = RT; PC = nPC; nPC += 4; continue;
		/* MTDR         */ case 0x7080003D: UNI_OP(); continue;
		/* HALT         */ case 0x70000000: UNI_OP(); continue;
		/* ----         */ default:         UNK_OP_P(0x70000000); continue; // ----
	} continue;
	// +-------------------------------+
	// | FPU                           |
	// +-------------------------------+
	/* ####         */ case 0x44000000 >> 26:
		if (OP >> 24 == 0x45) { switch (OP & 0xFFFF0000) {
		/* BC1F         */ case 0x45000000: PC = nPC; nPC += (!regs.CC) ? (IMM << 2) : 4; continue; // Branch COP1 on fp False
		/* BC1FL        */ case 0x45020000: if (!regs.CC)  { PC = nPC; nPC += (IMM << 2); } else { PC = nPC + 4; nPC = PC + 4; } continue; // Branch COP1 on fp False Likely
		/* BC1T         */ case 0x45010000: PC = nPC; nPC += ( regs.CC) ? (IMM << 2) : 4; continue; // Branch COP1 on fp True
		/* BC1TL        */ case 0x45030000: if ( regs.CC)  { PC = nPC; nPC += (IMM << 2); } else { PC = nPC + 4; nPC = PC + 4; } continue; // Branch COP1 on fp True Likely
		/* ----         */ default:         UNK_OP_P(0x44000000); continue; // ----
		} } else { switch (OP & 0xFFE0003F) {
		/* ADD.S        */ case 0x46000000: sFD = FS + FT; PC = nPC; nPC += 4; continue;
		/* SUB.S        */ case 0x46000001: sFD = FS - FT; PC = nPC; nPC += 4; continue;
		/* MUL.S        */ case 0x46000002: sFD = FS * FT; PC = nPC; nPC += 4; continue;
		/* DIV.S        */ case 0x46000003: sFD = FS / FT; PC = nPC; nPC += 4; continue;
		/* SQRT.S       */ case 0x46000004: sFD = sqrt(FS); PC = nPC; nPC += 4; continue;
		/* ABS.S        */ case 0x46000005: float f = FS; sFD = (f < 0) ? -f : f; PC = nPC; nPC += 4; continue;
		/* MOV.S        */ case 0x46000006: sFD = FS; PC = nPC; nPC += 4; continue;
		/* NEG.S        */ case 0x46000007: sFD = -FS; PC = nPC; nPC += 4; continue;
		/* ROUND.W.S    */ case 0x4600000C: UNI_OP(); continue;
		/* TRUNC.W.S    */ case 0x4600000D: TRUNC_W_S(); /*sFD = cast(float)F_I(FS);*/ PC = nPC; nPC += 4; continue; // MIRAR FUNCIONES SSE (http://softpixel.com/~cwright/programming/simd/sse.php) cvtss2si/cvttss2si
		/* CEIL.W.S     */ case 0x4600000E: UNI_OP(); continue;
		/* FLOOR.W.S    */ case 0x4600000F: UNI_OP(); continue;
		/* CVT.S.W      */ case 0x46800020: CVT_S_W(); PC = nPC; nPC += 4;continue;
		/* CVT.W.S      */ case 0x46000024: UNI_OP(); continue;
		/* C.F.S        */ case 0x46000030: regs.CC = false; PC = nPC; nPC += 4; continue; // Compare Unordered Single
		/* C.UN.S       */ case 0x46000031: regs.CC = (isnan(FS) ||  isnan(FT)); PC = nPC; nPC += 4; continue; // Compare Unordered Single
		/* C.EQ.S       */ case 0x46000032: regs.CC = (FS == FT); PC = nPC; nPC += 4; continue; // Compare Lesser Equal Single
		/* C.UEQ.S      */ case 0x46000033: regs.CC = (FS != FT); PC = nPC; nPC += 4; continue; // Compare Lesser UnEqual Single
		/* C.OLT.S      */ case 0x46000034: UNI_OP(); continue;
		/* C.TLT.S      */ case 0x46000035: UNI_OP(); continue;
		/* C.OLE.S      */ case 0x46000036: UNI_OP(); continue;
		/* C.ULE.S      */ case 0x46000037: UNI_OP(); continue;
		/* C.SF.S       */ case 0x46000038: UNI_OP(); continue;
		/* C.NGLE.S     */ case 0x46000039: UNI_OP(); continue;
		/* C.SEQ.S      */ case 0x4600003A: UNI_OP(); continue;
		/* C.NGL.S      */ case 0x4600003B: UNI_OP(); continue;
		/* C.LT.S       */ case 0x4600003C: regs.CC = (FS <  FT); if (QNAN) regs.CC = !regs.CC; PC = nPC; nPC += 4; continue; // Compare Lesser Than Single
		/* C.NGE.S      */ case 0x4600003D: UNI_OP(); continue;
		/* C.LE.S       */ case 0x4600003E: regs.CC = (FS <= FT); if (QNAN) regs.CC = !regs.CC; PC = nPC; nPC += 4; continue; // Compare Lesser Equal Single
		/* C.NGT.S      */ case 0x4600003F: UNI_OP(); continue;
		/* MFC1         */ case 0x44000000: sRT = F_I(FS); PC = nPC; nPC += 4; continue; // Move Word from COP1
		/* MTC1         */ case 0x44800000: sFS = I_F(RT); PC = nPC; nPC += 4; continue; // Move Word to COP1
		/* CFC1         */ case 0x44400000: /*UNI_OP();*/ sRT = regs.CC; PC = nPC; nPC += 4; continue; // move Control word From COP1
		/* CTC1         */ case 0x44c00000: /*UNI_OP();*/ regs.CC =  RT; PC = nPC; nPC += 4; continue; // move Control word To COP1
		/* LWC1         */ case 0xc4000000: UNI_OP(); continue;
		/* ----         */ default:         UNK_OP_P(0x44000000); continue; // ----
	} continue; }
	// +-------------------------------+
	// |  SPECIAL                      |
	// +-------------------------------+
	/* ####         */ case 0x00000000 >> 26: switch (OP & 0xFC00003F) {
		/* SRL          */ case 0x00000002: sRD = SRL(RT, POS); PC = nPC; nPC += 4; continue;
		/* SRLV         */ case 0x00000006: sRD = SRL(RT,  RS); PC = nPC; nPC += 4; continue;
		/* SLL          */ case 0x00000000: sRD = SLL(RT, POS); PC = nPC; nPC += 4; continue;
		/* SLLV         */ case 0x00000004: sRD = SLL(RT,  RS); PC = nPC; nPC += 4; continue;
		/* SRA          */ case 0x00000003: sRD = SRA(RT, POS); PC = nPC; nPC += 4; continue;
		/* SRAV         */ case 0x00000007: sRD = SRA(RT,  RS); PC = nPC; nPC += 4; continue;
		/* JR           */ case 0x00000008: PC = nPC; nPC = RS; if ((OP >> 21) & 0x1F == 31 && callstack_length > 0) callstack_length--; continue;
		/* JALR         */ case 0x00000009: callstack[callstack_length++] = nPC; PC = nPC; sRA = nPC + 4; nPC = RS; continue;
		/* ADDU         */ case 0x00000021: sRD = (RSU + RTU); PC = nPC; nPC += 4; continue;
		/* SUBU         */ case 0x00000023: sRD = (RSU - RTU); PC = nPC; nPC += 4; continue;
		/* SLTU         */ case 0x0000002B: sRD = (RSU < RTU); PC = nPC; nPC += 4; continue;
		/* SLT          */ case 0x0000002A: sRD = (cast(int)RSU < RT); PC = nPC; nPC += 4; continue;
		/* SYSCALL      */ case 0x0000000C: PC = nPC; nPC += 4; sync_out(); bios.syscall(CODE); sync_in(); continue;
		/* BREAK        */ case 0x0000000D: sync_out(); throw(new InterruptException("CPU BREAK")); continue;						
		/* MOVZ         */ case 0x0000000A: if (RT == 0) { sRD = RS; } PC = nPC; nPC += 4; continue;
		/* MOVN         */ case 0x0000000B: if (RT != 0) { sRD = RS; } PC = nPC; nPC += 4; continue;
		/* MULT         */ case 0x00000018: MULT (RS, RT); PC = nPC; nPC += 4; continue;
		/* MULTU        */ case 0x00000019: MULTU(RS, RT); PC = nPC; nPC += 4; continue;
		/* DIV          */ case 0x0000001A: DIV  (RS, RT); PC = nPC; nPC += 4; continue;
		/* DIVU         */ case 0x0000001B: DIVU (RS, RT); PC = nPC; nPC += 4; continue;
		/* MFHI         */ case 0x00000010: sRD = regs.HI; PC = nPC; nPC += 4; continue;
		/* MTHI         */ case 0x00000011: regs.HI =  RS; PC = nPC; nPC += 4; continue;
		/* MFLO         */ case 0x00000012: sRD = regs.LO; PC = nPC; nPC += 4; continue;
		/* MTLO         */ case 0x00000013: regs.LO =  RS; PC = nPC; nPC += 4; continue;
		/* ADD          */ case 0x00000020: sRD = RS + RT; PC = nPC; nPC += 4; continue;
		/* AND          */ case 0x00000024: sRD = RS & RT; PC = nPC; nPC += 4; continue;
		/* OR           */ case 0x00000025: sRD = RS | RT; PC = nPC; nPC += 4; continue;
		/* XOR          */ case 0x00000026: sRD = RS ^ RT; PC = nPC; nPC += 4; continue;
		/* NOR          */ case 0x00000027: sRD =  ~(RS | RT); PC = nPC; nPC += 4; continue;
		/* MAX          */ case 0x0000002C: sRD = MAX(RS, RT); PC = nPC; nPC += 4; continue;
		/* MIN          */ case 0x0000002D: sRD = MIN(RS, RT); PC = nPC; nPC += 4; continue;
		/* MADD         */ case 0x0000001C: MADD(); PC = nPC; nPC += 4; break;
		/* ----         */ default: UNK_OP(); continue;
	} continue;
	default: UNK_OP();
}