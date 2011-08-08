module pspemu.core.gpu.GpuState;

import std.conv;

import pspemu.core.gpu.Types;

import pspemu.core.Memory;
import pspemu.utils.MathUtils;
import pspemu.utils.StructUtils;
import pspemu.utils.String;
import core.bitop;
//import pspemu.utils.Utils;

import pspemu.hle.kd.ge.Types;

import std.bitmanip;

/*
enum TextureMapMode {
	GU_TEXTURE_COORDS  = 0,
	GU_TEXTURE_MATRIX  = 1,
	GU_ENVIRONMENT_MAP = 2,
}

enum TextureProjectionMapMode {
	GU_POSITION          = 0,
	GU_UV                = 1,
	GU_NORMALIZED_NORMAL = 2,
	GU_NORMAL            = 3,
}
*/

/* Texture Projection Map Mode */

enum TransformMode {
	Normal = 0,
	Raw    = 1,
}

struct ClutState {
	uint address;
	PixelFormats format;
	uint shift;
	uint mask;
	uint start;
	//ubyte[] data;
	ubyte* data;

	int colorEntrySize() { return PixelFormatSize(format, 1); }
	int blocksSize(int num_blocks) {
		return PixelFormatSize(format, num_blocks * 8);
	}
	
	int getIndex(int index) {
		return ((start + index) >> shift) & mask;
	}
	
	ubyte[] getRealClutData() {
		int from = getIndex(0) * colorEntrySize;
		int to   = getIndex(bsr(mask) - 1) * colorEntrySize;
		return data[from..to];
	}
	
	string hash() {
		return cast(string)(cast(ubyte*)cast(void*)&this)[0..data.offsetof];
		//return toString;
	}
	string toString() {
		return std.string.format("ClutState(addr=%08X, format=%d, shift=%d, mask=%d, start=%d)", address, format, shift, mask, start);
	}
}

struct ScreenBuffer {
	union {
		uint _address;
		struct { mixin(bitfields!(
			uint, "lowAddress" , 24,
			uint, "highAddress", 8
		)); }
	}
	uint width = 512;
	PixelFormats format = PixelFormats.GU_PSM_8888;
	uint loadAddress, storeAddress;
	uint address(uint _address) { return this._address = _address; }
	uint address() { return (0x04_000000 | this._address); }
	uint addressEnd() { return address + width * 272 * pixelSize; }
	uint pixelSize() { return PixelFormatSizeMul[format]; }
	ubyte[] row(void* ptr, int row) {
		int rowsize = PixelFormatSize(format, width);
		return ((cast(ubyte *)ptr) + rowsize * row)[0..rowsize];
	}
	bool isAnyAddressInBuffer(uint[] ptrList) {
		foreach (ptr; ptrList) {
			if ((ptr >= address) && (ptr < addressEnd)) return true;
		}
		return false;
	}
}

struct TextureTransfer {
	enum TexelSize { BIT_16 = 0, BIT_32 = 1 }
	//enum TexelSize { BIT_32 = 0, BIT_16 = 1 }
	
	uint srcAddress, dstAddress;
	ushort srcLineWidth, dstLineWidth;
	ushort srcX, srcY, dstX, dstY;
	ushort width, height;
	TexelSize texelSize;
	
	uint bpp() { return (texelSize == TexelSize.BIT_16) ? 2 : 4; }
	
	string toString() {
		return std.string.format(
			"TextureTransfer("
			"Size(%d, %d) : "
			"SRC(addr=%08X, w=%d, XY(%d, %d))"
			"-"
			"DST(addr=%08X, w=%d, XY(%d, %d))"
			") : Bpp:%s",
			width, height,
			srcAddress, srcLineWidth, srcX, srcY,
			dstAddress, dstLineWidth, dstX, dstY,
			bpp
		);
	}
}

struct LightState {
	struct Attenuation {
		float constant, linear, quadratic;
		
		string toString() {
			return std.string.format(
				"Attenuation(constant=%f, linear=%f, quadratic=%f)",
				constant, linear, quadratic
			);
		}
	}
	bool enabled = false;
	LightType type;
	LightModel kind;
	Vector position, spotDirection;
	Attenuation attenuation;
	float spotExponent;
	float spotCutoff;
	Colorf ambientColor, diffuseColor, specularColor;
	
