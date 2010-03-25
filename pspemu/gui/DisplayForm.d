module pspemu.gui.DisplayForm;

import dfl.all, dfl.internal.winapi;

import std.stdio, std.c.time;
import std.typetuple;

import pspemu.utils.Utils;

import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Disassembler;

import pspemu.gui.GLControlDisplay;
import pspemu.gui.GLControl;

import pspemu.models.IDisplay;
import pspemu.models.IController;

import pspemu.hle.Module;
import pspemu.hle.kd.threadman;

static const string svnRevision = import("svn.version");

class DisplayForm : Form, IMessageFilter {
	GLControlDisplay glc;
	ModuleManager    moduleManager;
	Cpu              cpu;
	Display          display;
	IController      controller;
	real             lastFps;

	void updateTitle() {
		text = std.string.format("PSP Emulator - r%s - FPS: %.1f", svnRevision, lastFps);
	}

	this(bool showMainMenu = false, ModuleManager moduleManager = null, Cpu cpu = null, Display display = null, IController controller = null) {
		Application.addMessageFilter(this);

		this.moduleManager = moduleManager;
		this.cpu = cpu;
		if (display    is null) display    = new NullDisplay;
		if (controller is null) controller = new Controller();
		this.display    = display;
		this.controller = controller;
		
		auto displaySize = display.displaySize;

		//Application.addMessageFilter(this);
		
		startPosition = FormStartPosition.CENTER_SCREEN;
		icon = Application.resources.getIcon(101);
		maximizeBox = false;

		if (showMainMenu) attachMenu();

		setClientSizeCore(displaySize.width, displaySize.height);
		updateTitle();
		maximumSize = Size(width, height);
		minimumSize = Size(width, height);
		
		with (glc = new GLControlDisplay(cpu, display)) {
			dock    = DockStyle.FILL;
			parent  = this;
			visible = true;
		}
		
		with (new GLControl) {
			width   = displaySize.width;
			height  = displaySize.height;
			parent  = this;
			visible = false;
		}

		with (new Timer) {
			interval = 20;
			tick ~= (Timer sender, EventArgs ea) { controller.frameWrite(); };
			start();
		}

		with (new Timer) {
			interval = 2000;
			tick ~= (Timer sender, EventArgs ea) {
				lastFps = cast(real)cpu.display.fpsCounter / 2.0;
				updateTitle();
				display.fpsCounter = 0;
			};
			start();
		}
	}

	void attachMenu() {
		menu = new MainMenu;
		Menu currentMenu = menu;

		void addClick(string name, void delegate(MenuItem, EventArgs) registerCallback = null, void delegate() menuGenerateCallback = null) {
			Menu backMenu = currentMenu;

			MenuItem menuItem = new MenuItem;
			menuItem.text = name;
			menuItem.parent = backMenu;
			if (registerCallback !is null) menuItem.click ~= registerCallback;

			currentMenu = menuItem;
			{
				if (menuGenerateCallback !is null) menuGenerateCallback();
			}
			currentMenu = backMenu;
		}

		void add(string name, void delegate() menuGenerateCallback = null) {
			addClick(name, null, menuGenerateCallback);
		}

		add("&File", {
			addClick("&Open...", (MenuItem mi, EventArgs ea) {
				auto fd = new OpenFileDialog;
				//fd.fileName   = "EBOOT.PBP";
				fd.filter     = "PSP Executable Files (*.pbp;*.elf;*.iso;*.cso;*.dax)|*.pbp;*.elf;*.iso;*.cso;*.dax|All Files (*.*)|*.*";
				//fd.defaultExt = "iso";
				if (fd.showDialog(this) == DialogResult.OK) {
				}
				/*
				if (fd.showDialog(this) == DialogResult.OK) {
					.load(fd.fileName);
					updateDebug();
				}
				*/
			});
			add("-");
			addClick("&Exit", (MenuItem mi, EventArgs ea) {
				Application.exit();
			});
		});
		add("&Run", {
			add("&Execute");
			add("&Stop");
			add("&Pause");
			add("-");
			add("Step &Into");
			add("Step &Over");
			add("Run to &Cursor");
			add("Run until &Return");
			add("-");
			add("S&ave State...");
			add("&Load State...");
		});
		add("&Tools", {
			add("&Debugger...");
			add("&Memory viewer...");
			add("&GE viewer...");
			add("-");
			add("Memory &Stick", {
				add("&Insert");
				add("&Eject");
				add("Selected &Path...");
			});
			add("-");
			add("Input", {
				add("&Keyboard");
				add("&Gamepad");
			});
			add("-");
			addClick("Take Screenshot...", (MenuItem mi, EventArgs ea) {
				SaveFileDialog fd = new SaveFileDialog;
				fd.defaultExt = "png";
				fd.fileName = "screenshot.png";
				fd.filter = "PNG files (*.png)|*.png";
				if (fd.showDialog(this) == DialogResult.OK) {
					//ImageFileFormatProvider["png"].write(bmp, fd.fileName);
				}
			});
			add("-");
			add("Ignore errors");
		});
		add("&Help", {
			add("&Website");
			add("&About...");
		});
	}
	
