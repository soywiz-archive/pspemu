module pspemu.core.gpu.Types;

import std.string;
import std.bitmanip;

import pspemu.utils.Utils;
import pspemu.utils.Math;

import pspemu.core.Memory;

// http://hitmen.c02.at/files/yapspd/psp_doc/chap27.html#sec27

static const auto PixelFormatSizeMul = [2, 2, 2, 4, 1, 1, 2, 4, 4, 4, 4];
static const auto PixelFormatSizeDiv = [1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1];

/*
enum PixelFormats {
	// Display, Texture, Palette
	GU_PSM_5650 = 0, GU_PSM_5551 = 1, GU_PSM_4444 = 2, GU_PSM_8888 = 3,
	// Texture Only
	GU_PSM_T4 = 4, GU_PSM_T8 = 5, GU_PSM_T16 = 6, GU_PSM_T32 = 7, GU_PSM_DXT1 = 8, GU_PSM_DXT3 = 9, GU_PSM_DXT5 = 10
}
*/

uint PixelFormatSize(PixelFormats format, uint count = 1) {
	return (count * PixelFormatSizeMul[format]) / PixelFormatSizeDiv[format];
}

uint PixelFormatUnpackSize(PixelFormats format, uint count) {
	return count * 4 * PixelFormatSizeDiv[format] / PixelFormatSizeMul[format];
}

struct Colorf {
	union {
		struct { float[4] rgba = [0.0, 0.0, 0.0, 1.0]; }
		struct { float[3] rgb; }
		struct { float r, g, b, a; }
		struct { float red, green, blue, alpha; }
	}
	float* ptr() { return rgba.ptr; }
	alias ptr pointer;
	static assert(this.sizeof == float.sizeof * 4);
}

//void main() {}

struct VertexType {
	static const uint[] typeSize = [0, byte.sizeof, short.sizeof, float.sizeof];
	static const uint[] colorSize = [0, 1, 1, 1, 2, 2, 2, 4];

	union {
		uint v;
		struct {
			mixin(bitfields!(
				uint, "texture",  2,
				uint, "color",    3,
				uint, "normal",   2,
				uint, "position", 2,
				uint, "weight",   2,
				uint, "index",    2,
				uint, "__0",      1,
				uint, "skinningWeightCount", 3,
				uint, "__1",      1,
				uint, "morphingVertexCount",   2,
				uint, "__2",      3,
				uint, "transform2D",           1,
				uint, "__3",      8
			));
		}
	}

	uint vertexSize() {
		uint size = 0;
		size += skinningWeightCount * typeSize[weight];
		size += 1 * colorSize[color];
		size += 2 * typeSize[texture ];
		size += 3 * typeSize[position];
		size += 3 * typeSize[normal  ];
		return size;
	}
}

struct UV {
	float u, v;
	Vector uv() { return Vector(u, v); }
}

struct Rect {
	uint x1, y1, x2, y2;
	bool isFull() {
		return (x1 <= 0 && y1 <= 0) && (x2 >= 480 && y2 >= 272);
	}
}

const auto GU_PI = 3.141593f;

enum Boolean { GU_FALSE = 0, GU_TRUE = 1 }

enum PrimitiveType { GU_POINTS = 0, GU_LINES = 1, GU_LINE_STRIP = 2, GU_TRIANGLES = 3, GU_TRIANGLE_STRIP = 4, GU_TRIANGLE_FAN = 5, GU_SPRITES = 6 }

// glEnable/glDisable
enum Stats {
	GU_ALPHA_TEST = 0,
	GU_DEPTH_TEST = 1,
	GU_SCISSOR_TEST = 2,
	GU_STENCIL_TEST = 3,
	GU_BLEND = 4,
	GU_CULL_FACE = 5,
	GU_DITHER = 6,
	GU_FOG = 7,
	GU_CLIP_PLANES = 8,
	GU_TEXTURE_2D = 9,
	GU_LIGHTING = 10,
	GU_LIGHT0 = 11,
	GU_LIGHT1 = 12,
	GU_LIGHT2 = 13,
	GU_LIGHT3 = 14,
	GU_LINE_SMOOTH = 15,
	GU_PATCH_CULL_FACE = 16,
	GU_COLOR_TEST = 17,
	GU_COLOR_LOGIC_OP = 18,
	GU_FACE_NORMAL_REVERSE = 19,
	GU_PATCH_FACE = 20,
	GU_FRAGMENT_2X = 21,
}

enum MatrixModes { GU_PROJECTION = 0, GU_VIEW = 1, GU_MODEL = 2, GU_TEXTURE = 3 }

