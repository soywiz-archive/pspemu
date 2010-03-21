module pspemu.core.gpu.ops.Special;

template Gpu_Special() {
	// Base Address Register
	auto OP_BASE() { gpu.info.baseAddress = (command.param24 << 8); }

	// Vertex List (Base Address)
	auto OP_VADDR() { gpu.info.vertexAddress = gpu.info.baseAddress + command.param24; }

	// Index List (Base Address)
	auto OP_IADDR() { gpu.info.indexAddress = gpu.info.baseAddress + command.param24; }

	// Vertex Type
	auto OP_VTYPE() {
		gpu.info.vertexType.v = command.param24;
		//writefln("VTYPE:%032b", command.param24);
		//writefln("     :%d", gpu.info.vertexType.position);
	}

	// Frame Buffer Pointer
	auto OP_FBP() { gpu.info.drawBuffer.address = command.param24; gpu.loadFrameBuffer(); }

	// Frame Buffer Width
	auto OP_FBW() { gpu.info.drawBuffer.width   = command.param16; }
}