module pspemu.core.cpu.interpreted.ops.Unimplemented;
import pspemu.core.cpu.interpreted.Utils;

template TemplateCpu_UNIMPLEMENTED() {
	void UNIMPLEMENTED() {
		throw(new Exception("Unimplemented")); assert(0, "Unimplemented");
	}
}