module pspemu.core.gpu.GpuState;

import pspemu.core.Memory;
import pspemu.core.gpu.Types;
import pspemu.utils.Math;

struct RGBA8888 {
	union {
		uint color;
		struct { ubyte r, g, b, a; }
	}
	static assert(this.sizeof == 4);
}

/*RGBA8888[] decode(PixelFormats format) {
}*/

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
	uint _address = 0;
	uint width = 512;
	PixelFormats format = PixelFormats.GU_PSM_8888;
	uint address(uint _address) { return this._address = (0x04_000000 | _address); }
	uint address() { return this._address; }
	uint pixelSize() { return PixelFormatSizeMul[format]; }
	ubyte[] row(void* ptr, int row) {
		int rowsize = PixelFormatSize(format, width);
		return ((cast(ubyte *)ptr) + rowsize * row)[0..rowsize];
	}
}

struct TextureState {
	uint address;
	uint width, height;
	uint size;
	PixelFormats format;
	bool swizzled;

	uint rwidth() { return PixelFormatSize(format, width); }
	//uint rwidth() { return width; }
	uint totalSize() { return rwidth * height; }
	bool hasPalette() { return (format >= PixelFormats.GU_PSM_T4 && format <= PixelFormats.GU_PSM_T32); }
	uint paletteRequiredComponents() { return hasPalette ? (1 << (4 + (format - PixelFormats.GU_PSM_T4))) : 0; }
	string toString() {
		return std.string.format("TextureState(addr=%08X, size(%dx%d), size=%d, format=%d, swizzled=%d)", address, width, height, size, format, swizzled);
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

static struct GpuState {
	Memory memory;

	ScreenBuffer drawBuffer;

	uint baseAddress;
	uint vertexAddress;
	uint indexAddress;
	int  clearFlags;
	VertexType vertexType;
	Colorf ambientModelColor, diffuseModelColor, specularModelColor;
	Colorf materialColor;
	Colorf textureEnviromentColor;

	// Matrix.
	Matrix projectionMatrix, worldMatrix, viewMatrix, textureMatrix;
	
	LightModel lightModel;
	
	// Textures.
	// Temporal values.
	bool textureMappingEnabled;   // Texture Mapping Enable (GL_TEXTURE_2D)
	int  mipMapLevel;
	bool textureSwizzled;
	PixelFormats textureFormat;
	int  textureFilterMin, textureFilterMag;
	int  textureWrapS, textureWrapT;
	int  textureEnvMode;
	UV   textureScale, textureOffset;

	TextureState[8] textures;
	ClutState uploadedClut;
	ClutState clut;

	Rect scissor;
	int faceCullingOrder;
	int shadeModel;

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
	
	TestFunction depthFunc = TestFunction.GU_ALWAYS;

	// Blending.
	int blendEquation;
	int blendFuncSrc;
	int blendFuncDst;

	TestFunction stencilFuncFunc;
	int  stencilFuncRef;
	uint stencilFuncMask;

	StencilOperations stencilOperationSfail;
	StencilOperations stencilOperationDpfail;
	StencilOperations stencilOperationDppass;

	uint fixSrc;
	uint fixDst;

	LogicalOperation logicalOperation = LogicalOperation.GU_COPY; // GL_COPY (default)
}

struct PrimitiveFlags {
	bool hasWeights;
	bool hasTexture;
	bool hasColor;
	bool hasNormal;
	bool hasPosition;
	int  numWeights;
}
