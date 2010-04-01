module pspemu.core.cpu.dynarec.Cpu;

public import pspemu.utils.EmiterX86;

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

class EmiterMipsToX86 : EmiterX86 {
	enum MipsRegisters : uint {
		// +00 +01 +02 +03 +04 +05 +06 +07
		    ZR, AT, V0, V1, A0, A1, A2, A3, // +00
		    T0, T1, T2, T3, T4, T5, T6, T7, // +08
		    S0, S1, S2, S3, S4, S5, S6, S7, // +16
		    T8, T9, K0, K1, GP, SP, FP, RA, // +24
	}

	void MIPS_LOAD_REGISTER_TABLE(uint register_table) {
		MOV(Register32.ECX, register_table);
	}

	byte MIPS_GET_DISPLACEMENT(MipsRegisters mipsRegister) {
		return cast(byte)(4 * (mipsRegister & 31));
	}

	void MIPS_LOAD_REGISTER(Register32 x32RegTo, MipsRegisters mipsRegFrom) {
		if (mipsRegFrom == 0) {
			MOV(x32RegTo, 0);
		} else {
			MOV_FROMPTR(Register32.ECX, x32RegTo, MIPS_GET_DISPLACEMENT(mipsRegFrom));
		}
	}

	void MIPS_STORE_REGISTER(Register32 x32RegFrom, MipsRegisters mipsRegTo) {
		if (mipsRegTo == 0) return;
		MOV_TOPTR(Register32.ECX, x32RegFrom, MIPS_GET_DISPLACEMENT(mipsRegTo));
	}

	void MIPS_STORE_REGISTER_VALUE(uint value, MipsRegisters mipsRegTo) {
		if (mipsRegTo == 0) return;
		MOV_TOPTR(Register32.ECX, value, MIPS_GET_DISPLACEMENT(mipsRegTo));
	}

	void MIPS_LI(MipsRegisters rt, uint value) {
		MIPS_STORE_REGISTER_VALUE(value, rt); return;
		/*
		if (value & ~0xFFFF) {
			MIPS_LUI(rt, value >> 16);
			MIPS_ORI(rt, rt, value & 0xFFFF);
		} else {
			MIPS_ORI(rt, MipsRegisters.ZR, value & 0xFFFF);
		}
		*/
	}
	
	void MIPS_NOP() {
	}

	void MIPS_ADDU(MipsRegisters rd, MipsRegisters rs, MipsRegisters rt) {
		if (rd == 0) return;
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		MIPS_LOAD_REGISTER(Register32.EDX, rt);
		ADD(Register32.EAX, Register32.EDX);
		MIPS_STORE_REGISTER(Register32.EAX, rd);
	}

	void MIPS_ADDIU(MipsRegisters rd, MipsRegisters rs, uint value) {
		if (rd == 0) return;
		if (rs == 0) {
			MIPS_STORE_REGISTER_VALUE(value, rd);
		} else {
			MIPS_LOAD_REGISTER(Register32.EAX, rs);
			ADD_EAX(value);
			MIPS_STORE_REGISTER(Register32.EAX, rd);
		}
	}

	void MIPS_ORI(MipsRegisters rd, MipsRegisters rs, ushort value) {
		if (rd == 0) return;
		if (rs == 0) {
			MIPS_STORE_REGISTER_VALUE(value, rd);
		} else {
			MIPS_LOAD_REGISTER(Register32.EAX, rs);
			if (value != 0) OR_AX(value);
			MIPS_STORE_REGISTER(Register32.EAX, rd);
		}
	}

	void MIPS_LUI(MipsRegisters rt, ushort value) {
		/*
		MOV(Register32.EAX, 0);
		OR_AX(value);
		SHL(Register32.EAX, 16);
		MIPS_STORE_REGISTER(Register32.EAX, rt);
		*/
		MIPS_STORE_REGISTER_VALUE((value << 16), rt);
	}

	void MIPS_SB(MipsRegisters rt, MipsRegisters rs, short offset) {
		// Value
		MIPS_LOAD_REGISTER(Register32.EAX, rt);
		PUSH(Register32.EAX);

		// Address
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		if (offset != 0) ADD_EAX(cast(int)offset);
		PUSH(Register32.EAX);

		CALL(createLabelToFunction(&MEMORY_WRITE_8));

		ADD(Register32.ESP, 8);
	}

	void MIPS_PREPARE_CMP(MipsRegisters rs, MipsRegisters rt) {
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		MIPS_LOAD_REGISTER(Register32.EDX, rt);
		CMP(Register32.EAX, Register32.EDX);
	}

	void MIPS_BNE(Label* label) {
		JNE(label);
	}
}

extern(C) void MEMORY_WRITE_8(uint addr, ubyte value) {
	//writefln("WRITE(%08X) <- %02X", addr, value);
}

class InstructionMarker {
	bool[uint] marks;

	void mark(uint PC) {
		marks[PC] = true;
	}

	void unmark(uint PC) {
		marks.remove(PC);
	}
	
	bool marked(uint PC) {
		return (PC in marks) !is null;
	}
}

class CpuDynaRec : Cpu {
	this(Memory memory, Gpu gpu, Display display, IController controller) {
		super(memory, gpu, display, controller);
	}

	struct InstructionInfo {
		uint PC;
		InstructionDefinition instructionDefinition;
		Instruction instruction;
		bool isJump() {
			return instructionDefinition.addrtype != ADDR_TYPE_NONE;
		}
		bool isEndOfBranch() {
			if (!isJump) return false;
			// @TODO Check conditional!
			return true;
		}
		bool isLikely() {
			// @TODO Check likely!
			return false;
		}
		void parse(uint PC, uint v) {
			this.PC = PC;
			instruction.v = v;
		}
		uint jumpAddress() {
			switch (instructionDefinition.addrtype) {
				default: return -1;
				case ADDR_TYPE_16: return PC + instruction.IMMU;
				case ADDR_TYPE_26: return instruction.JUMP2;
			}
		}
	}

	void analyzeFunction(uint PC) {
		InstructionMarker explored = new InstructionMarker;
		InstructionInfo instructionInfo;
		bool[uint] branchesToExplore;
		bool[uint] labels;
		branchesToExplore[PC] = true;
		
		while (branchesToExplore.length) {
			PC = branchesToExplore.keys[0];
			labels[PC] = true;
			branchesToExplore.remove(PC);
			for (;; PC++) {
				if (explored.marked(PC)) break;
				explored.mark(PC);
				instructionInfo.parse(PC, memory.read32(PC));

				if (instructionInfo.isJump) {
					branchesToExplore[instructionInfo.jumpAddress] = true;
				}

				if (instructionInfo.isEndOfBranch) break;
			}
		}
	}
}