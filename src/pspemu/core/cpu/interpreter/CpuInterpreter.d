module pspemu.core.cpu.interpreter.CpuInterpreter;

import std.stdio;
import std.math;

public import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Registers;

import pspemu.Exceptions;

import pspemu.core.cpu.interpreter.ops.Cpu_Alu;
import pspemu.core.cpu.interpreter.ops.Cpu_Memory;
import pspemu.core.cpu.interpreter.ops.Cpu_Branch;
import pspemu.core.cpu.interpreter.ops.Cpu_Special;
import pspemu.core.cpu.interpreter.ops.Cpu_Jump;
import pspemu.core.cpu.interpreter.ops.Cpu_Fpu;
import pspemu.core.cpu.interpreter.ops.Cpu_VFpu;

import pspemu.core.cpu.tables.Table;
import pspemu.core.cpu.tables.SwitchGen;
import pspemu.core.cpu.tables.DummyGen;
import pspemu.core.cpu.interpreter.Utils;
import pspemu.core.cpu.Instruction;
import pspemu.core.Memory;
import pspemu.core.Interrupts;

import pspemu.utils.Logger;
import core.thread;

//version = VERSION_SHIFT_ASM;

//import pspemu.utils.Utils;

final class CpuInterpreter : Cpu {
	public this(Memory memory, ISyscall syscall, Interrupts interrupts) {
		super(memory, syscall, interrupts);
	}

	public void execute_loop_limit(Registers registers, uint maxInstructions) {
		// Set up variables as locals in order to improve speed. Check if it really improves the speed?
		Cpu cpu = this;
		Instruction instruction;
		Memory memory = this.memory;
		Interrupts interrupts = this.interrupts;

		// Embed code of the instructions on this context.
		mixin TemplateCpu_ALU;
		mixin TemplateCpu_MEMORY;
		mixin TemplateCpu_BRANCH;
		mixin TemplateCpu_JUMP;
		mixin TemplateCpu_SPECIAL;
		mixin TemplateCpu_FPU;
		mixin TemplateCpu_VFPU;
		
		uint CYCLES;
		
    	while (running) {
	    	// If have pending interrupts.
	    	if (interrupts.I_F) {
	    		interrupts.executeInterrupts(registers);
	    	}

			// Read the instruction.
	    	instruction.v = memory.tread!(uint)(registers.PC);
	    	
	    	// If we are tracing.
	    	if (trace) {
	    		//writefln("%s :: nPC:%08X: INSTRUCTION:%08X : RA:%08X", threadState, registers.nPC, instruction.v, registers.RA);
	    		writefln("PC:%08X, nPC:%08X: INSTRUCTION:%08X : RA:%08X", registers.PC, registers.nPC, instruction.v, registers.RA);
	    	}
	    	
	    	// Execute the instruction.
	    	mixin(genSwitchAll());
	    	
	    	// Increment counters.
	    	//executedInstructionsCount++;
	    	registers.EXECUTED_INSTRUCTION_COUNT_THIS_THREAD++;
	    	CYCLES++;
	    	if (CYCLES > maxInstructions) break;
	    }
	}
}
