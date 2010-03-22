module pspemu.utils.OpenGL;

private import std.string, std.stdio, std.stream;

debug = DEBUG_GL_VER;

static __gshared:
private bool glInitializated = false;
private bool glInitializatedSystem = false;

extern(System):

alias uint      GLenum;
alias ubyte     GLboolean;
alias uint      GLbitfield;
alias void      GLvoid;
alias byte      GLbyte;
alias short     GLshort;
alias int       GLint;
alias ubyte     GLubyte;
alias ushort    GLushort;
alias uint      GLuint;
alias int       GLsizei;
alias float     GLfloat;
alias float     GLclampf;
alias double    GLdouble;
alias double    GLclampd;
alias char      GLchar;
alias ptrdiff_t GLintptr;
alias ptrdiff_t GLsizeiptr;

version (Windows) {
	private import std.c.windows.windows;
	private import std.windows.syserror;

	enum : uint {
		PFD_TYPE_RGBA = 0,
		PFD_TYPE_COLORINDEX = 1,
		PFD_MAIN_PLANE = 0,
		PFD_OVERLAY_PLANE = 1,
		PFD_UNDERLAY_PLANE = -1,
		PFD_DOUBLEBUFFER = 1,
		PFD_STEREO = 2,
		PFD_DRAW_TO_WINDOW = 4,
		PFD_DRAW_TO_BITMAP = 8,
		PFD_SUPPORT_GDI = 16,
		PFD_SUPPORT_OPENGL = 32,
		PFD_GENERIC_FORMAT = 64,
		PFD_NEED_PALETTE = 128,
		PFD_NEED_SYSTEM_PALETTE = 0x00000100,
		PFD_SWAP_EXCHANGE = 0x00000200,
		PFD_SWAP_COPY = 0x00000400,
		PFD_SWAP_LAYER_BUFFERS = 0x00000800,
		PFD_GENERIC_ACCELERATED = 0x00001000,
		PFD_DEPTH_DONTCARE = 0x20000000,
		PFD_DOUBLEBUFFER_DONTCARE = 0x40000000,
		PFD_STEREO_DONTCARE = 0x80000000,
	}
	
	struct LAYERPLANEDESCRIPTOR {
		WORD nSize;
		WORD nVersion;
		DWORD dwFlags;
		BYTE iPixelType;
		BYTE cColorBits;
		BYTE cRedBits;
		BYTE cRedShift;
		BYTE cGreenBits;
		BYTE cGreenShift;
		BYTE cBlueBits;
		BYTE cBlueShift;
		BYTE cAlphaBits;
		BYTE cAlphaShift;
		BYTE cAccumBits;
		BYTE cAccumRedBits;
		BYTE cAccumGreenBits;
		BYTE cAccumBlueBits;
		BYTE cAccumAlphaBits;
		BYTE cDepthBits;
		BYTE cStencilBits;
		BYTE cAuxBuffers;
		BYTE iLayerPlane;
		BYTE bReserved;
		COLORREF crTransparent;
	}

	struct POINTFLOAT {
		FLOAT x;
		FLOAT y;
	}

	struct GLYPHMETRICSFLOAT {
		FLOAT gmfBlackBoxX;
		FLOAT gmfBlackBoxY;
		POINTFLOAT gmfptGlyphOrigin;
		FLOAT gmfCellIncX;
		FLOAT gmfCellIncY;
	}

	void* function(char*) wglGetProcAddress;
	bool  function(HDC, HGLRC) wglMakeCurrent;
	HGLRC function(HDC) wglCreateContext;
	bool  function(HGLRC, HGLRC) wglShareLists;
	bool  function(HGLRC) wglDeleteContext;	
	bool  function(HGLRC, HGLRC, uint) wglCopyContext;
	HGLRC function(HDC, int) wglCreateLayerContext;
	bool  function(HDC, int, int,uint, LAYERPLANEDESCRIPTOR*) wglDescribeLayerPlane;
	HGLRC function() wglGetCurrentContext;
	HDC   function() wglGetCurrentDC;
	int   function(HDC, int, int, int, COLORREF*) wglGetLayerPaletteEntries;
	BOOL  function(HDC,int,BOOL) wglRealizeLayerPalette;
	int   function(HDC,int,int,int, COLORREF*) wglSetLayerPaletteEntries;
	BOOL  function(HDC,UINT) wglSwapLayerBuffers;
	BOOL  function(HDC,DWORD,DWORD,DWORD) wglUseFontBitmapsA;
	BOOL  function(HDC,DWORD,DWORD,DWORD) wglUseFontBitmapsW;
	BOOL  function(HDC,DWORD,DWORD,DWORD,FLOAT,FLOAT,int,GLYPHMETRICSFLOAT*) wglUseFontOutlinesA;
	BOOL  function(HDC,DWORD,DWORD,DWORD,FLOAT,FLOAT,int,GLYPHMETRICSFLOAT*) wglUseFontOutlinesW;

	HANDLE opengl_dll;

	char* toStringz(string value) {
		return ((cast(char[])value) ~ '\0').ptr;
	}
	
	// Used for API >= 1.2
	void glBindFunc(void** ptr, string funcName) {
		void* func = wglGetProcAddress(toStringz(funcName));
		if (!func) throw(new Exception(std.string.format("Can't bind '%s' : '%s'", funcName, sysErrorString(GetLastError()))));
		*ptr = func;
	}	
	
	// Used for API == 1.1
	void glBindFuncBase(void** ptr, string funcName) {
		version (Windows) {
			void* func = GetProcAddress(opengl_dll, toStringz(funcName));
			if (!func) throw(new Exception(std.string.format("Can't bind '%s'", funcName)));
			*ptr = func;
		} else {
			throw(new Exception(std.string.format("Can't bind '%s' (only works on windows)", funcName)));
		}	
	}

	private void glInitWindows() {
		//_gstatic
		//writefln("glInitWindows");
		opengl_dll = LoadLibraryA("opengl32.dll");

		mixin(glBindFuncBaseMix("wglGetProcAddress"));
		mixin(glBindFuncBaseMix("wglMakeCurrent"));
		mixin(glBindFuncBaseMix("wglCreateContext"));
		mixin(glBindFuncBaseMix("wglShareLists"));
		mixin(glBindFuncBaseMix("wglDeleteContext"));
		mixin(glBindFuncBaseMix("wglCopyContext"));
		mixin(glBindFuncBaseMix("wglCreateLayerContext"));
		mixin(glBindFuncBaseMix("wglDescribeLayerPlane"));
		mixin(glBindFuncBaseMix("wglGetCurrentContext"));
		mixin(glBindFuncBaseMix("wglGetCurrentDC"));
		mixin(glBindFuncBaseMix("wglGetLayerPaletteEntries"));
		mixin(glBindFuncBaseMix("wglRealizeLayerPalette"));
		mixin(glBindFuncBaseMix("wglSetLayerPaletteEntries"));
		mixin(glBindFuncBaseMix("wglSwapLayerBuffers"));
		mixin(glBindFuncBaseMix("wglUseFontBitmapsA"));
		mixin(glBindFuncBaseMix("wglUseFontBitmapsW"));
		mixin(glBindFuncBaseMix("wglUseFontOutlinesA"));
		mixin(glBindFuncBaseMix("wglUseFontOutlinesW"));
	}
} else {
	static assert (0 != 0);
}

string glBindFuncBaseMix(string t) { return "glBindFuncBase(cast(void**)&" ~ t ~ ", \"" ~ t ~ "\");"; }
string glBindFuncMix(string t) { return "glBindFunc(cast(void**)&" ~ t ~ ", \"" ~ t ~ "\");"; }
bool   glCatch(void function() glUsingVer) { try { glUsingVer(); return true; } catch (Exception e) { debug (DEBUG_GL_VER) writefln("%s", e); return false; } }

void glUsing(double ver = 4.0) {
	auto v = [1.1, 1.2, 1.3, 1.4, 1.5, 2.0, 2.1, 3.0, 3.1, 3.2, 3.3, 4.0];
	auto f = [&glUsing11, &glUsing12, &glUsing13, &glUsing14, &glUsing15, &glUsing20, &glUsing21, &glUsing30, &glUsing31, &glUsing32, &glUsing33, &glUsing40];
	
	debug (DEBUG_GL_VER) writefln("OpenGL init (requested ver: %.1f) {", ver);
	
	for (int n = 0; n < v.length; n++) {
		if (ver < v[n]) continue;
		bool r = glCatch(f[n]);
		debug (DEBUG_GL_VER) writefln("  Version: %.1f : %s", v[n], r);
	}
	
	debug (DEBUG_GL_VER) writefln("}");
}

void glInitSystem() {
	if (glInitializatedSystem) return;
	version (Windows) glInitWindows();
	glInitializatedSystem = true;
}


void glInit(double ver = 4.0) {
	if (glInitializated) return;
	glInitSystem();
	glUsing(ver);
	glInitializated = true;
}

///////////////////////////////////////////////////////////////////////////////
// OPENGL 1.1                                                                //
///////////////////////////////////////////////////////////////////////////////

