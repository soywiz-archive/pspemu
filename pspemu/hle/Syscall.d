module pspemu.hle.Syscall;

debug = DEBUG_EMIT;

import pspemu.utils.Utils;
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Instruction;

import pspemu.hle.Module;

import pspemu.models.ISyscall;

//import std.variant;

string szToString(char *s) { return cast(string)s[0..std.c.string.strlen(s)]; }

class Syscall : ISyscall {
	string[] emits;

	Cpu cpu;
	ModuleManager moduleManager;

	this(Cpu cpu, ModuleManager moduleManager) {
		this.cpu           = cpu;
		this.cpu.syscall   = this;
		this.moduleManager = moduleManager;
	}

	void opCall(int code) {
		uint   param   (int n) { return cpu.registers[4 + n]; }
		void*  param_p (int n) { return cpu.memory.getPointer(cpu.registers[4 + n]); }
		char*  paramszp(int n) { return cast(char *)param_p(n); }
		char[] paramsz (int n) { auto ptr = paramszp(n); return ptr[0..std.c.string.strlen(ptr)]; }

		void callLibrary(string libraryName, string functionName) {
			auto func = moduleManager[libraryName].getFunctionByName(functionName);
			func.pspModule.cpu = cpu;
			func.func();
		}

		switch (code) {
			case 0x2014: callLibrary("ThreadManForUser", "sceKernelSleepThread"); break;
			case 0x2015: callLibrary("ThreadManForUser", "sceKernelSleepThreadCB"); break;
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
				auto func = cast(pspemu.hle.Module.Module.Function*)cpu.memory.read32(cpu.registers.PC);
				func.pspModule.cpu = cpu;
				cpu.registers.pcSet(cpu.registers.RA);
				func.func();
				return;
			} break;
			case 0x2308: { // void emitInt(int v)
				auto vv = cpu.registers["a0"];
				debug (DEBUG_EMIT) writefln("emitInt(%d)", vv);
				emits ~= std.string.format("%d", vv);
			} break;
			case 0x2309: { // void emitFloat(float v)
				auto vv = cpu.registers.F[12];
				debug (DEBUG_EMIT) writefln("emitFloat(%f)", vv);
				emits ~= std.string.format("%f", vv);
			} break;
			case 0x230A: { // void emitString(char *v)
				auto vv = szToString(cast(char *)cpu.memory.getPointer(cpu.registers["a0"]));
				debug (DEBUG_EMIT) writefln("emitString(\"%s\")", vv);
				emits ~= std.string.format("\"%s\"", vv);
				//emits ~= cast(char *)cpu.memory.getPointer(cast(uint *)reinterpret!(char *)(cpu.registers.F[12]));
			} break;
			case 0x230B: { // void startTracing()
				cpu.checkBreakpoints = true;
				cpu.addBreakpoint(cpu.BreakPoint(cpu.registers.PC, [], true));
			} break;
			case 0x230C: { // void stopTracing()
				cpu.checkBreakpoints = false;
				cpu.instructionCounter.dump();
				//cpu.addBreakpoint(cpu.BreakPoint(cpu.registers.PC, [], true));
			} break;
			default:
				.writefln("Unimplemented SYSCALL (%08X)", code);
				assert(0);
			break;
		}
	}
}