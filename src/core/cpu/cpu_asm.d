module pspemu.core.cpu.cpu_asm;

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

	uint streamPosition;
	
	Segment[] segmentsBetween(int start, int end) {
		Segment[] list;
		foreach (segment; segments) if (segment.intersect(start, end)) list ~= segment;
		return list;
	}

	override size_t readBlock(void *data, size_t len) {
		foreach (segmentKey; segments.keys.sort) { auto segment = segments[segmentKey];
			if (segment.contains(streamPosition)) {
				segment.setGlobalPosition(streamPosition);
				size_t r = segment.stream.readBlock(data, len);
				streamPosition += r;
				return r;
			}
		}
		return 0;
	}

	override size_t writeBlock(const void *data, size_t len) {
		Segment[] segmentsBetween = this.segmentsBetween(streamPosition, streamPosition + len);
		size_t wlen = 0;
		int expect = 0;

		if ((segmentsBetween.length == 0) || !(segmentsBetween[0].contains(streamPosition))) {
			Segment segment = Segment(streamPosition); segments[segment.start] = segment;
			assert(segment.globalPositionToLocal(streamPosition) == 0);
			streamPosition += (wlen = segment.stream.writeBlock(data, len));
			expect = 0;
		} else {
			segmentsBetween[0].setGlobalPosition(streamPosition);
			streamPosition += (wlen = segmentsBetween[0].stream.writeBlock(data, len));
			expect = 1;
		}

		if (segmentsBetween.length > expect) {
			if (segmentsBetween[$ - 1].contains(streamPosition)) {
				segmentsBetween[$ - 1].setGlobalPosition(streamPosition);
				segmentsBetween[0].stream.write(cast(ubyte[])(segmentsBetween[$ - 1].stream.readString(segmentsBetween[$ - 1].left)));
			}
			foreach (segment; segmentsBetween[expect..$]) segments.remove(segment.start);
		}

		return wlen;
	}
	
	override ulong seek(long offset, SeekPos whence) {
		switch (whence) {
			case SeekPos.Current: streamPosition += offset; break;
			case SeekPos.Set: case SeekPos.End: streamPosition = cast(uint)offset; break;
		}
		return streamPosition;
	}
}

class AllegrexAssembler {
	uint[string] labels;
}

unittest {
	writefln("Unittesting: core.cpu.cpu_asm...");

	// Test SparseMemoryStream.
	{
		uint base = 1000;

		scope stream = new SparseMemoryStream;
		stream.position = base + 0;
		stream.writeString("AAA");
		assert(stream.segments.length == 1);

		stream.position = base + 4;
		stream.writeString("BBB");
		assert(stream.segments.length == 2);

		stream.position = base + 2;
		stream.writeString("CCC");
		assert(stream.segments.length == 1);
		
		stream.position = base + 0;
		assert(stream.readString(7) == "AACCCBB");

		stream.position = base + 7;
		stream.writeString("D");
		assert(stream.segments.length == 1);

		stream.position = base + 0;
		assert(stream.readString(8) == "AACCCBBD");
		assert(stream.segments.length == 1);
		assert(stream.segments[base].length == 8);

		stream.position = base - 2;
		stream.writeString("EEEE");
		assert(stream.segments.length == 1);
		writefln("%s", stream.readString(10));
		assert(stream.readString(10) == "EEEECCCBBD");
		assert(stream.segments[base - 2].length == 10);
		
	}
}