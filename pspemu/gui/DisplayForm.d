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
	IDisplay         display;
	IController      controller;

	this(ModuleManager moduleManager = null, Cpu cpu = null, IDisplay display = null, IController controller = null) {
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

		menu = new MainMenu;
		menu.menuItems.add("&File");
		menu.menuItems.add("&Run");
		menu.menuItems.add("&Tools");
		menu.menuItems.add("&Windows");
		menu.menuItems.add("&Help");

		setClientSizeCore(displaySize.width, displaySize.height);
		text = "PSP Emulator - r" ~ svnRevision;
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
			default:
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
