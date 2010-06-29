module pspemu.utils.Image;

import pspemu.utils.Utils;

import std.stream, std.stdio, std.path, std.typecons;

static struct RGBQUAD {
	ubyte rgbBlue;
	ubyte rgbGreen;
	ubyte rgbRed;
	ubyte rgbReserved;
}

RGBQUAD[] paletteGrayScale(int count = 0x100) {
	RGBQUAD[] palette;
	for (int n = 0; n < count; n++) {
		RGBQUAD rgba;
		rgba.rgbRed = rgba.rgbGreen = rgba.rgbBlue = cast(ubyte)n;
		rgba.rgbReserved = 0xFF;
		palette ~= rgba;
	}
	return palette;
}

RGBQUAD[] paletteRandom(int count = 0x100) {
	RGBQUAD[] palette;
	for (int n = 0; n < count; n++) {
		RGBQUAD rgba;
		rgba.rgbRed   = cast(ubyte)(n * 64);
		rgba.rgbGreen = cast(ubyte)(n * (256 + 64) - 64);
		rgba.rgbBlue  = cast(ubyte)(n);
		rgba.rgbReserved = 0xFF;
		palette ~= rgba;
	}
	return palette;
}

void writeBmp8(string fileName, void* data, int width, int height, RGBQUAD[] palette) {
	static struct BITMAPFILEHEADER { align(1):
		char[2] bfType = "BM";
		uint    bfSize;
		ushort  bfReserved1;
		ushort  bfReserved2;
		uint    bfOffBits;
	}
	
	static struct BITMAPINFOHEADER { align(1):
		uint   biSize;
		int    biWidth;
		int    biHeight;
		ushort biPlanes;
		ushort biBitCount;
		uint   biCompression;
		uint   biSizeImage;
		int    biXPelsPerMeter;
		int    biYPelsPerMeter;
		uint   biClrUsed;
		uint   biClrImportant;
	}

	BITMAPFILEHEADER h;
	BITMAPINFOHEADER ih;
	
	ih.biSize = ih.sizeof;
	ih.biWidth = width;
	ih.biHeight = height;
	ih.biPlanes = 1;
	ih.biBitCount = 8;
	ih.biCompression = 0;
	ih.biSizeImage = ubyte.sizeof * width * height;
	ih.biXPelsPerMeter = 0;
	ih.biYPelsPerMeter = 0;
	ih.biClrUsed = palette.length;
	ih.biClrImportant = 0;

	h.bfOffBits = h.sizeof + ih.sizeof;
	
	h.bfSize = h.sizeof + ih.sizeof + RGBQUAD.sizeof * 0x100 + ubyte.sizeof * width * height;

	scope file = new std.stream.File(fileName, FileMode.OutNew);
	file.write(TA(h));
	file.write(TA(ih));
	foreach (rgba; palette) file.write(TA(rgba));
	file.write((cast(ubyte*)data)[0..width * height]);
	file.close();
}
