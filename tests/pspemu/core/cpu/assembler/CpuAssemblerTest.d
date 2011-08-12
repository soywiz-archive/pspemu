module pspemu.core.cpu.assembler.CpuAssemblerTest;

import tests.Test;

import pspemu.core.cpu.assembler.CpuAssembler;

import pspemu.core.cpu.tables.Table;
import pspemu.core.Memory;

class CpuAssemblerTest : Test {
	Memory memory;
	CpuAssembler cpuAssembler;
	
	this() {
		this.memory = new Memory(); 
		this.cpuAssembler = new CpuAssembler(PspInstructions);
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
	
	void testAssembleMacro() {
		assertEquals(
			"[OP(200103E8)]",
			std.string.format("%s", this.cpuAssembler.assembleInstruction(0x00000000, "li r1, 1000"))
		);
		assertEquals(
			"[OP(3C010001),OP(34012110)]",
			std.string.format("%s", this.cpuAssembler.assembleInstruction(0x00000000, "li r1, 74000"))
		);
	}
	
	void testAssembleString() {
		PspMemoryStream stream = new PspMemoryStream(memory);
		stream.position = 0x_08900000;
		this.cpuAssembler.assemble(stream, r"
			loop:
				add  r1, r2, r3
				addi r2, r2, 1000
				beq  r0, r2, loop
				beq  r0, r0, skip
				addi r3, r0, 2000
			skip:
				syscall 0x1002
		");
		stream.position = 0x_08900000;
		
		Instruction[6] instructions;
		foreach (ref instruction; instructions) stream.read(instruction.v);

		assertEquals(
			"[OP(00430820),OP(204203E8),OP(1002FFFD),OP(10000001),OP(200307D0),OP(0004008C)]",
			std.string.format("%s", instructions)
		);
	}
}