	string toString() {
		string ret;
		
		ret ~= std.string.format("LightState(enabled = %s", enabled);
		if (enabled) {
			ret ~= std.string.format("\n    type         =%s", to!string(type));
			ret ~= std.string.format("\n    kind         =%s", to!string(kind));
			ret ~= std.string.format("\n    position     =%s", position);
			ret ~= std.string.format("\n    spotDirection=%s", spotDirection);
			ret ~= std.string.format("\n    attenuation  =%s", attenuation);
			ret ~= std.string.format("\n    spotExponent =%f", spotExponent);
			ret ~= std.string.format("\n    spotCutoff   =%f", spotCutoff);
			ret ~= std.string.format("\n    ambientColor =%f", ambientColor);
			ret ~= std.string.format("\n    diffuseColor =%f", diffuseColor);
			ret ~= std.string.format("\n    specularColor=%f", specularColor);
		}
		ret ~= ")";
		return ret;
	}
}

static struct VertexState {
	float u  = 0.0, v  = 0.0;        // Texture coordinates.
	float r  = 0.0, g  = 0.0, b  = 0.0, a  = 0.0;  // Color components.
	float nx = 0.0, ny = 0.0, nz = 0.0;  // Normal vector.
	float px = 0.0, py = 0.0, pz = 0.0;  // Position vector.
	float weights[8] = [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];  // Weights for skinning
	
	float[] floatValues() {
		return (&u)[0..20];
	} 

	// Getters
	Vector p () { return Vector(px, py, pz); }
	Vector n () { return Vector(nx, ny, nz); }
	Vector uv() { return Vector(u, v); }

	// Setters
	Vector p (Vector vec) { px = vec.x; py = vec.y; pz = vec.z; return vec; }
	Vector n (Vector vec) { nx = vec.x; ny = vec.y; nz = vec.z; return vec; }
	Vector uv(Vector vec) { u  = vec.x; v  = vec.y; return vec; }

	// Aliases
	alias p position;
	alias n normal;

	string toString(VertexType vertexType) {
		return toString(vertexType.getPrimitiveFlags);
	}
	
	string toString(PrimitiveFlags flags) {
		return toString(PrimitiveType.GU_POINTS, flags);
	}

	string toString(PrimitiveType type, PrimitiveFlags flags) {
		string ret;
		ret ~= "VertexState";
		if (flags.hasTexture ) ret ~= std.string.format("(UV=%f,%f)", u, v);
		if (flags.hasColor   ) ret ~= std.string.format("(RGBA:%02X%02X%02X%02X)", cast(uint)(r * 255), cast(uint)(g * 255), cast(uint)(b * 255), cast(uint)(a * 255));
		if (flags.hasNormal  ) ret ~= std.string.format("(NXYZ=%f,%f,%f)", nx, ny, nz);
		if (flags.hasPosition) ret ~= std.string.format("(PXYZ=%f,%f,%f)", px, py, pz);
		
		return ret;
		/*
		return std.string.format(
			"VertexState(UV=%f,%f)(RGBA:%02X%02X%02X%02X)(NXYZ=%f,%f,%f)(PXYZ=%f,%f,%f)",
			u, v,
			cast(uint)(r * 255), cast(uint)(g * 255), cast(uint)(b * 255), cast(uint)(a * 255),
			nx, ny, nz,
			px, py, pz
		);
		*/
	}
	
	string toString() {
		return toString(PrimitiveType.GU_POINTS, PrimitiveFlags.all);
	}
}

struct Viewport {
	float px, py, pz;
	float sx, sy, sz;
	
	string toString() {
		return std.string.format("Viewport(%f, %f, %f)(%f, %f, %f)", px, py, pz, sx, sy, sz);
	}
}

struct TextureState {
	bool enabled;   // Texture Mapping Enable (GL_TEXTURE_2D)
	
	// Format of the texture data.
	bool           swizzled;              /// Is texture swizzled?
	PixelFormats   format;                /// Texture Data mode

	// Normal attributes
	TextureFilter  filterMin, filterMag;  /// TextureFilter when drawing the texture scaled
	WrapMode       wrapU, wrapV;          /// Wrap mode when specifying texture coordinates beyond texture size
	UV             scale;                 /// 
	UV             offset;                ///
	TextureMapMode mapMode;
	TextureProjectionMapMode projMapMode; 
	uint[2]        texShade;
	Matrix         matrix;

	// Effects
	TextureEffect  effect;                /// 
	TextureColorComponent colorComponent; ///
	bool           fragment_2x;           /// ???

