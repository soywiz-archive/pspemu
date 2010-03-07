module pspemu.core.cpu.InstructionCounter;

import pspemu.utils.Utils;

import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Switch;
import pspemu.core.cpu.Table;

import std.stream, std.stdio, std.string, std.algorithm;

class InstructionCounter {
	struct Pair { string opname; uint count; }
	Pair[string] counts;

	void reset() {
		counts = null;
	}

	void count(string opname) {
		//writefln("opname: %s", opname);
		if ((opname in counts) is null) {
			counts[opname] = Pair(opname, 0);
		}
		counts[opname].count++;
	}

	void count(Instruction instruction) {
		pure static string build(string opname) { return "count(\"" ~ opname ~ "\");"; }
		mixin(genSwitch(PspInstructions, "build"));
	}

	void count(Stream stream) {
		//writefln("size: %d", stream.size);
		while (!stream.eof) {
			count(read!(Instruction)(stream));
		}
	}

	void dump() {
		writefln("InstructionCounter.count {");
		{
			Pair[] list = counts.values.dup;
			sort!("a.count > b.count")(list);
			foreach (pair; list) {
				writefln("  %-8s:%d", pair.opname, pair.count);
			}
		}
		writefln("}");
	}
}

version (unittest):
//static string setCalledArray(string opname) { return "count(\"" ~ opname ~ "\");"; } pragma(msg, genSwitch(PspInstructions, "setCalledArray"));
import pspemu.core.cpu.Assembler;
import pspemu.utils.SparseMemory;
unittest {
	auto memory    = new SparseMemoryStream;
	auto assembler = new AllegrexAssembler(memory);
	auto counter   = new InstructionCounter;

	assembler.assembleBlock(r"
		.text 0x0
		begin:
		addi r1, zero, 1000
		addi r2, zero, 999
		beq r1, r0, begin
		halt
	");

	counter.count(new SliceStream(memory, 0, 4 * Instruction.sizeof));

	assert(counter.counts.length == 3);
	assert(counter.counts["addi"].count == 2);
	assert(counter.counts["beq"].count  == 1);
	assert(counter.counts["halt"].count == 1);
}