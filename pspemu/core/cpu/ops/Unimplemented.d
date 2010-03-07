module pspemu.core.cpu.ops.Unimplemented;

import pspemu.core.cpu.Registers;
import pspemu.core.cpu.Instruction;
import pspemu.core.Memory;

template TemplateCpu_UNIMPLEMENTED() {
	void UNIMPLEMENTED() {
		assert(0, "Unimplemented");
	}

	alias UNIMPLEMENTED OP_CFC0;
	alias UNIMPLEMENTED OP_CTC0;
	alias UNIMPLEMENTED OP_DRET;
	alias UNIMPLEMENTED OP_ERET;
	alias UNIMPLEMENTED OP_LL;
	alias UNIMPLEMENTED OP_MFC0;
	alias UNIMPLEMENTED OP_MFDR;
	alias UNIMPLEMENTED OP_MTC0;
	alias UNIMPLEMENTED OP_MTDR;
	alias UNIMPLEMENTED OP_C_OLT_S;
	alias UNIMPLEMENTED OP_C_ULT_S;
	alias UNIMPLEMENTED OP_C_OLE_S;
	alias UNIMPLEMENTED OP_C_ULE_S;
	alias UNIMPLEMENTED OP_C_SF_S;
	alias UNIMPLEMENTED OP_C_NGLE_S;
	alias UNIMPLEMENTED OP_C_SEQ_S;
	alias UNIMPLEMENTED OP_C_NGE_S;
	alias UNIMPLEMENTED OP_C_NGL_S;
	alias UNIMPLEMENTED OP_C_NGW_S;
	alias UNIMPLEMENTED OP_C_NGT_S;
}