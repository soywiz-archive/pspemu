module pspemu.core.cpu.assembler.CpuAssembler;

import std.stdio;
import std.string;
import std.uni;
import std.conv;
import std.ascii;
import std.stream;

import pspemu.utils.Expression;
public import pspemu.core.cpu.Instruction;
public import pspemu.interfaces.IResetable;

class CpuAssembler : IResetable {
	InstructionDefinition[string] instructionDefinitions;
	uint[string] labels;
	Patch[] patches;
	
	struct Patch {
		enum Type {
			LO  = 0,
			HI  = 1,
			S32 = 2,
		}
		Type type;
		uint PC;
		string label;
	}
	
	this(const InstructionDefinition[] instructionDefinitions) {
		foreach (instructionDefinition; instructionDefinitions) {
			this.instructionDefinitions[instructionDefinition.name] = instructionDefinition;
		}
	}
	
	void reset() {
		labels = null;
		patches.length = 0;
	}

	static string[] tokenizeLine(string str) {
		string[] ret;
		
		bool isIdentStart(char c) {
			return isAlphaNum(c) || (c == '%');
		}
		
		auto code = { 
			for (int n = 0; n < str.length; n++) {
				char c = str[n];
				switch (c) {
					case ' ': case '\t': break;
					case '\n': case '\r': return;
					case '\'': case '"': {
						char start_c = c;
						int m = n;
						for (n++; n < str.length; n++) {
							if (str[n] == start_c) break;
						}
						ret ~= str[m..n];
						n--;
					} break;
					case ';':
						return;
					break;
					default:
						if (isIdentStart(c)) {
							int m = n;
							for (n++; n < str.length; n++) {
								if (!isAlphaNum(str[n])) break;							
							}
							ret ~= str[m..n];
							n--;
						} else {
							ret ~= [c];
						}
					break;
				}
			}
		};
		code();

		return ret;
	}
	
	int getLabel(string name) {
		if (!(name in labels)) throw(new Exception("Can't find label '" ~ name ~ "'"));
		return labels[name];
	}
	
	void assemble(Stream stream, string lines) {
		foreach (line; std.string.split(lines, "\n")) {
			auto lineTokens = tokenizeLine(line);
			uint PC = cast(uint)stream.position;
			//writefln("%s", line);
			
			if (lineTokens.length > 0) {
				// It's a label.
				if (lineTokens[$ - 1] == ":") {
					labels[lineTokens[0]] = PC;
				}
				// It's a directive
				else if (lineTokens[0] == ".") {
					assert(0);
				}
				// It's an instruction
				else {
					foreach (instruction; assembleInstruction(PC, lineTokens[0], lineTokens[1..$])) {
						stream.write(instruction.v);
					}
				}
			}
		}
		
		long backStreamPosition = stream.position;
		{
			foreach (patch; patches) {
				Instruction instruction;
				int PC = patch.PC;
				int address = cast(int)getLabel(patch.label);

				stream.position = PC; stream.read(instruction.v);
				
				switch (patch.type) {
					case Patch.Type.LO:
						//writefln("PATCHING: PC(0x%08X) : ADRESS(0x%08X)", PC, address);
						instruction.OFFSET2 = (address - PC) - 4;
					break;
					default: throw(new Exception("Unhandled Patch.Type '" ~ to!string(patch.type) ~ "'"));
				}
				
				stream.position = patch.PC; stream.write(instruction.v);
			}
		}
		stream.position = backStreamPosition;
		
		patches.length = 0;
	}
	
	Instruction[] assembleInstruction(uint PC, string opcodeName, string[] tokensParams) {
		final switch (opcodeName) {
			case "nop":
				return assembleInstruction(PC, "sll", ["r0", ",", "r0", ",", "r0"]);
			break;
		}
		
		if ((opcodeName in instructionDefinitions) is null) throw(new Exception("Can't find opcode '" ~ opcodeName ~ "'"));
		InstructionDefinition instructionDefinition = instructionDefinitions[opcodeName];
		
		string format = instructionDefinition.fmt;
		
		Instruction instruction;

		string[] tokensFormat = tokenizeLine(format);
		int tokenParamIndex;
		
		int getRegisterValue(string registerName) {
			if (registerName[0] == 'r') {
				return std.conv.to!int(registerName[1..$]);
			}
			throw(new Exception("Invalid registername '" ~ registerName ~ "'"));
		}

		int getImmediateValue(string value) {
			return cast(int)pspemu.utils.Expression.parseString(value);
		}
		
		foreach (formatToken; tokensFormat) {
			string paramToken = tokensParams[tokenParamIndex++];
			if (formatToken[0] == '%') {
				switch (formatToken) {
					case "%d": instruction.RD   = getRegisterValue(paramToken); break;   // RD
					case "%s": instruction.RS   = getRegisterValue(paramToken); break;   // RS
					case "%t": instruction.RT   = getRegisterValue(paramToken); break;   // RT
					case "%i": instruction.IMM  = getImmediateValue(paramToken); break;  // IMM
					case "%C": instruction.CODE = getImmediateValue(paramToken); break;  // CODE
					case "%a": instruction.POS  = getImmediateValue(paramToken); break;  // POSITION (SLL)
					case "%O": patches ~= Patch(Patch.Type.LO, PC, paramToken); break;  // IMM * 4
					default: throw(new Exception(std.string.format("Unknown format '%s'", formatToken)));
				}
			} else {
				if (formatToken != paramToken) {
					throw(new Exception(std.string.format("Expected '%s', but found '%s'", formatToken, paramToken)));
				}
			}
		}
		
		instruction.v |= instructionDefinition.opcode.value & instructionDefinition.opcode.mask;  
		
		return [instruction];
	}
	
	Instruction[] assembleInstruction(uint PC, string opcodeName, string params) {
		return assembleInstruction(PC, opcodeName, tokenizeLine(params));
	}
}