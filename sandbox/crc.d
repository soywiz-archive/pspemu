import std.stdio, std.zlib;

void main() {
	writefln("%08X", crc32(0, cast(ubyte[])"\0"));
}