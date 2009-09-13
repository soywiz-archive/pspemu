module utils.common;

import std.stream;
import std.string;

version (Windows) {
	pragma(lib, "kernel32.lib");
	import std.c.windows.windows;

	extern (Windows) {
		HGLOBAL LoadResource  (HMODULE hModule, HRSRC hResInfo);
		HRSRC   FindResourceA (HMODULE hModule, LPCTSTR lpName, LPCTSTR lpType);
		DWORD   SizeofResource(HMODULE hModule, HRSRC hResInfo);
	}
	
	ubyte[] MyLoadResource(char[] resname) {
		HRSRC hRsrc = FindResourceA(null, toStringz(resname), cast(char *)0x0A);
		return cast(ubyte[])LoadResource(null, hRsrc)[0..SizeofResource(null, hRsrc)];
	}

	Stream ResourceToStream(char[] resname) {
		return new MemoryStream(MyLoadResource(resname));
	}
}
