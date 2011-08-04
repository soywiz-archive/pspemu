module pspemu.core.cpu.tables.DummyGen;

import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.tables.Utils;

public string DummyGen(const InstructionDefinition[] ilist) {
	string ret = "";
	foreach (i; ilist) {
		string processed_iname = process_name(i.name);
		ret ~= "void OP_" ~ processed_iname ~ "() { OP_DISPATCH(\"" ~ processed_iname ~ "\"); }";
	}
	return ret;
}

public string DummyGenUnk() {
	return "void OP_UNK() { OP_DISPATCH(\"OP_UNK\"); }";
}