module pspemu.core.gpu.ops.Enable;

template Gpu_Enable() {
	/**
	 * Enable GE state
	 *
	 * The currently available states are:
	 *   - GU_ALPHA_TEST
	 *   - GU_DEPTH_TEST
	 *   - GU_SCISSOR_TEST
	 *   - GU_BLEND
	 *   - GU_CULL_FACE
	 *   - GU_DITHER
	 *   - GU_CLIP_PLANES
	 *   - GU_TEXTURE_2D
	 *   - GU_LIGHTING
	 *   - GU_LIGHT0
	 *   - GU_LIGHT1
	 *   - GU_LIGHT2
	 *   - GU_LIGHT3
	 *   - GU_COLOR_LOGIC_OP
	 *
	 * @param state - Which state to enable
	 **/
	// void sceGuEnable(int state);

	// Alpha Test Enable (GL_ALPHA_TEST) glAlphaFunc(GL_GREATER, 0.03f);
	auto OP_ATE() { gpu.state.alphaTestEnabled = command.bool1; /*gpu.state.alphaFunc = 0; gpu.state.alphaFuncValue = 0.03f;*/ }

	// depth (Z) Test Enable (GL_DEPTH_TEST)
	auto OP_ZTE() { gpu.state.depthTestEnabled = command.bool1; }

	// Clip Plane Enable (GL_CLIP_PLANE0)
	auto OP_CPE() { gpu.state.clipPlaneEnabled = command.bool1; }

	// Backface Culling Enable (GL_CULL_FACE)
	auto OP_BCE() { gpu.state.backfaceCullingEnabled = command.bool1; }

	// Alpha Blend Enable (GL_BLEND)
	auto OP_ABE() { gpu.state.alphaBlendEnabled = command.bool1; }

	// Stencil Test Enable (GL_STENCIL_TEST)
	auto OP_STE() { gpu.state.stencilTestEnabled = command.bool1; }

	// Logical Operation Enable (GL_COLOR_LOGIC_OP)
	auto OP_LOE() { gpu.state.logicalOperationEnabled = command.bool1; }

	// Texture Mapping Enable (GL_TEXTURE_2D)
	auto OP_TME() { gpu.state.textureMappingEnabled = command.bool1; }

	// Lighting Test Enable GL_LIGHTING.
	auto OP_LTE() { gpu.state.lightingEnabled = command.bool1; }

	// glDepthMask
	auto OP_ZMSK() { gpu.state.depthMask = command.bool1; }

	/**
	 * Set the blending-mode
	 *
	 * Keys for the blending operations:
	 *   - Cs - Source color
	 *   - Cd - Destination color
	 *   - Bs - Blend function for source fragment
	 *   - Bd - Blend function for destination fragment
	 *
	 * Available blending-operations are:
	 *   - GU_ADD - (Cs*Bs) + (Cd*Bd)
	 *   - GU_SUBTRACT - (Cs*Bs) - (Cd*Bd)
	 *   - GU_REVERSE_SUBTRACT - (Cd*Bd) - (Cs*Bs)
	 *   - GU_MIN - Cs < Cd ? Cs : Cd
	 *   - GU_MAX - Cs < Cd ? Cd : Cs
	 *   - GU_ABS - |Cs-Cd|
	 *
	 * Available blending-functions are:
	 *   - GU_SRC_COLOR
	 *   - GU_ONE_MINUS_SRC_COLOR
	 *   - GU_SRC_ALPHA
	 *   - GU_ONE_MINUS_SRC_ALPHA
	 *   - GU_DST_ALPHA
	 *   - GU_ONE_MINUS_DST_ALPHA
	 *   - GU_DST_COLOR
	 *   - GU_ONE_MINUS_DST_COLOR
	 *   - GU_FIX
	 *
	 * @param op - Blending Operation
	 * @param src - Blending function for source operand
	 * @param dest - Blending function for dest operand
	 * @param srcfix - Fix value for GU_FIX (source operand)
	 * @param destfix - Fix value for GU_FIX (dest operand)
	 **/
	// void sceGuBlendFunc(int op, int src, int dest, unsigned int srcfix, unsigned int destfix);

	// Blend Equation and Functions
	auto OP_ALPHA() {
		with (gpu.state) {
			blendFuncSrc  = command.extract!(int, 0, 4);
			blendFuncDst  = command.extract!(int, 4, 4);
			blendEquation = command.extract!(int, 8, 2);
		}
	}

	// source fix color
	auto OP_SFIX() { gpu.state.fixColorSrc.rgb[] = command.float3[]; }

	// destination fix color
	auto OP_DFIX() { gpu.state.fixColorDst.rgb[] = command.float3[]; }

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

	/**
	 * Set which range to use for depth calculations.
	 *
	 * @note The depth buffer is inversed, and takes values from 65535 to 0.
	 *
	 * Example: Use the entire depth-range for calculations:
	 * @code
	 * sceGuDepthRange(65535,0);
	 * @endcode
	 *
	 * @param near - Value to use for the near plane
	 * @param far - Value to use for the far plane
	 **/
	// void sceGuDepthRange(int near, int far);

	auto OP_NEARZ() {
		with (gpu.state) {
			depthRangeNear = command.extractFixedFloat!(0, 16);
		}
	}

	auto OP_FARZ () {
		with (gpu.state) {
			depthRangeFar = command.extractFixedFloat!(0, 16);
			
			//if (depthRangeNear > depthRangeFar) swap(depthRangeNear, depthRangeFar);
		}
	}
}

/*
	//case VC.DTE: break; // DiTher Enable
	//case VC.AAE: break; // AnitAliasing Enable
	//case VC.PCE: break; // Patch Cull Enable					
	//case VC.CTE: break; // Color Test Enable		
*/
