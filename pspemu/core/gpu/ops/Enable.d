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

	// Lighting Test Enable GL_LIGHTING.
	auto OP_LTE() { gpu.state.lightingEnabled = command.bool1; }

	// glDepthMask
	auto OP_ZMSK() { gpu.state.depthMask = command.bool1; }

	// Blend Equation and Functions
	auto OP_ALPHA() {
		with (gpu.state) {
			blendFuncSrc  = command.extract!(int, 0, 4);
			blendFuncDst  = command.extract!(int, 4, 4);
			blendEquation = command.extract!(int, 8, 2);
		}
	}

	// Alpha TeST Function & Reference Value
	auto OP_ATST() {
		with (gpu.state) {
			alphaTestFunc  = command.extract!(TestFunction, 0, 8)();
			alphaTestValue = command.extractFixedFloat!(8, 8)();
		}
	}

	// Fog enable (GL_FOG)
	auto OP_FGE() {
		// ...
		with (gpu.state) {
			fogEnable = command.bool1;
			//fogMode = GL_LINEAR;
			//fogHint = GL_DONT_CARE;
			//fogDensity = 0.1;
		}
	}

	auto OP_NEARZ() { gpu.state.depthRangeNear = command.extractFixedFloat!(0, 16)(); }
	auto OP_FARZ () { gpu.state.depthRangeFar = command.extractFixedFloat!(0, 16)(); }
}

/*
	//case VC.DTE: break; // DiTher Enable
	//case VC.AAE: break; // AnitAliasing Enable
	//case VC.PCE: break; // Patch Cull Enable					
	//case VC.CTE: break; // Color Test Enable		
*/
