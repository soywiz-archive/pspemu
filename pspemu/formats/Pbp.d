module pspemu.formats.Pbp;

import std.stdio, std.stream, std.string, std.file;

class Pbp {
	static auto files = ["param.sfo", "icon0.png", "icon1.pmf", "pic0.png", "pic1.png", "snd0.at3", "psp.data", "psar.data"];

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
			assert(offsets[n + 1] >= offsets[n], format("Invalid entry '%s' (0x%08X >= 0x%08X)", name, offsets[n + 1], offsets[n]));
			if (offsets[n + 1] != offsets[n]) slices[name] = new SliceStream(stream, offsets[n], offsets[n + 1]);
		}
	}

	bool has(string name) { return (name in slices) !is null; }
	Stream opIndex(string name) { assert(has(name)); return new SliceStream(slices[name], 0); }
	Stream opIndexAssign(string name, Stream stream) { return slices[name] = stream; }

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

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");

	const testPath = "demos";
	auto pbp = new Pbp(new BufferedFile(testPath ~ "/controller.pbp", FileMode.In));

	auto list = [
		"param.sfo" : true, // has
		"icon0.png" : false,
		"icon1.pmf" : false,
		"pic0.png"  : false,
		"pic1.png"  : false,
		"snd0.at3"  : false,
		"psp.data"  : true, // has
		"psar.data" : false,
	];

	// Check the existence of files.
	foreach (name, has; list) assert(pbp.has(name) == has);

	// Check the size of files.
	assert(pbp["param.sfo"].size == 0x100);
	assert(pbp["psp.data" ].size == 0x9A80);

	// Check that all the names returned are in our list.
	foreach (name; pbp) assert(name in list);

	// Check that reads the correct contents.
	auto param_sfo = pbp["param.sfo"];
	assert(param_sfo.toHash == 0x_B0AD9414);

	// Stores a file to disk.
	{
		scope (exit) std.file.remove("test.elf");
		scope file = new std.stream.File("test.elf", FileMode.OutNew);
		file.copyFrom(pbp["psp.data"]);
		file.close();
		assert(std.file.read("test.elf") == std.file.read(testPath ~ "/controller.elf"));
	}

	// Check the unpack.
	{
		scope (exit) rmdirRecurse("pbp-test");
		pbp.unpackTo("pbp-test"); 
		assert(isdir("pbp-test"));
		assert(isfile("pbp-test/param.sfo"));
		assert(isfile("pbp-test/psp.data"));
	}
	
	//static void main() { }
}
