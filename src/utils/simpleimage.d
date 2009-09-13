module simpleimage;

import std.stream;
import std.stdio;
import std.intrinsic;
import std.path;
import std.math;
import std.file;
import std.process;
import std.zlib;
import crc32;

int imin(int a, int b) { return (a < b) ? a : b; }
int imax(int a, int b) { return (a > b) ? a : b; }
int iabs(int a) { return (a < 0) ? -a : a; }

// TrueColor pixel
align(1) struct RGBA {
	union {
		struct { ubyte r; ubyte g; ubyte b; ubyte a; }
		ubyte[4] vv;
		uint v;
	}	

	static RGBA toBGRA(RGBA c) {
		ubyte r = c.r;
		c.r = c.b;
		c.b = r;
		return c;
	}
}

// Abstract Image
abstract class Image {
	// Info
	ubyte bpp();
	int width();
	int height();

	// Data
	void set(int x, int y, uint v);
	uint get(int x, int y);

	void set32(int x, int y, RGBA c) {
		if (bpp == 32) { return set(x, y, c.v); }
		throw(new Exception("Not implemented (set32)"));
	}

	RGBA get32(int x, int y) {
		if (bpp == 32) {
			RGBA c; c.v = get(x, y);
			return c;
		}
		throw(new Exception("Not implemented (get32)"));
	}

	RGBA getColor(int x, int y) {
		RGBA c;
		c.v = hasPalette ? color(get(x, y)).v : get(x, y);
		return c;
	}

	// Palette
	bool hasPalette() { return (bpp <= 8); }
	int ncolor() { return 0; }
	int ncolor(int n) { return ncolor; }
	RGBA color(int idx) { RGBA c; return c; }
	RGBA color(int idx, RGBA c) { return color(idx); }

	static uint colorDist(RGBA c1, RGBA c2) {
		return (
			(
				iabs(c1.r * c1.a - c2.r * c2.a) +
				iabs(c1.g * c1.a - c2.g * c2.a) +
				iabs(c1.b * c1.a - c2.b * c2.a) +
				iabs(c1.a * c1.a - c2.a * c2.a) +
			0)
		);
	}

	RGBA[] createPalette(int count) {
		throw(new Exception("Not implemented: createPalette"));
		/*
		RGBA[] list; list.length = count;

		int[RGBA] colors;

		void reduce(RGBA nc) {
			RGBA[] cc = colors.keys;
			RGBA c;
			uint max = 0xFFFFFFFF;
			for (int n = 0; n < cc.length; n++) {
				uint sum;
				for (int m = 0; m < cc.length; m++) sum += colorDist(cc[n], cc[m]);
				if (sum < max) {
					max = sum;
					c = cc[n];
				}
			}
			if (max != max.init) {
				colors.remove(c);
				//writefln("removed");
			}
		}

		for (int y = 0; y < height; y++) {
			writefln(y);
			for (int x = 0; x < width; x++) {
			RGBA c = get32(x, y);
			if (colors.length >= count && (c in colors)) {
				reduce(c);
			}
			colors[c]++;
		}
		}

		return list;
		*/
	}

	uint matchColor(RGBA c) {
		uint mdist = 0xFFFFFFFF;
		uint idx;
		for (int n = 0; n < ncolor; n++) {
			uint cdist = colorDist(color(n), c);
			if (cdist < mdist) {
				mdist = cdist;
				idx = n;
			}
		}
		return idx;
	}

	void copyFrom(Image i, bool convertPalette = false) {
		int mw = imin(width, i.width);
		int mh = imin(height, i.height);

		//if (bpp != i.bpp) throw(new Exception(std.string.format("BPP mismatch copying image (%d != %d)", bpp, i.bpp)));

		if (i.hasPalette) {
			ncolor = i.ncolor;
			for (int n = 0; n < ncolor; n++) color(n, i.color(n));
		}

		/*if (hasPalette && !i.hasPalette) {
			i = toColorIndex(i);
		}*/

		if (convertPalette && hasPalette && !i.hasPalette) {
			foreach (idx, c; i.createPalette(ncolor)) color(idx, c);
		}

		if (hasPalette && i.hasPalette) {
			for (int y = 0; y < i.height; y++) for (int x = 0; x < i.width; x++) set(x, y, get(x, y));
		} else if (hasPalette) {
			for (int y = 0; y < i.height; y++) for (int x = 0; x < i.width; x++) set(x, y, matchColor(i.get32(x, y)));
		} else {
			for (int y = 0; y < i.height; y++) for (int x = 0; x < i.width; x++) set32(x, y, i.get32(x, y));
		}
	}
}