enum : GLenum {
	GL_VERSION_1_1 = 1,
	GL_ACCUM                      = 0x0100,
	GL_LOAD                       = 0x0101,
	GL_RETURN                     = 0x0102,
	GL_MULT                       = 0x0103,
	GL_ADD                        = 0x0104,
	GL_NEVER                      = 0x0200,
	GL_LESS                       = 0x0201,
	GL_EQUAL                      = 0x0202,
	GL_LEQUAL                     = 0x0203,
	GL_GREATER                    = 0x0204,
	GL_NOTEQUAL                   = 0x0205,
	GL_GEQUAL                     = 0x0206,
	GL_ALWAYS                     = 0x0207,
	GL_CURRENT_BIT                = 0x00000001,
	GL_POINT_BIT                  = 0x00000002,
	GL_LINE_BIT                   = 0x00000004,
	GL_POLYGON_BIT                = 0x00000008,
	GL_POLYGON_STIPPLE_BIT        = 0x00000010,
	GL_PIXEL_MODE_BIT             = 0x00000020,
	GL_LIGHTING_BIT               = 0x00000040,
	GL_FOG_BIT                    = 0x00000080,
	GL_DEPTH_BUFFER_BIT           = 0x00000100,
	GL_ACCUM_BUFFER_BIT           = 0x00000200,
	GL_STENCIL_BUFFER_BIT         = 0x00000400,
	GL_VIEWPORT_BIT               = 0x00000800,
	GL_TRANSFORM_BIT              = 0x00001000,
	GL_ENABLE_BIT                 = 0x00002000,
	GL_COLOR_BUFFER_BIT           = 0x00004000,
	GL_HINT_BIT                   = 0x00008000,
	GL_EVAL_BIT                   = 0x00010000,
	GL_LIST_BIT                   = 0x00020000,
	GL_TEXTURE_BIT                = 0x00040000,
	GL_SCISSOR_BIT                = 0x00080000,
	GL_ALL_ATTRIB_BITS            = 0x000fffff,
	GL_POINTS                     = 0x0000,
	GL_LINES                      = 0x0001,
	GL_LINE_LOOP                  = 0x0002,
	GL_LINE_STRIP                 = 0x0003,
	GL_TRIANGLES                  = 0x0004,
	GL_TRIANGLE_STRIP             = 0x0005,
	GL_TRIANGLE_FAN               = 0x0006,
	GL_QUADS                      = 0x0007,
	GL_QUAD_STRIP                 = 0x0008,
	GL_POLYGON                    = 0x0009,
	GL_ZERO                       = 0,
	GL_ONE                        = 1,
	GL_SRC_COLOR                  = 0x0300,
	GL_ONE_MINUS_SRC_COLOR        = 0x0301,
	GL_SRC_ALPHA                  = 0x0302,
	GL_ONE_MINUS_SRC_ALPHA        = 0x0303,
	GL_DST_ALPHA                  = 0x0304,
	GL_ONE_MINUS_DST_ALPHA        = 0x0305,
	GL_DST_COLOR                  = 0x0306,
	GL_ONE_MINUS_DST_COLOR        = 0x0307,
	GL_SRC_ALPHA_SATURATE         = 0x0308,
	GL_TRUE                       = 1,
	GL_FALSE                      = 0,
	GL_CLIP_PLANE0                = 0x3000,
	GL_CLIP_PLANE1                = 0x3001,
	GL_CLIP_PLANE2                = 0x3002,
	GL_CLIP_PLANE3                = 0x3003,
	GL_CLIP_PLANE4                = 0x3004,
	GL_CLIP_PLANE5                = 0x3005,
	GL_BYTE                       = 0x1400,
	GL_UNSIGNED_BYTE              = 0x1401,
	GL_SHORT                      = 0x1402,
	GL_UNSIGNED_SHORT             = 0x1403,
	GL_INT                        = 0x1404,
	GL_UNSIGNED_INT               = 0x1405,
	GL_FLOAT                      = 0x1406,
	GL_2_BYTES                    = 0x1407,
	GL_3_BYTES                    = 0x1408,
	GL_4_BYTES                    = 0x1409,
	GL_DOUBLE                     = 0x140A,
	GL_NONE                       = 0,
	GL_FRONT_LEFT                 = 0x0400,
	GL_FRONT_RIGHT                = 0x0401,
	GL_BACK_LEFT                  = 0x0402,
	GL_BACK_RIGHT                 = 0x0403,
	GL_FRONT                      = 0x0404,
	GL_BACK                       = 0x0405,
	GL_LEFT                       = 0x0406,
	GL_RIGHT                      = 0x0407,
	GL_FRONT_AND_BACK             = 0x0408,
	GL_AUX0                       = 0x0409,
	GL_AUX1                       = 0x040A,
	GL_AUX2                       = 0x040B,
	GL_AUX3                       = 0x040C,
	GL_NO_ERROR                   = 0,
	GL_INVALID_ENUM               = 0x0500,
	GL_INVALID_VALUE              = 0x0501,
	GL_INVALID_OPERATION          = 0x0502,
	GL_STACK_OVERFLOW             = 0x0503,
	GL_STACK_UNDERFLOW            = 0x0504,
	GL_OUT_OF_MEMORY              = 0x0505,
	GL_2D                         = 0x0600,
	GL_3D                         = 0x0601,
	GL_3D_COLOR                   = 0x0602,
	GL_3D_COLOR_TEXTURE           = 0x0603,
	GL_4D_COLOR_TEXTURE           = 0x0604,
	GL_PASS_THROUGH_TOKEN         = 0x0700,
	GL_POINT_TOKEN                = 0x0701,
	GL_LINE_TOKEN                 = 0x0702,
	GL_POLYGON_TOKEN              = 0x0703,
	GL_BITMAP_TOKEN               = 0x0704,
	GL_DRAW_PIXEL_TOKEN           = 0x0705,
	GL_COPY_PIXEL_TOKEN           = 0x0706,
	GL_LINE_RESET_TOKEN           = 0x0707,
	GL_EXP                        = 0x0800,
	GL_EXP2                       = 0x0801,
	GL_CW                         = 0x0900,
	GL_CCW                        = 0x0901,
	GL_COEFF                      = 0x0A00,
	GL_ORDER                      = 0x0A01,
	GL_DOMAIN                     = 0x0A02,
	GL_CURRENT_COLOR              = 0x0B00,
	GL_CURRENT_INDEX              = 0x0B01,
	GL_CURRENT_NORMAL             = 0x0B02,
	GL_CURRENT_TEXTURE_COORDS     = 0x0B03,
	GL_CURRENT_RASTER_COLOR       = 0x0B04,
	GL_CURRENT_RASTER_INDEX       = 0x0B05,
	GL_CURRENT_RASTER_TEXTURE_COORDS = 0x0B06,
	GL_CURRENT_RASTER_POSITION    = 0x0B07,
	GL_CURRENT_RASTER_POSITION_VALID = 0x0B08,
	GL_CURRENT_RASTER_DISTANCE    = 0x0B09,
	GL_POINT_SMOOTH               = 0x0B10,
	GL_POINT_SIZE                 = 0x0B11,
	GL_POINT_SIZE_RANGE           = 0x0B12,
	GL_POINT_SIZE_GRANULARITY     = 0x0B13,
	GL_LINE_SMOOTH                = 0x0B20,
	GL_LINE_WIDTH                 = 0x0B21,
	GL_LINE_WIDTH_RANGE           = 0x0B22,
	GL_LINE_WIDTH_GRANULARITY     = 0x0B23,
	GL_LINE_STIPPLE               = 0x0B24,
	GL_LINE_STIPPLE_PATTERN       = 0x0B25,
	GL_LINE_STIPPLE_REPEAT        = 0x0B26,
	GL_LIST_MODE                  = 0x0B30,
	GL_MAX_LIST_NESTING           = 0x0B31,
	GL_LIST_BASE                  = 0x0B32,
	GL_LIST_INDEX                 = 0x0B33,
	GL_POLYGON_MODE               = 0x0B40,
	GL_POLYGON_SMOOTH             = 0x0B41,
	GL_POLYGON_STIPPLE            = 0x0B42,
	GL_EDGE_FLAG                  = 0x0B43,
	GL_CULL_FACE                  = 0x0B44,
	GL_CULL_FACE_MODE             = 0x0B45,
	GL_FRONT_FACE                 = 0x0B46,
	GL_LIGHTING                   = 0x0B50,
	GL_LIGHT_MODEL_LOCAL_VIEWER   = 0x0B51,
	GL_LIGHT_MODEL_TWO_SIDE       = 0x0B52,
	GL_LIGHT_MODEL_AMBIENT        = 0x0B53,
	GL_SHADE_MODEL                = 0x0B54,
	GL_COLOR_MATERIAL_FACE        = 0x0B55,
	GL_COLOR_MATERIAL_PARAMETER   = 0x0B56,
	GL_COLOR_MATERIAL             = 0x0B57,
	GL_FOG                        = 0x0B60,
	GL_FOG_INDEX                  = 0x0B61,
	GL_FOG_DENSITY                = 0x0B62,
	GL_FOG_START                  = 0x0B63,
	GL_FOG_END                    = 0x0B64,
	GL_FOG_MODE                   = 0x0B65,
	GL_FOG_COLOR                  = 0x0B66,
	GL_DEPTH_RANGE                = 0x0B70,
	GL_DEPTH_TEST                 = 0x0B71,
	GL_DEPTH_WRITEMASK            = 0x0B72,
	GL_DEPTH_CLEAR_VALUE          = 0x0B73,
	GL_DEPTH_FUNC                 = 0x0B74,
	GL_ACCUM_CLEAR_VALUE          = 0x0B80,
	GL_STENCIL_TEST               = 0x0B90,
	GL_STENCIL_CLEAR_VALUE        = 0x0B91,
	GL_STENCIL_FUNC               = 0x0B92,
	GL_STENCIL_VALUE_MASK         = 0x0B93,
	GL_STENCIL_FAIL               = 0x0B94,
	GL_STENCIL_PASS_DEPTH_FAIL    = 0x0B95,
	GL_STENCIL_PASS_DEPTH_PASS    = 0x0B96,
	GL_STENCIL_REF                = 0x0B97,
	GL_STENCIL_WRITEMASK          = 0x0B98,
	GL_MATRIX_MODE                = 0x0BA0,
	GL_NORMALIZE                  = 0x0BA1,
	GL_VIEWPORT                   = 0x0BA2,
	GL_MODELVIEW_STACK_DEPTH      = 0x0BA3,
	GL_PROJECTION_STACK_DEPTH     = 0x0BA4,
	GL_TEXTURE_STACK_DEPTH        = 0x0BA5,
	GL_MODELVIEW_MATRIX           = 0x0BA6,
	GL_PROJECTION_MATRIX          = 0x0BA7,
	GL_TEXTURE_MATRIX             = 0x0BA8,
	GL_ATTRIB_STACK_DEPTH         = 0x0BB0,
	GL_CLIENT_ATTRIB_STACK_DEPTH  = 0x0BB1,
	GL_ALPHA_TEST                 = 0x0BC0,
	GL_ALPHA_TEST_FUNC            = 0x0BC1,
	GL_ALPHA_TEST_REF             = 0x0BC2,
	GL_DITHER                     = 0x0BD0,
	GL_BLEND_DST                  = 0x0BE0,
	GL_BLEND_SRC                  = 0x0BE1,
	GL_BLEND                      = 0x0BE2,
	GL_LOGIC_OP_MODE              = 0x0BF0,
	GL_INDEX_LOGIC_OP             = 0x0BF1,
	GL_COLOR_LOGIC_OP             = 0x0BF2,
	GL_AUX_BUFFERS                = 0x0C00,
	GL_DRAW_BUFFER                = 0x0C01,
	GL_READ_BUFFER                = 0x0C02,
	GL_SCISSOR_BOX                = 0x0C10,
	GL_SCISSOR_TEST               = 0x0C11,
	GL_INDEX_CLEAR_VALUE          = 0x0C20,
	GL_INDEX_WRITEMASK            = 0x0C21,
	GL_COLOR_CLEAR_VALUE          = 0x0C22,
	GL_COLOR_WRITEMASK            = 0x0C23,
	GL_INDEX_MODE                 = 0x0C30,
	GL_RGBA_MODE                  = 0x0C31,
	GL_DOUBLEBUFFER               = 0x0C32,
	GL_STEREO                     = 0x0C33,
	GL_RENDER_MODE                = 0x0C40,
	GL_PERSPECTIVE_CORRECTION_HINT= 0x0C50,
	GL_POINT_SMOOTH_HINT          = 0x0C51,
	GL_LINE_SMOOTH_HINT           = 0x0C52,
	GL_POLYGON_SMOOTH_HINT        = 0x0C53,
	GL_FOG_HINT                   = 0x0C54,
	GL_TEXTURE_GEN_S              = 0x0C60,
	GL_TEXTURE_GEN_T              = 0x0C61,
	GL_TEXTURE_GEN_R              = 0x0C62,
	GL_TEXTURE_GEN_Q              = 0x0C63,
	GL_PIXEL_MAP_I_TO_I           = 0x0C70,
	GL_PIXEL_MAP_S_TO_S           = 0x0C71,
	GL_PIXEL_MAP_I_TO_R           = 0x0C72,
	GL_PIXEL_MAP_I_TO_G           = 0x0C73,
	GL_PIXEL_MAP_I_TO_B           = 0x0C74,
	GL_PIXEL_MAP_I_TO_A           = 0x0C75,
	GL_PIXEL_MAP_R_TO_R           = 0x0C76,
	GL_PIXEL_MAP_G_TO_G           = 0x0C77,
	GL_PIXEL_MAP_B_TO_B           = 0x0C78,
	GL_PIXEL_MAP_A_TO_A           = 0x0C79,
	GL_PIXEL_MAP_I_TO_I_SIZE      = 0x0CB0,
	GL_PIXEL_MAP_S_TO_S_SIZE      = 0x0CB1,
	GL_PIXEL_MAP_I_TO_R_SIZE      = 0x0CB2,
	GL_PIXEL_MAP_I_TO_G_SIZE      = 0x0CB3,
	GL_PIXEL_MAP_I_TO_B_SIZE      = 0x0CB4,
	GL_PIXEL_MAP_I_TO_A_SIZE      = 0x0CB5,
	GL_PIXEL_MAP_R_TO_R_SIZE      = 0x0CB6,
	GL_PIXEL_MAP_G_TO_G_SIZE      = 0x0CB7,
	GL_PIXEL_MAP_B_TO_B_SIZE      = 0x0CB8,
	GL_PIXEL_MAP_A_TO_A_SIZE      = 0x0CB9,
	GL_UNPACK_SWAP_BYTES          = 0x0CF0,
	GL_UNPACK_LSB_FIRST           = 0x0CF1,
	GL_UNPACK_ROW_LENGTH          = 0x0CF2,
	GL_UNPACK_SKIP_ROWS           = 0x0CF3,
	GL_UNPACK_SKIP_PIXELS         = 0x0CF4,
	GL_UNPACK_ALIGNMENT           = 0x0CF5,
	GL_PACK_SWAP_BYTES            = 0x0D00,
	GL_PACK_LSB_FIRST             = 0x0D01,
	GL_PACK_ROW_LENGTH            = 0x0D02,
	GL_PACK_SKIP_ROWS             = 0x0D03,
	GL_PACK_SKIP_PIXELS           = 0x0D04,
	GL_PACK_ALIGNMENT             = 0x0D05,
	GL_MAP_COLOR                  = 0x0D10,
	GL_MAP_STENCIL                = 0x0D11,
	GL_INDEX_SHIFT                = 0x0D12,
	GL_INDEX_OFFSET               = 0x0D13,
	GL_RED_SCALE                  = 0x0D14,
	GL_RED_BIAS                   = 0x0D15,
	GL_ZOOM_X                     = 0x0D16,
	GL_ZOOM_Y                     = 0x0D17,
	GL_GREEN_SCALE                = 0x0D18,
	GL_GREEN_BIAS                 = 0x0D19,
	GL_BLUE_SCALE                 = 0x0D1A,
	GL_BLUE_BIAS                  = 0x0D1B,
	GL_ALPHA_SCALE                = 0x0D1C,
	GL_ALPHA_BIAS                 = 0x0D1D,
	GL_DEPTH_SCALE                = 0x0D1E,
	GL_DEPTH_BIAS                 = 0x0D1F,
	GL_MAX_EVAL_ORDER             = 0x0D30,
	GL_MAX_LIGHTS                 = 0x0D31,
	GL_MAX_CLIP_PLANES            = 0x0D32,
	GL_MAX_TEXTURE_SIZE           = 0x0D33,
	GL_MAX_PIXEL_MAP_TABLE        = 0x0D34,
	GL_MAX_ATTRIB_STACK_DEPTH     = 0x0D35,
	GL_MAX_MODELVIEW_STACK_DEPTH  = 0x0D36,
	GL_MAX_NAME_STACK_DEPTH       = 0x0D37,
	GL_MAX_PROJECTION_STACK_DEPTH = 0x0D38,
	GL_MAX_TEXTURE_STACK_DEPTH    = 0x0D39,
	GL_MAX_VIEWPORT_DIMS          = 0x0D3A,
	GL_MAX_CLIENT_ATTRIB_STACK_DEPTH = 0x0D3B,
	GL_SUBPIXEL_BITS              = 0x0D50,
	GL_INDEX_BITS                 = 0x0D51,
	GL_RED_BITS                   = 0x0D52,
	GL_GREEN_BITS                 = 0x0D53,
	GL_BLUE_BITS                  = 0x0D54,
	GL_ALPHA_BITS                 = 0x0D55,
	GL_DEPTH_BITS                 = 0x0D56,
	GL_STENCIL_BITS               = 0x0D57,
	GL_ACCUM_RED_BITS             = 0x0D58,
	GL_ACCUM_GREEN_BITS           = 0x0D59,
	GL_ACCUM_BLUE_BITS            = 0x0D5A,
	GL_ACCUM_ALPHA_BITS           = 0x0D5B,
	GL_NAME_STACK_DEPTH           = 0x0D70,
	GL_AUTO_NORMAL                = 0x0D80,
	GL_MAP1_COLOR_4               = 0x0D90,
	GL_MAP1_INDEX                 = 0x0D91,
	GL_MAP1_NORMAL                = 0x0D92,
	GL_MAP1_TEXTURE_COORD_1       = 0x0D93,
	GL_MAP1_TEXTURE_COORD_2       = 0x0D94,
	GL_MAP1_TEXTURE_COORD_3       = 0x0D95,
	GL_MAP1_TEXTURE_COORD_4       = 0x0D96,
	GL_MAP1_VERTEX_3              = 0x0D97,
	GL_MAP1_VERTEX_4              = 0x0D98,
	GL_MAP2_COLOR_4               = 0x0DB0,
	GL_MAP2_INDEX                 = 0x0DB1,
	GL_MAP2_NORMAL                = 0x0DB2,
	GL_MAP2_TEXTURE_COORD_1       = 0x0DB3,
	GL_MAP2_TEXTURE_COORD_2       = 0x0DB4,
	GL_MAP2_TEXTURE_COORD_3       = 0x0DB5,
	GL_MAP2_TEXTURE_COORD_4       = 0x0DB6,
	GL_MAP2_VERTEX_3              = 0x0DB7,
	GL_MAP2_VERTEX_4              = 0x0DB8,
	GL_MAP1_GRID_DOMAIN           = 0x0DD0,
	GL_MAP1_GRID_SEGMENTS         = 0x0DD1,
	GL_MAP2_GRID_DOMAIN           = 0x0DD2,
	GL_MAP2_GRID_SEGMENTS         = 0x0DD3,
	GL_TEXTURE_1D                 = 0x0DE0,
	GL_TEXTURE_2D                 = 0x0DE1,
	GL_FEEDBACK_BUFFER_POINTER    = 0x0DF0,
	GL_FEEDBACK_BUFFER_SIZE       = 0x0DF1,
	GL_FEEDBACK_BUFFER_TYPE       = 0x0DF2,
	GL_SELECTION_BUFFER_POINTER   = 0x0DF3,
	GL_SELECTION_BUFFER_SIZE      = 0x0DF4,
	GL_TEXTURE_WIDTH              = 0x1000,
	GL_TEXTURE_HEIGHT             = 0x1001,
	GL_TEXTURE_INTERNAL_FORMAT    = 0x1003,
	GL_TEXTURE_BORDER_COLOR       = 0x1004,
	GL_TEXTURE_BORDER             = 0x1005,
	GL_DONT_CARE                  = 0x1100,
	GL_FASTEST                    = 0x1101,
	GL_NICEST                     = 0x1102,
	GL_LIGHT0                     = 0x4000,
	GL_LIGHT1                     = 0x4001,
	GL_LIGHT2                     = 0x4002,
	GL_LIGHT3                     = 0x4003,
	GL_LIGHT4                     = 0x4004,
	GL_LIGHT5                     = 0x4005,
	GL_LIGHT6                     = 0x4006,
	GL_LIGHT7                     = 0x4007,
	GL_AMBIENT                    = 0x1200,
	GL_DIFFUSE                    = 0x1201,
	GL_SPECULAR                   = 0x1202,
	GL_POSITION                   = 0x1203,
	GL_SPOT_DIRECTION             = 0x1204,
	GL_SPOT_EXPONENT              = 0x1205,
	GL_SPOT_CUTOFF                = 0x1206,
	GL_CONSTANT_ATTENUATION       = 0x1207,
	GL_LINEAR_ATTENUATION         = 0x1208,
	GL_QUADRATIC_ATTENUATION      = 0x1209,
	GL_COMPILE                    = 0x1300,
	GL_COMPILE_AND_EXECUTE        = 0x1301,
	GL_CLEAR                      = 0x1500,
	GL_AND                        = 0x1501,
	GL_AND_REVERSE                = 0x1502,
	GL_COPY                       = 0x1503,
	GL_AND_INVERTED               = 0x1504,
	GL_NOOP                       = 0x1505,
	GL_XOR                        = 0x1506,
	GL_OR                         = 0x1507,
	GL_NOR                        = 0x1508,
	GL_EQUIV                      = 0x1509,
	GL_INVERT                     = 0x150A,
	GL_OR_REVERSE                 = 0x150B,
	GL_COPY_INVERTED              = 0x150C,
	GL_OR_INVERTED                = 0x150D,
	GL_NAND                       = 0x150E,
	GL_SET                        = 0x150F,
	GL_EMISSION                   = 0x1600,
	GL_SHININESS                  = 0x1601,
	GL_AMBIENT_AND_DIFFUSE        = 0x1602,
	GL_COLOR_INDEXES              = 0x1603,
	GL_MODELVIEW                  = 0x1700,
	GL_PROJECTION                 = 0x1701,
	GL_TEXTURE                    = 0x1702,
	GL_COLOR                      = 0x1800,
	GL_DEPTH                      = 0x1801,
	GL_STENCIL                    = 0x1802,
	GL_COLOR_INDEX                = 0x1900,
	GL_STENCIL_INDEX              = 0x1901,
	GL_DEPTH_COMPONENT            = 0x1902,
	GL_RED                        = 0x1903,
	GL_GREEN                      = 0x1904,
	GL_BLUE                       = 0x1905,
	GL_ALPHA                      = 0x1906,
	GL_RGB                        = 0x1907,
	GL_RGBA                       = 0x1908,
	GL_LUMINANCE                  = 0x1909,
	GL_LUMINANCE_ALPHA            = 0x190A,
	GL_BITMAP                     = 0x1A00,
	GL_POINT                      = 0x1B00,
	GL_LINE                       = 0x1B01,
	GL_FILL                       = 0x1B02,
	GL_RENDER                     = 0x1C00,
	GL_FEEDBACK                   = 0x1C01,
	GL_SELECT                     = 0x1C02,
	GL_FLAT                       = 0x1D00,
	GL_SMOOTH                     = 0x1D01,
	GL_KEEP                       = 0x1E00,
	GL_REPLACE                    = 0x1E01,
	GL_INCR                       = 0x1E02,
	GL_DECR                       = 0x1E03,
	GL_VENDOR                     = 0x1F00,
	GL_RENDERER                   = 0x1F01,
	GL_VERSION                    = 0x1F02,
	GL_EXTENSIONS                 = 0x1F03,
	GL_S                          = 0x2000,
	GL_T                          = 0x2001,
	GL_R                          = 0x2002,
	GL_Q                          = 0x2003,
	GL_MODULATE                   = 0x2100,
	GL_DECAL                      = 0x2101,
	GL_TEXTURE_ENV_MODE           = 0x2200,
	GL_TEXTURE_ENV_COLOR          = 0x2201,
	GL_TEXTURE_ENV                = 0x2300,
	GL_EYE_LINEAR                 = 0x2400,
	GL_OBJECT_LINEAR              = 0x2401,
	GL_SPHERE_MAP                 = 0x2402,
	GL_TEXTURE_GEN_MODE           = 0x2500,
	GL_OBJECT_PLANE               = 0x2501,
	GL_EYE_PLANE                  = 0x2502,
	GL_NEAREST                    = 0x2600,
	GL_LINEAR                     = 0x2601,
	GL_NEAREST_MIPMAP_NEAREST     = 0x2700,
	GL_LINEAR_MIPMAP_NEAREST      = 0x2701,
	GL_NEAREST_MIPMAP_LINEAR      = 0x2702,
	GL_LINEAR_MIPMAP_LINEAR       = 0x2703,
	GL_TEXTURE_MAG_FILTER         = 0x2800,
	GL_TEXTURE_MIN_FILTER         = 0x2801,
	GL_TEXTURE_WRAP_S             = 0x2802,
	GL_TEXTURE_WRAP_T             = 0x2803,
	GL_CLAMP                      = 0x2900,
	GL_REPEAT                     = 0x2901,
	GL_CLIENT_PIXEL_STORE_BIT     = 0x00000001,
	GL_CLIENT_VERTEX_ARRAY_BIT    = 0x00000002,
	GL_CLIENT_ALL_ATTRIB_BITS     = 0xffffffff,
	GL_POLYGON_OFFSET_FACTOR      = 0x8038,
	GL_POLYGON_OFFSET_UNITS       = 0x2A00,
	GL_POLYGON_OFFSET_POINT       = 0x2A01,
	GL_POLYGON_OFFSET_LINE        = 0x2A02,
	GL_POLYGON_OFFSET_FILL        = 0x8037,
	GL_ALPHA4                     = 0x803B,
	GL_ALPHA8                     = 0x803C,
	GL_ALPHA12                    = 0x803D,
	GL_ALPHA16                    = 0x803E,
	GL_LUMINANCE4                 = 0x803F,
	GL_LUMINANCE8                 = 0x8040,
	GL_LUMINANCE12                = 0x8041,
	GL_LUMINANCE16                = 0x8042,
	GL_LUMINANCE4_ALPHA4          = 0x8043,
	GL_LUMINANCE6_ALPHA2          = 0x8044,
	GL_LUMINANCE8_ALPHA8          = 0x8045,
	GL_LUMINANCE12_ALPHA4         = 0x8046,
	GL_LUMINANCE12_ALPHA12        = 0x8047,
	GL_LUMINANCE16_ALPHA16        = 0x8048,
	GL_INTENSITY                  = 0x8049,
	GL_INTENSITY4                 = 0x804A,
	GL_INTENSITY8                 = 0x804B,
	GL_INTENSITY12                = 0x804C,
	GL_INTENSITY16                = 0x804D,
	GL_R3_G3_B2                   = 0x2A10,
	GL_RGB4                       = 0x804F,
	GL_RGB5                       = 0x8050,
	GL_RGB8                       = 0x8051,
	GL_RGB10                      = 0x8052,
	GL_RGB12                      = 0x8053,
	GL_RGB16                      = 0x8054,
	GL_RGBA2                      = 0x8055,
	GL_RGBA4                      = 0x8056,
	GL_RGB5_A1                    = 0x8057,
	GL_RGBA8                      = 0x8058,
	GL_RGB10_A2                   = 0x8059,
	GL_RGBA12                     = 0x805A,
	GL_RGBA16                     = 0x805B,
	GL_TEXTURE_RED_SIZE           = 0x805C,
	GL_TEXTURE_GREEN_SIZE         = 0x805D,
	GL_TEXTURE_BLUE_SIZE          = 0x805E,
	GL_TEXTURE_ALPHA_SIZE         = 0x805F,
	GL_TEXTURE_LUMINANCE_SIZE     = 0x8060,
	GL_TEXTURE_INTENSITY_SIZE     = 0x8061,
	GL_PROXY_TEXTURE_1D           = 0x8063,
	GL_PROXY_TEXTURE_2D           = 0x8064,
	GL_TEXTURE_PRIORITY           = 0x8066,
	GL_TEXTURE_RESIDENT           = 0x8067,
	GL_TEXTURE_BINDING_1D         = 0x8068,
	GL_TEXTURE_BINDING_2D         = 0x8069,
	GL_VERTEX_ARRAY               = 0x8074,
	GL_NORMAL_ARRAY               = 0x8075,
	GL_COLOR_ARRAY                = 0x8076,
	GL_INDEX_ARRAY                = 0x8077,
	GL_TEXTURE_COORD_ARRAY        = 0x8078,
	GL_EDGE_FLAG_ARRAY            = 0x8079,
	GL_VERTEX_ARRAY_SIZE          = 0x807A,
	GL_VERTEX_ARRAY_TYPE          = 0x807B,
	GL_VERTEX_ARRAY_STRIDE        = 0x807C,
	GL_NORMAL_ARRAY_TYPE          = 0x807E,
	GL_NORMAL_ARRAY_STRIDE        = 0x807F,
	GL_COLOR_ARRAY_SIZE           = 0x8081,
	GL_COLOR_ARRAY_TYPE           = 0x8082,
	GL_COLOR_ARRAY_STRIDE         = 0x8083,
	GL_INDEX_ARRAY_TYPE           = 0x8085,
	GL_INDEX_ARRAY_STRIDE         = 0x8086,
	GL_TEXTURE_COORD_ARRAY_SIZE   = 0x8088,
	GL_TEXTURE_COORD_ARRAY_TYPE   = 0x8089,
	GL_TEXTURE_COORD_ARRAY_STRIDE = 0x808A,
	GL_EDGE_FLAG_ARRAY_STRIDE     = 0x808C,
	GL_VERTEX_ARRAY_POINTER       = 0x808E,
	GL_NORMAL_ARRAY_POINTER       = 0x808F,
	GL_COLOR_ARRAY_POINTER        = 0x8090,
	GL_INDEX_ARRAY_POINTER        = 0x8091,
	GL_TEXTURE_COORD_ARRAY_POINTER= 0x8092,
	GL_EDGE_FLAG_ARRAY_POINTER    = 0x8093,
	GL_V2F                        = 0x2A20,
	GL_V3F                        = 0x2A21,
	GL_C4UB_V2F                   = 0x2A22,
	GL_C4UB_V3F                   = 0x2A23,
	GL_C3F_V3F                    = 0x2A24,
	GL_N3F_V3F                    = 0x2A25,
	GL_C4F_N3F_V3F                = 0x2A26,
	GL_T2F_V3F                    = 0x2A27,
	GL_T4F_V4F                    = 0x2A28,
	GL_T2F_C4UB_V3F               = 0x2A29,
	GL_T2F_C3F_V3F                = 0x2A2A,
	GL_T2F_N3F_V3F                = 0x2A2B,
	GL_T2F_C4F_N3F_V3F            = 0x2A2C,
	GL_T4F_C4F_N3F_V4F            = 0x2A2D,
	GL_EXT_vertex_array               = 1,
	GL_EXT_bgra                       = 1,
	GL_EXT_paletted_texture           = 1,
	GL_WIN_swap_hint                  = 1,
	GL_WIN_draw_range_elements        = 1,
	GL_VERTEX_ARRAY_EXT           = 0x8074,
	GL_NORMAL_ARRAY_EXT           = 0x8075,
	GL_COLOR_ARRAY_EXT            = 0x8076,
	GL_INDEX_ARRAY_EXT            = 0x8077,
	GL_TEXTURE_COORD_ARRAY_EXT    = 0x8078,
	GL_EDGE_FLAG_ARRAY_EXT        = 0x8079,
	GL_VERTEX_ARRAY_SIZE_EXT      = 0x807A,
	GL_VERTEX_ARRAY_TYPE_EXT      = 0x807B,
	GL_VERTEX_ARRAY_STRIDE_EXT    = 0x807C,
	GL_VERTEX_ARRAY_COUNT_EXT     = 0x807D,
	GL_NORMAL_ARRAY_TYPE_EXT      = 0x807E,
	GL_NORMAL_ARRAY_STRIDE_EXT    = 0x807F,
	GL_NORMAL_ARRAY_COUNT_EXT     = 0x8080,
	GL_COLOR_ARRAY_SIZE_EXT       = 0x8081,
	GL_COLOR_ARRAY_TYPE_EXT       = 0x8082,
	GL_COLOR_ARRAY_STRIDE_EXT     = 0x8083,
	GL_COLOR_ARRAY_COUNT_EXT      = 0x8084,
	GL_INDEX_ARRAY_TYPE_EXT       = 0x8085,
	GL_INDEX_ARRAY_STRIDE_EXT     = 0x8086,
	GL_INDEX_ARRAY_COUNT_EXT      = 0x8087,
	GL_TEXTURE_COORD_ARRAY_SIZE_EXT   = 0x8088,
	GL_TEXTURE_COORD_ARRAY_TYPE_EXT   = 0x8089,
	GL_TEXTURE_COORD_ARRAY_STRIDE_EXT = 0x808A,
	GL_TEXTURE_COORD_ARRAY_COUNT_EXT  = 0x808B,
	GL_EDGE_FLAG_ARRAY_STRIDE_EXT = 0x808C,
	GL_EDGE_FLAG_ARRAY_COUNT_EXT  = 0x808D,
	GL_VERTEX_ARRAY_POINTER_EXT   = 0x808E,
	GL_NORMAL_ARRAY_POINTER_EXT   = 0x808F,
	GL_COLOR_ARRAY_POINTER_EXT    = 0x8090,
	GL_INDEX_ARRAY_POINTER_EXT    = 0x8091,
	GL_TEXTURE_COORD_ARRAY_POINTER_EXT = 0x8092,
	GL_EDGE_FLAG_ARRAY_POINTER_EXT = 0x8093,
	GL_DOUBLE_EXT                  = GL_DOUBLE,
	GL_BGR_EXT                    = 0x80E0,
	GL_BGRA_EXT                   = 0x80E1,
	GL_COLOR_TABLE_FORMAT_EXT     = 0x80D8,
	GL_COLOR_TABLE_WIDTH_EXT      = 0x80D9,
	GL_COLOR_TABLE_RED_SIZE_EXT   = 0x80DA,
	GL_COLOR_TABLE_GREEN_SIZE_EXT = 0x80DB,
	GL_COLOR_TABLE_BLUE_SIZE_EXT  = 0x80DC,
	GL_COLOR_TABLE_ALPHA_SIZE_EXT = 0x80DD,
	GL_COLOR_TABLE_LUMINANCE_SIZE_EXT = 0x80DE,
	GL_COLOR_TABLE_INTENSITY_SIZE_EXT = 0x80DF,
	GL_COLOR_INDEX1_EXT           = 0x80E2,
	GL_COLOR_INDEX2_EXT           = 0x80E3,
	GL_COLOR_INDEX4_EXT           = 0x80E4,
	GL_COLOR_INDEX8_EXT           = 0x80E5,
	GL_COLOR_INDEX12_EXT          = 0x80E6,
	GL_COLOR_INDEX16_EXT          = 0x80E7,
	GL_MAX_ELEMENTS_VERTICES_WIN  = 0x80E8,
	GL_MAX_ELEMENTS_INDICES_WIN   = 0x80E9,
	GL_PHONG_WIN                  = 0x80EA,
	GL_PHONG_HINT_WIN             = 0x80EB,
	GL_FOG_SPECULAR_TEXTURE_WIN   = 0x80EC,
	GL_LOGIC_OP = GL_INDEX_LOGIC_OP,
	GL_TEXTURE_COMPONENTS = GL_TEXTURE_INTERNAL_FORMAT,
}

