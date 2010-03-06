module pspemu.core.cpu.ops.Misc;

import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Instruction;
import pspemu.core.Memory;

import pspemu.hle.Module;

import std.stdio;

class HaltException : Exception { this(string type = "HALT") { super(type); } }

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
		uint param(int n) { return registers[4 + n]; }
		void* param_p(int n) { return memory.getPointer(registers[4 + n]); }
		char* paramszp(int n) { return cast(char *)param_p(n); }
		char[] paramsz(int n) { auto ptr = paramszp(n); return ptr[0..std.c.string.strlen(ptr)]; }

		void callLibrary(string libraryName, string functionName) {
			auto func = pspemu.hle.Module.Module.loadModule(libraryName).names[functionName];
			func.pspModule.cpu = cpu;
			func.func();
		}

		registers.pcAdvance(4);
		//writefln();
		switch (instruction.CODE) {
			case 0x2150: callLibrary("sceCtrl", "sceCtrlPeekBufferPositive"); break;
			case 0x2147: callLibrary("sceDisplay", "sceDisplayWaitVblankStart"); break;
			case 0x206d: callLibrary("ThreadManForUser", "sceKernelCreateThread"); break;
			case 0x206f: callLibrary("ThreadManForUser", "sceKernelStartThread"); break;
			case 0x2071: callLibrary("ThreadManForUser", "sceKernelExitThread"); break;
			case 0x20bf: callLibrary("UtilsForUser", "sceKernelUtilsMt19937Init"); break;
			case 0x20c0: callLibrary("UtilsForUser", "sceKernelUtilsMt19937UInt"); break;
			case 0x213a: callLibrary("sceDisplay", "sceDisplaySetMode"); break; 
			case 0x213f: callLibrary("sceDisplay", "sceDisplaySetFrameBuf"); break;
			case 0x20eb: callLibrary("LoadExecForUser", "sceKernelExitGame"); break;
			case 0x2307: { // _pspemuHLECall
				auto func = cast(pspemu.hle.Module.Module.Function*)memory.read32(registers.PC);
				func.pspModule.cpu = cpu;
				registers.pcSet(registers.RA);
				func.func();
				return;
			} break;
			default:
				.writefln("Unimplemented SYSCALL (%08X)", instruction.CODE);
				assert(0);
			break;
		}
	}

	// Inlined.
	auto OP_UNK() { return q{
		.writefln("Unknown operation %s", instruction);
		registers.pcAdvance(4);
	}; }
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope memory    = new Memory;
	scope registers = new Registers;
	Instruction instruction = void;

	mixin TemplateCpu_MISC;
}
