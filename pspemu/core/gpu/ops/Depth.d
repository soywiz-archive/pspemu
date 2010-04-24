module pspemu.core.gpu.ops.Depth;

template Gpu_Depth() {
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
	// void sceGuDepthFunc(int function); // OP_ZTST
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
	// void sceGuAlphaFunc(int func, int value, int mask); // OP_ATST
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
	// void sceGuStencilFunc(int func, int ref, int mask); // OP_STST
	// sendCommandi(220,func | ((ref & 0xff) << 8) | ((mask & 0xff) << 16));
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
	// void sceGuStencilOp(int fail, int zfail, int zpass); // OP_SOP

	// Stencil OPeration
	auto OP_SOP() {
		with (gpu.state) {
			stencilOperationSfail  = command.extractEnum!(StencilOperations,  0);
			stencilOperationDpfail = command.extractEnum!(StencilOperations,  8);
			stencilOperationDppass = command.extractEnum!(StencilOperations, 16);
		}
	}

	/**
	 * Mask depth buffer writes
	 *
	 * @param mask - GU_TRUE(1) to disable Z writes, GU_FALSE(0) to enable
	 **/
	// void sceGuDepthMask(int mask);

	// glDepthMask
	auto OP_ZMSK() { gpu.state.depthMask = command.extract!(ushort); }

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
	// void sceGuDepthRange(int near, int far); // OP_NEARZ + OP_FARZ
	// void sceGuDepthOffset(unsigned int offset);
	auto OP_NEARZ() { gpu.state.depthRangeNear = command.extractFixedFloat!(0, 16); }
	auto OP_FARZ () { gpu.state.depthRangeFar  = command.extractFixedFloat!(0, 16); }
}
