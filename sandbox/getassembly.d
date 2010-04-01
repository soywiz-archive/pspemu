import std.stdio, std.string;

// cls && dmd -run getassembly.d

void test_start() {
	asm {
		naked;

		//EAX = 0, ECX = 1, EDX = 2, EBX = 3, ESP = 4, EBP = 5, ESI = 6, EDI = 7
		//add EDI, EDI;
		//push 999;
		//shl EDI, 16;
		//add EAX, 0xFFFFF;
		//mov [EDI + 4], 0x77777777;
		//mov [ECX + 0], [ECX + 4];
		//push int ptr [ECX + 4];
		
		//mov EDX, 0x77777777;
		//jne test_end;
		label2:;
		je test_end;
		ret;
		//add EAX, 8;
		/*
		cmp EAX, EDI;
		cmp EDI, EAX;
		*/
		//cmp EAX, E;
		/*
		call EAX;
		call ECX;
		call EDX;
		call EBX;
		call ESP;
		call EDI;
		*/
		
		/*
		mov [EAX + 4], EAX;
		mov EAX, [EAX + 4];
		jmp test_end;
		mov EDI, EAX;
		mov ECX, EAX;
		mov EDX, ESI;
		*/

		/*
		mov int ptr [EAX], 1;
		mov int ptr [ECX], 1;
		mov int ptr [EDX], 1;
		mov int ptr [EBX], 1;
		mov int ptr [ESP], 1;
		mov int ptr [EBP], 1;
		mov int ptr [ESI], 1;
		mov int ptr [EDI], 1;
		*/

		// Detect end.
		db 0x77, 0xFF, 0xFE, 0xFD, 0x77;
	}
}
void test_end() { }

void main() {
	auto test_start = cast(ubyte *)&test_start;
	auto test_end   = cast(ubyte *)&test_end;
	auto test_array = test_start[0..test_end - test_start];
	
	int index = std.string.indexOf(cast(char[])test_array, cast(char[])[0x77, 0xFF, 0xFE, 0xFD, 0x77]);
	
	/*
	foreach (v; test_start[0..index]) writef("%02X ", v); writefln("");
	foreach (v; test_start[0..index]) writefln("%08b ", v);
	*/

	foreach (v; test_start[0..index]) writefln("%02X: %08b ", v, v);
}