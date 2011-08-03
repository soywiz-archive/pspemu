module pspemu.Emulator;

import core.thread;
import std.stdio;
import std.c.stdlib;
import std.stream;
import std.file;
import std.path;
import std.process;


import pspemu.core.ThreadState;
import pspemu.core.EmulatorState;

import pspemu.core.cpu.CpuThreadBase;
import pspemu.core.cpu.interpreter.CpuThreadInterpreted;

import pspemu.hle.HleEmulatorState;

import pspemu.hle.ModuleNative;
import pspemu.hle.ModuleLoader;
import pspemu.hle.ModulePsp;

import pspemu.hle.ThreadManager;

class Emulator {
	public EmulatorState emulatorState;
	public HleEmulatorState hleEmulatorState;
	public CpuThreadInterpreted mainCpuThread;
	
	public this() {
		emulatorState    = new EmulatorState();
		hleEmulatorState = new HleEmulatorState(emulatorState);
		mainCpuThread    = new CpuThreadInterpreted(new ThreadState("mainCpuThread", emulatorState));
	}
	
	public void reset() {
		emulatorState.reset();
		hleEmulatorState.reset();
		mainCpuThread    = new CpuThreadInterpreted(new ThreadState("mainCpuThread", emulatorState));
		//hleEmulatorState.threadManager.add(mainCpuThread);
	}
	
	public void startDisplaySynchronized() {
		emulatorState.display.start();
		emulatorState.display.waitStarted();
	}
	
	public void startGpuSynchronized() {
		emulatorState.gpu.start();
		emulatorState.gpu.waitStarted();
	}
	
	public void startMainThread() {
		hleEmulatorState.threadManager.reset();
		hleEmulatorState.threadManager.add(mainCpuThread);
		hleEmulatorState.executionLoop();
		//mainCpuThread.start();
	}
	
	public void dumpRegisteredModules() {
		writefln("ModuleNative.registeredModules:");
		foreach (k, moduleName; ModuleNative.registeredModules) {
			writefln(" :: '%s':'%s'", k, moduleName);
		}
	}
}