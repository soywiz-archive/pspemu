module pspemu.core.gpu.Gpu;

import pspemu.core.Memory;
import pspemu.core.gpu.Commands;

class Gpu {
	Memory memory;

	this(Memory memory) {
		this.memory = memory;
	}
}