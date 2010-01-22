module pspemu.core.cpu.cpu_ops_misc;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

import std.stdio;

class HaltException : Exception { this(string type = "HALT") { super(type); } }

// http://pspemu.googlecode.com/svn/branches/old/src/core/cpu.d
// http://pspemu.googlecode.com/svn/branches/old/util/gen/impl/SPECIAL
// http://pspemu.googlecode.com/svn/branches/old/util/gen/impl/MISC
template TemplateCpu_MISC() {
	// sceKernelSuspendInterrupts
	void OP_MFIC() { registers[instruction.RT] = registers.IC; registers.pcAdvance(4); }
	void OP_MTIC() { registers.IC = registers[instruction.RT]; registers.pcAdvance(4); }

	void OP_BREAK() {
		registers.pcAdvance(4);
		throw(new HaltException("BREAK"));
	}

	void OP_DBREAK() {
		registers.pcAdvance(4);
		throw(new HaltException("DBREAK"));
	}

	void OP_HALT() {
		registers.pcAdvance(4);
		throw(new HaltException("HALT"));
	}

	void OP_SYNC() {
		.writefln("Unimplemented SYNC");
		registers.pcAdvance(4);
	}

	void OP_SYSCALL() {
		.writefln("Unimplemented SYSCALL");
		registers.pcAdvance(4);
	}
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope memory    = new Memory;
	scope registers = new Registers;
	Instruction instruction = void;

	mixin TemplateCpu_MISC;
}