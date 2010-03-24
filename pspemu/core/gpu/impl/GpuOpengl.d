module pspemu.core.gpu.impl.GpuOpengl;

// http://www.opengl.org/resources/code/samples/win32_tutorial/wglinfo.c

//version = VERSION_GL_BITMAP_RENDERING;

import std.c.windows.windows;
import std.windows.syserror;
import std.stdio;

import std.contracts;

import pspemu.utils.OpenGL;

import pspemu.core.Memory;
import pspemu.core.gpu.Types;

class Texture {
	GLuint gltex;
	
	this() {
		glGenTextures(1, &gltex);
	}

	~this() {
		glDeleteTextures(1, &gltex);
	}

	void update(Memory memory, TextureBuffer tbuffer) {
		ubyte* data = cast(ubyte*)memory.getPointer(tbuffer.address);
		auto pformat = GpuOpengl.PixelFormats[tbuffer.format];

		glActiveTexture(GL_TEXTURE0);
		bind();

		glPixelStorei(GL_UNPACK_ALIGNMENT, cast(int)pformat.size);

		glTexImage2D(
			GL_TEXTURE_2D,
			0,
			pformat.internal,
			tbuffer.width,
			tbuffer.height,
			0,
			pformat.external,
			pformat.opengl,
			data
		);
		//glCheckError();
		
		//std.file.write("demodemo", data[0..(tbuffer.width * tbuffer.height) * cast(uint)pformat.size]);
		
		//writefln("%d, %d, %d");
		writefln("update(%d):%08X,%s, %d", gltex, data, tbuffer, (tbuffer.width * tbuffer.height) * cast(uint)pformat.size);
	}

	void bind() {
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, gltex);
	}
}

class GpuOpengl : GpuImplAbstract {
	mixin OpenglBase;
	mixin OpenglUtils;

	/// Previous state to check changes in the new state and perform new operations.
	GpuState prevState;

	void init() {
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
			//writefln("UV(%f, %f)", vertex.u, vertex.v);
		}

