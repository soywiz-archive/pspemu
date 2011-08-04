module pspemu.core.EmulatorState;

import std.datetime;

import pspemu.interfaces.IResetable;
import pspemu.interfaces.ISyscall;

import pspemu.core.Interrupts;
import pspemu.core.Memory;
import pspemu.core.battery.Battery;
import pspemu.core.display.Display;
import pspemu.core.controller.Controller;
import pspemu.core.RunningState;
import pspemu.core.gpu.Gpu;
import pspemu.core.cpu.Cpu;

class EmulatorState : IResetable {
	// Information
	public SysTime       startTime; 
	public bool          unittesting = false;

	// Components
	public Interrupts    interrupts;
	public Memory        memory;
	public Battery       battery;
	public Display       display;
	public Controller    controller;
	public Gpu           gpu;
	public Cpu           cpu;
	public ISyscall      syscall;
	public RunningState  runningState;

	this(Interrupts interrupts, Memory memory, Battery battery, Display display, Controller controller, RunningState runningState, Gpu gpu, Cpu cpu) {
		this.interrupts    = interrupts; 
		this.memory        = memory;
		this.battery       = battery;
		this.display       = display;
		this.controller    = controller;
		this.runningState  = runningState;
		this.gpu           = gpu;
		this.cpu           = cpu;
		
		resetVariables();
	}
	
	protected void resetVariables() {
		this.startTime = Clock.currTime;
	}
	
	protected void resetComponents() {
		this.interrupts.reset();
		this.memory.reset();
		this.display.reset();
		this.controller.reset();
		this.gpu.reset();
		this.runningState.reset();
	}
	
	public void reset() {
		resetVariables();
		resetComponents();
	}
}