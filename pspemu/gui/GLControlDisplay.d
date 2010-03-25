module pspemu.gui.GLControlDisplay;

import dfl.all, dfl.internal.winapi;

import core.thread, core.memory;

import std.stdio, std.c.time;

import pspemu.core.gpu.impl.GpuOpengl;

import pspemu.gui.GLControl;
import pspemu.models.IDisplay;

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
