module pspemu.core.cpu.dynarec.ops.Memory;

template Cpu_Memory() {
	void OP_SB() {
		emiter.MIPS_SB(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET);
	}
}

template Cpu_Memory_Emiter() {
	void MIPS_SB(MipsRegisters rt, MipsRegisters rs, short offset) {
		PUSH(Register32.ECX);
		{
			// Value
			MIPS_LOAD_REGISTER(Register32.EAX, rt);
			PUSH(Register32.EAX);

			// Address
			MIPS_LOAD_REGISTER(Register32.EAX, rs);
			if (offset != 0) ADD_EAX(cast(int)offset);
			PUSH(Register32.EAX);
			{
				CALL(createLabelToFunction(&MEMORY_WRITE_8));
			}
			ADD(Register32.ESP, 8);
		}
		POP(Register32.ECX);
	}
}