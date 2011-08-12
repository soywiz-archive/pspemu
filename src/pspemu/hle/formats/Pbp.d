module pspemu.hle.formats.Pbp;

import std.stdio, std.stream, std.string, std.file;

class Pbp {
	__gshared auto files = ["param.sfo", "icon0.png", "icon1.pmf", "pic0.png", "pic1.png", "snd0.at3", "psp.data", "psar.data"];

	static protected struct Header {
		ubyte[4] pmagic   = [0, 'P', 'B', 'P'];
		ubyte[4] pversion = [0, 0, 1, 0];
		uint [8] offsets;

		// Check the size of the struct.
		static assert(this.sizeof == 40);

		void read(Stream stream) {
			// Reads the header.
			stream.readExact(&this, this.sizeof);

			// Check header and version.
			assert(pmagic   == this.init.pmagic  , "Not a valid PBP file.");
			assert(pversion == this.init.pversion, "Unknown version for PBP file.");
		}
	}

	Stream stream;
	Header header;
	Stream[string] slices;

	this() {
	}

	this(Stream _stream) {
		load(_stream);
	}

	void load(Stream _stream) {
		// Extracts a slice of the stream.
		stream = new SliceStream(_stream, 0);

		// Reads the header.
		header.read(stream);

		// Extract offsets and adds the end of the stream.
		auto offsets = header.offsets ~ cast(uint)stream.size;

		// Process all the files.
		slices = null;
		foreach (n, name; files) {
			if (offsets[n + 1] < offsets[n]) throw(new Exception(format("Pbp.load() : Invalid entry '%s' (0x%08X >= 0x%08X)", name, offsets[n + 1], offsets[n])));
			if (offsets[n + 1] != offsets[n]) slices[name] = new SliceStream(stream, offsets[n], offsets[n + 1]);
		}
	}

	bool has(string name) { return (name in slices) !is null; }
	Stream opIndex(string name) {
		if (!has(name)) throw(new Exception(std.string.format("Pbp.opIndex() can't found name '%s'", name)));
		return new SliceStream(slices[name], 0);
	}
	Stream opIndexAssign(string name, Stream stream) {
		return slices[name] = stream;
	}

	int opApply(int delegate(ref string, ref Stream) callback) { int result = 0; foreach (name, stream; slices) if ((result = callback(name, stream)) != 0) break; return result; }
	int opApply(int delegate(ref string) callback) { int result = 0; foreach (name; slices.keys) if ((result = callback(name)) != 0) break; return result; }

	void unpackTo(string folder = "pbp", bool createPath = true) {
		if (createPath) mkdirRecurse(folder);
		foreach (name, stream; this) {
			scope file = new std.stream.File(folder ~ "/" ~ name, FileMode.OutNew);
			file.copyFrom(stream);
			file.close();
		}
	}
}
