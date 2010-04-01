module pspemu.core.cpu.dynarec.ops.Alu;

template Cpu_Alu() {
	// LUI.
	void OP_LUI()  { emiter.MIPS_LUI  (cast(Register)instruction.RT, cast(ushort)instruction.IMMU); }

	// Logic operations.
	void OP_ORI()  { emiter.MIPS_ORI  (cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.IMMU); }

	// Arithmetic operations.
	void OP_ADDI() { emiter.MIPS_ADDIU(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(int)instruction.IMM); } alias OP_ADDI OP_ADDIU;
	void OP_ADD () { emiter.MIPS_ADDU(cast(Register)instruction.RD, cast(Register)instruction.RS, cast(Register)instruction.RT); } alias OP_ADD OP_ADDU;

	// Shift.
	void OP_SLL() { emiter.MIPS_SLL(cast(Register)instruction.RD, cast(Register)instruction.RT, cast(ubyte)instruction.POS); }

	// Set Less Than.
	void OP_SLTU() {
		if (inDelayedBranch) emiter.PUSHF();
		emiter.MIPS_SLTU(cast(Register)instruction.RD, cast(Register)instruction.RS, cast(Register)instruction.RT);
		if (inDelayedBranch) emiter.POPF();
	}
}

template Cpu_Alu_Emiter() {
	void MIPS_SLL(MipsRegisters rd, MipsRegisters rt, ubyte pos) {
		if (rd == 0) return;
		if (rt == 0) {
			MIPS_STORE_REGISTER_VALUE(0, rd);
		} else {
			MIPS_LOAD_REGISTER(Register32.EAX, rt);
			SHL(Register32.EAX, pos);
			MIPS_STORE_REGISTER(Register32.EAX, rd);
		}
	}

	void MIPS_LUI(MipsRegisters rt, ushort value) {
		if (rt == 0) return;
		MIPS_STORE_REGISTER_VALUE((value << 16), rt);
	}

	void MIPS_SLTU(MipsRegisters rd, MipsRegisters rs, MipsRegisters rt) {
		if (rd == 0) return;
		MIPS_PREPARE_CMP(rs, rt);
		SETL_EAX();
		MIPS_STORE_REGISTER(Register32.EAX, rd);
		//$rd = $rs < $rt;
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
}