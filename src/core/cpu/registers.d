module pspemu.core.cpu.registers;

import std.stdio;

version = VERSION_R0_CHECK;

class Registers {
	uint PC, nPC;
	uint[32] R;
	union { float[32] F; double[16] D; }

	void reset() {
		nPC = PC = 0;
		R[0..$] = 0;
		F[0..$] = 0.0;
		D[0..$] = 0.0;
	}

	uint opIndex(uint index) {
		return R[index];
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
}

unittest {
	writefln("Unittesting: Registers...");
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

	// Check PC increment.
	registers.PC  = 0x1000;
	registers.nPC = 0x1004;
	registers.advance_pc(4);
	assert(registers.PC == 0x1004);
	assert(registers.nPC == 0x1008);
}
