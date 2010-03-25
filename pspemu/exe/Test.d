module pspemu.exe.Test;

import std.stream, std.stdio, core.thread, std.variant;

import std.c.windows.windows;

import pspemu.models.IDisplay;

import pspemu.formats.Pbp;

import pspemu.utils.Utils;
import pspemu.utils.Assertion;

import pspemu.models.IDisplay;
import pspemu.models.IController;
import pspemu.models.ISyscall;

import pspemu.core.Memory;
import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Interrupts;
import pspemu.core.cpu.Disassembler;
import pspemu.core.gpu.Gpu;
import pspemu.core.gpu.impl.GpuOpengl;

import pspemu.hle.Module;
import pspemu.hle.Loader;
import pspemu.hle.Syscall;

import std.file;

static do_unittest = false;

unittest { do_unittest = true; }

class PspDisplay : Display {
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

void testExtended(string executableFile) {
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

	loader.load(std.string.format("%s.elf", executableFile));
	loader.setRegisters();

	version (TRACE_FROM_BEGINING) {
		cpu.checkBreakpoints = true;
		cpu.addBreakpoint(cpu.BreakPoint(loader.PC, [], true));
	}
	
	// Start GPU.
	gpu.start();

	// Vblank.
	(new Thread({
		while (cpu.running) {
			cpu.interrupts.queue(Interrupts.Type.VBLANK);
			Sleep(1000 / 60);
		}
	})).start();

	// Start CPU.
	try {
		syscall.emits = [];
		cpu.execute();
	} catch (Object o) {
		writefln("%s", o);
	}
	gpu.stop();
	cpu.stop();

	int emitPosition = 0;

	auto lines = std.string.splitlines(
		cast(char[])std.file.read(
			std.string.format("%s.expected", executableFile)
		)
	);

	foreach (line; lines) {
		auto emited   = (emitPosition < syscall.emits.length) ? syscall.emits[emitPosition] : "<not emited>";
		auto expected = line;
		assertTrue(emited == expected, std.string.format("emit(emited(%s) == expected(%s))", emited, expected));
		emitPosition++;
	}

	assertTrue(syscall.emits.length == lines.length, std.string.format("emits.length(emited(%d) == expected(%d))", syscall.emits.length, lines.length));
}

unittest {
	void reset() {
	}

	void testGroup(string groupName, void delegate() callback) {
		assertGroup(groupName);
		reset();
		callback();
	}

	foreach (DirEntry entry; dirEntries("tests", SpanMode.shallow)) {
		string name = entry.name;
		if (name.length >= 4 && name[$ - 4..$] != ".elf") continue;
		string full = name[0..$ - 4];
		if (std.file.exists(full ~ ".expected")) {
			testGroup(full, {
				testExtended(full);
			});
		} else {
			testGroup(full, {
				writefln("  Omited because .expected file doesn't exist.");
			});
		}
	}
}

void main() {
	if (do_unittest) {
		writefln("Unittesting: END");
		return;
	}
	writefln("main");
}
