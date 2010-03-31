module pspemu.core.cpu.interpreted.ops.Misc;
import pspemu.core.cpu.interpreted.Utils;

version = STOP_AT_UNKNOWN_INSTRUCTION;

import pspemu.hle.Syscall;

// http://pspemu.googlecode.com/svn/branches/old/src/core/cpu.d
// http://pspemu.googlecode.com/svn/branches/old/util/gen/impl/SPECIAL
// http://pspemu.googlecode.com/svn/branches/old/util/gen/impl/MISC
template TemplateCpu_MISC() {
	// sceKernelSuspendInterrupts
	auto OP_MFIC() { registers[instruction.RT] = registers.IC; registers.pcAdvance(4); }
	auto OP_MTIC() { registers.IC = registers[instruction.RT]; registers.pcAdvance(4); }

	auto OP_BREAK() {
		registers.pcAdvance(4);
		throw(new HaltException("BREAK"));
	}

	auto OP_DBREAK() {
		registers.pcAdvance(4);
		throw(new HaltException("DBREAK"));
	}

	auto OP_HALT() {
		registers.pcAdvance(4);
		throw(new HaltException("HALT"));
	}

	auto OP_SYNC() {
		.writefln("Unimplemented SYNC");
		registers.pcAdvance(4);
	}

	auto OP_SYSCALL() {
		registers.pcAdvance(4);
		if (cpu.syscall is null) {
			.writefln("Syscall handler not set");
		} else {
			cpu.syscall(instruction.CODE);
		}
	}

	// Inlined.
	auto OP_UNK() {
		.writefln("Unknown operation 0x%08X at 0x%08X", instruction.v, registers.PC);
		version (STOP_AT_UNKNOWN_INSTRUCTION) assert(0, std.string.format("Unknown operation 0x%08X at 0x%08X", instruction.v, registers.PC));
		registers.pcAdvance(4);
	}
}