		drawBegin();
		{
			switch (type) {
				// Special primitive that doesn't have equivalent in OpenGL.
				// With two points specify a GL_QUAD.
				// http://www.opengl.org/registry/specs/ARB/point_sprite.txt
				// http://cirl.missouri.edu/gpu/glsl_lessons/glsl_geometry_shader/index.html
				case PrimitiveType.GU_SPRITES:
					static string spriteVertexInterpolate(string vx, string vy) {
						string s;
						s ~= "vertex.px = " ~ vx ~ ".px; vertex.py = " ~ vy ~ ".py;";
						s ~= "vertex.nx = " ~ vx ~ ".px; vertex.ny = " ~ vy ~ ".py;";
						s ~= "vertex.u  = " ~ vx ~ ".u ; vertex.v  = " ~ vy ~ ".v;";
						return s;
					}

					glPushAttrib(GL_CULL_FACE);
					glDisable(GL_CULL_FACE);
					//if (!state.vertexType.transform2D) {
					if (0) {
						// TEST.
						glMatrixMode(GL_PROJECTION); glLoadIdentity();
						glOrtho(0.0f, 480.0f, 272.0f, 0.0f, -1.0f, 1.0f);
						glMatrixMode(GL_MODELVIEW); glLoadIdentity();

						auto matrix = state.projectionMatrix * state.worldMatrix * state.viewMatrix;
						for (int n = 0; n < vertexList.length; n += 2) {
							VertexState v1 = vertexList[n + 0], v2 = vertexList[n + 1], vertex = void;
							vertex = v1;
							
							//auto vv1 = Vector(v1.px, v1.py, v1.pz, 0);
							//auto vv2 = Vector(v2.px, v2.py, v2.pz, 0);
							
							//auto vertexProjected1 = matrix * [v1.px, v1.py, v1.pz, 1];
							//auto vertexProjected2 = matrix * [v2.px, v2.py, v2.pz, 1];
							auto vertexProjectedm = matrix * ((v1.p + v2.p) / 2);
							vertexProjectedm.x *= 480;
							vertexProjectedm.y *= 272;
							float width  = std.math.fabs(v2.p.x - v1.p.x) * 480;
							float height = std.math.fabs(v2.p.y - v1.p.y) * 272;
							
							mixin(spriteVertexInterpolate("v1", "v1")); vertex.px = vertexProjectedm.x - width; vertex.py = vertexProjectedm.y - height; vertex.pz = 0; putVertex(vertex); writefln("%s", vertex);
							mixin(spriteVertexInterpolate("v2", "v1")); vertex.px = vertexProjectedm.x + width; vertex.py = vertexProjectedm.y - height; vertex.pz = 0; putVertex(vertex); writefln("%s", vertex);
							mixin(spriteVertexInterpolate("v2", "v2")); vertex.px = vertexProjectedm.x + width; vertex.py = vertexProjectedm.y + height; vertex.pz = 0; putVertex(vertex); writefln("%s", vertex);
							mixin(spriteVertexInterpolate("v1", "v2")); vertex.px = vertexProjectedm.x - width; vertex.py = vertexProjectedm.y + height; vertex.pz = 0; putVertex(vertex); writefln("%s", vertex);
							writefln("");

							//vertexProjected1
							//writefln("%s | %s", v2.px - v1.px, v2.py - v1.py);
							// gl_Position = gl_ModelViewProjectionMatrix
							//state.viewMatrix * state.worldMatrix * state.projectionMatrix
						}
					}
					else {
						if (1) {
							glBegin(GL_QUADS);
							{
								for (int n = 0; n < vertexList.length; n += 2) {
									VertexState v1 = vertexList[n + 0], v2 = vertexList[n + 1], vertex = void;
									vertex = v1;
									
									mixin(spriteVertexInterpolate("v1", "v1")); putVertex(vertex);
									mixin(spriteVertexInterpolate("v2", "v1")); putVertex(vertex);
									mixin(spriteVertexInterpolate("v2", "v2")); putVertex(vertex);
									mixin(spriteVertexInterpolate("v1", "v2")); putVertex(vertex);
								}
							}
							glEnd();
						} else {
							glEnable(GL_POINT_SPRITE);
							//glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);  
							//glEnable(GL_COORD_REPLACE);
							glBegin(GL_POINTS);
							{
								for (int n = 0; n < vertexList.length; n += 2) {
									VertexState v1 = vertexList[n + 0], v2 = vertexList[n + 1], vertex = void;
									vertex = v1;
									vertex.position = (v1.position + v2.position) / 2;
									putVertex(vertex);
									//Vector(v1.px, v1.py, v1.pz) + Vector(v2.px, v2.py, v3.pz)
								}
								//foreach (ref vertex; vertexList) putVertex(vertex);
							}
							glEnd();
							glDisable(GL_POINT_SPRITE);
							//glDisable(GL_COORD_REPLACE);
						}
					}
					glPopAttrib();
				break;
				// Normal primitives that have equivalent in OpenGL.
				default: {
					glBegin(PrimitiveTypeTranslate[type]);
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
	
	version (VERSION_GL_BITMAP_RENDERING) {
	} else {
		ubyte[4 * 512 * 272] buffer_temp;
	}

	void frameStore(void* buffer) {
		//(cast(uint *)drawBufferAddress)[0..512 * 272] = bitmapData[0..512 * 272];
		glReadPixels(
			0, 0, // x, y
			state.drawBuffer.width, 272, // w, h
			PixelFormats[state.drawBuffer.format].external,
			GL_UNSIGNED_BYTE,
			&buffer_temp
		);
		for (int n = 0; n < 272; n++) {
			int m = 271 - n;
			state.drawBuffer.row(buffer, n)[] = state.drawBuffer.row(&buffer_temp, m)[];
		}
	}
}

template OpenglUtils() {
	static const uint[] PrimitiveTypeTranslate    = [GL_POINTS, GL_LINES, GL_LINE_STRIP, GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, GL_QUADS/*GU_SPRITE*/];
	static const uint[] TextureEnvModeTranslate   = [GL_MODULATE, GL_DECAL, GL_BLEND, GL_REPLACE, GL_ADD];	
	static const uint[] TestTranslate             = [GL_NEVER, GL_ALWAYS, GL_EQUAL, GL_NOTEQUAL, GL_LESS, GL_LEQUAL, GL_GREATER, GL_GEQUAL];
	static const uint[] StencilOperationTranslate = [GL_KEEP, GL_ZERO, GL_REPLACE, GL_INVERT, GL_INCR, GL_DECR];
	static const uint[] BlendEquationTranslate    = [GL_FUNC_ADD, GL_FUNC_SUBTRACT, GL_FUNC_REVERSE_SUBTRACT, GL_MIN, GL_MAX, GL_FUNC_ADD ];
	static const uint[] BlendFuncSrcTranslate     = [GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA ];
	static const uint[] BlendFuncDstTranslate     = [GL_DST_COLOR, GL_ONE_MINUS_DST_COLOR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA ];	
	static const uint[] LogicalOperationTranslate = [GL_CLEAR, GL_AND, GL_AND_REVERSE, GL_COPY, GL_AND_INVERTED, GL_NOOP, GL_XOR, GL_OR, GL_NOR, GL_EQUIV, GL_INVERT, GL_OR_REVERSE, GL_COPY_INVERTED, GL_OR_INVERTED, GL_NAND, GL_SET];

	Texture[uint] textureCache;
	
	void glEnableDisable(int type, bool enable) {
		if (enable) glEnable(type); else glDisable(type);
	}

	Texture getTexture(TextureBuffer tbuffer) {
		if ((tbuffer.address in textureCache) is null) {
			Texture texture = new Texture();
			texture.update(state.memory, tbuffer);
			textureCache[tbuffer.address] = texture;
		}
		return textureCache[tbuffer.address];
	}

	void drawBegin() {
		void prepareEnables() {
			glEnableDisable(GL_CLIP_PLANE0,    state.clipPlaneEnabled);
			glEnableDisable(GL_CULL_FACE,      state.backfaceCullingEnabled);
			glEnableDisable(GL_BLEND,          state.alphaBlendEnabled);
			glEnableDisable(GL_DEPTH_TEST,     state.depthTestEnabled);
			glEnableDisable(GL_STENCIL_TEST,   state.stencilTestEnabled);
			glEnableDisable(GL_COLOR_LOGIC_OP, state.logicalOperationEnabled);
			glEnableDisable(GL_TEXTURE_2D,     state.textureMappingEnabled);
			glEnableDisable(GL_ALPHA_TEST,     state.alphaTestEnabled);
		}

		void prepareMatrix() {
			if (state.vertexType.transform2D) {
				glMatrixMode(GL_PROJECTION); glLoadIdentity();
				glOrtho(0.0f, 480.0f, 272.0f, 0.0f, -1.0f, 1.0f);
				glMatrixMode(GL_MODELVIEW); glLoadIdentity();
				//writefln("transform");
			} else {
				//writefln("no transform");
				glMatrixMode(GL_PROJECTION); glLoadIdentity();
				glMultMatrixf(state.projectionMatrix.pointer);

				glMatrixMode(GL_MODELVIEW); glLoadIdentity();
				glMultMatrixf(state.viewMatrix.pointer);
				glMultMatrixf(state.worldMatrix.pointer);
			}
			/*
			writefln("Projection:\n%s", state.projectionMatrix);
			writefln("View:\n%s", state.viewMatrix);
			writefln("World:\n%s", state.worldMatrix);
			*/
		}

		void prepareTexture() {
			if (!state.textureMappingEnabled) return;

			glActiveTexture(GL_TEXTURE0);
			glMatrixMode(GL_TEXTURE);
			glLoadIdentity();
			
			if (state.vertexType.transform2D && (state.textureScale.u == 1 && state.textureScale.v == 1)) {
				glScalef(1.0f / state.textures[0].width, 1.0f / state.textures[0].height, 1);
			} else {
				glScalef(state.textureScale.u, state.textureScale.v, 1);
			}
			glTranslatef(state.textureOffset.u, state.textureOffset.v, 0);
			
			if (state.textureMappingEnabled) {
				glEnable(GL_TEXTURE_2D);
				getTexture(state.textures[0]).bind();
				//writefln("tex0:%s", state.textures[0]);

				glEnable(GL_CLAMP_TO_EDGE);
				glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, state.textureFilterMin ? GL_LINEAR : GL_NEAREST);
				glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, state.textureFilterMag ? GL_LINEAR : GL_NEAREST);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, state.textureWrapS);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, state.textureWrapT);

				glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, TextureEnvModeTranslate[state.textureEnvMode]);

			} else {
				glDisable(GL_TEXTURE_2D);
			}
		}
		
		void prepareStencil() {
			if (!state.stencilTestEnabled) return;

			//writefln("%d, %d, %d", state.stencilFuncFunc, state.stencilFuncRef, state.stencilFuncMask);
			glStencilFunc(
				TestTranslate[state.stencilFuncFunc],
				state.stencilFuncRef,
				state.stencilFuncMask
			);
			//glCheckError();

			glStencilOp(
				StencilOperationTranslate[state.stencilOperationSfail ],
				StencilOperationTranslate[state.stencilOperationDpfail],
				StencilOperationTranslate[state.stencilOperationDppass]
			);
			//glCheckError();
		}

		void prepareBlend() {
			if (!state.alphaBlendEnabled) return;

			glBlendEquation(BlendEquationTranslate[state.blendEquation]);
			glBlendFunc(BlendFuncSrcTranslate[state.blendFuncSrc], BlendFuncDstTranslate[state.blendFuncDst]);
			glShadeModel(state.shadeModel ? GL_SMOOTH : GL_FLAT);
		}

		void prepareColors() {
			glColor4fv(state.ambientModelColor.ptr);
		}

		void prepareCulling() {
			if (!state.backfaceCullingEnabled) return;

			glFrontFace(state.faceCullingOrder ? GL_CW : GL_CCW);
		}

		void prepareScissor() {
			if ((state.scissor.x1 <= 0 && state.scissor.y1 <= 0) && (state.scissor.x2 >= 480 && state.scissor.y2 >= 272)) {
				glDisable(GL_SCISSOR_TEST);
				return;
			}

			glEnable(GL_SCISSOR_TEST);
			glScissor(
				state.scissor.x1,
				272 - state.scissor.y2,
				state.scissor.x2 - state.scissor.x1,
				state.scissor.y2 - state.scissor.y1
			);
		}

		prepareEnables();
		prepareMatrix();
		prepareStencil();
		prepareScissor();
		prepareBlend();
		prepareCulling();
		prepareColors();
		prepareTexture();

		glLogicOp(LogicalOperationTranslate[state.logicalOperation]);
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
}

