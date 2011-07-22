module pspemu.core.cpu.dynarec.emiters.Memory;

extern(C) {
	typedef void function(uint addr, uint value) WriteFunc;
	typedef uint function(uint addr) ReadFunc;
}

template Cpu_Memory_Emiter() {
	void MIPS_STORE(MipsRegisters rt, MipsRegisters rs, short offset, int size, WriteFunc func) {
		if (memory.baseMemory is null) {
			// Value
			MIPS_LOAD_REGISTER(Register32.EAX, rt);
			PUSH(Register32.EAX);

			// Address
			MIPS_LOAD_REGISTER(Register32.EAX, rs);
			if (offset != 0) ADD(Register32.EAX, cast(int)offset);
			PUSH(Register32.EAX);
			PUSH(Register32.EBX);
			{
				CALL(cast(void*)func);
			}
			ADD(Register32.ESP, 8);
		} else {
			MIPS_LOAD_REGISTER(Register32.EAX, rs); // Address
			if (offset != 0) ADD(Register32.EAX, cast(int)offset);
			MIPS_LOAD_REGISTER(Register32.ECX, rt); // Value
			//AND(Register32.EAX, 0x0FFFFFFF);
			ADD(Register32.EAX, cast(uint)cast(void*)memory.baseMemory);
			switch (size) {
				case 1: MOV(Memory32(Register32.EAX, 0), Register8.CL); break;
				case 2: MOV(Memory32(Register32.EAX, 0), Register16.CX); break;
				case 4: MOV(Memory32(Register32.EAX, 0), Register32.ECX); break;
			}
		}
	}

	void MIPS_LOAD(MipsRegisters rt, MipsRegisters rs, short offset, ReadFunc func) {
		// Address
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		if (offset != 0) ADD(Register32.EAX, cast(int)offset);
		PUSH(Register32.EAX);
		PUSH(Register32.EBX);
		{
			CALL(cast(void*)func);
		}
		ADD(Register32.ESP, 4);
		MIPS_STORE_REGISTER(Register32.EAX, rt);
	}
}