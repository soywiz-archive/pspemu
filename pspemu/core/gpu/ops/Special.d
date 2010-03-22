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
		gpu.state.drawBuffer.address = command.param24;
		gpu.mustLoadFrameBuffer = true;
	}

	// Frame Buffer Width
	auto OP_FBW() { gpu.state.drawBuffer.width   = command.param16; }

	// texture Pixel Storage Mode
	auto OP_PSM() { gpu.state.drawBuffer.format = command.param24; }

	// SCISSOR start (1)
	auto OP_SCISSOR1() {
		with (gpu.state) {
			scissor.x1 = (command.param24 >>  0) & 0x3FF;
			scissor.y1 = (command.param24 >> 10) & 0x3FF;
		}
	}

	// SCISSOR end (2)
	auto OP_SCISSOR2() {
		with (gpu.state) {
			scissor.x2 = (command.param24 >>  0) & 0x3FF;
			scissor.y2 = (command.param24 >> 10) & 0x3FF;
		}
	}
	
	auto OP_FFACE() { gpu.state.faceCullingOrder = command.param24; }
	
	auto OP_SHADE() { gpu.state.shadeModel = command.param24; }
}