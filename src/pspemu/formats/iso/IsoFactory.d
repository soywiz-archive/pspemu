module pspemu.formats.iso.IsoFactory;

import std.stdio;
import std.stream;

import pspemu.formats.DetectFormat;
import pspemu.formats.iso.Iso;
import pspemu.formats.iso.Dax;
import pspemu.formats.iso.Cso;
import pspemu.formats.iso.Jso;

class IsoFactory {
	static public Iso getIsoFromStream(string isoPath) {
		return getIsoFromStream(new BufferedFile(isoPath), isoPath);
	}
	
	static public Iso getIsoFromStream(Stream inputStream, string isoPath = "<unknown>") {
		string format;
		switch (format = DetectFormat.detect(inputStream)) {
			case "iso" : return new Iso(inputStream, isoPath); break;
			case "ciso": return new Iso(new CSOStream(inputStream), isoPath); break;
			default: throw(new Exception(std.string.format("Can't create a iso from format '%s'", format)));
		}
	}
}