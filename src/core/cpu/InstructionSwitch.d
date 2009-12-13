module core.cpu.InstructionSwitch;

import core.cpu.Instruction;

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
	/*
	uint getCommonValues(immutable InstructionDefinition[] ilist, uint mask = 0x_FFFFFFFF) {
	}*/

	bool inArray(uint[] l, uint v) {
		foreach (c; l) if (c == v) return true;
		return false;
	}

	// Generate a set of switch for decoding instructions.
	string genSwitch(string prefix, InstructionDefinition[] ilist, uint _mask = 0x_FFFFFFFF, int level = 0) {
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
				r ~= genSwitch(prefix, ci[0..ci_len], ~mask, level + 2);
				r ~= indent(level + 1, "break;\n");
				
				cvalues ~= cvalue;
			}
			r ~= indent(level + 1, "default: OP_UNK(i); return;\n");
			r ~= indent(level + 0, "}\n");
		}
		return r;
	}

}
