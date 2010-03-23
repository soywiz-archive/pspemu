module pspemu.core.gpu.Types;

import std.string;
import std.bitmanip;

import pspemu.utils.Utils;

import pspemu.core.Memory;

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

struct TextureBuffer {
	uint address;
	uint width, height;
	uint size;
	uint format;
}

struct Colorf {
	union {
		struct { float[4] rgba = [0.0, 0.0, 0.0, 1.0]; }
		struct { float[3] rgb; }
		struct { float r, g, b, a; }
		struct { float red, green, blue, alpha; }
	}
	float* ptr() { return rgba.ptr; }
	static assert(this.sizeof == float.sizeof * 4);
}

struct TVector(Type, int Size = 4) {
	union {
		Type[Size] v;
		struct {
			static string __generateNamedFields() {
				string r = "";
				const auto names = ["x", "y", "z", "t"];
				for (int n = 0; n < Size; n++) {
					if (n < names.length) {
						r ~= "Type " ~ names[n] ~ ";";
					} else {
						r ~= "Type v" ~ tos(n) ~ ";";
					}
				}
				return r;
			}
			mixin(__generateNamedFields());
		}
	}
	alias TVector!(Type, Size) CTVector;

	static CTVector opCall(Type[] list) {
		CTVector vector = void;
		vector.v = list;
		return vector;
	}
	
	static string __generateConstructor() {
		string r = "static CTVector opCall(";
		for (int n = 0; n < Size; n++) {
			if (n != 0) r ~= ",";
			r ~= "Type v" ~ tos(n);
		}
		r ~= ") {";
		r ~= "return CTVector([";
		for (int n = 0; n < Size; n++) {
			if (n != 0) r ~= ",";
			r ~= "v" ~ tos(n);
		}
		r ~= "]);";
		r ~= "}";
		return r;
	}

	//pragma(msg, __generateConstructor());
	mixin(__generateConstructor());

	CTVector opAdd(CTVector that) {
		Type[Size] v; for (int n = 0; n < v.length; n++) v[n] = this.v[n] + that.v[n];
		return CTVector(v);
	}

	CTVector opSub(CTVector that) {
		Type[Size] v; for (int n = 0; n < v.length; n++) v[n] = this.v[n] - that.v[n];
		return CTVector(v);
	}

	CTVector opMul(Type that) {
		Type[Size] v; for (int n = 0; n < v.length; n++) v[n] = this.v[n] * that;
		return CTVector(v);
	}

	CTVector opDiv(Type that) {
		Type[Size] v; for (int n = 0; n < v.length; n++) v[n] = this.v[n] / that;
		return CTVector(v);
	}

	Type[] opSlice() { return v; }
	Type[] opSlice(size_t x, size_t y) { return v[x..y]; }
	Type opIndex(size_t index) { return v[index]; }
}

alias TVector!(float, 4) Vector;

struct Matrix {
	union {
		struct { float[4 * 4] cells; }
		struct { float[4][4]  rows; }
	}
	float* pointer() { return cells.ptr; }
	enum WriteMode { M4x4, M4x3 }
	const indexesM4x4 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
	const indexesM4x3 = [0, 1, 2,  4, 5, 6,  8, 9, 10,  12, 13, 14];
	uint index;
	WriteMode mode;
	void reset(WriteMode mode = WriteMode.M4x4) {
		index = 0;
		this.mode = mode;
		if (mode == WriteMode.M4x3) {
			cells[11] = cells[7] = cells[3] = 0.0;
			cells[15] = 1.0;
		}
	}
	void next() { index++; index &= 0xF; }
	void write(float cell) {
		auto indexes = (mode == WriteMode.M4x4) ? indexesM4x4 : indexesM4x3;
		cells[indexes[index++ % indexes.length]] = cell;
	}
	//static assert(this.sizeof == float.sizeof * 16 + uint.sizeof);
	string toString() {
		return std.string.format(
			"(%f, %f, %f, %f)\n"
			"(%f, %f, %f, %f)\n"
			"(%f, %f, %f, %f)\n"
			"(%f, %f, %f, %f)",
			cells[0], cells[1], cells[2], cells[3],
			cells[4], cells[5], cells[6], cells[7],
			cells[8], cells[9], cells[10], cells[11],
			cells[12], cells[13], cells[14], cells[15]
		);
	}
	Matrix opMul(Matrix that) {
		Matrix r = void;
		for (int y = 0; y < 4; y++) {
			for (int x = 0; x < 4; x++) {
				float v = 0.0;
				for (int n = 0; n < 4; n++) {
					v += this.rows[y][n] * that.rows[n][x];
				}
				r.rows[y][x] = v;
			}
		}
		return r;
	}
	float[4] opMul(float[4] that) {
		float[4] r = void;
		for (int y = 0; y < 4; y++) {
			float v = 0.0;
			for (int n = 0; n < 4; n++) {
				v += this.rows[y][n] * that[n];
			}
			r[y] = v;
		}
		return r;
	}
	Vector opMul(Vector that) {
		return Vector(this * that.v);
	}
	static bool compInteger(Matrix a, Matrix b) {
		uint[16] ia, ib;
		foreach (k, v; a.cells) ia[k] = cast(int)v;
		foreach (k, v; b.cells) ib[k] = cast(int)v;
		return ia == ib;
	}
}

