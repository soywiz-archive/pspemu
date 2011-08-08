module pspemu.core.cpu.assembler.CpuDisassembler;

public import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.tables.Table;
import pspemu.core.cpu.tables.SwitchGen;

import pspemu.core.cpu.assembler.CpuAssemblerUtils;

class CpuDisassembler {
	InstructionDefinition[string] instructionDefinitions;
	
	this() {
		foreach (instructionDefinition; mixin(PspInstructionsAllString)) {
			this.instructionDefinitions[instructionDefinition.name] = instructionDefinition;
		}
	}
	
	static string genSwitch_callFunction(string opname) {
		return "CALL(\"" ~ opname ~ "\");";
	}
	
	string getRegisterNameByIndex(int index) {
		return std.string.format("r%d", index);
	}

	string[] disassembleInstruction(uint PC, Instruction instruction) {
		string[] tokens;
		
		void CALL(string name) {
			scope instructionDefnition = instructionDefinitions[name];
			tokens ~= instructionDefnition.name;
			
			foreach (token; CpuAssemblerUtils.tokenizeLine(instructionDefnition.fmt)) {
				if (token[0] == '%') {
					switch (token) {
						case "%t": tokens ~= getRegisterNameByIndex(instruction.RT); break;
						case "%s": tokens ~= getRegisterNameByIndex(instruction.RS); break;
						case "%d": tokens ~= getRegisterNameByIndex(instruction.RD); break;
						case "%i": tokens ~= std.string.format("%d", instruction.IMM); break;
						default: throw(new Exception(std.string.format("Unknown token '%s'", token)));
					}
				} else {
					tokens ~= token;
				}
			}
		}
		
		mixin(mixin("pspemu.core.cpu.tables.SwitchGen.genSwitch(" ~ PspInstructionsAllString ~ ", \"genSwitch_callFunction\")"));
		
		return tokens;
	}
}