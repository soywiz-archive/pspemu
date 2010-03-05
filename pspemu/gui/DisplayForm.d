module pspemu.gui.DisplayForm;

import dfl.all, dfl.internal.winapi;
import core.thread;
import std.stdio, std.c.time;

import pspemu.gui.GLControl;

class DisplayForm : Form/*, IMessageFilter*/ {
	GLControlDisplay glc;

	this() {
		//Application.addMessageFilter(this);
		
		startPosition = FormStartPosition.CENTER_SCREEN;
		icon = Application.resources.getIcon(101);
		setClientSizeCore(480, 272);
		text = "Display (OpenGL)";
		maximumSize = Size(width, height);
		minimumSize = Size(width, height);
		
		with (glc = new GLControlDisplay) {
			dock    = DockStyle.FILL;
			parent  = this;
			visible = true;
		}
		
		prepareScreen();

		{
			auto glControl = new GLControl();
			with (glControl) {
				width   = 480;
				height  = 272;
				parent  = this;
				visible = false;
			}
			
			//cpu.gpu.init(glControl);
		}
		
		//cpu.interrupt = false; cpu.pauseAt = 0;
	}
	
	override protected void onClosing(CancelEventArgs cea) {
		glc.stop();
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

class GLControlDisplay : GLControl {
	bool update = true, updateOnce = false;
	bool running = true;
	bool ready = false;
	ubyte[] data;
	
	void threadRun() {
		long bcounter, counter, frequency, delay;
		QueryPerformanceFrequency(&frequency);

		delay = frequency / 60;

		data = new ubyte[512 * 272 * 4];
		for (int n = 0; n < data.length; n++) {
			data[n] = cast(ubyte)n;
		}
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

						{
							glDisable(GL_ALPHA_TEST); glDisable(GL_BLEND); glDisable(GL_DEPTH_TEST);
							glDisable(GL_DITHER); glDisable(GL_FOG); glDisable(GL_LIGHTING);
							glDisable(GL_LOGIC_OP); glDisable(GL_STENCIL_TEST); glDisable(GL_TEXTURE_1D);
							glDisable(GL_TEXTURE_2D); glPixelTransferi(GL_MAP_COLOR, GL_FALSE);
							glPixelTransferi(GL_RED_SCALE, 1); glPixelTransferi(GL_RED_BIAS, 0);
							glPixelTransferi(GL_GREEN_SCALE, 1); glPixelTransferi(GL_GREEN_BIAS, 0);
							glPixelTransferi(GL_BLUE_SCALE, 1); glPixelTransferi(GL_BLUE_BIAS, 0);
							glPixelTransferi(GL_ALPHA_SCALE, 1); glPixelTransferi(GL_ALPHA_BIAS, 0);
							/*
							#ifdef GL_EXT_convolution glDisable(GL_CONVOLUTION_1D_EXT);
							glDisable(GL_CONVOLUTION_2D_EXT); glDisable(GL_SEPARABLE_2D_EXT); #endif
							#ifdef GL_EXT_histogram glDisable(GL_HISTOGRAM_EXT);
							glDisable(GL_MINMAX_EXT); #endif
							#ifdef GL_EXT_texture3D glDisable(GL_TEXTURE_3D_EXT); #endif
							*/
						}
						//glClearColor(1, 1, 1, 1); glClear(GL_COLOR_BUFFER_BIT);

						//glDrawPixels(cpu.gpu.displayBuffer.width, 272, GL_RGBA, cpu.gpu.displayBuffer.formatGl, cpu.gpu.displayBuffer.pptr);
						glDrawPixels(512, 272, GL_RGBA, GL_UNSIGNED_BYTE, data.ptr);

						swapBuffers();
					}
					
					//bios.vblank = true;
					
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
	
	this() {
	}
	
	override void onHandleCreated(EventArgs ea) {
		super.onHandleCreated(ea);
		(new Thread(&threadRun)).start();
	}
	
	~this() {
		stop();
	}
}