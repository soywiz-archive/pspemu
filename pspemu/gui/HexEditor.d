module pspemu.gui.HexEditor;

import dfl.all, dfl.internal.winapi, dfl.internal.utf;
//import dfl.graphicsbuffer;

import std.intrinsic, std.stdio, std.string, std.stream, std.file, std.algorithm;

//class HexEditorComponent : DoubleBufferedControl {
//class HexEditorComponent : ScrollableControl {
//class HexEditorComponent : DoubleBufferedControl {
class HexEditorComponent : UserControl {
	struct HighLight {
		ulong from, to;
		Color colorBorder, colorBackground, colorText;
	}

	struct CachedRowLine {
		ulong baseAddress;
		uint  usedCount;
		Graphics graphics;
	}

	HighLight[] highLights;
	CachedRowLine[ulong] cachedRowLines;
	Font font;
	Stream _stream;
	Stream stream() { return _stream; }
	Stream stream(Stream _streamToSet) {
		_stream = _streamToSet;
		scrollSize = Size(0, cast(uint)((_stream.size / 0x10) * sizeHex.height));
		return _stream;
	}
	Color colorAddress;
	Color colorHex;
	Color colorText;

	int hexMargin = 4;
	int marginBetweenAddressAndHex = 8;
	int marginBetweenHexAndText = 8;
	
	Rect rectAddress, rectHex, rectText;
	Size sizeAddress, sizeHex, sizeText, sizeTotal;
	Graphics[0x100] glyphCache;

	this() {
		font = new Font("Courier New", 10, GraphicsUnit.PIXEL);
		fontUpdate();
		
		colorAddress = Color(0, 0, 255);
		colorHex  = Color(0, 0, 0);
		colorText = Color(0, 0, 0);
		
		backColor = Color(255, 255, 255);

		//stream = new std.stream.BufferedFile("gui_test.exe");

		HighLight mark;
		mark.from = 0x08;
		mark.to   = 0x19;
		mark.colorBorder = Color(0xFF, 0, 0);
		mark.colorBackground = Color(0xFF, 0xF0, 0xF0);
		mark.colorText = Color(0x00, 0x00, 0x00);
		highLights ~= mark;
		
		hScroll = true;
		autoScale = false;
		
		with (new Timer) {
			interval = 10;
			tick ~= (Timer sender, EventArgs ea) {
				if (updatedPosition) {
					lastRowPosition = rowPosition;
					invalidate();
				}
			};
			start();
		}
	}

	void fontUpdate() {
		auto g = new MemoryGraphics(1, 1);
		sizeAddress = g.measureText("00000000", font);
		sizeHex = g.measureText("00", font);
		sizeText = g.measureText("0", font);
		
		rectAddress = Rect(0, 0, sizeAddress.width, sizeAddress.height);
		rectHex     = Rect(rectAddress.x + rectAddress.width + marginBetweenAddressAndHex, 0, sizeHex.width * 16 + hexMargin * 15, sizeHex.height);
		rectText    = Rect(rectHex.x + rectHex.width + marginBetweenHexAndText, 0, sizeText.width * 16, sizeText.height);
		sizeTotal   = Size(rectText.x + rectText.width, rectText.y + rectText.height);
		for (int n = 0; n < glyphCache.length; n++) {
			Graphics gg = new MemoryGraphics(sizeText.width, sizeText.height);
			string sc = ".";
			try {
				if (n >= 0x20) sc = std.string.format("%s", cast(char)n);
			} catch {
			}

			Rect rect = Rect(Point(0, 0), sizeText);
			gg.fillRectangle(Color(255, 255, 255), rect);
			gg.drawText(sc, font, colorHex, rect);	
			glyphCache[n] = gg;
		}
	}

	void drawAddressColumn(ulong address, Graphics g, Point point) {
		string s = std.string.format("%08X", address);
		Rect rect = Rect(point, Size(1024, 1024));
		foreach (c; s) {
			g.drawText([c], font, colorAddress, rect);	
			rect.x += sizeText.width;
		}
	}
	
	void drawHexColumn(ubyte[] data, Graphics g, Point point) {
		foreach (k, c; data) {
			//g.drawText(std.string.format("%02X", c), font, colorHex, Rect(point.x, point.y, 1024, 1024));	
			string s = std.string.format("%02X", c);
			for (int n = 0; n < 2; n++) {
				glyphCache[s[n]].copyTo(g, Rect(point, sizeText));
				point += Size(sizeText.width, 0);
			}
			point += Size(hexMargin, 0);
		}
	}

