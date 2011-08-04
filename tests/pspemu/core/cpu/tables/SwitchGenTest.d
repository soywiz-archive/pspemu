module pspemu.core.cpu.tables.SwitchGenTest;

import pspemu.core.cpu.tables.SwitchGen;

import tests.Test;

import pspemu.core.cpu.Instruction;

alias InstructionDefinition ID;
alias ValueMask VM;

const PspInstructionsTest = [
	// Arithmetic operations.
	ID("add",         VM("000000:rs:rt:rd:00000:100000"), "%d, %s, %t", ADDR_TYPE_NONE, 0),
	ID("addu",        VM("000000:rs:rt:rd:00000:100001"), "%d, %s, %t", ADDR_TYPE_NONE, 0),
	
	ID("bgezal",      VM("000001:rs:10001:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_JAL),
	ID("bgezall",     VM("000001:rs:10011:imm16"), "%s, %O",     ADDR_TYPE_16,  INSTR_TYPE_JAL),

	ID("lh",          VM("100001:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0),
	ID("lw",          VM("100011:rs:rt:imm16"), "%t, %o", ADDR_TYPE_NONE, 0),
	
	ID("ceil.w.s",    VM("010001:10000:00000:fs:fd:001110"), "%D, %S",     ADDR_TYPE_NONE, 0),
	ID("floor.w.s",   VM("010001:10000:00000:fs:fd:001111"), "%D, %S",     ADDR_TYPE_NONE, 0),
	
	ID("cache",       VM("101111--------------------------"), "%k, %o", ADDR_TYPE_NONE, 0),
	ID("sync",        VM("000000:00000:00000:00000:00000:001111"), "", ADDR_TYPE_NONE, 0),
	
	ID("mfdr",        VM("011100:00000:----------:00000:111101"), "%t, %r", ADDR_TYPE_NONE, INSTR_TYPE_PSP),

	ID("lv.s",        VM("110010:rs:vt5:imm14:vt2"), "%Xs, %Y", ADDR_TYPE_NONE, INSTR_TYPE_PSP),
	ID("vpfxs",       VM("110111:00:----:negw:negz:negy:negx:cstw:cstz:csty:cstx:absw:absz:absy:absx:swzw:swzz:swzy:swzx"), "[%vp0, %vp1, %vp2, %vp3]", ADDR_TYPE_NONE, INSTR_TYPE_PSP),

];

class SwitchGenTest : Test {
	string find(Instruction instruction) {
		string callFunction2(string opname) {
			return "CALL(\"" ~ opname ~ "\");";
		}
		string ret;
		void CALL(string name) {
			ret = name;
		}
		mixin(genSwitch(PspInstructionsTest, "callFunction2"));
		return ret;
	}
	
	void testSwitchGen() {
		foreach (instructionDefinition; PspInstructionsTest) {
			assertEquals(instructionDefinition.name, find(Instruction(instructionDefinition.opcode.value))); // add
		}
		
		assertEquals("unk", find(Instruction(0b_00100000000000000000000000000000))); // unk
	}
}