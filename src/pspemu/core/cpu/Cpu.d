module pspemu.core.cpu.Cpu;

import std.stdio;
import core.thread;
import core.time;
import std.datetime;

import pspemu.core.ThreadState;
import pspemu.core.Memory;
import pspemu.core.exceptions.HaltException;
import pspemu.core.exceptions.NotImplementedException;

import pspemu.core.cpu.tables.Table;
import pspemu.core.cpu.tables.SwitchGen;
import pspemu.core.cpu.tables.DummyGen;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Registers;

import pspemu.utils.Logger;

import pspemu.hle.kd.threadman.Types;

abstract class Cpu {
	ISyscall   syscall;
	Interrupts interrupts;
	Memory     memory;
	
	public this(Memory memory, ISyscall syscall, Interrupts interrupts) {
		this.memory     = memory;
		this.syscall    = syscall;
		this.interrupts = interrupts;
	}

    abstract void execute(Registers registers, bool trace = false);
    
    string toString() { return "Cpu(" ~ threadState.toString() ~ ")"; }
    
	static string genSwitchBranch() {
		const string str = q{
			pspemu.core.cpu.tables.SwitchGen.genSwitch(
				PspInstructions_BCU ~
				PspInstructions_VFPU_BRANCH ~
			)
		};
		//pragma(msg, mixin(str));
		return mixin(str);
	}
	
	static string genSwitchAll() {
		const string str = q{
			pspemu.core.cpu.tables.SwitchGen.genSwitch(
				PspInstructions_ALU ~
				PspInstructions_BCU ~
				PspInstructions_LSU ~
				PspInstructions_FPU ~
				PspInstructions_COP0 ~
				PspInstructions_VFPU_IMP ~
				PspInstructions_VFPU_BRANCH ~
				PspInstructions_SPECIAL
			)
		};
		//pragma(msg, mixin(str));
		return mixin(str);
	}
}