void function(GLenum op, GLfloat value) glAccum;
void function(GLenum func, GLclampf _ref) glAlphaFunc;
GLboolean function(GLsizei n, GLuint *textures, GLboolean *residences) glAreTexturesResident;
void function(GLint i) glArrayElement;
void function(GLenum mode) glBegin;
void function(GLenum target, GLuint texture) glBindTexture;
void function(GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove, GLubyte *bitmap) glBitmap;
void function(GLenum sfactor, GLenum dfactor) glBlendFunc;
void function(GLuint list) glCallList;
void function(GLsizei n, GLenum type, GLvoid *lists) glCallLists;
void function(GLbitfield mask) glClear;
void function(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) glClearAccum;
void function(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha) glClearColor;
void function(GLclampd depth) glClearDepth;
void function(GLfloat c) glClearIndex;
void function(GLint s) glClearStencil;
void function(GLenum plane, GLdouble *equation) glClipPlane;
void function(GLbyte red, GLbyte green, GLbyte blue) glColor3b;
void function(GLbyte *v) glColor3bv;
void function(GLdouble red, GLdouble green, GLdouble blue) glColor3d;
void function(GLdouble *v) glColor3dv;
void function(GLfloat red, GLfloat green, GLfloat blue) glColor3f;
void function(GLfloat *v) glColor3fv;
void function(GLint red, GLint green, GLint blue) glColor3i;
void function(GLint *v) glColor3iv;
void function(GLshort red, GLshort green, GLshort blue) glColor3s;
void function(GLshort *v) glColor3sv;
void function(GLubyte red, GLubyte green, GLubyte blue) glColor3ub;
void function(GLubyte *v) glColor3ubv;
void function(GLuint red, GLuint green, GLuint blue) glColor3ui;
void function(GLuint *v) glColor3uiv;
void function(GLushort red, GLushort green, GLushort blue) glColor3us;
void function(GLushort *v) glColor3usv;
void function(GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha) glColor4b;
void function(GLbyte *v) glColor4bv;
void function(GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha) glColor4d;
void function(GLdouble *v) glColor4dv;
void function(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) glColor4f;
void function(GLfloat *v) glColor4fv;
void function(GLint red, GLint green, GLint blue, GLint alpha) glColor4i;
void function(GLint *v) glColor4iv;
void function(GLshort red, GLshort green, GLshort blue, GLshort alpha) glColor4s;
void function(GLshort *v) glColor4sv;
void function(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha) glColor4ub;
void function(GLubyte *v) glColor4ubv;
void function(GLuint red, GLuint green, GLuint blue, GLuint alpha) glColor4ui;
void function(GLuint *v) glColor4uiv;
void function(GLushort red, GLushort green, GLushort blue, GLushort alpha) glColor4us;
void function(GLushort *v) glColor4usv;
void function(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha) glColorMask;
void function(GLenum face, GLenum mode) glColorMaterial;
void function(GLint size, GLenum type, GLsizei stride, GLvoid *pointer) glColorPointer;
void function(GLint x, GLint y, GLsizei width, GLsizei height, GLenum type) glCopyPixels;
void function(GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLint border) glCopyTexImage1D;
void function(GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border) glCopyTexImage2D;
void function(GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width) glCopyTexSubImage1D;
void function(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height) glCopyTexSubImage2D;
void function(GLenum mode) glCullFace;
void function(GLuint list, GLsizei range) glDeleteLists;
void function(GLsizei n, GLuint *textures) glDeleteTextures;
void function(GLenum func) glDepthFunc;
void function(GLboolean flag) glDepthMask;
void function(GLclampd zNear, GLclampd zFar) glDepthRange;
void function(GLenum cap) glDisable;
void function(GLenum array) glDisableClientState;
void function(GLenum mode, GLint first, GLsizei count) glDrawArrays;
void function(GLenum mode) glDrawBuffer;
void function(GLenum mode, GLsizei count, GLenum type, GLvoid *indices) glDrawElements;
void function(GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels) glDrawPixels;
void function(GLboolean flag) glEdgeFlag;
void function(GLsizei stride, GLvoid *pointer) glEdgeFlagPointer;
void function(GLboolean *flag) glEdgeFlagv;
void function(GLenum cap) glEnable;
void function(GLenum array) glEnableClientState;
void function() glEnd;
void function() glEndList;
void function(GLdouble u) glEvalCoord1d;
void function(GLdouble *u) glEvalCoord1dv;
void function(GLfloat u) glEvalCoord1f;
void function(GLfloat *u) glEvalCoord1fv;
void function(GLdouble u, GLdouble v) glEvalCoord2d;
void function(GLdouble *u) glEvalCoord2dv;
void function(GLfloat u, GLfloat v) glEvalCoord2f;
void function(GLfloat *u) glEvalCoord2fv;
void function(GLenum mode, GLint i1, GLint i2) glEvalMesh1;
void function(GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2) glEvalMesh2;
void function(GLint i) glEvalPoint1;
void function(GLint i, GLint j) glEvalPoint2;
void function(GLsizei size, GLenum type, GLfloat *buffer) glFeedbackBuffer;
void function() glFinish;
void function() glFlush;
void function(GLenum pname, GLfloat param) glFogf;
void function(GLenum pname, GLfloat *params) glFogfv;
void function(GLenum pname, GLint param) glFogi;
void function(GLenum pname, GLint *params) glFogiv;
void function(GLenum mode) glFrontFace;
void function(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar) glFrustum;
GLuint function(GLsizei range) glGenLists;
void function(GLsizei n, GLuint *textures) glGenTextures;
void function(GLenum pname, GLboolean *params) glGetBooleanv;
void function(GLenum plane, GLdouble *equation) glGetClipPlane;
void function(GLenum pname, GLdouble *params) glGetDoublev;
GLenum function() glGetError;
void function(GLenum pname, GLfloat *params) glGetFloatv;
void function(GLenum pname, GLint *params) glGetIntegerv;
void function(GLenum light, GLenum pname, GLfloat *params) glGetLightfv;
void function(GLenum light, GLenum pname, GLint *params) glGetLightiv;
void function(GLenum target, GLenum query, GLdouble *v) glGetMapdv;
void function(GLenum target, GLenum query, GLfloat *v) glGetMapfv;
void function(GLenum target, GLenum query, GLint *v) glGetMapiv;
void function(GLenum face, GLenum pname, GLfloat *params) glGetMaterialfv;
void function(GLenum face, GLenum pname, GLint *params) glGetMaterialiv;
void function(GLenum map, GLfloat *values) glGetPixelMapfv;
void function(GLenum map, GLuint *values) glGetPixelMapuiv;
void function(GLenum map, GLushort *values) glGetPixelMapusv;
void function(GLenum pname, GLvoid* *params) glGetPointerv;
void function(GLubyte *mask) glGetPolygonStipple;
GLubyte* function(GLenum name) glGetString;
void function(GLenum target, GLenum pname, GLfloat *params) glGetTexEnvfv;
void function(GLenum target, GLenum pname, GLint *params) glGetTexEnviv;
void function(GLenum coord, GLenum pname, GLdouble *params) glGetTexGendv;
void function(GLenum coord, GLenum pname, GLfloat *params) glGetTexGenfv;
void function(GLenum coord, GLenum pname, GLint *params) glGetTexGeniv;
void function(GLenum target, GLint level, GLenum format, GLenum type, GLvoid *pixels) glGetTexImage;
void function(GLenum target, GLint level, GLenum pname, GLfloat *params) glGetTexLevelParameterfv;
void function(GLenum target, GLint level, GLenum pname, GLint *params) glGetTexLevelParameteriv;
void function(GLenum target, GLenum pname, GLfloat *params) glGetTexParameterfv;
void function(GLenum target, GLenum pname, GLint *params) glGetTexParameteriv;
void function(GLenum target, GLenum mode) glHint;
void function(GLuint mask) glIndexMask;
void function(GLenum type, GLsizei stride, GLvoid *pointer) glIndexPointer;
void function(GLdouble c) glIndexd;
void function(GLdouble *c) glIndexdv;
void function(GLfloat c) glIndexf;
void function(GLfloat *c) glIndexfv;
void function(GLint c) glIndexi;
void function(GLint *c) glIndexiv;
void function(GLshort c) glIndexs;
void function(GLshort *c) glIndexsv;
void function(GLubyte c) glIndexub;
void function(GLubyte *c) glIndexubv;
void function() glInitNames;
void function(GLenum format, GLsizei stride, GLvoid *pointer) glInterleavedArrays;
GLboolean function(GLenum cap) glIsEnabled;
GLboolean function(GLuint list) glIsList;
GLboolean function(GLuint texture) glIsTexture;
void function(GLenum pname, GLfloat param) glLightModelf;
void function(GLenum pname, GLfloat *params) glLightModelfv;
void function(GLenum pname, GLint param) glLightModeli;
void function(GLenum pname, GLint *params) glLightModeliv;
void function(GLenum light, GLenum pname, GLfloat param) glLightf;
void function(GLenum light, GLenum pname, GLfloat *params) glLightfv;
void function(GLenum light, GLenum pname, GLint param) glLighti;
void function(GLenum light, GLenum pname, GLint *params) glLightiv;
void function(GLint factor, GLushort pattern) glLineStipple;
void function(GLfloat width) glLineWidth;
void function(GLuint base) glListBase;
void function() glLoadIdentity;
void function(GLdouble *m) glLoadMatrixd;
void function(GLfloat *m) glLoadMatrixf;
void function(GLuint name) glLoadName;
void function(GLenum opcode) glLogicOp;
void function(GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order, GLdouble *points) glMap1d;
void function(GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order, GLfloat *points) glMap1f;
void function(GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, GLdouble *points) glMap2d;
void function(GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, GLfloat *points) glMap2f;
void function(GLint un, GLdouble u1, GLdouble u2) glMapGrid1d;
void function(GLint un, GLfloat u1, GLfloat u2) glMapGrid1f;
void function(GLint un, GLdouble u1, GLdouble u2, GLint vn, GLdouble v1, GLdouble v2) glMapGrid2d;
void function(GLint un, GLfloat u1, GLfloat u2, GLint vn, GLfloat v1, GLfloat v2) glMapGrid2f;
void function(GLenum face, GLenum pname, GLfloat param) glMaterialf;
void function(GLenum face, GLenum pname, GLfloat *params) glMaterialfv;
void function(GLenum face, GLenum pname, GLint param) glMateriali;
void function(GLenum face, GLenum pname, GLint *params) glMaterialiv;
void function(GLenum mode) glMatrixMode;
void function(GLdouble *m) glMultMatrixd;
void function(GLfloat *m) glMultMatrixf;
void function(GLuint list, GLenum mode) glNewList;
void function(GLbyte nx, GLbyte ny, GLbyte nz) glNormal3b;
void function(GLbyte *v) glNormal3bv;
void function(GLdouble nx, GLdouble ny, GLdouble nz) glNormal3d;
void function(GLdouble *v) glNormal3dv;
void function(GLfloat nx, GLfloat ny, GLfloat nz) glNormal3f;
void function(GLfloat *v) glNormal3fv;
void function(GLint nx, GLint ny, GLint nz) glNormal3i;
void function(GLint *v) glNormal3iv;
void function(GLshort nx, GLshort ny, GLshort nz) glNormal3s;
void function(GLshort *v) glNormal3sv;
void function(GLenum type, GLsizei stride, GLvoid *pointer) glNormalPointer;
void function(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar) glOrtho;
void function(GLfloat token) glPassThrough;
void function(GLenum map, GLsizei mapsize, GLfloat *values) glPixelMapfv;
void function(GLenum map, GLsizei mapsize, GLuint *values) glPixelMapuiv;
void function(GLenum map, GLsizei mapsize, GLushort *values) glPixelMapusv;
void function(GLenum pname, GLfloat param) glPixelStoref;
void function(GLenum pname, GLint param) glPixelStorei;
void function(GLenum pname, GLfloat param) glPixelTransferf;
void function(GLenum pname, GLint param) glPixelTransferi;
void function(GLfloat xfactor, GLfloat yfactor) glPixelZoom;
void function(GLfloat size) glPointSize;
void function(GLenum face, GLenum mode) glPolygonMode;
void function(GLfloat factor, GLfloat units) glPolygonOffset;
void function(GLubyte *mask) glPolygonStipple;
void function() glPopAttrib;
void function() glPopClientAttrib;
void function() glPopMatrix;
void function() glPopName;
void function(GLsizei n, GLuint *textures, GLclampf *priorities) glPrioritizeTextures;
void function(GLbitfield mask) glPushAttrib;
void function(GLbitfield mask) glPushClientAttrib;
void function() glPushMatrix;
void function(GLuint name) glPushName;
void function(GLdouble x, GLdouble y) glRasterPos2d;
void function(GLdouble *v) glRasterPos2dv;
void function(GLfloat x, GLfloat y) glRasterPos2f;
void function(GLfloat *v) glRasterPos2fv;
void function(GLint x, GLint y) glRasterPos2i;
void function(GLint *v) glRasterPos2iv;
void function(GLshort x, GLshort y) glRasterPos2s;
void function(GLshort *v) glRasterPos2sv;
void function(GLdouble x, GLdouble y, GLdouble z) glRasterPos3d;
void function(GLdouble *v) glRasterPos3dv;
void function(GLfloat x, GLfloat y, GLfloat z) glRasterPos3f;
void function(GLfloat *v) glRasterPos3fv;
void function(GLint x, GLint y, GLint z) glRasterPos3i;
void function(GLint *v) glRasterPos3iv;
void function(GLshort x, GLshort y, GLshort z) glRasterPos3s;
void function(GLshort *v) glRasterPos3sv;
void function(GLdouble x, GLdouble y, GLdouble z, GLdouble w) glRasterPos4d;
void function(GLdouble *v) glRasterPos4dv;
void function(GLfloat x, GLfloat y, GLfloat z, GLfloat w) glRasterPos4f;
void function(GLfloat *v) glRasterPos4fv;
void function(GLint x, GLint y, GLint z, GLint w) glRasterPos4i;
void function(GLint *v) glRasterPos4iv;
void function(GLshort x, GLshort y, GLshort z, GLshort w) glRasterPos4s;
void function(GLshort *v) glRasterPos4sv;
void function(GLenum mode) glReadBuffer;
void function(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels) glReadPixels;
void function(GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2) glRectd;
void function(GLdouble *v1, GLdouble *v2) glRectdv;
void function(GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2) glRectf;
void function(GLfloat *v1, GLfloat *v2) glRectfv;
void function(GLint x1, GLint y1, GLint x2, GLint y2) glRecti;
void function(GLint *v1, GLint *v2) glRectiv;
void function(GLshort x1, GLshort y1, GLshort x2, GLshort y2) glRects;
void function(GLshort *v1, GLshort *v2) glRectsv;
GLint function(GLenum mode) glRenderMode;
void function(GLdouble angle, GLdouble x, GLdouble y, GLdouble z) glRotated;
void function(GLfloat angle, GLfloat x, GLfloat y, GLfloat z) glRotatef;
void function(GLdouble x, GLdouble y, GLdouble z) glScaled;
void function(GLfloat x, GLfloat y, GLfloat z) glScalef;
void function(GLint x, GLint y, GLsizei width, GLsizei height) glScissor;
void function(GLsizei size, GLuint *buffer) glSelectBuffer;
void function(GLenum mode) glShadeModel;
void function(GLenum func, GLint _ref, GLuint mask) glStencilFunc;
void function(GLuint mask) glStencilMask;
void function(GLenum fail, GLenum zfail, GLenum zpass) glStencilOp;
void function(GLdouble s) glTexCoord1d;
void function(GLdouble *v) glTexCoord1dv;
void function(GLfloat s) glTexCoord1f;
void function(GLfloat *v) glTexCoord1fv;
void function(GLint s) glTexCoord1i;
void function(GLint *v) glTexCoord1iv;
void function(GLshort s) glTexCoord1s;
void function(GLshort *v) glTexCoord1sv;
void function(GLdouble s, GLdouble t) glTexCoord2d;
void function(GLdouble *v) glTexCoord2dv;
void function(GLfloat s, GLfloat t) glTexCoord2f;
void function(GLfloat *v) glTexCoord2fv;
void function(GLint s, GLint t) glTexCoord2i;
void function(GLint *v) glTexCoord2iv;
void function(GLshort s, GLshort t) glTexCoord2s;
void function(GLshort *v) glTexCoord2sv;
void function(GLdouble s, GLdouble t, GLdouble r) glTexCoord3d;
void function(GLdouble *v) glTexCoord3dv;
void function(GLfloat s, GLfloat t, GLfloat r) glTexCoord3f;
void function(GLfloat *v) glTexCoord3fv;
void function(GLint s, GLint t, GLint r) glTexCoord3i;
void function(GLint *v) glTexCoord3iv;
void function(GLshort s, GLshort t, GLshort r) glTexCoord3s;
void function(GLshort *v) glTexCoord3sv;
void function(GLdouble s, GLdouble t, GLdouble r, GLdouble q) glTexCoord4d;
void function(GLdouble *v) glTexCoord4dv;
void function(GLfloat s, GLfloat t, GLfloat r, GLfloat q) glTexCoord4f;
void function(GLfloat *v) glTexCoord4fv;
void function(GLint s, GLint t, GLint r, GLint q) glTexCoord4i;
void function(GLint *v) glTexCoord4iv;
void function(GLshort s, GLshort t, GLshort r, GLshort q) glTexCoord4s;
void function(GLshort *v) glTexCoord4sv;
void function(GLint size, GLenum type, GLsizei stride, GLvoid *pointer) glTexCoordPointer;
void function(GLenum target, GLenum pname, GLfloat param) glTexEnvf;
void function(GLenum target, GLenum pname, GLfloat *params) glTexEnvfv;
void function(GLenum target, GLenum pname, GLint param) glTexEnvi;
void function(GLenum target, GLenum pname, GLint *params) glTexEnviv;
void function(GLenum coord, GLenum pname, GLdouble param) glTexGend;
void function(GLenum coord, GLenum pname, GLdouble *params) glTexGendv;
void function(GLenum coord, GLenum pname, GLfloat param) glTexGenf;
void function(GLenum coord, GLenum pname, GLfloat *params) glTexGenfv;
void function(GLenum coord, GLenum pname, GLint param) glTexGeni;
void function(GLenum coord, GLenum pname, GLint *params) glTexGeniv;
void function(GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, GLvoid *pixels) glTexImage1D;
void function(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, GLvoid *pixels) glTexImage2D;
void function(GLenum target, GLenum pname, GLfloat param) glTexParameterf;
void function(GLenum target, GLenum pname, GLfloat *params) glTexParameterfv;
void function(GLenum target, GLenum pname, GLint param) glTexParameteri;
void function(GLenum target, GLenum pname, GLint *params) glTexParameteriv;
void function(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, GLvoid *pixels) glTexSubImage1D;
void function(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels) glTexSubImage2D;
void function(GLdouble x, GLdouble y, GLdouble z) glTranslated;
void function(GLfloat x, GLfloat y, GLfloat z) glTranslatef;
void function(GLdouble x, GLdouble y) glVertex2d;
void function(GLdouble *v) glVertex2dv;
void function(GLfloat x, GLfloat y) glVertex2f;
void function(GLfloat *v) glVertex2fv;
void function(GLint x, GLint y) glVertex2i;
void function(GLint *v) glVertex2iv;
void function(GLshort x, GLshort y) glVertex2s;
void function(GLshort *v) glVertex2sv;
void function(GLdouble x, GLdouble y, GLdouble z) glVertex3d;
void function(GLdouble *v) glVertex3dv;
void function(GLfloat x, GLfloat y, GLfloat z) glVertex3f;
void function(GLfloat *v) glVertex3fv;
void function(GLint x, GLint y, GLint z) glVertex3i;
void function(GLint *v) glVertex3iv;
void function(GLshort x, GLshort y, GLshort z) glVertex3s;
void function(GLshort *v) glVertex3sv;
void function(GLdouble x, GLdouble y, GLdouble z, GLdouble w) glVertex4d;
void function(GLdouble *v) glVertex4dv;
void function(GLfloat x, GLfloat y, GLfloat z, GLfloat w) glVertex4f;
void function(GLfloat *v) glVertex4fv;
void function(GLint x, GLint y, GLint z, GLint w) glVertex4i;
void function(GLint *v) glVertex4iv;
void function(GLshort x, GLshort y, GLshort z, GLshort w) glVertex4s;
void function(GLshort *v) glVertex4sv;
void function(GLint size, GLenum type, GLsizei stride, GLvoid *pointer) glVertexPointer;
void function(GLint x, GLint y, GLsizei width, GLsizei height) glViewport;

