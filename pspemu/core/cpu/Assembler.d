module pspemu.core.cpu.Assembler;

import pspemu.utils.SparseMemory;
import pspemu.utils.Expression;
import pspemu.utils.Utils;

import pspemu.core.Memory;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Switch;
import pspemu.core.cpu.Table;
import pspemu.core.cpu.Registers;

import std.stdio, std.string, std.stream, std.regexp, std.traits, std.conv;

static InstructionDefinition[string] instructionsAvailable;
static bool[string] macros;
static this() {
	// Instruction.
	foreach (instruction; PspInstructions) instructionsAvailable[instruction.name] = instruction;
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
		assert(symbolName in labels, std.string.format("Can't find '%s'", symbolName));
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

			void readInstruction () {
				stream.position = address;
				try {
					stream.read(instruction.v);
				} catch {
					assert(0, format("Can't read 4 bytes from address 0x%08X | %s", address, this));
				}
			}
			void writeInstruction() {
				stream.position = address;
				stream.write(instruction.v);
			}

			//writefln("fixAddress: 0x%08X, symbolAddress: 0x%08X", address, symbolAddress);
			switch (type) {
				case Type.MipsLo16:
					readInstruction();
					instruction.IMMU = cast(ushort)((symbolAddress >>  0) & 0xFFFF);
					writeInstruction();
				break;
				case Type.MipsHi16:
					readInstruction();
					instruction.IMMU = cast(ushort)((symbolAddress >> 16) & 0xFFFF);
					writeInstruction();
				break;
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

	private Instruction[] assembleInternal(ref uint PC, string line) {
		//writefln("%s", line);
		// Non empty line.
		if (line.length > 0) {
			//writefln("  '%s'", line);
			auto regexp = new RegExp(r"^([\w\.]+)\s*(.*)$", "");
			auto parts = regexp.match(line);
			string instructionName   = parts[1];
			string instructionParams = parts[2];

			// Check macro
			switch (instructionName) {
				case "la": {
					scope params = RegExp(getPattern("%s, %s")).match(instructionParams);
					assert(params.length == 3);
					//scope value = getSymbolAddress(params[2]);
					
					uint PC_BASE = PC;

					// TODO. If we already know where the label is, we could maybe remove the ori.
					auto i1 = assembleInternal(PC, "lui $1, 0");
					auto i2 = assembleInternal(PC, "ori " ~ params[1] ~ ", $1, 0");

					addReloc(Reloc(Reloc.Type.MipsHi16, params[2], PC_BASE + 0));
					addReloc(Reloc(Reloc.Type.MipsLo16, params[2], PC_BASE + 4));

					return i1 ~ i2;
				} break;
				case "li": {
					scope params = RegExp(getPattern("%s, %s")).match(instructionParams);
					assert(params.length == 3);
					scope value = parseString(params[2]);

					Instruction[] ii = [];

					// No upper part
					if ((value >> 16) == 0) {
						ii ~= assembleInternal(PC, format("ori %s, $0, 0x%04X", params[1], (value >>  0) & 0xFFFF));
					}
					// No lower part
					else if ((value & 0xFFFF) == 0) {
						ii ~= assembleInternal(PC, format("lui %s, 0x%04X", params[1], (value >> 16) & 0xFFFF));
					}
					// Signed short
					else if ((cast(short)value) == value) {
						ii ~= assembleInternal(PC, format("addi %s, $0, 0x%04X", params[1], value));
					}
					// Full 32 bit.
					else {
						ii ~= assembleInternal(PC, format("lui $1, 0x%04X", (value >> 16) & 0xFFFF));
						ii ~= assembleInternal(PC, format("ori %s, $1, 0x%04X", params[1], (value >>  0) & 0xFFFF));
					}
					
					return ii;
				} break;
				case "nop": {
					return assembleInternal(PC, "sll r0, r0, r0");
				} break;
				// Ignore.
				default: break;
			}

			// Obtain instruction.
			assert(instructionName in instructionsAvailable, format("Can't assemble unknown instruction '%s'", instructionName));
			auto instructionDefinition = instructionsAvailable[instructionName];

			auto paramTypes    = getParams(instructionDefinition.fmt);
			auto paramMatches  = RegExp(getPattern(instructionDefinition.fmt)).match(instructionParams);

			// Fix empty parameters.
			if (instructionParams == "") paramMatches ~= "";

			assert(paramMatches.length > 1, format("instruction:'%s'; params:'%s'; pattern:'%s'", instructionName, instructionParams, getPattern(instructionDefinition.fmt)));
			auto paramValues   = paramMatches[1..$];

			Instruction instruction;

			instruction.v = (instructionDefinition.opcode & instructionDefinition.mask);
			
			//writefln("%s", paramTypes.join(""));

			foreach (n; 0..paramTypes.length) {
				auto paramType = paramTypes[n], paramValue = paramValues[n];
				uint getRegister() {
					return cast(uint)Registers.getAlias(paramValue);
				}
				uint getFPRegister() {
					return cast(uint)Registers.FP.getAlias(paramValue);
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
				//writefln("param:%s", paramType);
				switch (paramType) {
					// Register.
					case "%d" : instruction.RD     = getRegister;  break; // Rd
					case "%s" : instruction.RS     = getRegister;  break; // Rs
					case "%t" : instruction.RT     = getRegister;  break; // Rt
					case "%1" :
					case "%S" : instruction.FS     = getFPRegister; break; // Fs
					case "%D" : instruction.FD     = getFPRegister; break; // Fd
					case "%T" : instruction.FT     = getFPRegister; break; // Ft
					case "%i" : instruction.IMM    = getImmediate(Sign.Signed); break; // 16bit signed immediate
					case "%I" : instruction.IMMU   = getImmediate(Sign.Unsigned); break; // 16bit unsigned immediate (always printed in hex)
					case "%O" : instruction.OFFSET = getOffset;    break; // 16bit signed offset (PC relative)
					case "%j" : instruction.JUMP   = getAbsoluteOffset; break; // 26bit absolute offset
					case "%J" : instruction.RS     = getRegister;  break; // register jump
					case "%a" : instruction.POS    = getImmediate(Sign.Unsigned); break;
					case "%ne": instruction.SIZE_E = getImmediate(Sign.Unsigned); break;
					case "%ni": instruction.SIZE_I = getImmediate(Sign.Unsigned); break;
					case "%o" : {
						scope results = RegExp(r"^(\-?\d+)\(([\$\d\w\-\+\_]+)\)$", "").match(paramValue);
						assert(results.length == 3);
						instruction.OFFSET = cast(int)parseString(results[1]);
						instruction.RS     = cast(uint)Registers.getAlias(results[2]);
						//writefln("%s", results[1]);
					} break;
					case "%C": {
						instruction.CODE = getImmediate(Sign.Unsigned);
					} break;
					default:
						throw(new Exception(std.string.format("Assembler.assembleInternal doesn't know how to process '%s'", paramType)));
					break;
 				}
			}

			PC += 4;
			return [instruction];
		}
		return [];
	}

	static string[] getParams(string pattern) {
		auto regexp = new RegExp(r"%\w+", "g");
		return regexp.match(pattern);
	}

	static string getPattern(string pattern) {
		pattern = replace(pattern, " ", r"\s+");
		pattern = replace(pattern, "%o", r"(\-?\d+\([\$\d\w\-\+\_]+\))");
		pattern = RegExp(r"%[\w\d]+", "g").replace(pattern, r"([\$\d\w\-\+\_]+)");
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
	Instruction[] assemble(ref uint PC, string line) {
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
					// Data
					case "float": {
						string process = parts[2];
						int pos;
						while (1) {
							if ((pos = std.string.indexOf(process, ',')) == -1) pos = process.length;
							float v = to!(float)(strip(process[0..pos]));
							stream.write(v);
							if (pos >= process.length) break;
							process = process[pos + 1..$];
						}
					} break;
					case "byte", "half", "word": {
						string process = parts[2];
						string current_string;
						bool is_string;
						void write_integer(long value) {
							void doalign(int n) {
								while ((stream.position % n) != 0) stream.write(cast(ubyte)0);
							}
							switch (parts[1]) {
								case "byte": doalign(1); stream.write(cast(byte)value); break;
								case "half": doalign(2); stream.write(cast(short)value); break;
								case "word": doalign(4); stream.write(cast(int)value); break;
							}
						}
						void token() {
							if (!current_string.length) return;
							if (is_string) {
								foreach (c; current_string) write_integer(c);
							} else {
								write_integer(parseString(current_string));
							}
							//writefln("TOKEN:'%s'", current_string);
							current_string = "";
							is_string = false;
						}
						for (int n = 0; n < process.length; n++) {
							char c = process[n];
							//writefln("%s", c);
							// Ignore spaces.
							if (std.ctype.isspace(c)) {
								assert(current_string.length == 0);
								continue;
							}
							// Ignore commas.
							else if (c == ',') {
								token();
							}
							// String.
							else if (c == '\'') {
								for (n++; n < process.length; n++) {
									c = process[n];
									if (c == '\'') break;
									current_string ~= c;
								}
								is_string = true;
							} else {
								current_string ~= c;
							}
						}
						token();
						//writefln("%s", process);
						//assert(0);
					} break;
				}
				return [];
			}

			PC = cast(uint)stream.position;
			uint nPC = PC;
			auto instructions = assembleInternal(nPC, operation);
			foreach (instruction; instructions) {
				//writefln("%08X: %08X", stream.position, instruction.v);
				stream.write(instruction.v);
			}
			return instructions;
		}
		return [];
	}

	Instruction[] assemble(string line) {
		uint PC;
		return assemble(PC, line);
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

	void smartDump() {
		auto sms = cast(SparseMemoryStream)stream;
		if (sms) {
			sms.smartDump();
		} else {
			writefln("Not a SparseMemoryStream");
		}
	}

	bool checkMemory(uint offset, ubyte[] data) {
		auto bpos = stream.position; scope (exit) stream.position = bpos;
		stream.position = offset;
		return (cast(ubyte[])stream.readString(data.length) == data);
	}

	alias assemble opCall;
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");

	scope assembler = new AllegrexAssembler;
	uint PC; Instruction[] instructions;

	ReturnType!(assembler.opCall) assembler_(string line) { return instructions = assembler(PC, line); }
	
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

	assembler.assembleBlock(".data\n value: .float 1.5, 1.6");
	assembler.assembleBlock("label2: la $1, label2");

	// Check inserting data and alignment.
	assembler.assembleBlock(r"
		.text 0x1000
		.byte 'hello', 0x0A, 10, 0, 1
		.word 0x7FFF
		.byte 1
		.half 2
	");
	assert(assembler.checkMemory(0x1000, cast(ubyte[])x"68656C6C 6F0A0A00 01000000 FF7F0000 01000200"));

	// Post reference.
	assembler.assembleBlock(r"
		la $1, label3
		label3: .float 1.0
	");

	assembler_(".text 0x1000        "); assert((PC == 0x1000));
	assembler_("; comment           "); assert((PC == 0x1000));
	assembler_("	addi a0, zero, 1 ; this is a comment"); assert((PC == 0x1000) && (instructions[0].v == 0x_20040001));
	assembler_("loop:               "); assert((PC == 0x1004));
	assembler_("  addi a1, zero, 2  "); assert((PC == 0x1004) && (instructions[0].v == 0x_20050002));
	assembler_("  add v0, a0, a1    "); assert((PC == 0x1008) && (instructions[0].v == 0x_00851020));
	assembler_("  addi v0, v0, -2   "); assert((PC == 0x100C) && (instructions[0].v == 0x_2042FFFE));
	assembler_("  beq  v0, v0, loop "); assert((PC == 0x1010) && (instructions[0].v == 0x_10420000));
	assembler.relocate();

	// Check relocations.
	assembler.stream.position = 0x1010;
	assembler.stream.read(instructions[0].v);
	assert(instructions[0].v == 0x_1042FFFC);
	
}
