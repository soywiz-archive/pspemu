module pspemu.core.gpu.ops.Gpu_Enable;

template Gpu_Enable() {
	/**
	 * Enable GE state
	 *
	 * The currently available states are:
	 *   - GU_ALPHA_TEST
	 *   - GU_DEPTH_TEST
	 *   - GU_SCISSOR_TEST
	 *   - GU_STENCIL_TEST
	 *   - GU_BLEND
	 *   - GU_CULL_FACE
	 *   - GU_DITHER
	 *   - GU_FOG
	 *   - GU_CLIP_PLANES
	 *   - GU_TEXTURE_2D
	 *   - GU_LIGHTING
	 *   - GU_LIGHT0
	 *   - GU_LIGHT1
	 *   - GU_LIGHT2
	 *   - GU_LIGHT3
	 *   - GU_LINE_SMOOTH
	 *   - GU_PATCH_CULL_FACE
	 *   - GU_COLOR_TEST
	 *   - GU_COLOR_LOGIC_OP
	 *   - GU_FACE_NORMAL_REVERSE
	 *   - GU_PATCH_FACE
	 *   - GU_FRAGMENT_2X
	 *
	 * @param state - Which state to enable
	 **/
	// void sceGuEnable(int state);

	// (GU_SCISSOR_TEST) // OP_SCISSOR1 + OP_SCISSOR2

	// Backface Culling Enable (GU_CULL_FACE)
	auto OP_BCE() { gpu.state.backfaceCullingEnabled = command.bool1; }

	// DiThering Enable (GU_DITHER)
	auto OP_DTE() { gpu.state.ditheringEnabled = command.bool1; }

	// Clip Plane Enable (GU_CLIP_PLANES/GL_CLIP_PLANE0)
	auto OP_CPE() { gpu.state.clipPlaneEnabled = command.bool1; }

	// AnitAliasing Enable (GU_LINE_SMOOTH?)
	auto OP_AAE() { gpu.state.lineSmoothEnabled = command.bool1; }
	
	// Patch Cull Enable (GU_PATCH_CULL_FACE)
	auto OP_PCE() { gpu.state.patchCullEnabled = command.bool1; }

	// Color Test Enable (GU_COLOR_TEST)
	auto OP_CTE() { gpu.state.colorTestEnabled = command.bool1; }
}
