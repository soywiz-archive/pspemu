module pspemu.core.gpu.GpuState;

import pspemu.core.Memory;
import pspemu.core.gpu.Types;
import pspemu.utils.Math;

import std.bitmanip;

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
	bool mustLoad, mustStore;
	uint address(uint _address) { return this._address = _address; }
	uint address() { return (0x04_000000 | this._address); }
	uint pixelSize() { return PixelFormatSizeMul[format]; }
	ubyte[] row(void* ptr, int row) {
		int rowsize = PixelFormatSize(format, width);
		return ((cast(ubyte *)ptr) + rowsize * row)[0..rowsize];
	}
}

struct TextureState {
	uint address;
	uint buffer_width;
	uint width, height;
	uint size;
	PixelFormats format;
	bool swizzled;

	uint rwidth() { return PixelFormatSize(format, buffer_width); }
	//uint rwidth() { return buffer_width; }
	//uint rwidth() { return PixelFormatSize(format, width); }
	//uint rwidth() { return width; }
	uint totalSize() { return rwidth * height; }
	bool hasPalette() { return (format >= PixelFormats.GU_PSM_T4 && format <= PixelFormats.GU_PSM_T32); }
	uint paletteRequiredComponents() { return hasPalette ? (1 << (4 + (format - PixelFormats.GU_PSM_T4))) : 0; }
	string toString() {
		return std.string.format("TextureState(addr=%08X, size(%dx%d), bwidth=%d size=%d, format=%d, swizzled=%d)", address, width, height, buffer_width, size, format, swizzled);
	}
}

struct LightState {
	struct Attenuation { float constant, linear, quadratic; }
	bool enabled = false;
	LightType type;
	LightModel kind;
	Vector position, spotDirection;
	Attenuation attenuation;
	float spotLightExponent;
	float spotLightCutoff;
	Colorf ambientLightColor;
	Colorf diffuseLightColor;
	Colorf specularLightColor;
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

static struct GpuState {
	Memory memory;

	ScreenBuffer drawBuffer, depthBuffer;

	VertexType vertexType;
	Viewport viewport;
	uint offsetX, offsetY;

	uint baseAddress;
	uint vertexAddress;
	uint indexAddress;

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
	bool textureMappingEnabled;   // Texture Mapping Enable (GL_TEXTURE_2D)
	int  mipMapMaxLevel;
	bool textureSwizzled;
	PixelFormats  textureFormat;
	TextureFilter textureFilterMin, textureFilterMag;
	WrapMode      textureWrapU, textureWrapV;
	TextureEffect textureEffect;
	TextureColorComponent textureColorComponent;
	UV   textureScale, textureOffset;
	bool mipmapShareClut;

	TextureState[8] textures;
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

	float fogDensity = 0.1;
	int fogMode;
	int fogHint;
	
	// Blending.
	int blendEquation;
	int blendFuncSrc;
	int blendFuncDst;

	TestFunction depthFunc = TestFunction.GU_ALWAYS;
	float depthRangeNear = 0.0, depthRangeFar = 1.0;
	ushort depthMask;

	TestFunction alphaTestFunc = TestFunction.GU_ALWAYS;
	float alphaTestValue;
	ubyte alphaTestMask = 0xFF;
	
	TestFunction stencilFuncFunc;
	ubyte stencilFuncRef;
	ubyte stencilFuncMask = 0xFF;

	StencilOperations stencilOperationSfail;
	StencilOperations stencilOperationDpfail;
	StencilOperations stencilOperationDppass;

	Colorf fixColorSrc, fixColorDst;

	LogicalOperation logicalOperation = LogicalOperation.GU_COPY; // GL_COPY (default)
	
	ubyte[4] colorMask = [0xFF, 0xFF, 0xFF, 0xFF];
	
	//static assert (this.sizeof <= 512);
}

struct PrimitiveFlags {
	bool hasWeights;
	bool hasTexture;
	bool hasColor;
	bool hasNormal;
	bool hasPosition;
	int  numWeights;
}
