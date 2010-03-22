module pspemu.exe.Test;

import std.stream, std.stdio, core.thread, std.variant;

import std.c.windows.windows;

import pspemu.models.IDisplay;

import pspemu.formats.Pbp;

import pspemu.utils.Utils;
import pspemu.utils.Assertion;

import pspemu.core.Memory;
import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Disassembler;
import pspemu.core.gpu.Gpu;

import pspemu.hle.Loader;
import pspemu.hle.Syscall;

import std.file;

static do_unittest = false;

unittest { do_unittest = true; }

class PspDisplay : BasePspDisplay {
	Memory memory;
	bool _vblank = true;

	this(Memory memory) {
		this.memory = memory;
	}

	void* frameBufferPointer() {
		//return memory.getPointer(Memory.frameBufferAddress);
		return memory.getPointer(memory.displayMemory);
	}

	bool vblank(bool status) { return _vblank = status; }
	bool vblank() { return _vblank; }
}

void testExtended(string name) {
	auto memory  = new Memory;
	auto display = new PspDisplay(memory);
	auto gpu     = new Gpu(memory);
	auto cpu     = new Cpu(memory, gpu, display);
	auto dissasembler = new AllegrexDisassembler(memory);

	auto loader  = new Loader(name ~ ".elf", cpu);
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
			Sleep(2);
			display.vblank = true;
			Sleep(2);
			display.vblank = false;
		}
	})).start();

	// Start CPU.
	try {
		Syscall.emits = [];
		cpu.execute();
	} catch (Object o) {
		writefln("%s", o);
	}
	gpu.stop();
	cpu.stop();

	int emitPosition = 0;

	auto lines = std.string.splitlines(cast(char[])std.file.read(name ~ ".expected"));

	foreach (line; lines) {
		/*
		void check(T)() {
			auto expected = Variant(std.conv.to!(T)(line));
			auto emited   = Syscall.emits[emitPosition]; // Variant
			assertTrue(emited == expected, std.string.format("emit!(%s)(emited(%s) == expected(%s))", typeid(T), emited, expected));
		}
		//auto line = cast(string)line_c;
		// Float
		if (std.string.indexOf(line, '.') >= 0) {
			check!(float)();
		}
		else {
			check!(int)();
		}
		*/
		auto emited   = (emitPosition < Syscall.emits.length) ? Syscall.emits[emitPosition] : "<not emited>";
		auto expected = line;
		assertTrue(emited == expected, std.string.format("emit(emited(%s) == expected(%s))", emited, expected));
		emitPosition++;
	}

	assertTrue(Syscall.emits.length == lines.length, std.string.format("emits.length(emited(%d) == expected(%d))", Syscall.emits.length, lines.length));
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