enum PixelFormats {
	// Display, Texture, Palette
	GU_PSM_5650 = 0, GU_PSM_5551 = 1, GU_PSM_4444 = 2, GU_PSM_8888 = 3,
	// Texture Only
	GU_PSM_T4 = 4, GU_PSM_T8 = 5, GU_PSM_T16 = 6, GU_PSM_T32 = 7, GU_PSM_DXT1 = 8, GU_PSM_DXT3 = 9, GU_PSM_DXT5 = 10
}
enum SplineMode { GU_FILL_FILL = 0, GU_OPEN_FILL = 1, GU_FILL_OPEN = 2, GU_OPEN_OPEN = 3 }
enum ShadingModel { GU_FLAT = 0, GU_SMOOTH = 1 } 
enum LogicalOperation {
	GU_CLEAR = 0, GU_AND = 1, GU_AND_REVERSE = 2, GU_COPY = 3, GU_AND_INVERTED = 4, GU_NOOP = 5, GU_XOR = 6, GU_OR = 7, GU_NOR = 8,
	GU_EQUIV = 9, GU_INVERTED = 10, GU_OR_REVERSE = 11, GU_COPY_INVERTED = 12, GU_OR_INVERTED = 13, GU_NAND = 14, GU_SET = 15
}
enum TextureFilter { GU_NEAREST = 0, GU_LINEAR = 1, GU_NEAREST_MIPMAP_NEAREST = 4, GU_LINEAR_MIPMAP_NEAREST = 5, GU_NEAREST_MIPMAP_LINEAR = 6, GU_LINEAR_MIPMAP_LINEAR = 7 }
enum TextureMapMode { GU_TEXTURE_COORDS = 0, GU_TEXTURE_MATRIX = 1, GU_ENVIRONMENT_MAP = 2 }
enum TextureLevelMode { GU_TEXTURE_AUTO = 0, GU_TEXTURE_CONST = 1, GU_TEXTURE_SLOPE = 2 }
enum TextureProjectionMapMode { GU_POSITION = 0, GU_UV = 1, GU_NORMALIZED_NORMAL = 2, GU_NORMAL = 3 }
enum WrapMode { GU_REPEAT = 0, GU_CLAMP = 1 }
enum FrontFaceDirection { GU_CCW = 0, GU_CW = 1 }
enum TestFunction { GU_NEVER = 0, GU_ALWAYS = 1, GU_EQUAL = 2, GU_NOTEQUAL = 3, GU_LESS = 4, GU_LEQUAL = 5, GU_GREATER = 6, GU_GEQUAL = 7 }
enum ClearBufferMask { GU_COLOR_BUFFER_BIT = 1, GU_STENCIL_BUFFER_BIT = 2, GU_DEPTH_BUFFER_BIT = 4, GU_FAST_CLEAR_BIT = 16 }
enum TextureEffect { GU_TFX_MODULATE = 0, GU_TFX_DECAL = 1, GU_TFX_BLEND = 2, GU_TFX_REPLACE = 3, GU_TFX_ADD = 4 }
enum TextureColorComponent { GU_TCC_RGB = 0, GU_TCC_RGBA = 1 }
enum BlendingOp { GU_ADD = 0, GU_SUBTRACT = 1, GU_REVERSE_SUBTRACT = 2, GU_MIN = 3, GU_MAX = 4, GU_ABS = 5 }
enum BlendingFactor {
	// Source
	GU_SRC_COLOR = 0, GU_ONE_MINUS_SRC_COLOR = 1, GU_SRC_ALPHA = 2, GU_ONE_MINUS_SRC_ALPHA = 3,
	// Dest
	GU_DST_COLOR = 0, GU_ONE_MINUS_DST_COLOR = 1, GU_DST_ALPHA = 4, GU_ONE_MINUS_DST_ALPHA = 5,
	// Both?
	GU_FIX = 10
}
enum StencilOperations { GU_KEEP = 0, GU_ZERO = 1, GU_REPLACE = 2, GU_INVERT = 3, GU_INCR = 4, GU_DECR = 5 }
enum LightComponents { GU_AMBIENT = 1, GU_DIFFUSE = 2, GU_SPECULAR = 4, GU_AMBIENT_AND_DIFFUSE = GU_AMBIENT | GU_DIFFUSE, GU_DIFFUSE_AND_SPECULAR = GU_DIFFUSE | GU_SPECULAR, GU_UNKNOWN_LIGHT_COMPONENT = 8 }
enum LightModel { GU_SINGLE_COLOR = 0, GU_SEPARATE_SPECULAR_COLOR = 1 }
enum LightType { GU_DIRECTIONAL = 0, GU_POINTLIGHT = 1, GU_SPOTLIGHT = 2 }
enum Contexts { GU_DIRECT = 0, GU_CALL = 1, GU_SEND = 2 }
enum ListQueue { GU_TAIL = 0, GU_HEAD = 1 }
enum SyncBehaviorMode { GU_SYNC_FINISH = 0, GU_SYNC_SIGNAL = 1, GU_SYNC_DONE = 2, GU_SYNC_LIST = 3, GU_SYNC_SEND = 4 }
enum BehaviorSyncWait { GU_SYNC_WAIT = 0, GU_SYNC_NOWAIT = 1 }
enum BehaviorSyncWhat { GU_SYNC_WHAT_DONE = 0, GU_SYNC_WHAT_QUEUED = 1, GU_SYNC_WHAT_DRAW = 2, GU_SYNC_WHAT_STALL = 3, GU_SYNC_WHAT_CANCEL = 4 }
enum Signals { GU_CALLBACK_SIGNAL = 1, GU_CALLBACK_FINISH = 4 }
enum SignalBehavior { GU_BEHAVIOR_SUSPEND = 1, GU_BEHAVIOR_CONTINUE = 2 }

