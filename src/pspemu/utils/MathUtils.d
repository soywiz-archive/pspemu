module pspemu.utils.MathUtils;

import std.conv;

//public import std.algorithm;;

enum : bool { Unsigned, Signed }	
enum Sign : bool { Unsigned, Signed }

// Reinterpret.
// float -> int
int   F_I(float v) { return *cast(int   *)&v; }
// int -> float
float I_F(int   v) { return *cast(float *)&v; }	

T1 reinterpret(T1, T2)(T2 v) { return *cast(T1 *)&v; }

void swap(T)(ref T a, ref T b) { auto c = a; a = b; b = c; }

T min(T)(T l, T r) { return (l < r) ? l : r; }
T max(T)(T l, T r) { return (l > r) ? l : r; }

T xabs(T)(T v) { return (v >= 0) ? v : -v; }
T sign(T)(T v) { if (v == 0) return 0; return (v > 0) ? 1 : -1; }

T clamp(T)(T v, T l = 0, T r = 1) {
	if (v < l) v = l;
	if (v > r) v = r;
	return v;
}

/*
T nextAlignedValueTpl(T, uint aligned)(T value) {
	return value + nextAlignedIncrement(cast(uint)value, alignment);
}
*/

T nextAlignedValue(T)(T value, T alignment) {
	return value + nextAlignedIncrement(value, alignment);
}

T nextAlignedIncrement(T)(T value, T alignment) {
	return (alignment - (value % alignment)) % alignment;
}

T previousAlignedValue(T)(T value, T alignment) {
	return value - previousAlignedDecrement(value, alignment);
}

T previousAlignedDecrement(T)(T value, T alignment) {
	return value % alignment;
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
						r ~= "Type v" ~ to!string(n) ~ ";";
					}
				}
				return r;
			}
			mixin(__generateNamedFields());
		}
	}

	static assert(this.sizeof == Size * Type.sizeof);
	
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
			r ~= "Type v" ~ to!string(n) ~ " = 0";
		}
		r ~= ") {";
		r ~= "return CTVector([";
		for (int n = 0; n < Size; n++) {
			if (n != 0) r ~= ",";
			r ~= "v" ~ to!string(n);
		}
		r ~= "]);";
		r ~= "}";
		return r;
	}

	//pragma(msg, __generateConstructor());
	mixin(__generateConstructor());

	static if (is(Type == float) && (Size == 4)) {
		version (VERSION_SSE_OPS) {
			alias bool ACTUALLY_VERSION_SSE_OPS;
		}
	}

	// Optimized SSE (for float[4]).
	static if (is(ACTUALLY_VERSION_SSE_OPS)) {
		// http://www.cortstratton.org/articles/HugiCode.html
		// http://softpixel.com/~cwright/programming/simd/sse.php

		// STACK:
		//    +00 - PTR retaddr (ret)
		//    +04 - PTR this
		//    +08 - PTR retval
		//    +12 - that.v[0]
		//    +16 - that.v[1]
		//    +20 - that.v[2]
		//    +24 - that.v[3]
		static string genSimpleVectorInternalOp(string middleOp) {
			return r"
			asm {
				naked;

				// Load 128bits (4 float) from this and that.
				mov ECX, [ESP + 4];
				movups XMM0, [ECX     ]; // this
				movups XMM1, [ESP + 12]; // that

				" ~ middleOp ~ r" XMM0, XMM1;

				// Stores 4 floats into result.
				mov ECX, [ESP + 8]; // ret
				movups [ECX], XMM0;
				
				ret;
			}
			";
		}

		// STACK:
		//    +00 - PTR retaddr (ret)
		//    +04 - PTR this
		//    +08 - PTR retval
		//    +12 - that
		static string genSimpleVectorExternalOp(string middleOp) {
			return r"
			asm {
				naked;

				// Load 128bits (4 float) from this and that.
				mov ECX, [ESP + 4];
				movups XMM0, [ECX     ]; // this
				mov ECX, [ESP + 12]; // that
				push ECX; push ECX; push ECX; push ECX;
				movups XMM1, [ESP]; // that*4
				pop ECX; pop ECX; pop ECX; pop ECX;

				" ~ middleOp ~ r" XMM0, XMM1; // that

				// Stores 4 floats into result.
				mov ECX, [ESP + 8]; // ret
				movups [ECX], XMM0;
				
				ret;
			}
			";
		}

		extern (C) {
			// Internal operations.
			CTVector opBinary(string op:"+")(CTVector that) { mixin(genSimpleVectorInternalOp("addps")); }
			CTVector opBinary(string op:"-")(CTVector that) { mixin(genSimpleVectorInternalOp("subps")); }
			CTVector opBinary(string op:"*")(CTVector that) { mixin(genSimpleVectorInternalOp("mulps")); }
			CTVector opBinary(string op:"/")(CTVector that) { mixin(genSimpleVectorInternalOp("divps")); }
			
			// External operations.
			CTVector opBinary(string op:"+")(Type that) { mixin(genSimpleVectorExternalOp("addps")); }
			CTVector opBinary(string op:"-")(Type that) { mixin(genSimpleVectorExternalOp("subps")); }
			CTVector opBinary(string op:"*")(Type that) { mixin(genSimpleVectorExternalOp("mulps")); }
			CTVector opBinary(string op:"/")(Type that) { mixin(genSimpleVectorExternalOp("divps")); }
		}
	} else {
		CTVector opBinary(string op)(CTVector that) { mixin("Type[Size] rv = void; for (int n = 0; n < rv.length; n++) rv[n] = this.v[n] " ~ op ~ " that.v[n]; return CTVector(rv);"); }
		CTVector opBinary(string op)(Type that    ) { mixin("Type[Size] v  = void; for (int n = 0; n < v.length ; n++) v [n] = this.v[n] " ~ op ~ " that; return CTVector(v);"); }
	}

	Type[] opSlice() { return v; }
	Type[] opSlice(size_t x, size_t y) { return v[x..y]; }
	Type* pointer() { return v.ptr; }
	Type opIndex(size_t index) { return v[index]; }
	string toString() {
		string s;
		for (int n = 0; n < v.length; n++) {
			if (n != 0) s ~= ", ";
			s ~= std.conv.to!(string)(v[n]);
		}
		//return std.conv.to!(string)(typeid(typeof(this))) ~ "(" ~ s ~ ")";
		return "vec(" ~ s ~ ")";
	}
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
	
	static Matrix opCall() {
		Matrix matrix;
		matrix.setIdentity();
		return matrix;
	}
	
	void setIdentity() {
		for (int y = 0; y < 4; y++) {
			for (int x = 0; x < 4; x++) {
				rows[y][x] = ((y == x) && (x < 3)) ? 1.0 : 0.0;
			}
		}
	}
	
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