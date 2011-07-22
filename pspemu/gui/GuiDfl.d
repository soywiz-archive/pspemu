module pspemu.gui.GuiDfl;

import dfl.all;
import dfl.internal.winapi;
import dfl.ext.DirectBitmap;
import dfl.ext.DrawingArea;

import std.stdio;
import core.thread;
import core.memory;
import std.process;

import pspemu.EmulatorHelper;

import pspemu.gui.GuiBase;
import pspemu.utils.MathUtils;

import pspemu.core.cpu.CpuThreadBase;

import pspemu.core.gpu.PixelDecoder;
import pspemu.utils.SvnVersion;

import pspemu.utils.imaging.hq2x;

import pspemu.utils.Path;

import pspemu.utils.UpdateChecker;

//version = USE_HQ2X;

//import pspemu.hle.kd.iofilemgr.Devices;
import pspemu.hle.vfs.devices.MemoryStickDevice;

MenuItem createMenu(string name, MenuItem[] childs = null) {
	MenuItem menuItem = new MenuItem(name, childs);
	menuItem.popup ~= delegate(MenuItem mi, EventArgs ea) {
		//writefln("popup!!");
		foreach (child; childs) child.popup(child, ea);
	};
	return menuItem;
}

MenuItem createMenu(string name, void delegate(MenuItem mi, EventArgs ea) clickCallback, bool delegate() checkedCallback = null, bool enabled = true) {
	MenuItem menuItem = new MenuItem;
	menuItem.text = name;
	if (clickCallback !is null) menuItem.click ~= clickCallback;
	if (checkedCallback !is null) {
		menuItem.popup ~= delegate(MenuItem mi, EventArgs ea) { mi.checked = checkedCallback(); };				
		menuItem.checked = checkedCallback();
	}
	menuItem.enabled = enabled;
	return menuItem;
}

MenuItem createMenu(string name, void delegate() clickCallback, bool delegate() checkedCallback = null, bool enabled = true) {
	return createMenu(name, delegate(MenuItem mi, EventArgs ea) { clickCallback(); }, checkedCallback, enabled);
}

MainMenu createMainMenu(MenuItem[] childs) {
	MainMenu mainMenu = new MainMenu();
	if (childs !is null) foreach (k, child; childs) {
		child.index = k;
		mainMenu.menuItems.add(child);
	}
	/*
	mainMenu.popup ~= delegate(MenuItem mi, EventArgs ea) {
		writefln("popupmainMenu!!");
	};
	*/
	return mainMenu;
}

class MainForm : Form, IMessageFilter {
	GuiDfl guiDfl;
	DrawingArea drawingArea2x;
	DrawingArea drawingArea1x;
	int windowSize = -1;
	bool justUpdatedWindowSize;
	PspCtrlButtons[255] buttonMaskDigital;
	PspCtrlButtons[255] buttonMaskAnalog;
	bool _scale2x = false;
	
	bool scale2x() {
		return _scale2x;
	}

	void scale2x(bool v) {
		_scale2x = v;
	}
	
	void setScale2xVisibility() {
		drawingArea1x.visible = !scale2x;
		drawingArea2x.visible = scale2x;
	}
	
	@property auto gpu() {
		return guiDfl.hleEmulatorState.emulatorState.gpu;
	}

	
	void setTitle() {
		string ctext = "";
		ctext ~= std.string.format("D PSP Emulator r%d", SvnVersion.revision);
		ctext ~= std.string.format(" - %s", guiDfl.hleEmulatorState.mainModuleName); 
		ctext ~= std.string.format(" - %s", guiDfl.hleEmulatorState.rootFileSystem.gameID);
		ctext ~= std.string.format(" - Gpu: %dms", gpu.lastFrameTime);
		ctext ~= std.string.format(" - Prims: %d", gpu.numberOfPrims);
		ctext ~= std.string.format(" - Vertices: %d", gpu.numberOfVertices);
		ctext ~= std.string.format(" - GpuVertex: %dms", gpu.lastVertexExtractionTime);
		ctext ~= std.string.format(" - GpuState: %dms", gpu.lastSetStateTime);
		ctext ~= std.string.format(" - GpuDraw: %dms", gpu.lastDrawTime);
		ctext ~= std.string.format(" - GpuBufTrans: %dms", gpu.lastBufferTransferTime);
		try {
			ctext ~= std.string.format(" - GpuTexCount: %d", gpu.impl.getTextureCacheCount());
			ctext ~= std.string.format(" - GpuSizeCount: %.2f MB", cast(float)gpu.impl.getTextureCacheSize() / 1024 / 1024);
		} catch (Throwable o) {
			
		}
		
		this.text = ctext; 
	}

