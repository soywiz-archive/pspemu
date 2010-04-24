module pspemu.core.gpu.ops.Enable;

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

	// Alpha Test Enable (GU_ALPHA_TEST) glAlphaFunc(GL_GREATER, 0.03f);
	auto OP_ATE() { gpu.state.alphaTestEnabled = command.bool1; /*gpu.state.alphaFunc = 0; gpu.state.alphaFuncValue = 0.03f;*/ }

	// depth (Z) Test Enable (GU_DEPTH_TEST)
	auto OP_ZTE() { gpu.state.depthTestEnabled = command.bool1; }

	// (GU_SCISSOR_TEST) // OP_SCISSOR1 + OP_SCISSOR2

	// Stencil Test Enable (GL_STENCIL_TEST)
	auto OP_STE() { gpu.state.stencilTestEnabled = command.bool1; }

	// Alpha Blend Enable (GU_BLEND)
	auto OP_ABE() { gpu.state.alphaBlendEnabled = command.bool1; }

	// Backface Culling Enable (GU_CULL_FACE)
	auto OP_BCE() { gpu.state.backfaceCullingEnabled = command.bool1; }

	// DiThering Enable (GU_DITHER)
	auto OP_DTE() { gpu.state.ditheringEnabled = command.bool1; }

	// Fog enable (GU_FOG)
	auto OP_FGE() { gpu.state.fogEnabled = command.bool1; /* fogMode = GL_LINEAR; fogHint = GL_DONT_CARE; fogDensity = 0.1; */ }

	// Clip Plane Enable (GU_CLIP_PLANES/GL_CLIP_PLANE0)
	auto OP_CPE() { gpu.state.clipPlaneEnabled = command.bool1; }

	// Texture Mapping Enable (GL_TEXTURE_2D)
	auto OP_TME() { gpu.state.textureMappingEnabled = command.bool1; }

	// Lighting Test Enable GL_LIGHTING.
	auto OP_LTE() { gpu.state.lightingEnabled = command.bool1; }
	
	// AnitAliasing Enable (GU_LINE_SMOOTH?)
	auto OP_AAE() { gpu.state.lineSmoothEnabled = command.bool1; }
	
	// Patch Cull Enable (GU_PATCH_CULL_FACE)
	auto OP_PCE() { gpu.state.patchCullEnabled = command.bool1; }

	// Color Test Enable (GU_COLOR_TEST)
	auto OP_CTE() { gpu.state.colorTestEnabled = command.bool1; }
	
	// Logical Operation Enable (GL_COLOR_LOGIC_OP)
	auto OP_LOE() { gpu.state.logicalOperationEnabled = command.bool1; }
}
