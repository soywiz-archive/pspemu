module pspemu.formats.DetectFormat;

import std.stream;

class DetectFormat {
	protected static int safe_read(Stream stream, int position, ubyte[] data) {
		try {
			stream.position = position;
			return stream.read(data);
		} catch {
			return 0;
		}
	} 
	
	protected static string _detect(Stream stream) {
		ubyte[0x10] magic;
		safe_read(stream, 0, magic);
		
		// Check normal magic.
		switch (cast(char[])magic[0..4]) {
			case "7z\xBC\xAF": return "7zip"; 
			case "CISO"      : return "ciso";
			case "JISO"      : return "jiso"; 
			case "DAX\0"     : return "dax";
			case "Rar!"      : return "rar";
			case "MZ\x90\0"  : return "exe_windows";
			case "\0PBP"     : return "pbp";
			case "\0PSF"     : return "psf";
			case "\x7FELF"   : return "elf";
			case "\x7EPSP"   : return "elf_encrypted";
			case "\x89PNG"   : return "png";
			case "RIFF"      : return "wav";
			case x"00008801" : 
				if (cast(char[])magic[4..8] == "PGF0") return "pgf";
				break;
			
			default: break;
		}
		
		// Check iso.
		safe_read(stream, 0x8000, magic);
		if (cast(char[])magic[0..6] == "\1CD001") return "iso";

		return "unknown";
	}

	public static string detect(Stream stream) {
		return _detect(new SliceStream(stream, stream.position));
	}
	
	public static string detect(string file) {
		if (std.file.isDir(file)) return "directory";
		scope Stream stream = new BufferedFile(file, FileMode.In);
		scope (exit) stream.close();
		return detect(stream);
	}
}