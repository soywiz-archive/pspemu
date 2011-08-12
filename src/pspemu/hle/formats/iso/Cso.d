module pspemu.hle.formats.iso.Cso;

//import std.stdio;

import etc.c.zlib;
import std.stream;

class CSOStream : Stream {
	struct Header {
		ubyte[4] magic;       // +00 : 'C','I','S','O'
		uint     header_size; // +04 : header size (==0x18)
		ulong    total_bytes; // +08 : number of original data size
		uint     block_size;  // +10 : number of compressed block size
		ubyte    ver;         // +14 : version 01
		ubyte    _align;      // +15 : align of index value
		ubyte[2] rsv_06;      // +16 : reserved
	}
	
	Header header;
	uint[] blockData;
	uint bufferBlock;
	ubyte[] buffer;
	Stream stream;
	z_stream zstream;
	long position = 0;
	
	int blocks() { return blockData.length - 1; }
	
	this(Stream stream) {
		this.stream = stream;
		
		stream.readExact(&header, header.sizeof);
		
		if (header.magic != cast(ubyte[])"CISO") throw(new Exception("Not a CSO file"));
		if (header.ver != 1) throw(new Exception("Not a CSO ver1"));
		//if (h.header_size != h.sizeof) throw(new Exception(std.string.format("Invalid header size %d!=%d", h.header_size, h.sizeof)));
		
		blockData.length = cast(uint)(header.total_bytes / header.block_size) + 1;
		stream.readExact(blockData.ptr, 4 * blockData.length);
		
		buffer.length = header.block_size;
		
		seekable = true;
		writeable = false;
		readable = true;
	}
	
	void readSector(uint sector) {
		if (bufferBlock == sector) return;

		if (sector >= blockData.length - 1) throw(new Exception("Invalid CSO sector"));
		
		bufferBlock = sector;
		
		bool getCompressed(uint sector) { return (blockData[sector] & (1 << 31)) == 0; }
		uint getPosition(uint sector) { return blockData[sector] & ~(1 << 31); }
		
		uint start = getPosition(sector);
		uint len = getPosition(sector + 1) - start;
		bool compressed = getCompressed(sector);
		
		stream.position = start;
		
		if (!compressed) {
			stream.readExact(buffer.ptr, len);
			return;
		}
		
		ubyte[] data = cast(ubyte[])stream.readString(len);
		if (data.length != len) throw(new Exception(std.string.format("block=%d : read error", sector)));
	
		if (inflateInit2(&zstream, -15) != Z_OK) throw(new Exception(std.string.format("defalteInit : %s", zstream.msg)));
		try {
			zstream.next_out  = buffer.ptr;
			zstream.avail_out = buffer.length;
			zstream.next_in   = data.ptr;
			zstream.avail_in  = data.length;
			int status  = inflate(&zstream, Z_FULL_FLUSH);
			if (status != Z_STREAM_END) throw(new Exception(std.string.format("block %d:inflate : %s[%d]\n", sector, zstream.msg, status)));
		} finally {
			inflateEnd(&zstream);
		}
	}
	
	override uint readBlock(void* _data, uint size) {
		ubyte *data = cast(ubyte*)_data;
		uint _size = size;
		while (true) {
			uint sec = cast(uint)(position / header.block_size);
			uint pos = cast(uint)(position % header.block_size);
			uint rem = header.block_size - pos;
			
			readSector(sec);
			
			if (size > rem) {
				data[0..rem] = buffer[pos..pos + rem];
				data += rem;
				size -= rem;
				position += rem;
			} else {
				data[0..size] = buffer[pos..pos + size];
				data += size;
				position += size;
				size = 0;
				break;
			}
		}
		
		return _size;
	}

	override uint writeBlock(const void* buffer, uint size) {
		throw(new Exception("Not implemented"));
	}
	
	override ulong seek(long offset, SeekPos whence) {
		switch (whence) {
			default:
			case SeekPos.Set:     return position = offset;
			case SeekPos.End:     return position = header.total_bytes + offset;
			case SeekPos.Current: return position += offset;
		}
	}
}
