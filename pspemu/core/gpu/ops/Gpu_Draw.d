module pspemu.core.gpu.ops.Gpu_Draw;

//debug = EXTRACT_PRIM;
//debug = EXTRACT_PRIM_COMPONENT;
//debug = DEBUG_DRAWING;
//debug = DEBUG_MATRIX;

static assert(byte.sizeof  == 1);
static assert(short.sizeof == 2);
static assert(float.sizeof == 4);

import std.datetime;
import std.math;
import pspemu.utils.MathUtils;
import pspemu.utils.BitUtils;

template Gpu_Draw() {
	/**
	 * Set the current clear-color
	 *
	 * @param color - Color to clear with
	 **/
	// void sceGuClearColor(unsigned int color);

	/**
	 * Set the current clear-depth
	 *
	 * @param depth - Set which depth to clear with (0x0000-0xffff)
	 **/
	// void sceGuClearDepth(unsigned int depth);

	/**
	 * Set the current stencil clear value
	 *
	 * @param stencil - Set which stencil value to clear with (0-255)
	 **/
	// void sceGuClearStencil(unsigned int stencil);

	/**
	 * Clear current drawbuffer
	 *
	 * Available clear-flags are (OR them together to get final clear-mode):
	 *   - GU_COLOR_BUFFER_BIT   - Clears the color-buffer
	 *   - GU_STENCIL_BUFFER_BIT - Clears the stencil-buffer
	 *   - GU_DEPTH_BUFFER_BIT   - Clears the depth-buffer
	 *
	 * @param flags - Which part of the buffer to clear
	 **/
	// void sceGuClear(int flags);

	auto OP_CLEAR() {
		// Set flags.
		if (command.extract!(bool, 0, 1)) {
			gpu.state.clearFlags = cast(ClearBufferMask)command.extract!(ubyte, 8, 8);
			gpu.state.clearingMode = true;
			// @TODO: Check which buffers are going to be used (using the state).
			gpu.performBufferOp(BufferOperation.LOAD, BufferType.ALL);
		}
		// Clear actually.
		else {
			//gpu.impl.clear();
			// @TODO: Check which buffers have been updated (using the state).
			gpu.markBufferOp(BufferOperation.STORE, BufferType.ALL);

			gpu.state.clearingMode = false;
		}
		
		debug (DEBUG_DRAWING) writefln("CLEAR(0x%08X, %d)", gpu.state.drawBuffer.address, command.extract!(bool, 0, 1));
	}

	/**
	 * Draw array of vertices forming primitives
	 *
	 * Available primitive-types are:
	 *   - GU_POINTS         - Single pixel points (1 vertex per primitive)
	 *   - GU_LINES          - Single pixel lines (2 vertices per primitive)
	 *   - GU_LINE_STRIP     - Single pixel line-strip (2 vertices for the first primitive, 1 for every following)
	 *   - GU_TRIANGLES      - Filled triangles (3 vertices per primitive)
	 *   - GU_TRIANGLE_STRIP - Filled triangles-strip (3 vertices for the first primitive, 1 for every following)
	 *   - GU_TRIANGLE_FAN   - Filled triangle-fan (3 vertices for the first primitive, 1 for every following)
	 *   - GU_SPRITES        - Filled blocks (2 vertices per primitive)
	 *
	 * The vertex-type decides how the vertices align and what kind of information they contain.
	 * The following flags are ORed together to compose the final vertex format:
	 *   - GU_TEXTURE_8BIT   - 8-bit texture coordinates
	 *   - GU_TEXTURE_16BIT  - 16-bit texture coordinates
	 *   - GU_TEXTURE_32BITF - 32-bit texture coordinates (float)
	 *
	 *   - GU_COLOR_5650     - 16-bit color (R5G6B5A0)
	 *   - GU_COLOR_5551     - 16-bit color (R5G5B5A1)
	 *   - GU_COLOR_4444     - 16-bit color (R4G4B4A4)
	 *   - GU_COLOR_8888     - 32-bit color (R8G8B8A8)
	 *
	 *   - GU_NORMAL_8BIT    - 8-bit normals
	 *   - GU_NORMAL_16BIT   - 16-bit normals
	 *   - GU_NORMAL_32BITF  - 32-bit normals (float)
	 *
	 *   - GU_VERTEX_8BIT    - 8-bit vertex position
	 *   - GU_VERTEX_16BIT   - 16-bit vertex position
	 *   - GU_VERTEX_32BITF  - 32-bit vertex position (float)
	 *
	 *   - GU_WEIGHT_8BIT    - 8-bit weights
	 *   - GU_WEIGHT_16BIT   - 16-bit weights
	 *   - GU_WEIGHT_32BITF  - 32-bit weights (float)
	 *
	 *   - GU_INDEX_8BIT     - 8-bit vertex index
	 *   - GU_INDEX_16BIT    - 16-bit vertex index
	 *
	 *   - GU_WEIGHTS(n)     - Number of weights (1-8)
	 *   - GU_VERTICES(n)    - Number of vertices (1-8)
	 *
	 *   - GU_TRANSFORM_2D   - Coordinate is passed directly to the rasterizer
	 *   - GU_TRANSFORM_3D   - Coordinate is transformed before passed to rasterizer
	 *
	 * @note Every vertex has to be aligned to the maxium size of all of its component.
	 *
	 * Vertex order:
	 * [for vertices(1-8)]
	 *     [weights (0-8)]
	 *     [texture uv]
	 *     [color]
	 *     [normal]
	 *     [vertex]
	 * [/for]
	 *
	 * @par Example: Render 400 triangles, with floating-point texture coordinates, and floating-point position, no indices
	 *
	 * <code>
	 *     sceGuDrawArray(GU_TRIANGLES, GU_TEXTURE_32BITF | GU_VERTEX_32BITF, 400 * 3, 0, vertices);
	 * </code>
	 *
	 * @param prim     - What kind of primitives to render
	 * @param vtype    - Vertex type to process
	 * @param count    - How many vertices to process
	 * @param indices  - Optional pointer to an index-list
	 * @param vertices - Pointer to a vertex-list
	 **/
	//void sceGuDrawArray(int prim, int vtype, int count, const void* indices, const void* vertices);

	// Vertex Type
	auto OP_VTYPE() {
		gpu.state.vertexType.v  = command.extract!(uint, 0, 24);
		//writefln("VTYPE:%032b", command.param24);
		//writefln("     :%d", gpu.state.vertexType.position);
	}

	// Base Address Register
	auto OP_BASE() {
		gpu.state.baseAddress = (command.param24 << 8);
	}

	// Vertex List (Base Address)
	auto OP_VADDR() {
		gpu.state.vertexAddress = gpu.state.baseAddress + command.param24;
	}

	// Index List (Base Address)
	auto OP_IADDR() {
		gpu.state.indexAddress = gpu.state.baseAddress + command.param24;
	}
	
	// http://en.wikipedia.org/wiki/Bernstein_polynomial
    float[4] bernsteinCoefficients(float u) {
    	static if (false) {
	    	float uPow1  = u;
	        float uPow2  = uPow1 * uPow1;
	        float uPow3  = uPow2 * uPow1;
	
			// Complementary.
	        float u1Pow1 = 1 - u;
	        float u1Pow2 = Pow1 * Pow1;
	        float u1Pow3 = u1Pow2 * Pow1;
	
	    	float[4] ret = [
	    		(u1Pow3),
	    		(3 * uPow1 * u1Pow2),
	    		(3 * uPow2 * u1Pow1),
	    		(uPow3)
	    	];
	    } else {
	    	float u0 = u - 0;
	    	float u1 = 1 - u;
	    	float[4] ret = [
	    		(u1 ^^ 3),
	    		(3 * (u0 ^^ 1) * (u1 ^^ 2)),
	    		(3 * (u1 ^^ 1) * (u0 ^^ 2)),
	    		(u0 ^^ 3)
	    	];
	    }

        return ret;
    }

	// Bezier Patch Kick
	auto OP_BEZIER() {
		int ucount = command.extract!(ubyte, 0,  8);
		int vcount = command.extract!(ubyte, 8, 16);
        int utype  = command.extract!(ubyte, 16, 2);
        int vtype  = command.extract!(ubyte, 18, 2);
        
	    int[] spline_knot(int n, int type) {
	        int[] knot = new int[n + 5];
	        foreach (i; 0..n - 1) {
				knot[i + 3] = i;
	        }
	
	        if ((type & 1) == 0) {
				knot[0] = -3;
				knot[1] = -2;
				knot[2] = -1;
	        }

	        if ((type & 2) == 0) {
				knot[n + 2] = n - 1;
				knot[n + 3] = n;
				knot[n + 4] = n + 1;
	        } else {
				knot[n + 2] = n - 2;
				knot[n + 3] = n - 2;
				knot[n + 4] = n - 2;
	        }
	
	        return knot;
	    }
		
		auto vertexPointerBase = gpu.memory.getPointerOrNull!ubyte(gpu.state.vertexAddress);
		auto indexPointerBase  = gpu.memory.getPointerOrNull!ubyte(gpu.state.indexAddress);
		auto vertexType        = gpu.state.vertexType;

		if ((ucount - 1) % 3 != 0 || (vcount - 1) % 3 != 0) {
			Logger.log(Logger.Level.ERROR, "Gpu", std.string.format("Unsupported bezier parameters ucount=%d vcount=%d", ucount, vcount));
            return;
        }
		
		Logger.log(Logger.Level.INFO, "Gpu", "BEZIER(ucount=%d, vcount=%d, div_s=%d, div_t=%d)", ucount, vcount, gpu.state.patch.div_s, gpu.state.patch.div_t);
		
		uint indexCount = ucount * vcount;
		
		/*
		VertexState controlPoints(int u, int v) {
			return vertexListBuffer[indexListBuffer[v + u * ucount]];
		}
		*/
		
		uint maxVertexCount;
		gpu.impl.readIndexes(indexListBuffer, indexPointerBase, indexCount, maxVertexCount, vertexType);
		gpu.impl.readVertices(vertexListBuffer, vertexPointerBase, maxVertexCount, vertexType, gpu.state.morphWeights, gpu.state.boneMatrix);
		
		Logger.log(Logger.Level.TRACE, "Gpu", "VERTEX_TYPE: %s", vertexType);
		foreach (n; 0..maxVertexCount) {
			Logger.log(Logger.Level.TRACE, "Gpu", "VERTEX: %d - %s", indexListBuffer[n], vertexListBuffer[indexListBuffer[n]].toString(vertexType));
		}

		/*
		{
			int n = ucount - 1;
			int m = vcount - 1;
			
			int[] knot_u = spline_knot(n, utype);
			int[] knot_v = spline_knot(m, vtype);
			
			float limit = 2.000001f;
		}
		*/
		
		gpu.performBufferOp(BufferOperation.LOAD, BufferType.ALL);
		
		gpu.impl.draw(
			indexListBuffer[0..indexCount],
			vertexListBuffer[0..maxVertexCount],
			//PrimitiveType.GU_TRIANGLE_STRIP,
			PrimitiveType.GU_LINE_STRIP,
			vertexType.getPrimitiveFlags
		);
		
		gpu.markBufferOp(BufferOperation.STORE, BufferType.ALL);
	}
	
	VertexState[] vertexListBuffer;
	ushort[] indexListBuffer;
	//VertexStateArrays vertexListBufferArrays;
	
	// draw PRIMitive
	// Primitive Kick
	auto OP_PRIM() {
		debug (DEBUG_MATRIX) {
			writefln("gpu.state.viewMatrix:\n%s", gpu.state.viewMatrix);
			writefln("gpu.state.worldMatrix:\n%s", gpu.state.worldMatrix);
			writefln("gpu.state.projectionMatrix:\n%s", gpu.state.projectionMatrix);
		}

		auto vertexPointerBase = gpu.memory.getPointerOrNull!ubyte(gpu.state.vertexAddress);
		auto indexPointerBase  = gpu.memory.getPointerOrNull!ubyte(gpu.state.indexAddress);

		auto primitiveType = command.extractEnum!(PrimitiveType, 16);
		auto vertexType    = gpu.state.vertexType;
		int  vertexSize    = vertexType.vertexSize;
		auto vertexCount   = command.param16;
		//auto morphingVertexCount    = vertexType.morphingVertexCount;
		//int  vertexSizeWithMorph    = vertexSize * morphingVertexCount;
		
		//float[] morphWeights = gpu.state.morphWeights;
		
		//if (vertexType.morphingVertexCount == 1) gpu.state.morphWeights[0] = 1.0;

		debug (EXTRACT_PRIM) writefln(
			"Prim(%d) PrimitiveType(%d) Size(%d)"
			" skinningWeightCount(%d)"
			" weight(%d)"
			" color(%d)"
			" texture(%d)"
			" position(%d)"
			" normal(%d)"
			" clearingMode(%d)"
			,
			vertexCount, primitiveType, vertexSize,
			vertexType.skinningWeightCount,
			vertexType.weight,
			vertexType.color,
			vertexType.texture,
			vertexType.position,
			vertexType.normal,
			gpu.state.clearingMode
		);
		
		//vertexListBufferArrays.reserve(vertexCount);
		
		uint indexCount = vertexCount;
		uint maxVertexCount;
		
		gpu.vertexExtractionStopWatch.start();
		{
			gpu.impl.readIndexes(indexListBuffer, indexPointerBase, indexCount, maxVertexCount, vertexType);
			gpu.impl.readVertices(vertexListBuffer, vertexPointerBase, maxVertexCount, vertexType, gpu.state.morphWeights, gpu.state.boneMatrix);
		}
		gpu.vertexExtractionStopWatch.stop();
		
		// Need to have the framebuffer updated.
		// @TODO: Check which buffers are going to be used (using the state).
		if (gpu.drawBufferTransferEnabled) gpu.performBufferOp(BufferOperation.LOAD, BufferType.ALL);
		try {
			gpu.impl.draw(
				indexListBuffer[0..indexCount],
				vertexListBuffer[0..maxVertexCount],
				primitiveType,
				vertexType.getPrimitiveFlags
			);
		} catch (Throwable o) {
			writefln("gpu.impl.draw Error: %s", o);
			//throw(o);
		}
		debug (DEBUG_DRAWING) {
			writefln("PRIM(0x%08X, %d, %d)", gpu.state.drawBuffer.address, primitiveType, vertexCount);
		}
		// Now we should store the updated framebuffer when required.
		// @TODO: Check which buffers have been updated (using the state).
		//gpu.impl.test("prim");
		//if (gpu.drawBufferTransferEnabled)
		{
			gpu.markBufferOp(BufferOperation.STORE, BufferType.ALL);
		}
		
		gpu.numberOfPrimsTemp++;
		gpu.numberOfVerticesTemp += vertexCount;
	}

	/**
	 * Image transfer using the GE
	 *
	 * @note Data must be aligned to 1 quad word (16 bytes)
	 *
	 * @par Example: Copy a fullscreen 32-bit image from RAM to VRAM
	 *
	 * <code>
	 *     sceGuCopyImage(GU_PSM_8888,0,0,480,272,512,pixels,0,0,512,(void*)(((unsigned int)framebuffer)+0x4000000));
	 * </code>
	 *
	 * @param psm    - Pixel format for buffer
	 * @param sx     - Source X
	 * @param sy     - Source Y
	 * @param width  - Image width
	 * @param height - Image height
	 * @param srcw   - Source buffer width (block aligned)
	 * @param src    - Source pointer
	 * @param dx     - Destination X
	 * @param dy     - Destination Y
	 * @param destw  - Destination buffer width (block aligned)
	 * @param dest   - Destination pointer
	 **/
	// void sceGuCopyImage(int psm, int sx, int sy, int width, int height, int srcw, void* src, int dx, int dy, int destw, void* dest);
	// sendCommandi(178/*OP_TRXSBP*/,((unsigned int)src) & 0xffffff);
	// sendCommandi(179/*OP_TRXSBW*/,((((unsigned int)src) & 0xff000000) >> 8)|srcw);
	// sendCommandi(235/*OP_TRXSPOS*/,(sy << 10)|sx);
	// sendCommandi(180/*OP_TRXDBP*/,((unsigned int)dest) & 0xffffff);
	// sendCommandi(181/*OP_TRXDBW*/,((((unsigned int)dest) & 0xff000000) >> 8)|destw);
	// sendCommandi(236/*OP_TRXDPOS*/,(dy << 10)|dx);
	// sendCommandi(238/*OP_TRXSIZE*/,((height-1) << 10)|(width-1));
	// sendCommandi(234/*OP_TRXKICK*/,(psm ^ 0x03) ? 0 : 1);

	/*struct TextureTransfer {
		uint srcAddress, dstAddress;
		ushort srcLineWidth, dstLineWidth;
		ushort srcX, srcY, dstX, dstY;
		ushort width, height;
	}*/
	
	// TRansfer X Source (Buffer Pointer/Width)/POSition
	auto OP_TRXSBP() {
		with (gpu.state.textureTransfer) {
			srcAddress = (srcAddress & 0xFF000000) | command.extract!(uint, 0, 24);
		}
	}

	auto OP_TRXSBW() {
		with (gpu.state.textureTransfer) {
			srcAddress = (srcAddress & 0x00FFFFFF) | (command.extract!(uint, 16, 8) << 24);
			srcLineWidth = command.extract!(ushort, 0, 16);
			srcX = srcY = 0;
		}
	}

	auto OP_TRXSPOS() {
		with (gpu.state.textureTransfer) {
			srcX = command.extract!(ushort,  0, 10);
			srcY = command.extract!(ushort, 10, 10);
		}
	}

	// TRansfer X Destination (Buffer Pointer/Width)/POSition
	auto OP_TRXDBP() {
		with (gpu.state.textureTransfer) {
			dstAddress = (dstAddress & 0xFF000000) | command.extract!(uint, 0, 24);
		}
	}

	auto OP_TRXDBW() {
		with (gpu.state.textureTransfer) {
			dstAddress = (dstAddress & 0x00FFFFFF) | (command.extract!(uint, 16, 8) << 24);
			dstLineWidth = command.extract!(ushort, 0, 16);
			dstX = dstY = 0;
		}
	}
	
	auto OP_TRXDPOS() {
		with (gpu.state.textureTransfer) {
			dstX = command.extract!(ushort,  0, 10);
			dstY = command.extract!(ushort, 10, 10);
		}
	}

	// TRansfer X SIZE
	auto OP_TRXSIZE() {
		with (gpu.state.textureTransfer) {
			width  = cast(ushort)(command.extract!(ushort,  0, 10) + 1);
			height = cast(ushort)(command.extract!(ushort, 10, 10) + 1);
		}
	}

	// TRansfer X KICK
	auto OP_TRXKICK() {
		// Optimize: We can also perform the upload directly into the framebuffer.
		// That way we won't need to store into ram and loading again after. But this way is simpler.
		
		//return;
		
		// @TODO It's possible that we need to load and store the framebuffer, and/or update textures after that.
		gpu.state.textureTransfer.texelSize = command.extractEnum!(TextureTransfer.TexelSize);

		// Specific implementation
		// @TODO. Checks more compatibility?!
		if (
			(gpu.state.drawBuffer.isAnyAddressInBuffer([gpu.state.textureTransfer.dstAddress])) && // Check that the address we are writting in is in the frame buffer.
			(gpu.state.textureTransfer.dstLineWidth == gpu.state.drawBuffer.width) && // Check that the dstLineWidth is the same as the current frame buffer width
			(gpu.state.drawBuffer.pixelSize == gpu.state.textureTransfer.bpp) && // Check that the BPP is the same.
		1) {
			gpu.impl.fastTrxKickToFrameBuffer();
			return;
		}

		// Generic implementation.
		with (gpu.state.textureTransfer) {
			auto srcAddressHost = cast(ubyte*)gpu.memory.getPointer(srcAddress);
			auto dstAddressHost = cast(ubyte*)gpu.memory.getPointer(dstAddress);

			if (gpu.state.drawBuffer.isAnyAddressInBuffer([srcAddress, dstAddress])) {
				gpu.performBufferOp(BufferOperation.STORE, BufferType.COLOR);
			}

			for (int n = 0; n < height; n++) {
				int srcOffset = ((n + srcY) * srcLineWidth + srcX) * bpp;
				int dstOffset = ((n + dstY) * dstLineWidth + dstX) * bpp;
				(dstAddressHost + dstOffset)[0.. width * bpp] = (srcAddressHost + srcOffset)[0.. width * bpp];
				//writefln("%08X <- %08X :: [%d]", dstOffset, srcOffset, width * bpp);
			}
			//std.file.write("buffer", dstAddressHost[0..512 * 272 * 4]);
			
			if (gpu.state.drawBuffer.isAnyAddressInBuffer([dstAddress])) {
				//gpu.impl.test();
				//gpu.impl.test("trxkick");
				gpu.markBufferOp(BufferOperation.LOAD, BufferType.COLOR);
			}
			//gpu.impl.test();
		}

		debug (DEBUG_DRAWING) writefln("TRXKICK(%s)", gpu.state.textureTransfer);
	}
}
