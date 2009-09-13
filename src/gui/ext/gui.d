module gui;

import dfl.all, dfl.internal.winapi;
import dfl.graphicsbuffer;

import std.cpuid;

import std.c.time, std.c.string;
import std.stdio;
import std.path;
import std.stream;
import std.string;
import std.random;
import std.intrinsic;
import std.thread;
import std.conv;

import psp.disassembler.cpu;
import psp.loader, psp.bios, psp.bios_io;
import psp.memory, psp.cpu;
import psp.controller;
import expression;
import utils.common;

import simpleimage;
import hexedit, glcontrol;
import utils.joystick;

debug = debug_cpuid;

BIOS bios;

long getRegistry(char[] exp, out bool found)  {
	found = true;
	foreach (k, rn; CPU_Disasm.regName) if (exp == rn) return cpu.regs[k];
	
	if (exp == "pc") return cpu.regs.PC;
	if (exp == "hi") return cpu.regs.HI;
	if (exp == "lo") return cpu.regs.LO;
	found = false;
	return 0;
}

class AboutDialog : dfl.form.Form {
	dfl.label.Label label1;
	dfl.richtextbox.RichTextBox richTextBox1;
	
	this() {
		initializeAbout();
		//richTextBox1.selectionStart = 0;
		//richTextBox1.selectionLength = 1;
	}
	
	private void initializeAbout() {
		maximizeBox = false;
		minimizeBox = false;
		showInTaskbar = false;
		text = "About";
		topMost = true;
		formBorderStyle = dfl.all.FormBorderStyle.FIXED_TOOLWINDOW;
		clientSize = dfl.all.Size(464, 242);
		startPosition = dfl.all.FormStartPosition.CENTER_PARENT;
		label1 = new dfl.label.Label();
		label1.dock = dfl.all.DockStyle.TOP;
		label1.font = new dfl.all.Font("Arial", 18f, dfl.all.FontStyle.BOLD);
		label1.text = "PSP Emulator";
		label1.textAlign = dfl.all.ContentAlignment.MIDDLE_CENTER;
		label1.bounds = dfl.all.Rect(0, 0, 480, 24);
		label1.parent = this;
		richTextBox1 = new dfl.richtextbox.RichTextBox();
		richTextBox1.text = cast(char[])MyLoadResource("about_txt");
		richTextBox1.backColor = dfl.all.SystemColors.control;
		richTextBox1.dock = dfl.all.DockStyle.BOTTOM;
		richTextBox1.cursor = Cursors.arrow;
		richTextBox1.foreColor = dfl.all.Color.empty;
		richTextBox1.borderStyle = dfl.all.BorderStyle.NONE;
		richTextBox1.bounds = dfl.all.Rect(0, 26, 464, 216);
		richTextBox1.scrollBars = RichTextBoxScrollBars.FORCED_VERTICAL;
		richTextBox1.font = new dfl.all.Font("Lucida Console", 9f, dfl.all.FontStyle.REGULAR);
		richTextBox1.readOnly = true;
		richTextBox1.parent = this;
	}
}

class SimpleInputForm : Form {
	char[] _value;	
	TextBox tb;
	
	char[] value() {
		return _value;
	}

	char[] value(char[] v) {
		tb.text = v;				
		return _value = v;
	}
	
	this() {
		this("Input");
	}
	
	this(char[] title) {
		startPosition = FormStartPosition.CENTER_SCREEN;
		formBorderStyle = FormBorderStyle.FIXED_TOOLWINDOW;
		text = title;
		setClientSizeCore(256, 24);
		with (tb = new TextBox()) {
			parent = this;
			dock = DockStyle.FILL;
		}
		
		tb.keyPress ~= &doKeyPress;
	}
	
	void doKeyPress(Control c, KeyPressEventArgs kea) {
		_value = tb.text;
		
		switch (kea.keyCode) {
			case Keys.ESCAPE: dialogResult = DialogResult.ABORT; close(); break;
			case Keys.ENTER: dialogResult = DialogResult.OK; close(); break;
			default:
		}
	}
	
	protected void onLoad(EventArgs ea) {		
		tb.focus();
		tb.selectAll();
	}
}

class PSP_BreakpointsForm : Form {
	PSP_Mdi psp_mdi;
	ListView lview;

	this() { this(PSP_Mdi.singleton); }
	
	this(PSP_Mdi parent) {
		mdiParent = (this.psp_mdi = parent);
		setClientSizeCore(480, 120);				
		
		text = "Breakpoints";
		icon = Application.resources.getIcon(101);
		
		with (lview = new ListView) {
			dock = DockStyle.FILL;
			view = View.DETAILS;
			gridLines = true;
			fullRowSelect = true;
			
			ColumnHeader col;
			
			with (col = new ColumnHeader) {
				text = "Adress";
				width = 128 - 8;
			} columns.add(col);

			with (col = new ColumnHeader) {
				text = "Type";
				width = 128 - 8;
			} columns.add(col);

			with (col = new ColumnHeader) {
				text = "Count";
				width = 128 - 8;
			} columns.add(col);

			parent = this;
		}		
	}
	
	void updateForm() {
	}
}

class PSP_GPUForm : Form {
	PSP_Mdi psp_mdi;
	TreeView tview;

	this() { this(PSP_Mdi.singleton); }
	
	this(PSP_Mdi parent) {
		mdiParent = (this.psp_mdi = parent);
		setClientSizeCore(480, 120);				
		
		text = "GPU";
		icon = Application.resources.getIcon(101);
		
		tview = new TreeView;
		tview.dock = DockStyle.FILL;
		tview.parent = this;
	}
	
	void updateForm() {
	}
}

class PSP_CallstackForm : Form {
	PSP_Mdi psp_mdi;
	ListView lview;

	this() { this(PSP_Mdi.singleton); }
	
