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
			if (rd == rs) {
				if (value != 0) ADD(MIPS_GET_REGISTER(rd), value);
			} else {
				MIPS_LOAD_REGISTER(Register32.EAX, rs);
				if (value != 0) ADD(Register32.EAX, value);
				MIPS_STORE_REGISTER(Register32.EAX, rd);
			}
		}
	}

	void MIPS_OR(MipsRegisters rd, MipsRegisters rs, MipsRegisters rt) {
		if (rd == 0) return;
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		MIPS_LOAD_REGISTER(Register32.ECX, rt);
		OR(Register32.EAX, Register32.ECX);
		MIPS_STORE_REGISTER(Register32.EAX, rd);
	}

	void MIPS_AND(MipsRegisters rd, MipsRegisters rs, MipsRegisters rt) {
		if (rd == 0) return;
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		MIPS_LOAD_REGISTER(Register32.ECX, rt);
		AND(Register32.EAX, Register32.ECX);
		MIPS_STORE_REGISTER(Register32.EAX, rd);
	}

	void MIPS_XOR(MipsRegisters rd, MipsRegisters rs, MipsRegisters rt) {
		if (rd == 0) return;
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		MIPS_LOAD_REGISTER(Register32.ECX, rt);
		XOR(Register32.EAX, Register32.ECX);
		MIPS_STORE_REGISTER(Register32.EAX, rd);
	}

	void MIPS_ORI(MipsRegisters rt, MipsRegisters rs, ushort value) {
		if (rt == 0) return;
		if (rs == 0) {
			MIPS_STORE_REGISTER_VALUE(value, rt);
		} else {
			MIPS_LOAD_REGISTER(Register32.EAX, rs);
			if (value != 0) OR_AX(value);
			MIPS_STORE_REGISTER(Register32.EAX, rt);
		}
	}

	void MIPS_XORI(MipsRegisters rt, MipsRegisters rs, ushort value) {
		if (rt == 0) return;
		if (rs == 0) {
			MIPS_STORE_REGISTER_VALUE(value, rt);
		} else {
			MIPS_LOAD_REGISTER(Register32.EAX, rs);
			if (value != 0) XOR_AX(value);
			MIPS_STORE_REGISTER(Register32.EAX, rt);
		}
	}

	void MIPS_ANDI(MipsRegisters rt, MipsRegisters rs, ushort value) {
		if (rt == 0) return;
		if (rs == 0) {
			MIPS_STORE_REGISTER_VALUE(0, rt);
		} else {
			MIPS_LOAD_REGISTER(Register32.EAX, rs);
			if (value != 0) AND_AX(value);
			MIPS_STORE_REGISTER(Register32.EAX, rt);
		}
	}
	
}