module pspemu.core.cpu.Instruction;

import std.stdio, std.string, std.bitmanip;
import pspemu.utils.bitslice;
import pspemu.utils.MathUtils;
//import std.numeric;

//alias CustomFloat!(10, 5, CustomFloatFlags.ieee) hfloat;

// From jpcsp.
float halffloatToFloat(int imm16) {
	int s = (imm16 >> 15) & 0x00000001; // sign
	int e = (imm16 >> 10) & 0x0000001f; // exponent
	int f = (imm16 >>  0) & 0x000003ff; // fraction
	
	// need to handle 0x7C00 INF and 0xFC00 -INF?
	if (e == 0) {
		// need to handle +-0 case f==0 or f=0x8000?
		if (f == 0) {
			// Plus or minus zero
			return reinterpret!float(s << 31);
		}
		// Denormalized number -- renormalize it
		while ((f & 0x00000400) == 0) {
		    f <<= 1;
		    e -=  1;
		}
		e += 1;
		f &= ~0x00000400;
	} else if (e == 31) {
	    if (f == 0) {
	        // Inf
		    return reinterpret!float((s << 31) | 0x7f800000);
		}
		// NaN
		return reinterpret!float((s << 31) | 0x7f800000 | (f << 13));
	}
	
	e = e + (127 - 15);
	f = f << 13;
	
	return reinterpret!float((s << 31) | (e << 23) | f);
}

// Extra.
enum { INSTR_TYPE_NONE = 0, INSTR_TYPE_PSP = 1, INSTR_TYPE_B = 2, INSTR_TYPE_JUMP = 4, INSTR_TYPE_JAL = 8, INSTR_TYPE_BRANCH = INSTR_TYPE_B | INSTR_TYPE_JUMP | INSTR_TYPE_JAL }
enum { ADDR_TYPE_NONE = 0, ADDR_TYPE_16 = 1, ADDR_TYPE_26 = 2, ADDR_TYPE_REG = 3 }

struct ValueMask {
	string format;
	uint value, mask;
	
	static ValueMask opCall(uint value, uint mask) {
		ValueMask ret;
		ret.format = "<unknown>";
		ret.value = value;
		ret.mask  = mask;
		return ret;
	}
	
	bool opCmp(ValueMask that) {
		return (this.value == that.value) && (this.mask == that.mask);
	}
	
	static ValueMask opCall(string format) {
		ValueMask ret;
		string[] parts;
		ret.format = format;
		int start, total;
		for (int n = 0; n <= format.length; n++) {
			if ((n == format.length) || (format[n] == ':')) {
				parts ~= format[start..n];
				start = n + 1;
			}
		}
		void alloc(uint count) {
			ret.value <<= count;
			ret.mask  <<= count;
			total += count;
		}
		void set(uint value, uint mask) {
			ret.value |= value;
			ret.mask  |= mask;
		}
		foreach (part; parts) {
			switch (part) {
				case "cstw", "cstz", "csty", "cstx":
				case "absw", "absz", "absy", "absx":
				case "mskw", "mskz", "msky", "mskx":
				case "negw", "negz", "negy", "negx":
				case "one", "two":
				case "vt1":
					alloc(1);
				break;
				case "vt2":
				case "satw", "satz", "saty", "satx":
				case "swzw", "swzz", "swzy", "swzx":
					alloc(2);
				break;
				case "imm3":
					alloc(3);
				break;
				case "imm4", "fcond":
					alloc(4);
				break;
				case "c0dr", "c0cr", "c1dr", "c1cr", "imm5", "vt5":
				case "rs", "rd", "rt", "sa", "lsb", "msb", "fs", "fd", "ft":
					alloc(5);
				break;
				case "vs", "vt", "vd", "imm7":
					alloc(7 );
				break;
				case "imm8" : alloc(8 ); break;
				case "imm14": alloc(14); break;
				case "imm16": alloc(16); break;
				case "imm20": alloc(20); break;
				case "imm26": alloc(26); break;
				default:
					if ((part[0] != '0') && (part[0] != '1') && (part[0] != '-')) {
						assert(0, "Unknown identifier");
					} else {
						for (int n = 0; n < part.length; n++) {
							alloc(1);
							switch (part[n]) {
								case '0': set(0, 1); break; 
								case '1': set(1, 1); break;
								case '-': set(0, 0); break;
								default:
									//pragma(msg, part);
									assert(0);
									set(0, 0);
								break;
							}
						}
					}
				break;
			}
		}
		assert(total == 32);
		return ret;
	}
}

