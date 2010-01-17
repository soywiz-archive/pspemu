module pspemu.formats.pbp;

import std.stdio, std.stream, std.string;

class PBP {
	static struct Header {
		ubyte[4] pmagic   = ['P', 'B', 'P', 0];
		ubyte[4] pversion = [0, 0, 1, 0];
		uint [8] offsets;

		// Check the size of the struct.
		static assert(Header.sizeof == 4 + 4 + (4 * 8));
	}

	Stream stream;
	Header header;
	Stream[string] slices;

	this(Stream stream) {
		this.stream = new SliceStream(stream, 0);
		this.stream.readExact(&header, header.sizeof);
		uint[] offsets = header.offsets;
		offsets ~= cast(uint)stream.size;
		foreach (n, name; ["param.sfo", "icon0.png", "icon1.pmf", "pic0.png", "pic1.png", "snd0.at3", "psp.data", "psar.data"]) {
			assert(offsets[n + 1] >= offsets[n], format("Invalid entry '%s' (0x%08X >= 0x%08X)", name, offsets[n + 1], offsets[n]));
			if (offsets[n + 1] != offsets[n]) {
				slices[name] = new SliceStream(stream, offsets[n], offsets[n + 1]);
			}
		}
	}

	Stream opIndex(string name) {
		assert(has(name));
		return new SliceStream(slices[name], 0);
		//return slices[name];
	}

	bool has(string name) { return (name in slices) !is null; }

	int opApply(int delegate(ref string, ref Stream) callback) {
		int result = 0;
		foreach (name, stream; slices) if ((result = callback(name, stream)) != 0) break;
		return result;
	}

	int opApply(int delegate(ref string) callback) {
		int result = 0;
		foreach (name; slices.keys) if ((result = callback(name)) != 0) break;
		return result;
	}
}

unittest {
	auto pbp = new PBP(new BufferedFile("../../demos/controller.pbp", FileMode.In));

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
	
	static void main() { }
}