typedef void (* PFNGLARRAYELEMENTEXTPROC) (GLint i);
typedef void (* PFNGLDRAWARRAYSEXTPROC) (GLenum mode, GLint first, GLsizei count);
typedef void (* PFNGLVERTEXPOINTEREXTPROC) (GLint size, GLenum type, GLsizei stride, GLsizei count, GLvoid *pointer);
typedef void (* PFNGLNORMALPOINTEREXTPROC) (GLenum type, GLsizei stride, GLsizei count, GLvoid *pointer);
typedef void (* PFNGLCOLORPOINTEREXTPROC) (GLint size, GLenum type, GLsizei stride, GLsizei count, GLvoid *pointer);
typedef void (* PFNGLINDEXPOINTEREXTPROC) (GLenum type, GLsizei stride, GLsizei count, GLvoid *pointer);
typedef void (* PFNGLTEXCOORDPOINTEREXTPROC) (GLint size, GLenum type, GLsizei stride, GLsizei count, GLvoid *pointer);
typedef void (* PFNGLEDGEFLAGPOINTEREXTPROC) (GLsizei stride, GLsizei count, GLboolean *pointer);
typedef void (* PFNGLGETPOINTERVEXTPROC) (GLenum pname, GLvoid* *params);
typedef void (* PFNGLARRAYELEMENTARRAYEXTPROC)(GLenum mode, GLsizei count, GLvoid* pi);
typedef void (* PFNGLDRAWRANGEELEMENTSWINPROC) (GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, GLvoid *indices);
typedef void (* PFNGLADDSWAPHINTRECTWINPROC)  (GLint x, GLint y, GLsizei width, GLsizei height);
typedef void (* PFNGLCOLORTABLEEXTPROC) (GLenum target, GLenum internalFormat, GLsizei width, GLenum format, GLenum type, GLvoid *data);
typedef void (* PFNGLCOLORSUBTABLEEXTPROC) (GLenum target, GLsizei start, GLsizei count, GLenum format, GLenum type, GLvoid *data);
typedef void (* PFNGLGETCOLORTABLEEXTPROC) (GLenum target, GLenum format, GLenum type, GLvoid *data);
typedef void (* PFNGLGETCOLORTABLEPARAMETERIVEXTPROC) (GLenum target, GLenum pname, GLint *params);
typedef void (* PFNGLGETCOLORTABLEPARAMETERFVEXTPROC) (GLenum target, GLenum pname, GLfloat *params);