	this(PSP_Mdi parent) {
		mdiParent = (this.psp_mdi = parent);
		setClientSizeCore(128, 304);				
		
		text = "Callstack";
		icon = Application.resources.getIcon(101);
		
		minimumSize = Size(width, height / 4);
		maximumSize = Size(width, height * 10);

		with (lview = new ListView) {
			dock = DockStyle.FILL;
			view = View.DETAILS;
			gridLines = true;
			fullRowSelect = true;
			
			ColumnHeader col;
			
			with (col = new ColumnHeader) {
				text = "Adress";
				width = 128 - 8;
			} columns.add(col);

			parent = this;
		}
		
		lview.doubleClick ~= &doDoubleClick;
	}
	
	void updateForm() {
		uint[] callstack = cpu.callstack[0..cpu.callstack_length];
		char[] get(int idx) { return std.string.format("%08X", callstack[idx]); }
		while (lview.items.length > callstack.length) lview.items.remove(lview.items[lview.items.length - 1]);
		uint prevLength = lview.items.length;		
		while (lview.items.length < callstack.length) lview.items.add(new ListViewItem(get(lview.items.length)));
		for (int n = 0; n < prevLength; n++) lview.items[n].text = get(n);
	}
	
	uint get(uint idx) {
		return cpu.callstack[idx];
	}
	
	void doDoubleClick(Control c, EventArgs ea) {
		if (lview.selectedIndices.length == 0) return;
		uint idx = lview.selectedIndices[0];

		if (!psp_mdi.disasm) return;
		
		psp_mdi.disasm.goTo(get(idx));
		psp_mdi.disasm.focus();
	}	
}

class PSP_RegistersForm : Form {
	PSP_Mdi psp_mdi;
	ListView lview;
	
	char[][] list = ["PC", "HI", "LO"];
	
	this() { this(PSP_Mdi.singleton); }
	
	this(PSP_Mdi parent) {
		mdiParent = (this.psp_mdi = parent);
		
		text = "Registers";
		icon = Application.resources.getIcon(101);
		
		setClientSizeCore(128, 325);				
		
		minimumSize = Size(width, height / 2);
		maximumSize = Size(width, height * 10);
				
		with (lview = new ListView) {
			dock = DockStyle.FILL;
			view = View.DETAILS;
			gridLines = true;
			fullRowSelect = true;
			
			ColumnHeader col;
			
			with (col = new ColumnHeader) {
				text = "REG";
				width = 32;
			} columns.add(col);

			with (col = new ColumnHeader) {
				text = "HEX";
				width = 64;
			} columns.add(col);

			parent = this;
		}
		
		lview.doubleClick ~= &doDoubleClick;
		
		for (int n = 0; n < 32; n++) list ~= CPU_Disasm.reg(n);
		for (int n = 0; n < 32; n++) list ~= CPU_Disasm.fpreg(n);

		lview.clear();
		foreach (le; list) {
			auto lvi = new ListViewItem(le);
			lvi.subItems.add(new ListViewSubItem("-"));
			lview.items.add(lvi);
		}
		
		updateForm();
	}
	
	uint get(uint idx) {
		switch (idx) {
			case 0: return cpu.regs.PC;
			case 1: return cpu.regs.HI;
			case 2: return cpu.regs.LO;
			default: {
				int reg = (idx - 3) % 32;
				//return (reg / 32 == 0) ? cpu.regs[reg] : cpu.regs.f[reg];
				return ((idx - 3) / 32 == 0) ? cpu.regs[reg] : *(cast(int *)&cpu.regs.f[reg]);
			}
		}
	}

	float getf(uint idx) {
		uint v = get(idx);
		return *(cast(float *)&v);
	}
	
	void update(uint idx) {
		if (isFloat(idx)) {
			lview.items[idx].subItems[0].text = std.string.format("%f", getf(idx));
		} else {
			lview.items[idx].subItems[0].text = std.string.format("%08X", get(idx));
		}
	}
	
	void set(uint idx, uint value) {
		switch (idx) {
			case 0 : cpu.regs._PC = value; break;
			case 1 : cpu.regs.HI  = value; break;
			case 2 : cpu.regs.LO  = value; break;
			default:
				cpu.regs[idx - 3] = value;
				int reg = (idx - 3) % 32;
				if ((idx - 3) / 32 == 0) {
					cpu.regs[reg] = value;
				} else {
					cpu.regs.f[reg] = *(cast(float *)&value);
				}
			break;
		}
		
		update(idx);
	}
	
	bool isFloat(uint idx) {
		return (idx >= 3 + 32);
	}
	
	void setf(uint idx, float value) {
		set(idx, *(cast(uint *)&value));
	}

	void updateForm() {		
		lview.beginUpdate();
		for (int n = 0; n < lview.items.length; n++) update(n);
		lview.endUpdate();
		refresh();
	}
	
	void doDoubleClick(Control c, EventArgs ea) {
		if (lview.selectedIndices.length == 0) return;
	
		SimpleInputForm sif = new SimpleInputForm("Change value");
		
		uint idx = lview.selectedIndices[0];
		uint value = get(idx);
		
		sif.value = std.string.format("0x%08X", value);
		
		//sif.value = std.string.format("%08X", );
		if (sif.showDialog() == DialogResult.OK) {				
			uint v = Expression.evaluate(sif.value);
			set(idx, v);
			refresh();			
			//goTo(v);
		}
	}
}

interface IKeyListener {
	public void onKeyDownGlobal(KeyEventArgs kea);
	public void onKeyUpGlobal(KeyEventArgs kea);
	public bool hasFocus();
}

class PSP_DisasmForm : DoubleBufferedForm, IKeyListener {
	PSP_Mdi psp_mdi;
	int row = 0;
	Timer t;
	bool mustRefresh = true;
	int position = 0x08900008;
	Size form_m;
	int nrows = 10;
	int rowSize = 11;
	Font font;
	Font font2;
	int cPC, cnPC;
	
	Color blue, black, white, pink, pink2, grey, grey2, red;
	
	uint cursorPosition() {
		return position + row * 4;
	}
	
	void updatePC() {
		cPC = cpu.regs.PC;
		cnPC = cpu.regs.nPC;
	}
	
