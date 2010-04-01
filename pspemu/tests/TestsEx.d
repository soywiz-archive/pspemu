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

import pspemu.core.cpu.interpreted.Cpu;
import pspemu.core.cpu.dynarec.Cpu;
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

void test_dynarec() {
	uint[32] registers;
	auto emiter = new EmiterMipsToX86();
	
	alias EmiterMipsToX86.MipsRegisters MipsRegisters;
	
	//emiter.INT3();
	emiter.MIPS_LOAD_REGISTER_TABLE(cast(uint)registers.ptr);

	//emiter.MIPS_LOAD_REGISTER(EmiterX86.Register32.EAX, 17);
	//emiter.MIPS_ADDU(1, 2, 3);
	emiter.MIPS_LI(MipsRegisters.T0, 128);

	auto loop_color = emiter.createLabelAndSetHere();

	emiter.MIPS_LI(MipsRegisters.A0, 0x04000000);
	emiter.MIPS_LI(MipsRegisters.A1, 0x88000);
	
	auto loop_write = emiter.createLabelAndSetHere();

	emiter.MIPS_ADDIU(MipsRegisters.A0, MipsRegisters.A0, 1);
	emiter.MIPS_ADDIU(MipsRegisters.A1, MipsRegisters.A1, -1);
	emiter.MIPS_SB(MipsRegisters.T0, MipsRegisters.A0, 0);
	
	emiter.MIPS_PREPARE_CMP(MipsRegisters.A1, MipsRegisters.ZR);
	emiter.MIPS_NOP();
	emiter.MIPS_BNE(loop_write);

	emiter.MIPS_ADDIU(MipsRegisters.T0, MipsRegisters.T0, -1);

	emiter.MIPS_PREPARE_CMP(MipsRegisters.T0, MipsRegisters.ZR);
	emiter.MIPS_NOP();
	emiter.MIPS_BNE(loop_color);
	
	/*
	auto loop_write = emiter.createLabelAndSetHere();
	emiter.JMP(loop_write);
	*/
	
	emiter.RET();

	std.file.write("test.bin", emiter.writedCode);

	emiter.execute();
	for (int n = 0; n < 32; n++) {
		writefln("r%d = %08X | %d", n, registers[n], registers[n]);
	}

/*
li t0, 128

loop_color:
	li a0, 0x04000000
	li a1, 0x88000
	loop_write:
		addiu a0, a0, 1
		addiu a1, a1, -1
		sb t0, 0(a0)
	bne a1, zr, loop_write
	nop
addi t0, t0, 1
syscall 0x2147 ; sceDisplay.sceDisplayWaitVblankStart
j loop_color
nop

*/
}

void main() {
	//test_dynarec(); return;

	// Components.
	auto memory        = new Memory;
	auto controller    = new Controller();
	auto display       = new PspDisplay(memory);
	auto gpu           = new Gpu(new GpuOpengl, memory);
	auto cpu           = new CpuInterpreted(memory, gpu, display, controller);
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

	writefln("Results:");
	writefln("  Total : %d", totalExecuted);
	writefln("  Failed: %d", totalFailed);
}