	void clickToolsWindowSize(int mult) {
		if (windowSize != mult) {
			windowSize = mult;
			justUpdatedWindowSize = true;
			setClientSizeCore(480 * windowSize, 272 * windowSize);
		}
	}

	this(GuiDfl guiDfl) {
		this.guiDfl = guiDfl;

		setButtonMasks();

		Application.addMessageFilter(this);
		
		setTitle();
		startPosition = FormStartPosition.CENTER_SCREEN;
		/*
		MainMenu mainMenu = new MainMenu();
		MenuItem mi = new MenuItem("Exit");
		mi.click ~= delegate(MenuItem mi, EventArgs ea) {
			writefln("CLICK: %s", mi);
		};
		mainMenu.menuItems.add(mi);
		
		menu = mainMenu;
		*/
		menu = createFromMainMenu();
		controls().add(drawingArea1x = new DrawingArea(480 * 1, 272 * 1));
		controls().add(drawingArea2x = new DrawingArea(480 * 2, 272 * 2));
		
		icon = Application.resources().getIcon(101);
		//setScale2xVisibility();

		drawingArea1x.dock = DockStyle.FILL;
		drawingArea2x.dock = DockStyle.FILL;

		resize ~= delegate(Control control, EventArgs ea) {
			if (justUpdatedWindowSize) {
				justUpdatedWindowSize = false;
				return;
			}
			windowSize = -1;
		};
		
		closed ~= delegate(Control control, EventArgs ea) {
			guiDfl.dumpThreads();
		};

		setClientSizeCore(480, 272);
		minimumSize = size;
		
		clickToolsWindowSize(1);
		
		guiDfl.started = true;
	}
	
