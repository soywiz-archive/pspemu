module jit.EmmiterX86;

public import jit.Emmiter;

enum Gpr8  : ubyte { AL  = 0, CL  = 1, DL  = 2, BL  = 3, AH  = 4, CH  = 5, DH  = 6, BH  = 7 }
enum Gpr16 : ubyte { AX  = 0, CX  = 1, DX  = 2, BX  = 3, SP  = 4, BP  = 5, SI  = 6, DI  = 7 }
enum Gpr32 : ubyte { EAX = 0, ECX = 1, EDX = 2, EBX = 3, ESP = 4, EBP = 5, ESI = 6, EDI = 7 }
enum Mmx   : ubyte { MM0 = 0, MM1 = 1, MM2 = 2, MM3 = 3, MM4 = 4, MM5 = 5, MM6 = 6, MM7 = 7 }

struct Mem32 {
	Gpr32 register;
	int offset;
	bool isBits8() {
		return cast(int)cast(byte)offset == offset;
	}
}

extern (Windows) uint IsDebuggerPresent();

class EmmiterX86 : EmmiterLittleEndian {
	//protected
	
	protected void writePrefix16() { write1(0x66); }
	protected void writePrefix32() { }
	
    protected void writeRefMem32(Mem32 mem, ubyte base = 0x00) {
        if (mem.isBits8) {
            write1(base | 0x70 | mem.register);
            write1(cast(byte)mem.offset);
        } else {
            write1(base | 0xB0 | mem.register);
            write4(mem.offset);
        }
    }
    
    // Utility for [EAX+12]
    void writeGpr32Mem32(Mem32 mem, Gpr32 extra = Gpr32.EAX) {
        if (mem.offset) {
            if (mem.isBits8) {
                write1(cast(ubyte)(0x40 | (mem.register << 0) | (extra << 3)));
                write1(cast(byte)mem.offset);
            } else {
                write1(cast(ubyte)(0x80 | (mem.register << 0) | (extra << 3)));
                write4(mem.offset);
            }
        } else {
            write1(mem.register);
        }
    }

	// PUSH	
    public void PUSH(Gpr32 reg  ) { writePrefix32(); write1(0x50 | reg); }
    public void PUSH(Gpr16 reg  ) { writePrefix16(); write1(0x50 | reg); }
    public void PUSH(ubyte value) { writePrefix32(); write1(0x6A); write1(value); }
    public void PUSH(uint  value) { writePrefix32(); write1(0x68); write4(value); }
    public void PUSH(Mem32 mem  ) { writePrefix32(); write1(0xFF); writeRefMem32(mem); }

	// POP
    public void POP (Gpr32 reg  ) { writePrefix32(); write1(0x58 | reg); }
    
    // PUSHF; POPF;
    public void PUSHF() { writePrefix32(); write1(0x9C); }
    public void POPF () { writePrefix32(); write1(0x9D); }
    
    // RET; RET n;
    void RET()            { writePrefix32(); write1(0xC3); }
    void RET(short value) { writePrefix32(); write1(0xC2); write2(value); }
    
    void OR_AX (ushort value) { writePrefix16(); write1(0x0D); write2(value); }
    void AND_AX(ushort value) { writePrefix16(); write1(0x25); write2(value); }
    void XOR_AX(ushort value) { writePrefix16(); write1(0x35); write2(value); }
    
