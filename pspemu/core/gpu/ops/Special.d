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
		gpu.state.drawBuffer.lowAddress = command.param24;
		gpu.state.drawBuffer.mustLoad = true;
	}

	// Frame Buffer Width
	auto OP_FBW() {
		gpu.state.drawBuffer.highAddress = command.extract!(ubyte, 16);
		gpu.state.drawBuffer.width       = command.extract!(ushort, 0);
	}

	// Depth Buffer Pointer
	auto OP_ZBP() {
		gpu.state.depthBuffer.lowAddress = command.param24;
		gpu.state.depthBuffer.mustLoad   = true;
	}

	// Depth Buffer Width
	auto OP_ZBW() {
		gpu.state.depthBuffer.highAddress = command.extract!(ubyte, 16);
		gpu.state.depthBuffer.width       = command.extract!(ushort, 0);
	}

	// texture Pixel Storage Mode
	auto OP_PSM() {
		gpu.state.drawBuffer.format = cast(PixelFormats)command.param24;
	}
	
	// SCISSOR start (1)
	auto OP_SCISSOR1() {
		with (gpu.state) {
			scissor.x1 = command.extract!(ushort,  0, 10);
			scissor.y1 = command.extract!(ushort, 10, 20);
		}
	}

	// SCISSOR end (2)
	auto OP_SCISSOR2() {
		with (gpu.state) {
			scissor.x2 = command.extract!(ushort,  0, 10);
			scissor.y2 = command.extract!(ushort, 10, 20);
		}
	}

	auto OP_FFACE() { gpu.state.faceCullingOrder = command.param24; }
	
	auto OP_SHADE() { gpu.state.shadeModel = command.param24; }

	auto OP_ZTST() { gpu.state.depthFunc = cast(TestFunction)command.param24; }

	// Stencil Test
	auto OP_STST() {
		with (gpu.state) {
			stencilFuncFunc = command.extractEnum!(TestFunction, 0);
			stencilFuncRef  = command.extract!(ubyte,  8);
			stencilFuncMask = command.extract!(ubyte, 16);
		}
	}

	// Stencil OPeration
	auto OP_SOP() {
		with (gpu.state) {
			stencilOperationSfail  = command.extractEnum!(StencilOperations,  0);
			stencilOperationDpfail = command.extractEnum!(StencilOperations,  8);
			stencilOperationDppass = command.extractEnum!(StencilOperations, 16);
		}
	}

	// source fix color
	auto OP_SFIX() { gpu.state.fixSrc = command.param24; }

	// destination fix color
	auto OP_DFIX() { gpu.state.fixDst = command.param24; }

	// Logical Operation
	auto OP_LOP() { gpu.state.logicalOperation = cast(LogicalOperation)command.param24; }

	// Fog COLor
	auto OP_FCOL() {
		gpu.state.fogColor.rgb[] = command.float3[];
	}

	// Fog FAR
	auto OP_FFAR() {
		gpu.state.fogEnd = command.float1;
	}

	// Fog DISTance
	auto OP_FDIST() {
		gpu.state.fogDist = command.float1;
	}
}