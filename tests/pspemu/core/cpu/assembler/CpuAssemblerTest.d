module pspemu.core.cpu.assembler.CpuAssemblerTest;

import tests.Test;

import pspemu.core.cpu.assembler.CpuAssembler;

import pspemu.core.cpu.tables.Table;

class CpuAssemblerTest : Test {
	CpuAssembler cpuAssembler;
	
	this() {
		this.cpuAssembler = new CpuAssembler(PspInstructions_ALU); 
	}
	
	void testUnknownOpcode() {
		expectException!Exception({
			this.cpuAssembler.assembleInstruction(0x00000000, "unknown_opcode", "");
		});
	}
	
	void testAssemble_R() {
		Instruction instruction;
		instruction.OP1 = 0b000000;
		instruction.OP2 = 0b100000;
		instruction.RD = 1;
		instruction.RS = 2;
		instruction.RT = 3;

		assertEquals(Instruction(0b_000000_00010_00011_00001_00000_100000), instruction);
		
		assertEquals(
			[instruction],
			this.cpuAssembler.assembleInstruction(0x00000000, "add", "r1, r2, r3")
		);
	}
	
	void testAssemble_I() {
		Instruction instruction;
		instruction.OP1 = 0b001000;
		instruction.RT = 1;
		instruction.RS = 2;
		instruction.IMM = 1000;
		assertEquals(
			[instruction],
			this.cpuAssembler.assembleInstruction(0x00000000, "addi", "r1, r2, 1000")
		);
	}
}