	TextureLevelMode levelMode;

	// Mimaps
	struct MipmapState {
		uint address;                     /// Pointer 
		uint buffer_width;                ///
		uint width, height;               ///
	}
	int            mipmapMaxLevel;        /// Levels of mipmaps
	bool           mipmapShareClut;       /// Mipmaps share clut?
	MipmapState[8] mipmaps;               /// MipmapState list
	float          mipmapBias;

	int mipmapRealWidth(int mipmap = 0) { return PixelFormatSize(format, mipmaps[mipmap].buffer_width); }
	int mipmapTotalSize(int mipmap = 0) { return mipmapRealWidth(mipmap) * mipmaps[mipmap].height; }

	string hash() { return cast(string)TA(this); }
	//string toString() { return std.string.format("TextureState(addr=%08X, size(%dx%d), bwidth=%d, format=%d, swizzled=%d)", address, width, height, buffer_width, format, swizzled); }

	int address() { return mipmaps[0].address; }
	int buffer_width() { return mipmaps[0].buffer_width; }
	int width() { return mipmaps[0].width; }
	int height() { return mipmaps[0].height; }
	bool hasPalette() { return (format >= PixelFormats.GU_PSM_T4 && format <= PixelFormats.GU_PSM_T32); }
	uint paletteRequiredComponents() { return hasPalette ? (1 << (4 + (format - PixelFormats.GU_PSM_T4))) : 0; }
	
	string toString() {
		string ret;
		ret ~= std.string.format("TextureState(enabled:%s\n", enabled);
		if (enabled) {
			ret ~= std.string.format("        , swizzled: %s\n", swizzled);
			ret ~= std.string.format("        , format: %s\n", to!string(format));
			ret ~= std.string.format("        , filterMinMag: %s,%s\n", to!string(filterMin), to!string(filterMag));
			ret ~= std.string.format("        , wrapUV: %s,%s\n", to!string(wrapU), to!string(wrapV));
			ret ~= std.string.format("        , scale: %s\n", scale);
			ret ~= std.string.format("        , offset: %s\n", offset);
			ret ~= std.string.format("        , mapMode: %s\n", to!string(mapMode));
			ret ~= std.string.format("        , projMapMode: %s\n", to!string(projMapMode));
			ret ~= std.string.format("        , texShade: %d,%d\n", texShade[0], texShade[1]);
			ret ~= std.string.format("        , effect: %s\n", to!string(effect));
			ret ~= std.string.format("        , colorComponent: %s\n", to!string(colorComponent));
			ret ~= std.string.format("        , fragment_2x: %s\n", to!string(fragment_2x));
			ret ~= std.string.format("        , mipmapMaxLevel: %d\n", mipmapMaxLevel);
			ret ~= std.string.format("        , mipmapShareClut: %s\n", to!string(mipmapShareClut));
			ret ~= std.string.format("        , mipmaps: ...\n");
		}
		ret ~= "    )";
		return ret;
	}
}

struct Patch {
	ubyte div_s;
	ubyte div_t;
	PatchPrimitiveType type;
}

struct FogState {
	bool enabled;
	Colorf color;
	float  dist, end;
	float  density; // 0.1
	int    mode;
	int    hint;
	
	string toString() {
		if (!enabled) return "FogState(enabled:false)";
		return std.string.format("FogState(enabled:%s, color:%s, dist:%f, end:%f, density:%f, mode:%d, hint:%d)", enabled, color, dist, end, density, mode, hint);
	}
}

struct DepthState {
	bool testEnabled;        // depth (Z) Test Enable (GL_DEPTH_TEST)
	TestFunction testFunc; // TestFunction.GU_ALWAYS
	float rangeNear, rangeFar; // 0.0 - 1.0
	ushort mask;
	
	string toString() {
		return std.string.format(
			"DepthState(testEnabled:%s, testFunc=%s, range(%f-%f), mask=%04X"
			, testEnabled
			, to!string(testFunc)
			, rangeNear, rangeFar
			, mask
		);
	}
}

struct BlendState {
	// Blending.
	bool enabled;       // Alpha Blend Enable (GL_BLEND)
	BlendingOp     equation;
	BlendingFactor funcSrc;
	BlendingFactor funcDst;
	Colorf fixColorSrc, fixColorDst;

