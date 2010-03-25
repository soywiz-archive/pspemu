module pspemu.gui.DisplayForm;

import dfl.all, dfl.internal.winapi;

import core.thread, core.memory;

import std.stdio, std.c.time;
import std.typetuple;

import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Disassembler;
import pspemu.core.gpu.impl.GpuOpengl;

import pspemu.gui.GLControl;
import pspemu.models.IDisplay;
import pspemu.models.IController;

import pspemu.hle.Module;
import pspemu.hle.kd.threadman;

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
		setClientSizeCore(displaySize.width, displaySize.height);
		text = "Display (OpenGL)";
		maximumSize = Size(width, height);
		minimumSize = Size(width, height);
		
		with (glc = new GLControlDisplay(display)) {
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
				moduleManager.get!(ThreadManForUser).dumpThreads();
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

class GLControlDisplay : GLControl {
	IDisplay display;
	bool update = true, updateOnce = false;
	bool running = true;
	bool ready = false;
	//ubyte[] data;

	void threadRun() {
		long bcounter, counter, frequency, delay;
		QueryPerformanceFrequency(&frequency);

		delay = frequency / display.verticalRefreshRate;

		//Thread.sleep(100_0000);
		while (true) {
			try {
				// Check OpenGL.
				makeCurrent();
				//Sleep(2000);
				writefln("GLControlDisplay.glInit");
				glInit(); assert(glMatrixMode !is null);
				break;
			} catch (Object o) {
				writefln("GLControlDisplay.threadRun: %s", o);
				Sleep(100);
			}
		}

		while (running) {
			writefln("threadRun.loop started");
			try {
				glMatrixMode(GL_MODELVIEW ); glLoadIdentity();
				glMatrixMode(GL_PROJECTION); glLoadIdentity();
				glPixelZoom(1, -1); glRasterPos2f(-1, 1);

				disableStates();

				//while (!ready) Sleep(1);
				while (running) {
					QueryPerformanceCounter(&bcounter);
					
					//if ((update && !cpu.paused) || updateOnce) {
					if (update || updateOnce) {
						updateOnce = false;

						glDrawPixels(
							display.frameBufferSize.width,
							display.frameBufferSize.height,
							GL_RGBA,
							GpuOpengl.PixelFormats[display.frameBufferPixelFormat & 3].opengl,
							display.frameBufferPointer
						);

						swapBuffers();
					}
					
					//GC.minimize();
					//GC.collect();
					
					while (true) {
						QueryPerformanceCounter(&counter);
						//Thread.sleep(0_5000);
						if (counter - bcounter >= delay - 4) break;
						//Thread.sleep(0_5000);
						Sleep(1);
					}
					
					display.vblank = true;
					Sleep(4);
					display.vblank = false;
				}
			} catch (Object e) {
				writefln("GLControlDisplay.threadRun.error: %s", e);
			} finally {
				writefln("GLControlDisplay.threadRun.end");
				//display.vblank = true;
				//Thread.sleep(10_0000);
				Sleep(10);
			}
		}
	}
	
	void disableStates() {
		glDisable(GL_ALPHA_TEST); glDisable(GL_BLEND); glDisable(GL_DEPTH_TEST);
		glDisable(GL_DITHER); glDisable(GL_FOG); glDisable(GL_LIGHTING);
		glDisable(GL_LOGIC_OP); glDisable(GL_STENCIL_TEST); glDisable(GL_TEXTURE_1D);
		glDisable(GL_TEXTURE_2D); glPixelTransferi(GL_MAP_COLOR, GL_FALSE);
		glPixelTransferi(GL_RED_SCALE, 1); glPixelTransferi(GL_RED_BIAS, 0);
		glPixelTransferi(GL_GREEN_SCALE, 1); glPixelTransferi(GL_GREEN_BIAS, 0);
		glPixelTransferi(GL_BLUE_SCALE, 1); glPixelTransferi(GL_BLUE_BIAS, 0);
		glPixelTransferi(GL_ALPHA_SCALE, 1); glPixelTransferi(GL_ALPHA_BIAS, 0);
	}
	
	override void onResize(EventArgs ea) {
		glViewport(0, 0, bounds.width, bounds.height);
	}
	
	override protected void render() {
		updateOnce = update = true;
	}

	void stop() {
		update = false;
		running = false;
	}
	
	this(IDisplay display) {
		this.display = display;
	}
	
	override void onHandleCreated(EventArgs ea) {
		super.onHandleCreated(ea);
		(new Thread(&threadRun)).start();
	}
	
	~this() {
		stop();
	}
}