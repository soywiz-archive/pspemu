module pspemu.core.EmulatorState;

import std.datetime;

import pspemu.interfaces.IResetable;
import pspemu.interfaces.IInterruptable;
import pspemu.interfaces.ISyscall;
import pspemu.interfaces.IDisplay;
import pspemu.interfaces.IBattery;

import pspemu.core.Interrupts;
import pspemu.core.Memory;
import pspemu.core.controller.Controller;
import pspemu.core.gpu.Gpu;
import pspemu.core.cpu.Cpu;

class EmulatorState : IResetable, IInterruptable {
	// Information
	public SysTime       startTime; 
	public bool          unittesting = false;

	// Components
	public Interrupts    interrupts;
	public Memory        memory;
	public IBattery      battery;
	public IDisplay      display;
	public Controller    controller;
	public Gpu           gpu;
	public Cpu           cpu;
	public ISyscall      syscall;

	this(Interrupts interrupts, Memory memory, IBattery battery, IDisplay display, Controller controller, Gpu gpu, Cpu cpu) {
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
	
	void interrupt() {
		this.cpu.interrupt();
	}
	
	public void reset() {
		resetVariables();
		resetComponents();
	}
}