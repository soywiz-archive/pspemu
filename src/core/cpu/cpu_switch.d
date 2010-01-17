module pspemu.core.cpu.cpu_switch;

import pspemu.core.cpu.instruction;

import std.stdio;

struct InstructionDefinition {
	string   name;
	uint     opcode;
	uint     mask;

	// Extra.
	enum Type    { NONE = 0, PSP = 1, B = 2, JUMP = 4, JAL = 8, BRANCH = B | JUMP | JAL }
	enum Address { NONE = 0, T16 = 1, T26 = 2, REG = 3 }
	string   fmt;
	Address  addrtype;
	Type     type;
}

// Compile-time functions.
static pure nothrow {

	// Return n tabs.
	string indent(uint n, string s = "") { string r; int m = n; while (m-- > 0) r ~= "\t"; return r ~ s; }
	string process_name(string s) {
		string r;
		foreach (c; s) {
			if (c == '.') {
				r ~= '_';
			} else {
				r ~= cast(char)((c >= 'a' && c <= 'z') ? (c + 'A' - 'a') : c);
			}
		}
		return r;
	}

	// Obtains a hex string from an integer.
	string getString(uint v) {
		string r; uint c = v;
		const string chars = "0123456789ABCDEF";
		while (c != 0) { r = (cast(char)chars[c % 0x10]) ~ r; c /= 0x10; }
		while (r.length < 8) r = '0' ~ r;
		return "0x_" ~ r;
	}

	// Obtains the common mask of a set of instructions.
	uint getCommonMask(InstructionDefinition[] ilist, uint _mask = 0x_FFFFFFFF) {
		uint mask = _mask;
		foreach (i; ilist) mask &= i.mask;
		return mask;
	}

	bool inArray(uint[] l, uint v) {
		foreach (c; l) if (c == v) return true;
		return false;
	}

	// Generate a set of switch for decoding instructions.
	string genSwitch(InstructionDefinition[] ilist, string prefix = "OP_", uint _mask = 0x_FFFFFFFF, int level = 0) {
		string r = "";
		
		//static assert (level > 16);
		
		if (ilist.length == 0) {
			// ""
		} else if (ilist.length == 1) {
			r = indent(level, prefix ~ process_name(ilist[0].name) ~ "(i); return;\n");
		} if (ilist.length > 1) {
			InstructionDefinition[512] ci; int ci_len = ilist.length;

			uint[] cvalues;

			uint mask = getCommonMask(cast(InstructionDefinition[])ilist, _mask);
			r ~= indent(level + 0, "switch (i.v & " ~ getString(mask) ~ ") {\n");
			foreach (i; ilist) {
				uint cvalue = i.opcode & mask; if (inArray(cvalues, cvalue)) continue;

				r ~= indent(level + 1, "case " ~ getString(cvalue) ~ ":\n");
				ci_len = 0;
				foreach (i2; ilist) {
					if ((i.opcode & mask) == (i2.opcode & mask)) ci[ci_len++] = i2;
				}
				r ~= genSwitch(ci[0..ci_len], prefix, ~mask, level + 2);
				r ~= indent(level + 1, "break;\n");
				
				cvalues ~= cvalue;
			}
			r ~= indent(level + 1, "default: " ~ prefix ~  "UNK(i); return;\n");
			r ~= indent(level + 0, "}\n");
		}
		return r;
	}

}

unittest {
	writefln("Unittesting: CPU_SWITCH...");

	static const testList = [
		InstructionDefinition("add"      , 0x00000020, 0xFC0007FF),
		InstructionDefinition("addi"     , 0x20000000, 0xFC000000),
		InstructionDefinition("test"     , 0x27000000, 0x0F000000),
	];

	// Check indentation function.
	assert(indent(2, "Test") == "\t\tTest");

	// Check getString function.
	assert(getString(0) == "0x_00000000");
	assert(getString(0x15) == "0x_00000015");
	assert(getString(-0x999) == "0x_FFFFF667");

	// Check process_name function.
	assert(process_name("floor.w.s") == "FLOOR_W_S");
	
	// Check inArray function.
	assert(inArray([1, 2, 3], 3) == true);
	assert(inArray([-1, 1], 0) == false);
	assert(inArray([], 0) == false);

	// Check getCommonMask function.
	assert(getCommonMask(testList[0..2]) == 0xFC000000);
	assert(getCommonMask(testList[0..3]) == 0x0C000000);

	// Check genSwitch function.
	{
		Instruction i;

		bool[string] called;

		void PREFIX_ADD (Instruction i) { called["add"]  = true; }
		void PREFIX_ADDI(Instruction i) { called["addi"] = true; }
		void PREFIX_UNK (Instruction i) { called["unk"]  = true; }

		void EXECUTE() { mixin(genSwitch(testList[0..2], "PREFIX_")); }

		i.v = 0x_00000020; EXECUTE();
		i.v = 0x_20000000; EXECUTE();
		i.v = 0x_30000020; EXECUTE();

		assert("add" in called);
		assert("addi" in called);
		assert("unk" in called);
	}
}