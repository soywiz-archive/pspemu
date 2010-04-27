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
	}

	// Frame Buffer Width
	auto OP_FBW() {
		gpu.state.drawBuffer.highAddress = command.extract!(ubyte, 16);
		gpu.state.drawBuffer.width       = command.extract!(ushort, 0);
		gpu.state.drawBuffer.mustLoad    = true;
	}

	// frame buffer Pixel Storage Mode
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
	// void sceGuScissor(int x, int y, int stopX, int stopY); // OP_SCISSOR1 + OP_SCISSOR2

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
	 * Set current viewport
	 *
	 * @par Example: Setup a viewport of size (480,272) with origo at (2048,2048)
	 * @code
	 * sceGuViewport(2048,2048,480,272);
	 * @endcode
	 *
	 * @param cx - Center for horizontal viewport
	 * @param cy - Center for vertical viewport
	 * @param width - Width of viewport
	 * @param height - Height of viewport
	 **/
	// void sceGuViewport(int cx, int cy, int width, int height); // OP_XSCALE + OP_YSCALE + OP_XPOS + OP_YPOS
	// sendCommandf(66,(float)(width>>1));
	// sendCommandf(67,(float)((-height)>>1));
	// sendCommandf(69,(float)cx);
	// sendCommandf(70,(float)cy);
	
	auto OP_XSCALE() { gpu.state.viewport.sx =  command.float1 * 2; }
	auto OP_YSCALE() { gpu.state.viewport.sy = -command.float1 * 2; }
	auto OP_ZSCALE() { gpu.state.viewport.sz = command.extractFixedFloat!(0, 16); }

	auto OP_XPOS  () { gpu.state.viewport.px = command.float1; }
	auto OP_YPOS  () { gpu.state.viewport.py = command.float1; }
	auto OP_ZPOS  () { gpu.state.viewport.pz = command.extractFixedFloat!(0, 16); }

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
	// void sceGuFrontFace(int order); // OP_FFACE
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
	// void sceGuShadeModel(int mode); // OP_SHADE
	auto OP_SHADE() {
		gpu.state.shadeModel = command.extractEnum!(ShadingModel);
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
	// void sceGuLogicalOp(int op); // OP_LOP
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
	//void sceGuOffset(unsigned int x, unsigned int y); // OP_OFFSETX + OP_OFFSETY

	auto OP_OFFSETX() { gpu.state.offsetX = command.extract!(uint, 0, 4); }
	auto OP_OFFSETY() { gpu.state.offsetY = command.extract!(uint, 0, 4); }
}