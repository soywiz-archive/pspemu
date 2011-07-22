module pspemu.core.gpu.ops.Gpu_Matrix;

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
		
		auto OP_TMS    () { gpu.state.texture.matrix.reset(Matrix.WriteMode.M4x4); }
		auto OP_TMATRIX() { gpu.state.texture.matrix.write(command.float1); }
		
		/**
		  * Specify skinning matrix entry
		  *
		  * To enable vertex skinning, pass GU_WEIGHTS(n), where n is between
		  * 1-8, and pass available GU_WEIGHT_??? declaration. This will change
		  * the amount of weights passed in the vertex araay, and by setting the skinning,
		  * matrices, you will multiply each vertex every weight and vertex passed.
		  *
		  * Please see sceGuDrawArray() for vertex format information.
		  *
		  * @param index - Skinning matrix index (0-7)
		  * @param matrix - Matrix to set
		**/
		//void sceGuBoneMatrix(unsigned int index, const ScePspFMatrix4* matrix);
		// @TODO : @FIX: @HACK : it defines the position in the matrixes. So we will do a hack there until fixed.
		// http://svn.ps2dev.org/filedetails.php?repname=psp&path=%2Ftrunk%2Fpspsdk%2Fsrc%2Fgu%2FsceGuBoneMatrix.c
		auto OP_BOFS() {
			gpu.state.boneMatrixIndex = command.param16 / 12; 
			gpu.state.boneMatrix[gpu.state.boneMatrixIndex].reset(Matrix.WriteMode.M4x3);
		}
		
		auto OP_BONE() {
			gpu.state.boneMatrix[gpu.state.boneMatrixIndex].write(command.float1);
		}
	} else {
		static assert (0, "Not implemented");
	}
}
