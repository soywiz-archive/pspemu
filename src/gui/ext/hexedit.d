module hexedit;

import std.string;
import std.stdio;
import std.stream;
import std.thread;
import std.c.time;
import std.intrinsic;

import dfl.all, dfl.internal.winapi, dfl.internal.utf;
import dfl.graphicsbuffer;

class HexComponent : DoubleBufferedControl {
	long position = 0;
	Stream s;
	Font font;
	Size cell_s;
	Size cell_m;
	Point cursor;
	int ncols = 0x10;
	int nrows = 0x20;
	int nibble = 0;
	int column;
	
	Color black, white, blue, red, red2, grey, grey2;
	
	Pen p_sep;
	Timer t;
	
	bool mustRefresh = true;
	
	bool[0x1000] keysp;
	
	Event!(HexComponent, EventArgs) updatingCoords;
	
	
	void goTo(uint position) {
		cursor.y = 0;
		cursor.x = position % 0x10;
		this.position = position - cursor.x;
		mustRefresh = true;
	}
	
	long cursorPosition() {
		return position + cursor.y * ncols + cursor.x;
	}
	
	void setFont() {
		font = new Font("Lucida Console", 10, GraphicsUnit.PIXEL);		
		Graphics g = new MemoryGraphics(1, 1);
		cell_s = g.measureText("00", font);
		cell_m = Size(5, 1);
		cell_s += cell_m;
	}
	
	void doTick(Timer t, EventArgs ea) {
		if (mustRefresh) updateGraphics();
	}
		
	this() {
		setFont();

		black = Color(0x00, 0x00, 0x00);
		white = Color(0xFF, 0xFF, 0xFF);
		blue  = Color(0x00, 0x00, 0xFF);
		red   = Color(0xFF, 0xC0, 0xC0);
		red2  = Color(0xFF, 0x00, 0x00);
		grey  = Color(0x9F, 0x9F, 0x9F);
		grey2 = Color(0xF0, 0xF0, 0xF0);
		
		p_sep = new Pen(grey);
		
		t = new Timer();
		t.interval = 1000 / 50;
		t.tick ~= &doTick;
		t.start();
	}
	
	Size drawText(Graphics g, char[] str, Font font, Color color, int x, int y, int ax = -1, int ay = -1) {
		Size s = g.measureText(str, font);
		
		Rect tr = Rect(
			x - (s.width  * (ax + 1) >> 1),
			y - (s.height * (ay + 1) >> 1),
			s.width,
			s.height
		);
		
		g.drawText(str, font, color, tr);
		
		return s;
	}
	
	Size drawText(Graphics g, char[] str, Font font, Color color, Point p, int ax = -1, int ay = -1) {
		return drawText(g, str, font, color, p.x, p.y, ax, ay);
	}
	
	void drawRectangle(Graphics g, Color c, Point p, int width, int height) {
		g.fillRectangle(c, p.x, p.y, width, height);
	}
	
	Point XY_t(int column, int y, int x = 0) {
		const int leftStart = 60;
		switch (column) {
			default:
			case 0: return Point(leftStart / 2, y * cell_s.height + 18);
			case 1: return Point(leftStart + 8 + x * cell_s.width, y * cell_s.height + 18);
			case 2: return Point(leftStart + 16 + ncols * cell_s.width + x * (cell_s.width / 2 - 2), y * cell_s.height + 18);
		}		
	}
	
	Point Y(Point p) { return Point(0, p.y); }
	Point X(Point p) { return Point(p.x, 0); }
	
	Point XY_f(int x, int y) {
		Point min = XY_t(1, 0, 0), max = XY_t(1, nrows, ncols);
		
		if (x < min.x) x = min.x;
		if (y < min.y) y = min.y;
		
		if (x < min.x || x >= max.x || y < min.y || y >= max.y) throw(new Exception("Invalid"));
		
		return Point(
			(x - min.x) * ncols / (max.x - min.x),
			(y - min.y) * nrows / (max.y - min.y)
		);
	}
	
	bool NB_f(int x, int y) {
		return false;
	}
	
	protected void onMouseDown(MouseEventArgs mea) {
		if (!parent.focused) return;
		try {
			Point p = XY_f(mea.x, mea.y);
			nibble = NB_f(mea.x, mea.y);
			setCursor(p.x, p.y);
		} catch {
		}
	}
	
	protected void onMouseMove(MouseEventArgs mea) {
		if (!mea.button) return;
		onMouseDown(mea);
	}
	
