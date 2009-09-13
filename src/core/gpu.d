module psp.gpu;

import std.stdio;
import std.string;
import std.random;
import std.c.time;
import std.file;

import dfl.all, dfl.internal.winapi;
import glcontrol, opengl;
import utils.common;

import psp.disassembler.gpu;

import psp.memory;

//version = gpu_use_shaders;
//version = gpu_no_lighting;

//debug = gpu_debug;
//debug = gpu_debug_verbose;
//debug = gpu_debug_matrix;
//debug = gpu_debug_texture;
//debug = gpu_debug_texture_dump;
//debug = gpu_debug_clut;
//debug = gpu_debug_clut_dump;
//debug = gpu_debug_vertex;

// http://wiki.ps2dev.org/psp:ge_register_list

class GPU {
	GLControl glcontrol;
	Memory mem;
	Registers regs;

	enum VC { // VideoCommand
		NOP				= 0x00,
		VADDR			= 0x01, // Vertex List (BASE)
		IADDR			= 0x02, // Index List (BASE)
		Unknown0x03		= 0x03, // 
		PRIM			= 0x04, // Primitive Kick
		BEZIER			= 0x05, // Bezier Patch Kick
		SPLINE			= 0x06, // Spline Surface Kick
		BBOX			= 0x07, // Bounding Box
		JUMP			= 0x08, // Jump To New Address (BASE)
		BJUMP			= 0x09, // Conditional Jump (BASE)
		CALL			= 0x0A, // Call Address (BASE)
		RET				= 0x0B, // Return From Call
		END				= 0x0C, // Stop Execution
		Unknown0x0D		= 0x0D, // 
		SIGNAL			= 0x0E, // Raise Signal Interrupt
		FINISH			= 0x0F, // Complete Rendering
		BASE			= 0x10, // Base Address Register
		Unknown0x11		= 0x11, // 
		VTYPE			= 0x12, // Vertex Type
		OFFSETADDR		= 0x13, // Offset Address (BASE)
		ORIGINADDR		= 0x14, // Origin Address (BASE)
		REGION1			= 0x15, // Draw Region Start
		REGION2			= 0x16, // Draw Region End
		LTE				= 0x17, // Lighting Enable
		LTE0			= 0x18, // Light 0 Enable
		LTE1			= 0x19, // Light 1 Enable
		LTE2			= 0x1A, // Light 2 Enable
		LTE3			= 0x1B, // Light 3 Enable
		CPE				= 0x1C, // Clip Plane Enable
		BCE				= 0x1D, // Backface Culling Enable
		TME				= 0x1E, // Texture Mapping Enable
		FGE				= 0x1F, // Fog Enable
		DTE				= 0x20, // Dither Enable
		ABE				= 0x21, // Alpha Blend Enable
		ATE				= 0x22, // Alpha Test Enable
		ZTE				= 0x23, // Depth Test Enable
		STE				= 0x24, // Stencil Test Enable
		AAE				= 0x25, // Anitaliasing Enable
		PCE				= 0x26, // Patch Cull Enable
		CTE				= 0x27, // Color Test Enable
		LOE				= 0x28, // Logical Operation Enable
		Unknown0x29		= 0x29, // 
		BOFS			= 0x2A, // Bone Matrix Offset
		BONE			= 0x2B, // Bone Matrix Upload
		MW0				= 0x2C, // Morph Weight 0
		MW1				= 0x2D, // Morph Weight 1
		MW2				= 0x2E, // Morph Weight 2
		MW3				= 0x2F, // Morph Weight 3
		MW4				= 0x30, // Morph Weight 4
		MW5				= 0x31, // Morph Weight 5
		MW6				= 0x32, // Morph Weight 6
		MW7				= 0x33, // Morph Weight 7
		Unknown0x34		= 0x34, // 
		Unknown0x35		= 0x35, // 
		PSUB			= 0x36, // Patch Subdivision
		PPRIM			= 0x37, // Patch Primitive
		PFACE			= 0x38, // Patch Front Face
		Unknown0x39		= 0x39, // 
		WMS				= 0x3A, // World Matrix Select
		WORLD			= 0x3B, // World Matrix Upload
		VMS				= 0x3C, // View Matrix Select
		VIEW			= 0x3D, // View Matrix upload
		PMS				= 0x3E, // Projection matrix Select
		PROJ			= 0x3F, // Projection Matrix upload
		TMS				= 0x40, // Texture Matrix Select
		TMATRIX			= 0x41, // Texture Matrix Upload
		XSCALE			= 0x42, // Viewport Width Scale
		YSCALE			= 0x43, // Viewport Height Scale
		ZSCALE			= 0x44, // Depth Scale
		XPOS			= 0x45, // Viewport X Position
		YPOS			= 0x46, // Viewport Y Position
		ZPOS			= 0x47, // Depth Position
		USCALE			= 0x48, // Texture Scale U
		VSCALE			= 0x49, // Texture Scale V
		UOFFSET			= 0x4A, // Texture Offset U
		VOFFSET			= 0x4B, // Texture Offset V
		OFFSETX			= 0x4C, // Viewport offset (X)
		OFFSETY			= 0x4D, // Viewport offset (Y)
		Unknown0x4E		= 0x4E, // 
		Unknown0x4F		= 0x4F, // 
		SHADE			= 0x50, // Shade Model
		RNORM			= 0x51, // Reverse Face Normals Enable
		Unknown0x52		= 0x52, // 
		CMAT			= 0x53, // Color Material
		EMC				= 0x54, // Emissive Model Color
		AMC				= 0x55, // Ambient Model Color
		DMC				= 0x56, // Diffuse Model Color
		SMC				= 0x57, // Specular Model Color
		AMA				= 0x58, // Ambient Model Alpha
		Unknown0x59		= 0x59, // 
		Unknown0x5A		= 0x5A, // 
		SPOW			= 0x5B, // Specular Power
		ALC				= 0x5C, // Ambient Light Color
		ALA				= 0x5D, // Ambient Light Alpha
		LMODE			= 0x5E, // Light Model
		LT0				= 0x5F, // Light Type 0
		LT1				= 0x60, // Light Type 1
		LT2				= 0x61, // Light Type 2
		LT3				= 0x62, // Light Type 3
		LXP0			= 0x63, // Light X Position 0
		LYP0			= 0x64, // Light Y Position 0
		LZP0			= 0x65, // Light Z Position 0
		LXP1			= 0x66, // Light X Position 1
		LYP1			= 0x67, // Light Y Position 1
		LZP1			= 0x68, // Light Z Position 1
		LXP2			= 0x69, // Light X Position 2
		LYP2			= 0x6A, // Light Y Position 2
		LZP2			= 0x6B, // Light Z Position 2
		LXP3			= 0x6C, // Light X Position 3
		LYP3			= 0x6D, // Light Y Position 3
		LZP3			= 0x6E, // Light Z Position 3
		LXD0			= 0x6F, // Light X Direction 0
		LYD0			= 0x70, // Light Y Direction 0
		LZD0			= 0x71, // Light Z Direction 0
		LXD1			= 0x72, // Light X Direction 1
		LYD1			= 0x73, // Light Y Direction 1
		LZD1			= 0x74, // Light Z Direction 1
		LXD2			= 0x75, // Light X Direction 2
		LYD2			= 0x76, // Light Y Direction 2
		LZD2			= 0x77, // Light Z Direction 2
		LXD3			= 0x78, // Light X Direction 3
		LYD3			= 0x79, // Light Y Direction 3
		LZD3			= 0x7A, // Light Z Direction 3
		LCA0			= 0x7B, // Light Constant Attenuation 0
		LLA0			= 0x7C, // Light Linear Attenuation 0
		LQA0			= 0x7D, // Light Quadratic Attenuation 0
		LCA1			= 0x7E, // Light Constant Attenuation 1
		LLA1			= 0x7F, // Light Linear Attenuation 1
		LQA1			= 0x80, // Light Quadratic Attenuation 1
		LCA2			= 0x81, // Light Constant Attenuation 2
		LLA2			= 0x82, // Light Linear Attenuation 2
		LQA2			= 0x83, // Light Quadratic Attenuation 2
		LCA3			= 0x84, // Light Constant Attenuation 3
		LLA3			= 0x85, // Light Linear Attenuation 3
		LQA3			= 0x86, // Light Quadratic Attenuation 3
		SPOTEXP0		= 0x87, // Spot light 0 exponent
		SPOTEXP1		= 0x88, // Spot light 1 exponent
		SPOTEXP2		= 0x89, // Spot light 2 exponent
		SPOTEXP3		= 0x8A, // Spot light 3 exponent
		SPOTCUT0		= 0x8B, // Spot light 0 cutoff
		SPOTCUT1		= 0x8C, // Spot light 1 cutoff
		SPOTCUT2		= 0x8D, // Spot light 2 cutoff
		SPOTCUT3		= 0x8E, // Spot light 3 cutoff
		ALC0			= 0x8F, // Ambient Light Color 0
		DLC0			= 0x90, // Diffuse Light Color 0
		SLC0			= 0x91, // Specular Light Color 0
		ALC1			= 0x92, // Ambient Light Color 1
		DLC1			= 0x93, // Diffuse Light Color 1
		SLC1			= 0x94, // Specular Light Color 1
		ALC2			= 0x95, // Ambient Light Color 2
		DLC2			= 0x96, // Diffuse Light Color 2
		SLC2			= 0x97, // Specular Light Color 2
		ALC3			= 0x98, // Ambient Light Color 3
		DLC3			= 0x99, // Diffuse Light Color 3
		SLC3			= 0x9A, // Specular Light Color 3
		FFACE			= 0x9B, // Front Face Culling Order
		FBP				= 0x9C, // Frame Buffer Pointer
		FBW				= 0x9D, // Frame Buffer Width
		ZBP				= 0x9E, // Depth Buffer Pointer
		ZBW				= 0x9F, // Depth Buffer Width
		TBP0			= 0xA0, // Texture Buffer Pointer 0
		TBP1			= 0xA1, // Texture Buffer Pointer 1
		TBP2			= 0xA2, // Texture Buffer Pointer 2
		TBP3			= 0xA3, // Texture Buffer Pointer 3
		TBP4			= 0xA4, // Texture Buffer Pointer 4
		TBP5			= 0xA5, // Texture Buffer Pointer 5
		TBP6			= 0xA6, // Texture Buffer Pointer 6
		TBP7			= 0xA7, // Texture Buffer Pointer 7
		TBW0			= 0xA8, // Texture Buffer Width 0
		TBW1			= 0xA9, // Texture Buffer Width 1
		TBW2			= 0xAA, // Texture Buffer Width 2
		TBW3			= 0xAB, // Texture Buffer Width 3
		TBW4			= 0xAC, // Texture Buffer Width 4
		TBW5			= 0xAD, // Texture Buffer Width 5
		TBW6			= 0xAE, // Texture Buffer Width 6
		TBW7			= 0xAF, // Texture Buffer Width 7
		CBP				= 0xB0, // CLUT Buffer Pointer
		CBPH			= 0xB1, // CLUT Buffer Pointer H
		TRXSBP			= 0xB2, // Transmission Source Buffer Pointer
		TRXSBW			= 0xB3, // Transmission Source Buffer Width
		TRXDBP			= 0xB4, // Transmission Destination Buffer Pointer
		TRXDBW			= 0xB5, // Transmission Destination Buffer Width
		Unknown0xB6		= 0xB6, // 
		Unknown0xB7		= 0xB7, // 
		TSIZE0			= 0xB8, // Texture Size Level 0
		TSIZE1			= 0xB9, // Texture Size Level 1
		TSIZE2			= 0xBA, // Texture Size Level 2
		TSIZE3			= 0xBB, // Texture Size Level 3
		TSIZE4			= 0xBC, // Texture Size Level 4
		TSIZE5			= 0xBD, // Texture Size Level 5
		TSIZE6			= 0xBE, // Texture Size Level 6
		TSIZE7			= 0xBF, // Texture Size Level 7
		TMAP			= 0xC0, // Texture Projection Map Mode + Texture Map Mode
		TEXTURE			= 0xC1, // Environment Map Matrix
		TMODE			= 0xC2, // Texture Mode
		TPSM			= 0xC3, // Texture Pixel Storage Mode
		CLOAD			= 0xC4, // CLUT Load
		CMODE			= 0xC5, // CLUT Mode
		TFLT			= 0xC6, // Texture Filter
		TWRAP			= 0xC7, // Texture Wrapping
		TBIAS			= 0xC8, // Texture Level Bias (???)
		TFUNC			= 0xC9, // Texture Function
		TEC				= 0xCA, // Texture Environment Color
		TFLUSH			= 0xCB, // Texture Flush
		TSYNC			= 0xCC, // Texture Sync
		FFAR			= 0xCD, // Fog Far (???)
		FDIST			= 0xCE, // Fog Range
		FCOL			= 0xCF, // Fog Color
		TSLOPE			= 0xD0, // Texture Slope
		Unknown0xD1		= 0xD1, // 
		PSM				= 0xD2, // Frame Buffer Pixel Storage Mode
		CLEAR			= 0xD3, // Clear Flags
		SCISSOR1		= 0xD4, // Scissor Region Start
		SCISSOR2		= 0xD5, // Scissor Region End
		NEARZ			= 0xD6, // Near Depth Range
		FARZ			= 0xD7, // Far Depth Range
		CTST			= 0xD8, // Color Test Function
		CREF			= 0xD9, // Color Reference
		CMSK			= 0xDA, // Color Mask
		ATST			= 0xDB, // Alpha Test
		STST			= 0xDC, // Stencil Test
		SOP				= 0xDD, // Stencil Operations
		ZTST			= 0xDE, // Depth Test Function
		ALPHA			= 0xDF, // Alpha Blend
		SFIX			= 0xE0, // Source Fix Color
		DFIX			= 0xE1, // Destination Fix Color
		DTH0			= 0xE2, // Dither Matrix Row 0
		DTH1			= 0xE3, // Dither Matrix Row 1
		DTH2			= 0xE4, // Dither Matrix Row 2
		DTH3			= 0xE5, // Dither Matrix Row 3
		LOP				= 0xE6, // Logical Operation
		ZMSK			= 0xE7, // Depth Mask
		PMSKC			= 0xE8, // Pixel Mask Color
		PMSKA			= 0xE9, // Pixel Mask Alpha
		TRXKICK			= 0xEA, // Transmission Kick
		TRXSPOS			= 0xEB, // Transfer Source Position
		TRXDPOS			= 0xEC, // Transfer Destination Position
		Unknown0xED		= 0xED, // 
		TRXSIZE			= 0xEE, // Transfer Size
		Unknown0xEF		= 0xEF, // 
		Unknown0xF0		= 0xF0, // 
		Unknown0xF1		= 0xF1, // 
		Unknown0xF2		= 0xF2, // 
		Unknown0xF3		= 0xF3, // 
		Unknown0xF4		= 0xF4, // 
		Unknown0xF5		= 0xF5, // 
		Unknown0xF6		= 0xF6, // 
		Unknown0xF7		= 0xF7, // 
		Unknown0xF8		= 0xF8, // 
		Unknown0xF9		= 0xF9, // 
		Unknown0xFA		= 0xFA, // 
		Unknown0xFB		= 0xFB, // 
		Unknown0xFC		= 0xFC, // 
		Unknown0xFD		= 0xFD, // 
		Unknown0xFE		= 0xFE, // 
		Unknown0xFF		= 0xFF, // 
	}

