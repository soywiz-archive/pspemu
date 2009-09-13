module kernel.common;

ubyte  read1(Stream s) { ubyte  v; s.read(v); return v; }
ushort read2(Stream s) { ushort v; s.read(v); return v; }
uint   read4(Stream s) { uint   v; s.read(v); return v; }

//template readStruct(T) { T readStruct(Stream s, inout T t) { return (cast(ubyte *)&t)[0..T.sizeof]; } }