module pspemu.gui.DisplayForm;

import dfl.all, dfl.internal.winapi;
import core.thread;
import std.stdio, std.c.time;
import std.typetuple;

import pspemu.gui.GLControl;
import pspemu.models.IDisplay;

class DisplayForm : Form/*, IMessageFilter*/ {
	GLControlDisplay glc;
	IDisplay display;

	this(IDisplay display = null) {
		if (display is null) display = new NullDisplay;
		this.display = display;
		
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
	}
	
	override void onPaint  (PaintEventArgs ea  ) { glc.refresh(); }
	override void onResize (EventArgs ea       ) { glc.refresh(); }
	override void onClosing(CancelEventArgs cea) { glc.stop(); }
	
	override void onPaintBackground(PaintEventArgs pea) { }      
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

		Sleep(100);

		while (running) {
			writefln("threadRun.loop started");
			try {
				//while (!ready) Sleep(1);
				while (running) {
					QueryPerformanceCounter(&bcounter);
					
					//if ((update && !cpu.paused) || updateOnce) {
					if (update || updateOnce) {
						updateOnce = false;

						// Check OpenGL.
						glInit(); assert(glMatrixMode !is null);

						makeCurrent();

						glMatrixMode(GL_MODELVIEW ); glLoadIdentity();
						glMatrixMode(GL_PROJECTION); glLoadIdentity();
						glPixelZoom(1, -1); glRasterPos2f(-1, 1);

						disableStates();

						glDrawPixels(
							display.frameBufferSize.width,
							display.frameBufferSize.height,
							GL_RGBA,
							GL_UNSIGNED_BYTE,
							display.frameBufferPointer
						);

						swapBuffers();
					}
					
					display.vblank(true);
					
					while (true) {
						QueryPerformanceCounter(&counter);
						if (counter - bcounter >= delay) break;
						//usleep(1000);
						Sleep(1);
					}
				}
			} catch (Object e) {
				writefln("GLControlDisplay.threadRun.error: %s", e);
			} finally {
				writefln("GLControlDisplay.threadRun.end");
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