	static const uint[] TST_T      = [GL_NEVER, GL_ALWAYS, GL_EQUAL, GL_NOTEQUAL, GL_LESS, GL_LEQUAL, GL_GREATER, GL_GEQUAL];
	static const uint[] BLENDE_T   = [GL_FUNC_ADD, GL_FUNC_SUBTRACT, GL_FUNC_REVERSE_SUBTRACT, GL_MIN, GL_MAX, GL_FUNC_ADD ];
	static const uint[] BLENDF_T_S = [GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA ];
	static const uint[] BLENDF_T_D = [GL_DST_COLOR, GL_ONE_MINUS_DST_COLOR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA ];
	static const uint[] PRIM_T     = [GL_POINTS, GL_LINES, GL_LINE_STRIP, GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN ];
	static const uint[] TFLT_T     = [GL_NEAREST, GL_LINEAR, 0, 0, GL_NEAREST_MIPMAP_NEAREST, GL_LINEAR_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR, GL_LINEAR_MIPMAP_LINEAR];
	static const uint[] TFUNC_T    = [GL_MODULATE, GL_DECAL, GL_BLEND, GL_REPLACE, GL_ADD];					
	static const uint[] DTYPE_T    = [0, GL_BYTE, GL_SHORT, GL_FLOAT];
	static const uint[] INDEXT_T   = [0, GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT, GL_UNSIGNED_INT];
	static const uint[] SIZE_T     = [0, GL_BYTE, GL_SHORT, GL_FLOAT];
	static const uint[] SSIZE_T    = [0, 1, 2, 4];
	static const uint[] LOGICOP_T  = [GL_CLEAR, GL_AND, GL_AND_REVERSE, GL_COPY, GL_AND_INVERTED, GL_NOOP, GL_XOR, GL_OR, GL_NOR, GL_EQUIV, GL_INVERT, GL_OR_REVERSE, GL_COPY_INVERTED, GL_OR_INVERTED, GL_NAND, GL_SET];
	static const uint[] STENOP_T   = [GL_KEEP, GL_ZERO, GL_REPLACE, GL_INVERT, GL_INCR, GL_DECR];

	struct PixelFormat {
		float size;
		uint internal;
		uint external;
		uint opengl;
	}
	
