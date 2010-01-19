module pspemu.core.cpu.registers;

import std.stdio, std.string;

version = VERSION_R0_CHECK;

/*
FIXME:
string[] list1 = ["r0", "r1", ...];
string[] list2 = ["v0", "v1", "a0", ...];
static this() {
	foreach (list; [list1, list2]) foreach (index, name; list) registerAliases[name] = index;
}
*/
static int[string] registerAliases;
static this() {
	foreach (n; 0..32) registerAliases[format("r%d", n)] = registerAliases[format("$%d", n)] = n;
	registerAliases["zero"] = 0;
	foreach (n; 0..10) {
		if (n <= 1) registerAliases[format("v%d", n)] =  2 + n;
		if (n <= 3) registerAliases[format("a%d", n)] =  4 + n;
		if (n <= 7) registerAliases[format("t%d", n)] =  9 + n;
		if (n <= 7) registerAliases[format("s%d", n)] = 16 + n;
		if (n <= 1) registerAliases[format("k%d", n)] = 26 + n;
	}
	registerAliases["t8"] = 24;
	registerAliases["t9"] = 25;
	registerAliases["gp"] = 28;
	registerAliases["sp"] = 29;
	registerAliases["s8"] = 30;
	registerAliases["ra"] = 31;
}

class Registers {
	uint PC, nPC;
	uint[32] R;
	union { float[32] F; double[16] D; }

	void reset() {
		PC = 0; nPC = 4;
		R[0..$] = 0;
		F[0..$] = 0.0;
		//D[0..$] = 0.0;
	}

	uint opIndex(uint index) {
		return R[index];
	}

	uint opIndex(string index) {
		return this[registerAliases[index]];
	}

	uint opIndexAssign(uint value, uint index) {
		R[index] = value;
		version (VERSION_R0_CHECK) if (index == 0) R[index] = 0;
		return R[index];
	}

	void advance_pc(int offset = 4) {
		PC = nPC;
		nPC += offset;
	}

	void set_pc(uint address) {
		PC  = address;
		nPC = PC + 4;
	}

	void dump(bool reduced = true) {
		writefln("Registers {");
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
	registers.set_pc(0x1000);
	assert(registers.PC == 0x1000);
	assert(registers.nPC == 0x1004);

	registers.advance_pc(4);
	assert(registers.PC == 0x1004);
	assert(registers.nPC == 0x1008);
}