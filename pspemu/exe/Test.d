module pspemu.exe.Test;

import std.stream, std.stdio, core.thread;

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

	auto loader  = new Loader(name ~ ".elf", memory);
	
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
	try { cpu.execute(); } catch (Object o) { }
	gpu.stop();
	cpu.stop();

	int emitPosition = 0;

	auto lines = std.string.splitlines(cast(char[])std.file.read(name ~ ".expected"));

	assertTrue(Syscall.emits.length == lines.length, std.string.format("emits.length(emited(%d) == expected(%d))", Syscall.emits.length, lines.length));

	foreach (line; lines) {
		void check(T)() {
			auto expected = std.conv.to!(T)(line);
			auto emited   = reinterpret!(T)(Syscall.emits[emitPosition]);
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
		emitPosition++;
	}
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");

	void reset() {
	}

	void testGroup(string groupName, void delegate() callback) {
		assertGroup(groupName);
		reset();
		callback();
	}

	testGroup("tests/test1", {
		testExtended("tests/test1");
	});
}

void main() {
	if (do_unittest) {
		writefln("Unittesting: END");
		return;
	}
	writefln("main");
}
