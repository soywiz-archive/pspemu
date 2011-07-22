module pspemu.utils.imaging.SimplePng;

import std.intrinsic;
import std.stdio;
import std.stream;
import std.file;
import std.zlib;
import etc.c.zlib;
import pspemu.utils.StructUtils;

class SimplePng {
	alias std.intrinsic.bswap BE;
	
	static public void write(uint[] pixels32, int width, int height, string file) {
		scope stream = new BufferedFile(file, FileMode.OutNew);
		scope (exit) { stream.flush(); stream.close(); } 
		
		write(pixels32, width, height, stream);
	}
	
	static public void write(uint[] pixels32, int width, int height, Stream file) {
        void writeChunk(string type, ubyte[] data = []) {
	        scope fullData = cast(ubyte[])type[0..4] ~ data;
	        file.write(BE(data.length));
	        file.write(fullData);
	
	        //auto crc = etc.c.zlib.crc32(0, fullData.ptr, fullData.length);
	        file.write(BE(std.zlib.crc32(0, fullData)));
	        //file.write(std.intrinsic.bswap(crc));
        }

        static struct PNG_IHDR { align(1):
            uint width;
            uint height;
            ubyte bps   = 8;
            ubyte ctype = 6;
            ubyte comp  = 0;
            ubyte filter = 0;
            ubyte interlace = 0;
        }
        
        static struct Pixel { align(1):
        	ubyte r, g, b, a;
        }
        
        Pixel[] pixelsFixed = cast(Pixel[])pixels32.dup;
        foreach (ref pixelFixed; pixelsFixed) {
        	swap(pixelFixed.r, pixelFixed.b);
        }
        
        file.write(cast(ubyte[])x"89504E470D0A1A0A");
        writeChunk("IHDR", TA(PNG_IHDR(BE(width), BE(height))));
        ubyte[] data;
        for (int n = 0; n < height; n++) {
            data ~= 0;
            data ~= cast(ubyte[])pixelsFixed[width * n..width * (n + 1)];
        }
        writeChunk("IDAT", cast(ubyte[])std.zlib.compress(data, 9));
        writeChunk("IEND");
	}
}