version (unittest) {
	import std.stdio;
}
unittest {
	auto m1 = Matrix([
		3, 0, 0, 0,
		0, 2, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	]);
	auto m2 = Matrix([
		2, 3, 0, 0,
		0, 2, 0, 0,
		0, 0, 2, 0,
		0, 0, 0, 2
	]);
	auto m3 = Matrix([
		6, 9, 0, 0,
		0, 4, 0, 0,
		0, 0, 2, 0,
		0, 0, 0, 2
	]);

	assert(Matrix.compInteger(m1 * m2, m3));
}
//void main() {}

struct VertexType {
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
}

struct UV {
	float u, v;
}

struct Rect {
	uint x1, y1, x2, y2;
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
	Matrix projectionMatrix, worldMatrix, viewMatrix;
	int mipMapLevel;
	bool textureSwizzled;
	int textureFormat;
	TextureBuffer[8] textures;
	int textureFilterMin, textureFilterMag;
	int textureWrapS, textureWrapT;
	int textureEnvMode;
	UV textureScale;
	UV textureOffset;
	Rect scissor;
	int faceCullingOrder;
	int shadeModel;

	bool clipPlaneEnabled;        // Clip Plane Enable (GL_CLIP_PLANE0)
	bool backfaceCullingEnabled;  // Backface Culling Enable (GL_CULL_FACE)
	bool alphaBlendEnabled;       // Alpha Blend Enable (GL_BLEND)
	bool depthTestEnabled;        // depth (Z) Test Enable (GL_DEPTH_TEST)
	bool stencilTestEnabled;      // Stencil Test Enable (GL_STENCIL_TEST)
	bool logicalOperationEnabled; // Logical Operation Enable (GL_COLOR_LOGIC_OP)
	bool textureMappingEnabled;   // Texture Mapping Enable (GL_TEXTURE_2D)
	bool alphaTestEnabled;        // Alpha Test Enable (GL_ALPHA_TEST) glAlphaFunc(GL_GREATER, 0.03f);
	
	int blendEquation;
	int blendFuncSrc;
	int blendFuncDst;
}

interface GpuImpl {
	void setState(GpuState *state);
	void init();
	void clear();
	void draw(VertexState[] vertexList, PrimitiveType type, PrimitiveFlags flags);
	void flush();
	void frameLoad (void* buffer);
	void frameStore(void* buffer);
}

abstract class GpuImplAbstract : GpuImpl {
	GpuState *state;
	void setState(GpuState *state) { this.state = state; }
}

// GU Primitive Types.
enum PrimitiveType { GU_POINTS = 0, GU_LINES = 1, GU_LINE_STRIP = 2, GU_TRIANGLES = 3, GU_TRIANGLE_STRIP = 4, GU_TRIANGLE_FAN = 5, GU_SPRITES = 6 };
struct PrimitiveFlags {
	bool hasWeights;
	bool hasTexture;
	bool hasColor;
	bool hasNormal;
	bool hasPosition;
	int  numWeights;
}

struct VertexState {
	float u, v;        // Texture coordinates.
	float r, g, b, a;  // Color components.
	float nx, ny, nz;  // Normal vector.
	float px, py, pz;  // Position vector.
	float weights[8];  // Weights for skinning and morphing.
}
