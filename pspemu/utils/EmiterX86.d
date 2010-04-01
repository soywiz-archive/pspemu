module pspemu.utils.EmiterX86;

import std.stdio, std.string;

/**
 * Generic emiter that will provide utilities for emiting code, labels and executing it.
 */
abstract class Emiter {
	static struct Label {
		enum Type { Internal, External }
		Type type;
		uint address;
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
	void writem(T)(T d) {
		if (bufferPosition + T.sizeof >= this.buffer.length) {
			this.buffer.length = this.buffer.length * 2;
		}
		*cast(T*)&buffer[bufferPosition] = d;
		bufferPosition += T.sizeof;
	}
	alias writem!(ubyte ) write1;
	alias writem!(ushort) write2;
	alias writem!(uint  ) write4;
	
	/*void write1(uint v) {
		write1(cast(ubyte)v);
	}*/

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
	void MOV (Register32 regTo, Register32 regFrom) { write1(0x89); write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3))); }

	// MOV byte ptr [EAX], 1; MOV short ptr [EAX], 1; MOV int ptr [EAX], 1;
	void MOV_TOPTR(Register32 reg, ubyte  value) { write1(0xC6); write1(reg); write1(value); }
	void MOV_TOPTR(Register32 reg, ushort value) { write1(0x66); write1(0xC7); write1(reg); write2(value); }
	void MOV_TOPTR(Register32 reg, uint   value) { write1(0xC7); write1(reg); write4(value); }
	
	// MOV int ptr [EAX+4], 1;
	void MOV_TOPTR(Register32 reg, uint   value, byte offset) { write1(0xC7); write1(0x40 | reg); write1(cast(ubyte)offset); write4(value); }

	// RET; RET n;
	void RET() { write1(0xC3); }
	void RET(short value) { write1(0xC2); write2(value); }

	void OR_AX(ushort value) {
		write1(0x66);
		write1(0x0D);
		write2(value);
	}
	
	void ADD_EAX(uint value) {
		write1(0x05);
		write4(value);
	}

	// ADD ESP, 8
	void ADD(Register32 reg, byte value) {
		write1(0x83);
		write1(0xC0 | reg);
		write1(value);
	}

	void SHL(Register32 reg, ubyte displacement) {
		write1(0xC1);
		write1(0xE0 | reg);
		write1(displacement);
	}

	// TRAP DEBUGGGER
	// http://faydoc.tripod.com/cpu/int3.htm
	// Very useful for debugging generated code.
	void INT3() {
		write1(0xCC);
	}

	// CMP EAX, ECX
	void CMP(Register32 l, Register32 r) {
		write1(0x39);
		write1(cast(ubyte)(0xC0 | (l << 0) | (r << 3)));
	}

	// CMP EAX, 1000
	void CMP(Register32 l, uint v) {
		write1(0x3D);
		write4(v);
	}

	// CALL label; JMP label;
	//void CALL(int relative_addr) { write1(0xE8); write4(relative_addr); }

	void CALL(Label* label) { write1(0xE8); createLabelPlaceholderHere(label, LabelPlaceholder.Type.Relative); write4(0); }
	void JMP (Label* label) { write1(0xE9); createLabelPlaceholderHere(label, LabelPlaceholder.Type.Relative); write4(0); }
	void JNE (Label* label) { write1(0x0F); write1(0x85); createLabelPlaceholderHere(label, LabelPlaceholder.Type.Relative); write4(0); }
	void JE  (uint v) { write1(0x0F); write1(0x84); write4(v); }
	
	void CALL(Register32 reg) { write1(0xFF); write1(0xD0 | (reg << 0)); }

	void ADD (Register32 regTo, Register32 regFrom) {
		write1(0x01);
		write1(cast(ubyte)(0xC0 | (regTo << 0) | (regFrom << 3)));
	}

	// MOV EAX, [EAX + 4];
	void MOV_FROMPTR(Register32 regTo, Register32 regFrom, byte offset) { write1(0x8B); write1(cast(ubyte)(0x40 | (regTo << 0) | (regFrom << 3))); write1(offset); }

	// MOV [EAX + 4], EAX;
	void MOV_TOPTR(Register32 regTo, Register32 regFrom, byte offset) { write1(0x89); write1(cast(ubyte)(0x40 | (regTo << 0) | (regFrom << 3))); write1(offset); }
}

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