void glUsing11() {
	mixin(glBindFuncBaseMix("glAccum"));
	mixin(glBindFuncBaseMix("glAlphaFunc"));
	mixin(glBindFuncBaseMix("glAreTexturesResident"));
	mixin(glBindFuncBaseMix("glArrayElement"));
	mixin(glBindFuncBaseMix("glBegin"));
	mixin(glBindFuncBaseMix("glBindTexture"));
	mixin(glBindFuncBaseMix("glBitmap"));
	mixin(glBindFuncBaseMix("glBlendFunc"));
	mixin(glBindFuncBaseMix("glCallList"));
	mixin(glBindFuncBaseMix("glCallLists"));
	mixin(glBindFuncBaseMix("glClear"));
	mixin(glBindFuncBaseMix("glClearAccum"));
	mixin(glBindFuncBaseMix("glClearColor"));
	mixin(glBindFuncBaseMix("glClearDepth"));
	mixin(glBindFuncBaseMix("glClearIndex"));
	mixin(glBindFuncBaseMix("glClearStencil"));
	mixin(glBindFuncBaseMix("glClipPlane"));
	mixin(glBindFuncBaseMix("glColor3b"));
	mixin(glBindFuncBaseMix("glColor3bv"));
	mixin(glBindFuncBaseMix("glColor3d"));
	mixin(glBindFuncBaseMix("glColor3dv"));
	mixin(glBindFuncBaseMix("glColor3f"));
	mixin(glBindFuncBaseMix("glColor3fv"));
	mixin(glBindFuncBaseMix("glColor3i"));
	mixin(glBindFuncBaseMix("glColor3iv"));
	mixin(glBindFuncBaseMix("glColor3s"));
	mixin(glBindFuncBaseMix("glColor3sv"));
	mixin(glBindFuncBaseMix("glColor3ub"));
	mixin(glBindFuncBaseMix("glColor3ubv"));
	mixin(glBindFuncBaseMix("glColor3ui"));
	mixin(glBindFuncBaseMix("glColor3uiv"));
	mixin(glBindFuncBaseMix("glColor3us"));
	mixin(glBindFuncBaseMix("glColor3usv"));
	mixin(glBindFuncBaseMix("glColor4b"));
	mixin(glBindFuncBaseMix("glColor4bv"));
	mixin(glBindFuncBaseMix("glColor4d"));
	mixin(glBindFuncBaseMix("glColor4dv"));
	mixin(glBindFuncBaseMix("glColor4f"));
	mixin(glBindFuncBaseMix("glColor4fv"));
	mixin(glBindFuncBaseMix("glColor4i"));
	mixin(glBindFuncBaseMix("glColor4iv"));
	mixin(glBindFuncBaseMix("glColor4s"));
	mixin(glBindFuncBaseMix("glColor4sv"));
	mixin(glBindFuncBaseMix("glColor4ub"));
	mixin(glBindFuncBaseMix("glColor4ubv"));
	mixin(glBindFuncBaseMix("glColor4ui"));
	mixin(glBindFuncBaseMix("glColor4uiv"));
	mixin(glBindFuncBaseMix("glColor4us"));
	mixin(glBindFuncBaseMix("glColor4usv"));
	mixin(glBindFuncBaseMix("glColorMask"));
	mixin(glBindFuncBaseMix("glColorMaterial"));
	mixin(glBindFuncBaseMix("glColorPointer"));
	mixin(glBindFuncBaseMix("glCopyPixels"));
	mixin(glBindFuncBaseMix("glCopyTexImage1D"));
	mixin(glBindFuncBaseMix("glCopyTexImage2D"));
	mixin(glBindFuncBaseMix("glCopyTexSubImage1D"));
	mixin(glBindFuncBaseMix("glCopyTexSubImage2D"));
	mixin(glBindFuncBaseMix("glCullFace"));
	mixin(glBindFuncBaseMix("glDeleteLists"));
	mixin(glBindFuncBaseMix("glDeleteTextures"));
	mixin(glBindFuncBaseMix("glDepthFunc"));
	mixin(glBindFuncBaseMix("glDepthMask"));
	mixin(glBindFuncBaseMix("glDepthRange"));
	mixin(glBindFuncBaseMix("glDisable"));
	mixin(glBindFuncBaseMix("glDisableClientState"));
	mixin(glBindFuncBaseMix("glDrawArrays"));
	mixin(glBindFuncBaseMix("glDrawBuffer"));
	mixin(glBindFuncBaseMix("glDrawElements"));
	mixin(glBindFuncBaseMix("glDrawPixels"));
	mixin(glBindFuncBaseMix("glEdgeFlag"));
	mixin(glBindFuncBaseMix("glEdgeFlagPointer"));
	mixin(glBindFuncBaseMix("glEdgeFlagv"));
	mixin(glBindFuncBaseMix("glEnable"));
	mixin(glBindFuncBaseMix("glEnableClientState"));
	mixin(glBindFuncBaseMix("glEnd"));
	mixin(glBindFuncBaseMix("glEndList"));
	mixin(glBindFuncBaseMix("glEvalCoord1d"));
	mixin(glBindFuncBaseMix("glEvalCoord1dv"));
	mixin(glBindFuncBaseMix("glEvalCoord1f"));
	mixin(glBindFuncBaseMix("glEvalCoord1fv"));
	mixin(glBindFuncBaseMix("glEvalCoord2d"));
	mixin(glBindFuncBaseMix("glEvalCoord2dv"));
	mixin(glBindFuncBaseMix("glEvalCoord2f"));
	mixin(glBindFuncBaseMix("glEvalCoord2fv"));
	mixin(glBindFuncBaseMix("glEvalMesh1"));
	mixin(glBindFuncBaseMix("glEvalMesh2"));
	mixin(glBindFuncBaseMix("glEvalPoint1"));
	mixin(glBindFuncBaseMix("glEvalPoint2"));
	mixin(glBindFuncBaseMix("glFeedbackBuffer"));
	mixin(glBindFuncBaseMix("glFinish"));
	mixin(glBindFuncBaseMix("glFlush"));
	mixin(glBindFuncBaseMix("glFogf"));
	mixin(glBindFuncBaseMix("glFogfv"));
	mixin(glBindFuncBaseMix("glFogi"));
	mixin(glBindFuncBaseMix("glFogiv"));
	mixin(glBindFuncBaseMix("glFrontFace"));
	mixin(glBindFuncBaseMix("glFrustum"));
	mixin(glBindFuncBaseMix("glGenLists"));
	mixin(glBindFuncBaseMix("glGenTextures"));
	mixin(glBindFuncBaseMix("glGetBooleanv"));
	mixin(glBindFuncBaseMix("glGetClipPlane"));
	mixin(glBindFuncBaseMix("glGetDoublev"));
	mixin(glBindFuncBaseMix("glGetError"));
	mixin(glBindFuncBaseMix("glGetFloatv"));
	mixin(glBindFuncBaseMix("glGetIntegerv"));
	mixin(glBindFuncBaseMix("glGetLightfv"));
	mixin(glBindFuncBaseMix("glGetLightiv"));
	mixin(glBindFuncBaseMix("glGetMapdv"));
	mixin(glBindFuncBaseMix("glGetMapfv"));
	mixin(glBindFuncBaseMix("glGetMapiv"));
	mixin(glBindFuncBaseMix("glGetMaterialfv"));
	mixin(glBindFuncBaseMix("glGetMaterialiv"));
	mixin(glBindFuncBaseMix("glGetPixelMapfv"));
	mixin(glBindFuncBaseMix("glGetPixelMapuiv"));
	mixin(glBindFuncBaseMix("glGetPixelMapusv"));
	mixin(glBindFuncBaseMix("glGetPointerv"));
	mixin(glBindFuncBaseMix("glGetPolygonStipple"));
	mixin(glBindFuncBaseMix("glGetString"));
	mixin(glBindFuncBaseMix("glGetTexEnvfv"));
	mixin(glBindFuncBaseMix("glGetTexEnviv"));
	mixin(glBindFuncBaseMix("glGetTexGendv"));
	mixin(glBindFuncBaseMix("glGetTexGenfv"));
	mixin(glBindFuncBaseMix("glGetTexGeniv"));
	mixin(glBindFuncBaseMix("glGetTexImage"));
	mixin(glBindFuncBaseMix("glGetTexLevelParameterfv"));
	mixin(glBindFuncBaseMix("glGetTexLevelParameteriv"));
	mixin(glBindFuncBaseMix("glGetTexParameterfv"));
	mixin(glBindFuncBaseMix("glGetTexParameteriv"));
	mixin(glBindFuncBaseMix("glHint"));
	mixin(glBindFuncBaseMix("glIndexMask"));
	mixin(glBindFuncBaseMix("glIndexPointer"));
	mixin(glBindFuncBaseMix("glIndexd"));
	mixin(glBindFuncBaseMix("glIndexdv"));
	mixin(glBindFuncBaseMix("glIndexf"));
	mixin(glBindFuncBaseMix("glIndexfv"));
	mixin(glBindFuncBaseMix("glIndexi"));
	mixin(glBindFuncBaseMix("glIndexiv"));
	mixin(glBindFuncBaseMix("glIndexs"));
	mixin(glBindFuncBaseMix("glIndexsv"));
	mixin(glBindFuncBaseMix("glIndexub"));
	mixin(glBindFuncBaseMix("glIndexubv"));
	mixin(glBindFuncBaseMix("glInitNames"));
	mixin(glBindFuncBaseMix("glInterleavedArrays"));
	mixin(glBindFuncBaseMix("glIsEnabled"));
	mixin(glBindFuncBaseMix("glIsList"));
	mixin(glBindFuncBaseMix("glIsTexture"));
	mixin(glBindFuncBaseMix("glLightModelf"));
	mixin(glBindFuncBaseMix("glLightModelfv"));
	mixin(glBindFuncBaseMix("glLightModeli"));
	mixin(glBindFuncBaseMix("glLightModeliv"));
	mixin(glBindFuncBaseMix("glLightf"));
	mixin(glBindFuncBaseMix("glLightfv"));
	mixin(glBindFuncBaseMix("glLighti"));
	mixin(glBindFuncBaseMix("glLightiv"));
	mixin(glBindFuncBaseMix("glLineStipple"));
	mixin(glBindFuncBaseMix("glLineWidth"));
	mixin(glBindFuncBaseMix("glListBase"));
	mixin(glBindFuncBaseMix("glLoadIdentity"));
	mixin(glBindFuncBaseMix("glLoadMatrixd"));
	mixin(glBindFuncBaseMix("glLoadMatrixf"));
	mixin(glBindFuncBaseMix("glLoadName"));
	mixin(glBindFuncBaseMix("glLogicOp"));
	mixin(glBindFuncBaseMix("glMap1d"));
	mixin(glBindFuncBaseMix("glMap1f"));
	mixin(glBindFuncBaseMix("glMap2d"));
	mixin(glBindFuncBaseMix("glMap2f"));
	mixin(glBindFuncBaseMix("glMapGrid1d"));
	mixin(glBindFuncBaseMix("glMapGrid1f"));
	mixin(glBindFuncBaseMix("glMapGrid2d"));
	mixin(glBindFuncBaseMix("glMapGrid2f"));
	mixin(glBindFuncBaseMix("glMaterialf"));
	mixin(glBindFuncBaseMix("glMaterialfv"));
	mixin(glBindFuncBaseMix("glMateriali"));
	mixin(glBindFuncBaseMix("glMaterialiv"));
	mixin(glBindFuncBaseMix("glMatrixMode"));
	mixin(glBindFuncBaseMix("glMultMatrixd"));
	mixin(glBindFuncBaseMix("glMultMatrixf"));
	mixin(glBindFuncBaseMix("glNewList"));
	mixin(glBindFuncBaseMix("glNormal3b"));
	mixin(glBindFuncBaseMix("glNormal3bv"));
	mixin(glBindFuncBaseMix("glNormal3d"));
	mixin(glBindFuncBaseMix("glNormal3dv"));
	mixin(glBindFuncBaseMix("glNormal3f"));
	mixin(glBindFuncBaseMix("glNormal3fv"));
	mixin(glBindFuncBaseMix("glNormal3i"));
	mixin(glBindFuncBaseMix("glNormal3iv"));
	mixin(glBindFuncBaseMix("glNormal3s"));
	mixin(glBindFuncBaseMix("glNormal3sv"));
	mixin(glBindFuncBaseMix("glNormalPointer"));
	mixin(glBindFuncBaseMix("glOrtho"));
	mixin(glBindFuncBaseMix("glPassThrough"));
	mixin(glBindFuncBaseMix("glPixelMapfv"));
	mixin(glBindFuncBaseMix("glPixelMapuiv"));
	mixin(glBindFuncBaseMix("glPixelMapusv"));
	mixin(glBindFuncBaseMix("glPixelStoref"));
	mixin(glBindFuncBaseMix("glPixelStorei"));
	mixin(glBindFuncBaseMix("glPixelTransferf"));
	mixin(glBindFuncBaseMix("glPixelTransferi"));
	mixin(glBindFuncBaseMix("glPixelZoom"));
	mixin(glBindFuncBaseMix("glPointSize"));
	mixin(glBindFuncBaseMix("glPolygonMode"));
	mixin(glBindFuncBaseMix("glPolygonOffset"));
	mixin(glBindFuncBaseMix("glPolygonStipple"));
	mixin(glBindFuncBaseMix("glPopAttrib"));
	mixin(glBindFuncBaseMix("glPopClientAttrib"));
	mixin(glBindFuncBaseMix("glPopMatrix"));
	mixin(glBindFuncBaseMix("glPopName"));
	mixin(glBindFuncBaseMix("glPrioritizeTextures"));
	mixin(glBindFuncBaseMix("glPushAttrib"));
	mixin(glBindFuncBaseMix("glPushClientAttrib"));
	mixin(glBindFuncBaseMix("glPushMatrix"));
	mixin(glBindFuncBaseMix("glPushName"));
	mixin(glBindFuncBaseMix("glRasterPos2d"));
	mixin(glBindFuncBaseMix("glRasterPos2dv"));
	mixin(glBindFuncBaseMix("glRasterPos2f"));
	mixin(glBindFuncBaseMix("glRasterPos2fv"));
	mixin(glBindFuncBaseMix("glRasterPos2i"));
	mixin(glBindFuncBaseMix("glRasterPos2iv"));
	mixin(glBindFuncBaseMix("glRasterPos2s"));
	mixin(glBindFuncBaseMix("glRasterPos2sv"));
	mixin(glBindFuncBaseMix("glRasterPos3d"));
	mixin(glBindFuncBaseMix("glRasterPos3dv"));
	mixin(glBindFuncBaseMix("glRasterPos3f"));
	mixin(glBindFuncBaseMix("glRasterPos3fv"));
	mixin(glBindFuncBaseMix("glRasterPos3i"));
	mixin(glBindFuncBaseMix("glRasterPos3iv"));
	mixin(glBindFuncBaseMix("glRasterPos3s"));
	mixin(glBindFuncBaseMix("glRasterPos3sv"));
	mixin(glBindFuncBaseMix("glRasterPos4d"));
	mixin(glBindFuncBaseMix("glRasterPos4dv"));
	mixin(glBindFuncBaseMix("glRasterPos4f"));
	mixin(glBindFuncBaseMix("glRasterPos4fv"));
	mixin(glBindFuncBaseMix("glRasterPos4i"));
	mixin(glBindFuncBaseMix("glRasterPos4iv"));
	mixin(glBindFuncBaseMix("glRasterPos4s"));
	mixin(glBindFuncBaseMix("glRasterPos4sv"));
	mixin(glBindFuncBaseMix("glReadBuffer"));
	mixin(glBindFuncBaseMix("glReadPixels"));
	mixin(glBindFuncBaseMix("glRectd"));
	mixin(glBindFuncBaseMix("glRectdv"));
	mixin(glBindFuncBaseMix("glRectf"));
	mixin(glBindFuncBaseMix("glRectfv"));
	mixin(glBindFuncBaseMix("glRecti"));
	mixin(glBindFuncBaseMix("glRectiv"));
	mixin(glBindFuncBaseMix("glRects"));
	mixin(glBindFuncBaseMix("glRectsv"));
	mixin(glBindFuncBaseMix("glRenderMode"));
	mixin(glBindFuncBaseMix("glRotated"));
	mixin(glBindFuncBaseMix("glRotatef"));
	mixin(glBindFuncBaseMix("glScaled"));
	mixin(glBindFuncBaseMix("glScalef"));
	mixin(glBindFuncBaseMix("glScissor"));
	mixin(glBindFuncBaseMix("glSelectBuffer"));
	mixin(glBindFuncBaseMix("glShadeModel"));
	mixin(glBindFuncBaseMix("glStencilFunc"));
	mixin(glBindFuncBaseMix("glStencilMask"));
	mixin(glBindFuncBaseMix("glStencilOp"));
	mixin(glBindFuncBaseMix("glTexCoord1d"));
	mixin(glBindFuncBaseMix("glTexCoord1dv"));
	mixin(glBindFuncBaseMix("glTexCoord1f"));
	mixin(glBindFuncBaseMix("glTexCoord1fv"));
	mixin(glBindFuncBaseMix("glTexCoord1i"));
	mixin(glBindFuncBaseMix("glTexCoord1iv"));
	mixin(glBindFuncBaseMix("glTexCoord1s"));
	mixin(glBindFuncBaseMix("glTexCoord1sv"));
	mixin(glBindFuncBaseMix("glTexCoord2d"));
	mixin(glBindFuncBaseMix("glTexCoord2dv"));
	mixin(glBindFuncBaseMix("glTexCoord2f"));
	mixin(glBindFuncBaseMix("glTexCoord2fv"));
	mixin(glBindFuncBaseMix("glTexCoord2i"));
	mixin(glBindFuncBaseMix("glTexCoord2iv"));
	mixin(glBindFuncBaseMix("glTexCoord2s"));
	mixin(glBindFuncBaseMix("glTexCoord2sv"));
	mixin(glBindFuncBaseMix("glTexCoord3d"));
	mixin(glBindFuncBaseMix("glTexCoord3dv"));
	mixin(glBindFuncBaseMix("glTexCoord3f"));
	mixin(glBindFuncBaseMix("glTexCoord3fv"));
	mixin(glBindFuncBaseMix("glTexCoord3i"));
	mixin(glBindFuncBaseMix("glTexCoord3iv"));
	mixin(glBindFuncBaseMix("glTexCoord3s"));
	mixin(glBindFuncBaseMix("glTexCoord3sv"));
	mixin(glBindFuncBaseMix("glTexCoord4d"));
	mixin(glBindFuncBaseMix("glTexCoord4dv"));
	mixin(glBindFuncBaseMix("glTexCoord4f"));
	mixin(glBindFuncBaseMix("glTexCoord4fv"));
	mixin(glBindFuncBaseMix("glTexCoord4i"));
	mixin(glBindFuncBaseMix("glTexCoord4iv"));
	mixin(glBindFuncBaseMix("glTexCoord4s"));
	mixin(glBindFuncBaseMix("glTexCoord4sv"));
	mixin(glBindFuncBaseMix("glTexCoordPointer"));
	mixin(glBindFuncBaseMix("glTexEnvf"));
	mixin(glBindFuncBaseMix("glTexEnvfv"));
	mixin(glBindFuncBaseMix("glTexEnvi"));
	mixin(glBindFuncBaseMix("glTexEnviv"));
	mixin(glBindFuncBaseMix("glTexGend"));
	mixin(glBindFuncBaseMix("glTexGendv"));
	mixin(glBindFuncBaseMix("glTexGenf"));
	mixin(glBindFuncBaseMix("glTexGenfv"));
	mixin(glBindFuncBaseMix("glTexGeni"));
	mixin(glBindFuncBaseMix("glTexGeniv"));
	mixin(glBindFuncBaseMix("glTexImage1D"));
	mixin(glBindFuncBaseMix("glTexImage2D"));
	mixin(glBindFuncBaseMix("glTexParameterf"));
	mixin(glBindFuncBaseMix("glTexParameterfv"));
	mixin(glBindFuncBaseMix("glTexParameteri"));
	mixin(glBindFuncBaseMix("glTexParameteriv"));
	mixin(glBindFuncBaseMix("glTexSubImage1D"));
	mixin(glBindFuncBaseMix("glTexSubImage2D"));
	mixin(glBindFuncBaseMix("glTranslated"));
	mixin(glBindFuncBaseMix("glTranslatef"));
	mixin(glBindFuncBaseMix("glVertex2d"));
	mixin(glBindFuncBaseMix("glVertex2dv"));
	mixin(glBindFuncBaseMix("glVertex2f"));
	mixin(glBindFuncBaseMix("glVertex2fv"));
	mixin(glBindFuncBaseMix("glVertex2i"));
	mixin(glBindFuncBaseMix("glVertex2iv"));
	mixin(glBindFuncBaseMix("glVertex2s"));
	mixin(glBindFuncBaseMix("glVertex2sv"));
	mixin(glBindFuncBaseMix("glVertex3d"));
	mixin(glBindFuncBaseMix("glVertex3dv"));
	mixin(glBindFuncBaseMix("glVertex3f"));
	mixin(glBindFuncBaseMix("glVertex3fv"));
	mixin(glBindFuncBaseMix("glVertex3i"));
	mixin(glBindFuncBaseMix("glVertex3iv"));
	mixin(glBindFuncBaseMix("glVertex3s"));
	mixin(glBindFuncBaseMix("glVertex3sv"));
	mixin(glBindFuncBaseMix("glVertex4d"));
	mixin(glBindFuncBaseMix("glVertex4dv"));
	mixin(glBindFuncBaseMix("glVertex4f"));
	mixin(glBindFuncBaseMix("glVertex4fv"));
	mixin(glBindFuncBaseMix("glVertex4i"));
	mixin(glBindFuncBaseMix("glVertex4iv"));
	mixin(glBindFuncBaseMix("glVertex4s"));
	mixin(glBindFuncBaseMix("glVertex4sv"));
	mixin(glBindFuncBaseMix("glVertexPointer"));
	mixin(glBindFuncBaseMix("glViewport"));
}

///////////////////////////////////////////////////////////////////////////////
// OPENGL 1.2                                                                //
///////////////////////////////////////////////////////////////////////////////

enum : GLenum {
    GL_RESCALE_NORMAL                  = 0x803A,
    GL_CLAMP_TO_EDGE                   = 0x812F,
    GL_MAX_ELEMENTS_VERTICES           = 0x80E8,
    GL_MAX_ELEMENTS_INDICES            = 0x80E9,
    GL_BGR                             = 0x80E0,
    GL_BGRA                            = 0x80E1,
    GL_UNSIGNED_BYTE_3_3_2             = 0x8032,
    GL_UNSIGNED_BYTE_2_3_3_REV         = 0x8362,
    GL_UNSIGNED_SHORT_5_6_5            = 0x8363,
    GL_UNSIGNED_SHORT_5_6_5_REV        = 0x8364,
    GL_UNSIGNED_SHORT_4_4_4_4          = 0x8033,
    GL_UNSIGNED_SHORT_4_4_4_4_REV      = 0x8365,
    GL_UNSIGNED_SHORT_5_5_5_1          = 0x8034,
    GL_UNSIGNED_SHORT_1_5_5_5_REV      = 0x8366,
    GL_UNSIGNED_INT_8_8_8_8            = 0x8035,
    GL_UNSIGNED_INT_8_8_8_8_REV        = 0x8367,
    GL_UNSIGNED_INT_10_10_10_2         = 0x8036,
    GL_UNSIGNED_INT_2_10_10_10_REV     = 0x8368,
    GL_LIGHT_MODEL_COLOR_CONTROL       = 0x81F8,
    GL_SINGLE_COLOR                    = 0x81F9,
    GL_SEPARATE_SPECULAR_COLOR         = 0x81FA,
    GL_TEXTURE_MIN_LOD                 = 0x813A,
    GL_TEXTURE_MAX_LOD                 = 0x813B,
    GL_TEXTURE_BASE_LEVEL              = 0x813C,
    GL_TEXTURE_MAX_LEVEL               = 0x813D,
    GL_SMOOTH_POINT_SIZE_RANGE         = 0x0B12,
    GL_SMOOTH_POINT_SIZE_GRANULARITY   = 0x0B13,
    GL_SMOOTH_LINE_WIDTH_RANGE         = 0x0B22,
    GL_SMOOTH_LINE_WIDTH_GRANULARITY   = 0x0B23,
    GL_ALIASED_POINT_SIZE_RANGE        = 0x846D,
    GL_ALIASED_LINE_WIDTH_RANGE        = 0x846E,
    GL_PACK_SKIP_IMAGES                = 0x806B,
    GL_PACK_IMAGE_HEIGHT               = 0x806C,
    GL_UNPACK_SKIP_IMAGES              = 0x806D,
    GL_UNPACK_IMAGE_HEIGHT             = 0x806E,
    GL_TEXTURE_3D                      = 0x806F,
    GL_PROXY_TEXTURE_3D                = 0x8070,
    GL_TEXTURE_DEPTH                   = 0x8071,
    GL_TEXTURE_WRAP_R                  = 0x8072,
    GL_MAX_3D_TEXTURE_SIZE             = 0x8073,
    GL_TEXTURE_BINDING_3D              = 0x806A,
}

void function(GLenum, GLuint, GLuint, GLsizei, GLenum, GLvoid*) glDrawRangeElements;
void function(GLenum, GLint, GLint, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum, GLvoid*) glTexImage3D;
void function(GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLenum, GLvoid*) glTexSubImage3D;
void function(GLenum, GLint, GLint, GLint, GLint, GLint, GLint, GLsizei, GLsizei) glCopyTexSubImage3D;

void glUsing12() {
	mixin(glBindFuncMix("glDrawRangeElements"));
	mixin(glBindFuncMix("glTexImage3D"));
	mixin(glBindFuncMix("glTexSubImage3D"));
	mixin(glBindFuncMix("glCopyTexSubImage3D"));
}

///////////////////////////////////////////////////////////////////////////////
// OPENGL 1.3                                                                //
///////////////////////////////////////////////////////////////////////////////

