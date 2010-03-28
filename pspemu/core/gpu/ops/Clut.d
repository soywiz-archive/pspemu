module pspemu.core.gpu.ops.Clut;

/**
 * CLUT (Color LookUp Table) opcodes.
 */
template Gpu_Clut() {
	// Clut Buffer Pointer (High)
	auto OP_CBP () { gpu.state.clut.address = (gpu.state.clut.address & 0xFF000000) | (command.param24 << 0); }
	auto OP_CBPH() { gpu.state.clut.address = (gpu.state.clut.address & 0x00FFFFFF) | (command.param24 << 8); }

	// Clut LOAD
	auto OP_CLOAD() {
		// @TODO
	}

	// Clut MODE
	auto OP_CMODE() {
		gpu.state.clut.format = command.extract!(PixelFormats)(0, 2);
		gpu.state.clut.shift  = command.extract!(uint)(2, 5);
		gpu.state.clut.mask   = command.extract!(uint)(8, 8);
		gpu.state.clut.start  = command.extract!(uint)(16, 5) << 4;
	}
}
