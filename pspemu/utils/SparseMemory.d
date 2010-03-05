module pspemu.utils.SparseMemory;

import std.stdio, std.string, std.stream;

class SparseMemoryStream : Stream {
	static struct Segment {
		MemoryStream stream;
		uint start;

		uint length() { return cast(uint)stream.size; }
		uint end() { return start + length; }
		bool contains(uint position) { return (position >= start) && (position <= end); }
		bool intersect(int start, int end) {
			bool result = (this.start <= end) && (this.end >= start);
			//.writefln("intersect Input(%d, %d)-Segment(%d, %d) : %s", start, end, this.start, this.end, result);
			return result;
		}
		uint globalPositionToLocal(uint globalPosition) { return globalPosition - start; }
		void setGlobalPosition(uint globalPosition) { /*assert(contains(globalPosition));*/ stream.position = globalPositionToLocal(globalPosition); }
		uint left() { return cast(uint)(stream.size - stream.position); }
		
		static Segment opCall(uint streamPosition) {
			Segment segment = void;
			segment.stream = new MemoryStream;
			segment.start  = streamPosition;
			return segment;
		}
	}

	Segment[uint] segments;
	
	this() {
		this.seekable  = true;
		this.readable  = true;
		this.writeable = true;
	}

	uint streamPosition;

	void smartDump() {
		int group = 4;
		.writefln("Segments: %d", segments.length);
		foreach (segment; segments) {
			.writefln("-------------------------------------------------------------------");
			.writefln("Segment (0x%08X)", segment.start);
			.writefln("-------------------------------------------------------------------");
			auto data = cast(ubyte[])(new SliceStream(segment.stream, 0)).readString(cast(uint)segment.stream.size);
			int pos = 0;
			while (true) {
				.writef("%08X |", segment.start + pos);
				for (int n = 0; n < 16; n++, pos++) {
					if ((n % group) == 0) .writef(" ");
					if (pos < data.length) {
						.writef("%02X", data[pos]);
					} else {
						.writef("  ");
					}
				}
				.writef(" | ");
				pos -= 16;
				for (int n = 0; n < 16; n++, pos++) {
					if (pos < data.length) {
						char c = data[pos];
						.writef("%s", std.ctype.isalnum(c) ? c : '.');
					} else {
						.writef(" ");
					}
				}
				.writefln(" |");
				if (pos >= data.length) break;
			}
			.writefln("");
		}
	}
	
	Segment[] segmentsBetween(int start, int end) {
		Segment[] list;
		foreach (segment; segments) if (segment.intersect(start, end)) list ~= segment;
		return list;
	}

	override size_t readBlock(void *data, size_t len) {
		//.writefln("readFrom: %08X", streamPosition);
		foreach (segmentKey; segments.keys.sort) { auto segment = segments[segmentKey];
			if (segment.contains(streamPosition)) {
				segment.setGlobalPosition(streamPosition);
				size_t r = segment.stream.readBlock(data, len);
				streamPosition += r;
				return r;
			}
		}
		assert(0);
		return 0;
	}

	override size_t writeBlock(const void *data, size_t len) {
		Segment[] segmentsBetween = this.segmentsBetween(streamPosition, streamPosition + len);
		size_t wlen = 0;

		if ((segmentsBetween.length == 0) || !(segmentsBetween[0].contains(streamPosition))) {
			//.writefln("writeTo: %08X", streamPosition);
			Segment segment = Segment(streamPosition); segments[segment.start] = segment;
			assert(segment.globalPositionToLocal(streamPosition) == 0);

			segmentsBetween = segment ~ segmentsBetween;
		}

		// Write on the first.
		segmentsBetween[0].setGlobalPosition(streamPosition);
		streamPosition += (wlen = segmentsBetween[0].stream.writeBlock(data, len));

		if (segmentsBetween.length > 1) {
			if (segmentsBetween[$ - 1].contains(streamPosition)) {
				segmentsBetween[$ - 1].setGlobalPosition(streamPosition);
				segmentsBetween[0].stream.write(cast(ubyte[])(segmentsBetween[$ - 1].stream.readString(segmentsBetween[$ - 1].left)));
			}
			foreach (segment; segmentsBetween[1..$]) segments.remove(segment.start);
		}

		return wlen;
	}

	override bool eof() { return false; }
	
	override ulong seek(long offset, SeekPos whence) {
		switch (whence) {
			case SeekPos.Current: streamPosition += offset; break;
			case SeekPos.Set, SeekPos.End: streamPosition = cast(uint)offset; break;
		}
		return streamPosition;
	}
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");

	// Test SparseMemoryStream.
	{
		uint base = 1000;

		scope stream = new SparseMemoryStream;
		stream.position = base + 0;
		stream.writeString("AAA");
		writefln("  Check a simple segment");
		assert(stream.segments.length == 1);

		stream.position = base + 4;
		stream.writeString("BBB");
		writefln("  Check a sparse segment");
		assert(stream.segments.length == 2);

		stream.position = base + 2;
		stream.writeString("CCC");
		writefln("  Join two segments. In between.");
		assert(stream.segments.length == 1);
		
		stream.position = base + 0;
		writefln("  Check contents.");
		assert(stream.readString(7) == "AACCCBB");

		stream.position = base + 7;
		stream.writeString("D");
		writefln("  Add to the end.");
		assert(stream.segments.length == 1);

		stream.position = base + 0;
		writefln("  Check segment.");
		assert(stream.readString(8) == "AACCCBBD");
		assert(stream.segments.length == 1);
		assert(stream.segments[base].length == 8);

		stream.position = base - 2;
		stream.writeString("EEEE");
		stream.position = base - 2;
		writefln("  Create segment before.");
		assert(stream.segments.length == 1);
		assert(stream.readString(10) == "EEEECCCBBD");
		assert(stream.segments[base - 2].length == 10);
		
	}
}
