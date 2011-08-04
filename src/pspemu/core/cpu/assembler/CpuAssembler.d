module pspemu.core.cpu.assembler.CpuAssembler;

import std.stdio;
import std.string;
import std.uni;
import std.conv;
import std.ascii;

import pspemu.utils.Expression;
public import pspemu.core.cpu.Instruction;

class CpuAssembler {
	InstructionDefinition[string] instructionDefinitions;
	
	this(const InstructionDefinition[] instructionDefinitions) {
		foreach (instructionDefinition; instructionDefinitions) {
			this.instructionDefinitions[instructionDefinition.name] = instructionDefinition;
		}
	}

	static string[] tokenize(string str) {
		string[] ret;
		
		bool isIdentStart(char c) {
			return isAlphaNum(c) || (c == '%');
		}
		
		for (int n = 0; n < str.length; n++) {
			char c = str[n];
			switch (c) {
				case ' ': case '\t': break;
				case '\n': case '\r': break;
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
		return ret;
	}
	
	Instruction[] assembleInstruction(uint PC, string opcodeName, string params) {
		if ((opcodeName in instructionDefinitions) is null) throw(new Exception("Can't find opcode '" ~ opcodeName ~ "'"));
		InstructionDefinition instructionDefinition = instructionDefinitions[opcodeName];
		
		string format = instructionDefinition.fmt;
		
		Instruction instruction;

		string[] tokensFormat = tokenize(format);
		string[] tokensParams = tokenize(params);
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
					case "%d": instruction.RD  = getRegisterValue(paramToken); break;
					case "%s": instruction.RS  = getRegisterValue(paramToken); break;
					case "%t": instruction.RT  = getRegisterValue(paramToken); break;
					case "%i": instruction.IMM = getImmediateValue(paramToken); break;
					default:
						throw(new Exception(std.string.format("Unknown format '%s'", formatToken)));
						break;
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
}