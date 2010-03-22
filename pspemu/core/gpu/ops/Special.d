module pspemu.core.gpu.ops.Special;

template Gpu_Special() {
	// Base Address Register
	auto OP_BASE() { gpu.state.baseAddress = (command.param24 << 8); }

	// Vertex List (Base Address)
	auto OP_VADDR() { gpu.state.vertexAddress = gpu.state.baseAddress + command.param24; }

	// Index List (Base Address)
	auto OP_IADDR() { gpu.state.indexAddress = gpu.state.baseAddress + command.param24; }

	// Vertex Type
	auto OP_VTYPE() {
		gpu.state.vertexType.v = command.param24;
		//writefln("VTYPE:%032b", command.param24);
		//writefln("     :%d", gpu.state.vertexType.position);
	}

	// Frame Buffer Pointer
	auto OP_FBP() {
		gpu.state.drawBuffer.address = command.param24; gpu.mustLoadFrameBuffer = true;
	}

	// Frame Buffer Width
	auto OP_FBW() { gpu.state.drawBuffer.width   = command.param16; }
}