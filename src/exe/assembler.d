import pspemu.core.cpu.cpu_asm;
import pspemu.utils.sparse_memory;

import std.stdio;
import std.string;
import std.getopt;

int main(string[] args) {
	auto memory = new SparseMemoryStream;
	auto assembler = new AllegrexAssembler(memory);

	void help() {
		writefln("MIPS ASSEMBLER");
		writefln("");
		writefln("mipsasm.exe <file.asm>");
	}

	void compile(string fileName) {
		assembler.assembleBlock(
			cast(string)std.file.read(fileName)
		);
	}
	
	string mipsVersion;

	getopt(args,
		"version", &mipsVersion
	);

	if (args.length) {
		foreach (fileName; args[1..$]) {
			writef("Compiling file '%s'...", fileName);
			compile(fileName);
			writefln("Ok");
		}
		memory.smartDump();
	} else {
		help();
		return -1;
	}
	
	return 0;
}