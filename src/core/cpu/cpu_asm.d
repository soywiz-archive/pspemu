module pspemu.core.cpu.cpu_asm;

import pspemu.utils.sparse_memory;
import pspemu.utils.expression;

import pspemu.core.memory;
import pspemu.core.cpu.instruction;
import pspemu.core.cpu.cpu_switch;
import pspemu.core.cpu.cpu_table;
import pspemu.core.cpu.registers;

import std.stdio, std.string, std.stream, std.regexp, std.traits;

static InstructionDefinition[string] instructions;
static bool[string] macros;
static this() {
	// Instruction.
	foreach (instruction; PspInstructions) instructions[instruction.name] = instruction;
	//foreach (macro; ["nop", "li"]) macros[macro] = true;
}

interface ISymbolResolver {
	bool hasSymbol(string name);
	uint getSymbolAddress(string name);
	void symbolDump();
}

template AllegrexAssemblerSymbolTemplate() {
	bool hasSymbol(string symbolName) {
		return (symbolName in labels) !is null;
	}

	uint getSymbolAddress(string symbolName) {
		return labels[symbolName];
	}

	void symbolDump() {
		.writefln("Symbols {");
		foreach (symbolName, address; labels) {
			writefln("  '%s' : 0x%08X", symbolName, address);
		}
		.writefln("}");
	}
}

// http://en.wikibooks.org/wiki/MIPS_Assembly/MIPS_Instructions
class AllegrexAssembler : ISymbolResolver {
	Stream stream;
	uint[string] labels;
	uint[string] segments;
	Reloc[] relocs;
	
	mixin AllegrexAssemblerSymbolTemplate;

	// FIXME: We should reuse this struct/class. See formats.elf.
	static struct Reloc {
		enum Type : byte { None = 0, Mips16, Mips32, MipsRel32, Mips26, MipsHi16, MipsLo16, MipsGpRel16, MipsLiteral, MipsGot16, MipsPc16, MipsCall16, MipsGpRel32 }

		Type   type;
		string symbolName;
		uint   address;

		string toString() {
			return std.string.format("Reloc(%d, '%s', 0x%08X)", type, symbolName, address);
		}

		void relocate(Stream stream, ISymbolResolver symbolResolver) {
			Instruction instruction;

			assert(symbolResolver.hasSymbol(symbolName), format("Symbol '%s' not found.", symbolName));
			uint symbolAddress = symbolResolver.getSymbolAddress(symbolName);

			void readInstruction () { stream.position = address; stream.read (instruction.v); }
			void writeInstruction() { stream.position = address; stream.write(instruction.v); }

			switch (type) {
				case Type.MipsPc16:
					readInstruction();
					instruction.IMM  = cast(short)((symbolAddress - address - 4) >> 2); // FIXME: Check overflow.
					writeInstruction();
				break;
				case Type.Mips26:
					readInstruction();
					instruction.JUMP = cast(int)((symbolAddress & ~0x_F0000000) >> 2); // FIXME: Check overflow.
					writeInstruction();
				break;
			}
		}
	}
	
	this() {
		stream = new SparseMemoryStream;
	}

	this(Stream stream) {
		this.stream = stream;
	}

	void reset() {
		labels = null;
		segments = null;
		relocs = [];
	}

	void startSegment(string segmentName, uint position) {
		segments[segmentName] = position;
		stream.position = position;
		//writefln("startSegment('%s')", segmentName);
	}

	void addReloc(Reloc reloc) {
		relocs ~= reloc;
	}