// TrueColor Bitmap
class Bitmap32 : Image {
	RGBA[] data;
	int _width, _height;

	ubyte bpp() { return 32; }
	int width() { return _width; }
	int height() { return _height; }

	void set(int x, int y, uint v) { data[y * _width + x].v = v; }
	uint get(int x, int y) { return data[y * _width + x].v; }

	this(int w, int h) {
		_width = w;
		_height = h;
		data.length = w * h;
	}
}

// Palletized Bitmap
class Bitmap8 : Image {
	RGBA[] palette;
	ubyte[] data;
	int _width, _height;

	override ubyte bpp() { return 8; }
	int width() { return _width; }
	int height() { return _height; }

	void set(int x, int y, uint v) { data[y * _width + x] = v; }
	uint get(int x, int y) { return data[y * _width + x]; }

	override RGBA get32(int x, int y) {
		return palette[get(x, y)];		
	}
	
	override int ncolor() { return palette.length;}
	override int ncolor(int s) { palette.length = s; return s; }
	RGBA color(int idx) { return palette[idx]; }
	RGBA color(int idx, RGBA col) { return palette[idx] = col; }


	this(int w, int h) {
		_width = w;
		_height = h;
		data.length = w * h;
	}
}

class ImageFileFormatProvider {
	static ImageFileFormat[char[]] list;

	static void registerFormat(ImageFileFormat iff) {
		list[iff.identifier] = iff;
	}

	static ImageFileFormat find(Stream s) {
		foreach (iff; list.values) if (iff.check(new SliceStream(s, s.position))) return iff;
		throw(new Exception("Unrecognized ImageFileFormat"));
		return null;
	}

	static Image read(Stream s) { return find(s).read(s); }

	static ImageFileFormat opIndex(char[] idx) {
		if ((idx in list) is null) throw(new Exception(std.string.format("Unknown ImageFileFormat '%s'", idx)));
		return list[idx];
	}
}

// Abstract ImageFileFormat
abstract class ImageFileFormat {
	private this() { }
	bool write(Image i, char[] name) {
		File s = new File(name, FileMode.OutNew);
		bool r = write(i, s);
		s.close();
		return r;
	}
	
	bool write(Image i, Stream s) { throw(new Exception("Writing not implemented")); return false; }
	Image read(Stream s) { throw(new Exception("Reading not implemented")); return null; }
	Image[] readMultiple(Stream s) { throw(new Exception("Multiple reading not implemented")); return null; }
	bool check(Stream s) { return false; }
	char[] identifier() { return "null"; }
}

// SPECS: http://www.libpng.org/pub/png/spec/iso/index-object.html
class ImageFileFormat_PNG : ImageFileFormat {
	void[] header = x"89504E470D0A1A0A";

	override char[] identifier() { return "png"; }

	align(1) struct PNG_IHDR {
		uint width;
		uint height;
		ubyte bps;
		ubyte ctype;
		ubyte comp;
		ubyte filter;
		ubyte interlace;
	}

