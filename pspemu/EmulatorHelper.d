module pspemu.EmulatorHelper;

import core.thread;
import std.stdio;
import std.c.stdlib;
import std.stream;
import std.file;
import std.path;
import std.string;
import std.array;
import std.process;

import pspemu.Emulator;

import pspemu.core.ThreadState;
import pspemu.core.EmulatorState;

import pspemu.core.cpu.CpuThreadBase;
import pspemu.core.cpu.interpreter.CpuThreadInterpreted;

import pspemu.hle.HleEmulatorState;

import pspemu.hle.ModuleNative;
import pspemu.hle.ModuleLoader;
import pspemu.hle.ModulePsp;
import pspemu.hle.ModuleManager;

import pspemu.gui.GuiBase;

import pspemu.hle.kd.iofilemgr.IoFileMgr;
import pspemu.hle.kd.sysmem.KDebug; 

import pspemu.hle.MemoryManager;
import pspemu.formats.DetectFormat;

import pspemu.hle.vfs.VirtualFileSystem;
import pspemu.hle.vfs.MountableVirtualFileSystem;

import pspemu.utils.Diff;

class EmulatorHelper {
	Emulator emulator;
	
	@property HleEmulatorState hleEmulatorState() {
		return emulator.hleEmulatorState;
	}
	
	this(Emulator emulator) {
		this.emulator = emulator;
		this.init();
	}
	
	public void init() {
		emulator.hleEmulatorState.memoryManager.allocHeap(PspPartition.Kernel0, "KernelFunctions", 1024);
		emulator.emulatorState.memory.twrite!uint(ModuleManager.CODE_PTR_EXIT_THREAD, 0x0000000C | (0x2071 << 6));
		emulator.emulatorState.memory.twrite!uint(ModuleManager.CODE_PTR_END_CALLBACK, 0x0000000C | (0x1003 << 6));
		//emulator.emulatorState.memory.twrite!uint(ModuleLoader.CODE_PTR_END_CALLBACK, 0x0000000C | (0x1002 << 6));
		
		with (emulator.emulatorState) {
			memory.position = ModuleManager.CODE_PTR_ARGUMENTS;
			memory.write(cast(uint)(memory.position + 4));
		}
		
		// @TODO: @FIX: @HACK because not all threads are stopping.
		emulator.emulatorState.runningState.onStop += delegate(...) {
			Thread.sleep(dur!("msecs")(100));
			std.c.stdlib.exit(0);
		};
	}
	
	public void setProgramFirstArg(string programPath) {
		Logger.log(Logger.Level.INFO, "EmulatorHelper", "setProgramFirstArg('%s')", programPath);
		with (emulator.emulatorState) {
			memory.position = ModuleManager.CODE_PTR_ARGUMENTS;
			memory.write(cast(uint)(memory.position + 4));
			memory.writeString(programPath ~ "\0");
		}
	}
	
	public void reset() {
		emulator.reset();
		init();
	}
	
	public void stop() {
		emulator.emulatorState.runningState.stop();
	}

