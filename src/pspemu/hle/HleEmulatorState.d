module pspemu.hle.HleEmulatorState;

/+
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

import pspemu.utils.UniqueIdFactory;

import pspemu.hle.Module;
import pspemu.hle.ModuleNative;
import pspemu.hle.ModulePsp;
import pspemu.hle.ModuleManager;
import pspemu.hle.MemoryManager;
import pspemu.hle.ModuleLoader;
import pspemu.hle.Syscall;
import pspemu.hle.RootFileSystem;
import pspemu.hle.Callbacks;
import pspemu.hle.KPrint;
import pspemu.hle.OsConfig;
import pspemu.hle.ThreadScheduler;

import pspemu.core.exceptions.NotImplementedException;

import pspemu.core.cpu.interpreter.CpuThreadInterpreted;

class HleEmulatorState : ISyscall {
	public UniqueIdFactory    uniqueIdFactory;
	public EmulatorState      emulatorState;
	public ModuleManager      moduleManager;
	public ModuleLoader       moduleLoader;
	public Syscall            syscallObject;
	public MemoryManager      memoryManager;
	public RootFileSystem     rootFileSystem;
	public CallbacksHandler   callbacksHandler;
	public KPrint             kPrint;
	public ModulePsp          mainModule;
	public OsConfig           osConfig;
	public Object             globalLock;
	public HleThreadManager   hleThreadManager;
	
	string mainModuleName() {
		return mainModule ? mainModule.name : "Not loaded";
	}

	public this(EmulatorState emulatorState) {
		globalLock = new Object();
		
		this.emulatorState = emulatorState;
		reset();
	}
	
	public void reset() {
		this.uniqueIdFactory  = new UniqueIdFactory();
		this.moduleManager    = new ModuleManager(this);
		this.memoryManager    = new MemoryManager(this.emulatorState.memory, this.moduleManager);
		this.moduleLoader     = new ModuleLoader(this);
		this.syscallObject    = new Syscall(this);
		this.rootFileSystem   = new RootFileSystem(this);
		this.callbacksHandler = new CallbacksHandler(this);
		this.kPrint           = new KPrint();
		this.osConfig         = new OsConfig();
		this.threadManager    = new ThreadManager();
		this.emulatorState.syscall = this;
	}

	public ThreadState currentThreadState() {
		throw(new Exception("Not implemented"));
	}
	
	public uint delegate() createExecuteGuestCode(ThreadState threadState, uint pointer) {
		return delegate() {
			return executeGuestCode(threadState, pointer);
		};
	}
	
	public uint executeGuestCode(uint pointer, uint[] arguments = null) {
		return executeGuestCode(thisThreadCpuThreadBase.threadState, pointer, arguments);
	}
	
	public uint executeGuestCode(ThreadState threadState, uint pointer, uint[] arguments = null) {
		//new CpuThreadBase();
		CpuThreadBase tempCpuThread = new CpuThreadInterpreted(threadState);
		
		Registers backRegisters = new Registers();
		backRegisters.copyFrom(tempCpuThread.threadState.registers);

		scope (exit) {
			tempCpuThread.threadState.registers.copyFrom(backRegisters);
		} 
		
		if (arguments !is null) {
			foreach (k, argument; arguments) tempCpuThread.threadState.registers.R[4 + k] = argument;
		}

		tempCpuThread.threadState.registers.pcSet = pointer;
		//tempCpuThread.threadState.registers.RA = EmulatorHelper.CODE_PTR_END_CALLBACK;
		tempCpuThread.threadState.registers.RA = 0x08000004;
		
		//writefln("**%08X", tempCpuThread.threadState.registers.PC);
		tempCpuThread.execute(false);
		//tempCpuThread.execute(true);
		return tempCpuThread.threadState.registers.V0;
	}

	public void syscall(CpuThreadBase cpuThread, int syscallNum) {
		this.syscallObject.syscall(cpuThread, syscallNum);
	}
}
+/