	override bool write(Image i, Stream s) {
		PNG_IHDR h;

		void writeChunk(char[4] type, void[] data = []) {
			uint crc = void;

			s.write(bswap(cast(uint)(cast(ubyte[])data).length));
			s.write(cast(ubyte[])type);
			s.write(cast(ubyte[])data);

			/*
			if (false) {
				//crc = init_crc32;
				crc = 0;
				foreach (c; cast(ubyte[])type) crc = update_crc32(c, crc);
				foreach (c; cast(ubyte[])data) crc = update_crc32(c, crc);
			} else if (false) {
				crc = etc.c.zlib.crc32_combine(
					etc.c.zlib.crc32(0, cast(ubyte *)type.ptr, type.length),
					etc.c.zlib.crc32(0, cast(ubyte *)data.ptr, data.length),
					data.length
				);
			} else {
			*/
				ubyte[] full = cast(ubyte[])type ~ cast(ubyte[])data;
				crc = etc.c.zlib.crc32(0, cast(ubyte *)full.ptr, full.length);
				//crc = 0;
			//}

			s.write(bswap(crc));
		}

		void writeIHDR() { writeChunk("IHDR", (cast(ubyte *)&h)[0..h.sizeof]); }
		void writeIEND() { writeChunk("IEND", []); }

		void writeIDAT() {
			ubyte[] data;

			data.length = i.height + i.width * i.height * 4;

			int n = 0;
			ubyte *datap = data.ptr;
			for (int y = 0; y < i.height; y++) {
				*datap = 0x00; datap++;
				for (int x = 0; x < i.width; x++) {
					if (i.hasPalette) {
						*datap = cast(ubyte)i.get(x, y); datap++;
					} else {
						RGBA cc = i.getColor(x, y);
						*datap = cc.r; datap++;
						*datap = cc.g; datap++;
						*datap = cc.b; datap++;
						*datap = cc.a; datap++;
					}
				}
			}

			writeChunk("IDAT", std.zlib.compress(data, 9));
		}

		void writePLTE() {
			ubyte[] data;
			data.length = i.ncolor * 3;
			ubyte* pdata = data.ptr;
			for (int n = 0; n < i.ncolor; n++) {
				RGBA c = i.color(n);
				*pdata = c.r; pdata++;
				*pdata = c.g; pdata++;
				*pdata = c.b; pdata++;
			}
			writeChunk("PLTE", data);
		}

		void writetRNS() {
			ubyte[] data;
			data.length = i.ncolor;
			ubyte* pdata = data.ptr;
			bool hasTrans = false;
			for (int n = 0; n < i.ncolor; n++) {
				RGBA c = i.color(n);
				*pdata = c.a; pdata++;
				if (c.a != 0xFF) hasTrans = true;
			}
			if (hasTrans) writeChunk("tRNS", data);
		}

		s.write(cast(ubyte[])header);
		h.width = bswap(i.width);
		h.height = bswap(i.height);
		h.bps = 8;
		h.ctype = (i.hasPalette) ? 3 : 6;
		h.comp = 0;
		h.filter = 0;
		h.interlace = 0;

		writeIHDR();
		if (i.hasPalette) writePLTE();
		writetRNS();
		writeIDAT();
		writeIEND();

		return true;
	}

	override Image read(Stream s) {
		PNG_IHDR h;

		uint Bpp;
		Image i;
		ubyte[] buffer;
		uint size, crc;
		ubyte[4] type;
		bool finished = false;

		if (!check(s)) throw(new Exception("Not a PNG file"));

		while (!finished && !s.eof) {
			s.read(size); size = bswap(size);
			s.read(type);
			uint pos = s.position;

			//writefln("%s", cast(char[])type);

			switch (cast(char[])type) {
				case "IHDR":
					s.read((cast(ubyte *)&h)[0..h.sizeof]);
					h.width = bswap(h.width); h.height = bswap(h.height);

					switch (h.ctype) {
						case 4: case 0: throw(new Exception("Grayscale images not supported yet"));
						case 2: Bpp = 3; break; // RGB
						case 3: Bpp = 1; break; // Index
						case 6: Bpp = 4; break; // RGBA
						default: throw(new Exception("Invalid image type"));
					}

					i = (Bpp == 1) ? cast(Image)(new Bitmap8(h.width, h.height)) : cast(Image)(new Bitmap32(h.width, h.height));
				break;
				case "PLTE":
					if (size % 3 != 0) throw(new Exception("Invalid Palette"));
					i.ncolor = size / 3;
					for (int n = 0; n < i.ncolor; n++) {
						RGBA c;
						s.read(c.r);
						s.read(c.g);
						s.read(c.b);
						c.a = 0xFF;
						i.color(n, c);
					}
				break;
				case "tRNS":
					if (Bpp == 1) {
						if (size != i.ncolor) throw(new Exception(std.string.format("Invalid Transparent Data (%d != %d)", size, i.ncolor)));
						for (int n = 0; n < i.ncolor; n++) {
							RGBA c = i.color(n);
							s.read(c.a);
							i.color(n, c);
						}
					} else {
						throw(new Exception(std.string.format("Invalid Transparent Data (%d != %d) 32bits", size, i.ncolor)));
					}
				break;
				case "IDAT":
					ubyte[] temp; temp.length = size;
					s.read(temp); buffer ~= temp;
				break;
				case "IEND":
					ubyte[] idata = cast(ubyte[])std.zlib.uncompress(buffer);
					ubyte *pdata = void;

					ubyte[] row, prow;

					prow.length = Bpp * (h.width + 1);
					row.length = prow.length;

					ubyte PaethPredictor(int a, int b, int c) {
						int babs(int a) { return (a < 0) ? -a : a; }
						int p = a + b - c; int pa = babs(p - a), pb = babs(p - b), pc = babs(p - c);
						if (pa <= pb && pa <= pc) return a; else if (pb <= pc) return b; else return c;
					}

					for (int y = 0; y < h.height; y++) {
						int x;

						pdata = idata.ptr + (1 + Bpp * h.width) * y;
						ubyte filter = *pdata; pdata++;

						switch (filter) {
							default: throw(new Exception(std.string.format("Row filter 0x%02d unsupported", filter)));
							case 0: for (x = Bpp; x < row.length; x++, pdata++) row[x] = *pdata; break; // Unfiltered
							case 1: for (x = Bpp; x < row.length; x++, pdata++) row[x] = *pdata + row[x - Bpp]; break; // Sub
							case 2: for (x = Bpp; x < row.length; x++, pdata++) row[x] = *pdata + prow[x]; break; // Up
							case 3: for (x = Bpp; x < row.length; x++, pdata++) row[x] = *pdata + (row[x - Bpp], prow[x]) >> 1; break; // Average
							case 4: for (x = Bpp; x < row.length; x++, pdata++) row[x] = *pdata + PaethPredictor(row[x - Bpp], prow[x], prow[x - Bpp]); break; // Paeth
						}

						prow[0..row.length] = row[0..row.length];

						ubyte *rowp = row.ptr + Bpp;
						for (x = 0; x < h.width; x++) {
							if (Bpp == 1) {
								i.set(x, y, *rowp++);
							} else {
								RGBA c;
								c.r = *rowp++;
								c.g = *rowp++;
								c.b = *rowp++;
								c.a = (Bpp == 4) ? *rowp++ : 0xFF;
								i.set(x, y, c.v);
							}
						}
					}
					//writefln("%d", pdata - idata.ptr);
					//writefln("%d", idata.length);
					finished = true;
				break;
				default: break;
			}
			s.position = pos + size;
			s.read(crc);
			//break;
		}

		return i;
	}