	public void loadMainModule(string pspModulePath) {
		Logger.log(Logger.Level.INFO, "EmulatorHelper", "Loading module ('%s')...", pspModulePath);

		//emulator.hleEmulatorState.memoryManager.allocHeap(PspPartition.User, "temp", 0x4000);
		
		emulator.mainCpuThread.threadState.thid = emulator.hleEmulatorState.uniqueIdFactory.set(0, emulator.mainCpuThread.threadState);
		//writefln("%s", emulator.mainCpuThread.threadState.thid);
		
		string fsProgramPath;
		
		auto rootFileSystem = emulator.hleEmulatorState.rootFileSystem;
		
		string detectedFormat;
		switch (detectedFormat = DetectFormat.detect(pspModulePath)) {
			case "directory": {
				string testPath;
				if (std.file.exists(testPath = pspModulePath ~ "/EBOOT.PBP")) {
					pspModulePath = testPath;
				} else if (std.file.exists(pspModulePath ~ "/PSP_GAME/SYSDIR/BOOT.BIN")) {
					pspModulePath = testPath;
				} else {
					writefln("Can't find any suitable PSP executable on '%s'", pspModulePath);
					throw(new Exception(std.string.format("Can't find any suitable PSP executable on '%s'", pspModulePath)));
				}
			}
			case "pbp": case "elf":
				fsProgramPath = "ms0:/PSP/GAME/virtual/" ~ std.path.basename(pspModulePath);
				rootFileSystem.setVirtualDir(std.path.dirname(pspModulePath));
				rootFileSystem.setVirtualBoot(pspModulePath);
			break;
			case "iso": case "ciso": {
				fsProgramPath = "umd0:/PSP_GAME/SYSDIR/BOOT.BIN";
				rootFileSystem.setIsoPath(pspModulePath);
				emulator.emulatorState.gpu.drawBufferTransferEnabled = false;
				emulator.emulatorState.gpu.justDrawOnVblank = true;
			} break;
			default:
				throw(new Exception(std.string.format("Can't handle type '%s'", detectedFormat)));
			break;
		}
		
		setProgramFirstArg(fsProgramPath);
		
		//ModulePsp modulePsp = emulator.hleEmulatorState.moduleLoader.loadModuleFromVfs(
		//ModulePsp modulePsp = loadModuleFromVfs(
		ModulePsp modulePsp = emulator.hleEmulatorState.moduleManager.loadModuleFromVfs(
			emulator.mainCpuThread,
			fsProgramPath,
			1,
			ModuleManager.CODE_PTR_ARGUMENTS + 4,
			pspModulePath
		);
		
		emulator.hleEmulatorState.mainModule = modulePsp;
		emulator.mainCpuThread.threadState.threadModule = modulePsp; 
	}
	
	public void initComponents() {
		emulator.startDisplay();
		emulator.startGpu();
	}
	
	public void waitComponentsInitialized() {
		emulator.waitDisplayStarted();
		emulator.waitGpuStarted();
	}
	
	public void start() {
		emulator.emulatorState.waitForAllCpuThreadsToTerminate();

		emulator.startMainThread();

		//emulator.emulatorState.dumpThreads();
		
		emulator.emulatorState.waitSomeCpuThreadsToStart();
		//emulator.emulatorState.dumpThreads();

		emulator.emulatorState.waitForAllCpuThreadsToTerminate();
		//emulator.emulatorState.dumpThreads();
	}
	
	public void loadAndRunTest(string pspTestExpectedPath) {
		auto pspTestBasePath = std.path.getName(pspTestExpectedPath);
		auto pspTestElfPath  = std.string.format("%s.elf", pspTestBasePath);
		
		emulator.emulatorState.unittesting = true;
		
		stdout.writef("%s...", pspTestBasePath); stdout.flush();
		if (std.file.exists(pspTestElfPath)) {
			loadMainModule(pspTestElfPath);
			start();

			string expected = std.string.strip(cast(string)std.file.read(pspTestExpectedPath));
			string returned = std.string.strip(emulator.hleEmulatorState.kPrint.outputBuffer);
			
			stdout.writefln("%s", (expected == returned) ? "OK" : "FAIL");
			if (expected != returned) {
				string[] expectedLines = std.array.split(expected, "\n");
				string[] returnedLines = std.array.split(returned, "\n");
				
				//writefln("%s", expectedLines);
				//writefln("%s", returnedLines);
				
				Diff.diffTextProcessed(returnedLines, expectedLines).print();
				/*
				stdout.writefln("    returned:'%s'", std.array.replace(returned, "\n", "|"));
				stdout.writefln("    expected:'%s'", std.array.replace(expected, "\n", "|"));
				*/
			}
		} else {
			stdout.writefln("MISSING %s", pspTestElfPath);
		}
	}
}