module pspemu.gui.HexEditorForm;

import dfl.all, dfl.internal.winapi, dfl.internal.utf;
//import dfl.graphicsbuffer;

import std.intrinsic, std.stdio, std.string, std.stream, std.file, std.algorithm;

import pspemu.gui.Utils;
import pspemu.core.Memory;

alias dfl.splitter.Splitter Splitter;

import pspemu.gui.HexEditor;

class HexEditorForm : Form {
	mixin MenuAdder;

	Memory memory;
	HexEditorComponent[] hexs;
	real[] divisors;
	int dontUpdateComponents;
	string currentFileName = "<memory>";
	
	HexEditorComponent currentHex() {
		return hexs[0];
	}

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

	void openFile(string fileName) {
		stream = new std.stream.File(fileName);
		currentFileName = fileName;
		updateTitle();
	}

	void openFileDialog() {
		auto fd = new OpenFileDialog;
		fd.filter  = "All files (*.*)|*.*";
		if (fd.showDialog(this) == DialogResult.OK) openFile(fd.fileName);
	}

	void openMemory() {
		stream = memory;
		currentFileName = "<memory>";
		updateTitle();
	}

	this(Memory memory = null) {
		//addShortcut(Keys.UP, (Object sender, FormShortcutEventArgs ea) { writefln("UP"); });
		if (memory is null) memory = new Memory;
		this.memory = memory;
		menu = new MainMenu;
		icon = Application.resources.getIcon(101);
		
		addMenu("&File", {
			addMenu("&Open file...\tCtrl+O", (MenuItem mi, EventArgs ea) { openFileDialog(); });
			addMenu("Open &memory\tCtrl+M" , (MenuItem mi, EventArgs ea) { openMemory(); });
		});
		addMenu("&Edit", {
			addMenu("&Find...\tCtrl+F", (MenuItem mi, EventArgs ea) {
				currentHex.showSearchForm();
			});
			addMenu("&Go to address...\tCtrl+G", (MenuItem mi, EventArgs ea) {
				currentHex.showGotoForm();
			});
		});
		addMenu("&Views", {
			addMenu("1 view\tAlt+1" , (MenuItem mi, EventArgs ea) { numberOfViews = 1; });
			addMenu("2 views\tAlt+2", (MenuItem mi, EventArgs ea) { numberOfViews = 2; });
			addMenu("3 views\tAlt+3", (MenuItem mi, EventArgs ea) { numberOfViews = 3; });
			addMenu("4 views\tAlt+4", (MenuItem mi, EventArgs ea) { numberOfViews = 4; });
		});
		addShortcut(Keys.ALT | Keys.D1, (Object sender, FormShortcutEventArgs ea) { numberOfViews = 1; });
		addShortcut(Keys.ALT | Keys.D2, (Object sender, FormShortcutEventArgs ea) { numberOfViews = 2; });
		addShortcut(Keys.ALT | Keys.D3, (Object sender, FormShortcutEventArgs ea) { numberOfViews = 3; });
		addShortcut(Keys.ALT | Keys.D4, (Object sender, FormShortcutEventArgs ea) { numberOfViews = 4; });
		addShortcut(Keys.CONTROL | Keys.F, (Object sender, FormShortcutEventArgs ea) { currentHex.showSearchForm(); });
		addShortcut(Keys.CONTROL | Keys.G, (Object sender, FormShortcutEventArgs ea) { currentHex.showGotoForm(); });
		addShortcut(Keys.CONTROL | Keys.O, (Object sender, FormShortcutEventArgs ea) { openFileDialog(); });
		addShortcut(Keys.CONTROL | Keys.M, (Object sender, FormShortcutEventArgs ea) { openMemory(); });
		
		updateTitle();
		backColor = Color(255, 255, 255);
		//startPosition = FormStartPosition.CENTER_SCREEN;
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

		openFile("gui_test.exe");
		//openMemory();
	}

	override void onMouseWheel(MouseEventArgs ea) {
		currentHex.onMouseWheel(ea);
		//writefln("wheel!");
	}

	override void onKeyDown(KeyEventArgs ea) {
		//ea.delta *= 5;
		//currentHex.onKeyDown(ea);
	}

	override void onKeyPress(KeyPressEventArgs ea) {
		//ea.delta *= 5;
		//currentHex.onKeyPress(ea);
	}
}
