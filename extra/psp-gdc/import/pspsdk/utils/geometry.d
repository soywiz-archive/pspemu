module pspsdk.utils.geometry;

import pspsdk.pspkerneltypes;
import pspsdk.pspgu;
import std.c.math;

struct TCNPVertex { // Texture, Color, Normal, Position
	ScePspFVector2 texture;
	u32 color;
	ScePspFVector3 normal;
	ScePspFVector3 position;
	static const FORMAT = (GU_TEXTURE_32BITF | GU_COLOR_8888 | GU_NORMAL_32BITF | GU_VERTEX_32BITF);
}

struct TCPVertex { // Texture, Color, Position
	ScePspFVector2 texture;
	u32 color;
	ScePspFVector3 position;
	static const FORMAT = (GU_TEXTURE_32BITF | GU_COLOR_8888 | GU_VERTEX_32BITF);
}

struct TPVertex { // Texture, Position
	ScePspFVector2 texture;
	ScePspFVector3 position;
	static const FORMAT = (GU_TEXTURE_32BITF | GU_VERTEX_32BITF);
}

struct NPVertex { // Normal, Position

	ScePspFVector3 normal;
	ScePspFVector3 position;
	static const FORMAT = (GU_NORMAL_32BITF | GU_VERTEX_32BITF);
}
//static const NP_VERTEX_FORMAT = (GU_NORMAL_32BITF | GU_VERTEX_32BITF);

static void generateTorus(uint slices, uint rows, float radius, float thickness, void* vertices, ushort* indices, uint size, int texture, int color, int normal, int position) {
	for (uint j = 0; j < slices; j++) {
		for (uint i = 0; i < rows; i++) {
			float s = i + 0.5f;
			float t = j;
			float cs,ct,ss,st;
			int offset = 0;

			cs = cosf(s * (2 * GU_PI) / slices);
			ct = cosf(t * (2 * GU_PI) / rows);
			ss = sinf(s * (2 * GU_PI) / slices);
			st = sinf(t * (2 * GU_PI) / rows);

			if (texture >= 0) {
				float* texcoords = cast(float*)((cast(ubyte*)vertices) + offset);
				texcoords[0] = cs * ct;
				texcoords[1] = cs * st;
				offset += texture;
			}

			if (color >= 0) {
				u32* col = cast(u32*)((cast(ubyte*)vertices) + offset);
				uint r = cast(uint)(128 + (cs * ct) * 127);
				uint g = cast(uint)(128 + (cs * st) * 127);
				uint b = cast(uint)(128 + (     ss) * 127);

				*col = (0xff << 24)|(b << 16)|(g << 8)|r;
				offset += color;
			}

			if (normal >= 0) {
				float* normals = cast(float*)((cast(ubyte*)vertices) + offset);
				normals[0] = cs * ct;
				normals[1] = cs * st;
				normals[2] = ss;

				offset += normal;
			}

			if (position >= 0) {
				float* pos = cast(float*)((cast(ubyte*)vertices) + offset);
				pos[0] = (radius + thickness * cs) * ct;
				pos[1] = (radius + thickness * cs) * st;
				pos[2] = thickness * ss;

				offset += position;
			}      

			vertices = cast(void*)((cast(ubyte*)vertices) + size);
		}
	}

	// TODO: generate degenerates instead, so we can tristrip the torus

	for (uint j = 0; j < slices; j++) {
		for (uint i = 0; i < rows; i++) {
			uint i1 = (i + 1) % rows;
			uint j1 = (j + 1) % slices;

			*indices++ = cast(ushort)(i  + j  * rows);
			*indices++ = cast(ushort)(i1 + j  * rows);
			*indices++ = cast(ushort)(i  + j1 * rows);

			*indices++ = cast(ushort)(i1 + j  * rows);
			*indices++ = cast(ushort)(i1 + j1 * rows);
			*indices++ = cast(ushort)(i  + j1 * rows);
		}
	}
}

void generateTorusTCNP(uint slices, uint rows, float radius, float thickness, TCNPVertex* vertices, ushort* indices) {
	generateTorus(slices, rows, radius, thickness, vertices, indices, TCNPVertex.sizeof, 2 * float.sizeof, u32.sizeof, 3 * float.sizeof, 3 * float.sizeof);
}

void generateTorusTCP(uint slices, uint rows, float radius, float thickness, TCPVertex* vertices, ushort* indices) {
	generateTorus(slices, rows, radius, thickness, vertices, indices, TCPVertex.sizeof, 2 * float.sizeof, u32.sizeof, -1, 3 * float.sizeof);
}

void generateTorusNP(uint slices, uint rows, float radius, float thickness, NPVertex* vertices, ushort* indices) {
	generateTorus(slices, rows, radius, thickness, vertices, indices, NPVertex.sizeof, -1, -1, 3 * float.sizeof, 3 * float.sizeof);
}

static void generateGrid(uint columns, uint rows, float width, float depth, void* vertices, ushort* indices, uint size, int texture, int color, int normal, int position)
{
	float ic = 1.0f / columns;
	float ir = 1.0f / rows;

	for (uint j = 0; j < rows; j++) {
		for (uint i = 0; i < columns; i++) {
			int offset = 0;

			if (texture >= 0) {
				float* texcoords = cast(float*)((cast(ubyte*)vertices) + offset);
				texcoords[0] = ic * i;
				texcoords[1] = ir * j;
				offset += texture;
			}

			if (color >= 0) {
				u32* col = cast(u32*)((cast(ubyte*)vertices) + offset);
				*col = 0xffffffff;
				offset += color;
			}

			if (normal >= 0) {
				float* normals = cast(float*)((cast(ubyte*)vertices) + offset);
				normals[0] = 0.0f;
				normals[1] = 1.0f;
				normals[2] = 0.0f;
				offset += normal;
			}

			if (position >= 0) {
				float* pos = cast(float*)((cast(ubyte*)vertices) + offset);
				pos[0] = ((ic * i) - 0.5f) * width;
				pos[1] = 0.0f;
				pos[2] = ((ir * j) - 0.5f) * depth;
				offset += position;
			}

			vertices = cast(void*)((cast(ubyte*)vertices) + size);
		}
	}

	for (uint j = 0; j < rows - 1; j++) {
		for (uint i = 0; i < columns - 1; i++) {
			*indices++ = cast(ushort)((i    ) + (j    ) * columns);
			*indices++ = cast(ushort)((i + 1) + (j    ) * columns);
			*indices++ = cast(ushort)((i    ) + (j + 1) * columns);

			*indices++ = cast(ushort)((i + 1) + (j    ) * columns);
			*indices++ = cast(ushort)((i + 1) + (j + 1) * columns);
			*indices++ = cast(ushort)((i    ) + (j + 1) * columns);
		}
	}
}

void generateGridTCNP(uint columns, uint rows, float width, float depth, TCNPVertex* vertices, ushort* indices) {
	generateGrid(columns, rows, width, depth, vertices, indices, TCNPVertex.sizeof, 2 * float.sizeof, u32.sizeof, 3 * float.sizeof, 3 * float.sizeof);
}

void generateGridNP(uint columns, uint rows, float width, float depth, NPVertex* vertices, ushort* indices) {
	generateGrid(columns, rows, width, depth, vertices, indices, NPVertex.sizeof, -1, -1, 3 * float.sizeof, 3 * float.sizeof);
}
