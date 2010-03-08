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

		prepareDrawing();
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
		//glClearColor(1.0, 1.0, 1.0, 1.0);
		//glClear(GL_COLOR_BUFFER_BIT);
	}

	void prepareDrawing() {
		if (gpu.info.vertexType.transform2D) {
			glMatrixMode(GL_PROJECTION); glLoadIdentity();
			glOrtho(0.0f, 480.0f, 272.0f, 0.0f, -1.0f, 1.0f);
			glMatrixMode(GL_MODELVIEW); glLoadIdentity();
		} else {
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			//glMultMatrixf(cast(float*)matrix_Projection);

			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			/*
			glMultMatrixf(cast(float*)matrix_Model);
			glMultMatrixf(cast(float*)matrix_World);
			*/
		}
		
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