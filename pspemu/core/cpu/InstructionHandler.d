module pspemu.core.cpu.InstructionHandler;

import std.stdio;
import core.thread;

import pspemu.core.ThreadState;
import pspemu.core.Memory;
import pspemu.core.exceptions.HaltException;

import pspemu.core.cpu.tables.Table;
import pspemu.core.cpu.tables.SwitchGen;
import pspemu.core.cpu.tables.DummyGen;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Registers;

string genSwitchAll() {
	const string str = q{
		genSwitch(
			PspInstructions_ALU ~
			PspInstructions_BCU ~
			PspInstructions_LSU ~
			PspInstructions_FPU ~
			PspInstructions_COP0 ~
			PspInstructions_VFPU_IMP ~
			//PspInstructions_VFPU ~
			PspInstructions_SPECIAL
		)
	};
	//pragma(msg, mixin(str));
	return mixin(str);
}

class InstructionHandler {
	void OP_DISPATCH(string name) {
		writefln("OP_DISPATCH(%s)", name);
		throw(new Exception("Invalid operation: " ~ name));
	}
	
	mixin(DummyGenUnk());
    mixin(DummyGen(PspInstructions_ALU));
    mixin(DummyGen(PspInstructions_BCU));
    mixin(DummyGen(PspInstructions_LSU));
    mixin(DummyGen(PspInstructions_FPU));
    mixin(DummyGen(PspInstructions_COP0));
    mixin(DummyGen(PspInstructions_VFPU_IMP));
    //mixin(DummyGen(PspInstructions_VFPU));
    mixin(DummyGen(PspInstructions_SPECIAL));

    void processSingle(Instruction instruction) {
    	mixin(genSwitchAll());
    }
}