	override void onPaint  (PaintEventArgs ea  ) { glc.refresh(); }
	override void onResize (EventArgs ea       ) { glc.refresh(); }
	override void onClosing(CancelEventArgs cea) { glc.stop(); }
	
	override void onPaintBackground(PaintEventArgs pea) { }

	uint keyModifiers;

	override bool preFilterMessage(ref Message m) {
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
				
				KeyEventArgs kea = new KeyEventArgs(cast(Keys)(key | keyModifiers));
				
				if (pressed) {
					onKeyDown(kea);
				} else {
					onKeyUp(kea);
				}
			break;
			default: break;
		}
		
		return false;
	}

	void onKeyDown(KeyEventArgs kea) {		
		keyChange(kea.keyCode, true);
	}

	void onKeyUp(KeyEventArgs kea) {
		keyChange(kea.keyCode, false);
		switch (kea.keyCode) {
			case Keys.F5:
				cpu.registers.dump();
				auto dissasembler = new AllegrexDisassembler(cpu.memory);
				dissasembler.registersType = AllegrexDisassembler.RegistersType.Symbolic;
				dissasembler.dump(cpu.registers.PC, -6, 6);
				moduleManager.get!(ThreadManForUser).threadManager.dumpThreads();
				moduleManager.get!(ThreadManForUser).semaphoreManager.dumpSemaphores();
			break;
			case Keys.F6:
			break;
			default:
			break;
		}
	}

	void keyChange(Keys key, bool pressed) {
		with (controller.currentFrame) {
			void update_pressed(uint mask) { if (pressed) Buttons |= mask; else Buttons &= ~mask; }

			switch (key) {
				case Keys.DOWN : update_pressed(Controller.Buttons.DOWN    ); break;
				case Keys.UP   : update_pressed(Controller.Buttons.UP      ); break;
				case Keys.LEFT : update_pressed(Controller.Buttons.LEFT    ); break;
				case Keys.RIGHT: update_pressed(Controller.Buttons.RIGHT   ); break;		
				case Keys.Q    : update_pressed(Controller.Buttons.LTRIGGER); break;
				case Keys.E    : update_pressed(Controller.Buttons.RTRIGGER); break;
				case Keys.W    : update_pressed(Controller.Buttons.TRIANGLE); break;
				case Keys.S    : update_pressed(Controller.Buttons.CROSS   ); break;
				case Keys.A    : update_pressed(Controller.Buttons.SQUARE  ); break;
				case Keys.D    : update_pressed(Controller.Buttons.CIRCLE  ); break;
				case Keys.ENTER: update_pressed(Controller.Buttons.START   ); break;
				case Keys.SPACE: update_pressed(Controller.Buttons.SELECT  ); break;
				default: break;
			}
			
			x = (Buttons & Controller.Buttons.LEFT) ? -1.0 : ((Buttons & Controller.Buttons.RIGHT) ? +1.0 : 0.0);
			y = (Buttons & Controller.Buttons.UP  ) ? -1.0 : ((Buttons & Controller.Buttons.DOWN ) ? +1.0 : 0.0);
		}
	}
}
