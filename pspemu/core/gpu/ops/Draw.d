module pspemu.core.gpu.ops.Draw;

//debug = EXTRACT_PRIM;
//debug = EXTRACT_PRIM_COMPONENT;

template Gpu_Draw() {
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

	static assert(byte.sizeof  == 1);
	static assert(short.sizeof == 2);
	static assert(float.sizeof == 4);

	// Draw Primitive
	auto OP_PRIM() {
		// GU Primitive Types.
		enum Type { GU_POINTS = 0, GU_LINES = 1, GU_LINE_STRIP = 2, GU_TRIANGLES = 3, GU_TRIANGLE_STRIP = 4, GU_TRIANGLE_FAN = 5, GU_SPRITES = 6 };

		struct VertexState {
			float u, v;        // Texture coordinates.
			float r, g, b, a;  // Color components.
			float nx, ny, nz;  // Normal vector.
			float px, py, pz;  // Position vector.
			float weights[8];  // Weights for skinning and morphing.
		}

		static const uint[] pspTypeSize = [0, byte.sizeof, short.sizeof, float.sizeof];
		static const uint[] pspTypeColorSize = [0, 1, 1, 1, 2, 2, 2, 4];

		auto vertexCount   = command.param16;
		auto primitiveType = cast(Type)((command.param24 >> 16) & 0b111);
		auto vertexPointer = cast(ubyte*)gpu.info.vertexPointer;
		auto vertexType    = gpu.info.vertexType;

		auto vertexSize = 0;
		vertexSize += vertexType.skinningWeightCount * pspTypeSize[vertexType.weight];
		vertexSize += 1 * pspTypeColorSize[vertexType.color];
		vertexSize += 2 * pspTypeSize[vertexType.texture ];
		vertexSize += 3 * pspTypeSize[vertexType.position];
		vertexSize += 3 * pspTypeSize[vertexType.normal  ];

		debug (EXTRACT_PRIM) writefln(
			"Prim(%d) Type(%d) Size(%d)"
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

		auto extractTable = [null, &extractArray!(byte), &extractArray!(short), &extractArray!(float)];
		auto extractColorTable = [null, &extractColor8bits, &extractColor8bits, &extractColor8bits, &extractColor16bits, &extractColor16bits, &extractColor16bits, &extractColor8888];

		auto extractWeights  = vertexType.skinningWeightCount ? &extractArray!(float) : null;
		auto extractTexture  = extractTable[vertexType.texture ];
		auto extractPosition = extractTable[vertexType.position];
		auto extractNormal   = extractTable[vertexType.normal  ];
		auto extractColor    = extractColorTable[vertexType.color];

		void extractVertex(ref VertexState vertex) {
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

		void putVertex(ref VertexState vertex) {
			if (extractTexture ) glTexCoord2f(vertex.u, vertex.v);
			if (extractColor   ) glColor4f(vertex.r, vertex.g, vertex.b, vertex.a);
			if (extractNormal  ) glNormal3f(vertex.nx, vertex.ny, vertex.nz);
			if (extractPosition) glVertex3f(vertex.px, vertex.py, vertex.pz);
		}

		prepareDrawing();
		switch (primitiveType) {
			// Special primitive that doesn't have equivalent in OpenGL.
			// With two points specify a GL_QUAD.
			case Type.GU_SPRITES:
				glBegin(GL_QUADS);
				{
					for (int n = 0; n < vertexCount; n += 2) {
						VertexState v1 = void, v2 = void, vertex = void;
						extractVertex(v1);
						extractVertex(v2);
						vertex = v1;

						vertex.px = v1.px; vertex.py = v1.py; putVertex(vertex);
						vertex.px = v2.px; vertex.py = v1.py; putVertex(vertex);
						vertex.px = v2.px; vertex.py = v2.py; putVertex(vertex);
						vertex.px = v1.px; vertex.py = v2.py; putVertex(vertex);
					}
				}
				glEnd();
			break;
			// Normal primitives that have equivalent in OpenGL.
			default: {
				static const uint[] pspToOpenglPrimitiveType = [GL_POINTS, GL_LINES, GL_LINE_STRIP, GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, GL_QUADS/*GU_SPRITE*/];
				glBegin(pspToOpenglPrimitiveType[primitiveType]);
				{
					for (int n = 0; n < vertexCount; n++) {
						VertexState vertex = void;
						extractVertex(vertex);
						putVertex(vertex);
					}
				}
				glEnd();
			} break;
		}
	}

	void prepareDrawing() {
		if (gpu.info.vertexType.transform2D) {
			glMatrixMode(GL_PROJECTION); glLoadIdentity();
			glOrtho(0.0f, 480.0f, 272.0f, 0.0f, -1.0f, 1.0f);
			glMatrixMode(GL_MODELVIEW); glLoadIdentity();
		} else {
			glMatrixMode(GL_PROJECTION); glLoadIdentity();
			glMultMatrixf(cast(float*)gpu.info.projectionMatrix.pointer);

			glMatrixMode(GL_MODELVIEW); glLoadIdentity();
			glMultMatrixf(gpu.info.viewMatrix.pointer);
			glMultMatrixf(gpu.info.worldMatrix.pointer);
		}
		glColor4f(1, 1, 1, 1);
		/*
			glMatrixMode(GL_PROJECTION); glLoadIdentity();
			glMultMatrixf(cast(float*)gpu.info.projectionMatrix.pointer);

			glMatrixMode(GL_MODELVIEW); glLoadIdentity();
			glMultMatrixf(gpu.info.viewMatrix.pointer);

			writefln("Projection:\n%s", gpu.info.projectionMatrix);
			writefln("View:\n%s", gpu.info.viewMatrix);
			writefln("World:\n%s", gpu.info.worldMatrix);
		*/
		/*
		glActiveTexture(GL_TEXTURE0);
		glMatrixMode(GL_TEXTURE);
		glLoadIdentity();
		
		if (info.vertexType.transform2D && (textureScale.u == 1 && textureScale.v == 1)) {
			glScalef(1.0f / textures[0].width, 1.0f / textures[0].height, 1);
		} else {
			glScalef(textureScale.u, textureScale.v, 1);
		}
		
		glTranslatef(textureOffset.u, textureOffset.v, 0);
		
		if (textureEnabled) setTexture(0); else unsetTexture();
		
		version (gpu_use_shaders) {
			gla_textureUse.set(textureEnabled);
		}
		
		glEnableDisable(GL_COLOR_ARRAY, vinfo.color);
		
		glColor4fv(AmbientMaterial.ptr);
		
		version (gpu_no_lighting) LightsEnabled = false;
		
		if (LightsEnabled) {
			//writefln("lights");
		
			// Ambient Material Color
			//glEnable(GL_COLOR_MATERIAL);
			//ColorMaterial
			
			glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, AmbientMaterial.ptr);
			glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, DiffuseMaterial.ptr);
			//glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, SpecularMaterial.ptr);
			//writefln("--------------------------- %f", light_specular_power);
			
			foreach (k, light; lights) {
				if (!light.enabled) continue;
				int lgl = GL_LIGHT0 + k;
				
				light.dir[3] = light.pos[3] = 0.0f;

				//writefln("Light%d", k);
				
				glLightfv(lgl, GL_POSITION, light.pos.ptr);
				glLightfv(lgl, GL_SPOT_DIRECTION, light.dir.ptr);
				
				glLightf (lgl, GL_CONSTANT_ATTENUATION, light.constant);
				glLightf (lgl, GL_LINEAR_ATTENUATION, light.linear);
				glLightf (lgl, GL_QUADRATIC_ATTENUATION, light.quadratic);

				glLightf (lgl, GL_SPOT_EXPONENT, light.exponent);
				glLightf (lgl, GL_SPOT_CUTOFF, light.cutoff);
				
				glLightfv(lgl, GL_SPECULAR, light.specular.ptr);
				glLightfv(lgl, GL_DIFFUSE, light.diffuse.ptr);
			}
		}
		*/
	}
}