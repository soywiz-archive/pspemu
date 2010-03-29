module pspemu.hle.Syscall;

import pspemu.utils.Utils;
import pspemu.utils.Logger;

import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Instruction;

import pspemu.hle.Module;

import pspemu.models.ISyscall;

import std.zlib;

//import std.variant;

class Syscall : ISyscall {
	string[] emits;

	Cpu cpu;
	ModuleManager moduleManager;

	this(Cpu cpu, ModuleManager moduleManager) {
		this.cpu           = cpu;
		this.cpu.syscall   = this;
		this.moduleManager = moduleManager;
	}

	void reset() {
		emits = [];
	}

	void opCall(int code) {
		static string szToString(char *s) { return cast(string)s[0..std.c.string.strlen(s)]; }

		void callModuleFunction(Module.Function* moduleFunction) {
			if (moduleFunction is null) throw(new Exception("Syscall.opCall.callModuleFunction: Invalid Module.Function"));
			moduleFunction.pspModule.cpu = cpu;
			moduleFunction.func();
		}

		void callLibrary(string libraryName, string functionName) {
			callModuleFunction(moduleManager[libraryName].getFunctionByName(functionName));
		}

		switch (code) {
			// Special syscalls for this emulator:
			case 0x1000: { // _pspemuHLECall
				uint PC = cpu.registers.PC;
				cpu.registers.pcSet(cpu.registers.RA);
				callModuleFunction(cast(Module.Function*)cpu.memory.read32(PC));
				return;
			} break;

			case 0x1010: { // void emitInt(int v)
				auto vv = cpu.registers.A0;
				Logger.log(Logger.Level.INFO, "Syscall", "emitInt(%d)", cast(int)vv);
				emits ~= std.string.format("int:%d", cast(int)vv);
			} break;
			case 0x1011: { // void emitFloat(float v)
				auto vv = cpu.registers.F[12];
				Logger.log(Logger.Level.INFO, "Syscall", "emitFloat(%d)", vv);
				emits ~= std.string.format("float:%f", vv);
			} break;
			case 0x1012: { // void emitString(char *v)
				auto vv = szToString(cast(char *)cpu.memory.getPointer(cpu.registers.A0));
				Logger.log(Logger.Level.INFO, "Syscall", "emitString(\"%s\")", vv);
				emits ~= std.string.format("string:\"%s\"", vv);
			} break;
			case 0x1013: { // emitMemoryBlock(void *address, unsigned int size)
				uint vv;
				try {
					auto slice = cpu.memory[cpu.registers.A0..cpu.registers.A0 + cpu.registers.A1];
					vv = crc32(0, slice);
					//writefln("%s", slice);
				} catch (Object o) {
					writefln("Error: %s", o);
				}
				Logger.log(Logger.Level.INFO, "Syscall", "emitMemoryBlock(0x%08X):0x%08X,%d", vv, cpu.registers.A0, cpu.registers.A1);
				emits ~= std.string.format("memory:0x%08X", vv);
			} break;

			case 0x1020: { // void startTracing()
				cpu.checkBreakpoints = true;
				cpu.addBreakpoint(cpu.BreakPoint(cpu.registers.PC, [], true));
			} break;
			case 0x1021: { // void stopTracing()
				cpu.checkBreakpoints = false;
				cpu.instructionCounter.dump();
				//cpu.addBreakpoint(cpu.BreakPoint(cpu.registers.PC, [], true));
			} break;	

			// PSP defined syscalls:
			case 0x2014: callLibrary("ThreadManForUser", "sceKernelSleepThread"); break;
			case 0x2015: callLibrary("ThreadManForUser", "sceKernelSleepThreadCB"); break;
			case 0x2150: callLibrary("sceCtrl",          "sceCtrlPeekBufferPositive"); break;
			case 0x2147: callLibrary("sceDisplay",       "sceDisplayWaitVblankStart"); break;
			case 0x206d: callLibrary("ThreadManForUser", "sceKernelCreateThread"); break;
			case 0x206f: callLibrary("ThreadManForUser", "sceKernelStartThread"); break;
			case 0x2071: callLibrary("ThreadManForUser", "sceKernelExitThread"); break;
			case 0x20bf: callLibrary("UtilsForUser",     "sceKernelUtilsMt19937Init"); break;
			case 0x20c0: callLibrary("UtilsForUser",     "sceKernelUtilsMt19937UInt"); break;
			case 0x213a: callLibrary("sceDisplay",       "sceDisplaySetMode"); break; 
			case 0x213f: callLibrary("sceDisplay",       "sceDisplaySetFrameBuf"); break;
			case 0x20eb: callLibrary("LoadExecForUser",  "sceKernelExitGame"); break;

			// Other syscalls:
			default: throw new Exception(std.string.format("Unimplemented SYSCALL (%08X)", code)); break;
		}
	}
}