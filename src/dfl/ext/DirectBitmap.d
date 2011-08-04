module dfl.ext.DirectBitmap;

private {
	import dfl.all;
	import dfl.internal.winapi;
	import std.c.stdlib : malloc, free;
	import std.string;
	import std.conv;
	import std.stdio;
	
	
	extern(Windows) int GetDIBits(
	  HDC hdc,           // handle to DC
	  HBITMAP hbmp,      // handle to bitmap
	  UINT uStartScan,   // first scan line to set
	  UINT cScanLines,   // number of scan lines to copy
	  LPVOID lpvBits,    // array for bitmap bits
	  LPBITMAPINFO lpbi, // bitmap data buffer
	  UINT uUsage        // RGB or palette index
	);
	
	extern (Windows) int SetDIBits(
	  HDC hdc,                  // handle to DC
	  HBITMAP hbmp,             // handle to bitmap
	  UINT uStartScan,          // starting scan line
	  UINT cScanLines,          // number of scan lines
	  VOID *lpvBits,      // array of bitmap bits
	  BITMAPINFO *lpbmi,  // bitmap data
	  UINT fuColorUse           // type of color indexes to use
	);
	
	const UINT DIB_RGB_COLORS = 0;
	
	
	extern (Windows) HBITMAP CreateDIBitmap(
	  HDC hdc,                        // handle to DC
	  BITMAPINFOHEADER *lpbmih, // bitmap data
	  DWORD fdwInit,                  // initialization option
	  VOID *lpbInit,            // initialization data
	  BITMAPINFO *lpbmi,        // color-format data
	  UINT fuUsage                    // color-data usage
	);
	
	const UINT BI_RGB = 0;
}



class DirectBitmap : Image {
	uint        width_;
	uint        height_;
	Pixel[]     pixData;
	BITMAPINFO  bitmapInfo;
	HBITMAP     memBM;
	HDC         memDC;
	HDC         ownerDC;
	bool        hq2x;

	this(uint width, uint height) {
		this(width, height, Graphics.getScreen.handle);
	}

	this(uint width, uint height, HDC ownerDC) {
		assert (ownerDC !is null);
		assert (width > 0);
		assert (height > 0);
		
		this.width_ = width;
		this.height_ = height;
		
		memDC = CreateCompatibleDC ( ownerDC );
		assert (memDC !is null);
		
		with (bitmapInfo.bmiHeader) {
			biSize = bitmapInfo.bmiHeader.sizeof;
			biWidth = width;
			biHeight = height;
			biPlanes = 1;
			biBitCount = 32;
			biCompression = BI_RGB;
		}
		
		memBM = CreateDIBitmap(ownerDC, &bitmapInfo.bmiHeader, 0, null, null, DIB_RGB_COLORS);
		assert (memBM !is null);
		
		void* selected = SelectObject ( memDC, memBM );
		assert (selected !is null);
		
		int ret = GetDIBits( memDC, memBM, 0, height, null, &bitmapInfo, DIB_RGB_COLORS );
		assert (ret != 0, to!string(GetLastError()));

		int len = bitmapInfo.bmiHeader.biSizeImage;
		//pixData = (cast(Pixel*)malloc(len))[0 .. len/3];
		pixData = new Pixel[len / 3];
		
		assert (bitmapInfo.bmiHeader.biBitCount == 32, to!string(bitmapInfo.bmiHeader.biBitCount));
	}
	
	
	~this() {
		//free(pixData.ptr);
		pixData = null;
		pixData = null;
		DeleteObject(memBM);
		memBM = null;
		DeleteDC(memDC);
		memDC = null;
	}
	
	
	Pixel[] lock() {
		int filled = GetDIBits( memDC, memBM, 0, height, pixData.ptr, &bitmapInfo, DIB_RGB_COLORS );
		assert (filled == height, to!string(filled));
		return pixData;
	}
	
	
	void unlock() {
		int filled = SetDIBits( memDC, memBM, 0, height, pixData.ptr, &bitmapInfo, DIB_RGB_COLORS );
		assert (filled == height, to!string(filled));
	}
	
	
	override void draw(Graphics graphics, Point pt) {
		HDC hdcDest = graphics.handle;
		
		BitBlt(
			hdcDest, // handle to destination DC
			pt.x,   // x-coord of destination upper-left corner
			pt.y,   // y-coord of destination upper-left corner
			width,  // width of destination rectangle
			height, // height of destination rectangle
			memDC,  // handle to source DC
			0,      // x-coordinate of source upper-left corner
			0,      // y-coordinate of source upper-left corner
			SRCCOPY // raster operation code
		);
	}
	
	override void drawStretched(Graphics graphics, Rect rect) {
		HDC hdcDest = graphics.handle;
		
		if ((rect.width == width_) && (rect.height == height_)) {
			draw(graphics, Point(rect.x, rect.y));
			return;
		}
		
		//SetStretchBltMode(hdcDest, COLORONCOLOR);
		//SetStretchBltMode(hdcDest, HALFTONE);
		
		//writefln("(%d,%d-%d,%d)(%d,%d)", rect.x, rect.y, rect.width, rect.height, width_, height_);

		StretchBlt(
			hdcDest,
			rect.x,
			rect.y,
			rect.width,
			rect.height,
			memDC,
			0,
			0,
			width_,
			height_,
			SRCCOPY
		);
	}
	
	override int height() {
		return height_;
	}
	
	
	override Size size() {
		return Size(width, height);
	}
	
	
	override int width() {
		return width_;
	}
}


align(1) struct Pixel {
	union {
		uint v;
		struct {
			ubyte b, g, r;
			ubyte a;
		}
	}
}
static assert (Pixel.sizeof == 4);
//static assert (Pixel.sizeof == 3);
