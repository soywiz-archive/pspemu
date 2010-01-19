module pspemu.core.cpu.cpu;

import pspemu.core.cpu.registers;
import pspemu.core.cpu.cpu_table;
import pspemu.core.cpu.cpu_switch;
import pspemu.core.cpu.cpu_ops_alu;
import pspemu.core.cpu.cpu_ops_branch;
import pspemu.core.cpu.cpu_ops_jump;
import pspemu.core.cpu.cpu_asm;
import pspemu.core.cpu.instruction;
import pspemu.core.memory;

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
		Registers registers = this.registers;
		Instruction instruction = void;

		// Operations.
		mixin TemplateCpu_ALU;
		mixin TemplateCpu_BRANCH;
		mixin TemplateCpu_JUMP;
		void OP_UNK() {
			.writefln("Unknown operation %s", instruction);
			registers.advance_pc(4);
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
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");
	scope cpu = new CPU();
	scope assembler = new AllegrexAssembler(cpu.memory);

	void reset() {
		cpu.reset();
		assembler.reset();
	}

	writefln("  (v0 = (7 + 11 - 5)) == 13");
	// ADD/ADDI test.
	{
		reset();

		assembler.assembleBlock(r"
			.text
			addi a0, zero, 7   ; a0 = 7
			addi a1, zero, 11  ; a1 = 11
			add  v0, a0, a1    ; v0 = a0 + a1
			addi v0, v0, -5    ; v0 = v0 - 5
		");

		cpu.registers.set_pc(assembler.segments["text"]);
		cpu.execute(4);
		//cpu.registers.dump(true);
		assert(cpu.registers["v0"] == 13);
	}

	writefln("  v0 = 2; while (v--);");
	// BGEZ test.
	{
		reset();

		assembler.assembleBlock(r"
			.text
			addi v0, zero, 2      ; v0 = 2
			loop:                 ;
				bgez v0, loop     ;
				addi v0, v0, -1   ; v0-- . Because of the delayed branch it should be executed anyways.
		");

		cpu.registers.set_pc(assembler.segments["text"]);
		foreach (step, expectedValue; [2, 2, 1, 1, 0, 0]) {
			//writefln("PC: %08X, nPC: %08X, STEP: %d", cpu.registers.PC, cpu.registers.nPC, step);
			cpu.executeSingle();
			assert(cpu.registers["v0"] == expectedValue, format("step: %d; v0 = %d; v0 != %d", step, cpu.registers["v0"], expectedValue));
		}
	}

	// Test fordward label references
	// Test JAL and JR
	{
		reset();

		assembler.assembleBlock(r"
			.text

			jal  my_function      ;               ; 0x08000000
			addi r1, zero, 1      ; r1 = 1        ; 0x08000004
			addi r4, zero, 1      ; r4 = 1        ; 0x08000008

			my_function:            ;
				addi r2, zero, 1    ; r2 = 1      ; 0x0800000C
				jr ra               ; Returns     ; 0x08000010
				addi r3, zero, 1    ; r3 = 1      ; 0x08000014
		");

		cpu.registers.set_pc(assembler.segments["text"]);
		cpu.execute(3);
		assert(cpu.registers["r1"] == 1);
		assert(cpu.registers["r2"] == 1);
		assert(cpu.registers["ra"] == assembler.labels["my_function"] - 4);
		cpu.execute(3);
		assert(cpu.registers["r3"] == 1);
		assert(cpu.registers["r4"] == 1);
	}

	// Test fordward label references
	// Test function calls and returns (JR ra)
	// NO Test likely branch
	{
		reset();

		assembler.assembleBlock(r"
			.text

			addi   v0, zero, 1      ; v0 = 1
			bgezal v0, my_function  ;
			addi   a0, zero, 1      ; a0 = 1
			addi   a1, zero, 1      ; a1 = 1

			my_function:            ;
				addi a2, zero, 1    ; a2 = 1
				jr ra               ; Returns from the function
		");
	}
}