	void goTo(int position) {
		this.position = position - (nrows >> 1) * 4;
		row = (nrows >> 1);
		mustRefresh = true;
		updatePC();
	}
	
	this() { this(PSP_Mdi.singleton); }

	this(PSP_Mdi parent) {
		mdiParent = (this.psp_mdi = parent);
		
		font = new Font("Lucida Console", 10, GraphicsUnit.PIXEL);
		font2 = new Font("Arial", 9, GraphicsUnit.PIXEL);
		white = Color(0xFF, 0xFF, 0xFF);
		white = Color(0xFF, 0xFF, 0xFF);
		black = Color(0x00, 0x00, 0x00);
		blue  = Color(0x00, 0x00, 0xFF);
		grey2 = Color(0x77, 0x77, 0x77);
		grey  = Color(0xE7, 0xE7, 0xE7);
		pink  = Color(0xF7, 0xC7, 0xE7);
		pink2 = Color(0xFF, 0xF0, 0xF9);
		red   = Color(0x7F, 0x00, 0x00);
		
		icon = Application.resources.getIcon(101);
		
		text = "Disassembler";
		
		setClientSizeCore(512, 325);
		
		form_m = Size(width - 512, height - 325);
		
		minimumSize = Size(320, height / 2);
		//maximumSize = Size(4096, 4096);
		
		psp_mdi.keylistener[this] = true;
		psp_mdi.disasms[this] = true;

		t = new Timer();
		t.interval = 20;
		t.tick ~= &doTick;
		t.start();
		
		closing ~= &doClosing;
	}
	
	void doClosing(Form f, CancelEventArgs cea) {
		psp_mdi.keylistener.remove(this);
		psp_mdi.disasms.remove(this);
		t.stop();
	}		
	
	void doTick(Timer t, EventArgs ea) {	
		//mustRefresh = true;
		if (mustRefresh) updateGraphics();
	}
	
	Size drawText(Graphics g, char[] str, Font font, Color color, int x, int y, int ax = -1, int ay = -1, int minWidth = -1024) {
		TextAlignment[] a_h = [TextAlignment.LEFT, TextAlignment.CENTER, TextAlignment.RIGHT];
		TextAlignment[] a_v = [TextAlignment.TOP , TextAlignment.MIDDLE, TextAlignment.BOTTOM];
	
		Size s = g.measureText(str, font);
		TextFormat tf = new TextFormat();
		tf.alignment = a_h[ax + 1] | a_v[ax + 1];

		int px = x - (s.width  * (ax + 1) >> 1);
		int py = y - (s.height * (ay + 1) >> 1);
		
		if (px < minWidth) {
			s.width -= minWidth - px;
			//writefln("%d - %d,%d", s.width, minWidth, px);
			px = minWidth;
		}
		
		g.drawText(
			str,
			font,
			color,
			Rect(px, py, s.width, s.height),
			tf
		);
		
		return s;
	}
	
	Graphics gbuf;
	
	protected override void onBufferPaint(PaintEventArgs ea) {
		mustRefresh = false;		
		Size size = Size(width - form_m.width, height - form_m.height);				
		Graphics g = ea.graphics;
		
		g.fillRectangle(white, 0, 0, width, height);
		
		//g.fillRectangle(grey, 0, row * rowSize, width, rowSize);				
		
		int cposition = position;
		
		for (int n = 0; n < 100; n++) {
			if ((n + 1) * rowSize >= size.height) { nrows = n; break; }

			if (cPC == cposition) g.fillRectangle(pink, 0, n * rowSize, width, rowSize);
			if (cnPC == cposition) g.fillRectangle(pink2, 0, n * rowSize, width, rowSize);
		
			drawText(g, std.string.format("%08X", cposition), font, blue, 4, n * rowSize);
			
			CPU_Disasm.RInstruction rins;
			char[] text;
			
			uint CODE;
			Color color;

			try {
				CODE = cpu.mem.read4(cposition);
				try {
					rins = CPU_Disasm.disasm(cposition, CODE);
					text = rins.text;
					color = black;
				} catch (Exception e) {
					text = "invalid";
					color = grey2;
				}
			} catch (Exception e) {
				text = "invalid address";
				color = grey2;
			}	

			if (text == "nop") color = grey2;
			
			if (cPC == cposition || n == row) color = red;
			
			char[][] blocks = std.string.split(text, ";");
			
			Size s = drawText(g, blocks[0], font, color, 58, n * rowSize);
			//writefln("%s", s.width);
			
			char[] comment = cpu.mem.getComment(cposition);
			
			if (blocks.length < 2) blocks ~= "";
			
			if (rins.ins.name == "jal") {
				comment = cpu.mem.getComment(rins.params[0]);
				if (!comment.length) comment = std.string.format("%08X", rins.params[0]);
			}			

			if (comment.length) blocks[1] = comment;
			
			if (blocks.length >= 2) {
				drawText(g, blocks[1], font2, blue, size.width - 65, n * rowSize - 1, 1, -1, 58 + s.width);
			}
			
			drawText(g, std.string.format("[%08X]", CODE), font, grey2, size.width - 3, n * rowSize, 1);
			
			cposition += 4;
		}
		
		g.drawRectangle(new Pen(red), 0, row * rowSize, size.width, rowSize);				
		
		text = std.string.format("Disassembler - %08X", cursorPosition);
	}
	
	override protected void onMouseWheel(MouseEventArgs mea) {		
		int disp = 4;
		//int disp = (nrows - 1);
		if (mea.delta < 0) {
			updateCursorRel(+disp);			
		} else if (mea.delta > 0) {
			updateCursorRel(-disp);
		}
	}
	
	void updateCursorRel(int crow) {
		row += crow;
		
		while (row < 0) {
			row++;
			position -= 4;
		}

		while (row >= nrows) {
			row--;
			position += 4;
		}
	
		mustRefresh = true;
	}
	
	override protected void onMouseDown(MouseEventArgs mea) {
		if (!focused) return;
		row = (mea.y / rowSize);
		while (row >= nrows) row--;
		mustRefresh = true;
		updatePC();
	}

