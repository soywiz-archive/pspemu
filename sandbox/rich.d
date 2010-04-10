private import dfl.all, dfl.internal.winapi;

import std.stdio, std.stream;

T sign(T)(T a) { if (a == 0) return 0; return (a > 0) ? 1 : -1; }
T min(T)(T a, T b) { return (a < b) ? a : b; }
T max(T)(T a, T b) { return (a > b) ? a : b; }

// http://msdn.microsoft.com/en-us/library/ff485923(v=VS.85).aspx
class RichTextBoxEx : RichTextBox {
	bool readOnly(bool set) {
		if (created) {
			SendMessageA(handle, EM_SETREADONLY, cast(WPARAM)set, 0);
			//Edit_SetReadOnly(handle, set);
		} else {
			writefln("aaaaaaaaaaaaaa");
		}
		return set;
	}
	int getLineIndex(int line) {
		return SendMessageA(handle, EM_LINEINDEX, cast(WPARAM)line, 0);
	}
}

class HexTextBox : RichTextBoxEx {
	Stream stream;
	uint lastFocusCur;
	
	long lines = 40;

	void updateText() {
		long low  = stream.position;
		long high = min(stream.size, stream.position + lines * 0x10);
		auto stream2 = new SliceStream(stream, low, high);
		long read = min(lines * 0x10, (high - low));
		
		ubyte[] data = cast(ubyte[])(stream2.readString(cast(uint)read));

		string t;		
		for (int n = 0, r = 0; n < lines; n++) {
			for (int m = 0; m < 0x10; m++, r++) {
				if (m != 0) t ~= " ";
				t ~= (r < data.length) ? std.string.format("%02X", data[r]) : "  ";
			}
			t ~= "\n";
		}
		text = t[0..$ - 1];
	}

	void scrollBy(long rows) {
		long position = stream.position + rows * 0x10;
		if (position < 0) position = 0;
		if (position > stream.size) position = stream.size;
		if (position != stream.position) {
			stream.position = position;
			auto prevSelectionStart  = selectionStart;
			auto prevSelectionLength = selectionLength;
			updateText();
			selectionStart  = prevSelectionStart;
			selectionLength = prevSelectionLength;
		}
	}

	this() {
		stream = new std.stream.File("rich.d");
		scrollBars = RichTextBoxScrollBars.NONE;
		borderStyle = BorderStyle.NONE;
		wordWrap = false;
		dock = DockStyle.FILL;
		font = new Font("Courier New", cast(float)9, FontStyle.REGULAR);
		backColor = Color(0xFF, 0xFF, 0xFF);
		foreColor = Color(0x00, 0x00, 0x00);
		
		mouseUp ~= (Object sender, MouseEventArgs ea) {
		};

		gotFocus ~= (Object sender, EventArgs ea) {
			selectionLength = 0;
			selectionStart = lastFocusCur;
			readOnly = true;
			//writefln("line:%d", getLineIndex(1));
		};
		
		handleCreated ~= (Object sender, EventArgs ea) {
		};

		updateText();
	}

	override void onKeyPress(KeyPressEventArgs kea) {
	}
	
	override void onKeyDown(KeyEventArgs kea) {
	}

	override void onKeyUp(KeyEventArgs kea) {
	}

	bool pressingShift, pressingControl;
	
