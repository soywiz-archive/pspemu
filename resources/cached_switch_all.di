switch (instruction.v & 0x_FC000000) {
        case 0x_00000000:
                switch (instruction.v & 0x_0000003F) {
                        case 0x_00000020:
                                {mixin(callFunction("add"));}
                        break;
                        case 0x_00000021:
                                {mixin(callFunction("addu"));}
                        break;
                        case 0x_00000022:
                                {mixin(callFunction("sub"));}
                        break;
                        case 0x_00000023:
                                {mixin(callFunction("subu"));}
                        break;
                        case 0x_00000024:
                                {mixin(callFunction("and"));}
                        break;
                        case 0x_00000027:
                                {mixin(callFunction("nor"));}
                        break;
                        case 0x_00000025:
                                {mixin(callFunction("or"));}
                        break;
                        case 0x_00000026:
                                {mixin(callFunction("xor"));}
                        break;
                        case 0x_00000000:
                                {mixin(callFunction("sll"));}
                        break;
                        case 0x_00000004:
                                {mixin(callFunction("sllv"));}
                        break;
                        case 0x_00000003:
                                {mixin(callFunction("sra"));}
                        break;
                        case 0x_00000007:
                                {mixin(callFunction("srav"));}
                        break;
                        case 0x_00000002:
                                switch (instruction.v & 0x_FFE00000) {
                                        case 0x_00000000:
                                                {mixin(callFunction("srl"));}
                                        break;
                                        case 0x_00200000:
                                                {mixin(callFunction("rotr"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_00000006:
                                switch (instruction.v & 0x_FC0007C0) {
                                        case 0x_00000000:
                                                {mixin(callFunction("srlv"));}
                                        break;
                                        case 0x_00000040:
                                                {mixin(callFunction("rotrv"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_0000002A:
                                {mixin(callFunction("slt"));}
                        break;
                        case 0x_0000002B:
                                {mixin(callFunction("sltu"));}
                        break;
                        case 0x_0000002C:
                                {mixin(callFunction("max"));}
                        break;
                        case 0x_0000002D:
                                {mixin(callFunction("min"));}
                        break;
                        case 0x_0000001A:
                                {mixin(callFunction("div"));}
                        break;
                        case 0x_0000001B:
                                {mixin(callFunction("divu"));}
                        break;
                        case 0x_00000018:
                                {mixin(callFunction("mult"));}
                        break;
                        case 0x_00000019:
                                {mixin(callFunction("multu"));}
                        break;
                        case 0x_0000001C:
                                {mixin(callFunction("madd"));}
                        break;
                        case 0x_0000001D:
                                {mixin(callFunction("maddu"));}
                        break;
                        case 0x_0000002E:
                                {mixin(callFunction("msub"));}
                        break;
                        case 0x_0000002F:
                                {mixin(callFunction("msubu"));}
                        break;
                        case 0x_00000010:
                                {mixin(callFunction("mfhi"));}
                        break;
                        case 0x_00000012:
                                {mixin(callFunction("mflo"));}
                        break;
                        case 0x_00000011:
                                {mixin(callFunction("mthi"));}
                        break;
                        case 0x_00000013:
                                {mixin(callFunction("mtlo"));}
                        break;
                        case 0x_0000000A:
                                {mixin(callFunction("movz"));}
                        break;
                        case 0x_0000000B:
                                {mixin(callFunction("movn"));}
                        break;
                        case 0x_00000016:
                                {mixin(callFunction("clz"));}
                        break;
                        case 0x_00000017:
                                {mixin(callFunction("clo"));}
                        break;
                        case 0x_00000008:
                                {mixin(callFunction("jr"));}
                        break;
                        case 0x_00000009:
                                {mixin(callFunction("jalr"));}
                        break;
                        case 0x_0000000C:
                                {mixin(callFunction("syscall"));}
                        break;
                        case 0x_0000000F:
                                {mixin(callFunction("sync"));}
                        break;
                        case 0x_0000000D:
                                {mixin(callFunction("break"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_20000000:
                {mixin(callFunction("addi"));}
        break;
        case 0x_24000000:
                {mixin(callFunction("addiu"));}
        break;
        case 0x_30000000:
                {mixin(callFunction("andi"));}
        break;
        case 0x_34000000:
                {mixin(callFunction("ori"));}
        break;
        case 0x_38000000:
                {mixin(callFunction("xori"));}
        break;
        case 0x_28000000:
                {mixin(callFunction("slti"));}
        break;
        case 0x_2C000000:
                {mixin(callFunction("sltiu"));}
        break;
        case 0x_3C000000:
                {mixin(callFunction("lui"));}
        break;
        case 0x_7C000000:
                switch (instruction.v & 0x_0000003F) {
                        case 0x_00000020:
                                switch (instruction.v & 0x_FFE007C0) {
                                        case 0x_7C000400:
                                                {mixin(callFunction("seb"));}
                                        break;
                                        case 0x_7C000600:
                                                {mixin(callFunction("seh"));}
                                        break;
                                        case 0x_7C000500:
                                                {mixin(callFunction("bitrev"));}
                                        break;
                                        case 0x_7C000080:
                                                {mixin(callFunction("wsbh"));}
                                        break;
                                        case 0x_7C0000C0:
                                                {mixin(callFunction("wsbw"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_00000000:
                                {mixin(callFunction("ext"));}
                        break;
                        case 0x_00000004:
                                {mixin(callFunction("ins"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_10000000:
                {mixin(callFunction("beq"));}
        break;
        case 0x_50000000:
                {mixin(callFunction("beql"));}
        break;
        case 0x_04000000:
                switch (instruction.v & 0x_001F0000) {
                        case 0x_00010000:
                                {mixin(callFunction("bgez"));}
                        break;
                        case 0x_00030000:
                                {mixin(callFunction("bgezl"));}
                        break;
                        case 0x_00110000:
                                {mixin(callFunction("bgezal"));}
                        break;
                        case 0x_00130000:
                                {mixin(callFunction("bgezall"));}
                        break;
                        case 0x_00000000:
                                {mixin(callFunction("bltz"));}
                        break;
                        case 0x_00020000:
                                {mixin(callFunction("bltzl"));}
                        break;
                        case 0x_00100000:
                                {mixin(callFunction("bltzal"));}
                        break;
                        case 0x_00120000:
                                {mixin(callFunction("bltzall"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_18000000:
                {mixin(callFunction("blez"));}
        break;
        case 0x_58000000:
                {mixin(callFunction("blezl"));}
        break;
        case 0x_1C000000:
                {mixin(callFunction("bgtz"));}
        break;
        case 0x_5C000000:
                {mixin(callFunction("bgtzl"));}
        break;
        case 0x_14000000:
                {mixin(callFunction("bne"));}
        break;
        case 0x_54000000:
                {mixin(callFunction("bnel"));}
        break;
        case 0x_08000000:
                {mixin(callFunction("j"));}
        break;
        case 0x_0C000000:
                {mixin(callFunction("jal"));}
        break;
        case 0x_44000000:
                switch (instruction.v & 0x_03E00000) {
                        case 0x_01000000:
                                switch (instruction.v & 0x_FC1F0000) {
                                        case 0x_44000000:
                                                {mixin(callFunction("bc1f"));}
                                        break;
                                        case 0x_44010000:
                                                {mixin(callFunction("bc1t"));}
                                        break;
                                        case 0x_44020000:
                                                {mixin(callFunction("bc1fl"));}
                                        break;
                                        case 0x_44030000:
                                                {mixin(callFunction("bc1tl"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_02000000:
                                switch (instruction.v & 0x_FC00003F) {
                                        case 0x_44000000:
                                                {mixin(callFunction("add.s"));}
                                        break;
                                        case 0x_44000001:
                                                {mixin(callFunction("sub.s"));}
                                        break;
                                        case 0x_44000002:
                                                {mixin(callFunction("mul.s"));}
                                        break;
                                        case 0x_44000003:
                                                {mixin(callFunction("div.s"));}
                                        break;
                                        case 0x_44000004:
                                                {mixin(callFunction("sqrt.s"));}
                                        break;
                                        case 0x_44000005:
                                                {mixin(callFunction("abs.s"));}
                                        break;
                                        case 0x_44000006:
                                                {mixin(callFunction("mov.s"));}
                                        break;
                                        case 0x_44000007:
                                                {mixin(callFunction("neg.s"));}
                                        break;
                                        case 0x_4400000C:
                                                {mixin(callFunction("round.w.s"));}
                                        break;
                                        case 0x_4400000D:
                                                {mixin(callFunction("trunc.w.s"));}
                                        break;
                                        case 0x_4400000E:
                                                {mixin(callFunction("ceil.w.s"));}
                                        break;
                                        case 0x_4400000F:
                                                {mixin(callFunction("floor.w.s"));}
                                        break;
                                        case 0x_44000024:
                                                {mixin(callFunction("cvt.w.s"));}
                                        break;
                                        case 0x_44000030:
                                                {mixin(callFunction("c.f.s"));}
                                        break;
                                        case 0x_44000031:
                                                {mixin(callFunction("c.un.s"));}
                                        break;
                                        case 0x_44000032:
                                                {mixin(callFunction("c.eq.s"));}
                                        break;
                                        case 0x_44000033:
                                                {mixin(callFunction("c.ueq.s"));}
                                        break;
                                        case 0x_44000034:
                                                {mixin(callFunction("c.olt.s"));}
                                        break;
                                        case 0x_44000035:
                                                {mixin(callFunction("c.ult.s"));}
                                        break;
                                        case 0x_44000036:
                                                {mixin(callFunction("c.ole.s"));}
                                        break;
                                        case 0x_44000037:
                                                {mixin(callFunction("c.ule.s"));}
                                        break;
                                        case 0x_44000038:
                                                {mixin(callFunction("c.sf.s"));}
                                        break;
                                        case 0x_44000039:
                                                {mixin(callFunction("c.ngle.s"));}
                                        break;
                                        case 0x_4400003A:
                                                {mixin(callFunction("c.seq.s"));}
                                        break;
                                        case 0x_4400003B:
                                                {mixin(callFunction("c.ngl.s"));}
                                        break;
                                        case 0x_4400003C:
                                                {mixin(callFunction("c.lt.s"));}
                                        break;
                                        case 0x_4400003D:
                                                {mixin(callFunction("c.nge.s"));}
                                        break;
                                        case 0x_4400003E:
                                                {mixin(callFunction("c.le.s"));}
                                        break;
                                        case 0x_4400003F:
                                                {mixin(callFunction("c.ngt.s"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_02800000:
                                {mixin(callFunction("cvt.s.w"));}
                        break;
                        case 0x_00000000:
                                {mixin(callFunction("mfc1"));}
                        break;
                        case 0x_00400000:
                                {mixin(callFunction("cfc1"));}
                        break;
                        case 0x_00800000:
                                {mixin(callFunction("mtc1"));}
                        break;
                        case 0x_00C00000:
                                {mixin(callFunction("ctc1"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_80000000:
                {mixin(callFunction("lb"));}
        break;
        case 0x_84000000:
                {mixin(callFunction("lh"));}
        break;
        case 0x_8C000000:
                {mixin(callFunction("lw"));}
        break;
        case 0x_88000000:
                {mixin(callFunction("lwl"));}
        break;
        case 0x_98000000:
                {mixin(callFunction("lwr"));}
        break;
        case 0x_90000000:
                {mixin(callFunction("lbu"));}
        break;
        case 0x_94000000:
                {mixin(callFunction("lhu"));}
        break;
        case 0x_A0000000:
                {mixin(callFunction("sb"));}
        break;
        case 0x_A4000000:
                {mixin(callFunction("sh"));}
        break;
        case 0x_AC000000:
                {mixin(callFunction("sw"));}
        break;
        case 0x_A8000000:
                {mixin(callFunction("swl"));}
        break;
        case 0x_B8000000:
                {mixin(callFunction("swr"));}
        break;
        case 0x_C0000000:
                {mixin(callFunction("ll"));}
        break;
        case 0x_E0000000:
                {mixin(callFunction("sc"));}
        break;
        case 0x_C4000000:
                {mixin(callFunction("lwc1"));}
        break;
        case 0x_E4000000:
                {mixin(callFunction("swc1"));}
        break;
        case 0x_40000000:
                switch (instruction.v & 0x_03E007FF) {
                        case 0x_00400000:
                                {mixin(callFunction("cfc0"));}
                        break;
                        case 0x_00C00000:
                                {mixin(callFunction("ctc0"));}
                        break;
                        case 0x_00000000:
                                {mixin(callFunction("mfc0"));}
                        break;
                        case 0x_00800000:
                                {mixin(callFunction("mtc0"));}
                        break;
                        case 0x_02000018:
                                {mixin(callFunction("eret"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_48000000:
                switch (instruction.v & 0x_03E00000) {
                        case 0x_00600000:
                                switch (instruction.v & 0x_FC00FF80) {
                                        case 0x_48000000:
                                                {mixin(callFunction("mfv"));}
                                        break;
                                        case 0x_48000080:
                                                {mixin(callFunction("mfvc"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_00E00000:
                                switch (instruction.v & 0x_FC00FF80) {
                                        case 0x_48000000:
                                                {mixin(callFunction("mtv"));}
                                        break;
                                        case 0x_48000080:
                                                {mixin(callFunction("mtvc"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_01000000:
                                switch (instruction.v & 0x_FC030000) {
                                        case 0x_48000000:
                                                {mixin(callFunction("bvf"));}
                                        break;
                                        case 0x_48020000:
                                                {mixin(callFunction("bvfl"));}
                                        break;
                                        case 0x_48010000:
                                                {mixin(callFunction("bvt"));}
                                        break;
                                        case 0x_48030000:
                                                {mixin(callFunction("bvtl"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_C8000000:
                {mixin(callFunction("lv.s"));}
        break;
        case 0x_D8000000:
                {mixin(callFunction("lv.q"));}
        break;
        case 0x_D4000000:
                switch (instruction.v & 0x_00000002) {
                        case 0x_00000000:
                                {mixin(callFunction("lvl.q"));}
                        break;
                        case 0x_00000002:
                                {mixin(callFunction("lvr.q"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_F8000000:
                {mixin(callFunction("sv.q"));}
        break;
        case 0x_64000000:
                switch (instruction.v & 0x_03800000) {
                        case 0x_00800000:
                                {mixin(callFunction("vdot"));}
                        break;
                        case 0x_01000000:
                                {mixin(callFunction("vscl"));}
                        break;
                        case 0x_02000000:
                                {mixin(callFunction("vhdp"));}
                        break;
                        case 0x_02800000:
                                {mixin(callFunction("vcrs.t"));}
                        break;
                        case 0x_00000000:
                                {mixin(callFunction("vmul"));}
                        break;
                        case 0x_03000000:
                                {mixin(callFunction("vdet"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_6C000000:
                switch (instruction.v & 0x_03800000) {
                        case 0x_02000000:
                                {mixin(callFunction("vslt"));}
                        break;
                        case 0x_03000000:
                                {mixin(callFunction("vsge"));}
                        break;
                        case 0x_01000000:
                                {mixin(callFunction("vmin"));}
                        break;
                        case 0x_01800000:
                                {mixin(callFunction("vmax"));}
                        break;
                        case 0x_00000000:
                                {mixin(callFunction("vcmp"));}
                        break;
                        case 0x_02800000:
                                {mixin(callFunction("vscmp"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_F0000000:
                switch (instruction.v & 0x_03800000) {
                        case 0x_03800000:
                                switch (instruction.v & 0x_FC600000) {
                                        case 0x_F0200000:
                                                {mixin(callFunction("vrot"));}
                                        break;
                                        case 0x_F0000000:
                                                switch (instruction.v & 0x_039F0000) {
                                                        case 0x_03830000:
                                                                {mixin(callFunction("vmidt"));}
                                                        break;
                                                        case 0x_03800000:
                                                                {mixin(callFunction("vmmov"));}
                                                        break;
                                                        case 0x_03860000:
                                                                {mixin(callFunction("vmzero"));}
                                                        break;
                                                        case 0x_03870000:
                                                                {mixin(callFunction("vmone"));}
                                                        break;
                                                        default:{mixin(callFunction("unk"));}
                                                }
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_00000000:
                                {mixin(callFunction("vmmul"));}
                        break;
                        case 0x_02800000:
                                {mixin(callFunction("vcrsp.t"));}
                        break;
                        case 0x_00800000:
                                switch (instruction.v & 0x_FC008080) {
                                        case 0x_F0000080:
                                                {mixin(callFunction("vtfm2"));}
                                        break;
                                        case 0x_F0000000:
                                                {mixin(callFunction("vhtfm2"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_01000000:
                                switch (instruction.v & 0x_FC008080) {
                                        case 0x_F0008000:
                                                {mixin(callFunction("vtfm3"));}
                                        break;
                                        case 0x_F0000080:
                                                {mixin(callFunction("vhtfm3"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_01800000:
                                switch (instruction.v & 0x_FC008080) {
                                        case 0x_F0008080:
                                                {mixin(callFunction("vtfm4"));}
                                        break;
                                        case 0x_F0008000:
                                                {mixin(callFunction("vhtfm4"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_02000000:
                                {mixin(callFunction("vmscl"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_D0000000:
                switch (instruction.v & 0x_03E00000) {
                        case 0x_00000000:
                                switch (instruction.v & 0x_FC1F0000) {
                                        case 0x_D0060000:
                                                {mixin(callFunction("vzero"));}
                                        break;
                                        case 0x_D0070000:
                                                {mixin(callFunction("vone"));}
                                        break;
                                        case 0x_D0000000:
                                                {mixin(callFunction("vmov"));}
                                        break;
                                        case 0x_D0010000:
                                                {mixin(callFunction("vabs"));}
                                        break;
                                        case 0x_D0020000:
                                                {mixin(callFunction("vneg"));}
                                        break;
                                        case 0x_D0100000:
                                                {mixin(callFunction("vrcp"));}
                                        break;
                                        case 0x_D0110000:
                                                {mixin(callFunction("vrsq"));}
                                        break;
                                        case 0x_D0120000:
                                                {mixin(callFunction("vsin"));}
                                        break;
                                        case 0x_D0130000:
                                                {mixin(callFunction("vcos"));}
                                        break;
                                        case 0x_D0140000:
                                                {mixin(callFunction("vexp2"));}
                                        break;
                                        case 0x_D0150000:
                                                {mixin(callFunction("vlog2"));}
                                        break;
                                        case 0x_D0160000:
                                                {mixin(callFunction("vsqrt"));}
                                        break;
                                        case 0x_D0170000:
                                                {mixin(callFunction("vasin"));}
                                        break;
                                        case 0x_D0180000:
                                                {mixin(callFunction("vnrcp"));}
                                        break;
                                        case 0x_D01A0000:
                                                {mixin(callFunction("vnsin"));}
                                        break;
                                        case 0x_D01C0000:
                                                {mixin(callFunction("vrexp2"));}
                                        break;
                                        case 0x_D0040000:
                                                {mixin(callFunction("vsat0"));}
                                        break;
                                        case 0x_D0050000:
                                                {mixin(callFunction("vsat1"));}
                                        break;
                                        case 0x_D0030000:
                                                {mixin(callFunction("vidt"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_00400000:
                                switch (instruction.v & 0x_FC1F0000) {
                                        case 0x_D0040000:
                                                {mixin(callFunction("vocp"));}
                                        break;
                                        case 0x_D00A0000:
                                                {mixin(callFunction("vsgn"));}
                                        break;
                                        case 0x_D0080000:
                                                {mixin(callFunction("vsrt3"));}
                                        break;
                                        case 0x_D0060000:
                                                {mixin(callFunction("vfad"));}
                                        break;
                                        case 0x_D0070000:
                                                {mixin(callFunction("vavg"));}
                                        break;
                                        case 0x_D0190000:
                                                {mixin(callFunction("vt4444.q"));}
                                        break;
                                        case 0x_D01A0000:
                                                {mixin(callFunction("vt5551.q"));}
                                        break;
                                        case 0x_D01B0000:
                                                {mixin(callFunction("vt5650.q"));}
                                        break;
                                        case 0x_D0100000:
                                                {mixin(callFunction("vmfvc"));}
                                        break;
                                        case 0x_D0110000:
                                                {mixin(callFunction("vmtvc"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_00600000:
                                {mixin(callFunction("vcst"));}
                        break;
                        case 0x_00200000:
                                switch (instruction.v & 0x_FC1F0000) {
                                        case 0x_D01D0000:
                                                {mixin(callFunction("vi2c"));}
                                        break;
                                        case 0x_D01C0000:
                                                {mixin(callFunction("vi2uc"));}
                                        break;
                                        case 0x_D0000000:
                                                {mixin(callFunction("vrnds"));}
                                        break;
                                        case 0x_D0010000:
                                                {mixin(callFunction("vrndi"));}
                                        break;
                                        case 0x_D0020000:
                                                {mixin(callFunction("vrndf1"));}
                                        break;
                                        case 0x_D0030000:
                                                {mixin(callFunction("vrndf2"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_02A00000:
                                switch (instruction.v & 0x_FC180000) {
                                        case 0x_D0080000:
                                                {mixin(callFunction("vcmovf"));}
                                        break;
                                        case 0x_D0000000:
                                                {mixin(callFunction("vcmovt"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        case 0x_02600000:
                                {mixin(callFunction("vf2id"));}
                        break;
                        case 0x_02000000:
                                {mixin(callFunction("vf2in"));}
                        break;
                        case 0x_02400000:
                                {mixin(callFunction("vf2iu"));}
                        break;
                        case 0x_02200000:
                                {mixin(callFunction("vf2iz"));}
                        break;
                        case 0x_02800000:
                                {mixin(callFunction("vi2f"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_60000000:
                switch (instruction.v & 0x_03800000) {
                        case 0x_00000000:
                                {mixin(callFunction("vadd"));}
                        break;
                        case 0x_00800000:
                                {mixin(callFunction("vsub"));}
                        break;
                        case 0x_03800000:
                                {mixin(callFunction("vdiv"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_DC000000:
                switch (instruction.v & 0x_03000000) {
                        case 0x_03000000:
                                {mixin(callFunction("viim"));}
                        break;
                        case 0x_02000000:
                                {mixin(callFunction("vpfxd"));}
                        break;
                        case 0x_00000000:
                                {mixin(callFunction("vpfxs"));}
                        break;
                        case 0x_01000000:
                                {mixin(callFunction("vpfxt"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_FC000000:
                switch (instruction.v & 0x_03FFFFFF) {
                        case 0x_03FF0000:
                                {mixin(callFunction("vnop"));}
                        break;
                        case 0x_03FF0320:
                                {mixin(callFunction("vsync"));}
                        break;
                        case 0x_03FF040D:
                                {mixin(callFunction("vflush"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_68000000:
                {mixin(callFunction("mfvme"));}
        break;
        case 0x_B0000000:
                {mixin(callFunction("mtvme"));}
        break;
        case 0x_BC000000:
                {mixin(callFunction("cache"));}
        break;
        case 0x_70000000:
                switch (instruction.v & 0x_000007FF) {
                        case 0x_0000003F:
                                {mixin(callFunction("dbreak"));}
                        break;
                        case 0x_00000000:
                                {mixin(callFunction("halt"));}
                        break;
                        case 0x_0000003E:
                                {mixin(callFunction("dret"));}
                        break;
                        case 0x_00000024:
                                {mixin(callFunction("mfic"));}
                        break;
                        case 0x_00000026:
                                {mixin(callFunction("mtic"));}
                        break;
                        case 0x_0000003D:
                                switch (instruction.v & 0x_FFE00000) {
                                        case 0x_70000000:
                                                {mixin(callFunction("mfdr"));}
                                        break;
                                        case 0x_70800000:
                                                {mixin(callFunction("mtdr"));}
                                        break;
                                        default:{mixin(callFunction("unk"));}
                                }
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        default:{mixin(callFunction("unk"));}
}
