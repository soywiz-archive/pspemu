module pspemu.core.cpu.interpreted.Cpu;

const uint THREAD0_CALL_MASK = 0xFFFF;
//const uint THREAD0_CALL_MASK = 0xFFF;

//debug = DEBUG_GEN_SWITCH;

import pspemu.core.gpu.Gpu;
import pspemu.models.IDisplay;
import pspemu.models.IController;
import pspemu.models.ISyscall;

import pspemu.core.Memory;
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Interrupts;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Table;
import pspemu.core.cpu.Switch;
import pspemu.core.cpu.interpreted.Utils;

// OPS.
import pspemu.core.cpu.interpreted.ops.Alu;
import pspemu.core.cpu.interpreted.ops.Branch;
import pspemu.core.cpu.interpreted.ops.Jump;
import pspemu.core.cpu.interpreted.ops.Memory;
import pspemu.core.cpu.interpreted.ops.Misc;
import pspemu.core.cpu.interpreted.ops.Fpu;
import pspemu.core.cpu.interpreted.ops.VFpu;
import pspemu.core.cpu.interpreted.ops.Unimplemented;

/**
 * Class that will be on charge of the emulation of Allegrex main CPU.
 */
class CpuInterpreted : public Cpu {
	this(Memory memory, Gpu gpu, Display display, IController controller) {
		super(memory, gpu, display, controller);
	}

	/**
	 * Will execute a number of instructions.
	 *
	 * Note: Some instructions may throw some kind of exceptions that will break the flow.
	 *
	 * @param  count  Maximum number of instructions to execute.
	 */
	void execute(uint count) {
		// Shortcuts for registers and memory.
		auto registers = this.registers;
		auto memory    = this.memory;
		auto cpu       = this;

		// Declaration for instruction struct that will allow to decode instructions easily.
		Instruction instruction = void;

		// Operations.
		mixin TemplateCpu_ALU;
		mixin TemplateCpu_BRANCH;
		mixin TemplateCpu_JUMP;
		mixin TemplateCpu_MEMORY;
		mixin TemplateCpu_MISC;
		mixin TemplateCpu_FPU;
		mixin TemplateCpu_VFPU;
		mixin TemplateCpu_UNIMPLEMENTED;

		// Will execute instructions until count reach zero or an exception is thrown.
		//writefln("Execute: %08X", count);
		while (count--) {
			// Equeue a THREAD Interrupt (to switch threads)
			if (registers.PAUSED || ((count & THREAD0_CALL_MASK) == 0)) interrupts.queue(Interrupts.Type.THREAD0);
			
			// Process interrupts if there are pending interrupts
			// Process IRQ (Interrupt ReQuest)
			if (interrupts.InterruptFlag) interrupts.process();

			if (runningState != RunningState.RUNNING) waitUntilResume();
			
			if (registers.PAUSED) {
				sleep(0);
				//writefln("paused!");
				continue;
			}

			if (checkBreakpoints) {
				breakPointPrevPC = registers.PC;
				if (traceStep) {
					if (breakpointRegisters) breakpointRegisters.copyFrom(registers);
					//breakpointStep.registers.
				}
			}

			instruction.v = memory.read32(registers.PC);
			lastValidPC = registers.PC;
			mixin(genSwitch(PspInstructions));

			if (checkBreakpoints) {
				if (traceStep) {
					trace(breakpointStep, breakPointPrevPC, true);
				} else {
					if (!checkBreakpoint(breakPointPrevPC)) {
					}
				}
			}

			registers.CLOCKS++;
		}
		//writefln("Execute: end");
	}
}

// Shows the generated switch.
debug (DEBUG_GEN_SWITCH) pragma(msg, genSwitch(PspInstructions));
