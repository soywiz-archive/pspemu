module pspemu.core.cpu.Switch;

import pspemu.core.cpu.Instruction;
import pspemu.utils.Assertion;

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

	/**
	 * Returns a string with a mixin if the function return a string (inlined).
	 * Returns a string with a call to that function if not. (void)
	 */
	string callFunction(string opname) {
		//return "OP_" ~ process_name(opname) ~ "();";
		string funcName = "OP_" ~ process_name(opname);
		return "static if (is(ReturnType!(" ~ funcName ~ ") : string)) { mixin(" ~ funcName ~ "); } else {" ~ funcName ~ "();}";
	}

	// Generate a set of switch for decoding instructions.
	string genSwitch(InstructionDefinition[] ilist, string processor = "callFunction", uint _mask = 0x_FFFFFFFF, int level = 0) {
		string r = "";
		
		//static assert (level > 16);
		
		if (ilist.length == 0) {
			// ""
		} else if (ilist.length == 1) {
			//r = indent(level, prefix ~ process_name(ilist[0].name) ~ "(); return;\n");
			r = indent(level, "{mixin(" ~ processor ~ "(\"" ~ ilist[0].name ~ "\"));}\n");
			//r ~= "mixin(\"if (__traits(compiles, " ~ ilist[0].name ~ ")) { } else { }\");";
			//r = indent(level, "{mixin(" ~ processor ~ "(__traits(identifier, " ~ ilist[0].name ~ ")));}\n");
		} if (ilist.length > 1) {
			InstructionDefinition[512] ci; int ci_len = ilist.length;

			uint[] cvalues;

			uint mask = getCommonMask(cast(InstructionDefinition[])ilist, _mask);
			r ~= indent(level + 0, "switch (instruction.v & " ~ getString(mask) ~ ") {\n");
			foreach (i; ilist) {
				uint cvalue = i.opcode & mask; if (inArray(cvalues, cvalue)) continue;

				r ~= indent(level + 1, "case " ~ getString(cvalue) ~ ":\n");
				ci_len = 0;
				foreach (i2; ilist) {
					if ((i.opcode & mask) == (i2.opcode & mask)) ci[ci_len++] = i2;
				}
				r ~= genSwitch(ci[0..ci_len], processor, ~mask, level + 2);
				r ~= indent(level + 1, "break;\n");
				
				cvalues ~= cvalue;
			}
			r ~= indent(level + 1, "default:{mixin(" ~ processor ~ "(\"unk\"));}\n");
			r ~= indent(level + 0, "}\n");
		}
		return r;
	}
}

unittest {
	static const testList = [
		InstructionDefinition("add"      , 0x00000020, 0xFC0007FF),
		InstructionDefinition("addi"     , 0x20000000, 0xFC000000),
		InstructionDefinition("test"     , 0x27000000, 0x0F000000),
	];

	// Check indentation function.
	assertTrue(indent(2, "Test") == "\t\tTest", "Checks indentation");

	// Check getString function.
	assertTrue(getString(0) == "0x_00000000", "Checks 0 value");
	assertTrue(getString(0x15) == "0x_00000015", "Checks unsigned integer");
	assertTrue(getString(-0x999) == "0x_FFFFF667", "Checks signed");

	// Check process_name function.
	assertTrue(process_name("floor.w.s") == "FLOOR_W_S", "Checks process_name conversion");
	
	// Check inArray function.
	assertTrue(inArray([1, 2, 3], 3) == true , "Checks inArray with 3 items");
	assertTrue(inArray([-1, 1  ], 0) == false, "Checks inArray with 2 items");
	assertTrue(inArray([       ], 0) == false, "Checks inArray with 0 items");

	// Check getCommonMask function.
	assertTrue(getCommonMask(testList[0..2]) == 0xFC000000, "getCommonMask check 1");
	assertTrue(getCommonMask(testList[0..3]) == 0x0C000000, "getCommonMask check 2");

	// Check genSwitch function.
	{
		Instruction instruction;

		bool[string] called;

		static string setCalledArray(string opname) { return "called[\"" ~ (opname) ~ "\"] = true;"; }

		void EXECUTE() { mixin(genSwitch(testList[0..2], "setCalledArray")); }

		instruction.v = 0x_00000020; EXECUTE(); // ADD
		instruction.v = 0x_20000000; EXECUTE(); // ADDI
		instruction.v = 0x_30000020; EXECUTE(); // UNK

		assertTrue(("add"  in called) !is null, "Check ADD was called");
		assertTrue(("addi" in called) !is null, "Check ADDI was called");
		assertTrue(("unk"  in called) !is null, "Check an unknown/invalid instruction was detected");
	}
}
