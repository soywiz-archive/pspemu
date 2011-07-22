module pspemu.core.cpu.dynarec.ops.Memory;

template Cpu_Memory() {
	void OP_SB() { emiter.MIPS_STORE(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, 1, &MEMORY_WRITE_SB); }
	void OP_SH() { emiter.MIPS_STORE(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, 2, &MEMORY_WRITE_SH); }
	void OP_SW() { emiter.MIPS_STORE(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, 4, &MEMORY_WRITE_SW); }

	void OP_LB () { emiter.MIPS_LOAD(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_READ_LB); }
	void OP_LH () { emiter.MIPS_LOAD(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_READ_LH); }
	void OP_LBU() { emiter.MIPS_LOAD(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_READ_LBU); }
	void OP_LHU() { emiter.MIPS_LOAD(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_READ_LHU); }
	void OP_LW () { emiter.MIPS_LOAD(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET, &MEMORY_READ_LW); }
}
