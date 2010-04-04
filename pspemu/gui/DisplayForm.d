module pspemu.gui.DisplayForm;

import dfl.all, dfl.internal.winapi;

import std.stdio, std.c.time, core.memory;
import std.typetuple;

import pspemu.utils.Utils;

import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Disassembler;

import pspemu.gui.GLControlDisplay;
import pspemu.gui.GLControl;

import pspemu.models.IDisplay;
import pspemu.models.IController;

import pspemu.hle.Module;
import pspemu.hle.Loader;
import pspemu.hle.Syscall;
import pspemu.hle.kd.threadman;

import pspemu.gui.AboutForm;

static const string svnRevision = import("svn.version");

class DisplayForm : Form, IMessageFilter {
	GLControlDisplay glc;
	ModuleManager    moduleManager;
	Loader           loader;
	Cpu              cpu;
	Display          display;
	IController      controller;
	real             lastFps;

	void updateTitle() {
		text = std.string.format("D PSP Emulator - r%s - FPS: %.1f - %s", svnRevision, lastFps, enumToString(cpu.runningState));
	}

	int resumeCount = 1;

	static const string emulationScopePauseResume = "emulationPauseCount(); scope (exit) emulationResumeCount();";

	void emulationPauseCount() {
		if (--resumeCount <= 0) {
			cpu.pause();
			updateTitle();
		}
	}

	void emulationResumeCount() {
		if (++resumeCount > 0) {
			cpu.resume();
			updateTitle();
		}
	}

	void emulationPause() {
		resumeCount = 1;
		emulationPauseCount();
	}
	
	void emulationResume() {
		resumeCount = 0;
		emulationResumeCount();
	}

