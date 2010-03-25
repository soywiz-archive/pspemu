module pspemu.exe.Pspemu;

//version = TRACE_FROM_BEGINING;

import std.stream, std.stdio, core.thread;

import dfl.all;

import std.c.windows.windows;

import pspemu.utils.Utils;

import pspemu.gui.MainForm;
import pspemu.gui.DisplayForm;

import pspemu.models.IDisplay;
import pspemu.models.IController;
import pspemu.models.ISyscall;

import pspemu.formats.Pbp;

import pspemu.core.Memory;
import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Disassembler;
import pspemu.core.gpu.Gpu;
import pspemu.core.gpu.impl.GpuOpengl;

import pspemu.hle.Module;
import pspemu.hle.Loader;
import pspemu.hle.Syscall;

class PspDisplay : BasePspDisplay {
	Memory memory;
	bool _vblank = true;

	this(Memory memory) {
		this.memory = memory;
		super();
	}

	void* frameBufferPointer() {
		//return memory.getPointer(Memory.frameBufferAddress);
		//writefln("%08X", memory.displayMemory);
		return memory.getPointer(_info.topaddr);
	}

	bool vblank(bool status) { return _vblank = status; }
	bool vblank() { return _vblank; }
}

int main(string[] args) {
	auto memory        = new Memory;
	auto controller    = new Controller();
	auto display       = new PspDisplay(memory);
	auto gpu           = new Gpu(new GpuOpengl, memory);
	auto cpu           = new Cpu(memory, gpu, display, controller);

	// HLE.
	auto moduleManager = new ModuleManager(cpu);
	auto loader        = new Loader(cpu, moduleManager);
	auto syscall       = new Syscall(cpu, moduleManager);

	//cpu.addBreakpoint(cpu.BreakPoint(0x08900130 + 4, ["t1", "t2", "v0"]));
	//cpu.addBreakpoint(cpu.BreakPoint(0x0893F530, []));
	

	string executableFile;

	executableFile = "tests/test1.elf";

	if (args.length >= 2) {
		executableFile = args[1];
	}

	// Load.
	loader.load(executableFile);
	loader.setRegisters();

	version (TRACE_FROM_BEGINING) {
		cpu.addBreakpoint(cpu.BreakPoint(loader.PC, [], true));
	}

	// Start GPU.
	gpu.start();

	// Start CPU.
	cpu.start();


	int retval = 0;
	try {
		Application.run(new DisplayForm(moduleManager, cpu, display, controller));
	} catch (Object o) {
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		retval = -1;
	}
	
	cpu.stop();
	gpu.stop();

	Application.exit();
	return retval;
}
