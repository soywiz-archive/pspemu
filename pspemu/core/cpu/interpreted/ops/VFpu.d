module pspemu.core.cpu.interpreted.ops.VFpu;
import pspemu.core.cpu.interpreted.Utils;

template TemplateCpu_VFPU() {
	// http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/Allegrex/Common.java?spec=svn819&r=819
	// S, P, T, Q

	// Matrix Identity
	// VMIDT(111100:111:00:00011:two:0000000:one:vd)
	void OP_VMIDT_Q() {
		uint vd = instruction.v & 0x7F;
		uint matrix = vd / 4;
		if (matrix >= 8) throw(new Exception("VMIDT_Q matrix >= 8"));
		cpu.registers.VF_MATRIX[matrix] = [
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1
		];
		registers.pcAdvance(4);
	}
}