	override protected void onMouseMove(MouseEventArgs mea) {
		if (!mea.button) return;
		onMouseDown(mea);
		updatePC();
	}
	
	public void onKeyDownGlobal(KeyEventArgs kea) {
		bool _updatePC = true;
		switch (kea.keyCode) {
			case Keys.UP: updateCursorRel(-1); break;
			case Keys.DOWN: updateCursorRel(+1); break;
			case Keys.PAGE_UP: updateCursorRel(-((nrows >> 1) + 1)); break;
			case Keys.PAGE_DOWN: updateCursorRel(+((nrows >> 1) + 1)); break;
			case Keys.G:
				if (kea.control) {
					SimpleInputForm sif = new SimpleInputForm("Go To");
					sif.value = std.string.format("0x%08X", cursorPosition);
					if (sif.showDialog() == DialogResult.OK) {				
						uint v = Expression.evaluate(sif.value);
						writefln("GOTO (%s) %08X", sif.value, v);
						goTo(v);
						_updatePC = false;
					}
					focus();			
				}
			break;
			default: _updatePC = false; break;
		}
		if (_updatePC) updatePC();
	}

	public void onKeyUpGlobal(KeyEventArgs kea) {
		mustRefresh = true;
	}	
	
	bool hasFocus() { return focused; }
}

class PSP_MemoryForm : Form, IKeyListener {
	PSP_Mdi psp_mdi;
	HexComponent hex;
	
	this() { this(PSP_Mdi.singleton); }

	this(PSP_Mdi parent) {
		mdiParent = (this.psp_mdi = parent);
		
		icon = Application.resources.getIcon(101);
		
		text = "Memory";
		
		setClientSizeCore(452, 325);
		minimumSize = Size(width, 1);
		maximumSize = Size(width, 4096);
		
		with (hex = new HexComponent()) {
			parent = this;
			dock = DockStyle.FILL;
			s = cpu.mem;
			position = 0x08900008;
			updatingCoords ~= &updating;
		}		

		closing ~= &doClosing;
		
		psp_mdi.keylistener[this] = true;
	}
	
	void updateForm() {
		hex.mustRefresh = true;
	}

	void doClosing(Form f, CancelEventArgs cea) {		
		psp_mdi.keylistener.remove(this);
	}	
	
	void updating(HexComponent hex, EventArgs ea) {
		text = std.string.format("Memory - %08X", hex.cursorPosition);		
	}
		
	protected void onKeyDownGlobal(KeyEventArgs kea) {		
		//writefln(kea.keyCode);
		if (kea.keyCode == Keys.G && kea.control) {
			SimpleInputForm sif = new SimpleInputForm("Go To");
			sif.value = std.string.format("0x%08X", hex.cursorPosition);
			if (sif.showDialog() == DialogResult.OK) {				
				uint v = Expression.evaluate(sif.value);
				writefln("GOTO (%s) %08X", sif.value, v);
				hex.goTo(v);
			}
			focus();
			return;
		}
		
		hex.onKeyDown(kea);
	}

	protected void onKeyUpGlobal(KeyEventArgs kea) {
		hex.onKeyUp(kea);
	}	
	
	bool hasFocus() { return focused; }
	
	/*protected override void onGotFocus(EventArgs ea) {
		writefln("mem.onGotFocus");
		super.onGotFocus(ea);
	}*/
}

class PSP_DisplayForm_OGL : Form {
	class GLControlDisplay : GLControl {
		bool update = false, updateOnce = false;
		bool running = true;
		
		class Worker : Thread {
			override int run() {
				long bcounter, counter, frequency, delay;
				QueryPerformanceFrequency(&frequency);
				
				delay = frequency / 60;
			
				try {
					while (running) {
						std.c.windows.windows.QueryPerformanceCounter(&bcounter);
						
						if ((update && !cpu.paused) || updateOnce) {
							updateOnce = false;
							makeCurrent();
							glMatrixMode(GL_MODELVIEW); glLoadIdentity();
							glMatrixMode(GL_PROJECTION); glLoadIdentity();
							glPixelZoom(1, -1); glRasterPos2f(-1, 1);
							glDrawPixels(cpu.gpu.displayBuffer.width, 272, GL_RGBA, cpu.gpu.displayBuffer.formatGl, cpu.gpu.displayBuffer.pptr);
							swapBuffers();
							wglMakeCurrent(null, null);
						}
						
						bios.vblank = true;
						
						while (true) {
							std.c.windows.windows.QueryPerformanceCounter(&counter);
							if (counter - bcounter >= delay) break;
							usleep(1000);
						}
					}
				} catch (Exception e) {
					writefln("PSP_DisplayForm_OGL.Worker.error: %s", e.toString);
				}
				
				return 0;
			}
		}
		
		override void onResize(EventArgs ea) {
			glViewport(0, 0, bounds.width, bounds.height);
		}
		
		override protected void render() {
			wglMakeCurrent(null, null);
			updateOnce = update = true;
		}
		
		this() {
			(new Worker()).start();
		}
		
		~this() {
			update = false;
			running = false;
		}
	}

	GLControl glc;
	PSP_Mdi psp_mdi;

	this() { this(PSP_Mdi.singleton); }
	
	this(PSP_Mdi parent) {				
		mdiParent = (this.psp_mdi = parent);
		icon = Application.resources.getIcon(101);
		setClientSizeCore(480, 272);
		text = "Display (OpenGL)";
		maximumSize = Size(width, height);
		minimumSize = Size(width, height);
		
		with (glc = new GLControlDisplay) {
			dock = DockStyle.FILL;
			parent = this;
		}
		
		prepareScreen();
	}
	
	override protected void onClosing(CancelEventArgs cea) {
		delete glc; glc = null;
	}
	
	
	void prepareScreen() {
	}
	
	void repaintScreen() {
		glc.refresh();
	}
	
	override void onPaint(PaintEventArgs ea) {
		repaintScreen();
	}
	
	override void onResize(EventArgs ea) {
		repaintScreen();
	}	
	
	override void onPaintBackground(PaintEventArgs pea) { }
}