enum : GLenum {
    GL_TEXTURE0                    = 0x84C0,
    GL_TEXTURE1                    = 0x84C1,
    GL_TEXTURE2                    = 0x84C2,
    GL_TEXTURE3                    = 0x84C3,
    GL_TEXTURE4                    = 0x84C4,
    GL_TEXTURE5                    = 0x84C5,
    GL_TEXTURE6                    = 0x84C6,
    GL_TEXTURE7                    = 0x84C7,
    GL_TEXTURE8                    = 0x84C8,
    GL_TEXTURE9                    = 0x84C9,
    GL_TEXTURE10                   = 0x84CA,
    GL_TEXTURE11                   = 0x84CB,
    GL_TEXTURE12                   = 0x84CC,
    GL_TEXTURE13                   = 0x84CD,
    GL_TEXTURE14                   = 0x84CE,
    GL_TEXTURE15                   = 0x84CF,
    GL_TEXTURE16                   = 0x84D0,
    GL_TEXTURE17                   = 0x84D1,
    GL_TEXTURE18                   = 0x84D2,
    GL_TEXTURE19                   = 0x84D3,
    GL_TEXTURE20                   = 0x84D4,
    GL_TEXTURE21                   = 0x84D5,
    GL_TEXTURE22                   = 0x84D6,
    GL_TEXTURE23                   = 0x84D7,
    GL_TEXTURE24                   = 0x84D8,
    GL_TEXTURE25                   = 0x84D9,
    GL_TEXTURE26                   = 0x84DA,
    GL_TEXTURE27                   = 0x84DB,
    GL_TEXTURE28                   = 0x84DC,
    GL_TEXTURE29                   = 0x84DD,
    GL_TEXTURE30                   = 0x84DE,
    GL_TEXTURE31                   = 0x84DF,
    GL_ACTIVE_TEXTURE              = 0x84E0,
    GL_CLIENT_ACTIVE_TEXTURE       = 0x84E1,
    GL_MAX_TEXTURE_UNITS           = 0x84E2,
    GL_NORMAL_MAP                  = 0x8511,
    GL_REFLECTION_MAP              = 0x8512,
    GL_TEXTURE_CUBE_MAP            = 0x8513,
    GL_TEXTURE_BINDING_CUBE_MAP    = 0x8514,
    GL_TEXTURE_CUBE_MAP_POSITIVE_X = 0x8515,
    GL_TEXTURE_CUBE_MAP_NEGATIVE_X = 0x8516,
    GL_TEXTURE_CUBE_MAP_POSITIVE_Y = 0x8517,
    GL_TEXTURE_CUBE_MAP_NEGATIVE_Y = 0x8518,
    GL_TEXTURE_CUBE_MAP_POSITIVE_Z = 0x8519,
    GL_TEXTURE_CUBE_MAP_NEGATIVE_Z = 0x851A,
    GL_PROXY_TEXTURE_CUBE_MAP      = 0x851B,
    GL_MAX_CUBE_MAP_TEXTURE_SIZE   = 0x851C,
    GL_COMPRESSED_ALPHA            = 0x84E9,
    GL_COMPRESSED_LUMINANCE        = 0x84EA,
    GL_COMPRESSED_LUMINANCE_ALPHA  = 0x84EB,
    GL_COMPRESSED_INTENSITY        = 0x84EC,
    GL_COMPRESSED_RGB              = 0x84ED,
    GL_COMPRESSED_RGBA             = 0x84EE,
    GL_TEXTURE_COMPRESSION_HINT    = 0x84EF,
    GL_TEXTURE_COMPRESSED_IMAGE_SIZE   = 0x86A0,
    GL_TEXTURE_COMPRESSED      = 0x86A1,
    GL_NUM_COMPRESSED_TEXTURE_FORMATS  = 0x86A2,
    GL_COMPRESSED_TEXTURE_FORMATS  = 0x86A3,
    GL_MULTISAMPLE                 = 0x809D,
    GL_SAMPLE_ALPHA_TO_COVERAGE    = 0x809E,
    GL_SAMPLE_ALPHA_TO_ONE         = 0x809F,
    GL_SAMPLE_COVERAGE             = 0x80A0,
    GL_SAMPLE_BUFFERS              = 0x80A8,
    GL_SAMPLES                     = 0x80A9,
    GL_SAMPLE_COVERAGE_VALUE       = 0x80AA,
    GL_SAMPLE_COVERAGE_INVERT      = 0x80AB,
    GL_MULTISAMPLE_BIT             = 0x20000000,
    GL_TRANSPOSE_MODELVIEW_MATRIX  = 0x84E3,
    GL_TRANSPOSE_PROJECTION_MATRIX = 0x84E4,
    GL_TRANSPOSE_TEXTURE_MATRIX    = 0x84E5,
    GL_TRANSPOSE_COLOR_MATRIX      = 0x84E6,
    GL_COMBINE                     = 0x8570,
    GL_COMBINE_RGB                 = 0x8571,
    GL_COMBINE_ALPHA               = 0x8572,
    GL_SOURCE0_RGB                 = 0x8580,
    GL_SOURCE1_RGB                 = 0x8581,
    GL_SOURCE2_RGB                 = 0x8582,
    GL_SOURCE0_ALPHA               = 0x8588,
    GL_SOURCE1_ALPHA               = 0x8589,
    GL_SOURCE2_ALPHA               = 0x858A,
    GL_OPERAND0_RGB                = 0x8590,
    GL_OPERAND1_RGB                = 0x8591,
    GL_OPERAND2_RGB                = 0x8592,
    GL_OPERAND0_ALPHA              = 0x8598,
    GL_OPERAND1_ALPHA              = 0x8599,
    GL_OPERAND2_ALPHA              = 0x859A,
    GL_RGB_SCALE                   = 0x8573,
    GL_ADD_SIGNED                  = 0x8574,
    GL_INTERPOLATE                 = 0x8575,
    GL_SUBTRACT                    = 0x84E7,
    GL_CONSTANT                    = 0x8576,
    GL_PRIMARY_COLOR               = 0x8577,
    GL_PREVIOUS                    = 0x8578,
    GL_DOT3_RGB                    = 0x86AE,
    GL_DOT3_RGBA                   = 0x86AF,
    GL_CLAMP_TO_BORDER             = 0x812D,
}

void function(GLenum) glActiveTexture;
void function(GLenum) glClientActiveTexture;
void function(GLenum, GLdouble) glMultiTexCoord1d;
void function(GLenum, GLdouble*) glMultiTexCoord1dv;
void function(GLenum, GLfloat) glMultiTexCoord1f;
void function(GLenum, GLfloat*) glMultiTexCoord1fv;
void function(GLenum, GLint) glMultiTexCoord1i;
void function(GLenum, GLint*) glMultiTexCoord1iv;
void function(GLenum, GLshort) glMultiTexCoord1s;
void function(GLenum, GLshort*) glMultiTexCoord1sv;
void function(GLenum, GLdouble, GLdouble) glMultiTexCoord2d;
void function(GLenum, GLdouble*) glMultiTexCoord2dv;
void function(GLenum, GLfloat, GLfloat) glMultiTexCoord2f;
void function(GLenum, GLfloat*) glMultiTexCoord2fv;
void function(GLenum, GLint, GLint) glMultiTexCoord2i;
void function(GLenum, GLint*) glMultiTexCoord2iv;
void function(GLenum, GLshort, GLshort) glMultiTexCoord2s;
void function(GLenum, GLshort*) glMultiTexCoord2sv;
void function(GLenum, GLdouble, GLdouble, GLdouble) glMultiTexCoord3d;
void function(GLenum, GLdouble*) glMultiTexCoord3dv;
void function(GLenum, GLfloat, GLfloat, GLfloat) glMultiTexCoord3f;
void function(GLenum, GLfloat*) glMultiTexCoord3fv;
void function(GLenum, GLint, GLint, GLint) glMultiTexCoord3i;
void function(GLenum, GLint*) glMultiTexCoord3iv;
void function(GLenum, GLshort, GLshort, GLshort) glMultiTexCoord3s;
void function(GLenum, GLshort*) glMultiTexCoord3sv;
void function(GLenum, GLdouble, GLdouble, GLdouble, GLdouble) glMultiTexCoord4d;
void function(GLenum, GLdouble*) glMultiTexCoord4dv;
void function(GLenum, GLfloat, GLfloat, GLfloat, GLfloat) glMultiTexCoord4f;
void function(GLenum, GLfloat*) glMultiTexCoord4fv;
void function(GLenum, GLint, GLint, GLint, GLint) glMultiTexCoord4i;
void function(GLenum, GLint*) glMultiTexCoord4iv;
void function(GLenum, GLshort, GLshort, GLshort, GLshort) glMultiTexCoord4s;
void function(GLenum, GLshort*) glMultiTexCoord4sv;
void function(GLdouble[16]) glLoadTransposeMatrixd;
void function(GLfloat[16]) glLoadTransposeMatrixf;
void function(GLdouble[16]) glMultTransposeMatrixd;
void function(GLfloat[16]) glMultTransposeMatrixf;
void function(GLclampf, GLboolean) glSampleCoverage;
void function(GLenum, GLint, GLenum, GLsizei, GLint, GLsizei, GLvoid*) glCompressedTexImage1D;
void function(GLenum, GLint, GLenum, GLsizei, GLsizei, GLint, GLsizei, GLvoid*) glCompressedTexImage2D;
void function(GLenum, GLint, GLenum, GLsizei, GLsizei, GLsizei depth, GLint, GLsizei, GLvoid*) glCompressedTexImage3D;
void function(GLenum, GLint, GLint, GLsizei, GLenum, GLsizei, GLvoid*) glCompressedTexSubImage1D;
void function(GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLsizei, GLvoid*) glCompressedTexSubImage2D;
void function(GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLsizei, GLvoid*) glCompressedTexSubImage3D;
void function(GLenum, GLint, GLvoid*) glGetCompressedTexImage;

void glUsing13() {
	mixin(glBindFuncMix("glActiveTexture"));
	mixin(glBindFuncMix("glClientActiveTexture"));
	mixin(glBindFuncMix("glMultiTexCoord1d"));
	mixin(glBindFuncMix("glMultiTexCoord1dv"));
	mixin(glBindFuncMix("glMultiTexCoord1f"));
	mixin(glBindFuncMix("glMultiTexCoord1fv"));
	mixin(glBindFuncMix("glMultiTexCoord1i"));
	mixin(glBindFuncMix("glMultiTexCoord1iv"));
	mixin(glBindFuncMix("glMultiTexCoord1s"));
	mixin(glBindFuncMix("glMultiTexCoord1sv"));
	mixin(glBindFuncMix("glMultiTexCoord2d"));
	mixin(glBindFuncMix("glMultiTexCoord2dv"));
	mixin(glBindFuncMix("glMultiTexCoord2f"));
	mixin(glBindFuncMix("glMultiTexCoord2fv"));
	mixin(glBindFuncMix("glMultiTexCoord2i"));
	mixin(glBindFuncMix("glMultiTexCoord2iv"));
	mixin(glBindFuncMix("glMultiTexCoord2s"));
	mixin(glBindFuncMix("glMultiTexCoord2sv"));
	mixin(glBindFuncMix("glMultiTexCoord3d"));
	mixin(glBindFuncMix("glMultiTexCoord3dv"));
	mixin(glBindFuncMix("glMultiTexCoord3f"));
	mixin(glBindFuncMix("glMultiTexCoord3fv"));
	mixin(glBindFuncMix("glMultiTexCoord3i"));
	mixin(glBindFuncMix("glMultiTexCoord3iv"));
	mixin(glBindFuncMix("glMultiTexCoord3s"));
	mixin(glBindFuncMix("glMultiTexCoord3sv"));
	mixin(glBindFuncMix("glMultiTexCoord4d"));
	mixin(glBindFuncMix("glMultiTexCoord4dv"));
	mixin(glBindFuncMix("glMultiTexCoord4f"));
	mixin(glBindFuncMix("glMultiTexCoord4fv"));
	mixin(glBindFuncMix("glMultiTexCoord4i"));
	mixin(glBindFuncMix("glMultiTexCoord4iv"));
	mixin(glBindFuncMix("glMultiTexCoord4s"));
	mixin(glBindFuncMix("glMultiTexCoord4sv"));
	mixin(glBindFuncMix("glLoadTransposeMatrixd"));
	mixin(glBindFuncMix("glLoadTransposeMatrixf"));
	mixin(glBindFuncMix("glMultTransposeMatrixd"));
	mixin(glBindFuncMix("glMultTransposeMatrixf"));
	mixin(glBindFuncMix("glSampleCoverage"));
	mixin(glBindFuncMix("glCompressedTexImage1D"));
	mixin(glBindFuncMix("glCompressedTexImage2D"));
	mixin(glBindFuncMix("glCompressedTexImage3D"));
	mixin(glBindFuncMix("glCompressedTexSubImage1D"));
	mixin(glBindFuncMix("glCompressedTexSubImage2D"));
	mixin(glBindFuncMix("glCompressedTexSubImage3D"));
	mixin(glBindFuncMix("glGetCompressedTexImage"));
}


///////////////////////////////////////////////////////////////////////////////
// OPENGL 1.4                                                                //
///////////////////////////////////////////////////////////////////////////////

enum : GLenum {
    GL_BLEND_DST_RGB                   = 0x80C8,
    GL_BLEND_SRC_RGB                   = 0x80C9,
    GL_BLEND_DST_ALPHA                 = 0x80CA,
    GL_BLEND_SRC_ALPHA                 = 0x80CB,
    GL_POINT_SIZE_MIN                  = 0x8126,
    GL_POINT_SIZE_MAX                  = 0x8127,
    GL_POINT_FADE_THRESHOLD_SIZE       = 0x8128,
    GL_POINT_DISTANCE_ATTENUATION      = 0x8129,
    GL_GENERATE_MIPMAP                 = 0x8191,
    GL_GENERATE_MIPMAP_HINT            = 0x8192,
    GL_DEPTH_COMPONENT16               = 0x81A5,
    GL_DEPTH_COMPONENT24               = 0x81A6,
    GL_DEPTH_COMPONENT32               = 0x81A7,
    GL_MIRRORED_REPEAT                 = 0x8370,
    GL_FOG_COORDINATE_SOURCE           = 0x8450,
    GL_FOG_COORDINATE                  = 0x8451,
    GL_FRAGMENT_DEPTH                  = 0x8452,
    GL_CURRENT_FOG_COORDINATE          = 0x8453,
    GL_FOG_COORDINATE_ARRAY_TYPE       = 0x8454,
    GL_FOG_COORDINATE_ARRAY_STRIDE     = 0x8455,
    GL_FOG_COORDINATE_ARRAY_POINTER    = 0x8456,
    GL_FOG_COORDINATE_ARRAY            = 0x8457,
    GL_COLOR_SUM                       = 0x8458,
    GL_CURRENT_SECONDARY_COLOR         = 0x8459,
    GL_SECONDARY_COLOR_ARRAY_SIZE      = 0x845A,
    GL_SECONDARY_COLOR_ARRAY_TYPE      = 0x845B,
    GL_SECONDARY_COLOR_ARRAY_STRIDE    = 0x845C,
    GL_SECONDARY_COLOR_ARRAY_POINTER   = 0x845D,
    GL_SECONDARY_COLOR_ARRAY           = 0x845E,
    GL_MAX_TEXTURE_LOD_BIAS            = 0x84FD,
    GL_TEXTURE_FILTER_CONTROL          = 0x8500,
    GL_TEXTURE_LOD_BIAS                = 0x8501,
    GL_INCR_WRAP                       = 0x8507,
    GL_DECR_WRAP                       = 0x8508,
    GL_TEXTURE_DEPTH_SIZE              = 0x884A,
    GL_DEPTH_TEXTURE_MODE              = 0x884B,
    GL_TEXTURE_COMPARE_MODE            = 0x884C,
    GL_TEXTURE_COMPARE_FUNC            = 0x884D,
    GL_COMPARE_R_TO_TEXTURE            = 0x884E,
    GL_CONSTANT_COLOR                  = 0x8001,
    GL_ONE_MINUS_CONSTANT_COLOR        = 0x8002,
    GL_CONSTANT_ALPHA                  = 0x8003,
    GL_ONE_MINUS_CONSTANT_ALPHA        = 0x8004,
    GL_BLEND_COLOR                     = 0x8005,
    GL_FUNC_ADD                        = 0x8006,
    GL_MIN                             = 0x8007,
    GL_MAX                             = 0x8008,
    GL_BLEND_EQUATION                  = 0x8009,
    GL_FUNC_SUBTRACT                   = 0x800A,
    GL_FUNC_REVERSE_SUBTRACT           = 0x800B,
}

void function(GLenum, GLenum, GLenum, GLenum) glBlendFuncSeparate;
void function(GLfloat) glFogCoordf;
void function(GLfloat*) glFogCoordfv;
void function(GLdouble) glFogCoordd;
void function(GLdouble*) glFogCoorddv;
void function(GLenum, GLsizei,GLvoid*) glFogCoordPointer;
void function(GLenum, GLint*, GLsizei*, GLsizei) glMultiDrawArrays;
void function(GLenum, GLsizei*, GLenum, GLvoid**, GLsizei) glMultiDrawElements;
void function(GLenum, GLfloat) glPointParameterf;
void function(GLenum, GLfloat*) glPointParameterfv;
void function(GLenum, GLint) glPointParameteri;
void function(GLenum, GLint*) glPointParameteriv;
void function(GLbyte, GLbyte, GLbyte) glSecondaryColor3b;
void function(GLbyte*) glSecondaryColor3bv;
void function(GLdouble, GLdouble, GLdouble) glSecondaryColor3d;
void function(GLdouble*) glSecondaryColor3dv;
void function(GLfloat, GLfloat, GLfloat) glSecondaryColor3f;
void function(GLfloat*) glSecondaryColor3fv;
void function(GLint, GLint, GLint) glSecondaryColor3i;
void function(GLint*) glSecondaryColor3iv;
void function(GLshort, GLshort, GLshort) glSecondaryColor3s;
void function(GLshort*) glSecondaryColor3sv;
void function(GLubyte, GLubyte, GLubyte) glSecondaryColor3ub;
void function(GLubyte*) glSecondaryColor3ubv;
void function(GLuint, GLuint, GLuint) glSecondaryColor3ui;
void function(GLuint*) glSecondaryColor3uiv;
void function(GLushort, GLushort, GLushort) glSecondaryColor3us;
void function(GLushort*) glSecondaryColor3usv;
void function(GLint, GLenum, GLsizei, GLvoid*) glSecondaryColorPointer;
void function(GLdouble, GLdouble) glWindowPos2d;
void function(GLdouble*) glWindowPos2dv;
void function(GLfloat, GLfloat) glWindowPos2f;
void function(GLfloat*) glWindowPos2fv;
void function(GLint, GLint) glWindowPos2i;
void function(GLint*) glWindowPos2iv;
void function(GLshort, GLshort) glWindowPos2s;
void function(GLshort*) glWindowPos2sv;
void function(GLdouble, GLdouble, GLdouble) glWindowPos3d;
void function(GLdouble*) glWindowPos3dv;
void function(GLfloat, GLfloat, GLfloat) glWindowPos3f;
void function(GLfloat*) glWindowPos3fv;
void function(GLint, GLint, GLint) glWindowPos3i;
void function(GLint*) glWindowPos3iv;
void function(GLshort, GLshort, GLshort) glWindowPos3s;
void function(GLshort*) glWindowPos3sv;
void function(GLclampf, GLclampf, GLclampf, GLclampf) glBlendColor;
void function(GLenum) glBlendEquation;

