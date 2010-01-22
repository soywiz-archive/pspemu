module pspemu.core.cpu.cpu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.cpu_table;
import pspemu.core.cpu.cpu_switch;
import pspemu.core.cpu.cpu_asm;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

// OPS.
import pspemu.core.cpu.cpu_utils;
import pspemu.core.cpu.cpu_ops_alu;
import pspemu.core.cpu.cpu_ops_branch;
import pspemu.core.cpu.cpu_ops_jump;
import pspemu.core.cpu.cpu_ops_memory;
import pspemu.core.cpu.cpu_ops_misc;
import pspemu.core.cpu.cpu_ops_fpu;

import std.stdio, std.string;

class CPU {
	Registers registers;
	Memory    memory;

	this() {
		registers = new Registers();
		memory    = new Memory();
	}

	void reset() {
		registers.reset();
		memory.reset();
	}

	void execute(uint count = 0x_FFFFFFFF) {
		Registers   registers = this.registers;
		Memory      memory    = this.memory;
		Instruction instruction;

		// Operations.
		mixin TemplateCpu_ALU;
		mixin TemplateCpu_BRANCH;
		mixin TemplateCpu_JUMP;
		mixin TemplateCpu_MEMORY;
		mixin TemplateCpu_MISC;
		mixin TemplateCpu_FPU;

		void OP_UNK() {
			.writefln("Unknown operation %s", instruction);
			registers.pcAdvance(4);
		}

		while (count--) {
			instruction.v = memory.read32(registers.PC);
			void EXEC() { mixin(genSwitch(PspInstructions)); }
			EXEC();
		}
	}

	void executeSingle() {
		execute(1);
	}

	void executeUntilHalt() {
		try { execute(); } catch (HaltException he) { }
	}
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope cpu = new CPU();
	scope assembler = new AllegrexAssembler(cpu.memory);

	void reset() {
		cpu.reset();
		assembler.reset();
	}

	void dump() {
		cpu.registers.dump();
		assembler.symbolDump();
	}

	void gotoText() {
		cpu.registers.pcSet(assembler.segments["text"]);
	}

	// ADD/ADDI test.
	writefln("  (v0 = (7 + 11 - 5)) == 13");
	{
		reset();

		assembler.assembleBlock(r"
		.text
			addi a0, zero, 7   ; a0 = 7
			addi a1, zero, 11  ; a1 = 11
			add  v0, a0, a1    ; v0 = a0 + a1
			addi v0, v0, -5    ; v0 = v0 - 5
			halt
		");

		gotoText();
		cpu.executeUntilHalt();
		assert(cpu.registers["v0"] == 13);
	}

	// BGEZ test.
	writefln("  v0 = 2; while (v--);");
	{
		reset();

		assembler.assembleBlock(r"
		.text
			addi v0, zero, 2   ; v0 = 2
		loop:                  ;
			bgez v0, loop      ;
			addi v0, v0, -1    ; v0-- . Because of the delayed branch it should be executed anyways.
		");

		gotoText();
		foreach (step, expectedValue; [2, 2, 1, 1, 0, 0]) {
			//writefln("PC: %08X, nPC: %08X, STEP: %d", cpu.registers.PC, cpu.registers.nPC, step);
			cpu.executeSingle();
			assert(cpu.registers["v0"] == expectedValue, format("step: %d; v0 = %d; v0 != %d", step, cpu.registers["v0"], expectedValue));
		}
	}

	// Test JAL and JR.
	writefln("  Simple function call");
	{
		reset();

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
		assert(cpu.registers["r1"] == 1);
		assert(cpu.registers["r2"] == 1);
		assert(cpu.registers["r4"] == 0);
		assert(cpu.registers["ra"] == assembler.getSymbolAddress("my_function") - 4);
		cpu.execute(3);
		assert(cpu.registers["r3"] == 1);
		assert(cpu.registers["r4"] == 1);
	}

	// Test function calls and returns (JR ra).
	// NO Test likely branch.
	writefln("  Simple branch likely");
	{
		reset();

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

		gotoText();
		cpu.executeUntilHalt();
		assert(cpu.registers["r1"] == 0);
		assert(cpu.registers["r2"] == 1);
		//dump();
		assert(cpu.registers.PC    == assembler.getSymbolAddress("label2") + 8);
	}
	
	// Load immediate. LUI + ORI + BITREV.
	writefln("  LI 32 bits LUI + ORI. BITREV.");
	{
		reset();
		assembler.assembleBlock(r"
		.text

			lui a0, 0x8000
			ori a0, a0, 0x1111
			bitrev a1, a0
			
			halt
		");

		gotoText();
		cpu.executeUntilHalt();
		assert(cpu.registers["a0"] == 0x_8000_1111);
		assert(cpu.registers["a1"] == 0x_8888_0001);
	}

	// MIN, MAX.
	writefln("  MIN, MAX");
	{
		reset();
		assembler.assembleBlock(r"
		.text

			addi r1, zero, -5
			addi r2, zero,  5
			max r11, r1, r2
			min r12, r1, r2
			min r13, zero, zero

			halt
		");

		gotoText();

		cpu.executeUntilHalt();
		assert(cpu.registers[11] == +5);
		assert(cpu.registers[12] == -5);
		assert(cpu.registers[13] ==  0);
	}

	// MULT
	writefln("  MULT/MFHI/MFLO");
	{
		reset();
		assembler.assembleBlock(r"
		.text

			addi r1, zero, 2
			addi r2, zero, 3
			mult r1, r2
			mflo r3
			mfhi r4

			halt
		");

		gotoText();
		cpu.executeUntilHalt();

		assert(cpu.registers[1] == 2);
		assert(cpu.registers[2] == 3);
		assert(cpu.registers[3] == 2 * 3);
		assert(cpu.registers[4] == 0);
		assert(cpu.registers.LO == cpu.registers[3]);
		assert(cpu.registers.HI == cpu.registers[4]);
	}

	writefln("  MADD/MTHI/MTLO");
	{
		reset();
		assembler.assembleBlock(r"
		.text

			addi r1, zero, 2
			addi r2, zero, 3
			addi r3, zero, 7
			mtlo r3
			mthi r3
			madd r1, r2
			
			halt
		");

		gotoText();
		cpu.executeUntilHalt();

		assert(cpu.registers[1] == 2);
		assert(cpu.registers[2] == 3);
		assert(cpu.registers[3] == 7);
		assert(cpu.registers.LO == cpu.registers[3] + (cpu.registers[1] * cpu.registers[2]));
		assert(cpu.registers.HI == cpu.registers[3] + (0));
	}

	writefln("  MOVZ/MOVN");
	{
		reset();
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

		gotoText();
		cpu.executeUntilHalt();
		//dump();
		assert(cpu.registers[11] == 2);
		assert(cpu.registers[12] == 0);
		assert(cpu.registers[21] == 0);
		assert(cpu.registers[22] == 2);
	}

	writefln("  NOR");
	{
		reset();
		assembler.assembleBlock(r"
		.text

			;li r1, 0x_000FF000
			lui r1, 0x_000F
			ori r1, r1, 0x_F000

			;li r2, 0x_F33FF33F
			lui r2, 0x_F33F
			ori r2, r2, 0x_F33F

			nor r3, r1, r2

			halt
		");

		gotoText();
		cpu.executeUntilHalt();
		//cpu.execute(5);
		assert(cpu.registers[1] == 0x_000FF000);
		assert(cpu.registers[2] == 0x_F33FF33F);
		assert(cpu.registers[3] == 0x_0CC00CC0);
	}
}
