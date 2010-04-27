module pspemu.tests.TestsEx;

//version = USE_CPU_DYNAREC;

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

version (USE_CPU_DYNAREC) {
	import pspemu.core.cpu.dynarec.Cpu;
} else {
	import pspemu.core.cpu.interpreted.Cpu;
}

import pspemu.core.gpu.impl.GpuOpengl;

import pspemu.hle.Module;
import pspemu.hle.Loader;
import pspemu.hle.Syscall;

import std.file, std.regex;

class PspDisplay : Display {
	Memory memory;

	this(Memory memory) {
		this.memory = memory;
	}

	void* frameBufferPointer() {
		return memory.getPointer(info.topaddr);
	}
}

void main(string[] args) {
	//test_dynarec(); return;

	// Components.
	auto memory        = new Memory;
	auto controller    = new Controller();
	auto display       = new PspDisplay(memory);
	auto gpu           = new Gpu(new GpuOpengl, memory);
	version (USE_CPU_DYNAREC) {
		auto cpu       = new CpuDynaRec(memory, gpu, display, controller);
	} else {
		auto cpu       = new CpuInterpreted(memory, gpu, display, controller);
	}
	auto dissasembler  = new AllegrexDisassembler(memory);

	// HLE.
	auto moduleManager = new ModuleManager(cpu);
	auto loader        = new Loader(cpu, moduleManager);
	auto syscall       = new Syscall(cpu, moduleManager);
	
	cpu.init();
	gpu.init();
	
	bool vblank_run = true;

	// Vblank.
	(new Thread({
		while (vblank_run) {
			cpu.interrupts.queue(Interrupts.Type.VBLANK);
			microsleep(1_000_000 / 60);
		}
	})).start();

	cpu.errorHandler = (Cpu cpu, Object error) {
		if ((cast(HaltException)error) is null) {
			writefln("ERROR: %s", error);
		}
	};
	
	// Test
	version (USE_CPU_DYNAREC) {
		loader.loadAndExecute("tests_ex/simple/loop2.asm"); return;
		//loader.loadAndExecute("demos/minifire.elf"); return;
	}

	string explorePath = "tests_ex";

	// Select the path to explore.
	if (args.length >= 2) {
		explorePath = args[1];
	}

	int totalFailed = 0, totalExecuted = 0;
	foreach (DirEntry e; dirEntries(explorePath, SpanMode.breadth)) {
		if (e.name.indexOf(".svn") != -1) continue;
		if (e.name.length >= 9 && e.name[$ - 9..$] == ".expected") {
			string fileNameExpected = e.name;
			string fileNameElf      = std.path.getName(e.name) ~ ".elf";
			string fileNameAsm      = std.path.getName(e.name) ~ ".asm";
			string fileNameC        = std.path.getName(e.name) ~ ".c";
			string fileNameExe;
			
			if (std.file.exists(fileNameElf) && std.file.exists(fileNameC)) {
				if (lastModified(fileNameC) > lastModified(fileNameElf)) {
					std.file.remove(fileNameElf);
				}
			}
			
			if (std.file.exists(fileNameAsm)) {
				fileNameExe = fileNameAsm;
			} else if (std.file.exists(fileNameElf)) {
				fileNameExe = fileNameElf;
			} else if (std.file.exists(fileNameC)) {
				string testPath = std.path.dirname(fileNameC);
				string fileData = cast(string)std.file.read(fileNameC);

				auto re = std.regex.regex(r"#pragma compile,\s+(.*)$", "gm");
				
				auto bat = "";

				bat ~= "@ECHO OFF\r\n";
				bat ~= "CD " ~ testPath ~ "\r\n";

				foreach (m; std.regex.match(fileData, re)) {
					string cmd = m.captures[1];
					cmd = std.string.replace(cmd, "%PSPSDK%", ApplicationPaths.exe ~ "\\dev\\pspsdk");
					bat ~= cmd ~ "\r\n";
					//writefln("%s", cmd);
					//std.process.system(cmd);
				}
				
				std.file.write("build_test.bat", cast(ubyte[])bat);

				std.process.system("build_test.bat");

				std.file.remove("build_test.bat");
				
				fileNameExe = fileNameElf;
				if (std.file.exists(fileNameElf) && std.file.exists(fileNameC)) {
					std.file.setTimes(fileNameElf, lastModified(fileNameC), lastModified(fileNameC));
				}
			} else {
				writefln("Can't find neither .asm, .elf or .c");
			}

			auto expectedLines = std.string.split(cast(string)std.file.read(fileNameExpected), "\n");
			writefln("Testing... %s", fileNameExe);
			syscall.reset();
			loader.loadAndExecute(fileNameExe);
			cpu.waitEnd();

			int passCount = 0, failCount = 0;

			for (int n = 0, maxLen = max(syscall.emits.length, expectedLines.length); n < maxLen; n++) {
				string emitedLine   = (n < syscall.emits.length) ? syscall.emits[n] : "<not emited>";
				string expectedLine = (n < expectedLines.length) ? expectedLines[n] : "<not expected>";
				bool pass = (emitedLine == expectedLine);
				writefln("  %s : '%s' <-> '%s'", pass ? "PASS" : "FAIL", emitedLine, expectedLine);
				if (!pass) failCount++;
				totalExecuted++;
			}

			writefln("");

			totalFailed += failCount;
		}
	}
	
	vblank_run = false;

	writefln("Results:");
	writefln("  Total : %d", totalExecuted);
	writefln("  Failed: %d", totalFailed);
}