	MainMenu createFromMainMenu() {
		return createMainMenu([
			createMenu("&File", [
				createMenu("&Open...", { clickOpen(); }),
				createMenu("-"),
				createMenu("&Exit", { this.close(); }),
			]),
			createMenu("&Run", [
				createMenu("&Execute"),
				createMenu("&Pause"),
				createMenu("-"),
				createMenu("&Reset"),
				createMenu("&Stop"),
			]),
			createMenu("&Tools", [
				createMenu("Memory stick", [
					createMenu("&Toggle\tF4", { clickToolsMemoryStickToogle(); }),
					createMenu("&Eject", { clickToolsMemoryStickSetInserted(false); }),
					createMenu("&Insert", { clickToolsMemoryStickSetInserted(true); }),
				]),
				createMenu("-"),
				createMenu("Window &Size...", [
					createMenu("Size x1\t1", { clickToolsWindowSize(1); }, { return windowSize == 1; }),
					createMenu("Size x2\t2", { clickToolsWindowSize(2); }, { return windowSize == 2; }),
					createMenu("Size x3\t3", { clickToolsWindowSize(3); }, { return windowSize == 3; }),
					createMenu("Custom size", {}, { return windowSize == -1; }, false),
				]),
				createMenu("HQ2X\tF8", { scale2x = !scale2x; }, { return scale2x; }),
				createMenu("&Take screenshot..."),
				createMenu("&Dump GPU frame and textures\tF6", { clickRecordGpuFrame(); }),
				createMenu("-"),
				createMenu("Frame limiting\tF3", {
					guiDfl.display.enableWaitVblank = !guiDfl.display.enableWaitVblank;
				}, {
					return guiDfl.display.enableWaitVblank;
				}),
				createMenu("Gpu DrawBufferTransfer\tF9", {
					gpu.drawBufferTransferEnabled = !gpu.drawBufferTransferEnabled;
				}, {
					return gpu.drawBufferTransferEnabled;
				}),
				createMenu("Gpu Just Transfer buffers on Vblank\tF10", {
					gpu.justDrawOnVblank = !gpu.justDrawOnVblank;
				}, {
					return gpu.justDrawOnVblank;
				}),
				createMenu("-"),
				createMenu("Dump Threads\tF2"),
				createMenu("-"),
				createMenu("Asociate extensions (.cso, .pbp)", {
					RunAsAdmin(ApplicationPaths.executablePath, "--associate_extensions");
				}),
			]),
			createMenu("&Extra", [
				createMenu("&Indie games (kawagames.com)", { ShellExecuteA(null, "open", "http://kawagames.com/", null, null, SW_SHOWNORMAL); }),
			]),
			createMenu("&Help", [
				createMenu("Oficial &Website", { ShellExecuteA(null, "open", "http://pspemu.soywiz.com/", null, null, SW_SHOWNORMAL); }),
				createMenu("&Compatibility Table", { ShellExecuteA(null, "open", "http://pspemu.soywiz.com/p/compatibility.html", null, null, SW_SHOWNORMAL); }),
				createMenu("Check for &updates...", {
					UpdateChecker.tryCheckBackground(delegate(bool result) {
						if (!result) {
							msgBox("No new version available", "You have the lastest version", MsgBoxButtons.OK, MsgBoxIcon.INFORMATION, MsgBoxDefaultButton.BUTTON1);
						}
					}, true);
					/*
					Thread thread = new Thread({
						int lastestVersion = SvnVersion.getLastOnlineVersion;
						int currentVersion = SvnVersion.revision;
						if (currentVersion < lastestVersion) {
							string str = std.string.format(
								"You have version %d\n"
								"And there is a new version %d\n"
								"\n" 
								"Would you like to download it?"
							, currentVersion ,lastestVersion);
							if (msgBox(str, "New version!", MsgBoxButtons.YES_NO, MsgBoxIcon.ASTERISK, MsgBoxDefaultButton.BUTTON1) == DialogResult.YES) {
								ShellExecuteA(null, "open", "http://pspemu.soywiz.com/", null, null, SW_SHOWNORMAL);
							}
						} else {
						}
					});
					thread.name = "CheckNewVersionThread";
					thread.start();
					*/
				}),
				createMenu("&About...", {
					string str = std.string.format(
                        "D PSP Emulator\n"
                        "soywiz 2008-2011\n"
                        "\n"
                        "Compiler: %s v%.3f\n"
                        "Compiled on: %s\n"
                        "SVN revision: %s\n"
                        //"DFL version: %s\n"
                        , __VENDOR__
                        , cast(float)(__VERSION__) / 1000
                        , __TIMESTAMP__
                        , SvnVersion.revision
                        //, dflVersion
                    );
                    msgBox(str, "About", MsgBoxButtons.OK, MsgBoxIcon.INFORMATION, MsgBoxDefaultButton.BUTTON1);
				}),
			]),
		]);
	}
	
	void clickRecordGpuFrame() {
		gpu.recordFrame();
	}
	
	void clickOpen() {
		OpenFileDialog openFileDialog = new OpenFileDialog();
		openFileDialog.filter = "All compatible files EBOOT.PBP, ELF and ISO Files|EBOOT.PBP;*.elf;*.iso;*.cso|All files (*.*)|*.*";
		if (openFileDialog.showDialog() == DialogResult.OK) {
			Thread thread = new Thread({
				//writefln("[1]");
				guiDfl.emulatorHelper.reset();
				//guiDfl.emulatorHelper.emulator.emulatorState.runningState.stopCpu();
				//writefln("[2]");
				//guiDfl.emulatorHelper.emulator.emulatorState.waitForAllCpuThreadsToTerminate();
				//writefln("[3]");
				guiDfl.emulatorHelper.loadMainModule(openFileDialog.fileName);
				//writefln("[4]");
				guiDfl.emulatorHelper.start();
				//writefln("[5]");
			});
			thread.name = "GuiOpen";
			thread.start();
		}
		//openFileDialog.
	}
	
