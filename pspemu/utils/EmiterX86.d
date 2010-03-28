module pspemu.utils.EmiterX86;

import std.stdio, std.string;

/**
 * Generic emiter that will provide utilities for emiting code, labels and executing it.
 */
abstract class Emiter {
	static struct Label {
		ubyte* address;
	}

	static struct LabelPlaceholder {
		enum Type { Relative, Absolute }
		Type type;
		Label* label;
		ubyte* address;
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

	/**
	 * Create a label with an unknown address that will be setted after.
	 */
	Label* createLabel() {
		return null;
	}

	/**
	 * Sets the address of a label to the current position.
	 */
	void setLabelHere(Label* label) {
	}

	/**
	 * Creates a label placeholder that will be setted with the label address after.
	 */
	LabelPlaceholder* createLabelPlaceholderHere(Label* label, LabelPlaceholder.Type type = LabelPlaceholder.Type.Relative) {
		return null;
	}

	/**
	 * Iterate over all the placeholders writting the address of the associated label.
	 */
	void writeLabels() {
		foreach (ref labelPlaceholder; labelsPlaceholders) {
			*(cast(uint *)labelPlaceholder.address) = labelPlaceholder.label.address - labelPlaceholder.address;
		}
	}

	/**
	 * Write methods for several sizes.
	 */
	void  writem(T)(T d) { *cast(T*)&buffer[bufferPosition] = d; bufferPosition += T.sizeof; }
	alias writem!(ubyte ) write1;
	alias writem!(ushort) write2;
	alias writem!(uint  ) write4;

	uint execute() {
		auto func = cast(uint function())cast(void *)buffer.ptr;
		return func();
	}

	void reset() {
		bufferPosition = 0;
	}
}

/**
 * Emiter that will generate X86 compatible opcodes.
 */
class EmiterX86 : Emiter {
	enum Register32 : ubyte { EAX = 0, ECX = 1, EDX = 2, EBX = 3, ESP = 4, EBP = 5, ESI = 6, EDI = 7 }
	enum Register16 : ubyte {  AX = 0,  CX = 1,  DX = 2,  BX = 3,  SP = 4,  BP = 5,  SI = 6,  DI = 7 }

	// PUSH EAX; PUSH AX;
	void PUSH(Register32 reg) { write1(0x50 | reg); }
	void PUSH(Register16 reg) { write1(0x66); PUSH(cast(Register32)reg); }
	void PUSH(ubyte value   ) { write1(0x6A); write1(value); }
	void PUSH(uint  value   ) { write1(0x68); write4(value); }

	// POP EAX; POP AX;
	void POP (Register32 reg) { write1(0x58 | reg); }
	void POP (Register16 reg) { write1(0x66); POP (cast(Register32)reg); }

	// MOV EAX, 999;
	void MOV (Register32 reg, uint value) { write1(0xB8 | reg); write4(value); }

	// MOV EAX, EAX;
	void MOV (Register32 regTo, Register32 regFrom) { write1(0x89); write4(0xC0 | (regTo << 0) | (regFrom << 3)); }

	// MOV byte ptr [EAX], 1; MOV short ptr [EAX], 1; MOV int ptr [EAX], 1;
	void MOV_TOPTR(Register32 reg, ubyte  value) { write1(0xC6); write1(reg); write1(value); }
	void MOV_TOPTR(Register32 reg, ushort value) { write1(0x66); write1(0xC7); write1(reg); write2(value); }
	void MOV_TOPTR(Register32 reg, uint   value) { write1(0xC7); write1(reg); write4(value); }

	// RET; RET n;
	void RET() { write1(0xC3); }
	void RET(short value) { write1(0xC2); write2(value); }

	// CALL label; JMP label;
	//void CALL(int relative_addr) { write1(0xE8); write4(relative_addr); }

	void CALL(Label* label) { write1(0xE8); createLabelPlaceholderHere(label, LabelPlaceholder.Type.Relative); write4(0); }
	void JMP (Label* label) { write1(0xE9); createLabelPlaceholderHere(label, LabelPlaceholder.Type.Relative); write4(0); }

	// MOV EAX, [EAX + 4];
	void MOV_FROMPTR(Register32 regTo, Register32 regFrom, byte offset) { write1(0x8B); write1(cast(ubyte)((regTo << 0) | (regFrom << 3))); write1(offset); }

	// MOV [EAX + 4], EAX;
	void MOV_TOPTR(Register32 regTo, Register32 regFrom, byte offset) { write1(0x89); write1(cast(ubyte)((regTo << 0) | (regFrom << 3))); write1(offset); }
}

unittest {
	//static void main() { }

	alias EmiterX86.Register32 R32;
	auto emiter = new EmiterX86();

	// Simple test.
	emiter.reset();
	emiter.MOV(R32.EAX, 9876);
	emiter.RET();
	assert(emiter.execute() == 9876);
}