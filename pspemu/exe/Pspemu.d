module pspemu.exe.Pspemu;

version = TRACE_EXEUCTION;

import std.stream, std.stdio, core.thread;

import dfl.all;

import pspemu.gui.MainForm;
import pspemu.gui.DisplayForm;

import pspemu.models.IDisplay;

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
		return memory.getPointer(0x04000000);
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
	
	auto loader  = new Loader(new BufferedFile("demos/controller.elf", FileMode.In), memory);
	writefln("PC: %08X", loader.PC);
	writefln("GP: %08X", loader.GP);
	
	cpu.registers.pcSet = loader.PC;
	cpu.registers["gp"] = loader.GP;
	cpu.registers["sp"] = 0x08800000;

	void runCPU() {
		(new Thread({
			auto dissasembler = new AllegrexDisassembler(memory);
			try {
				version (TRACE_EXEUCTION) {
					while (true) {
						try {
							dissasembler.dumpSimple(cpu.registers.PC);
						} catch {
						}
						cpu.executeSingle();
					}
				} else {
					cpu.execute();
				}
			} catch (Object o) {
				writefln("CPU Error: %s", o.toString());
				cpu.registers.dump();
				dissasembler.dump(cpu.registers.PC, -1, 10);
				//msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
			} finally {
				.writefln("End CPU executing.");
			}
		})).start();
	}

	runCPU();
	
	try {
		Application.run(new DisplayForm(display));
		return 0;
	} catch (Object o) {
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		return -1;
	}
}
