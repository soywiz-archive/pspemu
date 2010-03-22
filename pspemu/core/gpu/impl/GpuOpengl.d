module pspemu.core.gpu.impl.GpuOpengl;

import std.c.windows.windows;
import std.windows.syserror;

import std.contracts;

import pspemu.utils.OpenGL;

import pspemu.core.gpu.Types;

class GpuOpengl : GpuImplAbstract {
	mixin OpenglBase;
	mixin OpenglUtils;

	void init() {
		glInit();
		openglInit();
		openglPostInit();
	}

	void clear() {
		uint flags = 0;
		if (state.clearFlags & 0x100) flags |= GL_COLOR_BUFFER_BIT; // target
		if (state.clearFlags & 0x200) flags |= GL_ACCUM_BUFFER_BIT | GL_STENCIL_BUFFER_BIT; // stencil/alpha
		if (state.clearFlags & 0x400) flags |= GL_DEPTH_BUFFER_BIT; // zbuffer
		glClear(flags);
	}

	void draw(VertexState[] vertexList, PrimitiveType type, PrimitiveFlags flags) {
		void putVertex(ref VertexState vertex) {
			if (flags.hasTexture ) glTexCoord2f(vertex.u, vertex.v);
			if (flags.hasColor   ) glColor4f(vertex.r, vertex.g, vertex.b, vertex.a);
			if (flags.hasNormal  ) glNormal3f(vertex.nx, vertex.ny, vertex.nz);
			if (flags.hasPosition) glVertex3f(vertex.px, vertex.py, vertex.pz);
		}

		drawBegin();
		{
			switch (type) {
				// Special primitive that doesn't have equivalent in OpenGL.
				// With two points specify a GL_QUAD.
				case PrimitiveType.GU_SPRITES:
					glBegin(GL_QUADS);
					{
						for (int n = 0; n < vertexList.length; n += 2) {
							VertexState v1 = vertexList[n + 0], v2 = vertexList[n + 1], vertex = void;
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
					glBegin(pspToOpenglPrimitiveType[type]);
					{
						foreach (ref vertex; vertexList) putVertex(vertex);
					}
					glEnd();
				} break;
			}
		}
		drawEnd();
	}

	void flush() {
		glFlush();
	}

	void frameLoad(void* buffer) {
		//bitmapData[0..512 * 272] = (cast(uint *)drawBufferAddress)[0..512 * 272];
		glDrawPixels(
			state.drawBuffer.width,
			272,
			PixelFormats[state.drawBuffer.format].external,
			PixelFormats[state.drawBuffer.format].opengl,
			buffer
		);
	}

	void frameStore(void* buffer) {
		//(cast(uint *)drawBufferAddress)[0..512 * 272] = bitmapData[0..512 * 272];
		for (int n = 271, m = 0; n >= 0; n--, m++) {
			glReadPixels(
				0, n, // x, y
				state.drawBuffer.width, 1, // w, h
				PixelFormats[state.drawBuffer.format].external,
				GL_UNSIGNED_BYTE,
				state.drawBuffer.row(buffer, m).ptr
			);
		}
	}
}

template OpenglUtils() {
	void drawBegin() {
		if (state.vertexType.transform2D) {
		//if (1) {
			glMatrixMode(GL_PROJECTION); glLoadIdentity();
			glOrtho(0.0f, 480.0f, 272.0f, 0.0f, -1.0f, 1.0f);
			glMatrixMode(GL_MODELVIEW); glLoadIdentity();
		} else {
			glMatrixMode(GL_PROJECTION); glLoadIdentity();
			glMultMatrixf(state.projectionMatrix.pointer);

			glMatrixMode(GL_MODELVIEW); glLoadIdentity();
			glMultMatrixf(state.viewMatrix.pointer);
			glMultMatrixf(state.worldMatrix.pointer);
		}

		//glColor4fv(state.materialColor.ptr);
		glColor4fv(state.ambientModelColor.ptr);

		/*
			glMatrixMode(GL_PROJECTION); glLoadIdentity();
			glMultMatrixf(cast(float*)state.projectionMatrix.pointer);

			glMatrixMode(GL_MODELVIEW); glLoadIdentity();
			glMultMatrixf(state.viewMatrix.pointer);

			writefln("Projection:\n%s", state.projectionMatrix);
			writefln("View:\n%s", state.viewMatrix);
			writefln("World:\n%s", state.worldMatrix);
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
	
	void drawEnd() {
	}

	struct PixelFormat {
		float size;
		uint  internal;
		uint  external;
		uint  opengl;
	}

	static const auto PixelFormats = [
		PixelFormat(  2, 3, GL_RGB,  GL_UNSIGNED_SHORT_5_6_5_REV),
		PixelFormat(  2, 4, GL_RGBA, GL_UNSIGNED_SHORT_1_5_5_5_REV),
		PixelFormat(  2, 4, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4_REV),
		PixelFormat(  4, 4, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV),
		PixelFormat(0.5, 1, GL_RED,  GL_UNSIGNED_BYTE),
		PixelFormat(  1, 1, GL_RED,  GL_UNSIGNED_BYTE),
		PixelFormat(  2, 4, GL_RGBA, GL_UNSIGNED_SHORT),
		PixelFormat(  4, 4, GL_RGBA, GL_UNSIGNED_INT),
		PixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT1_EXT),
		PixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT3_EXT),
		PixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT5_EXT),
	];

	static const uint[] pspToOpenglPrimitiveType = [GL_POINTS, GL_LINES, GL_LINE_STRIP, GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, GL_QUADS/*GU_SPRITE*/];
}

template OpenglBase() {
	HDC hdc;
	HGLRC hglrc;
	uint *bitmapData;

	void openglInit() {
		// http://nehe.gamedev.net/data/lessons/lesson.asp?lesson=41
		// http://msdn.microsoft.com/en-us/library/ms970768.aspx
		// http://www.codeguru.com/cpp/g-m/opengl/article.php/c5587
		// PFD_DRAW_TO_BITMAP
		HBITMAP hbmpTemp;
		PIXELFORMATDESCRIPTOR pfd;
		BITMAPINFO bi;
		
		hdc = CreateCompatibleDC(GetDC(null));

		with (bi.bmiHeader) {
			biSize        = BITMAPINFOHEADER.sizeof;
			biBitCount    = 32;
			biWidth       = 512;
			biHeight      = 272;
			biCompression = BI_RGB;
			biPlanes      = 1;
		}

		hbmpTemp = enforce(CreateDIBSection(hdc, &bi, DIB_RGB_COLORS, cast(void **)&bitmapData, null, 0));
		enforce(SelectObject(hdc, hbmpTemp));

		with (pfd) {
			nSize      = pfd.sizeof;
			nVersion   = 1;
			dwFlags    = PFD_DRAW_TO_BITMAP | PFD_SUPPORT_OPENGL | PFD_SUPPORT_GDI;
			iPixelType = PFD_TYPE_RGBA;
			cDepthBits = pfd.cColorBits = 32;
			iLayerType = PFD_MAIN_PLANE;
		}

		enforce(SetPixelFormat(hdc, enforce(ChoosePixelFormat(hdc, &pfd)), &pfd));

		hglrc = enforce(wglCreateContext(hdc));
		openglMakeCurrent();
	}

	void openglMakeCurrent() {
		wglMakeCurrent(null, null);
		wglMakeCurrent(hdc, hglrc);
		assert(wglGetCurrentDC() == hdc);
		assert(wglGetCurrentContext() == hglrc);
	}

	void openglPostInit() {
		glMatrixMode(GL_MODELVIEW ); glLoadIdentity();
		glMatrixMode(GL_PROJECTION); glLoadIdentity();
		glPixelZoom(1, 1);
		glRasterPos2f(-1, 1);
	}
}

extern (Windows) {
	bool  SetPixelFormat(HDC, int, PIXELFORMATDESCRIPTOR*);
	bool  SwapBuffers(HDC);
	int   ChoosePixelFormat(HDC, PIXELFORMATDESCRIPTOR*);
	HBITMAP CreateDIBSection(HDC hdc, const BITMAPINFO *pbmi, UINT iUsage, VOID **ppvBits, HANDLE hSection, DWORD dwOffset);
	const uint BI_RGB = 0;
	const uint DIB_RGB_COLORS = 0;
}
