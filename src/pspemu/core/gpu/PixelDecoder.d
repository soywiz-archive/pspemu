module pspemu.core.gpu.PixelDecoder;

import std.string;
public import pspemu.core.gpu.Types;
import pspemu.utils.BitUtils;

/*
enum PixelFormats {
	// Display, Texture, Palette
	GU_PSM_5650 = 0, GU_PSM_5551 = 1, GU_PSM_4444 = 2, GU_PSM_8888 = 3,
	// Texture Only
	GU_PSM_T4 = 4, GU_PSM_T8 = 5, GU_PSM_T16 = 6, GU_PSM_T32 = 7, GU_PSM_DXT1 = 8, GU_PSM_DXT3 = 9, GU_PSM_DXT5 = 10
}
*/

// @TODO Use OpenCL
class PixelDecoder {
	align (1) struct Pixel {
		union {
			uint v;
			struct {
				//ubyte r, g, b, a;
				ubyte b, g, r, a;
			}
		} 
	}
	
	static public void decodePixels(PixelFormats inputFormat, void* inputDataPtr, Pixel[] outputData) {
		switch (inputFormat) {
			case PixelFormats.GU_PSM_5650: {
				ushort *inputPtr = cast(ushort*)inputDataPtr;
				foreach (ref pixel; outputData) {
					auto v = *inputPtr;
					pixel.r = cast(ubyte)BitUtils.extractNormalized!(uint, 0, 5, 255)(v);
					pixel.g = cast(ubyte)BitUtils.extractNormalized!(uint, 5, 6, 255)(v);
					pixel.b = cast(ubyte)BitUtils.extractNormalized!(uint,11, 5, 255)(v);
					pixel.a = 0xFF;
					inputPtr++;
				}
			} break;
			case PixelFormats.GU_PSM_5551: {
				ushort *inputPtr = cast(ushort*)inputDataPtr;
				foreach (ref pixel; outputData) {
					auto v = *inputPtr;
					pixel.r = cast(ubyte)BitUtils.extractNormalized!(uint, 0, 5, 255)(v);
					pixel.g = cast(ubyte)BitUtils.extractNormalized!(uint, 5, 5, 255)(v);
					pixel.b = cast(ubyte)BitUtils.extractNormalized!(uint,10, 5, 255)(v);
					pixel.a = 0xFF;
					inputPtr++;
				}
			} break;
			case PixelFormats.GU_PSM_8888: {
				uint *inputPtr = cast(uint*)inputDataPtr;
				foreach (ref pixel; outputData) {
					auto v = *inputPtr;
					pixel.r = cast(ubyte)BitUtils.extractNormalized!(uint, 0, 8, 255)(v);
					pixel.g = cast(ubyte)BitUtils.extractNormalized!(uint, 8, 8, 255)(v);
					pixel.b = cast(ubyte)BitUtils.extractNormalized!(uint,16, 8, 255)(v);
					pixel.a = 0xFF;
					inputPtr++;
				}
			} break;
			default: throw(new Exception(std.string.format("Unknown PixelFormats (%d)", inputFormat)));
		}
	}
}