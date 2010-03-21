module pspemu.core.gpu.ops.Matrix;

version = VERSION_GPU_MATRIX_LOAD_RAW;

template Gpu_Matrix() {
	version (VERSION_GPU_MATRIX_LOAD_RAW) {
		auto OP_VMS  () { gpu.info.viewMatrix.reset(Matrix.WriteMode.M4x3); }
		auto OP_VIEW () { gpu.info.viewMatrix.write(command.float1); }

		auto OP_WMS  () { gpu.info.worldMatrix.reset(Matrix.WriteMode.M4x3); }
		auto OP_WORLD() { gpu.info.worldMatrix.write(command.float1); }

		auto OP_PMS  () { gpu.info.projectionMatrix.reset(Matrix.WriteMode.M4x4); }
		auto OP_PROJ () { gpu.info.projectionMatrix.write(command.float1); }
	} else {
	}
}
