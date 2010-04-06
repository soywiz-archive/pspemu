module pspemu.gui.HexEditor;

import dfl.all, dfl.internal.winapi, dfl.internal.utf;
//import dfl.graphicsbuffer;

import std.intrinsic, std.stdio, std.string, std.stream, std.file, std.algorithm;

import pspemu.gui.Utils;
import pspemu.core.Memory;

alias dfl.splitter.Splitter Splitter;

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
	
	Button findButton, cancelButton2;
	GroupBox searchForGroup, optionsGroup;
	ContainerControl leftContentGroup;
	ComboBox searchTextBox; 
	ComboBox searchSearchType, searchInputType, searchEncodingType, searchEndianType;

	class SearchForm : Form {
		this() {
			text = "Find";
			showInTaskbar = false;
			setClientSizeCore(400, 184);
			controlBox  = true;
			minimizeBox = false;
			maximizeBox = false;
			topMost = true;
			formBorderStyle = FormBorderStyle.FIXED_SINGLE;

			{ // CreateRightButtonsGroup
				ContainerControl containerControl;

				with (containerControl = new ContainerControl) {
					dock = DockStyle.RIGHT;
					width = 120;
					parent = this;
					dockPadding.all = 8;
					dockPadding.top = 14;
				}

				with (findButton = new Button) {
					text = "&Find";
					dock = DockStyle.TOP;
					parent = containerControl;
				}

				with (cancelButton2 = new Button) {
					dock = DockStyle.TOP;
					dockPadding.top = 8;
					text = "&Cancel";
					parent = containerControl;
					click ~= (Control c, EventArgs ea) { this.close(); };
				}
			}
			
			{ // CreateLeftContentGroup
				with (leftContentGroup = new ContainerControl) {
					dock = DockStyle.FILL;
					parent = this;
					dockPadding.all = 8;
				}

				{ // CreateLeftSearchForGroup
					with (searchForGroup = new GroupBox) {
						dock = DockStyle.TOP;
						text = "Search for:";
						parent = leftContentGroup;
						dockPadding.all = 0;
						height = 74;
					}

					with (searchTextBox = new ComboBox) {
						dropDownStyle = ComboBoxStyle.DROP_DOWN;
						text = "";
						parent = searchForGroup;
						dock = DockStyle.TOP;
					}

					with (searchInputType = new ComboBox) {
						dropDownStyle = ComboBoxStyle.DROP_DOWN_LIST;
						dock = DockStyle.BOTTOM;
						foreach (itemText; ["Text Search", "Hexadecimal Search", "Integer Search", "Float Search"]) {
							auto label = new Label;
							label.text = itemText;
							items.add(label);
						}
						text = "";
						parent = searchForGroup;
						searchInputType.textChanged ~= (Control c, EventArgs ea) { checkConstraints(); };
					}
				}
				
				{ // CreateLeftOptionsGroup
					with (optionsGroup = new GroupBox) {
						dock = DockStyle.FILL;
						text = "Options:";
						parent = leftContentGroup;
						dockPadding.all = 0;
					}
					
					with (searchSearchType = new ComboBox) {
						dropDownStyle = ComboBoxStyle.DROP_DOWN_LIST;
						foreach (itemText; ["Normal Search", "Case Insensitive", "Relative Search", "Pattern Search"]) {
							auto label = new Label;
							label.text = itemText;
							items.add(label);
						}
						text = "";
						dock = DockStyle.TOP;
						parent = optionsGroup;
					}
					with (searchEncodingType = new ComboBox) {
						dropDownStyle = ComboBoxStyle.DROP_DOWN_LIST;
						foreach (itemText; ["8 bit (normal)", "16 bits (unicode)", "32 bits", "Variable (last bit extend)", "UTF-8", "Shift-JIS (japanese)"]) {
							auto label = new Label;
							label.text = itemText;
							items.add(label);
						}
						text = "";
						dock = DockStyle.TOP;
						parent = optionsGroup;
					}
					with (searchEndianType = new ComboBox) {
						dropDownStyle = ComboBoxStyle.DROP_DOWN_LIST;
						foreach (itemText; ["Little Endian (intel/psp)", "Big Endian (morotola)"]) {
							auto label = new Label;
							label.text = itemText;
							items.add(label);
						}
						text = "";
						dock = DockStyle.TOP;
						parent = optionsGroup;
					}
				}
				icon = null;
			}

			handleCreated ~= (Control c, EventArgs ea) {
				searchSearchType.selectedIndex = 0;
				searchInputType.selectedIndex = 0;
				searchEncodingType.selectedIndex = 0;
				searchEndianType.selectedIndex = 0;
				checkConstraints();
			};
			
			activated ~= (Control c, EventArgs ea) {
				searchTextBox.focus();
				opacity = 1.0;
			};
			
			deactivate ~= (Control c, EventArgs ea) {
				opacity = 0.9;
			};
			
			startPosition = FormStartPosition.CENTER_SCREEN;
			acceptButton = findButton;
			cancelButton = cancelButton2;
		}
		
		void checkConstraints() {
			searchSearchType.enabled   = (searchInputType.selectedIndex == 0);
			searchEncodingType.enabled = (searchInputType.selectedIndex == 0);
		}
	}

	HighLight[] highLights;
	CachedRowLine[ulong] cachedRowLines;
	Font font;
	Stream _stream;
	Stream stream() { return _stream; }
	Stream stream(Stream _streamToSet) {
		_stream = _streamToSet;
		scrollSize = Size(0, cast(uint)((_stream.size / 0x10) * sizeHex.height));
		//scrollPosition = Point(0, 0);
		cachedRowLines = null;
		invalidate();
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

	SearchForm searchForm;

	void showSearchForm() {
		if (searchForm is null || !searchForm.visible) searchForm = new SearchForm();
		searchForm.show();
	}

	this() {
		//showSearchForm();

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

class HexViewerForm : Form {
	mixin MenuAdder;

	Memory memory;
	HexEditorComponent[] hexs;
	real[] divisors;
	int dontUpdateComponents;
	string currentFileName = "<none>";

	void updateTitle() {
		text = std.string.format("Hex Viewer :: %s", currentFileName);
	}

	void getUpdatedComponents(int lastIndex = 10) {
		if (dontUpdateComponents) return;
		auto totalHeight = clientSize.height;
		int acumm = 0;
		foreach (n, hex; hexs) {
			acumm += hex.height;
			if (n >= lastIndex) break;
			if (n < hexs.length - 1) divisors[n] = cast(real)acumm / cast(real)totalHeight;
		}
	}

	void updateComponents() {
		auto totalHeight = cast(real)clientSize.height;
		int upToHeight = 0;
		foreach (n, divisor; divisors) {
			hexs[n].height = cast(int)(totalHeight * divisor) - upToHeight;
			upToHeight += hexs[n].height;
		}
	}

	int numberOfViews(int count) {
		if (count < 1) count = 1;
		if (count > hexs.length) count = hexs.length;
		foreach (n, divisor; divisors) {
			divisors[n] = cast(real)(n + 1) / cast(real)count;
		}
		updateComponents();
		return count;
	}
	
	int numberOfViews() {
		int count = 0;
		foreach (n, divisor; divisors) if (divisor < 1.0) count++;
		return count;
	}

	Stream stream(Stream stream) {
		foreach (hex; hexs) hex.stream = stream;
		return stream;
	}

	this(Memory memory = null) {
		if (memory is null) memory = new Memory;
		this.memory = memory;
		menu = new MainMenu;
		icon = Application.resources.getIcon(101);
		
		addMenu("&File", {
			addMenu("&Open file...", (MenuItem mi, EventArgs ea) {
				auto fd = new OpenFileDialog;
				fd.filter  = "All files (*.*)|*.*";
				if (fd.showDialog(this) == DialogResult.OK) {
					stream = new std.stream.File(fd.fileName);
					currentFileName = fd.fileName;
					updateTitle();
				}
			});
			addMenu("Open &memory", (MenuItem mi, EventArgs ea) {
				stream = memory;
				currentFileName = "<memory>";
				updateTitle();
			});
		});
		addMenu("&Edit", {
			addMenu("Search...", (MenuItem mi, EventArgs ea) {
				hexs[0].showSearchForm();
			});
			addMenu("Go to address...");
		});
		addMenu("&Views", {
			addMenu("1 view" , (MenuItem mi, EventArgs ea) { numberOfViews = 1; });
			addMenu("2 views", (MenuItem mi, EventArgs ea) { numberOfViews = 2; });
			addMenu("3 views", (MenuItem mi, EventArgs ea) { numberOfViews = 3; });
			addMenu("4 views", (MenuItem mi, EventArgs ea) { numberOfViews = 4; });
		});
		
		updateTitle();
		backColor = Color(255, 255, 255);
		startPosition = FormStartPosition.CENTER_SCREEN;
		setClientSizeCore(480, 320);
		
		hexs.length = 4;
		divisors.length = hexs.length - 1;
		
		ContainerControl lastParent = this;

		for (int n = 0; n < hexs.length; n++) {
			if (n % 2) {
				ContainerControl containerControl;
				with (containerControl = new ContainerControl) {
					dock = DockStyle.FILL;
					parent = lastParent;
				}
				lastParent = containerControl;
			}
			
			with (hexs[n] = new HexEditorComponent) {
				parent = lastParent;
				//stream = new std.stream.File("sandbox/sse.d");
				//stream = new std.stream.File("gui_test.exe");
				stream = memory;
				dock = DockStyle.TOP;
			}
		
			if (n < hexs.length - 1) {
				with (new Splitter()) {
					parent = lastParent;
					dock = DockStyle.TOP;
					backColor = Color(0xAF, 0xAF, 0xAF);
					minSize = 32;
					size = Size(0, 4);
					tag = cast(Object)cast(void*)n;
					move ~= (Control c, EventArgs ea) {
						int n = cast(int)cast(void*)c.tag;
						with (new Timer) {
							interval = 1;
							tick ~= (Timer t, EventArgs ea) {
								getUpdatedComponents(n + 1);
								updateComponents();
								stop();
							};
							start();
						}
						
					};
				}
			} else {
				hexs[n].dock = DockStyle.FILL;
			}
		}

		resize ~= (Control c, EventArgs ea) {
			dontUpdateComponents++;
			with (new Timer) {
				interval = 100;
				tick ~= (Timer t, EventArgs ea) {
					dontUpdateComponents--;
					stop();
				};
				start();
			}
			//writefln("[1]");
			updateComponents();
		};

		numberOfViews = 1;
	}

	override void onMouseWheel(MouseEventArgs ea) {
		hexs[0].onMouseWheel(ea);
		//writefln("wheel!");
	}

	override void onKeyDown(KeyEventArgs ea) {
		//ea.delta *= 5;
		hexs[0].onKeyDown(ea);
	}

	override void onKeyPress(KeyPressEventArgs ea) {
		//ea.delta *= 5;
		hexs[0].onKeyPress(ea);
	}
}
