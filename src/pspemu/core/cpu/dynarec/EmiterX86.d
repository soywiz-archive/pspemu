module pspemu.core.cpu.dynarec.EmiterX86;

import std.stdio, std.string;

/**
 * Generic emiter that will provide utilities for emiting code, labels and executing it.
 */
abstract class Emiter {
	static struct Label {
		enum Type { Internal, External }
		Type type;
		uint address = -1;
	}

	static struct LabelPlaceholder {
		enum Type { Relative, Absolute }
		Type type;
		Label* label;
		uint address;
	}
	
	ubyte[] buffer;
	uint bufferPosition;

	Label[] labels;
	LabelPlaceholder[] labelsPlaceholders;
	
	this(uint bufferSize) {
		this.buffer.length = bufferSize;
		reset();
	}
	
	this() {
		this(1024);
	}

	ubyte[] writedCode() {
		writeLabels();
		return buffer[0..bufferPosition];
	}

	/**
	 * Create a label with an unknown address that will be setted after.
	 */
	Label* createLabel() {
		labels ~= Label();
		return &labels[$ - 1];
	}

	/**
	 * Create a label with an unknown address that will be setted after.
	 */
	Label* createLabelAndSetHere() {
		auto label = createLabel;
		setLabelHere(label);
		return label;
	}

	Label* createLabelToFunction(void* ptr) {
		auto label = createLabel;
		label.type = Label.Type.External;
		label.address = cast(uint)ptr;
		return label;
	}

	/**
	 * Sets the address of a label to the current position.
	 */
	void setLabelHere(Label* label) {
		label.type = Label.Type.Internal;
		label.address = bufferPosition;
	}

	/**
	 * Creates a label placeholder that will be setted with the label address after.
	 */
	LabelPlaceholder* createLabelPlaceholderHere(Label* label, LabelPlaceholder.Type type = LabelPlaceholder.Type.Relative) {
		labelsPlaceholders ~= LabelPlaceholder(type, label, bufferPosition);
		return &labelsPlaceholders[$ - 1];
	}

	/**
	 * Iterate over all the placeholders writting the address of the associated label.
	 */
	void writeLabels() {
		foreach (ref labelPlaceholder; labelsPlaceholders) {
			auto label = labelPlaceholder.label;
			uint labelAddress = (label.type == Label.Type.Internal) ? (cast(uint)buffer.ptr + label.address) : label.address;
			uint placeholderAddress = cast(uint)buffer.ptr + labelPlaceholder.address;
			*cast(uint *)placeholderAddress = labelAddress - placeholderAddress - 4;
		}
	}

	/**
	 * Write methods for several sizes.
	 */
	void writem(Type)(Type d) {
		if (bufferPosition + Type.sizeof >= this.buffer.length) {
			this.buffer.length = this.buffer.length * 2;
		}
		*cast(Type*)&buffer[bufferPosition] = d;
		bufferPosition += Type.sizeof;
	}
	alias writem!(ubyte ) write1;
	alias writem!(ushort) write2;
	alias writem!(uint  ) write4;
	
	uint execute() {
		auto func = cast(uint function())cast(void *)buffer.ptr;
		writeLabels();
		return func();
	}

	void reset() {
		bufferPosition = 0;
	}
}

/**
 * Emiter that will generate X86 compatible opcodes.
 *
 * @see http://home.comcast.net/~fbui/intel.html
 * @see http://faydoc.tripod.com/cpu/index_a.htm
 */
class EmiterX86 : Emiter {
	enum Register32 : ubyte { EAX = 0, ECX = 1, EDX = 2, EBX = 3, ESP = 4, EBP = 5, ESI = 6, EDI = 7 }
	enum Register16 : ubyte {  AX = 0,  CX = 1,  DX = 2,  BX = 3,  SP = 4,  BP = 5,  SI = 6,  DI = 7 }
	enum Register8  : ubyte {  AL = 0,  CL = 1,  DL = 2,  BL = 3,  AH = 4,  CH = 5,  DH = 6,  BH = 7 }
	static struct Memory32 { Register32 register; int offset; bool isBits8() { return cast(int)cast(byte)offset == offset; } }

