import std.stream, std.intrinsic, std.zlib;

ubyte[] TA(T)(ref T v) { return cast(ubyte[])((&v)[0..1]); }

void main() {
	scope file = new BufferedFile("test.png", FileMode.OutNew);
	
	ubyte[] screenData = new ubyte[480 * 272 * 4];
	
	void writeChunk(string type, ubyte[] data = []) {
		scope fullData = cast(ubyte[])type[0..4] ~ data;
		file.write(std.intrinsic.bswap(data.length));
		file.write(fullData);

		//auto crc = etc.c.zlib.crc32(0, fullData.ptr, fullData.length);
		file.write(std.intrinsic.bswap(std.zlib.crc32(0, fullData)));
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
	alias std.intrinsic.bswap BE;
	file.write(cast(ubyte[])x"89504E470D0A1A0A");
	writeChunk("IHDR", TA(PNG_IHDR(BE(480), BE(272))));
	ubyte[] data;
	int rowsize = 480 * 4;
	for (int n = 0; n < 272; n++) {
		data ~= 0;
		data ~= screenData[(n + 0) * rowsize..(n + 1) * rowsize];
	}
	writeChunk("IDAT", cast(ubyte[])std.zlib.compress(data, 9));
	writeChunk("IEND");

	file.flush();
	file.close();
}