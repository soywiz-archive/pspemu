module pspemu.hle.HleThreadTest;

import pspemu.core.cpu.assembler.CpuAssembler;
import pspemu.core.cpu.interpreter.CpuInterpreter;
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Registers;
import pspemu.core.Interrupts;
import pspemu.core.Memory;
import pspemu.core.cpu.Registers;
import pspemu.interfaces.ISyscall;
import pspemu.interfaces.ICpu;
import pspemu.hle.HleThreadManager;
import pspemu.hle.HleThread;

import tests.Test;

class Syscall : ISyscall {
	void syscall(Registers registers, int syscallNum) {
		switch (syscallNum) {
			default: throw(new Exception(std.string.format("Called syscall 0x%08X", syscallNum)));
			case 0x1000:
				HleThread.threadYield();
			break;
		}
	}
}

class HleThreadTest : Test {
	Memory memory;
	Stream memoryStream;
	CpuAssembler cpuAssembler;
	HleThreadManager hleThreadManager;
	ISyscall syscall;
	Interrupts interrupts;
	
	void setUp() {
		this.memory = new Memory();
		this.memoryStream = new PspMemoryStream(this.memory); 
		this.syscall = new Syscall();
		this.interrupts = new Interrupts();
		this.cpuAssembler = new CpuAssembler();
		this.hleThreadManager = new HleThreadManager(); 
	}
	
	void testResumeAndYield() {
		this.cpuAssembler.assemble(new SliceStream(memoryStream, 0x08900000), r"
			li r1, 1111
			syscall 0x1000
			li r1, 2000
			addi r1, r1, 222
			syscall 0x1000
			li r1, 3000
		");
		HleThread hleThread1 = new HleThread(new CpuInterpreter(memory, syscall, interrupts));
		hleThread1.registers.pcSet = 0x08900000;
		
		hleThread1.threadResume();
		assertEquals(1111, hleThread1.registers.R[1]);

		hleThread1.threadResume();
		assertEquals(2222, hleThread1.registers.R[1]);
	}
}
