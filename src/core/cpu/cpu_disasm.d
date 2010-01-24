module pspemu.core.cpu.cpu_disasm;

import pspemu.core.memory;
import pspemu.core.cpu.instruction;
import pspemu.core.cpu.cpu_switch;
import pspemu.core.cpu.cpu_table;
import pspemu.core.cpu.registers;

class AllegrexDisassembler {
	string dissasm(Instruction i, uint PC) {
		//mixin(genSwitch(PspInstructions));
		return null;
	}
}
