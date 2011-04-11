module pspemu.core.cpu.interpreted.ops.Unimplemented;

import pspemu.All;

template TemplateCpu_UNIMPLEMENTED() {
	void UNIMPLEMENTED() {
		throw(new Exception("Unimplemented")); assert(0, "Unimplemented");
	}
}