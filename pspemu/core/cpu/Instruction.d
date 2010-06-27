module pspemu.core.cpu.Instruction;

import std.stdio, std.string, std.bitmanip;

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
				case "vt1": alloc(1); break;
				case "vt5":
				case "c0dr", "c0cr", "c1dr", "c1cr":
				case "rs", "rd", "rt", "sa", "lsb", "msb", "fs", "fd", "ft": alloc(5); break;
				case "fcond": alloc(4 ); break;
				case "imm7" : alloc(7 ); break;
				case "imm14": alloc(14); break;
				case "imm16": alloc(16); break;
				case "imm20": alloc(20); break;
				case "imm26": alloc(26); break;
				default:
					if ((part[0] != '0') && (part[0] != '1')) {
						assert(0, "Unknown identifier");
					} else {
						for (int n = 0; n < part.length; n++) {
							alloc(1);
							if (part[n] == '0') {
								set(0, 1);
							} else if (part[n] == '1') {
								set(1, 1);
							} else {
								//pragma(msg, part);
								assert(0);
								set(0, 0);
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

/*string bitslice(alias v, T, uint start, uint count)() {
}*/

struct Instruction {
	union {
		// Normal value.
		uint v;
		ubyte[4] vv;

		/*
		mixin(bitslice!(v, uint, "RD", 11 + 5 * 0, 5));
		mixin(bitslice!(v, uint, "RT", 11 + 5 * 1, 5));
		mixin(bitslice!(v, uint, "RS", 11 + 5 * 2, 5));
		*/
		
		// Type Register.
		struct { mixin(bitfields!(
			uint, "",   11,
			uint, "RD", 5,
			uint, "RT", 5,
			uint, "RS", 5,
			uint, "",   6
		)); }

		// Type Float Register.
		struct { mixin(bitfields!(
			uint, "",   6,
			uint, "FD", 5,
			uint, "FS", 5,
			uint, "FT", 5,
			uint, "",   11
		)); }

		//010001:00010:rt:c1cr:00000:000000
		//alias RD C1CR;
		alias FS C1CR;

		// Type Immediate.
		struct { mixin(bitfields!(
			int, "IMM", 16,
			int, "__0",  16
		)); }

		// Type Immediate Unsigned.
		struct { mixin(bitfields!(
			uint, "IMMU" , 16,
			uint, "__1", 16
		)); }

		// JUMP 26 bits.
		struct { mixin(bitfields!(
			uint, "JUMP", 26,
			uint, "__2",  6
		)); }

		// Immediate 7 bits.
		struct { mixin(bitfields!(
			uint, "IMM7", 7,
			uint, "__3",  25
		)); }

		uint JUMP2() { return JUMP << 2; }
		uint JUMP2(uint v) { JUMP = v >> 2; return v; }
		
		int OFFSET2() { return IMM * 4; }

		// LSB/MSB
		struct { mixin(bitfields!(
			uint, "",      6,
			uint, "LSB",   5,
			uint, "MSB",   5,
			uint, "",      16
		)); }

		
		uint SIZE_E() { return MSB + 1; }
		uint SIZE_E(uint size) { MSB = size - 1; return size; }

		uint SIZE_I() { return MSB - LSB + 1; }
		uint SIZE_I(uint size) { MSB = LSB + size - 1; return size; }

		// CODE
		struct { mixin(bitfields!(
			uint, "__5",   6,
			uint, "CODE",  20,
			uint, "__6",   6
		)); }

		alias LSB POS; // EXT/INS (POS/SIZE_E/SIZE_I)
		alias CODE CODE_BREAK; // @TODO Fixme! BREAK %c
		alias IMM OFFSET;
	}

	static assert (this.sizeof == 4, "Instruction length should be 4 bytes/32 bits.");

	uint opCast() { return v; }
	string toString() { return std.string.format("OP(%08X)", v); }
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	Instruction i;
	//       ------ SSSSS TTTTT DDDDD -----------
	i.v = 0b_111111_10001_11011_00100_11111111111;
	assert(i.RS == 0b_10001);
	assert(i.RT == 0b_11011);
	assert(i.RD == 0b_00100);

	//static void main() { }
}
