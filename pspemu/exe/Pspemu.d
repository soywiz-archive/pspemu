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

class PspDisplay : Display {
	Memory memory;

	this(Memory memory) {
		this.memory = memory;
	}

	void* frameBufferPointer() { return memory.getPointer(info.topaddr); }
}

int main(string[] args) {
	// Components.
	auto memory        = new Memory;
	auto controller    = new Controller();
	auto display       = new PspDisplay(memory);
	auto gpu           = new Gpu(new GpuOpengl, memory);
	auto cpu           = new Cpu(memory, gpu, display, controller);
	auto dissasembler  = new AllegrexDisassembler(memory);

	// HLE.
	auto moduleManager = new ModuleManager(cpu);
	auto loader        = new Loader(cpu, moduleManager);
	auto syscall       = new Syscall(cpu, moduleManager);

	bool showMainMenu  = true;
	
	cpu.init();
	gpu.init();

	//cpu.addBreakpoint(cpu.BreakPoint(0x08900130 + 4, ["t1", "t2", "v0"]));
	//cpu.addBreakpoint(cpu.BreakPoint(0x0893F530, []));

	// Start running.
	if (args.length >= 2) {
		loader.loadAndExecute(args[1]);
	}

	int retval = 0;
	try {
		Application.run(new DisplayForm(showMainMenu, loader, moduleManager, cpu, display, controller));
	} catch (Object o) {
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		retval = -1;
	}
	
	cpu.stop();
	gpu.stop();

	Application.exit();
	return retval;
}
