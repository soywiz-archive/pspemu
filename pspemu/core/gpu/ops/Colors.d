module pspemu.core.gpu.ops.Colors;

template Gpu_Colors() {
	/**
	 * Set current primitive color
	 *
	 * @param color - Which color to use (overriden by vertex-colors)
	 **/
	// void sceGuColor(unsigned int color); // sceGuMaterial(7, color); // OP_AMC + OP_AMA + OP_DMC + OP_SMC

	// void sceGuMaterial(int mode, int color); // if (mode & 1) { OP_AMC + OP_AMA } if (mode & 2) { OP_DMC } if (mode & 4) { OP_SMC }
	// void sceGuModelColor(unsigned int emissive, unsigned int ambient, unsigned int diffuse, unsigned int specular); // OP_EMC + OP_DMC + OP_AMC + OP_SMC
	// void sceGuAmbientColor(unsigned int color); // OP_AMC + OP_AMA
	// void sceGuAmbient(unsigned int color); // OP_ALC + OP_ALA

	// Diffuse Model Color
	auto OP_DMC() { gpu.state.diffuseModelColor.rgb[] = command.float3[]; }

	// Specular Model Color
	auto OP_SMC() { gpu.state.specularModelColor.rgb[] = command.float3[]; }

	// Emissive Model Color
	auto OP_EMC() { gpu.state.emissiveModelColor.rgb[] = command.float3[]; }

	// Ambient Model Color/Alpha
	auto OP_AMC() { gpu.state.ambientModelColor.rgb[] = command.float3[]; }
	auto OP_AMA() { gpu.state.ambientModelColor.alpha = command.float4[0]; }

	// Ambient Light Color/Alpha
	auto OP_ALC() { gpu.state.ambientLightColor.rgb[] = command.float3[]; }
	auto OP_ALA() { gpu.state.ambientLightColor.alpha = command.float4[0]; }

	/**
	 * Set which color components that the material will receive
	 *
	 * The components are ORed together from the following values:
	 *   - GU_AMBIENT
	 *   - GU_DIFFUSE
	 *   - GU_SPECULAR
	 *
	 * @param components - Which components to receive
	 **/
	// void sceGuColorMaterial(int components); // OP_CMAT
	// Material Color
	auto OP_CMAT() { gpu.state.materialColorComponents = command.extractSet!(LightComponents); }

	/**
	 * Specify the texture environment color
	 *
	 * This is used in the texture function when a constant color is needed.
	 *
	 * See sceGuTexFunc() for more information.
	 *
	 * @param color - Constant color (0x00BBGGRR)
	 **/
	// void sceGuTexEnvColor(unsigned int color); // OP_TEC
	// Texture Environment Color
	auto OP_TEC() { gpu.state.textureEnviromentColor.rgb[] = command.float3[]; }

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

	/**
	 * Set mask for which bits of the pixels to write
	 *
	 * @param mask - Which bits to filter against writes
	 **/
	// void sceGuPixelMask(unsigned int mask);
	
	// Pixel MasK Color
	auto OP_PMSKC() {
		gpu.state.colorMask[0] = command.extract!(bool,  0, 8);
		gpu.state.colorMask[1] = command.extract!(bool,  8, 8);
		gpu.state.colorMask[2] = command.extract!(bool, 16, 8);
	}
	// Pixel MasK Alpha
	auto OP_PMSKA() {
		gpu.state.colorMask[3] = command.extract!(bool, 0, 8);
	}
}
