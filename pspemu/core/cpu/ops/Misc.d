module pspemu.core.cpu.ops.Misc;

import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Instruction;
import pspemu.core.Memory;

import std.stdio;

class HaltException : Exception { this(string type = "HALT") { super(type); } }

import std.random;

//debug = DEBUG_SYSCALL;

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
		switch (instruction.CODE) {
			case 0x2150: { // _sceCtrlPeekBufferPositive
				registers.V0 = 0xFFFFFFFF;
				debug (DEBUG_SYSCALL) .writefln("_sceCtrlPeekBufferPositive");
			} break;
			case 0x20eb: { // _sceKernelExitGame 
				registers.V0 = 0;
				debug (DEBUG_SYSCALL) .writefln("_sceKernelExitGame");
			} break;
			case 0x2147: { // _sceDisplayWaitVblankStart
				registers.V0 = 0;
				debug (DEBUG_SYSCALL) .writefln("_sceDisplayWaitVblankStart");
			} break;
			case 0x20bf: { // _sceKernelUtilsMt19937Init
				// int 	sceKernelUtilsMt19937Init (SceKernelUtilsMt19937Context *ctx, u32 seed)
				auto mt = cast(std.random.Mt19937 *)param_p(0);
				mt.seed(param(1));
				debug (DEBUG_SYSCALL) .writefln("_sceKernelUtilsMt19937Init(ctx=0x%08X, seed=0x%08X)", param(0), param(1));
				registers.V0 = 0;
			} break;
			case 0x20c0: { // _sceKernelUtilsMt19937UInt
				auto mt = cast(std.random.Mt19937 *)param_p(0);
				// u32 	sceKernelUtilsMt19937UInt (SceKernelUtilsMt19937Context *ctx)
				registers.V0 = mt.front;
				mt.popFront();
				debug (DEBUG_SYSCALL) .writefln("_sceKernelUtilsMt19937UInt(ctx=0x%08X) == 0x%08X", param(0), registers.V0);
			} break;
			case 0x2071: // _sceKernelExitThread
				//int 	sceKernelExitThread (int status)
				registers.V0 = 0;
				debug (DEBUG_SYSCALL) .writefln("_sceKernelExitThread(status=%d) == %d", param(0), registers.V0);
			break;
			case 0x213a: // _sceDisplaySetMode
				// int 	sceDisplaySetMode (int mode, int width, int height)
				registers.V0 = 0;
				debug (DEBUG_SYSCALL) .writefln("_sceDisplaySetMode (mode=%d, width=%d, height=%d)", param(0), param(1), param(2));
			break;
			case 0x213f: // _sceDisplaySetFrameBuf
				// int 	sceDisplaySetFrameBuf (void *topaddr, int bufferwidth, int pixelformat, int sync)
				debug (DEBUG_SYSCALL) .writefln("_sceDisplaySetFrameBuf (%d, %d, %d, 0x%08X)", param(0), param(1), param(2), param(3));
				registers.V0 = 0;
			break;
			case 0x206d: // _sceKernelCreateThread
				// SceUID 	sceKernelCreateThread (const char *name, SceKernelThreadEntry entry, int initPriority, int stackSize, SceUInt attr, SceKernelThreadOptParam *option)
				debug (DEBUG_SYSCALL) .writefln("_sceKernelCreateThread(name='%s', entry=0x%08X, initPriority=%d, stackSize=%d, attr=0x%08X, option=0x%08X)", paramsz(0), param(1), param(2), param(3), param(4), param(5));
				registers.V0 = 9999;
			break;
			case 0x206f: // _sceKernelStartThread:
				// int 	sceKernelStartThread (SceUID thid, SceSize arglen, void *argp)
				debug (DEBUG_SYSCALL) .writefln("_sceKernelStartThread(thid=%d, arglen=%d, argp=0x%08X)", param(0), param(1), param(2));
				registers.V0 = 0;
			break;
			default:
				.writefln("Unimplemented SYSCALL (%08X)", instruction.CODE);
			break;
		}
		registers.pcAdvance(4);
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
