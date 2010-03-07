module pspemu.core.gpu.ops.Special;

//debug = EXTRACT_PRIM;
//debug = EXTRACT_PRIM_COMPONENT;

template Gpu_Special() {
	// Base Address Register
	auto OP_BASE() {
		gpu.info.baseAddress = (command.param24 << 8);
	}

	// Vertex List (Base Address)
	auto OP_VADDR() {
		gpu.info.vertexAddress = gpu.info.baseAddress + command.param24;
		//writefln("VADDR: %08X", gpu.info.vertexAddress);
	}

	// Index List (Base Address)
	auto OP_IADDR() {
		gpu.info.indexAddress = gpu.info.baseAddress + command.param24;
	}

	// Vertex Type
	auto OP_VTYPE() {
		gpu.info.vertexType.v = command.param24;
	}

	auto OP_FBP() { gpu.info.drawBuffer.address = command.param24; }
	auto OP_FBW() { gpu.info.drawBuffer.width   = command.param16; }

	auto OP_CLEAR() {
		// Set flags.
		if (command.param24 & 0x1) {
			gpu.info.clearFlags = 0;
			if (command.param24 & 0x100) gpu.info.clearFlags |= GL_COLOR_BUFFER_BIT; // target
			if (command.param24 & 0x200) gpu.info.clearFlags |= GL_ACCUM_BUFFER_BIT | GL_STENCIL_BUFFER_BIT; // stencil/alpha
			if (command.param24 & 0x400) gpu.info.clearFlags |= GL_DEPTH_BUFFER_BIT; // zbuffer
		}
		// Clear actually.
		else {
			glClear(gpu.info.clearFlags);
		}
	}

	// Draw Primitive
	auto OP_PRIM() {
		static const uint[] pspToOpenglPrimitiveType = [GL_POINTS, GL_LINES, GL_LINE_STRIP, GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, GL_QUADS/*SPRITE*/];
		static const uint[] pspTypeSize = [0, byte.sizeof, short.sizeof, float.sizeof];
		static const uint[] pspTypeColorSize = [0, 1, 1, 1, 2, 2, 2, 4];
		assert(byte.sizeof  == 1);
		assert(short.sizeof == 2);
		assert(float.sizeof == 4);

		int  vertexCount   = command.param16;
		int  primitiveType = (command.param24 >> 16) & 0b111;
		auto vertexPointer = cast(ubyte*)gpu.info.vertexPointer;
		auto vertexType = gpu.info.vertexType;
		struct PP {
			union {
				float[4] array;
				struct { float u, v; }
				struct { float x, y, z; }
				struct { float r, g, b, a; }
			}
		}
		PP p;

		auto vertexSize = 0;
		vertexSize += vertexType.skinningWeightCount * pspTypeSize[vertexType.weight];
		vertexSize += 1 * pspTypeColorSize[vertexType.color];
		vertexSize += 2 * pspTypeSize[vertexType.texture ];
		vertexSize += 3 * pspTypeSize[vertexType.position];
		vertexSize += 3 * pspTypeSize[vertexType.normal  ];

		debug (EXTRACT_PRIM) writefln("Prim(%d) Type(%d) Size(%d)", vertexCount, primitiveType, vertexSize);

		void extract(T)(float[] array) {
			foreach (ref value; array) {
				debug (EXTRACT_PRIM_COMPONENT) writefln("%08X(%s):%s", cast(uint)cast(void *)vertexPointer, typeid(T), *cast(T*)vertexPointer);
				value = *cast(T*)vertexPointer;
				vertexPointer += T.sizeof;
			}
		}
		void extractColor8888(float[] array) {
			for (int n = 0; n < 4; n++) array[n] = cast(float)vertexPointer[n] / 255.0;
			vertexPointer += 4;
		}
		void extractColor8bits(float[] array) {
			vertexPointer += 1;
		}
		void extractColor16bits(float[] array) {
			vertexPointer += 2;
		}
		auto extractTable = [null, &extract!(byte), &extract!(short), &extract!(float)];
		auto extractColorTable = [null, &extractColor8bits, &extractColor8bits, &extractColor8bits, &extractColor16bits, &extractColor16bits, &extractColor16bits, &extractColor8888];

		auto extractTexture  = extractTable[vertexType.texture ];
		auto extractPosition = extractTable[vertexType.position];
		auto extractNormal   = extractTable[vertexType.normal  ];
		auto extractColor    = extractColorTable[vertexType.color];

		glBegin(pspToOpenglPrimitiveType[primitiveType]);
		{
			for (int n = 0; n < vertexCount; n++) {
				if (extractTexture) {
					extractTexture(p.array[0..2]);
					glTexCoord2f(p.u, p.v);
					debug (EXTRACT_PRIM) writef("| texture(%f, %f) ", p.u, p.v);
				}
				if (extractColor) {
					extractColor(p.array[0..4]);
					glColor4f(p.r, p.g, p.b, p.a);
					debug (EXTRACT_PRIM) writef("| color(%f, %f, %f, %f) ", p.r, p.g, p.b, p.a);
				}
				if (extractNormal) {
					extractNormal(p.array[0..3]);
					glNormal3f(p.x, p.y, p.z);
					debug (EXTRACT_PRIM) writef("| normal(%f, %f, %f) ", p.x, p.y, p.z);
				}
				if (extractPosition) {
					extractPosition(p.array[0..3]);
					glVertex3f(p.x, p.y, p.z);
					debug (EXTRACT_PRIM) writef("| position(%f, %f, %f) ", p.x, p.y, p.z);
				}
				debug (EXTRACT_PRIM) writefln("");
			}
		}
		glEnd();
	}
}