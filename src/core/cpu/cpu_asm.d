module pspemu.core.cpu.cpu_asm;

import pspemu.utils.sparse_memory;
import pspemu.utils.expression;

import pspemu.core.cpu.instruction;
import pspemu.core.cpu.cpu_switch;
import pspemu.core.cpu.cpu_table;
import pspemu.core.cpu.registers;

import std.stdio, std.string, std.stream, std.regexp;

static InstructionDefinition[string] instructions;
static this() {
	// Instruction.
	foreach (instruction; PspInstructions) instructions[instruction.name] = instruction;
}

class AllegrexAssembler {
	Stream stream;
	uint[string] labels;
	uint[string] segments;
	
	this() {
		stream = new SparseMemoryStream;
	}

	this(Stream stream) {
		this.stream = stream;
	}

	void startSegment(string name, uint position) {
		segments[name] = position;
		stream.position = position;
	}

	bool assembleInternal(uint PC, string line, ref Instruction instruction) {
		// Clean line.
		{
			int commentPos = indexOf(line, ';');
			if (commentPos != -1) line = line[0..commentPos];
			line = strip(line);
		}

		// Non empty line.
		if (line.length > 0) {
			auto regexp = new RegExp(r"^(\w+)\s*(.*)$", "");
			auto parts = regexp.match(line);
			string instructionName   = parts[1];
			string instructionParams = parts[2];
			auto instructionDefinition = instructions[instructionName];
			auto parseParams = new RegExp(getPattern(instructionDefinition.fmt), "");
			auto paramTypes = getParams(instructionDefinition.fmt);
			auto paramValues = parseParams.match(instructionParams)[1..$];

			instruction.v = instructionDefinition.opcode & instructionDefinition.mask;

			foreach (n; 0..paramTypes.length) {
				auto paramType = paramTypes[n]; auto paramValue = paramValues[n];
				uint getRegister() { return cast(uint)registerAliases[paramValue]; }
				long getLiteral() { return parseString(paramValue); }
				switch (paramType) {
					// Register.
					case "%d"  : instruction.RD  = getRegister; break;
					case "%s"  : instruction.RS  = getRegister; break;
					case "%t"  : instruction.RT  = getRegister; break;
					case "%imm": instruction.IMM = cast(uint)getLiteral;  break;
				}
			}

			return true;
		}
		return false;
	}

	static string[] getParams(string pattern) {
		auto regexp = new RegExp(r"%\w+", "g");
		return regexp.match(pattern);
	}

	static string getPattern(string pattern) {
		auto regexp = new RegExp(r"%\w+", "g");
		pattern = replace(pattern, " ", r"\s+");
		pattern = regexp.replace(pattern, r"([\d\w\-]+)");
		return pattern;
	}

	bool assemble(ref uint PC, ref Instruction instruction, string line) {
		bool writted = assembleInternal(PC = cast(uint)stream.position, line, instruction);
		if (writted) {
			//writefln("%08X: %08X", stream.position, instruction.v);
			stream.write(instruction.v);
		}
		return writted;
	}

	bool assemble(string line) {
		Instruction instruction;
		uint PC;
		return assemble(PC, instruction, line);
	}
}

unittest {
	writefln("Unittesting: core.cpu.cpu_asm...");

	scope assembler = new AllegrexAssembler;
	uint PC; Instruction instruction;
	
	assembler.startSegment("code", 0x1000);
	assembler.assemble(PC, instruction, "addi a0, zero, 1"); assert((PC == 0x1000) && (instruction.v == 0x_20040001));
	assembler.assemble(PC, instruction, "addi a1, zero, 2"); assert((PC == 0x1004) && (instruction.v == 0x_20050002));
	assembler.assemble(PC, instruction, "add v0, a0, a1  "); assert((PC == 0x1008) && (instruction.v == 0x_00851020));
	assembler.assemble(PC, instruction, "addi v0, v0, -2 "); assert((PC == 0x100C) && (instruction.v == 0x_2042FFFE));
}
