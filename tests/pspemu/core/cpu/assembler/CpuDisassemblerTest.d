module pspemu.core.cpu.assembler.CpuDisassemblerTest;

import pspemu.core.cpu.assembler.CpuDisassembler;
import pspemu.core.cpu.assembler.CpuAssembler;
import pspemu.core.cpu.tables.Table;
import pspemu.core.Memory;

import tests.Test;

class CpuDisassemblerTest : Test {
	Memory memory;
	CpuAssembler cpuAssembler;
	CpuDisassembler cpuDisassembler;
	
	this() {
		this.memory = new Memory(); 
		this.cpuAssembler = new CpuAssembler(PspInstructions);
		this.cpuDisassembler = new CpuDisassembler();
	}
	
	string[] disaassembleInstruction(string assemblerLine, uint PC = 0x08900000) {
		return this.cpuDisassembler.disassembleInstruction(0x08900000, this.cpuAssembler.assembleInstruction(PC, assemblerLine)[0]);
	}

	void testDisassemble() {
		assertEquals(["addi", "r1", ",", "r2", ",", "1000"], disaassembleInstruction("addi r1, r2, 1000"));
	}
}