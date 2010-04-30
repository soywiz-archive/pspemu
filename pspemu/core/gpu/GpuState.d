module pspemu.core.gpu.GpuState;

import pspemu.core.Memory;
import pspemu.core.gpu.Types;
import pspemu.utils.Math;
import pspemu.utils.Utils;

import std.bitmanip;

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
	ubyte[] data;

	int colorEntrySize() { return PixelFormatSize(format, 1); }
	int blocksSize(int num_blocks) {
		return PixelFormatSize(format, num_blocks * 8);
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
	struct Attenuation { float constant, linear, quadratic; }
	bool enabled = false;
	LightType type;
	LightModel kind;
	Vector position, spotDirection;
	Attenuation attenuation;
	float spotExponent;
	float spotCutoff;
	Colorf ambientColor, diffuseColor, specularColor;
}

struct VertexState {
	float u, v;        // Texture coordinates.
	float r, g, b, a;  // Color components.
	float nx, ny, nz;  // Normal vector.
	float px, py, pz;  // Position vector.
	float weights[8];  // Weights for skinning and morphing.

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
}

struct Viewport {
	float px, py, pz;
	float sx, sy, sz;
}

struct TextureState {
	// Format of the texture data.
	bool           swizzled;              /// Is texture swizzled?
	PixelFormats   format;                /// Texture Data mode

	// Normal attributes
	TextureFilter  filterMin, filterMag;  /// TextureFilter when drawing the texture scaled
	WrapMode       wrapU, wrapV;          /// Wrap mode when specifying texture coordinates beyond texture size
	UV             scale;                 /// 
	UV             offset;                /// 

	// Effects
	TextureEffect  effect;                /// 
	TextureColorComponent colorComponent; ///
	bool           fragment_2x;           /// ???

	// Mimaps
	struct MipmapState {
		uint address;                     /// Pointer 
		uint buffer_width;                ///
		uint width, height;               ///
	}
	int            mipmapMaxLevel;        /// Levels of mipmaps
	bool           mipmapShareClut;       /// Mipmaps share clut?
	MipmapState[8] mipmaps;               /// MipmapState list

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
}

static struct GpuState {
	Memory memory;
	uint baseAddress, vertexAddress, indexAddress;
	ScreenBuffer drawBuffer, depthBuffer;
	TextureTransfer textureTransfer;
	
	union {
		uint[1024] RealState;
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
			
			Colorf fogColor;
			float  fogDist, fogEnd;

			// Matrix.
			Matrix projectionMatrix, worldMatrix, viewMatrix, textureMatrix;
			
			LightModel lightModel;
			
			// Textures.
			// Temporal values.
			TransformMode transformMode;
			
			TextureState texture;
			ClutState uploadedClut;
			ClutState clut;

			Rect scissor;
			FrontFaceDirection frontFaceDirection;
			ShadingModel shadeModel;

			float[8] morphWeights;

			// Lights related.
			Colorf ambientLightColor;
			float  specularPower;
			LightState[4] lights;

			// State.
			bool textureMappingEnabled;   // Texture Mapping Enable (GL_TEXTURE_2D)
			bool clipPlaneEnabled;        // Clip Plane Enable (GL_CLIP_PLANE0)
			bool backfaceCullingEnabled;  // Backface Culling Enable (GL_CULL_FACE)
			bool alphaBlendEnabled;       // Alpha Blend Enable (GL_BLEND)
			bool depthTestEnabled;        // depth (Z) Test Enable (GL_DEPTH_TEST)
			bool stencilTestEnabled;      // Stencil Test Enable (GL_STENCIL_TEST)
			bool logicalOperationEnabled; // Logical Operation Enable (GL_COLOR_LOGIC_OP)
			bool alphaTestEnabled;        // Alpha Test Enable (GL_ALPHA_TEST) glAlphaFunc(GL_GREATER, 0.03f);
			bool lightingEnabled;         // Lighting Enable (GL_LIGHTING)
			bool fogEnabled;              // FOG Enable (GL_FOG)
			bool ditheringEnabled;
			bool lineSmoothEnabled;
			bool colorTestEnabled;
			bool patchCullEnabled;

			float fogDensity; // 0.1
			int fogMode;
			int fogHint;
			
			// Blending.
			int blendEquation;
			int blendFuncSrc;
			int blendFuncDst;

			TestFunction depthFunc; // TestFunction.GU_ALWAYS
			float depthRangeNear, depthRangeFar; // 0.0 - 1.0
			ushort depthMask;

			TestFunction alphaTestFunc; // TestFunction.GU_ALWAYS
			float alphaTestValue;
			ubyte alphaTestMask; // 0xFF
			
			TestFunction stencilFuncFunc;
			ubyte stencilFuncRef;
			ubyte stencilFuncMask; // 0xFF

			StencilOperations stencilOperationSfail;
			StencilOperations stencilOperationDpfail;
			StencilOperations stencilOperationDppass;

			Colorf fixColorSrc, fixColorDst;

			LogicalOperation logicalOperation; // LogicalOperation.GU_COPY
			
			ubyte[4] colorMask; // [0xFF, 0xFF, 0xFF, 0xFF];
			//static assert (this.sizeof <= 512);
		}
	}

	static assert (this.RealState.offsetof + this.RealState.sizeof == this.sizeof); // RealState ends the struct
}

struct PrimitiveFlags {
	bool hasWeights;
	bool hasTexture;
	bool hasColor;
	bool hasNormal;
	bool hasPosition;
	int  numWeights;
}
