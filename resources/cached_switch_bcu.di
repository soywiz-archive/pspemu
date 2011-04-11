switch (instruction.v & 0x_FC000000) {
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
        case 0x_00000000:
                switch (instruction.v & 0x_001F07FF) {
                        case 0x_00000008:
                                {mixin(callFunction("jr"));}
                        break;
                        case 0x_00000009:
                                {mixin(callFunction("jalr"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        case 0x_0C000000:
                {mixin(callFunction("jal"));}
        break;
        case 0x_44000000:
                switch (instruction.v & 0x_03FF0000) {
                        case 0x_01000000:
                                {mixin(callFunction("bc1f"));}
                        break;
                        case 0x_01010000:
                                {mixin(callFunction("bc1t"));}
                        break;
                        case 0x_01020000:
                                {mixin(callFunction("bc1fl"));}
                        break;
                        case 0x_01030000:
                                {mixin(callFunction("bc1tl"));}
                        break;
                        default:{mixin(callFunction("unk"));}
                }
        break;
        default:{mixin(callFunction("unk"));}
}