module pspsdk.utils.emits;

import std.string;

extern (C):

void emitInt    (int   v);
void emitFloat  (float v);
void emitString (char *v);
void emitComment(char *v);
void emitMemoryBlock(void *address, uint size);
void emitHex(void *address, uint size);
void emitDString(char[] v) { emitString(toStringz(v)); }