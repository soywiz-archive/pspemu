module pspemu.core.gpu.impl.GpuOpenglUtils;

import std.c.windows.windows;
import std.windows.syserror;
import pspemu.utils.OpenGL;

static const uint[] PrimitiveTypeTranslate    = [GL_POINTS, GL_LINES, GL_LINE_STRIP, GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, GL_QUADS/*GU_SPRITE*/];
static const uint[] TextureEnvModeTranslate   = [GL_MODULATE, GL_DECAL, GL_BLEND, GL_REPLACE, GL_ADD];	
static const uint[] TestTranslate             = [GL_NEVER, GL_ALWAYS, GL_EQUAL, GL_NOTEQUAL, GL_LESS, GL_LEQUAL, GL_GREATER, GL_GEQUAL];
static const uint[] StencilOperationTranslate = [GL_KEEP, GL_ZERO, GL_REPLACE, GL_INVERT, GL_INCR, GL_DECR];
static const uint[] BlendEquationTranslate    = [GL_FUNC_ADD, GL_FUNC_SUBTRACT, GL_FUNC_REVERSE_SUBTRACT, GL_MIN, GL_MAX, GL_FUNC_ADD ];
static const uint[] BlendFuncSrcTranslate     = [GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA ];
static const uint[] BlendFuncDstTranslate     = [GL_DST_COLOR, GL_ONE_MINUS_DST_COLOR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA ];	
static const uint[] LogicalOperationTranslate = [GL_CLEAR, GL_AND, GL_AND_REVERSE, GL_COPY, GL_AND_INVERTED, GL_NOOP, GL_XOR, GL_OR, GL_NOR, GL_EQUIV, GL_INVERT, GL_OR_REVERSE, GL_COPY_INVERTED, GL_OR_INVERTED, GL_NAND, GL_SET];

struct GlPixelFormat {
	float size;
	uint  internal;
	uint  external;
	uint  opengl;
	uint  isize() { return cast(uint)size; }
}

static const auto GlPixelFormats = [
	GlPixelFormat(  2, 3, GL_RGB,  GL_UNSIGNED_SHORT_5_6_5_REV),
	GlPixelFormat(  2, 4, GL_RGBA, GL_UNSIGNED_SHORT_1_5_5_5_REV),
	GlPixelFormat(  2, 4, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4_REV),
	GlPixelFormat(  4, 4, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV),
	GlPixelFormat(0.5, 1, GL_COLOR_INDEX, GL_COLOR_INDEX4_EXT),
	GlPixelFormat(  1, 1, GL_COLOR_INDEX, GL_COLOR_INDEX8_EXT),
	GlPixelFormat(  2, 4, GL_COLOR_INDEX, GL_COLOR_INDEX16_EXT),
	GlPixelFormat(  4, 4, GL_RGBA, GL_UNSIGNED_INT /*COLOR_INDEX, GL_COLOR_INDEX32_EXT*/), // Not defined.
	GlPixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT1_EXT),
	GlPixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT3_EXT),
	GlPixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT5_EXT),
];

template OpenglBase() {
	HWND hwnd;
	HDC hdc;
	HGLRC hrc;
	uint* bitmapData;

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
		AdjustWindowRect(&rc, dwStyle, FALSE);
		hWnd = CreateWindowA("PSPGE", null, dwStyle, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, null, null, hInstance, null);
		if (hWnd is null) throw(new Exception("CreateWindow() failed:  Cannot create a window. : " ~ sysErrorString(GetLastError())));

		hDC = GetDC(hWnd);

		// http://msdn.microsoft.com/en-us/library/ms970745.aspx
		// http://www.gamedev.net/reference/articles/article540.asp
		pfd.nSize        = pfd.sizeof;
		pfd.nVersion     = 1;
		pfd.dwFlags      = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | flags;
		pfd.iLayerType   = PFD_MAIN_PLANE;
		pfd.iPixelType   = type; // PFD_TYPE_RGBA
		pfd.cColorBits   = 24;
		//pfd.cDepthBits   = 8;
		pfd.cDepthBits   = 16;
		pfd.cStencilBits = 8;

		pf = ChoosePixelFormat(hDC, &pfd);

		if (pf == 0) throw(new Exception("ChoosePixelFormat() failed:  Cannot find a suitable pixel format."));

		if (SetPixelFormat(hDC, pf, &pfd) == FALSE) throw(new Exception("SetPixelFormat() failed:  Cannot set format specified."));

		DescribePixelFormat(hDC, pf, PIXELFORMATDESCRIPTOR.sizeof, &pfd);
		ReleaseDC(hDC, hWnd);

		return hWnd;
	}
}

extern (Windows) {
	//bool  SetPixelFormat(HDC, int, PIXELFORMATDESCRIPTOR*);
	bool  SwapBuffers(HDC);
	int   ChoosePixelFormat(HDC, PIXELFORMATDESCRIPTOR*);
	HBITMAP CreateDIBSection(HDC hdc, const BITMAPINFO *pbmi, UINT iUsage, VOID **ppvBits, HANDLE hSection, DWORD dwOffset);
	const uint BI_RGB = 0;
	const uint DIB_RGB_COLORS = 0;
	int DescribePixelFormat(HDC hdc, int iPixelFormat, UINT nBytes, LPPIXELFORMATDESCRIPTOR ppfd);
	//LRESULT DefWindowProcA(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);
	BOOL PostMessageA(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);
}

pragma(lib, "gdi32.lib");
