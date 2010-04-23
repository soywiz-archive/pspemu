module pspemu.core.gpu.ops.Draw;

//debug = EXTRACT_PRIM;
//debug = EXTRACT_PRIM_COMPONENT;

static assert(byte.sizeof  == 1);
static assert(short.sizeof == 2);
static assert(float.sizeof == 4);

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
	 *   - GU_COLOR_BUFFER_BIT - Clears the color-buffer
	 *   - GU_STENCIL_BUFFER_BIT - Clears the stencil-buffer
	 *   - GU_DEPTH_BUFFER_BIT - Clears the depth-buffer
	 *
	 * @param flags - Which part of the buffer to clear
	 **/
	// void sceGuClear(int flags);

	auto OP_CLEAR() {
		// Set flags.
		if (command.param24 & 1) {
			gpu.state.clearFlags = cast(ClearBufferMask)command.extract!(ubyte, 8, 8);
			gpu.state.clearingMode = true;
			gpu.checkLoadFrameBuffer();
		}
		// Clear actually.
		else {
			//gpu.impl.clear();
			gpu.state.drawBuffer.mustStore = true;
			gpu.state.clearingMode = false;
		}
	}

	/**
	 * Draw array of vertices forming primitives
	 *
	 * Available primitive-types are:
	 *   - GU_POINTS - Single pixel points (1 vertex per primitive)
	 *   - GU_LINES - Single pixel lines (2 vertices per primitive)
	 *   - GU_LINE_STRIP - Single pixel line-strip (2 vertices for the first primitive, 1 for every following)
	 *   - GU_TRIANGLES - Filled triangles (3 vertices per primitive)
	 *   - GU_TRIANGLE_STRIP - Filled triangles-strip (3 vertices for the first primitive, 1 for every following)
	 *   - GU_TRIANGLE_FAN - Filled triangle-fan (3 vertices for the first primitive, 1 for every following)
	 *   - GU_SPRITES - Filled blocks (2 vertices per primitive)
	 *
	 * The vertex-type decides how the vertices align and what kind of information they contain.
	 * The following flags are ORed together to compose the final vertex format:
	 *   - GU_TEXTURE_8BIT - 8-bit texture coordinates
	 *   - GU_TEXTURE_16BIT - 16-bit texture coordinates
	 *   - GU_TEXTURE_32BITF - 32-bit texture coordinates (float)
	 *
	 *   - GU_COLOR_5650 - 16-bit color (R5G6B5A0)
	 *   - GU_COLOR_5551 - 16-bit color (R5G5B5A1)
	 *   - GU_COLOR_4444 - 16-bit color (R4G4B4A4)
	 *   - GU_COLOR_8888 - 32-bit color (R8G8B8A8)
	 *
	 *   - GU_NORMAL_8BIT - 8-bit normals
	 *   - GU_NORMAL_16BIT - 16-bit normals
	 *   - GU_NORMAL_32BITF - 32-bit normals (float)
	 *
	 *   - GU_VERTEX_8BIT - 8-bit vertex position
	 *   - GU_VERTEX_16BIT - 16-bit vertex position
	 *   - GU_VERTEX_32BITF - 32-bit vertex position (float)
	 *
	 *  - GU_WEIGHT_8BIT - 8-bit weights
	 *   - GU_WEIGHT_16BIT - 16-bit weights
	 *   - GU_WEIGHT_32BITF - 32-bit weights (float)
	 *
	 *   - GU_INDEX_8BIT - 8-bit vertex index
	 *   - GU_INDEX_16BIT - 16-bit vertex index
	 *
	 *   - GU_WEIGHTS(n) - Number of weights (1-8)
	 *   - GU_VERTICES(n) - Number of vertices (1-8)
	 *
	 *   - GU_TRANSFORM_2D - Coordinate is passed directly to the rasterizer
	 *   - GU_TRANSFORM_3D - Coordinate is transformed before passed to rasterizer
	 *
	 * @note Every vertex must align to 32 bits, which means that you HAVE to pad if it does not add up!
	 *
	 * Vertex order:
	 * [for vertices(1-8)]
	 * [weights (0-8)]
	 * [texture uv]
	 * [color]
	 * [normal]
	 * [vertex]
	 * [/for]
	 *
	 * @par Example: Render 400 triangles, with floating-point texture coordinates, and floating-point position, no indices
	 * @code
	 * sceGuDrawArray(GU_TRIANGLES,GU_TEXTURE_32BITF|GU_VERTEX_32BITF,400*3,0,vertices);
	 * @endcode
	 *
	 * @param prim - What kind of primitives to render
	 * @param vtype - Vertex type to process
	 * @param count - How many vertices to process
	 * @param indices - Optional pointer to an index-list
	 * @param vertices - Pointer to a vertex-list
	 **/
	//void sceGuDrawArray(int prim, int vtype, int count, const void* indices, const void* vertices);

	// Vertex Type
	auto OP_VTYPE() {
		gpu.state.vertexType.v = command.param24;
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

	VertexState[] vertexListBuffer;
	
	// draw PRIMitive
	auto OP_PRIM() {
		auto vertexPointerBase = cast(ubyte*)gpu.memory.getPointer(gpu.state.vertexAddress);
		auto indexPointerBase  = gpu.state.indexAddress ? cast(ubyte*)gpu.memory.getPointer(gpu.state.indexAddress) : null;

		ubyte* vertexPointer = vertexPointerBase;
		ubyte* indexPointer  = indexPointerBase;

		auto vertexCount   = command.param16;
		auto primitiveType = command.extractEnum!(PrimitiveType, 16);
		auto vertexType    = gpu.state.vertexType;
		int  vertexSize    = vertexType.vertexSize;

		debug (EXTRACT_PRIM) writefln(
			"Prim(%d) PrimitiveType(%d) Size(%d)"
			" skinningWeightCount(%d)"
			" weight(%d)"
			" color(%d)"
			" texture(%d)"
			" position(%d)"
			" normal(%d)"
			,
			vertexCount, primitiveType, vertexSize,
			vertexType.skinningWeightCount,
			vertexType.weight,
			vertexType.color,
			vertexType.texture,
			vertexType.position,
			vertexType.normal
		);
		
		void pad(ref ubyte* ptr, ubyte pad) {
			if ((cast(uint)ptr) % pad) ptr += (pad - ((cast(uint)ptr) % pad));
		}

		void moveIndexGen(T)() {
			auto TIndexPointer = cast(T *)indexPointer;
			vertexPointer = vertexPointerBase + (*TIndexPointer * vertexSize);
			indexPointer += T.sizeof;
		}

		void extractArray(T)(float[] array) {
			pad(vertexPointer, T.sizeof);
			foreach (ref value; array) {
				debug (EXTRACT_PRIM_COMPONENT) writefln("%08X(%s):%s", cast(uint)cast(void *)vertexPointer, typeid(T), *cast(T*)vertexPointer);
				value = *cast(T*)vertexPointer;
				vertexPointer += T.sizeof;
			}
		}
		void extractColor8888(float[] array) {
			pad(vertexPointer, 4);
			for (int n = 0; n < 4; n++) {
				array[n] = cast(float)vertexPointer[n] / 255.0;
			}
			vertexPointer += 4;
		}
		void extractColor8bits (float[] array) {
			pad(vertexPointer, 1);
			// palette?
			writefln("Unimplemented Gpu.OP_PRIM.extractColor8bits");
			//throw(new Exception("Unimplemented Gpu.OP_PRIM.extractColor8bits"));
			vertexPointer += 1;
		}
		void extractColor16bits(float[] array) {
			pad(vertexPointer, 2);
			writefln("Unimplemented Gpu.OP_PRIM.extractColor16bits");
			//throw(new Exception("Unimplemented Gpu.OP_PRIM.extractColor16bits"));
			vertexPointer += 2;
		}

		auto extractTable      = [null, &extractArray!(byte), &extractArray!(short), &extractArray!(float)];
		auto extractColorTable = [null, &extractColor8bits, &extractColor8bits, &extractColor8bits, &extractColor16bits, &extractColor16bits, &extractColor16bits, &extractColor8888];
		auto moveIndexTable    = [null, &moveIndexGen!(ubyte), &moveIndexGen!(ushort), &moveIndexGen!(uint)];

		auto extractWeights  = vertexType.skinningWeightCount ? &extractArray!(float) : null;
		auto extractTexture  = extractTable[vertexType.texture ];
		auto extractPosition = extractTable[vertexType.position];
		auto extractNormal   = extractTable[vertexType.normal  ];
		auto extractColor    = extractColorTable[vertexType.color];
		auto moveIndex       = (indexPointer !is null) ? moveIndexTable[vertexType.index] : null;

		void extractVertex(ref VertexState vertex) {
			if (moveIndex) moveIndex();
			
			if (extractWeights) {
				extractWeights(vertex.weights[0..vertexType.skinningWeightCount]);
				debug (EXTRACT_PRIM) writef("| weights(...) ");
			}

			if (extractTexture) {
				extractTexture((&vertex.u)[0..2]);
				debug (EXTRACT_PRIM) writef("| texture(%f, %f) ", vertex.u, vertex.v);
			}
			if (extractColor) {
				extractColor((&vertex.r)[0..4]);
				debug (EXTRACT_PRIM) writef("| color(%f, %f, %f, %f) ", vertex.r, vertex.g, vertex.b, vertex.a);
			}
			if (extractNormal) {
				extractNormal((&vertex.nx)[0..3]);
				debug (EXTRACT_PRIM) writef("| normal(%f, %f, %f) ", vertex.nx, vertex.ny, vertex.nz);
			}
			if (extractPosition) {
				extractPosition((&vertex.px)[0..3]);
				debug (EXTRACT_PRIM) writef("| position(%f, %f, %f) ", vertex.px, vertex.py, vertex.pz);
			}
			debug (EXTRACT_PRIM) writefln("");
		}

		if (vertexListBuffer.length < vertexCount) vertexListBuffer.length = vertexCount;
		for (int n = 0; n < vertexCount; n++) extractVertex(vertexListBuffer[n]);

		gpu.checkLoadFrameBuffer();
		try {
			gpu.impl.draw(
				vertexListBuffer[0..vertexCount],
				primitiveType,
				PrimitiveFlags(
					extractWeights  !is null,
					extractTexture  !is null,
					extractColor    !is null,
					extractNormal   !is null,
					extractPosition !is null,
					vertexType.skinningWeightCount
				)
			);
		} catch (Object o) {
			writefln("gpu.impl.draw Error");
			throw(o);
		}
		gpu.state.drawBuffer.mustStore = true;
	}
}