	void clickToolsMemoryStickToogle() {
		clickToolsMemoryStickSetInserted(false, true);
	}
	
	void clickToolsMemoryStickSetInserted(bool inserted, bool toggle = false) {
		MemoryStickDevice memoryStickDevice = guiDfl.hleEmulatorState.rootFileSystem.getDevice!MemoryStickDevice("ms0:");
		if (toggle) inserted = !memoryStickDevice.inserted; 
		memoryStickDevice.inserted = inserted;
	}

	void setButtonMasks() {
		buttonMaskDigital[37 ] = PspCtrlButtons.PSP_CTRL_LEFT;
		buttonMaskDigital[38 ] = PspCtrlButtons.PSP_CTRL_UP;
		buttonMaskDigital[39 ] = PspCtrlButtons.PSP_CTRL_RIGHT;
		buttonMaskDigital[40 ] = PspCtrlButtons.PSP_CTRL_DOWN; 
		buttonMaskDigital['W'] = PspCtrlButtons.PSP_CTRL_TRIANGLE;
		buttonMaskDigital['A'] = PspCtrlButtons.PSP_CTRL_SQUARE;
		buttonMaskDigital['S'] = PspCtrlButtons.PSP_CTRL_CROSS;
		buttonMaskDigital['D'] = PspCtrlButtons.PSP_CTRL_CIRCLE;
		buttonMaskDigital['Q'] = PspCtrlButtons.PSP_CTRL_LTRIGGER;
		buttonMaskDigital['E'] = PspCtrlButtons.PSP_CTRL_RTRIGGER;
		buttonMaskDigital[13 ] = PspCtrlButtons.PSP_CTRL_START;
		buttonMaskDigital[32 ] = PspCtrlButtons.PSP_CTRL_SELECT;

		buttonMaskAnalog['J'] = PspCtrlButtons.PSP_CTRL_LEFT;
		buttonMaskAnalog['I'] = PspCtrlButtons.PSP_CTRL_UP;
		buttonMaskAnalog['L'] = PspCtrlButtons.PSP_CTRL_RIGHT;
		buttonMaskAnalog['K'] = PspCtrlButtons.PSP_CTRL_DOWN;
	}
	
	override bool preFilterMessage(ref Message msg) {
		switch (msg.msg) {
			case WM_KEYDOWN, WM_KEYUP: {
				bool processedKey = false;
				SceCtrlData *sceCtrlData = &guiDfl.controller.sceCtrlData;
				PspCtrlButtons maskDigital = buttonMaskDigital[msg.wParam & 0xFF];
				PspCtrlButtons maskAnalog = buttonMaskAnalog[msg.wParam & 0xFF];
				bool Pressed = (msg.msg == WM_KEYDOWN);
				//writefln("%032b:%d", buttonMask, Pressed);
				sceCtrlData.SetPressedButton(maskDigital, Pressed);
				sceCtrlData.SetPressedButtonAnalog(maskAnalog, Pressed);
				
				if (maskDigital != 0) processedKey = true;
				if (maskAnalog != 0) processedKey = true;
				
				if (processedKey) return true;
			} break;
			default: break;
		}

		switch (msg.msg) {
			//case WM_KEY:
			case WM_KEYDOWN:
				//.writefln("%d %d", msg.lParam, msg.wParam);
				switch (cast(char)msg.wParam) {
					case '1', '2', '3':
						int mult = (msg.wParam - '0');
						clickToolsWindowSize(mult);
						return true;
					break;
					default: break;
				}
				
				switch (msg.wParam) {
					case VK_F1:
						guiDfl.dumpMemory();
						return true;
					break;
					case VK_F2:
						guiDfl.dumpThreads();
						guiDfl.dumpDisplayMode();
						return true;
					break;
					case VK_F3:
						guiDfl.display.enableWaitVblank = !guiDfl.display.enableWaitVblank;
						return true;
					break;
					case VK_F4: {
						clickToolsMemoryStickToogle();
						return true;
					} break;
					case VK_F6: {
						clickRecordGpuFrame();
						return true;
					} break;
					case VK_F8: {
						scale2x = !scale2x;
						return true;
					} break;
					case VK_F9:
						gpu.drawBufferTransferEnabled = !gpu.drawBufferTransferEnabled;
						return true;
					break;
					case VK_F10:
						gpu.justDrawOnVblank = !gpu.justDrawOnVblank;
						return true;
					break;
					case VK_F12:
						//core.memory.GC.minimize();
						core.memory.GC.collect();
						return true;
					break;

					default:
					break;
				}
			break;
			default:
			break;
		}
		
		return false;
	}
}

