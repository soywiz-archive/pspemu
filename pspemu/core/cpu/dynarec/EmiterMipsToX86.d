module pspemu.core.cpu.dynarec.EmiterMipsToX86;

import pspemu.core.cpu.dynarec.EmiterX86;

import pspemu.core.Memory;
import pspemu.core.cpu.Registers;

import pspemu.core.cpu.dynarec.emiters.Alu;
import pspemu.core.cpu.dynarec.emiters.Memory;

import pspemu.core.cpu.interpreter.Utils;

class EmiterMipsToX86 : EmiterX86 {
	Memory memory;
	//Registers registers;

	enum MipsRegisters : uint {
		// +00 +01 +02 +03 +04 +05 +06 +07
		    ZR, AT, V0, V1, A0, A1, A2, A3, // +00
		    T0, T1, T2, T3, T4, T5, T6, T7, // +08
		    S0, S1, S2, S3, S4, S5, S6, S7, // +16
		    T8, T9, K0, K1, GP, SP, FP, RA, // +24
	}

	/*
	
	Registers:
		GPR: 4*32
		HI, LO
		CMP1, CMP2
		CLOCKS
		FPR: 4*32
	*/

	static void executeCode(Registers registers, void* codePointer) {
		uint registersInt = cast(uint)&registers.R;
		auto func = cast(uint)codePointer;
		asm {
			//push EBP;
			push EBX;
				mov EBX, registersInt;
				//mov EBP, 0;
				mov EAX, func;
				call EAX;
			pop EBX;
			//pop EBP;
		}
	}

	byte MIPS_GET_DISPLACEMENT(MipsRegisters mipsRegister) {
		return cast(byte)(4 * (0 + (mipsRegister & 31)));
	}
	
	Memory32 MIPS_GET_REGISTER(MipsRegisters mipsRegister) {
		return Memory32(Register32.EBX, MIPS_GET_DISPLACEMENT(mipsRegister));
	}

	Memory32 MIPS_GET_LOHI(int pos) {
		// @TODO! IMPORTANT!
		// Change Registers from a class to a struct
		// in order to be able to determine offsetof at compile time.
		// Amd make those functions as robust as possible.

		return Memory32(Register32.EBX, 4 * (32 + 0 + pos));
		//return Memory32(Register32.EBX, registers.LO.offsetof);
		//return Memory32(Register32.EBX, Registers.LO.offsetof);
	}

	Memory32 MIPS_GET_CMP(int pos) {
		return Memory32(Register32.EBX, 4 * (32 + 2 + pos));
	}
	
	Memory32 MIPS_GET_CLOCKS() {
		return Memory32(Register32.EBX, 4 * (32 + 4));
	}

	void MIPS_LOAD_REGISTER(Register32 x32RegTo, MipsRegisters mipsRegFrom) {
		if (mipsRegFrom == 0) {
			MOV(x32RegTo, 0);
		} else {
			MOV(x32RegTo, MIPS_GET_REGISTER(mipsRegFrom));
		}
	}

	void MIPS_STORE_REGISTER(Register32 x32RegFrom, MipsRegisters mipsRegTo) {
		if (mipsRegTo == 0) return;
		MOV(MIPS_GET_REGISTER(mipsRegTo), x32RegFrom);
	}

	void MIPS_STORE_REGISTER_VALUE(uint value, MipsRegisters mipsRegTo) {
		if (mipsRegTo == 0) return;
		MOV(MIPS_GET_REGISTER(mipsRegTo), value);
	}

	void MIPS_LI(MipsRegisters rt, uint value) {
		MIPS_STORE_REGISTER_VALUE(value, rt); return;
	}
	
	void MIPS_NOP() {
	}

	mixin Cpu_Alu_Emiter;
	mixin Cpu_Memory_Emiter;

	void MIPS_SYSCALL(uint PC, uint code) {
		{
			PUSH(code);
			PUSH(PC);
			PUSH(Register32.EBX);
			CALL(createLabelToFunction(&SYSCALL));
			ADD(Register32.ESP, 8);
		}
		RET();
	}

	void MIPS_PREPARE_CMP(MipsRegisters rs, MipsRegisters rt) {
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		MIPS_LOAD_REGISTER(Register32.EDX, rt);
		CMP(Register32.EAX, Register32.EDX);
	}
}

extern (C) {
	void MEMORY_WRITE_SB(Registers registers, uint addr, uint value) {
		//lastCpu.memory.twrite(addr, cast(ubyte)value);
	}
	void MEMORY_WRITE_SH(Registers registers, uint addr, uint value) {
		//lastCpu.memory.twrite(addr, cast(ushort)value);
	}
	void MEMORY_WRITE_SW(Registers registers, uint addr, uint value) {
		//lastCpu.memory.twrite(addr, cast(uint)value);
	}

	uint MEMORY_READ_LB (Registers registers, uint addr) {
		//return lastCpu.memory.tread!(byte)(addr);
		return -1;
	}
	uint MEMORY_READ_LH (Registers registers, uint addr) {
		//return lastCpu.memory.tread!(short)(addr);
		return -1;
	}
	uint MEMORY_READ_LBU(Registers registers, uint addr) {
		//return lastCpu.memory.tread!(ubyte)(addr);
		return -1;
	}
	uint MEMORY_READ_LHU(Registers registers, uint addr) {
		//return lastCpu.memory.tread!(ushort)(addr);
		return -1;
	}
	uint MEMORY_READ_LW (Registers registers, uint addr) {
		//return lastCpu.memory.tread!(uint)(addr);
		return -1;
	}
	
	void JUMP_PC(uint PC) {
		//lastCpu.registers.pcSet = PC;
		return;
	}

	void SYSCALL(Registers registers, uint PC, uint code) {
		registers.pcSet = PC + 4;
		//writefln("SYSCALL PC(%08X) -> CODE(%08X)", PC, code);
		//lastCpu.syscall(code);
		throw(new Exception("FATAL"));
	}
}
