module pspemu.formats.iso.Dax;

import std.stream;

import pspemu.utils.StreamUtils;

class DAXStream : Stream {
	struct Header {
		char magic[4] = "DAX\0";
		uint decompressedIsoSize;
		uint _version;
		uint nonCompressedAreaCount;
		uint reserved[4];    
		
		static assert(this.sizeof == 8 * 4);
	}

	struct NCArea {
		static const auto FrameSize = 8192;
		static const auto MAX = 192;
	
		uint frame; // First frame of the NC Area
		uint size;  // Size of the NC Area in frames 

		static assert(this.sizeof == 8);
	}

	Header header;
	
	this(Stream stream) {
		readInplace(header, stream);

		if (header.magic != Header.init.magic) throw(new Exception("Not a DAX file"));
		if (!(header._version >= 0 && header._version <= 1)) throw(new Exception("Only supported DAX file versions 0 and 1"));

		// @TODO
		assert(0, "Not implemented");
	}
}