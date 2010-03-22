module pspemu.core.gpu.ops.Enable;

template Gpu_Enable() {
	// Clip Plane Enable (GL_CLIP_PLANE0)
	auto OP_CPE() { gpu.state.clipPlaneEnabled = command.bool1; }

	// Backface Culling Enable (GL_CULL_FACE)
	auto OP_BCE() { gpu.state.backfaceCullingEnabled = command.bool1; }

	// Alpha Blend Enable (GL_BLEND)
	auto OP_ABE() { gpu.state.alphaBlendEnabled = command.bool1; }

	// depth (Z) Test Enable (GL_DEPTH_TEST)
	auto OP_ZTE() { gpu.state.depthTestEnabled = command.bool1; }

	// Stencil Test Enable (GL_STENCIL_TEST)
	auto OP_STE() { gpu.state.stencilTestEnabled = command.bool1; }

	// Logical Operation Enable (GL_COLOR_LOGIC_OP)
	auto OP_LOE() { gpu.state.logicalOperationEnabled = command.bool1; }

	// Texture Mapping Enable (GL_TEXTURE_2D)
	auto OP_TME() { gpu.state.textureMappingEnabled = command.bool1; }

	// Alpha Test Enable (GL_ALPHA_TEST) glAlphaFunc(GL_GREATER, 0.03f);
	auto OP_ATE() { gpu.state.alphaTestEnabled = command.bool1; /*gpu.state.alphaFunc = 0; gpu.state.alphaFuncValue = 0.03f;*/ }

	// glDepthMask
	auto OP_ZMSK() { }

	auto OP_ALPHA() {
		with (gpu.state) {
			blendFuncSrc  = (command.param24 >> 0) & 0xF;
			blendFuncDst  = (command.param24 >> 4) & 0xF;
			blendEquation = (command.param24 >> 8) & 0x03;
		}
	}

	// Fog enable (GL_FOG)
	auto OP_FGE() {
		// ...
	}
}

/*
	case VC.ALPHA: {
		debug (gpu_debug_verbose) writefln("VC.ALPHA[1]");
		if (&glBlendEquation !is null) glBlendEquation(BLENDE_T[(param >> 8) & 0x03]);

		debug (gpu_debug_verbose) writefln("VC.ALPHA[2]");
		if (&glBlendFunc !is null) {
			glBlendFunc(
				BLENDF_T_S[(param >> 0) & 0xF],
				BLENDF_T_S[(param >> 4) & 0xF]
			);
		}
		debug (gpu_debug_verbose) writefln("VC.ALPHA[3]");
	} break;
	case VC.FGE: // FoG Enable
		glEnableDisable(GL_FOG, param);
		if (!param) break;
		glFogi(GL_FOG_MODE, GL_LINEAR);
		glFogf(GL_FOG_DENSITY, 0.1f);
		glHint(GL_FOG_HINT, GL_DONT_CARE);
	break;
	//case VC.DTE: break; // DiTher Enable
	//case VC.AAE: break; // AnitAliasing Enable
	//case VC.PCE: break; // Patch Cull Enable					
	//case VC.CTE: break; // Color Test Enable		
*/
