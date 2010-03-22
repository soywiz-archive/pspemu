module pspemu.core.gpu.Commands;

import pspemu.utils.Utils;
import std.string;
import std.typecons;

mixin(defineEnum!("Opcode", ubyte, // VideoCommand
	"NOP"			, // 0x00 - NOP
	"VADDR"			, // 0x01 - Vertex List (BASE)
	"IADDR"			, // 0x02 - Index List (BASE)
	"Unknown0x03"	, // 0x03 - 
	"PRIM"			, // 0x04 - Primitive Kick
	"BEZIER"		, // 0x05 - Bezier Patch Kick
	"SPLINE"		, // 0x06 - Spline Surface Kick
	"BBOX"			, // 0x07 - Bounding Box
	"JUMP"			, // 0x08 - Jump To New Address (BASE)
	"BJUMP"			, // 0x09 - Conditional Jump (BASE)
	"CALL"			, // 0x0A - Call Address (BASE)
	"RET"			, // 0x0B - Return From Call
	"END"			, // 0x0C - Stop Execution
	"Unknown0x0D"	, // 0x0D - 
	"SIGNAL"		, // 0x0E - Raise Signal Interrupt
	"FINISH"		, // 0x0F - Complete Rendering
	"BASE"			, // 0x|| - Base Address Register
	"Unknown0x11"	, // 0x|| - 
	"VTYPE"			, // 0x|| - Vertex Type
	"OFFSETADDR"	, // 0x|| - Offset Address (BASE)
	"ORIGINADDR"	, // 0x|| - Origin Address (BASE)
	"REGION1"		, // 0x|| - Draw Region Start
	"REGION2"		, // 0x|| - Draw Region End
	"LTE"			, // 0x|| - Lighting Enable
	"LTE0"			, // 0x|| - Light 0 Enable
	"LTE1"			, // 0x|| - Light 1 Enable
	"LTE2"			, // 0x|| - Light 2 Enable
	"LTE3"			, // 0x|| - Light 3 Enable
	"CPE"			, // 0x|| - Clip Plane Enable
	"BCE"			, // 0x|| - Backface Culling Enable
	"TME"			, // 0x|| - Texture Mapping Enable
	"FGE"			, // 0x|| - Fog Enable
	"DTE"			, // 0x|| - Dither Enable
	"ABE"			, // 0x|| - Alpha Blend Enable
	"ATE"			, // 0x|| - Alpha Test Enable
	"ZTE"			, // 0x|| - Depth Test Enable
	"STE"			, // 0x|| - Stencil Test Enable
	"AAE"			, // 0x|| - Anitaliasing Enable
	"PCE"			, // 0x|| - Patch Cull Enable
	"CTE"			, // 0x|| - Color Test Enable
	"LOE"			, // 0x|| - Logical Operation Enable
	"Unknown0x29"	, // 0x|| - 
	"BOFS"			, // 0x|| - Bone Matrix Offset
	"BONE"			, // 0x|| - Bone Matrix Upload
	"MW0"			, // 0x|| - Morph Weight 0
	"MW1"			, // 0x|| - Morph Weight 1
	"MW2"			, // 0x|| - Morph Weight 2
	"MW3"			, // 0x|| - Morph Weight 3
	"MW4"			, // 0x|| - Morph Weight 4
	"MW5"			, // 0x|| - Morph Weight 5
	"MW6"			, // 0x|| - Morph Weight 6
	"MW7"			, // 0x|| - Morph Weight 7
	"Unknown0x34"	, // 0x|| - 
	"Unknown0x35"	, // 0x|| - 
	"PSUB"			, // 0x|| - Patch Subdivision
	"PPRIM"			, // 0x|| - Patch Primitive
	"PFACE"			, // 0x|| - Patch Front Face
	"Unknown0x39"	, // 0x|| - 
	"WMS"			, // 0x|| - World Matrix Select
	"WORLD"			, // 0x|| - World Matrix Upload
	"VMS"			, // 0x|| - View Matrix Select
	"VIEW"			, // 0x|| - View Matrix upload
	"PMS"			, // 0x|| - Projection matrix Select
	"PROJ"			, // 0x|| - Projection Matrix upload
	"TMS"			, // 0x|| - Texture Matrix Select
	"TMATRIX"		, // 0x|| - Texture Matrix Upload
	"XSCALE"		, // 0x|| - Viewport Width Scale
	"YSCALE"		, // 0x|| - Viewport Height Scale
	"ZSCALE"		, // 0x|| - Depth Scale
	"XPOS"			, // 0x|| - Viewport X Position
	"YPOS"			, // 0x|| - Viewport Y Position
	"ZPOS"			, // 0x|| - Depth Position
	"USCALE"		, // 0x|| - Texture Scale U
	"VSCALE"		, // 0x|| - Texture Scale V
	"UOFFSET"		, // 0x|| - Texture Offset U
	"VOFFSET"		, // 0x|| - Texture Offset V
	"OFFSETX"		, // 0x|| - Viewport offset (X)
	"OFFSETY"		, // 0x|| - Viewport offset (Y)
	"Unknown0x4E"	, // 0x|| - 
	"Unknown0x4F"	, // 0x|| - 
	"SHADE"			, // 0x|| - Shade Model
	"RNORM"			, // 0x|| - Reverse Face Normals Enable
	"Unknown0x52"	, // 0x|| - 
	"CMAT"			, // 0x|| - Color Material
	"EMC"			, // 0x|| - Emissive Model Color
	"AMC"			, // 0x|| - Ambient Model Color
	"DMC"			, // 0x|| - Diffuse Model Color
	"SMC"			, // 0x|| - Specular Model Color
	"AMA"			, // 0x|| - Ambient Model Alpha
	"Unknown0x59"	, // 0x|| - 
	"Unknown0x5A"	, // 0x|| - 
	"SPOW"			, // 0x|| - Specular Power
	"ALC"			, // 0x|| - Ambient Light Color
	"ALA"			, // 0x|| - Ambient Light Alpha
	"LMODE"			, // 0x|| - Light Model
	"LT0"			, // 0x|| - Light Type 0
	"LT1"			, // 0x|| - Light Type 1
	"LT2"			, // 0x|| - Light Type 2
	"LT3"			, // 0x|| - Light Type 3
	"LXP0"			, // 0x|| - Light X Position 0
	"LYP0"			, // 0x|| - Light Y Position 0
	"LZP0"			, // 0x|| - Light Z Position 0
	"LXP1"			, // 0x|| - Light X Position 1
	"LYP1"			, // 0x|| - Light Y Position 1
	"LZP1"			, // 0x|| - Light Z Position 1
	"LXP2"			, // 0x|| - Light X Position 2
	"LYP2"			, // 0x|| - Light Y Position 2
	"LZP2"			, // 0x|| - Light Z Position 2
	"LXP3"			, // 0x|| - Light X Position 3
	"LYP3"			, // 0x|| - Light Y Position 3
	"LZP3"			, // 0x|| - Light Z Position 3
	"LXD0"			, // 0x|| - Light X Direction 0
	"LYD0"			, // 0x|| - Light Y Direction 0
	"LZD0"			, // 0x|| - Light Z Direction 0
	"LXD1"			, // 0x|| - Light X Direction 1
	"LYD1"			, // 0x|| - Light Y Direction 1
	"LZD1"			, // 0x|| - Light Z Direction 1
	"LXD2"			, // 0x|| - Light X Direction 2
	"LYD2"			, // 0x|| - Light Y Direction 2
	"LZD2"			, // 0x|| - Light Z Direction 2
	"LXD3"			, // 0x|| - Light X Direction 3
	"LYD3"			, // 0x|| - Light Y Direction 3
	"LZD3"			, // 0x|| - Light Z Direction 3
	"LCA0"			, // 0x|| - Light Constant Attenuation 0
	"LLA0"			, // 0x|| - Light Linear Attenuation 0
	"LQA0"			, // 0x|| - Light Quadratic Attenuation 0
	"LCA1"			, // 0x|| - Light Constant Attenuation 1
	"LLA1"			, // 0x|| - Light Linear Attenuation 1
	"LQA1"			, // 0x|| - Light Quadratic Attenuation 1
	"LCA2"			, // 0x|| - Light Constant Attenuation 2
	"LLA2"			, // 0x|| - Light Linear Attenuation 2
	"LQA2"			, // 0x|| - Light Quadratic Attenuation 2
	"LCA3"			, // 0x|| - Light Constant Attenuation 3
	"LLA3"			, // 0x|| - Light Linear Attenuation 3
	"LQA3"			, // 0x|| - Light Quadratic Attenuation 3
	"SPOTEXP0"		, // 0x|| - Spot light 0 exponent
	"SPOTEXP1"		, // 0x|| - Spot light 1 exponent
	"SPOTEXP2"		, // 0x|| - Spot light 2 exponent
	"SPOTEXP3"		, // 0x|| - Spot light 3 exponent
	"SPOTCUT0"		, // 0x|| - Spot light 0 cutoff
	"SPOTCUT1"		, // 0x|| - Spot light 1 cutoff
	"SPOTCUT2"		, // 0x|| - Spot light 2 cutoff
	"SPOTCUT3"		, // 0x|| - Spot light 3 cutoff
	"ALC0"			, // 0x|| - Ambient Light Color 0
	"DLC0"			, // 0x|| - Diffuse Light Color 0
	"SLC0"			, // 0x|| - Specular Light Color 0
	"ALC1"			, // 0x|| - Ambient Light Color 1
	"DLC1"			, // 0x|| - Diffuse Light Color 1
	"SLC1"			, // 0x|| - Specular Light Color 1
	"ALC2"			, // 0x|| - Ambient Light Color 2
	"DLC2"			, // 0x|| - Diffuse Light Color 2
	"SLC2"			, // 0x|| - Specular Light Color 2
	"ALC3"			, // 0x|| - Ambient Light Color 3
	"DLC3"			, // 0x|| - Diffuse Light Color 3
	"SLC3"			, // 0x|| - Specular Light Color 3
	"FFACE"			, // 0x|| - Front Face Culling Order
	"FBP"			, // 0x|| - Frame Buffer Pointer
	"FBW"			, // 0x|| - Frame Buffer Width
	"ZBP"			, // 0x|| - Depth Buffer Pointer
	"ZBW"			, // 0x|| - Depth Buffer Width
	"TBP0"			, // 0x|| - Texture Buffer Pointer 0
	"TBP1"			, // 0x|| - Texture Buffer Pointer 1
	"TBP2"			, // 0x|| - Texture Buffer Pointer 2
	"TBP3"			, // 0x|| - Texture Buffer Pointer 3
	"TBP4"			, // 0x|| - Texture Buffer Pointer 4
	"TBP5"			, // 0x|| - Texture Buffer Pointer 5
	"TBP6"			, // 0x|| - Texture Buffer Pointer 6
	"TBP7"			, // 0x|| - Texture Buffer Pointer 7
	"TBW0"			, // 0x|| - Texture Buffer Width 0
	"TBW1"			, // 0x|| - Texture Buffer Width 1
	"TBW2"			, // 0x|| - Texture Buffer Width 2
	"TBW3"			, // 0x|| - Texture Buffer Width 3
	"TBW4"			, // 0x|| - Texture Buffer Width 4
	"TBW5"			, // 0x|| - Texture Buffer Width 5
	"TBW6"			, // 0x|| - Texture Buffer Width 6
	"TBW7"			, // 0x|| - Texture Buffer Width 7
	"CBP"			, // 0x|| - CLUT Buffer Pointer
	"CBPH"			, // 0x|| - CLUT Buffer Pointer H
	"TRXSBP"		, // 0x|| - Transmission Source Buffer Pointer
	"TRXSBW"		, // 0x|| - Transmission Source Buffer Width
	"TRXDBP"		, // 0x|| - Transmission Destination Buffer Pointer
	"TRXDBW"		, // 0x|| - Transmission Destination Buffer Width
	"Unknown0xB6"	, // 0x|| - 
	"Unknown0xB7"	, // 0x|| - 
	"TSIZE0"		, // 0x|| - Texture Size Level 0
	"TSIZE1"		, // 0x|| - Texture Size Level 1
	"TSIZE2"		, // 0x|| - Texture Size Level 2
	"TSIZE3"		, // 0x|| - Texture Size Level 3
	"TSIZE4"		, // 0x|| - Texture Size Level 4
	"TSIZE5"		, // 0x|| - Texture Size Level 5
	"TSIZE6"		, // 0x|| - Texture Size Level 6
	"TSIZE7"		, // 0x|| - Texture Size Level 7
	"TMAP"			, // 0x|| - Texture Projection Map Mode + Texture Map Mode
	"TEXTURE"		, // 0x|| - Environment Map Matrix
	"TMODE"			, // 0x|| - Texture Mode
	"TPSM"			, // 0x|| - Texture Pixel Storage Mode
	"CLOAD"			, // 0x|| - CLUT Load
	"CMODE"			, // 0x|| - CLUT Mode
	"TFLT"			, // 0x|| - Texture Filter
	"TWRAP"			, // 0x|| - Texture Wrapping
	"TBIAS"			, // 0x|| - Texture Level Bias (???)
	"TFUNC"			, // 0x|| - Texture Function
	"TEC"			, // 0x|| - Texture Environment Color
	"TFLUSH"		, // 0x|| - Texture Flush
	"TSYNC"			, // 0x|| - Texture Sync
	"FFAR"			, // 0x|| - Fog Far (???)
	"FDIST"			, // 0x|| - Fog Range
	"FCOL"			, // 0x|| - Fog Color
	"TSLOPE"		, // 0x|| - Texture Slope
	"Unknown0xD1"	, // 0x|| - 
	"PSM"			, // 0x|| - Frame Buffer Pixel Storage Mode
	"CLEAR"			, // 0x|| - Clear Flags
	"SCISSOR1"		, // 0x|| - Scissor Region Start
	"SCISSOR2"		, // 0x|| - Scissor Region End
	"NEARZ"			, // 0x|| - Near Depth Range
	"FARZ"			, // 0x|| - Far Depth Range
	"CTST"			, // 0x|| - Color Test Function
	"CREF"			, // 0x|| - Color Reference
	"CMSK"			, // 0x|| - Color Mask
	"ATST"			, // 0x|| - Alpha Test
	"STST"			, // 0x|| - Stencil Test
	"SOP"			, // 0x|| - Stencil Operations
	"ZTST"			, // 0x|| - Depth Test Function
	"ALPHA"			, // 0x|| - Alpha Blend
	"SFIX"			, // 0x|| - Source Fix Color
	"DFIX"			, // 0x|| - Destination Fix Color
	"DTH0"			, // 0x|| - Dither Matrix Row 0
	"DTH1"			, // 0x|| - Dither Matrix Row 1
	"DTH2"			, // 0x|| - Dither Matrix Row 2
	"DTH3"			, // 0x|| - Dither Matrix Row 3
	"LOP"			, // 0x|| - Logical Operation
	"ZMSK"			, // 0x|| - Depth Mask
	"PMSKC"			, // 0x|| - Pixel Mask Color
	"PMSKA"			, // 0x|| - Pixel Mask Alpha
	"TRXKICK"		, // 0x|| - Transmission Kick
	"TRXSPOS"		, // 0x|| - Transfer Source Position
	"TRXDPOS"		, // 0x|| - Transfer Destination Position
	"Unknown0xED"	, // 0x|| - 
	"TRXSIZE"		, // 0x|| - Transfer Size
	"Unknown0xEF"	, // 0x|| - 
	"Unknown0xF0"	, // 0x|| - 
	"Unknown0xF1"	, // 0x|| - 
	"Unknown0xF2"	, // 0x|| - 
	"Unknown0xF3"	, // 0x|| - 
	"Unknown0xF4"	, // 0x|| - 
	"Unknown0xF5"	, // 0x|| - 
	"Unknown0xF6"	, // 0x|| - 
	"Unknown0xF7"	, // 0x|| - 
	"Unknown0xF8"	, // 0x|| - 
	"Unknown0xF9"	, // 0x|| - 
	"Unknown0xFA"	, // 0x|| - 
	"Unknown0xFB"	, // 0x|| - 
	"Unknown0xFC"	, // 0x|| - 
	"Unknown0xFD"	, // 0x|| - 
	"Unknown0xFE"	, // 0x|| - 
	"Unknown0xFF"	  // 0x|| - 
));

struct Command {
	union {
		uint v;
		struct {
			ubyte[3] V;
			Opcode opcode;
		}
	}
	
	uint     param16() { return v & 0xFFFF; }
	uint     param24() { return v & 0xFFFFFF; }
	float[3] float3 () { return [cast(float)V[0] / 255.0, cast(float)V[1] / 255.0, cast(float)V[2] / 255.0]; }
	float[4] float4 () { return [cast(float)V[0] / 255.0, cast(float)V[1] / 255.0, cast(float)V[2] / 255.0, 1.0]; }
	float    float1 () { return reinterpret!(float)(v << 8); }
	bool     bool1  () { return (v << 8) != 0; }

	string toString() {
		return std.string.format("Command[%08X](%02X:%s)", v, opcode, enumToString(opcode));
	}
	
	static assert(this.sizeof == 4);
}
