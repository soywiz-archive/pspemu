module pspemu.core.gpu.ops.Matrix;

version = VERSION_GPU_MATRIX_LOAD_RAW;

template Gpu_Matrix() {
	version (VERSION_GPU_MATRIX_LOAD_RAW) {
		/**
		 * Set transform matrices
		 *
		 * Available matrices are:
		 *   - GU_PROJECTION - View->Projection matrix
		 *   - GU_VIEW - World->View matrix
		 *   - GU_MODEL - Model->World matrix
		 *   - GU_TEXTURE - Texture matrix
		 *
		 * @param type - Which matrix-type to set
		 * @param matrix - Matrix to load
		 **/
		// void sceGuSetMatrix(int type, const ScePspFMatrix4* matrix);

		auto OP_VMS  () { gpu.state.viewMatrix.reset(Matrix.WriteMode.M4x3); }
		auto OP_VIEW () { gpu.state.viewMatrix.write(command.float1); }

		auto OP_WMS  () { gpu.state.worldMatrix.reset(Matrix.WriteMode.M4x3); }
		auto OP_WORLD() { gpu.state.worldMatrix.write(command.float1); }

		auto OP_PMS  () { gpu.state.projectionMatrix.reset(Matrix.WriteMode.M4x4); }
		auto OP_PROJ () { gpu.state.projectionMatrix.write(command.float1); }
	} else {
		static assert (0, "Not implemented");
	}
}
