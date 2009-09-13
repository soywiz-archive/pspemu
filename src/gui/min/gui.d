module gui;

import dfl.all, dfl.internal.winapi;

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
import glcontrol;
import utils.joystick;

debug = debug_cpuid;

BIOS bios;

int run_cpu(void *p) {
	cpu.run();
	return 0;
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

CPU.ErrorResult cpuError(char[] msg) {
	switch (msgBox(null, msg, "CPU Exception", MsgBoxButtons.ABORT_RETRY_IGNORE, MsgBoxIcon.ERROR, MsgBoxDefaultButton.BUTTON1)) {
		case DialogResult.ABORT : return CPU.ErrorResult.ABORT;
		case DialogResult.RETRY : return CPU.ErrorResult.RETRY;
		case DialogResult.IGNORE: return CPU.ErrorResult.IGNORE;
	}
}

void start() {
	bios = new BIOS_HLE();
	bios.init();
	cpu.onError = &cpuError;
	cpu.bios = bios;
	(new Thread(&run_cpu, null)).start;
}

class PSP_DisplayForm_OGL : Form, IMessageFilter {
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

	this() {
		Application.addMessageFilter(this);
		
		startPosition = FormStartPosition.CENTER_SCREEN;
		icon = Application.resources.getIcon(101);
		setClientSizeCore(480, 272);
		text = "Display (OpenGL)";
		maximumSize = Size(width, height);
		minimumSize = Size(width, height);
		
		with (glc = new GLControlDisplay) {
			dock = DockStyle.FILL;
			parent = this;
			visible = true;
		}
		
		prepareScreen();

		{
			GLControl glControl;
			with (glControl = new GLControl()) {
				width = 480;
				height = 272;
				parent = this;
				visible = false;
			}
			
			cpu.gpu.init(glControl);
		}
		
		cpu.interrupt = false; cpu.pauseAt = 0;
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
	
	void onKeyDown(KeyEventArgs kea) {
		keyChange(kea.keyCode, true);
	}

	void onKeyUp(KeyEventArgs kea) {
		keyChange(kea.keyCode, false);
	}
	
	void keyChange(Keys key, bool pressed) {
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
}

int main(char[][] args) {		
	ModuleLoader.loadLibraryInfo(ResourceToStream("libdoc"));

	start();
	
	if (args.length >= 2) load(args[1], false); else throw(new Exception("Needed pbp to launch"));

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
		Application.run(new PSP_DisplayForm_OGL);
	}
	
	
	return 0;
}