module pspemu.core.cpu.dynarec.ops.Memory;

extern(C) {
	typedef void function(uint addr, ubyte value) WriteFunc;
	typedef uint function(uint addr) ReadFunc;
}

template Cpu_Memory() {
	void OP_SB() { emiter.MIPS_STORE(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_WRITE_SB); }
	void OP_SH() { emiter.MIPS_STORE(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_WRITE_SH); }
	void OP_SW() { emiter.MIPS_STORE(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_WRITE_SW); }

	void OP_LB () { emiter.MIPS_LOAD(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_READ_LB); }
	void OP_LH () { emiter.MIPS_LOAD(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_READ_LH); }
	void OP_LBU() { emiter.MIPS_LOAD(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_READ_LBU); }
	void OP_LHU() { emiter.MIPS_LOAD(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_READ_LHU); }
	void OP_LW () { emiter.MIPS_LOAD(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_READ_LW); }
}

template Cpu_Memory_Emiter() {
	void MIPS_STORE(MipsRegisters rt, MipsRegisters rs, short offset, WriteFunc func) {
		// Value
		MIPS_LOAD_REGISTER(Register32.EAX, rt);
		PUSH(Register32.EAX);

		// Address
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		if (offset != 0) ADD(Register32.EAX, cast(int)offset);
		PUSH(Register32.EAX);
		{
			CALL(cast(void*)func);
		}
		ADD(Register32.ESP, 8);
	}

	void MIPS_LOAD(MipsRegisters rt, MipsRegisters rs, short offset, ReadFunc func) {
		// Address
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		if (offset != 0) ADD(Register32.EAX, cast(int)offset);
		PUSH(Register32.EAX);
		{
			CALL(cast(void*)func);
		}
		ADD(Register32.ESP, 4);
		MIPS_STORE_REGISTER(Register32.EAX, rt);
	}
}