void glUsing14() {
	mixin(glBindFuncMix("glBlendFuncSeparate"));
	mixin(glBindFuncMix("glFogCoordf"));
	mixin(glBindFuncMix("glFogCoordfv"));
	mixin(glBindFuncMix("glFogCoordd"));
	mixin(glBindFuncMix("glFogCoorddv"));
	mixin(glBindFuncMix("glFogCoordPointer"));
	mixin(glBindFuncMix("glMultiDrawArrays"));
	mixin(glBindFuncMix("glMultiDrawElements"));
	mixin(glBindFuncMix("glPointParameterf"));
	mixin(glBindFuncMix("glPointParameterfv"));
	mixin(glBindFuncMix("glPointParameteri"));
	mixin(glBindFuncMix("glPointParameteriv"));
	mixin(glBindFuncMix("glSecondaryColor3b"));
	mixin(glBindFuncMix("glSecondaryColor3bv"));
	mixin(glBindFuncMix("glSecondaryColor3d"));
	mixin(glBindFuncMix("glSecondaryColor3dv"));
	mixin(glBindFuncMix("glSecondaryColor3f"));
	mixin(glBindFuncMix("glSecondaryColor3fv"));
	mixin(glBindFuncMix("glSecondaryColor3i"));
	mixin(glBindFuncMix("glSecondaryColor3iv"));
	mixin(glBindFuncMix("glSecondaryColor3s"));
	mixin(glBindFuncMix("glSecondaryColor3sv"));
	mixin(glBindFuncMix("glSecondaryColor3ub"));
	mixin(glBindFuncMix("glSecondaryColor3ubv"));
	mixin(glBindFuncMix("glSecondaryColor3ui"));
	mixin(glBindFuncMix("glSecondaryColor3uiv"));
	mixin(glBindFuncMix("glSecondaryColor3us"));
	mixin(glBindFuncMix("glSecondaryColor3usv"));
	mixin(glBindFuncMix("glSecondaryColorPointer"));
	mixin(glBindFuncMix("glWindowPos2d"));
	mixin(glBindFuncMix("glWindowPos2dv"));
	mixin(glBindFuncMix("glWindowPos2f"));
	mixin(glBindFuncMix("glWindowPos2fv"));
	mixin(glBindFuncMix("glWindowPos2i"));
	mixin(glBindFuncMix("glWindowPos2iv"));
	mixin(glBindFuncMix("glWindowPos2s"));
	mixin(glBindFuncMix("glWindowPos2sv"));
	mixin(glBindFuncMix("glWindowPos3d"));
	mixin(glBindFuncMix("glWindowPos3dv"));
	mixin(glBindFuncMix("glWindowPos3f"));
	mixin(glBindFuncMix("glWindowPos3fv"));
	mixin(glBindFuncMix("glWindowPos3i"));
	mixin(glBindFuncMix("glWindowPos3iv"));
	mixin(glBindFuncMix("glWindowPos3s"));
	mixin(glBindFuncMix("glWindowPos3sv"));
	mixin(glBindFuncMix("glBlendColor"));
	mixin(glBindFuncMix("glBlendEquation"));
}

///////////////////////////////////////////////////////////////////////////////
// OPENGL 1.5                                                                //
///////////////////////////////////////////////////////////////////////////////

enum : GLenum {
    GL_BUFFER_SIZE                     = 0x8764,
    GL_BUFFER_USAGE                    = 0x8765,
    GL_QUERY_COUNTER_BITS              = 0x8864,
    GL_CURRENT_QUERY                   = 0x8865,
    GL_QUERY_RESULT                    = 0x8866,
    GL_QUERY_RESULT_AVAILABLE          = 0x8867,
    GL_ARRAY_BUFFER                    = 0x8892,
    GL_ELEMENT_ARRAY_BUFFER            = 0x8893,
    GL_ARRAY_BUFFER_BINDING            = 0x8894,
    GL_ELEMENT_ARRAY_BUFFER_BINDING    = 0x8895,
    GL_VERTEX_ARRAY_BUFFER_BINDING     = 0x8896,
    GL_NORMAL_ARRAY_BUFFER_BINDING     = 0x8897,
    GL_COLOR_ARRAY_BUFFER_BINDING      = 0x8898,
    GL_INDEX_ARRAY_BUFFER_BINDING      = 0x8899,
    GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING = 0x889A,
    GL_EDGE_FLAG_ARRAY_BUFFER_BINDING  = 0x889B,
    GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING = 0x889C,
    GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING = 0x889D,
    GL_WEIGHT_ARRAY_BUFFER_BINDING     = 0x889E,
    GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = 0x889F,
    GL_READ_ONLY                       = 0x88B8,
    GL_WRITE_ONLY                      = 0x88B9,
    GL_READ_WRITE                      = 0x88BA,
    GL_BUFFER_ACCESS                   = 0x88BB,
    GL_BUFFER_MAPPED                   = 0x88BC,
    GL_BUFFER_MAP_POINTER              = 0x88BD,
    GL_STREAM_DRAW                     = 0x88E0,
    GL_STREAM_READ                     = 0x88E1,
    GL_STREAM_COPY                     = 0x88E2,
    GL_STATIC_DRAW                     = 0x88E4,
    GL_STATIC_READ                     = 0x88E5,
    GL_STATIC_COPY                     = 0x88E6,
    GL_DYNAMIC_DRAW                    = 0x88E8,
    GL_DYNAMIC_READ                    = 0x88E9,
    GL_DYNAMIC_COPY                    = 0x88EA,
    GL_SAMPLES_PASSED                  = 0x8914,
    GL_FOG_COORD_SRC                   = GL_FOG_COORDINATE_SOURCE,
    GL_FOG_COORD                       = GL_FOG_COORDINATE,
    GL_CURRENT_FOG_COORD               = GL_CURRENT_FOG_COORDINATE,
    GL_FOG_COORD_ARRAY_TYPE            = GL_FOG_COORDINATE_ARRAY_TYPE,
    GL_FOG_COORD_ARRAY_STRIDE          = GL_FOG_COORDINATE_ARRAY_STRIDE,
    GL_FOG_COORD_ARRAY_POINTER         = GL_FOG_COORDINATE_ARRAY_POINTER,
    GL_FOG_COORD_ARRAY                 = GL_FOG_COORDINATE_ARRAY,
    GL_FOG_COORD_ARRAY_BUFFER_BINDING  = GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING,
    GL_SRC0_RGB                        = GL_SOURCE0_RGB,
    GL_SRC1_RGB                        = GL_SOURCE1_RGB,
    GL_SRC2_RGB                        = GL_SOURCE2_RGB,
    GL_SRC0_ALPHA                      = GL_SOURCE0_ALPHA,
    GL_SRC1_ALPHA                      = GL_SOURCE1_ALPHA,
    GL_SRC2_ALPHA                      = GL_SOURCE2_ALPHA,
}

GLvoid function(GLsizei, GLuint*) glGenQueries;
GLvoid function(GLsizei,GLuint*) glDeleteQueries;
GLboolean function(GLuint) glIsQuery;
GLvoid function(GLenum, GLuint) glBeginQuery;
GLvoid function(GLenum) glEndQuery;
GLvoid function(GLenum, GLenum, GLint*) glGetQueryiv;
GLvoid function(GLuint, GLenum, GLint*) glGetQueryObjectiv;
GLvoid function(GLuint, GLenum, GLuint*) glGetQueryObjectuiv;
GLvoid function(GLenum, GLuint) glBindBuffer;
GLvoid function(GLsizei, GLuint*) glDeleteBuffers;
GLvoid function(GLsizei, GLuint*) glGenBuffers;
GLboolean function(GLuint) glIsBuffer;
GLvoid function(GLenum, GLsizeiptr, GLvoid*, GLenum) glBufferData;
GLvoid function(GLenum, GLintptr, GLsizeiptr,GLvoid*) glBufferSubData;
GLvoid function(GLenum, GLintptr, GLsizeiptr, GLvoid*) glGetBufferSubData;
GLvoid* function(GLenum, GLenum) glMapBuffer;
GLboolean function(GLenum) glUnmapBuffer;
GLvoid function(GLenum, GLenum, GLint*) glGetBufferParameteriv;
GLvoid function(GLenum, GLenum, GLvoid**) glGetBufferPointerv;

void glUsing15() {
	mixin(glBindFuncMix("glGenQueries"));
	mixin(glBindFuncMix("glDeleteQueries"));
	mixin(glBindFuncMix("glIsQuery"));
	mixin(glBindFuncMix("glBeginQuery"));
	mixin(glBindFuncMix("glEndQuery"));
	mixin(glBindFuncMix("glGetQueryiv"));
	mixin(glBindFuncMix("glGetQueryObjectiv"));
	mixin(glBindFuncMix("glGetQueryObjectuiv"));
	mixin(glBindFuncMix("glBindBuffer"));
	mixin(glBindFuncMix("glDeleteBuffers"));
	mixin(glBindFuncMix("glGenBuffers"));
	mixin(glBindFuncMix("glIsBuffer"));
	mixin(glBindFuncMix("glBufferData"));
	mixin(glBindFuncMix("glBufferSubData"));
	mixin(glBindFuncMix("glGetBufferSubData"));
	mixin(glBindFuncMix("glMapBuffer"));
	mixin(glBindFuncMix("glUnmapBuffer"));
	mixin(glBindFuncMix("glGetBufferParameteriv"));
	mixin(glBindFuncMix("glGetBufferPointerv"));
}

///////////////////////////////////////////////////////////////////////////////
// OPENGL 2.0                                                                //
///////////////////////////////////////////////////////////////////////////////

enum : GLenum {
    GL_BLEND_EQUATION_RGB              = 0x8009,
    GL_VERTEX_ATTRIB_ARRAY_ENABLED     = 0x8622,
    GL_VERTEX_ATTRIB_ARRAY_SIZE        = 0x8623,
    GL_VERTEX_ATTRIB_ARRAY_STRIDE      = 0x8624,
    GL_VERTEX_ATTRIB_ARRAY_TYPE        = 0x8625,
    GL_CURRENT_VERTEX_ATTRIB           = 0x8626,
    GL_VERTEX_PROGRAM_POINT_SIZE       = 0x8642,
    GL_VERTEX_PROGRAM_TWO_SIDE         = 0x8643,
    GL_VERTEX_ATTRIB_ARRAY_POINTER     = 0x8645,
    GL_STENCIL_BACK_FUNC               = 0x8800,
    GL_STENCIL_BACK_FAIL               = 0x8801,
    GL_STENCIL_BACK_PASS_DEPTH_FAIL    = 0x8802,
    GL_STENCIL_BACK_PASS_DEPTH_PASS    = 0x8803,
    GL_MAX_DRAW_BUFFERS                = 0x8824,
    GL_DRAW_BUFFER0                    = 0x8825,
    GL_DRAW_BUFFER1                    = 0x8826,
    GL_DRAW_BUFFER2                    = 0x8827,
    GL_DRAW_BUFFER3                    = 0x8828,
    GL_DRAW_BUFFER4                    = 0x8829,
    GL_DRAW_BUFFER5                    = 0x882A,
    GL_DRAW_BUFFER6                    = 0x882B,
    GL_DRAW_BUFFER7                    = 0x882C,
    GL_DRAW_BUFFER8                    = 0x882D,
    GL_DRAW_BUFFER9                    = 0x882E,
    GL_DRAW_BUFFER10                   = 0x882F,
    GL_DRAW_BUFFER11                   = 0x8830,
    GL_DRAW_BUFFER12                   = 0x8831,
    GL_DRAW_BUFFER13                   = 0x8832,
    GL_DRAW_BUFFER14                   = 0x8833,
    GL_DRAW_BUFFER15                   = 0x8834,
    GL_BLEND_EQUATION_ALPHA            = 0x883D,
    GL_POINT_SPRITE                    = 0x8861,
    GL_COORD_REPLACE                   = 0x8862,
    GL_MAX_VERTEX_ATTRIBS              = 0x8869,
    GL_VERTEX_ATTRIB_ARRAY_NORMALIZED  = 0x886A,
    GL_MAX_TEXTURE_COORDS              = 0x8871,
    GL_MAX_TEXTURE_IMAGE_UNITS         = 0x8872,
    GL_FRAGMENT_SHADER                 = 0x8B30,
    GL_VERTEX_SHADER                   = 0x8B31,
    GL_MAX_FRAGMENT_UNIFORM_COMPONENTS = 0x8B49,
    GL_MAX_VERTEX_UNIFORM_COMPONENTS   = 0x8B4A,
    GL_MAX_VARYING_FLOATS              = 0x8B4B,
    GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS  = 0x8B4C,
    GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS= 0x8B4D,
    GL_SHADER_TYPE                     = 0x8B4F,
    GL_FLOAT_VEC2                      = 0x8B50,
    GL_FLOAT_VEC3                      = 0x8B51,
    GL_FLOAT_VEC4                      = 0x8B52,
    GL_INT_VEC2                        = 0x8B53,
    GL_INT_VEC3                        = 0x8B54,
    GL_INT_VEC4                        = 0x8B55,
    GL_BOOL                            = 0x8B56,
    GL_BOOL_VEC2                       = 0x8B57,
    GL_BOOL_VEC3                       = 0x8B58,
    GL_BOOL_VEC4                       = 0x8B59,
    GL_FLOAT_MAT2                      = 0x8B5A,
    GL_FLOAT_MAT3                      = 0x8B5B,
    GL_FLOAT_MAT4                      = 0x8B5C,
    GL_SAMPLER_1D                      = 0x8B5D,
    GL_SAMPLER_2D                      = 0x8B5E,
    GL_SAMPLER_3D                      = 0x8B5F,
    GL_SAMPLER_CUBE                    = 0x8B60,
    GL_SAMPLER_1D_SHADOW               = 0x8B61,
    GL_SAMPLER_2D_SHADOW               = 0x8B62,
    GL_DELETE_STATUS                   = 0x8B80,
    GL_COMPILE_STATUS                  = 0x8B81,
    GL_LINK_STATUS                     = 0x8B82,
    GL_VALIDATE_STATUS                 = 0x8B83,
    GL_INFO_LOG_LENGTH                 = 0x8B84,
    GL_ATTACHED_SHADERS                = 0x8B85,
    GL_ACTIVE_UNIFORMS                 = 0x8B86,
    GL_ACTIVE_UNIFORM_MAX_LENGTH       = 0x8B87,
    GL_SHADER_SOURCE_LENGTH            = 0x8B88,
    GL_ACTIVE_ATTRIBUTES               = 0x8B89,
    GL_ACTIVE_ATTRIBUTE_MAX_LENGTH     = 0x8B8A,
    GL_FRAGMENT_SHADER_DERIVATIVE_HINT = 0x8B8B,
    GL_SHADING_LANGUAGE_VERSION        = 0x8B8C,
    GL_CURRENT_PROGRAM                 = 0x8B8D,
    GL_POINT_SPRITE_COORD_ORIGIN       = 0x8CA0,
    GL_LOWER_LEFT                      = 0x8CA1,
    GL_UPPER_LEFT                      = 0x8CA2,
    GL_STENCIL_BACK_REF                = 0x8CA3,
    GL_STENCIL_BACK_VALUE_MASK         = 0x8CA4,
    GL_STENCIL_BACK_WRITEMASK          = 0x8CA5,
}