	override bool check(Stream s) {
		ubyte[] cheader; cheader.length = header.length;
		s.read(cast(ubyte[])cheader);
		return (cheader == header);
	}
}

// http://local.wasp.uwa.edu.au/~pbourke/dataformats/tga/
class ImageFileFormat_TGA : ImageFileFormat {
	align(1) struct TGA_Header {
	   char  idlength;
	   char  colourmaptype;
	   char  datatypecode;
	   short colourmaporigin;
	   short colourmaplength;
	   char  colourmapdepth;
	   short x_origin;
	   short y_origin;
	   short width;
	   short height;
	   char  bitsperpixel;
	   char  imagedescriptor;
	}

	override char[] identifier() { return "tga"; }

	RGBA RGBA_BGRA(RGBA ic) {
		RGBA oc;
		oc.vv[0] = ic.vv[2]; oc.vv[1] = ic.vv[1];
		oc.vv[2] = ic.vv[0]; oc.vv[3] = ic.vv[3];
		return oc;
	}

	override bool write(Image i, Stream s) {
		TGA_Header h;

		h.idlength = 0;
		h.x_origin = 0;
		h.y_origin = 0;
		h.width = i.width;
		h.height = i.height;
		h.colourmaporigin = 0;
		h.imagedescriptor = 0b_00_1_0_1000;

		if (i.hasPalette) {
			h.colourmaptype = 1;
			h.datatypecode = 1;
			h.colourmaplength = i.ncolor;
			h.colourmapdepth = 32;
			h.bitsperpixel = 8;
		} else {
			h.colourmaptype = 0;
			h.datatypecode = 2;
			h.colourmaplength = 0;
			h.colourmapdepth = 0;
			h.bitsperpixel = 32;
		}

		s.writeExact(&h, h.sizeof);

		// CLUT
		if (i.hasPalette) {
			for (int n = 0; n < i.ncolor; n++) s.write(RGBA_BGRA(i.color(n)).v);
		}

		ubyte[] data;
		data.length = h.width * h.height * (i.hasPalette ? 1 : 4);
		//writef("(%dx%d)", h.width, h.height);

		ubyte *ptr = data.ptr;
		if (i.hasPalette) {
			for (int y = 0; y < h.height; y++) for (int x = 0; x < h.width; x++) {
				*ptr = cast(ubyte)i.get(x, y);
				ptr++;
			}
		} else {
			for (int y = 0; y < h.height; y++) for (int x = 0; x < h.width; x++) {
				RGBA c; c.v = i.get(x, y);
				*cast(uint *)ptr = RGBA_BGRA(c).v;
				ptr += 4;
			}
		}

		s.write(data);

		return false;
	}
}

static this() {
	ImageFileFormatProvider.registerFormat(new ImageFileFormat_PNG);
	ImageFileFormatProvider.registerFormat(new ImageFileFormat_TGA);
}