//alias PSP_DisplayForm_SOFT PSP_DisplayForm;
alias PSP_DisplayForm_OGL PSP_DisplayForm;

//Event!(KeyEventArgs) test;

class PSP_Mdi : Form, IMessageFilter {
	static PSP_Mdi singleton;

	Timer t;
	bool[PSP_DisasmForm] disasms;
	bool[IKeyListener] keylistener;
	
	bool usingJoystick = false;
	
	//GLControl drawer;
	
	this() {
		Application.addMessageFilter(this);

		singleton = this;
	
		icon = Application.resources.getIcon(101);
		
		text = "PSP [Stopped]";
		isMdiContainer = true;
		startPosition = FormStartPosition.CENTER_SCREEN;
		//windowState = FormWindowState.MAXIMIZED;
		width = 800;
		height = 600;

		createMenu();
		createTimer();		
		configLoad();
		
		GLControl glControl;
		with (glControl = new GLControl()) {
			width = 480;
			height = 272;
			parent = this;
			visible = false;
		}
		
		cpu.gpu.init(glControl);
	}
	
	override protected void onClosing(CancelEventArgs cea) {		
		t.stop(); closeAll();
	
		cpu._exit = true;
		doStop();
		
		usleep(30000);
		
		Application.exit();
	}	
	
	void configSave() {	
		// Saving config
		Stream s = new File("psp.config", FileMode.OutNew);
		
		s.writefln("v0");
		
		void serializeFormState(Form form) {
			s.writefln("%d,%d,%d,%d,%d", cast(int)form.windowState, form.left, form.top, form.width, form.height);
		}

		serializeFormState(this);
		
		foreach (form; mdiChildren) {
			char[] type = form.classinfo.name;
			s.writef("%s:", type); serializeFormState(form);
		}
		s.close();	
	}
	
	void closeAll() {
		writefln("closing");
		foreach (form; mdiChildren) form.close();
	}
	
	void configLoad() {
		try {
			void unserializeFormState(Form form, char[] state) {
				char[][] p = state.split(",");				
				form.setDesktopBounds(toInt(p[1]), toInt(p[2]), toInt(p[3]), toInt(p[4]));
				form.windowState = cast(FormWindowState)toInt(p[0]);
			}
		
			Stream s = new File("psp.config", FileMode.In);
			
			if (s.readLine != "v0") throw(new Exception("Invalid version"));
			
			unserializeFormState(this, s.readLine);
			
			while (!s.eof) {
				char[][] cf = std.string.split(s.readLine, ":");
				
				//writefln(ClassInfo.find(cf[0]));
				
				//writefln(ClassInfo.find(cf[0]).create);
				
				Form form = cast(Form)(ClassInfo.find(cf[0]).create());				
				
				form.show();
				
				unserializeFormState(form, cf[1]);
			}
			s.close();			
		} catch (Exception e) {		
			//throw(e);	
			closeAll();
			createForms();
		}		
	}
	
	uint keyModifiers;

	override bool preFilterMessage(inout Message m) {
		switch (m.msg) {
			case 256: // WM_KEYDOWN
			case 257: // WM_KEYUP
				bool pressed = (m.msg != 257);
				uint key = m.wParam, mod = m.lParam;
				uint mmask;
				
				if (key == Keys.CONTROL_KEY) mmask = Keys.CONTROL;
				else if (key == Keys.SHIFT_KEY) mmask = Keys.SHIFT;
				//else if (key == Keys.ALT_KEY) mmask = Keys.ALT;
				
				if (mmask) if (pressed) keyModifiers |= mmask; else keyModifiers &= ~mmask;
				
				//writefln("%032b", mod);
				
				KeyEventArgs kea = new KeyEventArgs(cast(Keys)(key | keyModifiers));
				
				if (pressed) onKeyDown(kea); else onKeyUp(kea);
				
				//return true;
			break;
			default: break;
		}
		
		return false;
	}
	
	void createForms() {
		doNewMemory();
		doNewDisasm();
		doNewRegisters();
		doNewCallstack();
		doNewDisplay();
	}
		
	void createTimer() {
		t = new Timer();
		t.interval = 1000 / 60;
		t.tick ~= &doTick;
		t.start();	
	}
	
	void createMenu() {
		Menu[5] menul;
		
		MenuItem createMenu(int level, char[] name, void delegate(MenuItem mi, EventArgs ea) doClick = null) {
			MenuItem menui = new MenuItem(name);			
			if (doClick) menui.click ~= doClick;
			menul[level + 1] = menui;
			menul[level].menuItems.add(menui);			
			return menui;
		}
				
		menu = new MainMenu;	
		menul[0] = menu;	
		createMenu(0, "&File");
		createMenu(  1, "&Open...", &menuOpen);
		createMenu(  1, "&Exit", &menuExit);
		createMenu(0, "&Run");
		createMenu(  1, "&Execute\tF9", &menuExecute);
		createMenu(  1, "&Stop", &menuStop);
		createMenu(  1, "&Pause", &menuPause);
		createMenu(  1, "&Run to Cursor\tF6", &menuRunToCursor);
		createMenu(  1, "Step &Into\tF7", &menuStepInto);
		createMenu(  1, "Step &Over\tF8", &menuStepOver);
		createMenu(  1, "-");
		createMenu(  1, "Sa&ve State", &menuSaveState);
		createMenu(  1, "&Load State", &menuLoadState);
		createMenu(0, "&Tools");
		createMenu(  1, "&Dump memory...", &menuDumpMemory);
		createMenu(  1, "&Restore memory...", &menuRestoreMemory);
		createMenu(  1, "-");
		createMenu(  1, "&Memory Stick");
		createMenu(    2, "&Insert", &menuMemoryStickInsert);
		createMenu(    2, "&Eject", &menuMemoryStickEject);
		createMenu(    2, "Select &Path...");
		createMenu(  1, "-");
		createMenu(  1, "&Input");
		createMenu(    2, "&Keyboard", &menuInputKeyboard).checked = true;
		createMenu(    2, "&Joystick", &menuInputJoystick);
		createMenu(  1, "-");
		createMenu(  1, "&Take screenshot...", &menuSaveScreenshot);
		createMenu(  1, "-");
		createMenu(  1, "&Ignore Errors", &menuIgnoreErrors);
		createMenu(0, "&Windows");
		createMenu(  1, "&Display", &menuNewDisplay);
		createMenu(  1, "Di&sasembler", &menuNewDisasm);
		createMenu(  1, "&Registers", &menuNewRegisters);
		createMenu(  1, "&Memory", &menuNewMemory);
		createMenu(  1, "&Callstack", &menuNewCallstack);
		createMenu(  1, "&GPU", &menuNewGPU);
		createMenu(  1, "&Breakpoints", &menuNewBreakpoints);
		createMenu(  1, "-");
		createMenu(  1, "&Save distribution", &menuSaveWindows);
		createMenu(0, "&Help");	
		createMenu(  1, "&Contents...", &menuHelpContents);
		createMenu(  1, "-");
		createMenu(  1, "Search for update...", &menuSearchUpdate);
		createMenu(  1, "-");
		createMenu(  1, "&Web page...", &menuWebpage);
		createMenu(  1, "&About...", &menuAbout);		
	}
	