GLvoid function(GLenum, GLenum) glBlendEquationSeparate;
GLvoid function(GLsizei, GLenum*) glDrawBuffers;
GLvoid function(GLenum, GLenum, GLenum, GLenum) glStencilOpSeparate;
GLvoid function(GLenum, GLenum, GLint, GLuint) glStencilFuncSeparate;
GLvoid function(GLenum, GLuint) glStencilMaskSeparate;
GLvoid function(GLuint, GLuint) glAttachShader;
GLvoid function(GLuint, GLuint, GLchar*) glBindAttribLocation;
GLvoid function(GLuint) glCompileShader;
GLuint function() glCreateProgram;
GLuint function(GLenum) glCreateShader;
GLvoid function(GLuint) glDeleteProgram;
GLvoid function(GLuint) glDeleteShader;
GLvoid function(GLuint, GLuint) glDetachShader;
GLvoid function(GLuint) glDisableVertexAttribArray;
GLvoid function(GLuint) glEnableVertexAttribArray;
GLvoid function(GLuint, GLuint, GLsizei, GLsizei*, GLint*, GLenum*, GLchar*) glGetActiveAttrib;
GLvoid function(GLuint, GLuint, GLsizei, GLsizei*, GLint*, GLenum*, GLchar*) glGetActiveUniform;
GLvoid function(GLuint, GLsizei, GLsizei*, GLuint*) glGetAttachedShaders;
GLint function(GLuint, GLchar*) glGetAttribLocation;
GLvoid function(GLuint, GLenum, GLint*) glGetProgramiv;
GLvoid function(GLuint, GLsizei, GLsizei*, GLchar*) glGetProgramInfoLog;
GLvoid function(GLuint, GLenum, GLint *) glGetShaderiv;
GLvoid function(GLuint, GLsizei, GLsizei*, GLchar*) glGetShaderInfoLog;
GLvoid function(GLuint, GLsizei, GLsizei*, GLchar*) glGetShaderSource;
GLint function(GLuint, GLchar*) glGetUniformLocation;
GLvoid function(GLuint, GLint, GLfloat*) glGetUniformfv;
GLvoid function(GLuint, GLint, GLint*) glGetUniformiv;
GLvoid function(GLuint, GLenum, GLdouble*) glGetVertexAttribdv;
GLvoid function(GLuint, GLenum, GLfloat*) glGetVertexAttribfv;
GLvoid function(GLuint, GLenum, GLint*) glGetVertexAttribiv;
GLvoid function(GLuint, GLenum, GLvoid**) glGetVertexAttribPointerv;
GLboolean function(GLuint) glIsProgram;
GLboolean function(GLuint) glIsShader;
GLvoid function(GLuint) glLinkProgram;
GLvoid function(GLuint, GLsizei, GLchar**, GLint*) glShaderSource;
GLvoid function(GLuint) glUseProgram;
GLvoid function(GLint, GLfloat) glUniform1f;
GLvoid function(GLint, GLfloat, GLfloat) glUniform2f;
GLvoid function(GLint, GLfloat, GLfloat, GLfloat) glUniform3f;
GLvoid function(GLint, GLfloat, GLfloat, GLfloat, GLfloat) glUniform4f;
GLvoid function(GLint, GLint) glUniform1i;
GLvoid function(GLint, GLint, GLint) glUniform2i;
GLvoid function(GLint, GLint, GLint, GLint) glUniform3i;
GLvoid function(GLint, GLint, GLint, GLint, GLint) glUniform4i;
GLvoid function(GLint, GLsizei, GLfloat*) glUniform1fv;
GLvoid function(GLint, GLsizei, GLfloat*) glUniform2fv;
GLvoid function(GLint, GLsizei, GLfloat*) glUniform3fv;
GLvoid function(GLint, GLsizei, GLfloat*) glUniform4fv;
GLvoid function(GLint, GLsizei, GLint*) glUniform1iv;
GLvoid function(GLint, GLsizei, GLint*) glUniform2iv;
GLvoid function(GLint, GLsizei, GLint*) glUniform3iv;
GLvoid function(GLint, GLsizei, GLint*) glUniform4iv;
GLvoid function(GLint, GLsizei, GLboolean, GLfloat*) glUniformMatrix2fv;
GLvoid function(GLint, GLsizei, GLboolean, GLfloat*) glUniformMatrix3fv;
GLvoid function(GLint, GLsizei, GLboolean, GLfloat*) glUniformMatrix4fv;
GLvoid function(GLuint) glValidateProgram;
GLvoid function(GLuint, GLdouble) glVertexAttrib1d;
GLvoid function(GLuint, GLdouble*) glVertexAttrib1dv;
GLvoid function(GLuint, GLfloat) glVertexAttrib1f;
GLvoid function(GLuint, GLfloat*) glVertexAttrib1fv;
GLvoid function(GLuint, GLshort) glVertexAttrib1s;
GLvoid function(GLuint, GLshort*) glVertexAttrib1sv;
GLvoid function(GLuint, GLdouble, GLdouble) glVertexAttrib2d;
GLvoid function(GLuint, GLdouble*) glVertexAttrib2dv;
GLvoid function(GLuint, GLfloat, GLfloat) glVertexAttrib2f;
GLvoid function(GLuint, GLfloat*) glVertexAttrib2fv;
GLvoid function(GLuint, GLshort, GLshort) glVertexAttrib2s;
GLvoid function(GLuint, GLshort*) glVertexAttrib2sv;
GLvoid function(GLuint, GLdouble, GLdouble, GLdouble) glVertexAttrib3d;
GLvoid function(GLuint, GLdouble*) glVertexAttrib3dv;
GLvoid function(GLuint, GLfloat, GLfloat, GLfloat) glVertexAttrib3f;
GLvoid function(GLuint, GLfloat*) glVertexAttrib3fv;
GLvoid function(GLuint, GLshort, GLshort, GLshort) glVertexAttrib3s;
GLvoid function(GLuint, GLshort*) glVertexAttrib3sv;
GLvoid function(GLuint, GLbyte*) glVertexAttrib4Nbv;
GLvoid function(GLuint, GLint*) glVertexAttrib4Niv;
GLvoid function(GLuint, GLshort*) glVertexAttrib4Nsv;
GLvoid function(GLuint, GLubyte, GLubyte, GLubyte, GLubyte) glVertexAttrib4Nub;
GLvoid function(GLuint, GLubyte*) glVertexAttrib4Nubv;
GLvoid function(GLuint, GLuint*) glVertexAttrib4Nuiv;
GLvoid function(GLuint, GLushort*) glVertexAttrib4Nusv;
GLvoid function(GLuint, GLbyte*) glVertexAttrib4bv;
GLvoid function(GLuint, GLdouble, GLdouble, GLdouble, GLdouble) glVertexAttrib4d;
GLvoid function(GLuint, GLdouble*) glVertexAttrib4dv;
GLvoid function(GLuint, GLfloat, GLfloat, GLfloat, GLfloat) glVertexAttrib4f;
GLvoid function(GLuint, GLfloat*) glVertexAttrib4fv;
GLvoid function(GLuint, GLint*) glVertexAttrib4iv;
GLvoid function(GLuint, GLshort, GLshort, GLshort, GLshort) glVertexAttrib4s;
GLvoid function(GLuint, GLshort*) glVertexAttrib4sv;
GLvoid function(GLuint, GLubyte*) glVertexAttrib4ubv;
GLvoid function(GLuint, GLuint*) glVertexAttrib4uiv;
GLvoid function(GLuint, GLushort*) glVertexAttrib4usv;
GLvoid function(GLuint, GLint, GLenum, GLboolean, GLsizei, GLvoid*) glVertexAttribPointer;

void glUsing20() {
	mixin(glBindFuncMix("glBlendEquationSeparate"));
	mixin(glBindFuncMix("glDrawBuffers"));
	mixin(glBindFuncMix("glStencilOpSeparate"));
	mixin(glBindFuncMix("glStencilFuncSeparate"));
	mixin(glBindFuncMix("glStencilMaskSeparate"));
	mixin(glBindFuncMix("glAttachShader"));
	mixin(glBindFuncMix("glBindAttribLocation"));
	mixin(glBindFuncMix("glCompileShader"));
	mixin(glBindFuncMix("glCreateProgram"));
	mixin(glBindFuncMix("glCreateShader"));
	mixin(glBindFuncMix("glDeleteProgram"));
	mixin(glBindFuncMix("glDeleteShader"));
	mixin(glBindFuncMix("glDetachShader"));
	mixin(glBindFuncMix("glDisableVertexAttribArray"));
	mixin(glBindFuncMix("glEnableVertexAttribArray"));
	mixin(glBindFuncMix("glGetActiveAttrib"));
	mixin(glBindFuncMix("glGetActiveUniform"));
	mixin(glBindFuncMix("glGetAttachedShaders"));
	mixin(glBindFuncMix("glGetAttribLocation"));
	mixin(glBindFuncMix("glGetProgramiv"));
	mixin(glBindFuncMix("glGetProgramInfoLog"));
	mixin(glBindFuncMix("glGetShaderiv"));
	mixin(glBindFuncMix("glGetShaderInfoLog"));
	mixin(glBindFuncMix("glGetShaderSource"));
	mixin(glBindFuncMix("glGetUniformLocation"));
	mixin(glBindFuncMix("glGetUniformfv"));
	mixin(glBindFuncMix("glGetUniformiv"));
	mixin(glBindFuncMix("glGetVertexAttribdv"));
	mixin(glBindFuncMix("glGetVertexAttribfv"));
	mixin(glBindFuncMix("glGetVertexAttribiv"));
	mixin(glBindFuncMix("glGetVertexAttribPointerv"));
	mixin(glBindFuncMix("glIsProgram"));
	mixin(glBindFuncMix("glIsShader"));
	mixin(glBindFuncMix("glLinkProgram"));
	mixin(glBindFuncMix("glShaderSource"));
	mixin(glBindFuncMix("glUseProgram"));
	mixin(glBindFuncMix("glUniform1f"));
	mixin(glBindFuncMix("glUniform2f"));
	mixin(glBindFuncMix("glUniform3f"));
	mixin(glBindFuncMix("glUniform4f"));
	mixin(glBindFuncMix("glUniform1i"));
	mixin(glBindFuncMix("glUniform2i"));
	mixin(glBindFuncMix("glUniform3i"));
	mixin(glBindFuncMix("glUniform4i"));
	mixin(glBindFuncMix("glUniform1fv"));
	mixin(glBindFuncMix("glUniform2fv"));
	mixin(glBindFuncMix("glUniform3fv"));
	mixin(glBindFuncMix("glUniform4fv"));
	mixin(glBindFuncMix("glUniform1iv"));
	mixin(glBindFuncMix("glUniform2iv"));
	mixin(glBindFuncMix("glUniform3iv"));
	mixin(glBindFuncMix("glUniform4iv"));
	mixin(glBindFuncMix("glUniformMatrix2fv"));
	mixin(glBindFuncMix("glUniformMatrix3fv"));
	mixin(glBindFuncMix("glUniformMatrix4fv"));
	mixin(glBindFuncMix("glValidateProgram"));
	mixin(glBindFuncMix("glVertexAttrib1d"));
	mixin(glBindFuncMix("glVertexAttrib1dv"));
	mixin(glBindFuncMix("glVertexAttrib1f"));
	mixin(glBindFuncMix("glVertexAttrib1fv"));
	mixin(glBindFuncMix("glVertexAttrib1s"));
	mixin(glBindFuncMix("glVertexAttrib1sv"));
	mixin(glBindFuncMix("glVertexAttrib2d"));
	mixin(glBindFuncMix("glVertexAttrib2dv"));
	mixin(glBindFuncMix("glVertexAttrib2f"));
	mixin(glBindFuncMix("glVertexAttrib2fv"));
	mixin(glBindFuncMix("glVertexAttrib2s"));
	mixin(glBindFuncMix("glVertexAttrib2sv"));
	mixin(glBindFuncMix("glVertexAttrib3d"));
	mixin(glBindFuncMix("glVertexAttrib3dv"));
	mixin(glBindFuncMix("glVertexAttrib3f"));
	mixin(glBindFuncMix("glVertexAttrib3fv"));
	mixin(glBindFuncMix("glVertexAttrib3s"));
	mixin(glBindFuncMix("glVertexAttrib3sv"));
	mixin(glBindFuncMix("glVertexAttrib4Nbv"));
	mixin(glBindFuncMix("glVertexAttrib4Niv"));
	mixin(glBindFuncMix("glVertexAttrib4Nsv"));
	mixin(glBindFuncMix("glVertexAttrib4Nub"));
	mixin(glBindFuncMix("glVertexAttrib4Nubv"));
	mixin(glBindFuncMix("glVertexAttrib4Nuiv"));
	mixin(glBindFuncMix("glVertexAttrib4Nusv"));
	mixin(glBindFuncMix("glVertexAttrib4bv"));
	mixin(glBindFuncMix("glVertexAttrib4d"));
	mixin(glBindFuncMix("glVertexAttrib4dv"));
	mixin(glBindFuncMix("glVertexAttrib4f"));
	mixin(glBindFuncMix("glVertexAttrib4fv"));
	mixin(glBindFuncMix("glVertexAttrib4iv"));
	mixin(glBindFuncMix("glVertexAttrib4s"));
	mixin(glBindFuncMix("glVertexAttrib4sv"));
	mixin(glBindFuncMix("glVertexAttrib4ubv"));
	mixin(glBindFuncMix("glVertexAttrib4uiv"));
	mixin(glBindFuncMix("glVertexAttrib4usv"));
	mixin(glBindFuncMix("glVertexAttribPointer"));
}



///////////////////////////////////////////////////////////////////////////////
// OPENGL 2.1                                                                //
///////////////////////////////////////////////////////////////////////////////

enum : GLenum {
    GL_CURRENT_RASTER_SECONDARY_COLOR = 0x845F,
    GL_PIXEL_PACK_BUFFER              = 0x88EB,
    GL_PIXEL_UNPACK_BUFFER            = 0x88EC,
    GL_PIXEL_PACK_BUFFER_BINDING      = 0x88ED,
    GL_PIXEL_UNPACK_BUFFER_BINDING    = 0x88EF,
    GL_FLOAT_MAT2x3                   = 0x8B65,
    GL_FLOAT_MAT2x4                   = 0x8B66,
    GL_FLOAT_MAT3x2                   = 0x8B67,
    GL_FLOAT_MAT3x4                   = 0x8B68,
    GL_FLOAT_MAT4x2                   = 0x8B69,
    GL_FLOAT_MAT4x3                   = 0x8B6A,
    GL_SRGB                           = 0x8C40,
    GL_SRGB8                          = 0x8C41,
    GL_SRGB_ALPHA                     = 0x8C42,
    GL_SRGB8_ALPHA8                   = 0x8C43,
    GL_SLUMINANCE_ALPHA               = 0x8C44,
    GL_SLUMINANCE8_ALPHA8             = 0x8C45,
    GL_SLUMINANCE                     = 0x8C46,
    GL_SLUMINANCE8                    = 0x8C47,
    GL_COMPRESSED_SRGB                = 0x8C48,
    GL_COMPRESSED_SRGB_ALPHA          = 0x8C49,
    GL_COMPRESSED_SLUMINANCE          = 0x8C4A,
    GL_COMPRESSED_SLUMINANCE_ALPHA    = 0x8C4B,
}

void function(GLint, GLsizei, GLboolean, GLfloat*) glUniformMatrix2x3fv;
void function(GLint, GLsizei, GLboolean, GLfloat*) glUniformMatrix3x2fv;
void function(GLint, GLsizei, GLboolean, GLfloat*) glUniformMatrix2x4fv;
void function(GLint, GLsizei, GLboolean, GLfloat*) glUniformMatrix4x2fv;
void function(GLint, GLsizei, GLboolean, GLfloat*) glUniformMatrix3x4fv;
void function(GLint, GLsizei, GLboolean, GLfloat*) glUniformMatrix4x3fv;

void glUsing21() {
	mixin(glBindFuncMix("glUniformMatrix2x3fv"));
	mixin(glBindFuncMix("glUniformMatrix3x2fv"));
	mixin(glBindFuncMix("glUniformMatrix2x4fv"));
	mixin(glBindFuncMix("glUniformMatrix4x2fv"));
	mixin(glBindFuncMix("glUniformMatrix3x4fv"));
	mixin(glBindFuncMix("glUniformMatrix4x3fv"));
}

void glUsing30() {
}

void glUsing31() {
}

void glUsing32() {
}

void glUsing33() {
}

void glUsing40() {
}

///////////////////////////////////////////////////////////////////////////////
// SHADERS WRAPPER                                                           //
///////////////////////////////////////////////////////////////////////////////

class glShaderException : Exception { this(string s) { super(s); } }

class glShader {
	GLuint id;
	char[] error;
	
    // GL_FRAGMENT_SHADER, GL_VERTEX_SHADER
	this(GLenum type) {
		if (glCreateShader is null) throw(new glShaderException("glCreateShader undefined"));
		id = glCreateShader(type);
	}

	this(GLenum type, string program) {
		this(type);
		set(program);
	}
	
	void set(string program) {
		int strl = program.length;
		char* str = program.dup.ptr;
		glShaderSource(id, 1, &str, &strl);
		compile();
	}
	
	void set(Stream s) {
		auto buffer = new ubyte[cast(uint)s.size];
		s.read(buffer);
		set(cast(string)buffer);
	}
	
	void compile() {
		GLint r;
		glCompileShader(id);
		glGetShaderiv(id, GL_COMPILE_STATUS, &r);
		if (!r) {
			glGetShaderiv(id, GL_INFO_LOG_LENGTH, &r);
			error.length = r;
			glGetShaderInfoLog(id, error.length, &r, error.ptr);
			error.length = r;
			throw(new glShaderException(cast(string)error));
		}
	}
}

class glFragmentShader : glShader {
	this() { super(GL_FRAGMENT_SHADER); }
	this(string program) { super(GL_FRAGMENT_SHADER, program); }
}

class glVertexShader : glShader {
	this() { super(GL_VERTEX_SHADER); }
	this(string program) { super(GL_VERTEX_SHADER, program); }
}

class glProgram {
	GLuint id;
	char[] error;
	
	this() {
		if (glCreateProgram is null) throw(new glShaderException("glCreateProgram undefined"));
		id = glCreateProgram();
	}
	
	void attach(glShader shader) {
		glAttachShader(id, shader.id);
	}
	
	void link() {
		GLint r;
		glLinkProgram(id);
		glGetShaderiv(id, GL_INFO_LOG_LENGTH, &r);
		if (r) {
			glGetShaderiv(id, GL_INFO_LOG_LENGTH, &r);
			error.length = r;
			glGetShaderInfoLog(id, error.length, &r,  error.ptr);
			error.length = r;
			throw(new glShaderException(cast(string)error));
		}		
	}
	
	void use() {
		glUseProgram(id);
	}
	
	glAttrib getAttrib(string name, bool except = false) {
		GLuint aid = glGetAttribLocation(id, toStringz(name));
		if (except && aid == -1) throw(new Exception(std.string.format("Attribute '%s' isn't active", name)));
		return new glAttrib(id, aid);
	}
	
	glUniform getUniform(string name, bool except = false) {
		GLuint aid = glGetUniformLocation(id, toStringz(name));
		if (except && aid == -1) throw(new Exception(std.string.format("Attribute '%s' isn't active", name)));
		return new glUniform(id, aid);
	}
}

class glAttrib {
	GLuint pid;
	GLuint id;
	
	public this(GLuint pid, GLuint id) {
		this.pid = pid;
		this.id = id;
	}
	
	void set(GLshort v0) { glVertexAttrib1s(id, v0); }
	void set1f(GLfloat v0) { glVertexAttrib1f(id, v0); }
	void set3f(GLfloat v0, GLfloat v1, GLfloat v2) { glVertexAttrib3f(id, v0, v1, v2); }
	void set4f(GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3) { glVertexAttrib4f(id, v0, v1, v2, v3); }
}

class glUniform {
	GLuint pid;
	GLuint id;
	
	public this(GLuint pid, GLuint id) {
		this.pid = pid;
		this.id = id;
	}

	void set(GLint v0) { glUniform1i(id, v0); }
	
	void set(GLint v0, GLint v1) { glUniform2i(id, v0, v1); }
	void set(GLint v0, GLint v1, GLint v2) { glUniform3i(id, v0, v1, v2); }
	void set(GLint v0, GLint v1, GLint v2, GLint v3) { glUniform4i(id, v0, v1, v2, v3); }
	
	void set(GLfloat v0, GLfloat v1, GLfloat v2) { glUniform3f(id, v0, v1, v2); }
	void set(GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3) { glUniform4f(id, v0, v1, v2, v3); }
	
	void setMatrix4(GLfloat* v, bool transpose = false) { glUniformMatrix4fv(id, 1, transpose, v); }
	
	void get(out GLint[] v) {
		glGetUniformiv(pid, id, v.ptr);
	}
}

///////////////////////////////////////////////////////////////////////////////
// EXTENSIONS                                                                //
///////////////////////////////////////////////////////////////////////////////

static const int GL_COMPRESSED_RGB_S3TC_DXT1_EXT  = 0x83F0;
static const int GL_COMPRESSED_RGBA_S3TC_DXT1_EXT = 0x83F1;
static const int GL_COMPRESSED_RGBA_S3TC_DXT3_EXT = 0x83F2;
static const int GL_COMPRESSED_RGBA_S3TC_DXT5_EXT = 0x83F3;

void glCheckError() {
	void throwError(string s) { throw(new Exception(s)); }
	switch (glGetError()) {
		case GL_NO_ERROR:          return;
		case GL_INVALID_ENUM:      throwError("Invalid enum");
		case GL_INVALID_VALUE:     throwError("Invalid value");
		case GL_INVALID_OPERATION: throwError("Invalid operation");
		case GL_STACK_OVERFLOW:    throwError("Stack Overflow");
		case GL_STACK_UNDERFLOW:   throwError("Stack Underflow");
		case GL_OUT_OF_MEMORY:     throwError("Out of memory");
		default:                   throwError("Unknown error");
	}
}

static this() {
	glInitSystem();
}