    // MOV EAX, 999; MOV EAX, EAX;
    void MOV (Gpr32 reg  , uint  value  ) { writePrefix32(); write1(0xB8 | reg); write4(value); }
    void MOV (Gpr32 regTo, Gpr32 regFrom) { writePrefix32(); write1(0x89); write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3))); }
    
    // ADD ESP, 8; ADD EAX, 9999; ADD [EAX + 4], 9999;
    void ADD(Gpr32 reg, byte value) { writePrefix32(); write1(0x83); write1(0xC0 | reg); write1(value); }
    void ADD(Gpr32 reg, int  value) { writePrefix32(); if (reg == Gpr32.EAX) { write1(0x05); } else { write1(0x81); write1(cast(ubyte)(0xC0 | reg)); } write4(value);  }
    void ADD(Mem32 mem, int  value) { writePrefix32(); write1(0x81); writeGpr32Mem32(mem); write4(value); }
    
	void SHL(Gpr32 reg, ubyte displacement) { write1(0xC1); write1(0xE0 | reg); write1(displacement); }

    // CMP EAX, ECX; CMP [EAX+8], 0x77777777; CMP EAX, 1000
    void CMP(Gpr32 l  , Gpr32 r    ) { writePrefix32(); write1(0x39); write1(cast(ubyte)(0xC0 | (l << 0) | (r << 3))); }
    void CMP(Mem32 mem, uint  value) { writePrefix32(); write1(0x81); writeRefMem32(mem, 0x08); write4(value); }
    void CMP(Gpr32 l  , uint  value) {
    	if (l == Gpr32.EAX) {
	    	writePrefix32();
	    	write1(0x3D);
	    	write4(value);
	    } else {
	    	writePrefix32();
	    	write1(0x81);
	    	write1(0xF8 | l);
	    	write4(value);
	    }
    }

	// ?
    void SETL_EAX() { writePrefix32(); MOV(Gpr32.EAX, 0); write1(0x0F); write1(0x9C); write1(0xC2); }

    // CALL label; JMP label;
    //void CALL(int relative_addr) { write1(0xE8); write4(relative_addr); }

    void CALL(ref Label label) { write1(0xE8); writeLabelRelativeAfter4(label); }
    void JMP (ref Label label) { write1(0xE9); writeLabelRelativeAfter4(label); } // Jump
    void JE  (ref Label label) { write1(0x0F); write1(0x84); writeLabelRelativeAfter4(label); } // Jump if Equal
    void JNE (ref Label label) { write1(0x0F); write1(0x85); writeLabelRelativeAfter4(label); } // Jump if Not Equal
    void JNGE(ref Label label) { write1(0x0F); write1(0x8C); writeLabelRelativeAfter4(label); } // Jump if Not Greater or Equal (signed)
    void JGE (ref Label label) { write1(0x0F); write1(0x8D); writeLabelRelativeAfter4(label); } // Jump if Greater or Equal (signed)
    void JE  (uint  value) { write1(0x0F); write1(0x84); write4(value); }
    
    void CALL(Gpr32 reg) { writePrefix32(); write1(0xFF); write1(0xD0 | (reg << 0)); }
    void CALL(void* ptr) { writePrefix32(); MOV(Gpr32.EAX, cast(uint)ptr); CALL(Gpr32.EAX); }

    void ADD(Gpr32 regTo, Gpr32 regFrom) { writePrefix32(); write1(0x01); write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3))); }
    void OR (Gpr32 regTo, Gpr32 regFrom) { writePrefix32(); write1(0x09); write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3))); }
    void AND(Gpr32 regTo, Gpr32 regFrom) { writePrefix32(); write1(0x21); write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3))); }
    void XOR(Gpr32 regTo, Gpr32 regFrom) { writePrefix32(); write1(0x31); write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3))); }

    void DIV (Gpr32 reg) { writePrefix32(); write1(0xF7); write1(cast(ubyte)(0xF0 | reg)); }
    void IDIV(Gpr32 reg) { writePrefix32(); write1(0xF7); write1(cast(ubyte)(0xF8 | reg)); }

    // MOV EAX, [EAX + 4]; MOV [EAX + 4], EAX;
    void MOV(Gpr32 reg, Mem32 mem) { writePrefix32(); write1(0x8B); writeGpr32Mem32(mem, reg); }
    void MOV(Mem32 mem, Gpr32 reg) { writePrefix32(); write1(0x89); writeGpr32Mem32(mem, reg); }
    void MOV(Mem32 mem, Gpr16 reg) { writePrefix16(); write1(0x89); writeGpr32Mem32(mem, cast(Gpr32)reg); }
    void MOV(Mem32 mem, Gpr8  reg) { assert(mem.offset == 0); write1(0x88); write1(cast(ubyte)((mem.register << 0) | (reg << 3))); }

    // TRAP DEBUGGGER. Very useful for debugging generated code.
    // http://faydoc.tripod.com/cpu/int3.htm
    void DEBUGGER_BREAK() {
    	if (IsDebuggerPresent()) INT3();
    }
    void INT3() { write1(0xCC); }

	// ENTER; LEAVE
	void LEAVE() { write1(0xC9); }
	
	void STACK_LEAVE(uint bytes) { ADD(Gpr32.ESP, bytes); }
}