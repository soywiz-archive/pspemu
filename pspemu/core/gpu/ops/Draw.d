module pspemu.core.gpu.ops.Draw;

//debug = EXTRACT_PRIM;
//debug = EXTRACT_PRIM_COMPONENT;

template Gpu_Draw() {
	auto OP_CLEAR() {
		// Set flags.
		if (command.param24 & 0x1) {
			gpu.state.clearFlags = command.param24;
		}
		// Clear actually.
		else {
			gpu.checkLoadFrameBuffer();
			gpu.impl.clear();
			gpu.mustStoreFrameBuffer = true;
		}
	}

	static assert(byte.sizeof  == 1);
	static assert(short.sizeof == 2);
	static assert(float.sizeof == 4);
	
	VertexState[] vertexListBuffer;

	// Draw Primitive
	auto OP_PRIM() {
		auto vertexPointerBase = cast(ubyte*)gpu.memory.getPointer(gpu.state.vertexAddress);
		auto indexPointerBase  = gpu.state.indexAddress ? cast(ubyte*)gpu.memory.getPointer(gpu.state.indexAddress) : null;

		ubyte* vertexPointer = vertexPointerBase;
		ubyte* indexPointer  = indexPointerBase;

		auto vertexCount   = command.param16;
		auto primitiveType = cast(PrimitiveType)((command.param24 >> 16) & 0b111);
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

		void moveIndexGen(T)() {
			auto TIndexPointer = cast(T *)indexPointer;
			vertexPointer = vertexPointerBase + (*TIndexPointer * vertexSize);
			indexPointer += T.sizeof;
		}

		void extractArray(T)(float[] array) {
			foreach (ref value; array) {
				debug (EXTRACT_PRIM_COMPONENT) writefln("%08X(%s):%s", cast(uint)cast(void *)vertexPointer, typeid(T), *cast(T*)vertexPointer);
				value = *cast(T*)vertexPointer;
				vertexPointer += T.sizeof;
			}
		}
		void extractColor8888  (float[] array) { for (int n = 0; n < 4; n++) array[n] = cast(float)vertexPointer[n] / 255.0; vertexPointer += 4; }
		void extractColor8bits (float[] array) { /* palette? */ assert(0); vertexPointer += 1; }
		void extractColor16bits(float[] array) { assert(0); vertexPointer += 2; }

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
		gpu.mustStoreFrameBuffer = true;
	}
}
