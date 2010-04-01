module pspemu.core.cpu.interpreted.ops.Unimplemented;
import pspemu.core.cpu.interpreted.Utils;

template TemplateCpu_UNIMPLEMENTED() {
	void UNIMPLEMENTED() {
		assert(0, "Unimplemented");
	}
}