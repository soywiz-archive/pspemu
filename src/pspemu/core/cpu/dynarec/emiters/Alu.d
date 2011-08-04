module pspemu.core.cpu.dynarec.emiters.Alu;

template Cpu_Alu_Emiter() {
	void MIPS_DIV(MipsRegisters rs, MipsRegisters rt, Sign signed) {
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		MIPS_LOAD_REGISTER(Register32.EDX, rt);
		if (signed) {
			IDIV(Register32.EDX);
		} else {
			DIV(Register32.EDX);
		}
		MOV(MIPS_GET_LOHI(0), Register32.EAX); // Result
		MOV(MIPS_GET_LOHI(1), Register32.EDX); // Remainder
	}

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
