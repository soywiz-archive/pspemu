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
				case PrimitiveType.GU_SPRITES:
					glPushAttrib(GL_CULL_FACE);
					glDisable(GL_CULL_FACE);
					glBegin(GL_QUADS);
					{
						for (int n = 0; n < vertexList.length; n += 2) {
							VertexState v1 = vertexList[n + 0], v2 = vertexList[n + 1], vertex = void;
							vertex = v1;
							
							static string test(string vx, string vy) {
								string s;
								s ~= "vertex.px = " ~ vx ~ ".px; vertex.py = " ~ vy ~ ".py;";
								s ~= "vertex.nx = " ~ vx ~ ".px; vertex.ny = " ~ vy ~ ".py;";
								s ~= "vertex.u  = " ~ vx ~ ".u ; vertex.v  = " ~ vy ~ ".v;";
								return s;
							}

							mixin(test("v1", "v1")); putVertex(vertex);
							mixin(test("v2", "v1")); putVertex(vertex);
							mixin(test("v2", "v2")); putVertex(vertex);
							mixin(test("v1", "v2")); putVertex(vertex);
						}
					}
					glPopAttrib();
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
		void prepareMatrix() {
			if (state.vertexType.transform2D) {
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
			/*
			writefln("Projection:\n%s", state.projectionMatrix);
			writefln("View:\n%s", state.viewMatrix);
			writefln("World:\n%s", state.worldMatrix);
			*/
		}

		void prepareTexture() {
			if (glActiveTexture is null) return;

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

				static const uint[] TextureEnvModeTranslate = [GL_MODULATE, GL_DECAL, GL_BLEND, GL_REPLACE, GL_ADD];	
				glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, TextureEnvModeTranslate[state.textureEnvMode]);

			} else {
				glDisable(GL_TEXTURE_2D);
			}

			/*
			if (textureEnabled) setTexture(0); else unsetTexture();
			
			version (gpu_use_shaders) {
				gla_textureUse.set(textureEnabled);
			}
			*/
		}

		glEnableDisable(GL_CLIP_PLANE0,    state.clipPlaneEnabled);
		glEnableDisable(GL_CULL_FACE,      state.backfaceCullingEnabled);
		glEnableDisable(GL_BLEND,          state.alphaBlendEnabled);
		glEnableDisable(GL_DEPTH_TEST,     state.depthTestEnabled);
		glEnableDisable(GL_STENCIL_TEST,   state.stencilTestEnabled);
		glEnableDisable(GL_COLOR_LOGIC_OP, state.logicalOperationEnabled);
		glEnableDisable(GL_TEXTURE_2D,     state.textureMappingEnabled);
		glEnableDisable(GL_ALPHA_TEST,     state.alphaTestEnabled);
	
		static const uint[] BlendEquationTranslate = [GL_FUNC_ADD, GL_FUNC_SUBTRACT, GL_FUNC_REVERSE_SUBTRACT, GL_MIN, GL_MAX, GL_FUNC_ADD ];
		glBlendEquation(BlendEquationTranslate[state.blendEquation]);

		static const uint[] BlendFuncSrcTranslate = [GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA ];
		static const uint[] BlendFuncDstTranslate = [GL_DST_COLOR, GL_ONE_MINUS_DST_COLOR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA ];	
		glBlendFunc(BlendFuncSrcTranslate[state.blendFuncSrc], BlendFuncDstTranslate[state.blendFuncDst]);

		glColor4fv(state.ambientModelColor.ptr);
		
		prepareMatrix();
		prepareTexture();
		glFrontFace (state.faceCullingOrder ? GL_CW : GL_CCW);
		glShadeModel(state.shadeModel ? GL_SMOOTH : GL_FLAT);

		// Scissor
		//if (scissor.isFull) { glDisable(GL_SCISSOR_TEST); break; }
		glEnable(GL_SCISSOR_TEST);
		glScissor(
			state.scissor.x1,
			272 - state.scissor.y2,
			state.scissor.x2 - state.scissor.x1,
			state.scissor.y2 - state.scissor.y1
		);


		
		/*
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
			//wc.lpfnWndProc   = cast(WNDPROC)&DefWindowProcA;
			wc.lpfnWndProc   = cast(WNDPROC)&WindowProc;
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

	static extern(Windows) LONG WindowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam) { 
		static PAINTSTRUCT ps;

		switch (uMsg) {
			case WM_PAINT:
				BeginPaint(hWnd, &ps);
				EndPaint(hWnd, &ps);
				return 0;
			case WM_SIZE:
				//glViewport(0, 0, LOWORD(lParam), HIWORD(lParam));
				PostMessageA(hWnd, WM_PAINT, 0, 0);
				return 0;
			case WM_CHAR:
				/*
				switch (wParam) {
					case 27:
						PostQuitMessage(0);
						break;
				}
				*/
				return 0;
			case WM_CLOSE:
				PostQuitMessage(0);
				return 0;
			default:
		}

		return DefWindowProcA(hWnd, uMsg, wParam, lParam); 
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
