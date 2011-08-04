module pspemu.formats.Pgf;

import std.stream;
import std.string;
import std.conv;
import pspemu.utils.StructUtils;

// http://forums.ps2dev.org/viewtopic.php?p=59845
// http://hitmen.c02.at/files/yapspd/psp_doc/chap26.html#sec26.9

// Based on jpcsp's and intraFont's work.
class Pgf {
    // Enums based on intraFont's findings.
    enum FileType {
    	FONT_FILETYPE_PGF     = 0x00,
    	FONT_FILETYPE_BWFON   = 0x01,
    }
    enum Flags {
	    FONT_PGF_BMP_H_ROWS   = 0x01,
	    FONT_PGF_BMP_V_ROWS   = 0x02,
	    FONT_PGF_BMP_OVERLAY  = 0x03,
	    FONT_PGF_METRIC_FLAG1 = 0x04,
	    FONT_PGF_METRIC_FLAG2 = 0x08,
	    FONT_PGF_METRIC_FLAG3 = 0x10,
	    FONT_PGF_CHARGLYPH    = 0x20,
	    FONT_PGF_SHADOWGLYPH  = 0x40,
    }
	
	struct Map(T = uint) {
		T src;
		T dst;
	}

	struct Point32 {
		uint x;
		uint y;
	}
	
	align(1) struct Header {
		ushort     headerOffset;
		ushort     headerSize;
		char[4]    magic = "PGF0";
		uint       revision;
		uint       _version;
		uint       charMapLength;
		uint       charPointerLength;
		uint       charMapBpe;
		uint       charPointerBpe;
		uint       __unk1;
		uint       hSize;
		uint       vSize;
		uint       hResolution;
		uint       vResolution;
		ubyte      __unk2;
		char[64]   fontName;
		char[64]   fontType;
		ubyte      __unk3;
		ushort     firstGlyph;
		ushort     lastGlyph;
		ubyte[34]  __unk4;
		uint       maxLeftXAdjust;
		uint       maxBaseYAdjust;
		uint       minCenterXAdjust;
		uint       maxTopYAdjust;
		Point32    maxAdvance;
		Point32    maxSize;
		ushort     maxGlyphWidth;
		ushort     maxGlyphHeight;
		ushort     __unk5;
		ubyte      dimTableLength;
		ubyte      xAdjustTableLength;
		ubyte      yAdjustTableLength;
		ubyte      advanceTableLength;
		ubyte[102] __unk6;
		uint       shadowMapLength;
		uint       shadowMapBpe;
		uint       __unk7;
		Point32    shadowScale;
		ulong      __unk8;
	}
	
	align(1) struct HeaderExtraRevision3 {
		uint      compCharMapBpe1;
		ushort    compCharMapLength1;
		ushort    __unk1;
		uint      compCharMapBpe2;
		ushort    compCharMapLength2;
		ubyte[6]  __unk2;
	}
	
	Header header;
	HeaderExtraRevision3 headerExtraRevision3;
	Map!uint[] dimensionTable;
	Map!uint[] advanceTable;
	Map!uint[] xAdjustTable;
	Map!uint[] yAdjustTable;
	ubyte[] shadowCharMap;
	Map!ushort[] charmapCompressionTable1;
	Map!ushort[] charmapCompressionTable2;
	ubyte[] charMap;
	ubyte[] charPointerTable;

	string fontName() {
		return to!string(header.fontName.ptr);
	}
	string fontType() {
		return to!string(header.fontType.ptr);
	}
	
	Stream fontDataStream;
	ubyte[] fontData;
	
	void load(string fileName) {
		load(new BufferedFile(fileName, FileMode.In));
	}
	
	void load(Stream stream) {
		stream.read(TA(header));
		
		if (header.revision == 3) {
			stream.read(TA(headerExtraRevision3));
		}
		
		// PGF Tables.
		void readVector(T)(ref T[] table, int size) {
			table = new T[size];
			foreach (ref entry; table) stream.read(TA(entry));
		}
		
		readVector(dimensionTable, header.dimTableLength);
		readVector(xAdjustTable, header.xAdjustTableLength);
		readVector(yAdjustTable, header.yAdjustTableLength);
		readVector(advanceTable, header.advanceTableLength);
		readVector(shadowCharMap, ((header.shadowMapLength * header.shadowMapBpe + 31) & ~31) / 8);
		
		if (header.revision == 3) {
			readVector(charmapCompressionTable1, headerExtraRevision3.compCharMapLength1);
			readVector(charmapCompressionTable2, headerExtraRevision3.compCharMapLength2);
		}
		
		readVector(charMap         , (((header.charMapLength     * header.charMapBpe     + 31) & ~31) / 8));
		readVector(charPointerTable, (((header.charPointerLength * header.charPointerBpe + 31) & ~31) / 8));
		
		fontDataStream = new SliceStream(stream, stream.position, stream.size);
		fontDataStream.read(fontData = new ubyte[cast(uint)fontDataStream.size]); 
	}
	
	string toString() {
		return std.string.format("Pgf('%s', '%s')", fontName, fontType);
	}
}