	void drawTextColumn(ubyte[] data, Graphics g, Point point) {
		foreach (k, c; data) {
			string sc = ".";
			try {
				if (c >= 0x20) {
					sc = std.string.format("%s", cast(char)c);
				}
			} catch {
			}
			foreach (cc; sc) {
				//g.drawText(std.string.format("%s", sc), font, colorText, Rect(point.x, point.y, 1024, 1024));	
				glyphCache[cc].copyTo(g, Rect(point, sizeText));
				point += Size(sizeText.width, 0);
			}
			//point += Size(32, 0);
		}
	}

	void drawAddressColumn(ulong address, Graphics g) { drawAddressColumn(address, g, rectAddress.location); }
	void drawHexColumn(ubyte[] data, Graphics g) { drawHexColumn(data, g, rectHex.location); }
	void drawTextColumn(ubyte[] data, Graphics g) { drawTextColumn(data, g, rectText.location); }

	bool updatedPosition() {
		return lastRowPosition != rowPosition;
	}
	
	ulong rowPosition() {
		return (scrollPosition.y / sizeHex.height);
	}
	
	ulong lastRowPosition;

	Graphics getTextRow(ulong position) {
		CachedRowLine* row = (position in cachedRowLines);
		if (row is null) {
			if (cachedRowLines.length > 128) {
				auto rows = cachedRowLines.values;
				sort!("a.usedCount < b.usedCount")(rows);
				foreach (crow; rows) {
					auto key = crow.baseAddress;
					if (cachedRowLines.length < 128) continue;
					cachedRowLines.remove(key);
				}
			}
		
			auto rect = Rect(Point(0, 0), sizeTotal);
			auto g = new MemoryGraphics(rect.width, rect.height);
			
			g.fillRectangle(backColor, rect);
			if (((stream is null) && position == 0) || (position < stream.size)) {
				drawAddressColumn(position, g);
				if (stream !is null) {
					auto sliceStream = new SliceStream(stream, position, position + 0x10);
					ubyte[16] data;
					int dataSize = sliceStream.read(data);
					drawHexColumn(data[0..dataSize], g);
					drawTextColumn(data[0..dataSize], g);
				}
			}
			cachedRowLines[position] = CachedRowLine(position, 0, g);
			row = position in cachedRowLines;
		}
		
		row.usedCount++;
		
		return row.graphics;
	}
	
	void onResize(EventArgs ea) {
		invalidate();
	}
	
	override void onVisibleChanged(EventArgs ea) {
	}
	
	override void onMouseWheel(MouseEventArgs ea) {
		//ea.delta *= 5;
		super.onMouseWheel(ea);
	}

	override void onKeyDown(KeyEventArgs ea) {
		writefln("keyDown!");
		//ea.delta *= 5;
		super.onKeyDown(ea);
	}
	
	override void onKeyPress(KeyPressEventArgs ea) {
		writefln("onKeyPress!");
		//ea.delta *= 5;
		super.onKeyPress(ea);
	}
	
	override void onMouseDown(MouseEventArgs mea) {
		writefln("down!");
	}

	override void onMouseUp(MouseEventArgs mea) {
		writefln("onMouseUp!");
	}
	
	override void onPaintBackground(PaintEventArgs pea) { }
	
	override Rect displayRectangle() {
		return Rect(Point(0, 0), clientSize);
	}

	protected override void onPaint(PaintEventArgs ea) {
		auto g = ea.graphics;
		Rect clipRectangle = ea.clipRectangle;
		//writefln("%s", scrollPosition.y & ~0xF);
		//writefln("Rect(%s, %s, %s, %s)", displayRectangle.x, displayRectangle.y, displayRectangle.width, displayRectangle.height);
		Graphics[] list;

		int rowCount = (clipRectangle.height / sizeHex.height) + 1;

		for (int n = 0; n < rowCount; n++) {
			int pn = cast(int)(rowPosition + n);
			list ~= getTextRow(pn * 0x10);
		}
		for (int n = 0; n < rowCount; n++) {
			list[n].copyTo(g, Rect(0, n * sizeHex.height, 1000, 1000));
		}

		g.fillRectangle(backColor, Rect(Point(sizeTotal.width, 0), Size(clipRectangle.width, clipRectangle.height)));
	}

	void onMouseMove(MouseEventArgs mea) {
		if (rectAddress.contains(Point(mea.x, 5))) {
			cursor = Cursors.arrow;
		} else if (rectHex.contains(Point(mea.x, 5))) {
			cursor = Cursors.iBeam;
		} else if (rectText.contains(Point(mea.x, 5))) {
			cursor = Cursors.iBeam;
		} else {
			cursor = Cursors.arrow;
		}
	}
}
