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
	
	public this() {
		emulatorState    = new EmulatorState();
		hleEmulatorState = new HleEmulatorState(emulatorState);
	}
	
	public void reset() {
		emulatorState.reset();
		hleEmulatorState.reset();
	}
	
	void startComponentsSynchronized() {
		emulatorState.display.start();
		emulatorState.display.waitStarted();
		
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