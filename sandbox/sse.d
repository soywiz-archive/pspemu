// dmd -gc -release -noboundscheck -O -run sse.d
// http://www.intel.com/software/products/documentation/vlin/
// http://www.digitalmars.com/ctg/ctgAsm.html
// http://en.wikipedia.org/wiki/X86_calling_conventions

import std.c.stdio;
import std.stdio;
import std.cpuid;

struct Vector {
	float[4] v;

	static if (0) {
		extern (C) Vector opAdd(Vector that) {
			Vector ret = void;
			for (int n = 0; n < 4; n++) ret.v[n] = this.v[n] + that.v[n];
			return ret;
		}
	} else {
		extern (C) Vector opAdd(Vector that) {
			asm {
				naked;

				// Load 128bits (4 float) from this and that.
				mov ECX, [ESP + 4];
				movups XMM0, [ECX +  0]; // this
				movups XMM1, [ESP + 12]; // that

				// Sum
				addps  XMM0, XMM1; 

				// Stores 4 floats into result.
				mov ECX, [ESP + 8]; // ret
				movups [ECX], XMM0;
				
				ret;
			}
		}
		extern (C) Vector opMul(float that) {
			asm {
				naked;

				// Load 128bits (4 float) from this and that.
				mov ECX, [ESP + 4];
				movups XMM0, [ECX]; // that

				mov ECX, [ESP + 12];
				push ECX; push ECX; push ECX; push ECX;
				movups XMM1, [ESP]; // that
				pop ECX; pop ECX; pop ECX; pop ECX;
				
				mulps  XMM0, XMM1      ; // that

				// Stores 4 floats into result.
				mov ECX, [ESP + 8]; // ret
				movups [ECX], XMM0;
				
				ret;
			}
		}
	}

	static assert(this.sizeof == 4 * float.sizeof);
}

void main() {
	auto v1 = Vector([1, 1, 1, 1]);
	auto v2 = Vector([2, 2, 2, 2]);
	auto v3 = v1 + v2;
	printf("v1 = %f, %f, %f, %f\n", v1.v[0], v1.v[1], v1.v[2], v1.v[3]);
	printf("v2 = %f, %f, %f, %f\n", v2.v[0], v2.v[1], v2.v[2], v2.v[3]);
	printf("v3 = %f, %f, %f, %f\n", v3.v[0], v3.v[1], v3.v[2], v3.v[3]);

	v3 = v3 * 2;
	printf("v3 = %f, %f, %f, %f\n", v3.v[0], v3.v[1], v3.v[2], v3.v[3]);
	//writefln(std.cpuid.toString());
}