uint GU_ABGR(ubyte a, ubyte b, ubyte g, ubyte r) { return (a << 24) | (b << 16) | (g << 8) | r; } // Will be inlined.
uint GU_ARGB(ubyte a, ubyte r, ubyte g, ubyte b) { return GU_ABGR(a, b, g, r); }
uint GU_RGBA(ubyte r, ubyte g, ubyte b, ubyte a) { return GU_ABGR(a, b, g, r); }

/+
/* Vertex Declarations Begin */
#define GU_TEXTURE_SHIFT(n)	((n)<<0)
#define GU_TEXTURE_8BIT		GU_TEXTURE_SHIFT(1)
#define GU_TEXTURE_16BIT	GU_TEXTURE_SHIFT(2)
#define GU_TEXTURE_32BITF	GU_TEXTURE_SHIFT(3)
#define GU_TEXTURE_BITS		GU_TEXTURE_SHIFT(3)

#define GU_COLOR_SHIFT(n)	((n)<<2)
#define GU_COLOR_5650		GU_COLOR_SHIFT(4)
#define GU_COLOR_5551		GU_COLOR_SHIFT(5)
#define GU_COLOR_4444		GU_COLOR_SHIFT(6)
#define GU_COLOR_8888		GU_COLOR_SHIFT(7)
#define GU_COLOR_BITS		GU_COLOR_SHIFT(7)

#define GU_NORMAL_SHIFT(n)	((n)<<5)
#define GU_NORMAL_8BIT		GU_NORMAL_SHIFT(1)
#define GU_NORMAL_16BIT		GU_NORMAL_SHIFT(2)
#define GU_NORMAL_32BITF	GU_NORMAL_SHIFT(3)
#define GU_NORMAL_BITS		GU_NORMAL_SHIFT(3)

#define GU_VERTEX_SHIFT(n)	((n)<<7)
#define GU_VERTEX_8BIT		GU_VERTEX_SHIFT(1)
#define GU_VERTEX_16BIT		GU_VERTEX_SHIFT(2)
#define GU_VERTEX_32BITF	GU_VERTEX_SHIFT(3)
#define GU_VERTEX_BITS		GU_VERTEX_SHIFT(3)

#define GU_WEIGHT_SHIFT(n)	((n)<<9)
#define GU_WEIGHT_8BIT		GU_WEIGHT_SHIFT(1)
#define GU_WEIGHT_16BIT		GU_WEIGHT_SHIFT(2)
#define GU_WEIGHT_32BITF	GU_WEIGHT_SHIFT(3)
#define GU_WEIGHT_BITS		GU_WEIGHT_SHIFT(3)

#define GU_INDEX_SHIFT(n)	((n)<<11)
#define GU_INDEX_8BIT		GU_INDEX_SHIFT(1)
#define GU_INDEX_16BIT		GU_INDEX_SHIFT(2)
#define GU_INDEX_BITS		GU_INDEX_SHIFT(3)

#define GU_WEIGHTS(n)		((((n)-1)&7)<<14)
#define GU_WEIGHTS_BITS		GU_WEIGHTS(8)
#define GU_VERTICES(n)		((((n)-1)&7)<<18)
#define GU_VERTICES_BITS	GU_VERTICES(8)

#define GU_TRANSFORM_SHIFT(n)	((n)<<23)
#define GU_TRANSFORM_3D		GU_TRANSFORM_SHIFT(0)
#define GU_TRANSFORM_2D		GU_TRANSFORM_SHIFT(1)
#define GU_TRANSFORM_BITS	GU_TRANSFORM_SHIFT(1)
/* Vertex Declarations End */
+/

/* Color Macro, maps floating point channels (0..1) into one 32-bit value */
//#define GU_COLOR(r,g,b,a)	GU_RGBA((u32)((r) * 255.0f),(u32)((g) * 255.0f),(u32)((b) * 255.0f),(u32)((a) * 255.0f))
