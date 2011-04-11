module pspemu.core.cpu.Switch;

import pspemu.core.cpu.Instruction;
//import pspemu.utils.Assertion;

import std.stdio, std.traits;

// Here is the magic of the instruction decoding.
// OLD OLD:   http://pspemu.googlecode.com/svn/branches/old/util/gen/cpu_switch.back.d
// OLD:       http://pspemu.googlecode.com/svn/branches/old/util/gen/cpu_gen.php
// PSPPlayer: 
// Jpcsp:     http://jpcsp.googlecode.com/svn/trunk/src/jpcsp/Allegrex.isa
// mfzpsp:    
// pcsp:      

// Compile-time functions.
static pure nothrow {

	// Return n tabs.
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
		foreach (i; ilist) mask &= i.opcode.mask;
		return mask;
	}

	bool inArray(uint[] l, uint v) {
		foreach (c; l) if (c == v) return true;
		return false;
	}

	/**
	 * Returns a string with a mixin if the function return a string (inlined).
	 * Returns a string with a call to that function if not. (void)
	 */
	string callFunction(string opname) {
		string funcName = "OP_" ~ process_name(opname);
		return (
			"static if (__traits(compiles, " ~ funcName ~ ")) {"
				"static if (is(ReturnType!(" ~ funcName ~ ") : string)) {"
					"mixin(" ~ funcName ~ ");"
				"} else {" ~
					funcName ~ "();"
				"}"
			"} else {"
				"OP_UNK();"
			"}"
		);
	}
	
	string repeat(string str, int count) {
		string ret = "";
		for (int n = 0; n < count; n++) ret ~= str;
		return ret;
	}

	// Generate a set of switch for decoding instructions.
	string genSwitch(InstructionDefinition[] ilist, string processor = "callFunction", uint _mask = 0x_FFFFFFFF, int level = 0) {
		string r = "";
		
		assert (level < 16);
		
		string indent_level = repeat("\t", level);
		
		if (ilist.length == 0) {
			// ""
		} else if (ilist.length == 1) {
			r = indent_level ~ "{mixin(" ~ processor ~ "(\"" ~ ilist[0].name ~ "\"));}\n";
		} if (ilist.length > 1) {
			InstructionDefinition[512] ci; int ci_len;

			uint[] cvalues;

			uint mask = getCommonMask(cast(InstructionDefinition[])ilist, _mask);
			r ~= indent_level ~ "switch (instruction.v & " ~ getString(mask) ~ ") {\n";
			foreach (i; ilist) {
				uint cvalue = i.opcode.value & mask;
				if (inArray(cvalues, cvalue)) continue;

				r ~= indent_level ~ "\tcase " ~ getString(cvalue) ~ ":\n";
				ci_len = 0;
				foreach (i2; ilist) {
					if ((i.opcode.value & mask) == (i2.opcode.value & mask)) ci[ci_len++] = i2;
				}
				r ~= genSwitch(ci[0..ci_len], processor, ~mask, level + 2);
				r ~= indent_level ~ "\tbreak;\n";
				
				cvalues ~= cvalue;
			}
			r ~= indent_level ~ "\tdefault:{mixin(" ~ processor ~ "(\"unk\"));}\n";
			r ~= indent_level ~ "}\n";
		}
		return r;
	}
}
