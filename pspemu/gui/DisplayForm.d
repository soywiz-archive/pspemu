module pspemu.gui.DisplayForm;

import dfl.all, dfl.internal.winapi;

import core.thread, core.memory;

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

		//Thread.sleep(100_0000);
		Sleep(100);

		while (running) {
			writefln("threadRun.loop started");
			try {
				// Check OpenGL.
				glInit(); assert(glMatrixMode !is null);

				makeCurrent();

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

						static const auto formatList = [
							GL_UNSIGNED_SHORT_5_6_5_REV,   // PSP_DISPLAY_PIXEL_FORMAT_565    16-bit RGB 5:6:5.
							GL_UNSIGNED_SHORT_1_5_5_5_REV, // PSP_DISPLAY_PIXEL_FORMAT_5551   16-bit RGBA 5:5:5:1.
							GL_UNSIGNED_SHORT_4_4_4_4_REV, // PSP_DISPLAY_PIXEL_FORMAT_4444 	
							GL_UNSIGNED_INT_8_8_8_8_REV,   // PSP_DISPLAY_PIXEL_FORMAT_8888
						];
						
						/*
							// pspemu_old/src/core/gpu.d

							static PixelFormat[] PIXELF_T = [
								PixelFormat(  2, 3, GL_RGB,  GL_UNSIGNED_SHORT_5_6_5_REV),
								PixelFormat(  2, 4, GL_RGBA, GL_UNSIGNED_SHORT_1_5_5_5_REV),
								PixelFormat(  2, 4, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4_REV),
								PixelFormat(  4, 4, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV),
								PixelFormat(0.5, 1, GL_RED,  GL_UNSIGNED_BYTE),
								PixelFormat(  1, 1, GL_RED,  GL_UNSIGNED_BYTE),
								PixelFormat(  2, 4, GL_RGBA, GL_UNSIGNED_SHORT),
								PixelFormat(  4, 4, GL_RGBA, GL_UNSIGNED_INT),
								PixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT1_EXT),
								PixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT3_EXT),
								PixelFormat(  4, 4, GL_RGBA, GL_COMPRESSED_RGBA_S3TC_DXT5_EXT),
							];
						*/

						glDrawPixels(
							display.frameBufferSize.width,
							display.frameBufferSize.height,
							GL_RGBA,
							formatList[display.frameBufferPixelFormat & 3],
							display.frameBufferPointer
						);

						swapBuffers();
					}
					
					display.vblank = true;
					
					//GC.minimize();
					//GC.collect();
					
					while (true) {
						QueryPerformanceCounter(&counter);
						//Thread.sleep(0_5000);
						if (counter - bcounter >= delay) break;
						//Thread.sleep(0_5000);
						Sleep(1);
					}

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