struct InstructionDefinition {
	string  name;

	ValueMask opcode;
	
	string  fmt;
	uint    addrtype;
	uint    type;

	string toString() {
		return format("InstructionDefinition('%s', %08X, %08X, '%s', %s, %s)", name, opcode.value, opcode.mask, fmt, addrtype, type);
	}
}

struct Instruction {
	union {
		// Normal value.
		uint v;
		ubyte[4] vv;

		mixin(""
			// Type Register.
			~ bitslice!("v", uint, "RD", 11 + 5 * 0, 5)
			~ bitslice!("v", uint, "RT", 11 + 5 * 1, 5)
			~ bitslice!("v", uint, "RS", 11 + 5 * 2, 5)

			// Type Float Register.
			~ bitslice!("v", uint, "FD", 6 + 5 * 0, 5)
			~ bitslice!("v", uint, "FS", 6 + 5 * 1, 5)
			~ bitslice!("v", uint, "FT", 6 + 5 * 2, 5)

			// Type Immediate (Unsigned).
			~ bitslice!("v", int , "IMM" , 0, 16)
			~ bitslice!("v", uint, "IMMU", 0, 16)
			
			// JUMP 26 bits.
			~ bitslice!("v", uint, "JUMP", 0, 26)

			// Immediate 7 bits.
			// VFPU
			~ bitslice!("v", int , "IMM7", 0, 7)
			// // SVQ(111110:rs:vt5:imm14:0:vt1)
			~ bitslice!("v", uint, "VT1", 0, 1)
			~ bitslice!("v", uint, "VT2", 0, 2)
			~ bitslice!("v", int , "IMM14", 2, 14)
			~ bitslice!("v", uint, "VT5", 16, 5)
			~ bitslice!("v", uint, "IMM5", 16, 5)
			
			~ bitslice!("v", uint, "IMM4",  0, 4)
			
			~ bitslice!("v", uint, "IMM3",  16, 3)

			~ bitslice!("v", uint, "VD",  0, 7)
			~ bitslice!("v", uint, "ONE", 7, 1)
			~ bitslice!("v", uint, "VS",  8, 7)
			~ bitslice!("v", uint, "TWO", 15, 1)
			~ bitslice!("v", uint, "VT",  16, 7)
			
			// CODE
			~ bitslice!("v", uint, "CODE", 6, 20)

			// C1CR
			~ bitslice!("v", uint, "C1CR", 6 + 5 * 1, 5)

			// LSB/MSB
			~ bitslice!("v", uint, "LSB", 6 + 5 * 0, 5)
			~ bitslice!("v", uint, "MSB", 6 + 5 * 1, 5)
		);

		alias LSB POS; // EXT/INS (POS/SIZE_E/SIZE_I)
		alias CODE CODE_BREAK; // @TODO Fixme! BREAK %c
		alias IMM OFFSET;
		
		uint ONE_TWO() { return 1 + 1 * ONE + 2 * TWO; }

		uint JUMP2() { return JUMP << 2; }
		uint JUMP2(uint v) { JUMP = v >> 2; return v; }
		
		int OFFSET2() { return IMM * 4; }
		
		uint SIZE_E() { return MSB + 1; }
		uint SIZE_E(uint size) { MSB = size - 1; return size; }

		uint SIZE_I() { return MSB - LSB + 1; }
		uint SIZE_I(uint size) { MSB = LSB + size - 1; return size; }
		
		uint EXT(int offset, int size) { return (v >> offset) & ((1 << size) - 1); }
		
		uint VT5_1() { return VT5 | (VT1 << 5); }
		uint VT5_2() { return VT5 | (VT2 << 5); }
	}

	static assert (this.sizeof == 4, "Instruction length should be 4 bytes/32 bits.");
	
	/**
	 * 16bit Immediate HalfFloat
	 */
	@property float IMM_HF() {
		float value = halffloatToFloat(IMMU);
		//writefln("%032b", v);
		//writefln("%016b", IMMU);
		//writefln("%f", value);
		return value;
	}


	uint opCast() { return v; }
	string toString() { return std.string.format("OP(%08X)", v); }
}