	PSP_MemoryForm[] memories() {
		PSP_MemoryForm[] r;
		foreach (child; mdiChildren) if (child.classinfo == PSP_MemoryForm.classinfo) r ~= cast(PSP_MemoryForm)child;
		return r;
	}

	PSP_RegistersForm[] registers() { PSP_RegistersForm[] r; foreach (child; mdiChildren) if (child.classinfo == PSP_RegistersForm.classinfo) r ~= cast(PSP_RegistersForm)child; return r; }
	PSP_CallstackForm[] callstacks() { PSP_CallstackForm[] r; foreach (child; mdiChildren) if (child.classinfo == PSP_CallstackForm.classinfo) r ~= cast(PSP_CallstackForm)child; return r; }
	PSP_DisplayForm[] displays() { PSP_DisplayForm[] r; foreach (child; mdiChildren) if (child.classinfo == PSP_DisplayForm.classinfo) r ~= cast(PSP_DisplayForm)child; return r; }
	
	void updateDebug() {
		cpu.updateDebug = false;
	
		foreach (r; registers ) r.updateForm();
		foreach (r; memories  ) r.updateForm();
		foreach (r; callstacks) r.updateForm();
		foreach (r; displays  ) r.refresh();
		
		if (disasm) {
			disasm.goTo(cpu.regs.PC);
			disasm.focus();
		}
	}
	
	void doExecute() {
		text = "PSP [Running]";
		PSP_DisplayForm[] dlist = displays;
		if (dlist.length) dlist[0].focus();
		cpu.interrupt = false;
		cpu.pauseAt = 0;
	}
	
	void doStop() {
		text = "PSP [Stopped]";
		cpu.pauseAt = 0;
		cpu.stop = true;
		cpu.interrupt = true;	
	}
	
	void doPause() {
		text = "PSP [Paused]";
		cpu.pauseExtern();
	}
	
	void doStepInto() {
		doPause();
		cpu.pauseAt = 0;
		cpu.next = true;
	}	

	void doStepOver() {
		cpu.nextOver = true;
		doStepInto();
	}

	void doRunToCursor() {
		if (!disasm) return;		
		cpu.next = true;
		cpu.pauseAt = disasm.cursorPosition;		
		cpu.interrupt = true;
	}	

	void doAbout() {
		char[] str = std.string.format("soywiz 2008\n%s\n%s v%.3f\nDFL version ?", __TIMESTAMP__, __VENDOR__, cast(float)(__VERSION__) / 1000);
		msgBox(str, "About", MsgBoxButtons.OK, MsgBoxIcon.INFORMATION, MsgBoxDefaultButton.BUTTON1);	
		//(new AboutDialog()).showDialog();
	}
	
	void doDumpMemory() {
		SaveFileDialog fd = new SaveFileDialog;
		fd.fileName = "mem.dump";
		if (fd.showDialog(this) == DialogResult.OK) {
			Stream s = fd.openFile();
			s.write(cpu.mem.main);
			s.close();
		}
	}
	
	void doOpen() {
		OpenFileDialog fd = new OpenFileDialog;
		fd.fileName = "EBOOT.PBP";
		if (fd.showDialog(this) == DialogResult.OK) {
			.load(fd.fileName);
			updateDebug();
		}		
	}

	void doRestoreMemory() {
		OpenFileDialog fd = new OpenFileDialog;
		fd.fileName = "mem.dump";
		if (fd.showDialog(this) == DialogResult.OK) {
			Stream s = fd.openFile();
			// PSP USER DUMP
			if (s.size == 0x1800000) {
				s.read(cpu.mem.main[0x00800000..cpu.mem.main.length]);
			} else {
				s.read(cpu.mem.main);
			}
			s.close();
			updateDebug();
		}		
	}
	
	void doSaveState() {
		cpu.stateSave(new File("0.sstate", FileMode.OutNew));
		updateDebug();
	}

	void doLoadState() {
		cpu.stateLoad(new File("0.sstate", FileMode.In));
		updateDebug();
	}
	
	void doSaveScreenshot() {
		Bitmap32 bmp = new Bitmap32(480, 272);
		ubyte* buffer = cast(ubyte*)cpu.gpu.displayBuffer.pptr;
		switch (cpu.gpu.displayBuffer.formatGl) {
			case GL_UNSIGNED_INT_8_8_8_8_REV:
				for (int y  = 0; y < 272; y++) {
					for (int x  = 0; x < 480; x++) {
						bmp.set(x, y, (cast(uint*)buffer)[y * cpu.gpu.displayBuffer.width + x] | 0xFF000000);
					}
				}
			break;
			default:
				throw(new Exception("displayMode not supported yet"));
			break;
		}
		
		SaveFileDialog fd = new SaveFileDialog;
		fd.defaultExt = "png";
		fd.fileName = "screenshot.png";
		fd.filter = "PNG files (*.png)|*.png";
		if (fd.showDialog(this) == DialogResult.OK) {
			ImageFileFormatProvider["png"].write(bmp, fd.fileName);
		}
	}
	
