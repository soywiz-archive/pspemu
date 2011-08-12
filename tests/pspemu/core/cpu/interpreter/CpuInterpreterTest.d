module pspemu.core.cpu.interpreter.CpuInterpreterTest;

import pspemu.core.cpu.interpreter.CpuInterpreter;
import pspemu.core.cpu.assembler.CpuAssembler;
import pspemu.core.cpu.tables.Table;
import pspemu.core.Interrupts;
import pspemu.core.Memory;
import pspemu.interfaces.ISyscall;

import pspemu.Exceptions;

import tests.Test;

class SyscallMock : ISyscall {
	Interrupts interrupts;
	
	this(Interrupts interrupts) {
		this.interrupts = interrupts;
	}
	
	void syscall(Registers registers, int syscallNum) {
		switch (syscallNum) {
			case 0x1002: throw(new HaltException("halt"));
			case 0x1003:
				interrupts.interrupt(Interrupts.Type.Systimer0);
			break;
			default: throw(new NotImplementedException("Not expected syscall"));
		}
	}
}

class CpuInterpreterTest : Test {
	Memory          memory;
	SyscallMock     syscall;
	CpuInterpreter  cpu;
	Interrupts      interrupts;
	Registers       registers;
	CpuAssembler    cpuAssembler;
	int             systimerCalledCount;
	
	this() {
		registers  = new Registers();
		interrupts = new Interrupts();
		memory     = new Memory();
		syscall    = new SyscallMock(interrupts);
		cpu        = new CpuInterpreter(memory, syscall, interrupts);
		
		cpuAssembler = new CpuAssembler(PspInstructions);
		
		interrupts.addInterruptHandler(Interrupts.Type.Systimer0, delegate(Interrupts.Task interruptTask) {
			interruptTask.registers[1] = interruptTask.registers[1] + 1;
			systimerCalledCount++;
		});
	}
	
	void setUp() {
		systimerCalledCount = 0;
	}
	
	void execudeCode(string codeString, int maxInstructions = 100) {
		PspMemoryStream stream = new PspMemoryStream(memory);
		
		uint CODE_START = 0x_08900000;
		
		stream.position = CODE_START;
		registers.reset();
		cpuAssembler.reset();
		cpuAssembler.assemble(stream, codeString);
		cpuAssembler.assemble(stream, "syscall 0x1002");
		
		registers.pcSet = CODE_START;
		//cpu.trace = true;
		expectException!HaltException({
			cpu.execute_loop_limit(registers, maxInstructions);
		});
	}
	
	void testSimple() {
		execudeCode(r"
			loop:
				add  r1, r2, r3        ; 0x00
				addi r2, r2, 1000      ; 0x04
				beq  r0, r2, loop      ; 0x08
				nop                    ; 0x0C
				beq  r0, r0, skip      ; 0x10
				nop                    ; 0x14
				addi r3, r0, 2000      ; 0x18
			skip:
		");
		assertEquals(registers[0], 0);
		assertEquals(registers[2], 1000);
		assertEquals(registers[3], 0);
		//registers.dump();
	}
	
	void testLoop() {
		execudeCode(r"
				addi r1, r0, 10        ; 0x00
				addi r2, r0, 0         ; 0x04
			loop:
				addi r2, r2, 1         ; 0x08
				bne  r2, r1, loop      ; 0x0C
				nop                    ; 0x10
		");
		assertEquals(registers[0], 0);
		assertEquals(registers[1], 10);
		assertEquals(registers[2], 10);
	}
	
	void testInterruptRestoreRegistersAndIsCalledImmediately() {
		execudeCode(r"
			addi r1, r0, 1             ; 0x00
			syscall 0x1003             ; 0x04
			addi r1, r1, 1             ; 0x08
		");
		assertEquals(systimerCalledCount, 1);
		assertEquals(registers[1], 2);
	}
}