class GuiDfl : GuiBase {
	MainForm mainForm = null;
	bool ended;
	bool started;

	this(EmulatorHelper emulatorHelper) {
		super(emulatorHelper);
	}
	
	this(HleEmulatorState hleEmulatorState) {
		super(hleEmulatorState);
	}
	
	public void init() {
		GuiDfl guiDfl = this;
		Thread thread = new Thread({
			Application.enableVisualStyles();
			
			Application.run(mainForm = new MainForm(guiDfl));
			ended = true;
			hleEmulatorState.emulatorState.runningState.stop();
		});
		thread.name = "DflThread";
		thread.start();
	}
	
	uint[] tempFullScreen;
	uint[] tempFullScreenX2;
	
	public void loopStep() {
		if (mainForm is null) return;
		if (!started) return;
		if (ended) return;
		
		if (tempFullScreen.length == 0) tempFullScreen = new uint[480 * 272];
		
		//writefln("COMPONENTS: %s, %s", controller, display);
		
		DrawingArea drawingArea;
		Pixel[] pixels;
		if (mainForm.scale2x) {
			drawingArea = mainForm.drawingArea2x;
			if (tempFullScreenX2.length == 0) tempFullScreenX2 = new uint[480 * 2 * 272 * 2];
		} else {
			drawingArea = mainForm.drawingArea1x;
		}
		pixels = drawingArea.dbmp.lock();
		
		//writefln("[1]");
		
		for (int n = 0; n < 272; n++) {
			void* rowInput = this.display.memory.getPointer(this.display.topaddr + n * 512 * PixelFormatSizeMul[display.pixelformat]);
			int rowOutputStart = (271 - n) * 480;
			//Pixel[] rowOutput = pixels[rowOutputStart..rowOutputStart + 480];
			auto rowOutput = tempFullScreen[rowOutputStart..rowOutputStart + 480];

			PixelDecoder.decodePixels(
				cast(PixelFormats)display.pixelformat,
				rowInput,
				cast(PixelDecoder.Pixel[])rowOutput
			);
		}
		
		//writefln("[2] %08X %d, %08X %d", cast(uint)pixels.ptr, pixels.length, cast(uint)tempFullScreen.ptr, tempFullScreen.length);
		
		int count1 = 480 * 272;
		
		if (mainForm.scale2x) {
			hq2x_32(tempFullScreen.ptr, tempFullScreenX2.ptr, 480, 272);
			int count2 = count1 * 2 * 2;
			
			(cast(uint[])pixels)[0..count2] = (cast(uint[])tempFullScreenX2)[0..count2];
			//(cast(uint[])pixels)[0..count1] = (cast(uint[])tempFullScreen)[0..count1];
		} else {
			(cast(uint[])pixels)[0..count1] = (cast(uint[])tempFullScreen)[0..count1];
		}
		
		//writefln("[3]");

		/*		
		for (int n = 0; n < 272; n++) {
			int rowOutputStart = n * 480;
			(cast(uint[])pixels)[rowOutputStart..rowOutputStart + 480] = (cast(uint[])tempFullScreen)[rowOutputStart..rowOutputStart + 480];
		}
		*/

		drawingArea.dbmp.unlock();
		mainForm.setTitle();
		mainForm.setScale2xVisibility();
		drawingArea._invalidate();

		//Graphics g = drawingArea.createGraphics();
		//g.drawText("Hello World", new Font("Arial", 12), Color.fromArgb(255, 255, 255, 255), dfl.drawing.Rect(0, 0, 100, 100));
		
		//writefln("[4]");
		
		this.controller.sceCtrlData.DoEmulatedAnalogFrame();
		this.controller.push();
		
		//writefln("[5]");
	}
}