	PSP_DisasmForm disasm() {
		return (disasms.keys.length) ? disasms.keys[0] : null;
	}
	
	void doWebpage() {
		ShellExecuteA(null, "open", "http://soywiz.com/d/pspemulator/", null, null, SW_SHOWNORMAL);
	}
		
	void doNewDisplay() { (new PSP_DisplayForm(this)).show; }
	void doNewDisasm() { (new PSP_DisasmForm(this)).show; }
	void doNewMemory() { (new PSP_MemoryForm(this)).show; }
	void doNewRegisters() { (new PSP_RegistersForm(this)).show; }
	void doNewCallstack() { (new PSP_CallstackForm(this)).show; }
	void doNewBreakpoints() { (new PSP_BreakpointsForm(this)).show; }
	void doNewGPU() { (new PSP_GPUForm(this)).show; }
	
	// MENU
	
	void menuOpen(MenuItem mi, EventArgs ea) { doOpen(); }
	void menuSaveWindows(MenuItem mi, EventArgs ea) { configSave(); }

	void menuNewDisplay(MenuItem mi, EventArgs ea) { doNewDisplay(); }
	void menuNewDisasm(MenuItem mi, EventArgs ea) { doNewDisasm(); }
	void menuNewMemory(MenuItem mi, EventArgs ea) { doNewMemory(); }
	void menuNewCallstack(MenuItem mi, EventArgs ea) { doNewCallstack(); }
	void menuNewRegisters(MenuItem mi, EventArgs ea) { doNewRegisters(); }
	void menuNewBreakpoints(MenuItem mi, EventArgs ea) { doNewBreakpoints(); }
	void menuNewGPU(MenuItem mi, EventArgs ea) { doNewGPU(); }
	
	void menuExit(MenuItem mi, EventArgs ea) { close(); }
	void menuExecute(MenuItem mi, EventArgs ea) { doExecute(); }
	void menuPause(MenuItem mi, EventArgs ea) {	doPause(); }	
	void menuStop(MenuItem mi, EventArgs ea) { doStop(); }
	void menuRunToCursor(MenuItem o, EventArgs ea) { doRunToCursor(); }
	void menuStepInto(MenuItem o, EventArgs ea) { doStepInto(); }
	void menuStepOver(MenuItem mi, EventArgs ea) { doStepOver(); }
	void menuAbout(MenuItem mi, EventArgs ea) { doAbout(); }
	void menuDumpMemory(MenuItem mi, EventArgs ea) { doDumpMemory(); }
	void menuRestoreMemory(MenuItem mi, EventArgs ea) { doRestoreMemory(); }
	void menuSaveState(MenuItem mi, EventArgs ea) { doSaveState(); }
	void menuLoadState(MenuItem mi, EventArgs ea) { doLoadState(); }
	void menuSaveScreenshot(MenuItem mi, EventArgs ea) { doSaveScreenshot(); }
	void menuWebpage(MenuItem mi, EventArgs ea) { doWebpage(); }
	
	void menuIgnoreErrors(MenuItem mi, EventArgs ea) {
		bool action = !mi.checked;
		cpu.ignoreErrors = action;
		mi.checked = action;
	}
	
	void menuSearchUpdate(MenuItem mi, EventArgs ea) {
		msgBox("Not implemented yet");
	}
	
	void setInput(MenuItem mi) {
		foreach (cmi; mi.parent.menuItems) {
			cmi.checked = (mi is cmi);
		}
	}
	
	void menuInputKeyboard(MenuItem mi, EventArgs ea) {
		usingJoystick = false;
		setInput(mi);
	}
	
	void menuInputJoystick(MenuItem mi, EventArgs ea) {
		usingJoystick = true;
		setInput(mi);
	}
	
	void menuMemoryStickInsert(MenuItem mi, EventArgs ea) {
		if (Device_MemoryStick.singleton) Device_MemoryStick.singleton.changeState(true);
	}

	void menuMemoryStickEject(MenuItem mi, EventArgs ea) {
		if (Device_MemoryStick.singleton) Device_MemoryStick.singleton.changeState(false);
	}
	
	void menuHelpContents(MenuItem mi, EventArgs ea) {
		ShellExecuteA(null, "open", "pspemu.chm", null, null, SW_SHOWNORMAL);
	}

	void doTick(Timer t, EventArgs ea) {
		joyUpdate();
		if (cpu.updateDebug) {
			updateDebug();
		}
	}
		
	void onKeyDown(KeyEventArgs kea) {		
		keyChange(kea.keyCode, true);
	
		switch (kea.keyCode) {
			case Keys.F6: doRunToCursor(); break;
			case Keys.F7: doStepInto(); break;
			case Keys.F8: doStepOver(); break;
			case Keys.F9: doExecute(); break;
			default: break;
		}
				
		foreach (keyl; keylistener.keys) {
			if (!keyl.hasFocus) continue;			
			keyl.onKeyDownGlobal(kea);
		}
	}

	void onKeyUp(KeyEventArgs kea) {
		keyChange(kea.keyCode, false);
		
		foreach (keyl; keylistener.keys) {
			if (!keyl.hasFocus) continue;
			keyl.onKeyUpGlobal(kea);
		}		
	}
	