	void write16bits() { write1(0x66); }

	void refMemory32(Memory32 mem, ubyte base = 0x00) {
		if (mem.isBits8) {
			write1(base | 0x70 | mem.register);
			write1(cast(byte)mem.offset);
		} else {
			write1(base | 0xB0 | mem.register);
			write4(mem.offset);
		}
	}

	// PUSH EAX; PUSH AX; PUSH 1; PUSH 999;
	// POP EAX; POP AX;
	void PUSH(Register32 reg) { write1(0x50 | reg); }
	void PUSH(Register16 reg) { write16bits(); PUSH(cast(Register32)reg); }
	void PUSH(ubyte value   ) { write1(0x6A); write1(value); }
	void PUSH(uint  value   ) { write1(0x68); write4(value); }
	void PUSH(Memory32 mem  ) { write1(0xFF); refMemory32(mem); }
	void POP(Register32 reg) { write1(0x58 | reg); }
	void POP(Register16 reg) { write16bits(); POP(cast(Register32)reg); }

	// PUSHF; POPF;
	void PUSHF() { write1(0x9C); }
	void POPF() { write1(0x9D); }

	// MOV EAX, 999; MOV EAX, EAX;
	void MOV (Register32 reg, uint value) { write1(0xB8 | reg); write4(value); }
	void MOV (Register32 regTo, Register32 regFrom) { write1(0x89); write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3))); }

	// Utility for [EAX+12]
	void writeMemory32(Memory32 mem, Register32 extra = Register32.EAX) {
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

	// MOV byte ptr [EAX+12], 1; MOV short ptr [EAX+8], 1; MOV int ptr [EAX+4], 1;
	void MOV(Memory32 mem, ubyte  value) { write1(0xC6); writeMemory32(mem); write1(value); }
	void MOV(Memory32 mem, ushort value) { write16bits(); write1(0xC7); writeMemory32(mem); write2(value); }
	void MOV(Memory32 mem, uint   value) { write1(0xC7); writeMemory32(mem); write4(value); }
	
	// RET; RET n;
	void RET() { write1(0xC3); }
	void RET(short value) { write1(0xC2); write2(value); }

	void OR_AX (ushort value) { write16bits(); write1(0x0D); write2(value); }
	void AND_AX(ushort value) { write16bits(); write1(0x25); write2(value); }
	void XOR_AX(ushort value) { write16bits(); write1(0x35); write2(value); }
	
	// ADD ESP, 8; ADD EAX, 9999; ADD [EAX + 4], 9999;
	void ADD(Register32 reg, byte value) { write1(0x83); write1(0xC0 | reg); write1(value); }
	void ADD(Register32 reg, int value) { if (reg == Register32.EAX) { write1(0x05); } else { write1(0x81); write1(cast(ubyte)(0xC0 | reg)); } write4(value);  }
	void ADD(Memory32 mem, int value) { write1(0x81); writeMemory32(mem); write4(value); }
	
	void SHL(Register32 reg, ubyte displacement) {
		write1(0xC1);
		write1(0xE0 | reg);
		write1(displacement);
	}

	// TRAP DEBUGGGER. Very useful for debugging generated code.
	// http://faydoc.tripod.com/cpu/int3.htm
	void INT3() { write1(0xCC); }

	// CMP EAX, ECX
	void CMP(Register32 l, Register32 r) {
		write1(0x39);
		write1(cast(ubyte)(0xC0 | (l << 0) | (r << 3)));
	}
	
	// CMP [EAX+8], 0x77777777
	void CMP(Memory32 mem, uint value) {
		write1(0x81);
		refMemory32(mem, 0x08);
		write4(value);
	}

	// CMP EAX, 1000
	void CMP(Register32 l, uint v) {
		write1(0x3D);
		write4(v);
	}

	void SETL_EAX() {
		MOV(Register32.EAX, 0);
		write1(0x0F);
		write1(0x9C);
		write1(0xC2);
	}

	// CALL label; JMP label;
	//void CALL(int relative_addr) { write1(0xE8); write4(relative_addr); }

	void CALL(Label* label) { write1(0xE8); createLabelPlaceholderHere(label, LabelPlaceholder.Type.Relative); write4(0); }
	void JMP (Label* label) { write1(0xE9); createLabelPlaceholderHere(label, LabelPlaceholder.Type.Relative); write4(0); } // Jump
	void JE  (Label* label) { write1(0x0F); write1(0x84); createLabelPlaceholderHere(label, LabelPlaceholder.Type.Relative); write4(0); } // Jump if Equal
	void JNE (Label* label) { write1(0x0F); write1(0x85); createLabelPlaceholderHere(label, LabelPlaceholder.Type.Relative); write4(0); } // Jump if Not Equal
	void JNGE(Label* label) { write1(0x0F); write1(0x8C); createLabelPlaceholderHere(label, LabelPlaceholder.Type.Relative); write4(0); } // Jump if Not Greater or Equal (signed)
	void JGE (Label* label) { write1(0x0F); write1(0x8D); createLabelPlaceholderHere(label, LabelPlaceholder.Type.Relative); write4(0); } // Jump if Greater or Equal (signed)
	void JE  (uint v) { write1(0x0F); write1(0x84); write4(v); }
	
	void CALL(Register32 reg) { write1(0xFF); write1(0xD0 | (reg << 0)); }
	void CALL(void* func) { MOV(Register32.EAX, cast(uint)func); CALL(Register32.EAX); }

	void ADD (Register32 regTo, Register32 regFrom) {
		write1(0x01);
		write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3)));
	}
	void OR (Register32 regTo, Register32 regFrom) { write1(0x09); write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3))); }
	void AND(Register32 regTo, Register32 regFrom) { write1(0x21); write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3))); }
	void XOR(Register32 regTo, Register32 regFrom) { write1(0x31); write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3))); }

	void DIV(Register32 reg) {
		write1(0xF7);
		write1(cast(ubyte)(0xF0 | reg));
	}

	void IDIV(Register32 reg) {
		write1(0xF7);
		write1(cast(ubyte)(0xF8 | reg));
	}

	// MOV EAX, [EAX + 4]; MOV [EAX + 4], EAX;
	void MOV(Register32 reg, Memory32 mem) { write1(0x8B); writeMemory32(mem, reg); }
	void MOV(Memory32 mem, Register16 reg) { write16bits(); MOV(mem, cast(Register32)reg); }
	void MOV(Memory32 mem, Register32 reg) { write1(0x89); writeMemory32(mem, reg); }
	
	void MOV(Memory32 mem, Register8 reg) {
		assert(mem.offset == 0);
		write1(0x88);
		write1(cast(ubyte)((mem.register << 0) | (reg << 3)));
	}
}
/*
unittest {
	//static void main() { }

	alias EmiterX86.Register32 R32;
	auto emiter = new EmiterX86();

	// Simple test.
	emiter.reset();
	//emiter.MOV(R32.EAX, 9876);
	emiter.MOV(R32.EAX, 0);
	emiter.MOV(R32.ECX, 9876);
	auto loop_write = emiter.createLabelAndSetHere();
	emiter.ADD_EAX(+1);
	emiter.CMP(R32.EAX, R32.ECX);
	emiter.JNE(loop_write);
	emiter.RET();
	
	emiter.writeLabels();
	
	//std.file.write("test.bin", emiter.writedCode); writefln("%s", emiter.writedCode);
	
	assert(emiter.execute() == 9876);
}
*/