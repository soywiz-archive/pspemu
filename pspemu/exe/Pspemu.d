module pspemu.exe.Pspemu;

//version = TRACE_FROM_BEGINING;

import std.stream, std.stdio, core.thread;

import dfl.all;

import std.c.windows.windows;

import pspemu.gui.MainForm;
import pspemu.gui.DisplayForm;

import pspemu.models.IDisplay;

import pspemu.formats.Pbp;

import pspemu.core.Memory;
import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Disassembler;
import pspemu.core.gpu.Gpu;

import pspemu.hle.Loader;

class PspDisplay : BasePspDisplay {
	Memory memory;
	bool _vblank = true;

	this(Memory memory) {
		this.memory = memory;
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
	auto memory  = new Memory;
	auto display = new PspDisplay(memory);
	auto gpu     = new Gpu(memory);
	auto cpu     = new Cpu(memory, gpu, display);
	auto dissasembler = new AllegrexDisassembler(memory);

	//cpu.addBreakpoint(cpu.BreakPoint(0x08900130 + 4, ["t1", "t2", "v0"]));

	string executableFile;

	//executableFile = "demos/minifire.elf";
	//executableFile = "demos/controller.pbp";
	//executableFile = "demos/counter.pbp";
	//executableFile = "demos/mytest.pbp";
	//executableFile = "demos/text.pbp";
	//executableFile = "demos/lines.pbp";
	executableFile = "tests/test1.elf";
	//
	//executableFile = "demos/cube.pbp";
	//executableFile = "demos/ortho.pbp";

	if (args.length >= 2) {
		executableFile = args[1];
	}
	
	auto loader  = new Loader(executableFile, cpu);
	loader.setRegisters();

	version (TRACE_FROM_BEGINING) {
		cpu.checkBreakpoints = true;
		cpu.addBreakpoint(cpu.BreakPoint(loader.PC, [], true));
	}

	/*
	cpu.checkBreakpoints = true;
	cpu.addBreakpoint(cpu.BreakPoint(0x890042C, ["f0", "f1", "f12"], true));
	*/

	// Start GPU.
	gpu.start();

	// Start CPU.
	(new Thread({
		//Thread.sleep(2000_0000);
		//Sleep(2000);
		dissasembler.registersType = AllegrexDisassembler.RegistersType.Symbolic;
		try {
			cpu.execute();
		} catch (Object o) {
			writefln("CPU Error: %s", o.toString());
			cpu.registers.dump();
			dissasembler.dump(cpu.registers.PC, -6, 6);
			writefln("CPU Error: %s", o.toString());
		} finally {
			.writefln("End CPU executing.");
			cpu.stop();
			gpu.stop();
			Application.exit();
		}
	})).start();

	int retval = 0;
	try {
		Application.run(new DisplayForm(display));
	} catch (Object o) {
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		retval = -1;
	}
	
	cpu.stop();
	gpu.stop();

	Application.exit();
	return retval;
}