	bool assembleInternal(uint PC, string line, ref Instruction instruction) {
		// Non empty line.
		if (line.length > 0) {
			//writefln("  '%s'", line);
			auto regexp = new RegExp(r"^(\w+)\s*(.*)$", "");
			auto parts = regexp.match(line);
			string instructionName   = parts[1];
			string instructionParams = parts[2];

			// Obtain instruction.
			assert(instructionName in instructions, format("Can't assemble unknown instruction '%s'", instructionName));
			auto instructionDefinition = instructions[instructionName];

			auto paramTypes    = getParams(instructionDefinition.fmt);
			auto paramMatches  = RegExp(getPattern(instructionDefinition.fmt)).match(instructionParams);

			// Fix empty parameters.
			if (instructionParams == "") paramMatches ~= "";

			assert(paramMatches.length > 1, format("instruction:'%s'; params:'%s'; pattern:'%s'", instructionName, instructionParams, getPattern(instructionDefinition.fmt)));
			auto paramValues   = paramMatches[1..$];

			instruction.v = instructionDefinition.opcode & instructionDefinition.mask;

			foreach (n; 0..paramTypes.length) {
				auto paramType = paramTypes[n], paramValue = paramValues[n];
				uint getRegister() {
					return cast(uint)Registers.getAlias(paramValue);
				}
				uint getImmediate(bool signed) {
					scope value = parseString(paramValue);
					if (signed) {
						scope values = cast(short)value;
						assert(values >= cast(short) (1 << 15));
						assert(values <  cast(short)~(1 << 15));
					} else {
						scope valueu = cast(ushort)value;
						assert(valueu >= 0);
						assert(valueu < 0x1_0000);
					}
					return cast(uint)value;
				}
				uint getOffset() {
					//writefln("OFFSET: %08X", PC);
					addReloc(Reloc(Reloc.Type.MipsPc16, paramValue, PC));
					return 0;
				}
				uint getAbsoluteOffset() {
					//writefln("OFFSET: %08X", PC);
					addReloc(Reloc(Reloc.Type.Mips26, paramValue, PC));
					return 0;
				}
				switch (paramType) {
					// Register.
					case "%d" : instruction.RD     = getRegister;  break; // Rd
					case "%s" : instruction.RS     = getRegister;  break; // Rs
					case "%t" : instruction.RT     = getRegister;  break; // Rt
					case "%i" : instruction.IMM    = getImmediate(true); break; // 16bit signed immediate
					case "%I" : instruction.IMMU   = getImmediate(false); break; // 16bit unsigned immediate (always printed in hex)
					case "%O" : instruction.OFFSET = getOffset;    break; // 16bit signed offset (PC relative)
					case "%j" : instruction.JUMP   = getAbsoluteOffset; break; // 26bit absolute offset
					case "%J" : instruction.RS     = getRegister;  break; // register jump
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
		pattern = replace(pattern, " ", r"\s+");
		pattern = RegExp(r"%\w+", "g").replace(pattern, r"([\d\w\-\+\_]+)");
		return '^' ~ pattern ~ "$";
	}

	static string stripComments(string line) {
		int index = std.string.indexOf(line, ';');
		if (index == -1) index = line.length;
		return strip(line[0..index]);
	}

	static void parseLine(string line, out string label, out string operation) {
		line = stripComments(line);

		int index = std.string.indexOf(line, ':');
		if (index == -1) {
			label = null;
			operation = line;
		} else {
			label     = strip(line[0..index]);
			operation = strip(line[index + 1..$]);
		}
	}

	// Returns true if writted something.
	bool assemble(ref uint PC, ref Instruction instruction, string line) {
		// Clean line. Strip comments and spaces.
		string labelName, operation;

		parseLine(line, labelName, operation);

		// Extract label.
		if (labelName != null) {
			if (labelName.length) {
				assert((labelName in labels) is null, format("Label '%s' already defined", labelName));
				labels[labelName] = (PC = cast(uint)stream.position);
			}
		}
		if (operation.length) {
			
			// Directives.
			if (operation[0] == '.') {
				scope parts = RegExp(r"^(\w+)\s*(.*)$").match(operation[1..$]);

				switch (parts[1]) {
					// Sections.
					case "text", "data": {
						scope const defaults = ["text" : Memory.mainMemoryAddress, "data" : Memory.mainMemoryAddress | 0x80000]; // FIXME
						auto segmentName = strip(parts[1]), segmentAddress = strip(parts[2]);

						startSegment(
							segmentName,
							PC = cast(uint)parseString(segmentAddress, defaults[segmentName])
						);
					} break;
				}
				return false;
			}

			if (assembleInternal(PC = cast(uint)stream.position, operation, instruction)) {
				//writefln("%08X: %08X", stream.position, instruction.v);
				stream.write(instruction.v);
				return true;
			}
		}
		return false;
	}

	bool assemble(string line) {
		Instruction instruction;
		uint PC;
		return assemble(PC, instruction, line);
	}

	// FIXME: Rename relocate to something like 'address fixing'. Because it's not really relocation.
	void relocate() {
		foreach (reloc; relocs) reloc.relocate(stream, this);
		relocs = [];
	}

	void assembleBlock(string block) {
		foreach (line; splitlines(block)) assemble(line);
		relocate();
	}

	alias assemble opCall;
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");

	scope assembler = new AllegrexAssembler;
	uint PC; Instruction instruction;

	ReturnType!(assembler.opCall) assembler_(string line) { return assembler(PC, instruction, line); }
	
	assembler.startSegment("text", 0x2000); assert((assembler.stream.position == 0x2000));

	assembler_("halt"); // Instruction without parameters.
	assembler_("lui r1, 0x_000F");
	assembler_(";"); // Tests empty comment.
	assembler_(".data ;"); // Tests empty comment with instruction before.
	assembler_("label: .data ;"); // Tests empty comment with instruction before.

	try {
		assembler_("jal ra, loop;"); // Tests an instruction with more parameters.
		assert(0);
	} catch {
	}

	assembler_(".text 0x1000        "); assert((PC == 0x1000));
	assembler_("; comment           "); assert((PC == 0x1000));
	assembler_("	addi a0, zero, 1 ; this is a comment"); assert((PC == 0x1000) && (instruction.v == 0x_20040001));
	assembler_("loop:               "); assert((PC == 0x1004));
	assembler_("  addi a1, zero, 2  "); assert((PC == 0x1004) && (instruction.v == 0x_20050002));
	assembler_("  add v0, a0, a1    "); assert((PC == 0x1008) && (instruction.v == 0x_00851020));
	assembler_("  addi v0, v0, -2   "); assert((PC == 0x100C) && (instruction.v == 0x_2042FFFE));
	assembler_("  beq  v0, v0, loop "); assert((PC == 0x1010) && (instruction.v == 0x_10420000));
	assembler.relocate();

	// Check relocations.
	assembler.stream.position = 0x1010;
	assembler.stream.read(instruction.v);
	assert(instruction.v == 0x_1042FFFC);
	
}
