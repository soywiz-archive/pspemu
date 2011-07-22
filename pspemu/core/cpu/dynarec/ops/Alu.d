module pspemu.core.cpu.dynarec.ops.Alu;

template Cpu_Alu() {
	// LUI.
	void OP_LUI()  { emiter.MIPS_LUI(RT, cast(ushort)IMMU); }

	// Logic operations.
	void OP_OR  ()  { emiter.MIPS_OR  (RD, RS, RT); }
	void OP_AND ()  { emiter.MIPS_AND (RD, RS, RT); }
	void OP_XOR ()  { emiter.MIPS_XOR (RD, RS, RT); }

	void OP_ORI ()  { emiter.MIPS_ORI (RT, RS, cast(ushort)IMMU); }
	void OP_XORI()  { emiter.MIPS_XORI(RT, RS, cast(ushort)IMMU); }
	void OP_ANDI()  { emiter.MIPS_ANDI(RT, RS, cast(ushort)IMMU); }

	// Arithmetic operations.
	void OP_ADDI() { emiter.MIPS_ADDIU(RT, RS, IMM); } alias OP_ADDI OP_ADDIU;
	void OP_ADD () { emiter.MIPS_ADDU(RD, RS, RT); } alias OP_ADD OP_ADDU;

	// Shift.
	void OP_SLL() { emiter.MIPS_SLL(RD, RT, POS); }

	// Set Less Than.
	void OP_SLTU() { emiter.MIPS_SLTU(RD, RS, RT); }

	// Divide.
	void OP_DIV () { emiter.MIPS_DIV(RS, RT, Sign.Signed); }
	void OP_DIVU() { emiter.MIPS_DIV(RS, RT, Sign.Unsigned); }
}
