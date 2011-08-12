module pspemu.hle.formats.Psf;

import std.stdio, std.stream, std.string, std.file;

private import std.variant;

class PSF {
	static protected struct Header {
		ubyte[4] pmagic   = [0, 'P', 'S', 'F'];  // Magic header of the PSF file.
		ubyte[4] pversion = [1, 1, 0, 0];        // Default version of the PSF file.
		uint     offsetKeys;                     // Offset to the keys table.
		uint     offsetValues;                   // Offset to the values table.
		uint     count;                          // Number of entries.

		static assert(this.sizeof == 20);
		
		void read(Stream stream) {
			stream.readExact(&this, this.sizeof);
			assert(pmagic   == this.init.pmagic  );
			assert(pversion == this.init.pversion);
		}
	}

	class Pair {
		align(1) static struct Entry {
			enum Type : ubyte { Binary = 0, String = 2, Integer = 4 }

			ushort offsetKey;
			ubyte  _0;
			Type   type;
			uint   size;
			uint   sizePadded;
			uint   offsetValue;

			static assert(this.sizeof == 16);

			void read(Stream stream) {
				stream.readExact(&this, this.sizeof);
			}
		}

		Entry   entry;
		string  key;
		Variant value;

		this(Stream stream) {
			entry.read(stream);
			auto streamKey   = new SliceStream(stream, header.offsetKeys   + entry.offsetKey);
			auto streamValue = new SliceStream(stream, header.offsetValues + entry.offsetValue);
			auto valueRaw    = cast(ubyte[])streamValue.readString(entry.size);

			char c;
			while (!streamKey.eof) {
				streamKey.read(c);
				if (c == 0) break;
				key ~= c;
			}

			switch (entry.type) {
				case Entry.Type.Binary : value = cast(ubyte[])valueRaw; break;
				case Entry.Type.String : value = cast(string)valueRaw; break;
				case Entry.Type.Integer: value = *cast(uint *)valueRaw.ptr; break;
			}

			//writefln("%s: %s", key, value);
		}
	}

	Stream stream;
	Header header;
	Pair[string] pairs;

	this(Stream _stream) {
		stream = new SliceStream(_stream, 0);
		
		// Read the header.
		header.read(stream);

		foreach (n; 0 .. header.count) {
			auto pair = new Pair(stream);
			pairs[pair.key] = pair;
		}
	}

	Variant opIndex(string key) {
		return pairs[key].value;
	}

	int opApply(int delegate(ref string, ref Variant) callback) {
		int result = 0; foreach (pair; pairs) if ((result = callback(pair.key, pair.value)) != 0) break; return result;
	}
}