	void emulationReset() {
		try {
			mixin(emulationScopePauseResume);
			loader.reloadAndExecute();
		} catch (Object o) {
			msgBox(o.toString(), "Error reloading", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		}
	}

	void emulationStop() {
		resumeCount = resumeCount.init;
		cpu.stop();
		updateTitle();
	}

	this(bool showMainMenu = false, Loader loader = null, ModuleManager moduleManager = null, Cpu cpu = null, Display display = null, IController controller = null) {
		Application.addMessageFilter(this);

		this.moduleManager = moduleManager;
		this.cpu = cpu;
		this.loader = loader;
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
			static if (0) {
				dock    = DockStyle.FILL;
			} else {
				width   = displaySize.width;
				height  = displaySize.height;
			}
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
				if (lastFps == 0) lastFps = std.math.NaN(0);
				updateTitle();
				display.fpsCounter = 0;
			};
			start();
		}
	}

	void attachMenu() {
		menu = new MainMenu;
		Menu currentMenu = menu;

		MenuItem addClick(string name, void delegate(MenuItem, EventArgs) registerCallback = null, void delegate() menuGenerateCallback = null) {
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
			
			return menuItem;
		}

		MenuItem add(string name, void delegate() menuGenerateCallback = null) {
			return addClick(name, null, menuGenerateCallback);
		}

		add("&File", {
			addClick("&Open...", (MenuItem mi, EventArgs ea) {
				auto fd = new OpenFileDialog;
				fd.filter  = "PSP Executable Files (*.pbp;*.elf;*.asm;*.iso;*.cso;*.dax)|*.pbp;*.elf;*.asm;*.iso;*.cso;*.dax|All Files (*.*)|*.*";

				// Pauses execution and resumes at the end.
				mixin(emulationScopePauseResume);
				//emulationPauseCount();

				if (fd.showDialog(this) == DialogResult.OK) {
					try {
						loader.loadAndExecute(fd.fileName);
					} catch (Object o) {
						msgBox(o.toString(), "Error loading", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
					}
				} else {
					//emulationResumeCount();
				}
			});
			add("-");
			addClick("&Exit", (MenuItem mi, EventArgs ea) {
				//cpu.stop();
				this.close();
				//Application.exit();
			});
		});
		add("&Run", {
			addClick("&Execute", (MenuItem mi, EventArgs ea) {
				emulationResume();
			});
			addClick("&Pause", (MenuItem mi, EventArgs ea) {
				emulationPause();
			});
			add("-");
			addClick("&Reset", (MenuItem mi, EventArgs ea) {
				emulationReset();
			});
			addClick("&Stop", (MenuItem mi, EventArgs ea) {
				emulationStop();
			});
			/* // For Debugger
			add("-");
			add("Step &Into");
			add("Step &Over");
			add("Run to &Cursor");
			add("Run until &Return");
			*/
			/*
			add("-");
			add("S&ave State...");
			add("&Load State...");
			*/
		});
		add("&Tools", {
			/*
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
			add("Ignore errors");
			*/
			addClick("Take Screenshot...", (MenuItem mi, EventArgs ea) {
				mixin(emulationScopePauseResume);

				std.date.Date date; date.parse(std.date.toUTCString(std.date.UTCtoLocalTime(std.date.getUTCtime())));
				string filename = std.string.format("dpspemu screenshot - %04d-%02d-%02d %02d-%02d-%02d.png", date.year, date.month, date.day, date.hour, date.minute, date.second);

				SaveFileDialog fd = new SaveFileDialog;
				fd.defaultExt = "png";
				fd.fileName = filename;
				fd.filter = "PNG files (*.png)|*.png";

				if (fd.showDialog(this) == DialogResult.OK) {
					scope file = new BufferedFile(fd.fileName, FileMode.OutNew);
					
					void writeChunk(string type, ubyte[] data = []) {
						scope fullData = cast(ubyte[])type[0..4] ~ data;
						file.write(std.intrinsic.bswap(data.length));
						file.write(fullData);
						file.write(std.intrinsic.bswap(std.zlib.crc32(0, fullData)));
					}
					
					//ImageFileFormatProvider["png"].write(bmp, fd.fileName);
					static struct PNG_IHDR { align(1):
						uint width;   // 480 big endian
						uint height;  // 272 big endian
						ubyte bps   = 8;
						ubyte ctype = 6;
						ubyte comp  = 0;
						ubyte filter = 0;
						ubyte interlace = 0;
					}
					alias std.intrinsic.bswap BE;
					file.write(cast(ubyte[])x"89504E470D0A1A0A");
					writeChunk("IHDR", TA(PNG_IHDR(BE(480), BE(272))));
					auto screenData = glc.takeScreenshot();
					ubyte[] data;
					int rowsize = 480 * 4;
					for (int n = 0; n < 272; n++) {
						data ~= 0;
						int crow = 271 - n;
						data ~= screenData[(crow + 0) * rowsize..(crow + 1) * rowsize];
					}
					writeChunk("IDAT", cast(ubyte[])std.zlib.compress(data, 9));
					writeChunk("IEND");

					file.flush();
					file.close();
				}
			});
			add("-");
			addClick("Frame &limiting", (MenuItem mi, EventArgs ea) {
				mi.checked = !mi.checked;
				display.frameLimiting = mi.checked;
			}).checked = true;
		});
		add("&Help", {
			addClick("&Website", (MenuItem mi, EventArgs ea) {
				ShellExecuteA(null, "open", "http://pspemu.soywiz.com/", null, null, SW_SHOWNORMAL);
			});
			addClick("&About...", (MenuItem mi, EventArgs ea) {
				string str = std.string.format(
					"D PSP Emulator\n"
					"soywiz 2008,2010\n"
					"\n"
					"Compiler: %s v%.3f\n"
					"Compiled on: %s\n"
					"SVN revision: %s\n"
					, __VENDOR__
					, cast(float)(__VERSION__) / 1000
					, __TIMESTAMP__
					, svnRevision
				);
				msgBox(str, "About", MsgBoxButtons.OK, MsgBoxIcon.INFORMATION, MsgBoxDefaultButton.BUTTON1);	
			});
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
