module pspemu.exe.Pspemu;

//version = TRACE_FROM_BEGINING;

import std.stream, std.stdio, core.thread;

import dfl.all;

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

	this(Memory memory) {
		this.memory = memory;
	}

	void* frameBufferPointer() {
		//return memory.getPointer(Memory.frameBufferAddress);
		return memory.getPointer(memory.displayMemory);
	}

	void vblank(bool status) {
		// Dummy.
	}
}

int main() {
	auto memory  = new Memory;
	auto cpu     = new Cpu(memory);
	auto gpu     = new Gpu(memory);
	auto display = new PspDisplay(memory);
	
	//cpu.addBreakpoint(cpu.BreakPoint(0x08900130 + 4, ["t1", "t2", "v0"]));

	string executableFile;

	/*
	executableFile = "demos/controller.elf";
	executableFile = new BufferedFile(elfFile, FileMode.In);
	*/
	//executableFile = "demos/minifire.elf";
	//executableFile = "demos/controller.pbp";
	executableFile = "demos/counter.pbp";
	//executableFile = "demos/mytest.pbp";
	//executableFile = "demos/text.pbp";
	
	auto loader  = new Loader(executableFile, memory);
	writefln("PC: %08X", loader.PC);
	writefln("GP: %08X", loader.GP);
	
	cpu.registers.pcSet = loader.PC;
	cpu.registers["gp"] = loader.GP;
	//cpu.registers["sp"] = 0x08800000;
	cpu.registers["sp"] = 0x09F00000;
	cpu.registers["k0"] = 0x09F00000;
	//cpu.registers["ra"] = 0x08900004;
	cpu.registers["ra"] = 0;
	//cpu.registers["ra"] = 0x089065A8;
	cpu.registers["a0"] = 0; // argumentsLength.
	cpu.registers["a1"] = loader.PC; // argumentsPointer
	cpu.registers["a2"] = 0; // argumentsPointer

	version (TRACE_FROM_BEGINING) {
		cpu.checkBreakpoints = true;
		cpu.addBreakpoint(cpu.BreakPoint(loader.PC, [], true));
	}

	/*
	cpu.checkBreakpoints = true;
	cpu.addBreakpoint(cpu.BreakPoint(0x089006D8, ["a0", "a1", "a2", "a3", "t0"]));
	*/

	/*if (0) {
		cpu.checkBreakpoints = true;
		cpu.addBreakpoint(cpu.BreakPoint(0x0890013C, ["t0", "t1", "t2", "v0"]));
		cpu.addBreakpoint(cpu.BreakPoint(0x08900140, ["t0", "t1", "t2", "v0"]));
		cpu.addBreakpoint(cpu.BreakPoint(0x08900144, ["t0"], true));
	} else {
		//cpu.addBreakpoint(cpu.BreakPoint(0x08900284, ["v1"]));
	}*/

	(new Thread({
		auto dissasembler = new AllegrexDisassembler(memory);
		Thread.sleep(2000_0000);
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
		}
	})).start();
	
	int retval = 0;
	try {
		Application.run(new DisplayForm(display));
	} catch (Object o) {
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		retval = -1;
	}
	
	cpu.stop = true;

	Application.exit();
	return retval;
}
