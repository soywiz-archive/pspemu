module pspemu.tests.TestsEx;

import std.stream, std.stdio, core.thread, std.file;

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

class PspDisplay : Display {
	Memory memory;

	this(Memory memory) {
		this.memory = memory;
	}

	void* frameBufferPointer() {
		return memory.getPointer(info.topaddr);
	}
}

void main() {
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

	cpu.errorHandler = (Cpu cpu, Object error) {
	};

	int totalFailed = 0, totalExecuted = 0;
	foreach (DirEntry e; dirEntries("tests_ex", SpanMode.breadth)) {
		if (e.name.indexOf(".svn") != -1) continue;
		if (e.name.length >= 9 && e.name[$ - 9..$] == ".expected") {
			string fileNameExpected = e.name;
			string fileNameElf      = std.path.getName(e.name) ~ ".elf";
			auto expectedLines = std.string.split(cast(string)std.file.read(fileNameExpected), "\n");
			writefln("Testing... %s", fileNameElf);
			syscall.reset();
			loader.loadAndExecute(fileNameElf);
			cpu.waitEnd();
			int maxLen = max(syscall.emits.length, expectedLines.length);
			int passCount = 0, failCount = 0;
			for (int n = 0; n < maxLen; n++) {
				string emitedLine   = (n < syscall.emits.length) ? syscall.emits[n] : "<not emited>";
				string expectedLine = (n < expectedLines.length) ? expectedLines[n] : "<not expected>";
				bool pass = (emitedLine == expectedLine);
				writefln("  %s : '%s' <-> '%s'", pass ? "PASS" : "FAIL", emitedLine, expectedLine);
				if (!pass) failCount++;
				totalExecuted++;
			}
			totalFailed += failCount;
		}
	}

	writefln("");
	writefln("Results:");
	writefln("  Total : %d", totalExecuted);
	writefln("  Failed: %d", totalFailed);
}