module pspemu.hle.Syscall;

import pspemu.All;

class Syscall : ISyscall {
	string[] emits;
	struct CallbackState {
		Registers registers;
		PspThread thread;
		bool paused;
	}
	CallbackState[] interruptCallbackStatePool;

	void reset() {
		emits = [];
	}

	void opCallReal(ExecutionState executionState, int code) {
		static string szToString(char* s) { return cast(string)s[0..std.c.string.strlen(s)]; }

		void callModuleFunction(Module.Function* moduleFunction) {
			if (moduleFunction is null) throw(new Exception("Syscall.opCall.callModuleFunction: Invalid Module.Function"));
			//moduleFunction.pspModule.cpu = cpu; // Not Thread Safe
			moduleFunction.func();
		}

		void callLibrary(string libraryName, string functionName) {
			callModuleFunction(executionState.systemHLE.moduleManager[libraryName].getFunctionByName(functionName));
		}

		switch (code) {
			// Special syscalls for this emulator:
			case 0x1000: { // _pspemuHLECall
				uint PC = executionState.registers.PC;
				auto moduleFunction = cast(Module.Function*)executionState.memory.tread!(uint)(PC);
				executionState.registers.pcSet(executionState.registers.RA);
				try {
					callModuleFunction(moduleFunction);
				} catch (Object o) {
					if (cast(HaltException)o) throw(o);
					throw(new Exception(std.string.format("%s: %s", moduleFunction.toString, o)));
				}
			} break;
			case 0x1001: { // _pspemuHLEInterruptCallbackEnter
				auto pspThread = executionState.systemHLE.moduleManager.get!(ThreadManForUser).threadManager.currentThread;
				//writefln("_pspemuHLEInterruptCallbackEnter"); cpu.startTracing();
				auto backRegisters = new Registers;
				backRegisters.copyFrom(executionState.registers);
				interruptCallbackStatePool ~= CallbackState(backRegisters, pspThread, pspThread.paused);
				pspThread.paused = false;
			} break;
			case 0x1002: { // _pspemuHLEInterruptCallbackReturn
				//writefln("_pspemuHLEInterruptCallbackReturn"); cpu.stopTracing();
				auto callbackState = interruptCallbackStatePool[$ - 1];
				executionState.registers.copyFrom(callbackState.registers);
				callbackState.thread.paused = callbackState.paused;
				interruptCallbackStatePool.length = interruptCallbackStatePool.length - 1;
			} break;
			case 0x1003: { // _pspemuHLEInvalid
				throw(new Exception("_pspemuHLEInvalid"));
			} break;
			case 0x1010: { // void emitInt(int v)
				auto vv = executionState.registers.A0;
				Logger.log(Logger.Level.INFO, "Syscall", "emitInt(%d)", cast(int)vv);
				emits ~= std.string.format("int:%d", cast(int)vv);
			} break;
			case 0x1011: { // void emitFloat(float v)
				auto vv = executionState.registers.F[12];
				Logger.log(Logger.Level.INFO, "Syscall", "emitFloat(%f)", vv);
				emits ~= std.string.format("float:%f", vv);
			} break;
			case 0x1012: { // void emitString(char *v)
				auto vv = szToString(cast(char *)executionState.memory.getPointer(executionState.registers.A0));
				Logger.log(Logger.Level.INFO, "Syscall", "emitString(\"%s\")", vv);
				emits ~= std.string.format("string:\"%s\"", vv);
			} break;
			case 0x1013: { // emitMemoryBlock(void *address, unsigned int size)
				uint vv;
				try {
					auto slice = executionState.memory[executionState.registers.A0..executionState.registers.A0 + executionState.registers.A1];
					vv = crc32(0, slice);
					//writefln("%s", slice);
				} catch (Object o) {
					writefln("Error: %s", o);
				}
				Logger.log(Logger.Level.INFO, "Syscall", "emitMemoryBlock(0x%08X):0x%08X,%d", vv, executionState.registers.A0, executionState.registers.A1);
				emits ~= std.string.format("memory:0x%08X", vv);
			} break;
			case 0x1014: { // emitHex(void *address, unsigned int size)
				uint vv;
				auto slice = executionState.memory[executionState.registers.A0..executionState.registers.A0 + executionState.registers.A1];
				string hex_string = "";
				foreach (value; slice) hex_string ~= std.string.format("%02X", value);
				Logger.log(Logger.Level.INFO, "Syscall", "emitHex(%s):0x%08X,%d", vv, executionState.registers.A0, executionState.registers.A1);
				emits ~= std.string.format("hex:%s", hex_string);
			} break;

			case 0x1020: { // void startTracing()
				//executionState.startTracing();
				throw(new Exception("executionState.startTracing();"));
			} break;
			case 0x1021: { // void stopTracing()
				//executionState.stopTracing();
				throw(new Exception("executionState.stopTracing();"));
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
	
	void opCall(ExecutionState executionState, int code) {
		try {
			opCallReal(executionState, code);
		} catch (Object o) {
			if (cast(HaltException)o) throw(o);
			executionState.registers.dump();
			throw(new Exception(std.string.format("SYSCALL(0x%04X): %s", code, o)));
		}
	}
}