	override void wndProc(ref Message msg) {
		switch (msg.msg) {
			case WM_KEYDOWN: {
				Keys key = cast(Keys)msg.wParam;
				char keyc = cast(char)key;

				if ((selectionStart % 3) == 2) selectionStart  = selectionStart + 1;

				uint prevSelectionStart = selectionStart;
				
				//writefln("%08X:%08X:%s", msg.lParam, msg.wParam, pressingShift);
				
				void moveBy(int count, bool alignBytes = false) {
					int nextSelectionStart  = selectionStart;
					int nextSelectionLength = selectionLength;
					if (pressingShift) {
						/*
						if (count > 0) {
							nextSelectionLength = nextSelectionLength + count;
						} else {
							nextSelectionStart = nextSelectionStart + count;
							nextSelectionLength = nextSelectionLength - count;
						}
						*/
						nextSelectionLength = nextSelectionLength + count;
					} else {
						nextSelectionLength = 0;
						nextSelectionStart = nextSelectionStart + count;
					}
					if (nextSelectionStart < 0) {
						long scrollCount = ((nextSelectionStart + 1) / (0x10 * 3)) - 1;
						//writefln("scrollCount:%d", scrollCount);
						selectionStart = (0x10 * 3) - (-nextSelectionStart % (0x10 * 3));
						scrollBy(scrollCount);
						return;
					}
					if (nextSelectionStart > 0x10 * 3 * lines) {
						long scrollCount = ((nextSelectionStart - 1) - 0x10 * 3 * lines) / (0x10 * 3) + 1;
						//writefln("scrollCount:%d", scrollCount);
						selectionStart = 0x10 * 3 * (cast(int)lines - 1) + nextSelectionStart % (0x10 * 3);
						scrollBy(scrollCount);
						return;
					}
					if (alignBytes) {
						while ((nextSelectionStart  % 3)) nextSelectionStart--;
						while ((nextSelectionLength % 3)) nextSelectionLength++;
					} else {
						if ((nextSelectionStart  % 3) == 2) if (count > 0) nextSelectionStart++; else nextSelectionStart--;
						if ((nextSelectionLength % 3) == 2) nextSelectionLength++;
					}
					selectionStart  = nextSelectionStart;
					selectionLength = nextSelectionLength;
				}

				switch (key) {
					case Keys.SHIFT_KEY  : pressingShift   = true; break;
					case Keys.CONTROL_KEY: pressingControl = true; break;
					case Keys.PAGE_UP  : moveBy(-3 * 0x10 * cast(int)lines / 2, true); break;
					case Keys.PAGE_DOWN: moveBy(+3 * 0x10 * cast(int)lines / 2, true); break;
					case Keys.UP   : moveBy(-3 * 0x10, true); break;
					case Keys.DOWN : moveBy(+3 * 0x10, true); break;
					case Keys.LEFT : pressingControl ? moveBy(-1, false) : moveBy(-3, true); break;
					case Keys.RIGHT: pressingControl ? moveBy(+1, false) : moveBy(+3, true); break;
					default:
						//writefln("%d, %d", selectionStart, text.length);
						
						if (pressingControl && (keyc == 'C')) {
							break;
						}
						
						if ((keyc >= '0' && keyc <= '9') || (keyc >= 'A' && keyc <= 'F')) {
							selectionLength = 1;
							if (selectedText.length == 0) {
								selectionLength = 0;
								return;
							}
							//selectedRtf = "aaaa";
							selectionColor = Color(0xFF, 0, 0);
							selectedText = [keyc];
							if ((selectionStart % 3) == 2) {
								selectionStart = selectionStart + 1;
							}
						}
					break;
				}
				lastFocusCur = selectionStart;
				return;
			}
			case WM_KEYUP: {
				Keys key = cast(Keys)msg.wParam;
				char keyc = cast(char)key;

				switch (key) {
					case Keys.SHIFT_KEY  : pressingShift   = false; break;
					case Keys.CONTROL_KEY: pressingControl = false; break;
					default:
				}
				return;
			}

			case WM_CHAR: return;
			//case WM_LBUTTONDOWN: return;
			case WM_LBUTTONUP: return;
			//case WM_MOUSEMOVE: return;
			case WM_LBUTTONDBLCLK: return;
			case WM_RBUTTONUP: return;
			case 0x02A1, 0x0281, 0x0215: return;
			case WM_SETFOCUS, WM_PAINT, WM_ERASEBKGND, WM_MOUSEFIRST, 0x0434, 0x0437, WM_NCHITTEST, 0x02A3, WM_SETCURSOR, WM_MOUSEACTIVATE, WM_TIMER, WM_LBUTTONDOWN:
			break;
			default:
				//writefln("%04X", msg.msg);
		}
		{
			super.wndProc(msg);
		}
		switch (msg.msg) {
			case WM_LBUTTONDOWN, WM_MOUSEMOVE:
				//writefln("%d, %d", selectionStart, selectionLength);
				while (selectionStart  % 3) selectionStart  = selectionStart - 1;
				while (selectionLength % 3) selectionLength = selectionLength + 1;
			break;
			default:
		}
	}
}

int main() {
	Form form;
	HexTextBox hexTextBox;
	
	with(form = new Form) {
		text = "RichTextBox";
		size = Size(500, 640);
	}
	
	with (hexTextBox = new HexTextBox) {
		parent = form;
	}
	
	Application.run(form);
	return 0;
}