template OpenglBase() {
	HWND hwnd;
	HDC hdc;
	HGLRC hrc;
	uint *bitmapData;

	version (VERSION_GL_BITMAP_RENDERING) {
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

			hrc = enforce(wglCreateContext(hdc));
			openglMakeCurrent();
			glInit();
		}
	} else {
		// http://www.opengl.org/resources/code/samples/win32_tutorial/wglinfo.c
		void openglInit() {
			hwnd = CreateOpenGLWindow(512, 272, PFD_TYPE_RGBA, 0);
			if (hwnd == null) throw(new Exception("Invalid window handle"));

			hdc = GetDC(hwnd);
			hrc = wglCreateContext(hdc);
			openglMakeCurrent();

			glInit();
			//assert(glActiveTexture !is null);

			ShowWindow(hwnd, SW_HIDE);
			//ShowWindow(hwnd, SW_SHOW);
		}
	}

	void openglMakeCurrent() {
		wglMakeCurrent(null, null);
		wglMakeCurrent(hdc, hrc);
		assert(wglGetCurrentDC() == hdc);
		assert(wglGetCurrentContext() == hrc);
	}

	void openglPostInit() {
		glMatrixMode(GL_MODELVIEW ); glLoadIdentity();
		glMatrixMode(GL_PROJECTION); glLoadIdentity();
		glPixelZoom(1, 1);
		glRasterPos2f(-1, 1);
	}

	static HWND CreateOpenGLWindow(int width, int height, BYTE type, DWORD flags) {
		int         pf;
		HDC         hDC;
		HWND        hWnd;
		WNDCLASS    wc;
		PIXELFORMATDESCRIPTOR pfd;
		static HINSTANCE hInstance = null;

		if (!hInstance) {
			hInstance        = GetModuleHandleA(null);
			wc.style         = CS_OWNDC;
			wc.lpfnWndProc   = cast(WNDPROC)&DefWindowProcA;
			wc.cbClsExtra    = 0;
			wc.cbWndExtra    = 0;
			wc.hInstance     = hInstance;
			wc.hIcon         = LoadIconA(null, cast(char*)32517);
			wc.hCursor       = LoadCursorA(null, cast(char*)0);
			wc.hbrBackground = null;
			wc.lpszMenuName  = null;
			wc.lpszClassName = "PSPGE";

			if (!RegisterClassA(&wc)) throw(new Exception("RegisterClass() failed:  Cannot register window class."));
		}

		int dwStyle = WS_OVERLAPPEDWINDOW | WS_CLIPSIBLINGS | WS_CLIPCHILDREN;
		RECT rc;
		rc.top = rc.left = 0;
		rc.right = width;
		rc.bottom = height;
		AdjustWindowRect( &rc, dwStyle, FALSE );  
		hWnd = CreateWindowA("PSPGE", null, dwStyle, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, null, null, hInstance, null);
		if (hWnd is null) throw(new Exception("CreateWindow() failed:  Cannot create a window. : " ~ sysErrorString(GetLastError())));

		hDC = GetDC(hWnd);

		pfd.nSize        = pfd.sizeof;
		pfd.nVersion     = 1;
		pfd.dwFlags      = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | flags;
		pfd.iPixelType   = type;
		pfd.cColorBits   = 32;

		pf = ChoosePixelFormat(hDC, &pfd);

		if (pf == 0) throw(new Exception("ChoosePixelFormat() failed:  Cannot find a suitable pixel format."));

		if (SetPixelFormat(hDC, pf, &pfd) == FALSE) throw(new Exception("SetPixelFormat() failed:  Cannot set format specified."));

		DescribePixelFormat(hDC, pf, PIXELFORMATDESCRIPTOR.sizeof, &pfd);
		ReleaseDC(hDC, hWnd);

		return hWnd;
	}
}

extern (Windows) {
	bool  SetPixelFormat(HDC, int, PIXELFORMATDESCRIPTOR*);
	bool  SwapBuffers(HDC);
	int   ChoosePixelFormat(HDC, PIXELFORMATDESCRIPTOR*);
	HBITMAP CreateDIBSection(HDC hdc, const BITMAPINFO *pbmi, UINT iUsage, VOID **ppvBits, HANDLE hSection, DWORD dwOffset);
	const uint BI_RGB = 0;
	const uint DIB_RGB_COLORS = 0;
	int DescribePixelFormat(HDC hdc, int iPixelFormat, UINT nBytes, LPPIXELFORMATDESCRIPTOR ppfd);
	LRESULT DefWindowProcA(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);
	BOOL PostMessageA(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);
}

pragma(lib, "gdi32.lib");

version (unittest) {
	import core.thread;
}

// cls && dmd ..\..\..\utils\opengl.d ..\types.d -version=TEST_GPUOPENGL -unittest -run GpuOpengl.d
unittest {
	auto gpuImpl = new GpuOpengl;
	(new Thread({
		gpuImpl.init();
	})).start();
}
version (TEST_GPUOPENGL) static void main() {}