	protected override void onBufferPaint(PaintEventArgs ea) {			
		//if (!mustRefresh) return;
		mustRefresh = false;
		updatingCoords(this, EventArgs.empty);

		Graphics g = ea.graphics;
		
		g.fillRectangle(white, 0, 0, width, height);
		
		int[] guides = [ XY_t(1, 0, 0).x - 6, XY_t(1, 0, ncols).x ];
		
		Point guide_p = XY_t(1, cursor.y, cursor.x) - Size(cell_m.width / 2, 0);
		
		drawRectangle(g, grey2, Y(guide_p), width, cell_s.height);
		drawRectangle(g, grey2, X(guide_p), cell_s.width, height);
		
		drawRectangle(g, red, guide_p, cell_s.width, cell_s.height);		
		
		if (column == 0) {
			if (nibble == 0) {
				drawRectangle(g, red2, guide_p, cell_s.width / 2, cell_s.height);
			} else {
				drawRectangle(g, red2, Point(guide_p.x + cell_s.width / 2, guide_p.y), cell_s.width / 2, cell_s.height);
			}
			drawRectangle(g, red, XY_t(2, cursor.y, cursor.x), cell_s.width / 2, cell_s.height);
		} else {
			drawRectangle(g, red2, XY_t(2, cursor.y, cursor.x), cell_s.width / 2, cell_s.height);
		}
		
		foreach (guide; guides) g.drawLine(p_sep, guide, 0, guide, height);		
		g.drawLine(p_sep, 0, 16, width, 16);
		
		drawText(g, "Offset", font, blue, X(XY_t(0, 0)) + Size(0, 3), 0, -1);

		for (int x = 0; x < ncols; x++) {			
			drawText(g, std.string.format("%02X", x), font, blue, X(XY_t(1, -1, x)) + Size(0, 3));
		}
		
		if (!s) return;
		
		position &= ~0x0F;

		s.position = position;
		
		for (int y = 0; y < 100; y++) {			
			Point p = XY_t(0, y); if (p.y + cell_s.height >= height) { nrows = y; break; }
		
			if (!s.eof) {
				drawText(g, std.string.format("%08X", s.position), font, blue, p, 0, -1);
				
				
				ubyte[] row_d = new ubyte[ncols];
				int max; try { max = s.read(row_d); } catch { }
				
				for (int x = 0; x < max; x++) {
					char c = cast(char)row_d[x];
					char[] cc = (c < 0x20 || c == 0x7f) ? "." : [c];
					drawText(g, std.string.format("%02X", row_d[x]), font, black, XY_t(1, y, x));				
					drawText(g, fromAnsi(cc.ptr, 1), font, black, XY_t(2, y, x));
				}
			}
		}
	}
		
	void moveCursor(int x, int y) {
		int ix = x / 2;
		
		if ( nibble && x > 0) ix++;
		if (!nibble && x < 0) ix--;
	
		if (x % 2) nibble = !nibble;
	
		cursor.x += ix;
		cursor.y += y;
		
		while (cursor.x < 0) {
			cursor.x = ncols + cursor.x;
			cursor.y--;
			if (cursor.y < 0 && position <= 0) cursor.x = 0;
		}

		while (cursor.x >= ncols) {
			cursor.x = cursor.x - ncols;
			cursor.y++;
		}
		
		while (cursor.y < 0) {
			cursor.y++;
			if (position >= ncols) position -= ncols;
		}
		
		while (cursor.y >= nrows) {
			if (cursor.y <= 0) break;			
			cursor.y--;
			
			if (position <= s.size - ncols) {
				position += ncols;								
			} else {
				nrows--;
			}
		}
		
		mustRefresh = true;
	}

	void setCursor(int x, int y) {
		cursor.x = x;
		cursor.y = y;
		mustRefresh = true;
	}
	
	void setCursorX(int x) {
		cursor.x = x;
		mustRefresh = true;
	}
		
	void keyChange(Keys key, bool pressed) {
		bool processed = false;
		keysp[key] = pressed;
		
		if (keysp[Keys.UP   ]) { processed = true; moveCursor( 0, -1); }
		if (keysp[Keys.DOWN ]) { processed = true; moveCursor( 0, +1); }
		if (keysp[Keys.LEFT ]) { processed = true; moveCursor(-1,  0); }
		if (keysp[Keys.RIGHT]) { processed = true; moveCursor(+1,  0); }
		
		if (keysp[Keys.HOME ]) { processed = true; setCursorX(0); }
		if (keysp[Keys.END  ]) { processed = true; setCursorX(ncols - 1); }

		if (keysp[Keys.PAGE_UP]) { processed = true; moveCursor(0, -((nrows >> 1) + 1)); }
		if (keysp[Keys.PAGE_DOWN]) { processed = true; moveCursor(0, +((nrows >> 1) + 1)); }
		
		if (keysp[Keys.TAB]) {
			processed = true;
			column = !column;
			mustRefresh = true;
		}
		
		if (!processed && pressed) {
			if (column == 0) {
				if ((key >= '0' && key <= '9') || (key >= 'A' && key <= 'F')) {
					int v = (key >= '0' && key <= '9') ? (key - '0') : (key - 'A' + 10);
				
					ubyte d;
					s.position = cursorPosition;
					s.read(d);
					s.position = cursorPosition;
					
					if (!nibble) {
						s.write(cast(ubyte)((d & 0x0F) | ((v << 4) & 0xF0)));
					} else {
						s.write(cast(ubyte)((d & 0xF0) | ((v << 0) & 0x0F)));
					}
					moveCursor(+1,  0);
				}
			}/* else {
				ubyte d = key;
				s.position = cursorPosition;
				nibble = false;
				s.write(d);
				//writefln("key");
				moveCursor(+2,  0);
			}*/
		}
	}
	
	void doKeyPress(Control c, KeyPressEventArgs kea) {
		//_value = tb.text;
		
		writefln(kea.keyCode);
		/*
		switch (kea.keyCode) {
			case Keys.ESCAPE: dialogResult = DialogResult.ABORT; close(); break;
			case Keys.ENTER: dialogResult = DialogResult.OK; close(); break;
			default:
		}*/
	}	
		
	void onKeyDown(KeyEventArgs kea) {
		keyChange(kea.keyCode, true);
	}

	void onKeyUp(KeyEventArgs kea) {
		keyChange(kea.keyCode, false);
	}
}
