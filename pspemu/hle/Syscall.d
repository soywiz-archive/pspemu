module pspemu.hle.Syscall;

import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Instruction;

import pspemu.hle.Module;

class Syscall {
	static void opCall(Cpu cpu, Instruction instruction) {
		uint   param   (int n) { return cpu.registers[4 + n]; }
		void*  param_p (int n) { return cpu.memory.getPointer(cpu.registers[4 + n]); }
		char*  paramszp(int n) { return cast(char *)param_p(n); }
		char[] paramsz (int n) { auto ptr = paramszp(n); return ptr[0..std.c.string.strlen(ptr)]; }

		void callLibrary(string libraryName, string functionName) {
			auto func = pspemu.hle.Module.Module.loadModule(libraryName).names[functionName];
			func.pspModule.cpu = cpu;
			func.func();
		}

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
				auto func = cast(pspemu.hle.Module.Module.Function*)cpu.memory.read32(cpu.registers.PC);
				func.pspModule.cpu = cpu;
				cpu.registers.pcSet(cpu.registers.RA);
				func.func();
				return;
			} break;
			default:
				.writefln("Unimplemented SYSCALL (%08X)", instruction.CODE);
				assert(0);
			break;
		}
	}
}