module pspemu.core.cpu.Test;

version (Unittest):

import pspemu.core.Memory;
import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Assembler;
import pspemu.core.cpu.Disassembler;
import pspemu.utils.Assertion;

import std.c.stdlib, std.stdio, std.string, std.math;

unittest {
	auto cpu          = new Cpu();
	auto assembler    = new AllegrexAssembler(cpu.memory);
	auto dissasembler = new AllegrexDisassembler(cpu.memory);

	void reset() { cpu.resetFast(); assembler.reset(); }
	void dump() { cpu.registers.dump(); assembler.symbolDump(); }
	void gotoText() { cpu.registers.pcSet(assembler.segments["text"]); }
	void gotoTextAndExecuteUntilHalt() {
		gotoText();
		cpu.executeUntilHalt();
	}
	assertOnFail({
		// If an assert failed, we will dump registers.
		dump();
		dissasembler.dump(cpu.registers.PC, -6, +6);
		//assert(0);
		exit(-1);
	});
	void testGroup(string groupName, void delegate() callback) { assertGroup(groupName); reset(); callback(); }

	testGroup("ADD/ADDI", {
		assembler.assembleBlock(r"
		.text
			addi a0, zero, 7   ; a0 = 7
			addi a1, zero, 11  ; a1 = 11
			add  v0, a0, a1    ; v0 = a0 + a1
			addi v0, v0, -5    ; v0 = v0 - 5
			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers["v0"] == 13, "(v0 = (7 + 11 - 5)) == 13");
	});

	testGroup("ADDIU", {
		assembler.assembleBlock(r"
		.text
			li a0, 1000
			addiu a0, a0, -1
			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers["a0"] == 999, "a0 = 1000; a0--; (a0 == 999);");
	});

	testGroup("BGEZ", {
		assembler.assembleBlock(r"
		.text
			addi v0, zero, 2   ; v0 = 2
		loop:                  ;
			bgez v0, loop      ;
			addi v0, v0, -1    ; v0-- . Because of the delayed branch it should be executed anyways.
		");

		gotoText();

		// FALSE for testing.
		//assertTrue(false, "");

		foreach (step, expectedValue; [2, 2, 1, 1, 0, 0]) {
			//writefln("PC: %08X, nPC: %08X, STEP: %d", cpu.registers.PC, cpu.registers.nPC, step);
			cpu.executeSingle();
			assertTrue(cpu.registers["v0"] == expectedValue, format("v0 = 2; while (v--); step: %d; v0 = %d; v0 != %d", step, cpu.registers["v0"], expectedValue));
		}
	});

	testGroup("JAL/JR", {
		assembler.assembleBlock(r"
		.text

			jal  my_function        ;             ; 0x08000000
			addi r1, zero, 1        ; r1 = 1      ; 0x08000004
			addi r4, zero, 1        ; r4 = 1      ; 0x08000008

		my_function:                ;
			addi r2, zero, 1        ; r2 = 1      ; 0x0800000C
			jr ra                   ; Returns     ; 0x08000010
			addi r3, zero, 1        ; r3 = 1      ; 0x08000014
		");

		gotoText();
		cpu.execute(3);
		assertTrue(cpu.registers["r1"] == 1, "Simple function call");
		assertTrue(cpu.registers["r2"] == 1, "Simple function call");
		assertTrue(cpu.registers["r4"] == 0, "Simple function call");
		assertTrue(cpu.registers["ra"] == assembler.getSymbolAddress("my_function") - 4, "Simple function call");
		cpu.execute(3);
		assertTrue(cpu.registers["r3"] == 1, "Simple function call");
		assertTrue(cpu.registers["r4"] == 1, "Simple function call");
	});

	testGroup("BRANCH LIKELY", {
		assembler.assembleBlock(r"
		.text

			; Ensures that the registers are setted to zero. (Though them should be already).
			add   r1, zero, zero   ; r1 = 0
			add   r2, zero, zero   ; r2 = 0

		label0:
			addi  r9, zero, -1     ;
			bgezl r9, label1       ; no jumps
			addi  r1, zero, 1      ; r1 = 1 ; shouldn't be executed!

		label1:
			addi  r9, zero, 0      ;
			bgezl r9, label2       ; jumps
			addi  r2, zero, 1      ; r2 = 1 ; should be executed plus the jump!

		label2:
			add   zr, zr, zr       ; nop

			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers["r1"] == 0, "Simple branch likely: No branch");
		assertTrue(cpu.registers["r2"] == 1, "Simple branch likely: Branch");
		//dump();
		assertTrue(cpu.registers.PC    == assembler.getSymbolAddress("label2") + 8, "Simple branch likely: PC");
	});
	
	testGroup("BRANCH LIKELY BEQL", {
		assembler.assembleBlock(r"
		.text

			li a0, 1
			beql a0, zr, label1
			li a0, 2
		label1:

		");

		gotoTextAndExecuteUntilHalt();

		assertTrue(cpu.registers["a0"] == 1, "BEQL");
	});
	
	testGroup("LI + LUI + ORI + BITREV", {
		assembler.assembleBlock(r"
		.text

			lui a0, 0x8000
			ori a0, a0, 0x1111
			bitrev a1, a0
			li a2, 0x80001111
			
			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers["a0"] == 0x_8000_1111, "LUI + ORI");
		assertTrue(cpu.registers["a1"] == 0x_8888_0001, "BITREV");
		assertTrue(cpu.registers["a2"] == cpu.registers["a0"], "LI MACRO");
	});

	testGroup("MIN/MAX", {
		assembler.assembleBlock(r"
		.text

			addi r1, zero, -5
			addi r2, zero,  5
			max r11, r1, r2
			min r12, r1, r2
			min r13, zero, zero

			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers[11] == +5, "MAX");
		assertTrue(cpu.registers[12] == -5, "MIN");
		assertTrue(cpu.registers[13] ==  0, "MIN 0");
	});

	testGroup("MULT/MFHI/MFLO", {
		assembler.assembleBlock(r"
		.text

			addi r1, zero, 2
			addi r2, zero, -3
			mult r1, r2
			mflo r3
			mfhi r4

			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers[1] == 2, "ADDI Check 1");
		assertTrue(cpu.registers[2] == -3, "ADDI Check 2");
		assertTrue(cpu.registers[3] == 2 * -3, "MULT R->LO");
		assertTrue(cpu.registers[4] == 0xFFFFFFFF, "MULT R->HI");
		assertTrue(cpu.registers.LO == cpu.registers[3], "MULT LO");
		assertTrue(cpu.registers.HI == cpu.registers[4], "MULT HI");
	});

	testGroup("MULTU", {
		assembler.assembleBlock(r"
		.text

			addi r1, zero, 2
			addi r2, zero, -3
			multu r1, r2
			mflo r3
			mfhi r4

			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers[3] == (2 * -3), "MULTU R->LO");
		assertTrue(cpu.registers[4] == 0x00000001, "MULT R->HI");
	});

	testGroup("MADD/MTHI/MTLO", {
		assembler.assembleBlock(r"
		.text

			addi r1, zero, 2
			addi r2, zero, 3
			addi r3, zero, 7
			mtlo r3
			mthi r3

			halt

			madd r1, r2
			
			halt
		");

		gotoText();

		cpu.executeUntilHalt();
		assertTrue(cpu.registers[1] == 2, "ADDI Check 1");
		assertTrue(cpu.registers[2] == 3, "ADDI Check 2");
		assertTrue(cpu.registers[3] == 7, "ADDI Check 3");
		assertTrue(cpu.registers.LO == 7, "MTLO Check");
		assertTrue(cpu.registers.HI == 7, "MTHI Check");

		cpu.executeUntilHalt();
		assertTrue(cpu.registers.LO == cpu.registers[3] + (cpu.registers[1] * cpu.registers[2]), "MADD LO");
		assertTrue(cpu.registers.HI == cpu.registers[3] + (0), "MADD HI");
	});

	testGroup("MOVZ/MOVN", {
		assembler.assembleBlock(r"
		.text

			addi r0, zero, 0
			addi r1, zero, 1
			addi r2, zero, 2

			movz r11, r2, r0
			movz r12, r2, r1

			movn r21, r2, r0
			movn r22, r2, r1

			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers[11] == 2, "MOVZ 0");
		assertTrue(cpu.registers[12] == 0, "MOVZ 1");
		assertTrue(cpu.registers[21] == 0, "MOVN 0");
		assertTrue(cpu.registers[22] == 2, "MOVN 1");
	});

	testGroup("LI", {
		assembler.assembleBlock(r"
		.text
			li r2, 0x_F33F_F33F
			li r3, -2
			li r4, 0x_FEEF_0000
			li r5, 0x_0000_FEEF

			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers[2] == 0x_F33F_F33F, "LI 32 bits value");
		assertTrue(cpu.registers[3] == -2, "LI negative number");
		assertTrue(cpu.registers[4] == 0x_FEEF_0000, "LI upper value");
		assertTrue(cpu.registers[5] == 0x_0000_FEEF, "LI lower value");
	});

	testGroup("LA", {
		assembler.assembleBlock(r"
		.text
			la r2, values
			halt
		.data
			values:
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers[2] == assembler.getSymbolAddress("values"), "LA");
	});

	testGroup("LU USES R1", {
		assembler.assembleBlock(r"
		.text

			li r1, 0x_11111111
			li r2, 0x_22222222

			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers[1] != 0x_11111111, "LI should have used register r1");
	});

	testGroup("NOR", {
		assembler.assembleBlock(r"
		.text

			li r2, 0x_000FF000
			li r3, 0x_F33FF33F

			nor r4, r2, r3

			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers[2] == 0x_000FF000, "NOR CHECK 1");
		assertTrue(cpu.registers[3] == 0x_F33FF33F, "NOR CHECK 2");
		assertTrue(cpu.registers[4] == 0x_0CC00CC0, "NOR");
	});

	testGroup("FLOAT (LWC1/SWC1, ADD.S, CEIL.W.S)", {
		assembler.assembleBlock(r"
		.data
			values: .float 1.5, 1.6

		.text
			la $1, values
			lwc1 $f2, 0($1)
			lwc1 $f3, 4($1)
			add.s $f4, $f2, $f3
			swc1 $f4, 8($1)
			ceil.w.s $f1, $f2
			halt
		");

		gotoTextAndExecuteUntilHalt();
		assertTrue(cpu.registers.F[2] == 1.5f, "LWC1 1");
		assertTrue(cpu.registers.F[3] == 1.6f, "LWC1 2");
		assertTrue(cpu.registers.F[4] == 1.5f + 1.6f, "ADD.S");
		assertTrue(cpu.registers.RF[4] == cpu.memory.read32(assembler.segments["data"] + 8), "SWC1");
		assertTrue(cpu.registers.RF[1] == 2, "CEIL.W.S");
	});

	testGroup("FLOAT CVT_S_W", {
		assembler.assembleBlock(r"
		.data
			values: .word 7
		.text
			la $1, values
			lw $1, 0($1)
			mtc1 $1, $f0
			cvt.s.w $f1, $f0

			halt
		");

		gotoTextAndExecuteUntilHalt();
		//cpu.execute(5);
		assertTrue(cpu.registers.RF[0] == 7, "MTC1");
		assertTrue(cpu.registers.F[1] == 7.0, "CVT_S_W");
	});

	testGroup("SHIFT", {
		assembler.assembleBlock(r"
		.text
			li s0, 0x_80_00_00_00
			li s1, 0x_70_00_00_00

			sra a0, s0, 30
			sra a1, s1, 27
			srl a2, s0, 30
			srl a3, s1, 27

			li s0, 0x_17_39_A5_CD
			rotr t0, s0, 0
			rotr t1, s0, 4
			rotr t2, s0, 16
			rotr t3, s0, 24
			
			halt
		");

		gotoTextAndExecuteUntilHalt();

		// Arithmetic. Carries last bit. (two's complement)
		assertTrue(cpu.registers["a0"] == 0xFFFFFFFE, "SRA -");
		assertTrue(cpu.registers["a1"] == 0x0000000E, "SRA +");
		
		// Logic.
		assertTrue(cpu.registers["a2"] == 0x00000002, "SRL -");
		assertTrue(cpu.registers["a3"] == 0x0000000E, "SRL +");
		
		assertTrue(cpu.registers["t0"] == 0x_1739A5CD, "ROTR 0");
		assertTrue(cpu.registers["t1"] == 0x_D1739A5C, "ROTR 4");
		assertTrue(cpu.registers["t2"] == 0x_A5CD1739, "ROTR 16");
		assertTrue(cpu.registers["t3"] == 0x_39A5CD17, "ROTR 24");
	});

	testGroup("SIGN EXTEND", {
		assembler.assembleBlock(r"
		.text
			li a0, 0xFF
			seb a0, a0

			li a1, 0x7F
			seb a1, a1
			
			li a2, 0xFFF8
			seh a2, a2

			li a3, 0x7FF8
			seh a3, a3

			halt
		");

		gotoTextAndExecuteUntilHalt();

		assertTrue(cpu.registers["a0"] == 0xFFFFFFFF, "SEB -");
		assertTrue(cpu.registers["a1"] == 0x0000007F, "SEB +");
		assertTrue(cpu.registers["a2"] == 0xFFFFFFF8, "SEH -");
		assertTrue(cpu.registers["a3"] == 0x00007FF8, "SEH +");
	});

	testGroup("EXT/INS", {
		assembler.assembleBlock(r"
		.text
			li a0, 0x_73_48_5C_20
			
			ext s0, a0, 0, 4
			ext s1, a0, 4, 4
			ext s2, a0, 12, 20
			
			li a1, 0x34
			li s3, 0x_F7_72_5A_43
			ins s3, a1, 16, 8
		
			halt
		");

		gotoTextAndExecuteUntilHalt();
		
		assertTrue(cpu.registers["s0"] == 0x_0, "EXT 0,4");
		assertTrue(cpu.registers["s1"] == 0x_2, "EXT 4,4");
		assertTrue(cpu.registers["s2"] == 0x_73485, "EXT 12,20");
		assertTrue(cpu.registers["s3"] == 0x_F7_34_5A_43, "INS 16,8");
	});

	testGroup("SLTIU", {
		assembler.assembleBlock(r"
		.text
			li r2, 0xFFFFFFFE
			sltiu r1, r2, -1
		
			halt
		");

		gotoTextAndExecuteUntilHalt();
		
		assertTrue(cpu.registers["r1"] == 1, "SLTIU YES");
	});
	
	//WSBW
	//WSBH
	//CLO
	//CLZ
	//SLLV
}