	string toString() {
		if (!enabled) return std.string.format("BlendState(enabled: %s)", false);

		return std.string.format(
			"BlendState(enabled: %s, equation: %s, funcSrc: %s, funcDst: %s, fixColorSrc: %s, fixColorDst: %s)",
			enabled, to!string(equation), to!string(funcSrc), to!string(funcDst), fixColorSrc, fixColorDst
		);
	}
}

struct AlphaTestState {
	bool enabled;        // Alpha Test Enable (GL_ALPHA_TEST) glAlphaFunc(GL_GREATER, 0.03f);
	TestFunction func; // TestFunction.GU_ALWAYS
	float value;
	ubyte mask; // 0xFF
	
	string toString() {
		if (!enabled) return "AlphaTestState(enabled:false)";
		return std.string.format(
			"AlphaTestState(enabled:%s, func:%s, value:%f, mask:%02X)"
			, enabled
			, to!string(func)
			, value
			, mask
		);
	}
}

struct StencilState {
	bool testEnabled;      // Stencil Test Enable (GL_STENCIL_TEST)
	TestFunction funcFunc;
	ubyte funcRef;
	ubyte funcMask; // 0xFF
	StencilOperations operationSfail;
	StencilOperations operationDpfail;
	StencilOperations operationDppass;
	string toString() {
		if (!testEnabled) return std.string.format("StencilState(enabled: %s)", false);
		return std.string.format(
			"StencilState(enabled: %s, funcFunc:%s, funcRef:%02X, funcMask:%02X, opSfail:%s, opDpfail:%s, opDppass:%s)",
			testEnabled, to!string(funcFunc), funcRef, funcMask, to!string(operationSfail), to!string(operationDpfail), to!string(operationDppass)
		);
	}
}

struct LogicalOperationState {
	bool enabled;
	LogicalOperation operation; // LogicalOperation.GU_COPY
	string toString() {
		if (!enabled) return std.string.format("LogicalOperationState(enabled: %s)", false);
		return std.string.format(
			"LogicalOperationState(enabled: %s, operation:%s)",
			enabled, to!string(operation),
		);
	}
}

struct LightingState {
	bool enabled;         // Lighting Enable (GL_LIGHTING)
	LightModel lightModel;
	Colorf ambientLightColor;
	float  specularPower;
	LightState[4] lights;

	string toString() {
		if (!enabled) return std.string.format("LightingState(enabled: %s)", false);
		return std.string.format(
			"LightingState(\n",
			"    enabled: %s\n"
			"    lightModel: %s\n"
			"    ambientLightColor: %s\n"
			"    specularPower: %f\n"
			"    lights[0]: %s\n"
			"    lights[1]: %s\n"
			"    lights[2]: %s\n"
			"    lights[3]: %s\n"
			")\n"
			, enabled
			, to!string(lightModel)
			, ambientLightColor
			, specularPower
			, lights[0]
			, lights[1]
			, lights[2]
			, lights[3]
		);
	}
}

static struct GpuState {
	Memory memory;
	uint baseAddress, vertexAddress, indexAddress;
	ScreenBuffer drawBuffer, depthBuffer;
	TextureTransfer textureTransfer;
	
	void reset() {
		morphWeights = [1, 0, 0, 0, 0, 0, 0, 0];
	}
	
	union {
		//PspGeContext RealState;
		uint[512] RealState;
		struct {
			VertexType vertexType; // here because of transform2d
			Viewport viewport;
			uint offsetX, offsetY;
			bool toggleUpdateState;

			ClearBufferMask clearFlags;
			bool clearingMode;

			Colorf ambientModelColor, diffuseModelColor, specularModelColor, emissiveModelColor;
			Colorf textureEnviromentColor;
			LightComponents materialColorComponents;
			
			// Matrix.
			Matrix projectionMatrix, worldMatrix, viewMatrix;
			Matrix[8] boneMatrix;
			uint boneMatrixIndex;
			Patch patch;
			
			// Textures.
			// Temporal values.
			TransformMode transformMode;
			
			TextureState texture;
			ClutState uploadedClut;
			ClutState clut;

			Rect scissor;
			FrontFaceDirection frontFaceDirection;
			ShadingModel shadeModel;

			//float[8] morphWeights = [1, 0, 0, 0, 0, 0, 0, 0];
			float[8] morphWeights;

