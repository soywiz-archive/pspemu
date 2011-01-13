module pspsdk.utils.emits;

import std.string;

extern (C) {
	void emitInt    (int   v);
	void emitFloat  (float v);
	void emitString (char *v);
	void emitComment(char *v);
	void emitMemoryBlock(void *address, uint size);
	void emitHex(void *address, uint size);
	void emitDString(char[] v) { emitString(toStringz(v)); }
}

void emit(int v) { emitInt(v); }
void emit(float v) { emitFloat(v); }
void emit(char[] v) { emitString(toStringz(v)); }
void emit(ubyte[] v) { emitMemoryBlock(v.ptr, v.length); }