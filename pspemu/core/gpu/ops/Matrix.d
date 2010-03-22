module pspemu.core.gpu.ops.Matrix;

version = VERSION_GPU_MATRIX_LOAD_RAW;

template Gpu_Matrix() {
	version (VERSION_GPU_MATRIX_LOAD_RAW) {
		auto OP_VMS  () { gpu.state.viewMatrix.reset(Matrix.WriteMode.M4x3); }
		auto OP_VIEW () { gpu.state.viewMatrix.write(command.float1); }

		auto OP_WMS  () { gpu.state.worldMatrix.reset(Matrix.WriteMode.M4x3); }
		auto OP_WORLD() { gpu.state.worldMatrix.write(command.float1); }

		auto OP_PMS  () { gpu.state.projectionMatrix.reset(Matrix.WriteMode.M4x4); }
		auto OP_PROJ () { gpu.state.projectionMatrix.write(command.float1); }
	} else {
	}
}