			// State.
			bool clipPlaneEnabled;        // Clip Plane Enable (GL_CLIP_PLANE0)
			bool backfaceCullingEnabled;  // Backface Culling Enable (GL_CULL_FACE)
			bool ditheringEnabled;
			bool lineSmoothEnabled;
			bool colorTestEnabled;
			bool patchCullEnabled;

			LightingState   lighting;
			FogState        fog;
			BlendState      blend;
			DepthState      depth;
			AlphaTestState  alphaTest;
			StencilState    stencil;
			LogicalOperationState logicalOperation;
			
			ubyte[4] colorMask; // [0xFF, 0xFF, 0xFF, 0xFF];
		}
	}
	
	// Size of the inner state if less than PspGeContext.sizeof
	static assert((colorMask.offsetof + colorMask.sizeof - vertexType.offsetof) <= PspGeContext.sizeof);
	
	// RealState ends the struct
	static assert (this.RealState.offsetof + this.RealState.sizeof == this.sizeof);
	
	string toString() {
		return toString(PrimitiveType.GU_POINTS, PrimitiveFlags.all);
	}
	
	string toString(PrimitiveType type, PrimitiveFlags flags) {
		string ret;
		
		alias std.string.format format;
		
		ret ~= format("GpuState(\n");
		ret ~= format("    vertexType              = %s;\n"  , vertexType);
		ret ~= format("    baseAddress             = %08X;\n", baseAddress);
		ret ~= format("    vertexAddress           = %08X;\n", vertexAddress);
		ret ~= format("    indexAddress            = %08X;\n", indexAddress);
		ret ~= format("    textureTransfer         = %s\n",    textureTransfer);
		ret ~= format("    viewport                = %s\n",    viewport);
		ret ~= format("    offset                  = (%d, %d)\n", offsetX, offsetY);
		ret ~= format("    clearFlags              = %s\n",    toSet(clearFlags));
		ret ~= format("    ambientModelColor       = %s\n",    ambientModelColor);
		ret ~= format("    diffuseModelColor       = %s\n",    diffuseModelColor);
		ret ~= format("    specularModelColor      = %s\n",    specularModelColor);
		ret ~= format("    emissiveModelColor      = %s\n",    emissiveModelColor);
		ret ~= format("    textureEnviromentColor  = %s\n",    textureEnviromentColor);
		ret ~= format("    materialColorComponents = %s\n",    toSet(materialColorComponents));
		ret ~= format("    fog                     = %s\n",    fog);

		if (!vertexType.transform2D) {
			ret ~= format("    projectionMatrix        = \n%s\n",  projectionMatrix);
			ret ~= format("    worldMatrix             = \n%s\n",  worldMatrix);
			ret ~= format("    viewMatrix              = \n%s\n",  viewMatrix);
		}
		
		if (flags.hasTexture) {
			ret ~= format("    texture.matrix          = \n%s\n",  texture.matrix);
			ret ~= format("    texture                 = %s\n",    texture);
		}

		ret ~= format("    transformMode           = %s\n",    to!string(transformMode));
		ret ~= format("    uploadedClut            = %s\n",    uploadedClut);
		ret ~= format("    clut                    = %s\n",    clut);
		ret ~= format("    scissor                 = %s\n",    scissor);
		ret ~= format("    frontFaceDirection      = %s\n",    to!string(frontFaceDirection));
		ret ~= format("    shadeModel              = %s\n",    to!string(shadeModel));
		ret ~= format("    clipPlaneEnabled        = %s\n",    clipPlaneEnabled);
		ret ~= format("    backfaceCullingEnabled  = %s\n",    backfaceCullingEnabled);
		ret ~= format("    ditheringEnabled        = %s\n",    ditheringEnabled);
		ret ~= format("    lineSmoothEnabled       = %s\n",    lineSmoothEnabled);
		ret ~= format("    colorTestEnabled        = %s\n",    colorTestEnabled);
		ret ~= format("    patchCullEnabled        = %s\n",    patchCullEnabled);
		ret ~= format("    lighting                = %s\n",    lighting);
		ret ~= format("    blend                   = %s\n",    blend);
		ret ~= format("    depth                   = %s\n",    depth);
		ret ~= format("    alphaTest               = %s\n",    alphaTest);
		ret ~= format("    stencil                 = %s\n",    stencil);
		ret ~= format("    logicalOperation        = %s\n",    logicalOperation);
		ret ~= format("    colorMask               = %s\n",    colorMask);

		return ret;
	}
}
