module pspsdk.utils.emits;

import std.string;
import std.c.stdio;
import pspsdk.pspkdebug;

extern (C) {
	void emitInt    (int   v);
	void emitFloat  (float v);
	void emitString (char *v);
	void emitComment(char *v);
	void emitMemoryBlock(void *address, uint size);
	void emitHex(void *address, uint size);
	void emitDString(char[] v) { emitString(toStringz(v)); }
	
	FILE * funopen(
		void *cookie,
		int function(void *, ubyte *, int) readfn,
		int function(void *, ubyte *, int) writefn,
		fpos_t function(void *, fpos_t, int) seekfn,
		int function(void *) closefn
	);
	
	int KprintfWrite(void *cookie, ubyte *ptr, int len) {
		Kprintf("%s", std.string.toStringz(cast(char[])ptr[0..len]));
		//emit(cast(char[])ptr[0..len]);
		return len;
	}
	
	void RedirectOutputToKprintf() {
		stdout = stderr = funopen(null, null, &KprintfWrite, null, null);
		setbuf(stdout, null);
	}
}

void emit(int v) { emitInt(v); }
void emit(float v) { emitFloat(v); }
void emit(char[] v) { emitString(toStringz(v)); }
void emit(ubyte[] v) { emitMemoryBlock(v.ptr, v.length); }
