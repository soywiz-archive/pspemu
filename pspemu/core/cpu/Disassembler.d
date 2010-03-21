module pspemu.core.cpu.Disassembler;

import pspemu.core.Memory;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Switch;
import pspemu.core.cpu.Table;
import pspemu.core.cpu.Registers;

import std.stdio, std.string;

static InstructionDefinition[string] instructionsAvailable;
static bool[string] macros;
static this() {
	// Instruction.
	foreach (instruction; PspInstructions) instructionsAvailable[instruction.name] = instruction;
	//foreach (macro; ["nop", "li"]) macros[macro] = true;
}

class AllegrexDisassembler {
	enum RegistersType { Simple, Symbolic }
	Memory memory;
	RegistersType registersType = RegistersType.Simple;

	this(Memory memory = null) {
		this.memory = memory;
	}

	string getRegister(uint index) {
		index &= 0b_11111;
		switch (registersType) {
			case RegistersType.Simple  : return std.string.format("r%d", index);
			case RegistersType.Symbolic: return Registers.aliasesInv[index];
		}
	}

	string getFloatRegister(uint index) {
		return std.string.format("f%d", index);
	}

	string getImmediate(int value) {
		return std.string.format("%d", value);
	}

	string getImmediateUnsigned(uint value) {
		return std.string.format("0x%04X", value);
	}

	string[] dissasm(Instruction instruction, uint PC) {
		string[] line;
		void detectedInstruction(string op) {
			if (op in instructionsAvailable) {
				InstructionDefinition instructionDefinition = instructionsAvailable[op];
				string fmt = instructionDefinition.fmt;
				line ~= instructionDefinition.name;
				line ~= " ";
				for (int n = 0; n < fmt.length; n++) {
					switch (fmt[n]) {
						case '%':
							switch (fmt[n + 1]) {
								case 'd': line ~= getRegister(instruction.RD); break;
								case 's': line ~= getRegister(instruction.RS); break;
								case 't': line ~= getRegister(instruction.RT); break;
								case 'D': line ~= getFloatRegister(instruction.FD); break;
								case '1':
								case 'S': line ~= getFloatRegister(instruction.FS); break;
								case 'T': line ~= getFloatRegister(instruction.FT); break;
								case 'j': line ~= std.string.format("0x%08X", (instruction.JUMP << 2)); break;
								case 'J': line ~= getRegister(instruction.RS); break;
								case 'i': line ~= getImmediate(instruction.IMM); break;
								case 'I': line ~= getImmediateUnsigned(instruction.IMMU); break;
								case 'C': line ~= std.string.format("0x%05X", instruction.CODE); break;
								case 'o':
									line ~= getImmediate(instruction.IMM);
									line ~= "(";
									line ~= getRegister(instruction.RS);
									line ~= ")";
								break;
								case 'O':
									line ~= std.string.format("0x%08X", PC + 4 + instruction.OFFSET * 4);
								break;
								case 'a':
									line ~= std.string.format("%d", instruction.POS);
								break;
								case 'n':
									switch (fmt[n++ + 2]) {
										case 'e': line ~= std.string.format("%d", instruction.SIZE_E); break;
										case 'i': line ~= std.string.format("%d", instruction.SIZE_I); break;
									}
								break;
								default: {
									writefln("Notice: Unknown format '%s%s' on %s.%s", "%", fmt[n + 1], typeid(typeof(this)), "dissasm");
									line[$ - 1] ~= fmt[n];
									continue;
									//assert(0, format("Unknown format '%s'", fmt[n + 1]));
								}
								/*
								case 'j': instruction.JUMP   = getAbsoluteOffset; break; // 26bit absolute offset
								case 'J': instruction.RS     = getRegister;  break; // register jump
								case 'o': {
								*/
							}
							line ~= "";
							n++;
						break;
						default: {
							line[$ - 1] ~= fmt[n];
						}
					}
				}
				while ((line.length) && (!line[$ - 1].length || (line[$ - 1] == " "))) line = line[0..$ - 1];
			} else {
				line = [std.string.format("<unknown instruction 0x%08X>", instruction.v)];
			}
		}
		static string callDetectedInstruction(string opname) { return "detectedInstruction(\"" ~ (opname) ~ "\");"; }
		mixin(genSwitch(PspInstructions, "callDetectedInstruction"));
		return line;
	}

	string[] dissasm(uint PC, Memory memory = null) {
		if (memory is null) memory = this.memory;
		assert(memory !is null);
		Instruction instruction;
		try {
			instruction.v = memory.read32(PC);
		} catch (MemoryException me) {
			return ["Invalid Address"];
		}
		return dissasm(instruction, PC);
	}

	string dissasmSimple(uint PC, Memory memory = null) {
		return std.string.join(dissasm(PC, memory), "");
	}

	void dump(uint PC, int min = 0, int max = 0, Memory memory = null) {
		assert((PC & 0b11) == 0, "Address not aligned");
		writefln("Disassembler dump (0x%08X, %d, %d) {", PC, min, max);
		for (uint pos = PC + min * 4; pos <= PC + max * 4; pos += 4) {
			writefln("%s%08X: %s", ((pos == PC) ? "->" : "  "), pos, dissasmSimple(pos, memory));
		}
		writefln("}");
	}

	void dumpSimple(uint PC, int min = 0, int max = 0, Memory memory = null) {
		assert((PC & 0b11) == 0, "Address not aligned");
		for (uint pos = PC + min * 4; pos <= PC + max * 4; pos += 4) {
			writef("%s", ((pos == PC) ? "->" : "  "));
			dumpPC(pos, memory);
			writefln("");
		}
	}

	void dumpPC(uint PC, Memory memory = null) {
		writef("%08X: %s", PC, dissasmSimple(PC, memory));
	}
}

version (Unittest):
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Assembler;
import pspemu.utils.Assertion;

unittest {
	auto cpu          = new Cpu();
	auto assembler    = new AllegrexAssembler(cpu.memory);
	auto dissasembler = new AllegrexDisassembler(cpu.memory);

	assembler.assembleBlock(r"
	.text
		addi a0, zero, 7
		halt
	");

	uint start = assembler.segments["text"];

	assertGroup("RegistersType.Simple");
	{
		dissasembler.registersType = AllegrexDisassembler.RegistersType.Simple;
		assertTrue(dissasembler.dissasm(start) == ["addi", " ", "r4", ", ", "r0", ", ", "7"]);
		assertTrue(dissasembler.dissasmSimple(start + 0) == "addi r4, r0, 7", "Check addi");
		assertTrue(dissasembler.dissasmSimple(start + 4) == "halt"          , "Check halt");
	}
	assertGroup("RegistersType.Symbolic");
	{
		dissasembler.registersType = AllegrexDisassembler.RegistersType.Symbolic;
		assertTrue(dissasembler.dissasmSimple(start + 0) == "addi a0, zr, 7", "Check addi");
	}
}

