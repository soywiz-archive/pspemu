module pspemu.hle.Syscall;

import std.stdio;
import std.conv;
import std.random;
import core.thread;

import pspemu.core.EmulatorState;
import pspemu.core.ThreadState;
import pspemu.core.Memory;

import pspemu.core.exceptions.HaltException;

import pspemu.core.cpu.ISyscall;
import pspemu.core.cpu.Registers;
import pspemu.core.cpu.CpuThreadBase;

import pspemu.utils.MemoryPartition;
import pspemu.utils.UniqueIdFactory;

import pspemu.hle.Module;
import pspemu.hle.ModuleNative;
import pspemu.hle.ModuleManager;
import pspemu.hle.ModuleLoader;
import pspemu.hle.Syscall;

import pspemu.core.cpu.CpuThreadBase;

//import pspemu.hle.kd.sysmem.KDebug;

import pspemu.hle.HleEmulatorState;

class Syscall : ISyscall {
	HleEmulatorState hleEmulatorState;

	static public class Function {
		string info;
		void delegate(Function) callback;
		
		this(void delegate(Function) callback, string info) {
			this.callback = callback;
			this.info = info;
		}
	}
	
	public this(HleEmulatorState hleEmulatorState) {
		this.hleEmulatorState = hleEmulatorState;
	}
	
	public void syscall(CpuThreadBase cpuThread, int syscallNum) {
		if (syscallNum != 0x1000) {
			Logger.log(Logger.Level.TRACE, "Syscall", "%s : Called syscall 0x%04X", thisThreadCpuThreadBase, syscallNum);
		}
		
		static string szToString(char* s) { return cast(string)s[0..std.c.string.strlen(s)]; }

		void callModuleFunction(Module.Function* moduleFunction, string libraryName = "<unsetted:libraryName>", string functionName = "<unsetted:functionName>") {
			if (moduleFunction is null) {
				throw(new Exception(std.string.format("Syscall.opCall.callModuleFunction: Invalid Module.Function (%s::%s)", libraryName, functionName)));
			}
			if (moduleFunction.func is null) {
				throw(new Exception(std.string.format("function is null")));
			}
			moduleFunction.func(cpuThread);
		}

		void callLibrary(string libraryName, string functionName) {
			callModuleFunction(
				hleEmulatorState.moduleManager[libraryName].getFunctionByName(functionName),
				libraryName,
				functionName
			);
		}
		
		auto threadState = cpuThread.threadState;
		auto registers = threadState.registers;
		auto memory = threadState.emulatorState.memory;
		uint get_argument_int(int index) {
			return registers.R[4 + index];
		}
		float get_argument_float(int index) {
			return registers.F[0 + index];
		}
		string get_argument_str(int index) {
			return to!string(cast(char *)memory.getPointerOrNull(get_argument_int(index)));	
		}
		T* get_argument_ptr(T)(int index) {
			return cast(T *)memory.getPointerOrNull(get_argument_int(index));
		}
		void set_return_value(uint value) {
			registers.V0 = value;
		}
		
		//writefln("syscall(%08X)", syscallNum);
		
		switch (syscallNum) {
			// Special syscalls for this emulator:
			case 0x1000: { // _pspemuHLECall
				uint PC = registers.PC;
				auto moduleFunction = memory.tread!(Module.Function *)(PC);
				if (moduleFunction is null) throw(new Exception("Module function not implemented"));
				//writefln("%s", cast(void *)moduleFunction);
				registers.pcSet = registers.RA;
				registers.CallStackPos--;
				try {
					callModuleFunction(moduleFunction);
				} catch (Throwable o) {
					if (cast(HaltException)o) throw(o);
					.writefln("***********************************************");
					.writef("%s: ", moduleFunction.toString);
					.writefln("%s", o);
					.writefln("***********************************************");
					throw(new Exception("There was an error in a hleModule"));
				}
			} break;
			
			// Special syscalls for this emulator:
			case 0x1001: { // _pspemuHLECall2
				uint PC = registers.PC;
				auto functionToCall = memory.tread!(Syscall.Function)(PC);
				.writefln("INFO: %s", functionToCall.info);
				functionToCall.callback(functionToCall);
				throw(new Exception("_pspemuHLECall2"));
			} break;
			
			// Special syscalls for this emulator:
			case 0x1002: { // _pspemuHLECall3
				throw(new HaltException("halt"));
			} break;

			// Special syscalls for this emulator:
			case 0x1003: { // _pspemuHLECall3
				//writefln("RESULT: %08X", registers.V0); 
				//registers.A0 = registers.V0;
				//callLibrary("ThreadManForUser", "sceKernelExitThread");
				throw(new TerminateCallbackException("TerminateCallbackException"));
			} break;

			case 0x206d: callLibrary("ThreadManForUser", "sceKernelCreateThread"); break;
			case 0x206f: callLibrary("ThreadManForUser", "sceKernelStartThread"); break;
			case 0x2071: callLibrary("ThreadManForUser", "sceKernelExitThread"); break;
			case 0x20bf: callLibrary("UtilsForUser",     "sceKernelUtilsMt19937Init"); break;
			case 0x20c0: callLibrary("UtilsForUser",     "sceKernelUtilsMt19937UInt"); break;
			case 0x2147: callLibrary("sceDisplay",       "sceDisplayWaitVblankStart"); break;
			case 0x213a: callLibrary("sceDisplay",       "sceDisplaySetMode"); break; 
			case 0x213f: callLibrary("sceDisplay",       "sceDisplaySetFrameBuf"); break;
			case 0x20eb: callLibrary("LoadExecForUser",  "sceKernelExitGame"); break;
			case 0x2150: callLibrary("sceCtrl",          "sceCtrlPeekBufferPositive"); break;
			case 0x1010: hleEmulatorState.kPrint.Kprintf("EMIT(int):%d\n", cast(int)get_argument_int(0)); break;
			case 0x1011: hleEmulatorState.kPrint.Kprintf("EMIT(float):%f\n", get_argument_float(0)); break;
			case 0x1012: hleEmulatorState.kPrint.Kprintf("EMIT(comment):'%s'\n", get_argument_str(0)); break;
			/*
			void emitString(char *v) {
				asm("syscall 0x1012");
			}
			
			void emitComment(char *v) {
				asm("syscall 0x1012");
			}
			
			void emitMemoryBlock(void *address, unsigned int size) {
				asm("syscall 0x1013");
			}
			
			void emitHex(void *address, unsigned int size) {
				asm("syscall 0x1014");
			*/
			default:
				writefln("syscall(%08X)", syscallNum);
				throw(new Exception(std.string.format("Unknown syscall (%08X)", syscallNum)));
			break;
		}
	}
}