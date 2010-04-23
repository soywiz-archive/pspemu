module pspemu.core.gpu.ops.Special;

template Gpu_Special() {
	/**
	 * Set draw buffer parameters (and store in context for buffer-swap)
	 *
	 * Available pixel formats are:
	 *   - GU_PSM_5650
	 *   - GU_PSM_5551
	 *   - GU_PSM_4444
	 *   - GU_PSM_8888
	 *
	 * @par Example: Setup a standard 16-bit draw buffer
	 * @code
	 * sceGuDrawBuffer(GU_PSM_5551,(void*)0,512);
	 * @endcode
	 *
	 * @param psm - Pixel format to use for rendering (and display)
	 * @param fbp - VRAM pointer to where the draw buffer starts
	 * @param fbw - Frame buffer width (block aligned)
	 **/
	// void sceGuDrawBuffer(int psm, void* fbp, int fbw);

	// Frame Buffer Pointer
	auto OP_FBP() {
		gpu.state.drawBuffer.lowAddress = command.param24;
		gpu.state.drawBuffer.mustLoad = true;
	}

	// Frame Buffer Width
	auto OP_FBW() {
		gpu.state.drawBuffer.highAddress = command.extract!(ubyte, 16);
		gpu.state.drawBuffer.width       = command.extract!(ushort, 0);
	}

	/**
	 * Set depth buffer parameters
	 *
	 * @param zbp - VRAM pointer where the depthbuffer should start
	 * @param zbw - The width of the depth-buffer (block-aligned)
	 *
	 **/
	// void sceGuDepthBuffer(void* zbp, int zbw);

	// Depth Buffer Pointer
	auto OP_ZBP() {
		gpu.state.depthBuffer.lowAddress = command.param24;
		gpu.state.depthBuffer.mustLoad   = true;
	}

	// Depth Buffer Width
	auto OP_ZBW() {
		gpu.state.depthBuffer.highAddress = command.extract!(ubyte, 16);
		gpu.state.depthBuffer.width       = command.extract!(ushort, 0);
	}

	// texture Pixel Storage Mode
	auto OP_PSM() {
		gpu.state.drawBuffer.format = command.extractEnum!(PixelFormats);
	}
	
	/**
	 * Set what to scissor within the current framebuffer
	 *
	 * Note that scissoring is only performed if the custom scissoring is enabled (GU_SCISSOR_TEST)
	 *
	 * @param x - Left of scissor region
	 * @param y - Top of scissor region
	 * @param stopX - Right of scissor region
	 * @param stopY - Bottom of scissor region
	 **/
	// void sceGuScissor(int x, int y, int stopX, int stopY); 

	// SCISSOR start (1)
	auto OP_SCISSOR1() {
		with (gpu.state) {
			scissor.x1 = command.extract!(ushort,  0, 10);
			scissor.y1 = command.extract!(ushort, 10, 20);
		}
	}

	// SCISSOR end (2)
	auto OP_SCISSOR2() {
		with (gpu.state) {
			scissor.x2 = command.extract!(ushort,  0, 10);
			scissor.y2 = command.extract!(ushort, 10, 20);
		}
	}

	/**
	 * Set the current face-order (for culling)
	 *
	 * This only has effect when culling is enabled (GU_CULL_FACE)
	 *
	 * Culling order can be:
	 *   - GU_CW - Clockwise primitives are not culled
	 *   - GU_CCW - Counter-clockwise are not culled
	 *
	 * @param order - Which order to use
	 **/
	// void sceGuFrontFace(int order);
	auto OP_FFACE() {
		gpu.state.frontFaceDirection = command.extractEnum!(FrontFaceDirection);
	}

	/**
	 * Set how primitives are shaded
	 *
	 * The available shading-methods are:
	 *   - GU_FLAT - Primitives are flatshaded, the last vertex-color takes effet
	 *   - GU_SMOOTH - Primtives are gouraud-shaded, all vertex-colors take effect
	 *
	 * @param mode - Which mode to use
	**/
	// void sceGuShadeModel(int mode);
	auto OP_SHADE() {
		gpu.state.shadeModel = command.extractEnum!(ShadingModel);
	}

	/**
	 * Select which depth-test function to use
	 *
	 * Valid choices for the depth-test are:
	 *   - GU_NEVER - No pixels pass the depth-test
	 *   - GU_ALWAYS - All pixels pass the depth-test
	 *   - GU_EQUAL - Pixels that match the depth-test pass
	 *   - GU_NOTEQUAL - Pixels that doesn't match the depth-test pass
	 *   - GU_LESS - Pixels that are less in depth passes
	 *   - GU_LEQUAL - Pixels that are less or equal in depth passes
	 *   - GU_GREATER - Pixels that are greater in depth passes
	 *   - GU_GEQUAL - Pixels that are greater or equal passes
	 *
	 * @param function - Depth test function to use
	 **/
	// void sceGuDepthFunc(int function);
	auto OP_ZTST() {
		gpu.state.depthFunc = command.extractEnum!(TestFunction);
	}

	/**
	 * Set the alpha test parameters
	 * 
	 * Available comparison functions are:
	 *   - GU_NEVER
	 *   - GU_ALWAYS
	 *   - GU_EQUAL
	 *   - GU_NOTEQUAL
	 *   - GU_LESS
	 *   - GU_LEQUAL
	 *   - GU_GREATER
	 *   - GU_GEQUAL
	 *
	 * @param func - Specifies the alpha comparison function.
	 * @param value - Specifies the reference value that incoming alpha values are compared to.
	 * @param mask - Specifies the mask that both values are ANDed with before comparison.
	 **/
	// void sceGuAlphaFunc(int func, int value, int mask);
	auto OP_ATST() {
		with (gpu.state) {
			alphaTestFunc  = command.extractEnum!(TestFunction, 0);
			alphaTestValue = command.extractFixedFloat!(8, 8);
			alphaTestMask  = command.extract!(ubyte, 16);
		}
	}

	/**
	 * Set stencil function and reference value for stencil testing
	 *
	 * Available functions are:
	 *   - GU_NEVER
	 *   - GU_ALWAYS
	 *   - GU_EQUAL
	 *   - GU_NOTEQUAL
	 *   - GU_LESS
	 *   - GU_LEQUAL
	 *   - GU_GREATER
	 *   - GU_GEQUAL
	 *
	 * @param func - Test function
	 * @param ref - The reference value for the stencil test
	 * @param mask - Mask that is ANDed with both the reference value and stored stencil value when the test is done
	 **/
	// void sceGuStencilFunc(int func, int ref, int mask);
	// Stencil Test
	auto OP_STST() {
		with (gpu.state) {
			stencilFuncFunc = command.extractEnum!(TestFunction, 0);
			stencilFuncRef  = command.extract!(ubyte,  8);
			stencilFuncMask = command.extract!(ubyte, 16);
		}
	}

	/**
	 * Set the stencil test actions
	 *
	 * Available actions are:
	 *   - GU_KEEP - Keeps the current value
	 *   - GU_ZERO - Sets the stencil buffer value to zero
	 *   - GU_REPLACE - Sets the stencil buffer value to ref, as specified by sceGuStencilFunc()
	 *   - GU_INCR - Increments the current stencil buffer value
	 *   - GU_DECR - Decrease the current stencil buffer value
	 *   - GU_INVERT - Bitwise invert the current stencil buffer value
	 *
	 * As stencil buffer shares memory with framebuffer alpha, resolution of the buffer
	 * is directly in relation.
	 *
	 * @param fail - The action to take when the stencil test fails
	 * @param zfail - The action to take when stencil test passes, but the depth test fails
	 * @param zpass - The action to take when both stencil test and depth test passes
	 **/
	// void sceGuStencilOp(int fail, int zfail, int zpass);

	// Stencil OPeration
	auto OP_SOP() {
		with (gpu.state) {
			stencilOperationSfail  = command.extractEnum!(StencilOperations,  0);
			stencilOperationDpfail = command.extractEnum!(StencilOperations,  8);
			stencilOperationDppass = command.extractEnum!(StencilOperations, 16);
		}
	}

	/**
	 * Set color logical operation
	 *
	 * Available operations are:
	 *   - GU_CLEAR
	 *   - GU_AND
	 *   - GU_AND_REVERSE 
	 *   - GU_COPY
	 *   - GU_AND_INVERTED
	 *   - GU_NOOP
	 *   - GU_XOR
	 *   - GU_OR
	 *   - GU_NOR
	 *   - GU_EQUIV
	 *   - GU_INVERTED
	 *   - GU_OR_REVERSE
	 *   - GU_COPY_INVERTED
	 *   - GU_OR_INVERTED
	 *   - GU_NAND
	 *   - GU_SET
	 *
	 * This operation only has effect if GU_COLOR_LOGIC_OP is enabled.
	 *
	 * @param op - Operation to execute
	 **/
	// void sceGuLogicalOp(int op);
	// Logical Operation
	auto OP_LOP() {
		gpu.state.logicalOperation = command.extractEnum!(LogicalOperation);
	}

	/**
	 * Set virtual coordinate offset
	 *
	 * The PSP has a virtual coordinate-space of 4096x4096, this controls where rendering is performed
	 * 
	 * @par Example: Center the virtual coordinate range
	 * @code
	 * sceGuOffset(2048-(480/2),2048-(480/2));
	 * @endcode
	 *
	 * @param x - Offset (0-4095)
	 * @param y - Offset (0-4095)
	 */
	//void sceGuOffset(unsigned int x, unsigned int y);
	auto OP_OFFSETX() {
		command.extract!(uint, 4);
	}

	auto OP_OFFSETY() {
		command.extract!(uint, 4);
	}
}