module pspemu.core.gpu.GpuState;

import pspemu.core.Memory;
import pspemu.core.gpu.Types;
import pspemu.core.gpu.Utils;

struct ScreenBuffer {
	uint _address = 0;
	uint width = 512;
	uint format = 3;
	uint address(uint _address) { return this._address = (0x04_000000 | _address); }
	uint address() { return this._address; }
	uint pixelSize() {
		switch (format) {
			case 0, 1, 2: return 2;
			case 3: return 4;
			default: throw(new Exception(std.string.format("Invalid ScreenBuffer.format %d", format)));
		}
	}
	ubyte[] row(void* ptr, int row) {
		int rowsize = width * pixelSize;
		return ((cast(ubyte *)ptr) + rowsize * row)[0..rowsize];
	}
}

struct TextureState {
	static const auto textureSizeMul = [2, 2, 2, 4, 1, 1, 2, 4, 4, 4, 4];
	static const auto textureSizeDiv = [1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1];

	uint address;
	uint width, height;
	uint size;
	uint format;
	bool swizzled;

	uint sizePixels(uint count) in {
		assert((format >= 0 && format) < (textureSizeMul.length));
	} body {
		return (count * textureSizeMul[format]) / textureSizeDiv[format];
	}

	uint rwidth() { return sizePixels(width); }
	uint totalSize() { return rwidth * height; }
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
	int  textureFormat;
	int  textureFilterMin, textureFilterMag;
	int  textureWrapS, textureWrapT;
	int  textureEnvMode;
	UV   textureScale, textureOffset;

	TextureState[8] textures;

	Rect scissor;
	int faceCullingOrder;
	int shadeModel;

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

	// Blending.
	int blendEquation;
	int blendFuncSrc;
	int blendFuncDst;

	int  stencilFuncFunc;
	int  stencilFuncRef;
	uint stencilFuncMask;

	uint stencilOperationSfail;
	uint stencilOperationDpfail;
	uint stencilOperationDppass;

	uint fixSrc;
	uint fixDst;

	uint logicalOperation = 3; // GL_COPY (default)
}

struct PrimitiveFlags {
	bool hasWeights;
	bool hasTexture;
	bool hasColor;
	bool hasNormal;
	bool hasPosition;
	int  numWeights;
}