	static PixelFormat[] PIXELF_T = [
		PixelFormat(  2, 3, GL_RGB,  GL_UNSIGNED_SHORT_5_6_5_REV),
		PixelFormat(  2, 4, GL_RGBA, GL_UNSIGNED_SHORT_1_5_5_5_REV),
		PixelFormat(  2, 4, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4_REV),
		PixelFormat(  4, 4, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV),
		PixelFormat(0.5, 1, GL_RED,  GL_UNSIGNED_BYTE),
		PixelFormat(  1, 1, GL_RED,  GL_UNSIGNED_BYTE),
		PixelFormat(  2, 4, GL_RGBA, GL_UNSIGNED_SHORT),
		PixelFormat(  4, 4, GL_RGBA, GL_UNSIGNED_INT),
		PixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT1_EXT),
		PixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT3_EXT),
		PixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT5_EXT),
	];
	
	struct Texture {
		uint ptr; uint lwidth;
		int width, height;
		int format;
		double psize() { return cast(double)PIXELF_T[format].size; }
		int tsize() { return cast(int)(psize * width * height); }
		int rwidth() { return cast(int)(PIXELF_T[format].size * width); }
		ubyte[] data;
		
		void dump() {
			writefln("TEXTURE {");
			writefln("  ptr   : %08X", ptr);
			writefln("  lwidth: %08X", lwidth);
			writefln("  width : %08X", width);
			writefln("  height: %08X", height);
			writefln("  format: %08X", format);
			writefln("}");
		}
	}
	
	class ScreenBuffer {
		public int width = 512;
		public int format = 3;

		int _ptr = 0;
		
		int ptr(int addr) { return _ptr = 0x04000000 | addr;}
		int ptr() { return 0x04000000 | _ptr; }
		int formatGl() { return PIXELF_T[format].opengl; }
		float psize() { return PIXELF_T[format].size; }
		
		void* pptr() { return mem.gptr(ptr); }
	}

	/*static uint c5_6_5(inout void* ptr) {
		scope (exit) ptr += 2;
		ushort d = *cast(ushort*)ptr;
		return 0xFF000000;
	}*/
	
	static uint c8_8_8_8(inout void* ptr) { scope (exit) ptr += 4; return *cast(uint*)ptr; }
	
	alias uint function(inout void*) ColorConverter;
	static ColorConverter[] colorConverters = [null, null, null, &c8_8_8_8];
	
	class Clut {
		uint ptr;
		void* mptr;
		int blocks;
		int blockSize;
		int count;
		int format;
		int shift;
		int mask;
		int start;
		uint[0x100] colors;
		
		uint glTexId;
		
		void dump() {
			writefln("CLUT {");
			writefln("  ptr    : %08X", ptr);
			writefln("  format : %08X", format);
			writefln("  blocks : %08X", blocks);
			writefln("}");
		}
		
		void init() {
			glGenTextures(1, &glTexId);
			version (gpu_use_shaders) {
				gla_clut.set(3);
			}
		}
		
		void update() {
			ColorConverter convert = colorConverters[format];
			void* cptr = mptr;
			for (int n = 0; n < count; n++) colors[n] = convert(cptr);

			glActiveTexture(GL_TEXTURE3);
			glBindTexture(GL_TEXTURE_1D, glTexId);
			
			glTexImage1D(
				GL_TEXTURE_1D,
				0,
				4,
				256,
				0,
				GL_RGBA,
				GL_UNSIGNED_INT_8_8_8_8_REV,
				colors.ptr
			);

			glEnableDisable(GL_CLAMP_TO_EDGE, 1);
			glTexParameterf(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			glTexParameterf(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			
			//debug (gpu_debug_clut_dump) write("clut.dump", cast(ubyte[])colors);
			
			debug (gpu_debug_clut) writefln("clut:%d", glTexId);
		}
	}

	struct UV {
		float u, v;
	}
	
	struct VertexState {
		float[8] boneWeights;
		float r, g, b, a;
		float px, py, pz;	
		float nx, ny, nz;	
		float u, v;
	}
	
	struct VertexInfo {
		int transform2D;
		int skinningWeightCount;
		int morphingVertexCount;
		int texture;
		int color;
		int normal;
		int position;
		int weight;
		int index;
		
		int ptr_vertex;
		int ptr_index;
	}
	
	struct Light {
		enum Type {
			GU_DIRECTIONAL,
			GU_POINTLIGHT,
			GU_SPOTLIGHT,
		}
		
		bool enabled;
		Type type;
		ubyte kind;
		
		// Position/Direction
		float[4] pos;
		float[4] dir;
		
		// Colors
		float[4] ambient  = [0, 0, 0, 0]; // Ambient color
		float[4] diffuse  = [0, 0, 0, 0]; // Diffuse color
		float[4] specular = [0, 0, 0, 0]; // Specular color
		
		// Attenuation
		float    constant  = 1; // Constant attenuation
		float    linear    = 0; // Linear attenuation
		float    quadratic = 0; // Quadratic attenuation
		
		float    exponent =   0; // Light exponent
		float    cutoff   = 180; // Light cutoff	
	}
	
	Light[4] lights;
	bool LightsEnabled;
	float light_specular_power;
	float[4] AmbientMaterial;
	float[4] DiffuseMaterial;
	float[4] ColorMaterial;
	float[4] SpecularMaterial;
	float[4] AmbientLight;
	
	struct Scissor {
		int x1, y1;
		int x2, y2;
		
		bool isFull() { return (x1 <= 0) && (y1 <= 0) && (x2 >= 480) && (y2 >= 272); }
	}
	
	Scissor scissor;
	Clut clut;
	ScreenBuffer drawBuffer, displayBuffer;
	Texture[8] textures;
	
	float[16    ] matrix_Model;
	float[16    ] matrix_World;
	float[16    ] matrix_Projection;
	float[16    ] matrix_Texture;
	float[16 * 8] matrix_Bones;
	int matrix_BonesOffset;
	float[8     ] morphWeights;
	
	UV textureScale  = UV(1, 1);
	UV textureOffset = UV(0, 0);

	float matrixTemp[16];
	
	VertexInfo vinfo;
	
	int textureFormat;
	int textureSwizzled;
	int textureFilterMin, textureFilterMag;
	int textureWrapS, textureWrapT;
	int textureEnabled;
	int textureEnvMode;
	int mipMapLevel;
	
	int clearFlags;

	float fogStart, fogDepth, fogEnd;
	
	void reset() {
		foreach (ptr; textures_gl.keys) {
			glDeleteTextures(1, &textures_gl[ptr].id);
			textures_gl.remove(ptr);
		}
		
		if (glActiveTexture) {
			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, 0);
		}
		
		initShadersVariables();
	}

	static void glEnableDisable(int type, int enable) {
		if (enable) glEnable(type); else glDisable(type);
	}

	static void glEnableDisableClientState(int type, int enable) {
		if (enable) glEnableClientState(type); else glDisableClientState(type);
	}
	
	void DumpMatrix(float* matrix) {
		writefln("MATRIX{");
		for (int y = 0, n = 0; y < 4; y++) {
			writef("  ");
			for (int x = 0; x < 4; x++, n++) writef("%f, ", matrix[n]);
			writefln();
		}
		writefln("}");			
	}
	
	void swapDrawRows() {
		int rowSize = cast(int)(drawBuffer.width * drawBuffer.psize);
		ubyte[] temp; temp.length = rowSize;
		ubyte* ptr1 = cast(ubyte*)drawBuffer.pptr;
		ubyte* ptr2 = ptr1 + (271 * rowSize);
		
		for (; ptr1 < ptr2; ptr1 += rowSize, ptr2 -= rowSize) {
			temp[0..rowSize] = ptr1[0..rowSize];
			ptr1[0..rowSize] = ptr2[0..rowSize];
			ptr2[0..rowSize] = temp[0..rowSize];
		}
	}
	
	// load back frame buffer from memory
	void loadFramebuffer() {
		ubyte* ptr = cast(ubyte*)drawBuffer.pptr;
		swapDrawRows();
		glDrawPixels(drawBuffer.width, 272, GL_RGBA, drawBuffer.formatGl, ptr);
	}

	// store frame buffer in memory
	void storeFramebuffer() {
		ubyte* ptr = cast(ubyte*)drawBuffer.pptr;
		glReadPixels(0, 0, drawBuffer.width, 272, GL_RGBA, drawBuffer.formatGl, ptr);
		swapDrawRows();
	}
	
	void unswizzle(inout Texture tex) {
		tex.data.length = tex.tsize;
		int rowWidth = tex.rwidth;
		int pitch = (rowWidth - 16) / 4;
		int bxc = rowWidth / 16;
		int byc = tex.height / 8;

		uint*  src = cast(uint*)mem.gptr(tex.ptr);
		
		//writefln("unswizzle: %08X", *src);
		
		ubyte* ydest = tex.data.ptr;
		for (int by = 0; by < byc; by++) {
			ubyte* xdest = ydest;
			for (int bx = 0; bx < bxc; bx++) {
				uint* dest = cast(uint*)xdest;
				for (int n = 0; n < 8; n++, dest += pitch) {
					*(dest++) = *(src++);
					*(dest++) = *(src++);
					*(dest++) = *(src++);
					*(dest++) = *(src++);
				}
				xdest += 16;
			}
			ydest += rowWidth * 8;
		}
	}	
	
	void convertColor(out float r, out float g, out float b, out float a, uint color) {
		switch (vinfo.color) {
			default:
				a = b = g = r = 0;
			break;
			/*case 4: // VTColorBGR5650
				a = 1.0f;
			break;
			case 5: // VTColorABGR5551
				r = cast(float)((color >>  0) & 0xFF) / 255.0f;
				g = cast(float)((color >>  1) & 0xFF) / 255.0f;
				b = cast(float)((color >>  8) & 0xFF) / 255.0f;
				a = cast(float)((color >> 12) & 0xFF) / 255.0f;
			break;*/
			case 6: // VTColorABGR4444
				r = cast(float)((color >>  0) & 0xF) / 255.0f;
				g = cast(float)((color >>  4) & 0xF) / 255.0f;
				b = cast(float)((color >>  8) & 0xF) / 255.0f;
				a = cast(float)((color >> 12) & 0xF) / 255.0f;
			break;
			case 7: // VTColorABGR8888
				r = cast(float)((color >>  0) & 0xFF) / 255.0f;
				g = cast(float)((color >>  8) & 0xFF) / 255.0f;
				b = cast(float)((color >> 16) & 0xFF) / 255.0f;
				a = cast(float)((color >> 24) & 0xFF) / 255.0f;
			break;
		}
		//a = 1.0f;
	}
	
	struct Texture_gl {
		uint id;
		int width, height;
	}
	
	Texture_gl[uint] textures_gl;
	
	void unsetTexture() {
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, 0);
	}
	
	void setTexture(int texN) {
		Texture tex = textures[texN & 0b111];
		
		glActiveTexture(GL_TEXTURE0);
		
		if (tex.ptr == 0) {
			glBindTexture(GL_TEXTURE_2D, 0);
			return;
		}
		
		if (!tex.data.length) {
			ubyte* ptr = cast(ubyte*)mem.gptr(tex.ptr);
			debug (gpu_debug_texture_dump) std.file.write(std.string.format("texture_%08X.dump", ptr), ptr[0..cast(int)(tex.tsize)]);
			if (textureSwizzled) {
				unswizzle(tex);
			} else {
				tex.data = (cast(ubyte*)mem.gptr(tex.ptr))[0..tex.data.length];
			}
		}
		
		uint genTexture(inout Texture tex) {
			uint glTexId;
			glGenTextures(1, &glTexId);
			glBindTexture(GL_TEXTURE_2D, glTexId);
			glPixelStorei(GL_UNPACK_ALIGNMENT, cast(int)PIXELF_T[tex.format].size);
			
			//ubyte* ptr = cast(ubyte*)mem.gptr(tex.ptr);
			ubyte* ptr = tex.data.ptr;
			ubyte* tptr = ptr;
			
			debug (gpu_debug_texture) {
				debug (gpu_debug_texture) writefln("TEXTURE(%d)", glTexId);
				debug (gpu_debug_texture) writefln("SIZE(%d,%d)", tex.width, tex.height);
				debug (gpu_debug_texture) writefln("FORMAT(%08X)", tex.format);
				ubyte *cptr = cast(ubyte*)ptr;
			}
			
			//debug (gpu_debug_texture_dump) std.file.write("texture.dump", ptr[0..cast(int)(tex.width * tex.height * PIXELF_T[tex.format].size)]);
			
			glTexImage2D(
				GL_TEXTURE_2D,
				0,
				PIXELF_T[tex.format].internal,
				tex.width,
				tex.height,
				0,
				PIXELF_T[tex.format].external,
				PIXELF_T[tex.format].opengl,
				tptr
			);
			
			return glTexId;
		}		

		if (!(tex.ptr in textures_gl)) {
			textures_gl[tex.ptr] = Texture_gl(genTexture(tex), tex.width, tex.height);
			debug (gpu_debug_texture) tex.dump();
		}
		
		glEnableDisable(GL_CLAMP_TO_EDGE, (textureWrapS == GL_CLAMP) || (textureWrapT == GL_CLAMP));
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, textureFilterMin);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, textureFilterMag);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, textureWrapS);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, textureWrapT);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, textureEnvMode);
		
		bool useClut = (tex.format >= 4) && (tex.format <= 5);

		version (gpu_use_shaders) {
			if (useClut) {
				glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
				glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			}
			
			gla_tex.set(0);
			gla_clutUse.set(useClut);
			
			debug (gpu_debug_clut) writefln("clutUse: %d", (tex.format >= 4) && (tex.format <= 5));		
		} else {
			if (useClut) {
				updateTextureClut(tex, clut);
			} else{
				glBindTexture(GL_TEXTURE_2D, textures_gl[tex.ptr].id);
			}
		}
	}
	
	void updateTextureClut(Texture tex, Clut clut, int block = 0) {
		if (tex.format < 4) return;

		uint[] data; data.length = tex.width * tex.height * 4;
		uint *cptr = data.ptr;
		uint[] colors = clut.colors;
		int s = tex.width * tex.height;
		
		//ubyte* ptr = cast(ubyte*)mem.gptr(tex.ptr);
		ubyte* ptr = tex.data.ptr;
		
		switch (tex.format) {
			case 4: // 4bpp
				throw(new Exception("Not implemented 4bpp"));
				while (s--) {
					ubyte c = *ptr;
					*cptr = colors[(c >> 0) & 0b1111]; cptr++;
					*cptr = colors[(c >> 4) & 0b1111]; cptr++;
					ptr++; 
				}
			break;
			case 5: // 8bpp
				while (s--) {
					*cptr = colors[*ptr]; cptr++;
					ptr++; 
				}
			break;
		}
		
		glTexImage2D(
			GL_TEXTURE_2D,
			0,
			4,
			tex.width,
			tex.height,
			0,
			GL_RGBA,
			GL_UNSIGNED_INT_8_8_8_8_REV,
			data.ptr
		);
	}
	
	void prepareDrawing() {
		if (vinfo.transform2D) {
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			glOrtho(0.0f, 480.0f, 272.0f, 0.0f, -1.0f, 1.0f);
			/*
			writefln("transform2d");
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			*/
		} else {
			version (gpu_use_shaders) {
				uploadMatrix_Projection();
				uploadMatrix_ModelView();
			} else {
				glMatrixMode(GL_PROJECTION);
				glLoadIdentity();
				glMultMatrixf(cast(float*)matrix_Projection);

				glMatrixMode(GL_MODELVIEW);
				glLoadIdentity();
				glMultMatrixf(cast(float*)matrix_Model);
				glMultMatrixf(cast(float*)matrix_World);
			}
		}
		
		glActiveTexture(GL_TEXTURE0);
		glMatrixMode(GL_TEXTURE);
		glLoadIdentity();
		
		//glScalef(0.01, 0.01, 1);
		//writefln("%d (%f,%f) (%d,%d)", vinfo.transform2D, textureScale.u, textureScale.v, textures[0].width, textures[0].height);
		
		if (vinfo.transform2D && (textureScale.u == 1 && textureScale.v == 1)) {
			glScalef(1.0f / textures[0].width, 1.0f / textures[0].height, 1);
		} else {
			glScalef(textureScale.u, textureScale.v, 1);
		}
		
		glTranslatef(textureOffset.u, textureOffset.v, 0);
		
		if (textureEnabled) setTexture(0); else unsetTexture();
		
		version (gpu_use_shaders) {
			gla_textureUse.set(textureEnabled);
		}
		
		glEnableDisable(GL_COLOR_ARRAY, vinfo.color);
		
		glColor4fv(AmbientMaterial.ptr);
		
		version (gpu_no_lighting) LightsEnabled = false;
		
		if (LightsEnabled) {
			//writefln("lights");
		
			// Ambient Material Color
			//glEnable(GL_COLOR_MATERIAL);
			//ColorMaterial
			
			glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, AmbientMaterial.ptr);
			glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, DiffuseMaterial.ptr);
			//glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, SpecularMaterial.ptr);
			//writefln("--------------------------- %f", light_specular_power);
			
			foreach (k, light; lights) {
				if (!light.enabled) continue;
				int lgl = GL_LIGHT0 + k;
				
				light.dir[3] = light.pos[3] = 0.0f;

				//writefln("Light%d", k);
				
				glLightfv(lgl, GL_POSITION, light.pos.ptr);
				glLightfv(lgl, GL_SPOT_DIRECTION, light.dir.ptr);
				
				glLightf (lgl, GL_CONSTANT_ATTENUATION, light.constant);
				glLightf (lgl, GL_LINEAR_ATTENUATION, light.linear);
				glLightf (lgl, GL_QUADRATIC_ATTENUATION, light.quadratic);

				glLightf (lgl, GL_SPOT_EXPONENT, light.exponent);
				glLightf (lgl, GL_SPOT_CUTOFF, light.cutoff);
				
				glLightfv(lgl, GL_SPECULAR, light.specular.ptr);
				glLightfv(lgl, GL_DIFFUSE, light.diffuse.ptr);
			}
		}
	}
	
	void ProcessList(inout DisplayList list) {
		scope (exit) {
			debug (gpu_debug_matrix) {
				writefln("}");
				writefln("GL_MODELVIEW_MATRIX");
				glGetFloatv(GL_MODELVIEW_MATRIX, cast(float *)matrixTemp);
				DumpMatrix(cast(float *)matrixTemp);
				writefln("GL_PROJECTION_MATRIX");
				glGetFloatv(GL_PROJECTION_MATRIX, cast(float *)matrixTemp);
				DumpMatrix(cast(float *)matrixTemp);
			}
		}

		debug (gpu_debug) {
			writefln();
			writefln();
			//writefln("ProcessList %08X", &list);
			writefln("------------------------------------------------------------------------------");
			writefln("ProcessList 0x%08X", list.StartAddress);
		}
		
		void execute() {
			debug (gpu_debug) writefln("EXECUTE {");
			
			while (true) {
				uint packet = *list.Packets; list.Packets++;
				VC   command = cast(VC)((packet >> 24) & 0x_00_00_00_FF);
				uint param   = (packet >>  0) & 0x_00_FF_FF_FF;
				float[] param4f() { return [((param >>  0) & 0xFF) / 255.0f, ((param >>  8) & 0xFF) / 255.0f, ((param >> 16) & 0xFF) / 255.0f, 1.0]; }
				float paramf() { return I_F(param << 8); }
				bool paramb() { return (param != 0); }
				
				debug (gpu_debug) writefln("  %s: %06X", GPU_Disasm.disasm(list.Packets - 1), param);
				
				switch (command) {
					// ------------------
					//  SPECIAL COMMANDS
					// ------------------
				
					case VC.BASE: list.Base = (param << 8); continue; // Address translation
					case VC.JUMP: list.Packets = cast(uint *)mem.gptr((param | list.Base) & (~0b11)); continue; // JUMP
					case VC.CALL: list.Stack[list.StackIndex++] = list.Packets; list.Packets = cast(uint *)mem.gptr((param | list.Base) & (~0b11)); continue; // Sublists
					case VC.RET: list.Packets = list.Stack[--list.StackIndex]; continue;
					case VC.SIGNAL: continue;
					case VC.FINISH: case VC.Unknown0x11: list.Drawn = true; continue;
					case VC.END: if (list.Drawn) { list.Done = true; mem.interrupts.queue(INTS.GE); } return;

					// ------------------
					//  GRAPHIC COMMANDS
					// ------------------

					case VC.CLEAR: { // glClear
						if (!(param & 0x1)) {
							glClear(clearFlags);
						} else {
							clearFlags = 0;
							if (param & 0x100) clearFlags |= GL_COLOR_BUFFER_BIT; // target
							if (param & 0x200) clearFlags |= GL_ACCUM_BUFFER_BIT | GL_STENCIL_BUFFER_BIT; // stencil/alpha
							if (param & 0x400) clearFlags |= GL_DEPTH_BUFFER_BIT; // zbuffer
						}
					} continue;
					case VC.SHADE: glShadeModel(param ? GL_SMOOTH : GL_FLAT); continue; // glShadeModel
					case VC.FFACE: glFrontFace(param ? GL_CW : GL_CCW); continue; // glFrontFace
					case VC.VADDR: vinfo.ptr_vertex = list.Base | param; continue; // Vertex list ADDRess (Base)
					case VC.IADDR: vinfo.ptr_index = list.Base | param; continue; // Index list ADDRess (Base)
					case VC.VTYPE:
						vinfo.texture             = (param >>  0) & 0b11;
						vinfo.color               = (param >>  2) & 0b111;
						vinfo.normal              = (param >>  5) & 0b11;
						vinfo.position            = (param >>  7) & 0b11;
						vinfo.weight              = (param >>  9) & 0b11;
						vinfo.index               = (param >> 11) & 0b11;
						vinfo.skinningWeightCount = ((param >> 14) & 0b111) + 1;
						vinfo.morphingVertexCount = (param >> 18) & 0b11;
						vinfo.transform2D         = (param >> 23) & 0b1;
						//writefln("skinningWeightCount: %d", vinfo.skinningWeightCount);
					break;
					//case VC.OFFSETADDR: break;
					//case VC.REGION1: break;
					//case VC.REGION2: break;
					case VC.LOP: glLogicOp(LOGICOP_T[param]); break; // Logical OPeration
					
					// -------------------
					//  ENABLE ATTRIBUTES
					// -------------------
					
					//case VC.CPE: glEnableDisable(GL_CLIP_PLANE0, param); break; // Clip Plane Enable
					case VC.BCE: glEnableDisable(GL_CULL_FACE, param); break; // Backface Culling Enable
					case VC.ABE: glEnableDisable(GL_BLEND, param); break; // Alpha Blend Enable
					case VC.ZTE: glEnableDisable(GL_DEPTH_TEST, param); break; // depth (Z) Test Enable
					case VC.STE: glEnableDisable(GL_STENCIL_TEST, param); break; // Stencil Test Enable
					case VC.LOE: glEnableDisable(GL_COLOR_LOGIC_OP, param); break; // Logical Operation Enable
					case VC.TME: glEnableDisable(GL_TEXTURE_2D, textureEnabled = param); break; // Texture Mapping Enable
					case VC.ATE: glEnableDisable(GL_ALPHA_TEST, param); glAlphaFunc(GL_GREATER, 0.03f); break; // Alpha Test Enable
					case VC.ZMSK: glDepthMask(!paramb); break;
					case VC.ALPHA: {
						debug (gpu_debug_verbose) writefln("VC.ALPHA[1]");
						if (&glBlendEquation !is null) glBlendEquation(BLENDE_T[(param >> 8) & 0x03]);

						debug (gpu_debug_verbose) writefln("VC.ALPHA[2]");
						if (&glBlendFunc !is null) {
							glBlendFunc(
								BLENDF_T_S[(param >> 0) & 0xF],
								BLENDF_T_S[(param >> 4) & 0xF]
							);
						}
						debug (gpu_debug_verbose) writefln("VC.ALPHA[3]");
					} break;
					case VC.FGE: // FoG Enable
						glEnableDisable(GL_FOG, param);
						if (!param) break;
						glFogi(GL_FOG_MODE, GL_LINEAR);
						glFogf(GL_FOG_DENSITY, 0.1f);
						glHint(GL_FOG_HINT, GL_DONT_CARE);
					break;
					//case VC.DTE: break; // DiTher Enable
					//case VC.AAE: break; // AnitAliasing Enable
					//case VC.PCE: break; // Patch Cull Enable					
					//case VC.CTE: break; // Color Test Enable					
					
					// ------------------
					//  MORPHING
					// ------------------
					
					case VC.MW0: case VC.MW1: case VC.MW2: case VC.MW3: case VC.MW4: case VC.MW5: case VC.MW6: case VC.MW7: morphWeights[command - VC.MW0] = paramf; break; // Morph Weight N

					// ------------------
					//  PATCHES
					// ------------------
					
					//case VC.PSUB: /*context.PatchDivS = (param >> 0) & 0xFF; context.PatchDivT = (param >> 8) & 0xFF;*/ break;
					//case VC.PPRIM: break;
					//case VC.PFACE: /*context.PatchFrontFace = (param & 0x1);*/ break; // 0 = clockwise | 1 = counter clockwise
					//case VC.ZPOS: break; // depth (Z) POSition
					
					// ------------------
					//  TEXTURE MAPPING
					// ------------------
					
					case VC.USCALE : textureScale.u  = paramf; break;
					case VC.VSCALE : textureScale.v  = paramf; break;
					case VC.UOFFSET: textureOffset.u = paramf; break;
					case VC.VOFFSET: textureOffset.v = paramf; break;
					//case VC.OFFSETX: break;
					//case VC.OFFSETY: break;
					
					// ------------------
					//  LIGHTING
					// ------------------

					case VC.LTE: LightsEnabled = paramb; glEnableDisable(GL_LIGHTING, param); break; // Light Enable
					case VC.LTE0: case VC.LTE1: case VC.LTE2: case VC.LTE3: lights[command - VC.LTE0].enabled = paramb; glEnableDisable(GL_LIGHT0 + (command - VC.LTE0), param); break; // Light Enable N
					
					//case VC.RNORM: break;
					case VC.CMAT: ColorMaterial[0..4] = param4f[0..4]; break; // Color Material
					//case VC.EMC: break; // Emissive material Color
					case VC.AMC: AmbientMaterial[0..3] = param4f[0..3]; break; // Ambient Material Color
					case VC.AMA: AmbientMaterial[3] = param4f[0]; break; // Ambient Material Alpha
					
					case VC.DMC: DiffuseMaterial[0..4] = param4f[0..4]; break; // Diffuse material Color
					case VC.SMC: SpecularMaterial[0..4] = param4f[0..4]; break; // Specular material Color
					
					case VC.SPOW: light_specular_power = paramf; break; // Specular POWer
					
					case VC.ALC: AmbientLight[0..3] = param4f[0..3]; break; // Ambient Light Color
					case VC.ALA: AmbientLight[3] = param4f[0]; break; // Ambient Light Alpha
					
					//case VC.LMODE: break;
					case VC.LT0: case VC.LT1: case VC.LT2: case VC.LT3:
						lights[command - VC.LXP0].type = cast(Light.Type)((param >> 8) & 0b11);
						lights[command - VC.LXP0].kind = cast(Light.Type)((param >> 0) & 0b11);
					break;
					case VC.LXP0: case VC.LXP1: case VC.LXP2: case VC.LXP3: lights[command - VC.LXP0].pos[0] = paramf; break; // Light X Position N
					case VC.LYP0: case VC.LYP1: case VC.LYP2: case VC.LYP3: lights[command - VC.LYP0].pos[1] = paramf; break; // Light Y Position N
					case VC.LZP0: case VC.LZP1: case VC.LZP2: case VC.LZP3: lights[command - VC.LZP0].pos[2] = paramf; break; // Light Z Position N
					case VC.LXD0: case VC.LXD1: case VC.LXD2: case VC.LXD3: lights[command - VC.LXD0].dir[0] = paramf; break; // Light X Direction N
					case VC.LYD0: case VC.LYD1: case VC.LYD2: case VC.LYD3: lights[command - VC.LYD0].dir[1] = paramf; break; // Light Y Direction N
					case VC.LZD0: case VC.LZD1: case VC.LZD2: case VC.LZD3: lights[command - VC.LZD0].dir[2] = paramf; break; // Light Z Direction N
					case VC.SLC0: case VC.SLC1: case VC.SLC2: case VC.SLC3: lights[command - VC.SLC0].specular[0..4] = param4f; break; // Specular Light Color N
					case VC.DLC0: case VC.DLC1: case VC.DLC2: case VC.DLC3: lights[command - VC.DLC0].diffuse[0..4]  = param4f; break; // Diffuse Light Color N
					case VC.LCA0: case VC.LCA1: case VC.LCA2: case VC.LCA3: lights[command - VC.LCA0].constant  = paramf; break; // Light Constant Attenuation N
					case VC.LLA0: case VC.LLA1: case VC.LLA2: case VC.LLA3: lights[command - VC.LLA0].linear    = paramf; break; // Light Linear Attenuation N
					case VC.LQA0: case VC.LQA1: case VC.LQA2: case VC.LQA3: lights[command - VC.LQA0].quadratic = paramf; break; // Light Linear Attenuation N
					
					// ------------------
					//  FRAME BUFFER
					// ------------------
					
					case VC.FBP: drawBuffer.ptr = param; break; // Frame Buffer Pointer						
					case VC.FBW: drawBuffer.width = param & 0xFFFF; loadFramebuffer(); break; // Fame Buffer Width
					case VC.PSM: drawBuffer.format = param; break; // texture Pixel Storage Mode

					// ------------------
					//  STENCIL
					// ------------------
					
					case VC.STST: // Stencil TeST
						glStencilFunc(
							TST_T[((param >>  0) & 0xFF)],
							((param >>  8) & 0xFF),
							((param >> 16) & 0xFF)
						);
					break;
					case VC.SOP: // Stencil OPeration
						glStencilOp(
							STENOP_T[((param >>  0) & 0xFF)],
							STENOP_T[((param >>  8) & 0xFF)],
							STENOP_T[((param >> 16) & 0xFF)]
						);
					break;

					// ------------------
					//  FOG
					// ------------------
					
					case VC.FCOL: { // Fog COLor
						float[4] color4;
						color4[0] = cast(float)((param >>  0) & 0xFF) / 255.0f;
						color4[1] = cast(float)((param >>  8) & 0xFF) / 255.0f;
						color4[2] = cast(float)((param >> 16) & 0xFF) / 255.0f;
						color4[3] = 1.0f;
						glFogfv(GL_FOG_COLOR, cast(float*)color4);
					} break;
					case VC.FFAR: // Fog FAR
						fogEnd = I_F(packet << 8);;
					break;
					case VC.FDIST: // Fog DIStance
						fogDepth = I_F(packet << 8);

						// We get f precalculated, so need to derive start
						if (fogEnd != 0.0 && fogDepth != 0.0) {
							fogStart = fogEnd - (1 / fogDepth);
							glFogf(GL_FOG_START, fogStart);
							glFogf(GL_FOG_END  , fogEnd  );
						}
					break;

					// ------------------
					//  TEXTURES
					// ------------------
					
					case VC.TPSM: textureFormat = param; break; // Texture Pixel Storage Mode
					case VC.TMODE:
						textureSwizzled  = (param >>  0) & 0x1;
						mipMapLevel      = (param >> 16) & 0x4;
					break;
					case VC.TBP0: case VC.TBP1: case VC.TBP2: case VC.TBP3: case VC.TBP4: case VC.TBP5: case VC.TBP6: case VC.TBP7: // Texture Buffer Pointer N
						int N = command - VC.TBP0;
						textures[N].ptr &= 0xFF000000;
						textures[N].ptr |= param;
					break;
					case VC.TBW0: case VC.TBW1: case VC.TBW2: case VC.TBW3: case VC.TBW4: case VC.TBW5: case VC.TBW6: case VC.TBW7: // Texture Buffer Width N
						int N = command - VC.TBW0;
						textures[N].lwidth = param & 0x00FFFFFF;
						textures[N].ptr &= 0x00FFFFFF;
						textures[N].ptr |= (param << 8) & 0xFF000000;
					break;
					case VC.TSIZE0: case VC.TSIZE1: case VC.TSIZE2: case VC.TSIZE3: case VC.TSIZE4: case VC.TSIZE5: case VC.TSIZE6: case VC.TSIZE7: // Texture SIZE N
						int N = command - VC.TSIZE0;
						textures[N].width  = 1 << ((param >> 0) & 0xFF);
						textures[N].height = 1 << ((param >> 8) & 0xFF);
						textures[N].format = textureFormat;
					break;
					case VC.TFLUSH: /*gla_textureUse.set(0);*/ break; // Texture Flush
					//case VC.TSYNC: /*SetTexture( context, 0 );*/ break; // Texture SYNcronize
					break;
					case VC.TFLT: // Texture FiLTer
						textureFilterMin = TFLT_T[((param >> 0) & 0x7) & 0x1]; // only GL_NEAREST, GL_LINEAR (no mipmaps) (& 0x1)
						textureFilterMag = TFLT_T[((param >> 8) & 0x7) & 0x1]; // only GL_NEAREST, GL_LINEAR (no mipmaps) (& 0x1)
					break;
					case VC.TWRAP:
						textureWrapS = TFLT_T[(param >> 0) & 0xFF];
						textureWrapT = TFLT_T[(param >> 8) & 0xFF];
					break;
					case VC.TFUNC: textureEnvMode = TFUNC_T[param & 0x07]; break;
					case VC.TEC:
						float[4] color4;
						color4[0] = cast(float)((param >> 16) & 0xFF) / 255.0f;
						color4[1] = cast(float)((param >>  8) & 0xFF) / 255.0f;
						color4[2] = cast(float)((param >>  0) & 0xFF) / 255.0f;
						color4[3] = 1.0f;
						glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, cast(float*)color4);
					break;
					
					// ------------------
					//  CLUT
					// ------------------
					
					case VC.CBP : clut.ptr = (clut.ptr & 0xFF000000) | (param << 0); break;
					case VC.CBPH: clut.ptr = (clut.ptr & 0x00FFFFFF) | (param << 8); break;
					case VC.CLOAD:
						if (clut.ptr) {
							clut.mptr = mem.gptr(clut.ptr);
							clut.blocks = param;
							clut.blockSize = ((clut.format == 3) ? 8 : 16);
							clut.count  = param * clut.blockSize;
							clut.update();
						}
						debug (gpu_debug_clut) clut.dump;
					break;
					case VC.CMODE:
						clut.format = ((param >>  0) & 0x03) << 0;
						clut.shift  = ((param >>  2) & 0x1F) << 0;
						clut.mask   = ((param >>  8) & 0xFF) << 0;
						clut.start  = ((param >> 16) & 0x1F) << 4;
					break;		

					// ----------------
					//  SCISSORS
					// ----------------
				
					case VC.SCISSOR1:	// SCISSOR start (1)
						scissor.x1 = (param >>  0) & 0x3FF;
						scissor.y1 = (param >> 10) & 0x3FF;
					break;
					case VC.SCISSOR2:	// SCISSOR end (2)
						scissor.x2 = ((param >>  0) & 0x3FF) + 1;
						scissor.y2 = ((param >> 10) & 0x3FF) + 1;
						
						if (scissor.isFull) { glDisable(GL_SCISSOR_TEST); break; }
						
						glEnable(GL_SCISSOR_TEST);
						glScissor(
							scissor.x1,
							272 - scissor.y2,
							scissor.x2 - scissor.x1,
							scissor.y2 - scissor.y1
						);
					break;
				
					// ----------------
					//  MATRIX LOADING
					// ----------------
					
					case VC.WMS: // World Matrix Select
						//float* matrix = cast(float *)matrixTemp;
						float* matrix = cast(float *)matrix_World;
					
						for (int y = 0; y < 4; y++) {
							for (int x = 0; x < 3; x++) {
								packet = *list.Packets; list.Packets++;
								*matrix = I_F(packet << 8);
								matrix++;
							}
							*matrix = ((y == 3) ? 1.0f : 0.0f); matrix++;
						}
						
						debug (gpu_debug_matrix) DumpMatrix(cast(float*)matrix_World);
						
						version (gpu_use_shaders) uploadMatrix_World();
					break;
					case VC.VMS: // View Matrix Select
						float* matrix = cast(float *)matrix_Model;
					
						for (int y = 0; y < 4; y++) {
							for (int x = 0; x < 3; x++) {
								packet = *list.Packets; list.Packets++;
								*matrix = I_F(packet << 8);
								matrix++;
							}
							*matrix = ((y == 3) ? 1.0f : 0.0f); matrix++;
						}
						
						debug (gpu_debug_matrix) DumpMatrix(cast(float*)matrix_Model);
						
						version (gpu_use_shaders) uploadMatrix_ModelView();
					break;
					case VC.PMS: // Projection Matrix Select
						float* matrix = cast(float *)matrix_Projection;
					
						for (int y = 0; y < 4; y++) {
							for (int x = 0; x < 4; x++) {
								packet = *list.Packets; list.Packets++;
								*matrix = I_F(packet << 8);
								matrix++;
							}
						}
						
						debug (gpu_debug_matrix) DumpMatrix(cast(float*)matrix_Projection);
						
						version (gpu_use_shaders) uploadMatrix_Projection();
					break;
					/*case VC.TMS: // Texture Matrix Select
						float* matrix = cast(float *)matrix_Texture;
					
						for (int y = 0; y < 4; y++) {
							for (int x = 0; x < 3; x++) {
								packet = *list.Packets; list.Packets++;
								*matrix = I_F(packet << 8);
								matrix++;
							}
							*matrix = ((y == 3) ? 1.0f : 0.0f); matrix++;
						}
						
						debug (gpu_debug_matrix) DumpMatrix(cast(float*)matrix_Texture);
						// TODO
					break;*/
					case VC.BOFS: // Bone OFfSet and upload
						int matId = (param / 12);
						float* matrix = (cast(float *)matrix_Bones) + matId * 16;
					
						for (int y = 0; y < 4; y++) {
							for (int x = 0; x < 3; x++) {
								packet = *list.Packets; list.Packets++;
								*matrix = I_F(packet << 8);
								matrix++;
							}
							*matrix = ((y == 3) ? 1.0f : 0.0f); matrix++;
						}
						
						debug (gpu_debug_matrix) DumpMatrix(cast(float*)matrix_Bones);
						
						//DumpMatrix((cast(float*)matrix_Bones) + matId * 16);
						
						version (gpu_use_shaders) {
							gla_BoneMatrix[matId].setMatrix4((cast(float*)matrix_Bones) + matId * 16);
						}
					break;
					
					// ------------------
					//  DRAWING
					// ------------------
					
					case VC.PRIM: {
						int vertexCount = param & 0xFFFF;
						int primitiveType = (param >> 16) & 0b111;

						ubyte* ptr_base = cast(ubyte *)mem.gptr(vinfo.ptr_vertex);
						ubyte* ptr = void;
						ubyte* idx_base = vinfo.ptr_index ? cast(ubyte *)mem.gptr(vinfo.ptr_index) : null;
						ubyte* idx = idx_base;
						
						int vertex_size = 0;
						int vinfo_weight_s   = SSIZE_T[vinfo.weight] * vinfo.skinningWeightCount;
						int vinfo_color_s = vinfo.color ? ((vinfo.color == 7) ? 4 : 2) : 0;
						int vinfo_texture_s  = SSIZE_T[vinfo.texture] * 2;
						int vinfo_position_s = SSIZE_T[vinfo.position] * 3;
						int vinfo_normal_s   = SSIZE_T[vinfo.normal] * 3;
						vertex_size += vinfo_weight_s;
						vertex_size += vinfo_texture_s;
						vertex_size += vinfo_color_s;
						vertex_size += vinfo_position_s;
						vertex_size += vinfo_normal_s;
						
						//writefln("##### vertex_size: %d", vertex_size);
						
						void setIndex(int index) {
							//index /= 2;
							debug (gpu_debug_vertex) writefln("Index: %d", index);
							ptr = ptr_base + (index * vertex_size);
						}
						
						setIndex(0);
						
						void moveIndex() {
							if (!vinfo.index) return;
							
							switch (vinfo.index) {
								case 1: setIndex(*(cast(ubyte*)idx)); idx++; break;
								case 2: setIndex(*(cast(ushort*)idx)); idx += 2; break;
								case 3: setIndex(*(cast(uint*)idx)); idx += 4; break;
							}							
						}
						
						float extractFloat()   { scope (exit) { ptr += 4; } return *cast(float *)ptr; }
						uint  extractWord()    { scope (exit) { ptr += 4; } return *cast(uint *) ptr; }
						short extractFixed16() { scope (exit) { ptr += 2; } return *cast(short *)ptr; }
						byte  extractFixed8()  { scope (exit) { ptr += 1; } return *cast(byte *) ptr; }
						void  extractFloat1(int size, out float v1)  {
							switch (size) {
								default: break; // NONE
								case 1: v1 = extractFixed8();  break; // FIXED8
								case 2: v1 = extractFixed16(); break; // FIXED16
								case 3: v1 = extractFloat();   break; // FLOAT
							}
						}
						void  extractFloat2(int size, out float v1, out float v2)  {
							switch (size) {
								default: break; // NONE
								case 1: v1 = extractFixed8();  v2 = extractFixed8(); break; // FIXED8
								case 2: v1 = extractFixed16(); v2 = extractFixed16(); break; // FIXED16
								case 3: v1 = extractFloat();   v2 = extractFloat(); break; // FLOAT
							}
						}
						void  extractFloat3(int size, out float v1, out float v2, out float v3)  {
							switch (size) {
								default: break; // NONE
								case 1: v1 = extractFixed8();  v2 = extractFixed8();  v3 = extractFixed8(); // FIXED8
								case 2: v1 = extractFixed16(); v2 = extractFixed16(); v3 = extractFixed16(); break; // FIXED16
								case 3: v1 = extractFloat();   v2 = extractFloat();   v3 = extractFloat(); break; // FLOAT
							}
						}
						void extractColorType(int type, out float r, out float g, out float b, out float a) {
							switch (type) {
								default: break;
								case 1: case 2: case 3: convertColor(r, g, b, a, extractFixed8()); break;
								case 4: case 5: case 6: convertColor(r, g, b, a, extractFixed16()); break;
								case 7: convertColor(r, g, b, a, extractWord()); break;
							}
							//r = 1.0f;
							//g = 1.0f;
							//b = 1.0f;
							//a = 1.0f;
						}
						void  extractFloatN(int len, int size, float* v)  {
							switch (size) {
								default: break; // NONE
								case 1: for (int n = 0; n < len; n++) v[n] = extractFixed8();  break; // FIXED8
								case 2: for (int n = 0; n < len; n++) v[n] = extractFixed16(); break; // FIXED16
								case 3: for (int n = 0; n < len; n++) v[n] = extractFloat();   break; // FLOAT
							}
						}
						void extractPosition(inout VertexState cvs, int size) { extractFloatN(3, size, &cvs.px); }
						void extractNormal(inout VertexState cvs, int size) { extractFloatN(3, size, &cvs.nx); }
						void extractUV(inout VertexState cvs, int size) { extractFloatN(2, size, &cvs.u); }
						void extractColor(inout VertexState cvs, int type) { extractColorType(type, cvs.r, cvs.g, cvs.b, cvs.a); }
						void extractVertex(inout VertexState cvs) {
							moveIndex();
						
							debug (gpu_debug_vertex) writefln("  VERTEX (%d) {", vertexCount);
							
							if (vinfo.weight) {
								for (int n = 0; n < vinfo.skinningWeightCount; n++) {
									extractFloat1(vinfo.weight, cvs.boneWeights[n]);
									debug (gpu_debug_vertex) writefln("    WH%d (%f)", n, cvs.boneWeights[n]);
								}
							}
							
							if (vinfo.texture) {
								extractUV(cvs, vinfo.texture);
								debug (gpu_debug_vertex) writefln("    U_V (%f, %f)", cvs.u, cvs.v);
							}
							
							if (vinfo.color) {
								extractColor(cvs, vinfo.color);
								debug (gpu_debug_vertex) writefln("    COL (%f, %f, %f, %f)", cvs.r, cvs.g, cvs.b, cvs.a);
							}
							
							if (vinfo.normal) {
								extractNormal(cvs, vinfo.normal);
								debug (gpu_debug_vertex) writefln("    NOR (%f, %f, %f)", cvs.nx, cvs.ny, cvs.nz);
							}
							
							if (vinfo.position) {
								extractPosition(cvs, vinfo.position);
								debug (gpu_debug_vertex) writefln("    POS (%f, %f, %f)", cvs.px, cvs.py, cvs.pz);
							}
							
							debug (gpu_debug_vertex) writefln("  }");
							
							vertexCount--;
						}
						
						prepareDrawing();
						
						debug (gpu_debug_vertex) writefln("PRIM (%d: %d) {", primitiveType, vertexCount);
						
						if (primitiveType == 6) {
							//glPushAttrib(GL_ALL_ATTRIB_BITS);
							glPushAttrib(GL_CULL_FACE);

							glDisable(GL_CULL_FACE);
							
							glBegin(GL_QUADS);
							while (vertexCount) {
								debug (gpu_debug_vertex) writefln(" SPRITE {");
							
								VertexState v1, v2;
								extractVertex(v1);
								extractVertex(v2);
								
								version (gpu_use_shaders) {
									gla_spriteCenter.set(
										(v1.px + v2.px) / 2,
										(v1.py + v2.py) / 2,
										(v1.pz + v2.pz) / 2,
										1
									);
								}
									
								// V1
								if (vinfo.normal  ) glNormal3f(v1.nx, v1.ny, v1.nz);
								if (vinfo.color   ) glColor4f(v1.r, v1.g, v1.b, v1.a);

								version (gpu_use_shaders) gla_spriteCorner.set(1);
								if (vinfo.texture ) glTexCoord2f(v1.u, v1.v);
								if (vinfo.position) glVertex3f(v1.px, v1.py, v1.pz);

								version (gpu_use_shaders) gla_spriteCorner.set(2);
								if (vinfo.texture ) glTexCoord2f(v2.u, v1.v);
								if (vinfo.position) glVertex3f(v2.px, v1.py, v1.pz);

								// V2
								if (vinfo.normal  ) glNormal3f(v2.nx, v2.ny, v2.nz);
								if (vinfo.color   ) glColor4f(v2.r, v2.g, v2.b, v2.a);

								version (gpu_use_shaders) gla_spriteCorner.set(3);
								if (vinfo.texture ) glTexCoord2f(v2.u, v2.v);
								if (vinfo.position) glVertex3f(v2.px, v2.py, v1.pz);

								version (gpu_use_shaders) gla_spriteCorner.set(4);
								if (vinfo.texture ) glTexCoord2f(v1.u, v2.v);
								if (vinfo.position) glVertex3f(v1.px, v2.py, v1.pz);
								
								debug (gpu_debug_vertex) writefln(" }");
							}
							glEnd();

							glPopAttrib();
						} else {
							VertexState cvs;
							
							glBegin(PRIM_T[primitiveType]);
							{
								while (vertexCount) {
									extractVertex(cvs);
									version (gpu_use_shaders) {
										if (vinfo.weight  ) {
											for (int n = 0; n < vinfo.weight; n++) {
												//writefln("%f", cvs.boneWeights[n]);
												gla_morphWeight[n].set1f(cvs.boneWeights[n]);
											}
										}
									}
									if (vinfo.texture ) glTexCoord2f(cvs.u, cvs.v);
									if (vinfo.color   ) glColor4f(cvs.r, cvs.g, cvs.b, cvs.a);
									if (vinfo.normal  ) glNormal3f(cvs.nx, cvs.ny, cvs.nz);
									if (vinfo.position) glVertex3f(cvs.px, cvs.py, cvs.pz);
								}
							}
							glEnd();
						}
						
						debug (gpu_debug_vertex) writefln("}");
						
					} break;
				
					/*
					case VC.ATST:					
						paramf = cast(float)((param >> 8) & 0xFF) / 255.0f;
						
						if (paramf > 0.0f) {
							glEnable(GL_ALPHA_TEST);
							glAlphaFunc(TST_T[param & 0xFF], paramf);
						} else {
							glDisable(GL_ALPHA_TEST);
						}
						// @param mask - Specifies the mask that both values are ANDed with before comparison.
						//temp = ( argi >> 16 ) & 0xFF;
						//assert( ( temp == 0x0 ) || ( temp == 0xFF ) );
					break;
					case VC.ZTST:					
						glDepthFunc(ZTST_T[param]);
					break;
					case VC.NEARZ:
						context->NearZ = cast(float)cast(int)(cast(short)cast(ushort)argi);
						//glDepthRange( context->NearZ, context->FarZ );
						break;
					case VC.FARZ:
						argi = ( int )( ( short )( ushort )argi );
						if (context->NearZ > argi) {
							context->FarZ = context->NearZ;
							context->NearZ = ( float )argi;
						} else {
							context->FarZ = ( float )argi;
						}
						glDepthRange( context->NearZ, context->FarZ );
					break;
					case VC.SFIX:	// source fix color
						context->SourceFix = argi;
					break;
					case VC.DFIX:	// destination fix color
						context->DestFix = argi;
					break;
					case VC.BEZIER:
						if (context->TexturesEnabled) SetTexture(context, 0);

						int vertexSize = DetermineVertexSize( vertexType );
						byte* ptr = context->Memory->Translate( vertexBufferAddress );

						bool isIndexed = ( vertexType & ( VTIndex8 | VTIndex16 ) ) != 0;
						byte* iptr = 0;
						if (isIndexed) iptr = context->Memory->Translate( indexBufferAddress );

						int ucount = ( argi & 0xFF );
						int vcount = ( ( argi >> 8 ) & 0xFF );

						DrawBezier( context, vertexType, vertexSize, iptr, ptr, ucount, vcount );
					break;
					case VC.SPLINE:
					break;

					// ------------------
					//  TEXTURE TRANSFER
					// ------------------
					
					case VC.TRXSBP: // Transmission Source Buffer Pointer
						context->TextureTx.SourceAddress = argi;
					break;
					case VC.TRXSBW: // Transmission Source Buffer Width
						context->TextureTx.SourceAddress |= ( argi << 8 ) & 0xFF000000;
						context->TextureTx.SourceLineWidth = argi & 0x0000FFFF;
					break;
					case VC.TRXDBP: // Transmission Destination Buffer Pointer
						context->TextureTx.DestinationAddress = argi;
					break;
					case VC.TRXDBW: // Transmission Destination Buffer Width
						context->TextureTx.DestinationAddress |= ( argi << 8 ) & 0xFF000000;
						context->TextureTx.DestinationLineWidth = argi & 0x0000FFFF;
					break;
					case VC.TRXSIZE: // Transfer Size
						context->TextureTx.Width = ( argi & 0x3FF ) + 1;
						context->TextureTx.Height = ( ( argi >> 10 ) & 0x1FF ) + 1;
					break;
					case VC.TRXSPOS: // Transfer Source Position
						context->TextureTx.SX = argi & 0x1FF;
						context->TextureTx.SY = ( argi >> 10 ) & 0x1FF;
					break;
					case VC.TRXDPOS: // Transfer Destination Position
						context->TextureTx.DX = argi & 0x3FF;
						context->TextureTx.DY = ( argi >> 10 ) & 0x1FF;
					break;
					case VC.TRXKICK: // Transmission Kick
						context->TextureTx.PixelSize = ( argi & 0x1 );
						TextureTransfer( context );
					break;
					*/
					
					default:
						debug (gpu_debug) writefln("unprocessed");
						//throw(new Exception(std.string.format("Unimplemented GPU opcode '%02X'", cast(uint)command)));
					break;
				} // switch
			} // while
		}
		
		execute();
	}
		
	struct PspGeCallbackData {
		uint signal_func; // PspGeCallback
		uint signal_arg;  // void*
		uint finish_func; // PspGeCallback
		uint finish_arg;  // void*
		
		void Dump() {
			writefln("PspGeCallbackData {");
			writefln("  signal_func: %08X", signal_func);
			writefln("  signal_arg: %08X", signal_func);
			writefln("  finish_func: %08X", finish_func);
			writefln("  finish_arg: %08X", finish_arg);
			writefln("}");
		}
	}
	
	struct VideoPacket {
		union { struct {
			ubyte[3] Argument;
			ubyte Command;
		} }
		uint Data;
	}
	
	struct DisplayList {
		int   ID;

		uint* Packets;
		uint  StartAddress;
		uint  StallAddress;

		bool  Queued;
		bool  Done;
		bool  Stalled;
		bool  Drawn;
		bool  Cancelled;

		int   CallbackID;
		int   Argument;

		int   Base;
		uint* Stack[32];
		int   StackIndex;
		
		static DisplayList opCall(uint list, uint stall, uint callback, uint argument) {
			DisplayList dl;
			dl.StartAddress = list;
			dl.StallAddress = stall;
			dl.CallbackID = callback;
			dl.Argument = argument;
			return dl;
		}
	}
	
	DisplayList[int] displaylists;
	int dlist_min, dlist_max;
	PspGeCallbackData[uint] callbacks;
	bool mustUpdate;
	
	int enqueueHead(DisplayList dl) {
		int id = --dlist_min;
		displaylists[id] = dl;
		return id;
	}
	
	int enqueue(DisplayList dl) {
		int id = ++dlist_max;
		displaylists[id] = dl;
		return id;
	}
	
	int setCallback() {
		uint pos = callbacks.length + 0xFFFF;
		regs[Registers.R.v0] = pos;		
		callbacks[pos] = PspGeCallbackData();
		mem.readd(regs[Registers.R.a0], TA(callbacks[pos]));
		callbacks[pos].Dump();
		return 0;
	}	
	
	int unsetCallback() {
		uint callback = regs[Registers.R.a0];
		
		if (!(callback in callbacks)) return -1;
		callbacks.remove(regs[Registers.R.a0]);
		return 0;
	}
	
	int draw(int param) {
		if (!glcontrol) throw(new Exception("sceGeDrawSync :: NO glcontrol"));
		
		debug (gpu_debug) writefln("(S) gpu.draw(%d)", param);
		
		glcontrol.makeCurrent();
		
		glMatrixMode(GL_MODELVIEW); glLoadIdentity();
		glMatrixMode(GL_PROJECTION); glLoadIdentity();
		glPixelZoom(1, 1); glRasterPos2f(-1, 1);
	
		foreach (dl_i; displaylists.keys.sort) {
			DisplayList dl = displaylists[dl_i];
			dl.Packets = cast(uint*)mem.gptr(dl.StartAddress);
			ProcessList(dl);
			displaylists.remove(dl_i);
		}
		glFlush();
		
		storeFramebuffer();
		
		wglMakeCurrent(null, null);
		
		dlist_max = dlist_min = 0;
		
		debug (gpu_debug) writefln("(E) gpu.draw(%d)", param);
		
		return 0;
	}
	
	version (gpu_use_shaders) {
		glProgram prg;

		glUniform gla_transform2D;
		glUniform gla_tex;
		glUniform gla_clut;
		glUniform gla_clutUse;
		glUniform gla_clutOffset;
		glUniform gla_textureUse;
		glUniform gla_spriteCenter;
		glUniform[8] gla_BoneMatrix;
		glUniform gla_morphCount;
		glUniform gla_WorldMatrix;

		glAttrib gla_spriteCorner;
		glAttrib[8] gla_morphWeight;
	}
	
	void initShaders() {
		version (gpu_use_shaders) {
			glProgram prg = new glProgram();
			prg.attach(new glVertexShader(cast(char[])MyLoadResource("gpu_vert")));
			prg.attach(new glFragmentShader(cast(char[])MyLoadResource("gpu_frag")));
			prg.link();
			prg.use();
			
			gla_transform2D  = prg.getUniform("transform2D");
			gla_clut         = prg.getUniform("clut");
			gla_clutUse      = prg.getUniform("clutUse");
			gla_clutOffset   = prg.getUniform("clutOffset");
			gla_tex          = prg.getUniform("tex");
			gla_textureUse   = prg.getUniform("textureUse");
			gla_WorldMatrix  = prg.getUniform("WorldMatrix", true);

			gla_spriteCenter = prg.getUniform("spriteCenter");
			gla_spriteCorner = prg.getAttrib("spriteCorner");
			
			gla_morphCount = prg.getUniform("morphCount");		
			for (int n = 0; n < 8; n++) {
				gla_BoneMatrix[n] = prg.getUniform(std.string.format("BoneMatrix[%d]", n));
				gla_morphWeight[n] = prg.getAttrib(std.string.format("morphWeight[%d]", n));
			}
			
			clut.init();
			
			initShadersVariables();
		}
	}
	
	void initShadersVariables() {
		version (gpu_use_shaders) {
			if (!gla_WorldMatrix) return;
			
			writefln("initShadersVariables");
		
			matrix_World[0..16] = [
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1
			];
			
			uploadMatrix_World();
		}
	}

	version (gpu_use_shaders) {
		void uploadMatrix_World() {
			//DumpMatrix(cast(float*)matrix_World);
			gla_WorldMatrix.setMatrix4(cast(float*)matrix_World);
		}

		void uploadMatrix_Projection() {
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			glMultMatrixf(cast(float*)matrix_Projection);
		}

		void uploadMatrix_ModelView() {
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			glMultMatrixf(cast(float*)matrix_Model);
		}
	}
	
	void init(GLControl glcontrol) {
		this.glcontrol = glcontrol;
		initShaders();
	}
	
	this(Memory mem) {
		writefln("GPU.this();");
		this.mem = mem;
		this.regs = mem.regs;
		drawBuffer = new ScreenBuffer;
		displayBuffer = new ScreenBuffer;
		clut = new Clut;
	}
}