	void keyChange(Keys key, bool pressed) {
		if (usingJoystick) return;
	
		cpu.ctrl.data.TimeStamp = time(null);
		
		uint Buttons = cpu.ctrl.data.Buttons;
		
		void update_pressed(uint mask) { if (pressed) Buttons |= mask; else Buttons &= ~mask; }
		
		switch (key) {
			case Keys.DOWN : update_pressed(Controller.Buttons.DOWN); break;
			case Keys.UP   : update_pressed(Controller.Buttons.UP); break;
			case Keys.LEFT : update_pressed(Controller.Buttons.LEFT); break;
			case Keys.RIGHT: update_pressed(Controller.Buttons.RIGHT); break;		
			case Keys.Q    : update_pressed(Controller.Buttons.LTRIGGER); break;
			case Keys.E    : update_pressed(Controller.Buttons.RTRIGGER); break;
			case Keys.W    : update_pressed(Controller.Buttons.TRIANGLE); break;
			case Keys.S    : update_pressed(Controller.Buttons.CROSS); break;
			case Keys.A    : update_pressed(Controller.Buttons.SQUARE); break;
			case Keys.D    : update_pressed(Controller.Buttons.CIRCLE); break;
			case Keys.ENTER: update_pressed(Controller.Buttons.START); break;
			case Keys.SPACE: update_pressed(Controller.Buttons.SELECT); break;
			default: break;
		}
		
		cpu.ctrl.data.Lx = (Buttons & Controller.Buttons.LEFT) ? 0x00 : ((Buttons & Controller.Buttons.RIGHT) ? 0xFF : 0x7F);
		cpu.ctrl.data.Ly = (Buttons & Controller.Buttons.UP  ) ? 0x00 : ((Buttons & Controller.Buttons.DOWN ) ? 0xFF : 0x7F);
		
		cpu.ctrl.data.Buttons = Buttons;
		
		for (int n = 0; n < 6; n++) cpu.ctrl.data.Rsrv[n] = 0;
	}
	
	void joyUpdate() {
		if (!usingJoystick) return;
	
		Joystick joy = Joystick[0];
		joy.update();

		uint Buttons = 0;
		
		void CHECK(int cond, int mask) { if (cond != 0) Buttons |= mask; }
		
		CHECK(joy.povX < 0, Controller.Buttons.LEFT);
		CHECK(joy.povX > 0, Controller.Buttons.RIGHT);
		CHECK(joy.povY < 0, Controller.Buttons.DOWN);
		CHECK(joy.povY > 0, Controller.Buttons.UP);
		CHECK(joy.buttons & (1 << 0), Controller.Buttons.TRIANGLE);
		CHECK(joy.buttons & (1 << 1), Controller.Buttons.CIRCLE);
		CHECK(joy.buttons & (1 << 2), Controller.Buttons.CROSS);
		CHECK(joy.buttons & (1 << 3), Controller.Buttons.SQUARE);

		CHECK(joy.buttons & (1 << 6), Controller.Buttons.LTRIGGER);
		CHECK(joy.buttons & (1 << 7), Controller.Buttons.RTRIGGER);
		CHECK(joy.buttons & (1 << 8), Controller.Buttons.START);
		CHECK(joy.buttons & (1 << 9), Controller.Buttons.SELECT);
		
		cpu.ctrl.data.Lx = (joy.x >> 8);
		cpu.ctrl.data.Ly = (joy.y >> 8);
		cpu.ctrl.data.TimeStamp = time(null);
		cpu.ctrl.data.Buttons = Buttons;
		
		for (int n = 0; n < 6; n++) cpu.ctrl.data.Rsrv[n] = 0;
	}
	
	/*protected override void onGotFocus(EventArgs ea) {
		writefln("main.onGotFocus");
		writefln("%s", getActiveMdiChild());
		super.onGotFocus(ea);
	}
	
	protected void onLostFocus(EventArgs ea) {
		writefln("%s", getActiveMdiChild());
	}*/
}

int run_cpu(void *p) {
	cpu.run();
	return 0;
}

CPU.ErrorResult cpuError(char[] msg) {
	switch (msgBox(PSP_Mdi.singleton, msg, "CPU Exception", MsgBoxButtons.ABORT_RETRY_IGNORE, MsgBoxIcon.ERROR, MsgBoxDefaultButton.BUTTON1)) {
		case DialogResult.ABORT : return CPU.ErrorResult.ABORT;
		case DialogResult.RETRY : return CPU.ErrorResult.RETRY;
		case DialogResult.IGNORE: return CPU.ErrorResult.IGNORE;
	}
}

void load(char[] fileName, bool resume = false) {
	cpu.pauseExtern();
	{
		auto s = new File(fileName);
		if (s.readString(11) == "PSPEMUSTATE") {
			s.position = 0;
			cpu.stateLoad(s);
		} else {
			s.close();
			cpu.mem.reset();
			cpu.gpu.reset();
			
			ModuleLoader.appPath = std.path.getDirName(fileName);
			
			ModuleLoader.LoaderResult lr = ModuleLoader.LoadModule(
				bios,
				new File(fileName)
			);
			
			writefln("ENTRY: %08X", lr.EntryAddress);
			
			cpu.regs._PC = lr.EntryAddress;
			cpu.regs[Registers.R.ra] = 0x08000004;
			cpu.regs[Registers.R.a0] = 0; // argumentsLength
			cpu.regs[Registers.R.a1] = lr.EntryAddress; // argumentsPointer
			cpu.regs[Registers.R.a2] = 0;
			cpu.regs[Registers.R.gp] = lr.GlobalPointer;
			cpu.regs[Registers.R.sp] = 0x09F00000;
			cpu.regs[Registers.R.k0] = 0x09F00000;
			
			cpu.resetExtern();
			
			bios.start();
		}
	}
	if (resume) cpu.resumeExtern();
}

void start() {
	bios = new BIOS_HLE();
	bios.init();
	cpu.onError = &cpuError;
	cpu.bios = bios;
	
	Expression.mapvalues ~= &getRegistry;

	(new Thread(&run_cpu, null)).start;
}

int main(char[][] args) {		
	ModuleLoader.loadLibraryInfo(ResourceToStream("libdoc"));

	start();
	
	if (args.length >= 2) load(args[1], false);

	debug (debug_cpuid) {
		writefln("CPUID {");
		foreach (l; std.string.split(std.cpuid.toString, "\n")) writefln("  %s", l);
		writefln("}");
	}
	
	writefln("Joysticks: %d", Joystick.count);
	Joystick.openAll();
	
	//if (false)
	{
		Application.enableVisualStyles();
		Application.run(new PSP_Mdi);
	}
	
	
	return 0;
}