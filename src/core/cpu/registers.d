module pspemu.core.cpu.registers;

import std.stdio, std.string;

version = VERSION_R0_CHECK;

class Registers {
	uint PC, nPC;
	uint HI, LO;
	uint IC;
	uint[32] R;
	union { float[32] F; double[16] D; }
	protected static int[string] aliases;

	static this() {
		aliases["zero"] = 0;
		foreach (n; 0..32) aliases[format("r%d", n)] = aliases[format("$%d", n)] = n;
		foreach (n, name; [
			"zr", "at", "v0", "v1", "a0", "a1", "a2", "a3",
			"t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7",
			"s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7",
			"t8", "t9", "k0", "k1", "gp", "sp", "fp", "ra"
		]) aliases[name] = n;
		aliases = aliases.rehash;
	}

	void reset() {
		PC = 0; nPC = 4;
		R[0..$] = 0;
		F[0..$] = 0.0;
		//D[0..$] = 0.0;
	}

	uint opIndex(uint   index) { return R[index]; }
	uint opIndex(string index) { return this[aliases[index]]; }

	static int getAlias(string aliasName) {
		assert(aliasName in aliases, format("Unknown register alias '%s'", aliasName));
		return aliases[aliasName];
	}

	uint opIndexAssign(uint value, uint index) {
		R[index] = value;
		version (VERSION_R0_CHECK) if (index == 0) R[index] = 0;
		return R[index];
	}

	void pcAdvance(int offset = 4) { PC = nPC; nPC += offset; }
	void pcSet(uint address) { PC  = address; nPC = PC + 4; }

	void dump(bool reduced = true) {
		writefln("Registers {");
		writefln("  PC = 0x%08X | nPC = 0x%08X", PC, nPC);
		writefln("  LO = 0x%08X | HI  = 0x%08X", LO, HI );
		writefln("  IC = 0x%08X", IC);
		foreach (k, v; R) {
			if (reduced && (v == 0)) continue;
			writefln("  r%-2d = 0x%08X", k, v);
		}
		writefln("}");
	}
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope registers = new Registers();

	// Set all the integer registers expect the 0.
	foreach (n; 1 .. 32) {
		registers[n] = n;
		assert(registers[n] == n);
	}

	// Check setting register 0.
	version (VERSION_R0_CHECK) {
		registers[0] = 1;
		assert(registers[0] == 0);
	} else {
		registers[0] = 1;
		assert(registers[0] == 1);
	}

	// Check PC set and increment.
	registers.pcSet(0x1000);
	assert(registers.PC == 0x1000);
	assert(registers.nPC == 0x1004);

	registers.pcAdvance(4);
	assert(registers.PC == 0x1004);
	assert(registers.nPC == 0x1008);
}