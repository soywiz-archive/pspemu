module pspemu.gui.GLControlDisplay;

// http://hitmen.c02.at/files/yapspd/psp_doc/chap10.html

import dfl.all, dfl.internal.winapi;

import core.thread, core.memory;

import std.stdio, std.c.time;

import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Interrupts;
import pspemu.core.gpu.Types;
import pspemu.core.gpu.impl.GpuOpenglUtils;

import pspemu.gui.GLControl;
import pspemu.models.IDisplay;

import pspemu.utils.Utils;

class GLControlDisplay : GLControl {
	Display display;
	Cpu      cpu;
	bool update = true, updateOnce = false;
	bool running = true;
	bool ready = false;
	//ubyte[] data;
	
	TaskQueue externalActions;
	
	ubyte[] takeScreenshot() {
		auto screenData = new ubyte[480 * 272 * 4];
		externalActions.addAndWait({
			glReadPixels(
				0, 0, 480, 272,
				GL_RGBA,
				GL_UNSIGNED_BYTE,
				screenData.ptr
			);
		});
		return screenData;
	}

	void threadRun() {
		long backPerformanceCounter, frequency, delay;
		QueryPerformanceFrequency(&frequency);
		
		long performanceCounter() {
			long value = void;
			QueryPerformanceCounter(&value);
			return value;
		}

		delay = frequency / display.verticalRefreshRate;

		//Thread.sleep(100_0000);
		//Sleep(1000);

		while (running) {
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
					backPerformanceCounter = performanceCounter;
					
					//if ((update && !cpu.paused) || updateOnce) {
					if (update || updateOnce) {
						updateOnce = false;
						
						auto pixelFormat = GlPixelFormats[display.frameBufferPixelFormat];

						glPixelStorei(GL_UNPACK_ALIGNMENT, cast(int)pixelFormat.size);
						//glPixelStorei(GL_UNPACK_ROW_LENGTH, PixelFormatUnpackSize(cast(PixelFormats)display.frameBufferPixelFormat, 512));

						glDrawPixels(
							display.frameBufferSize.width,
							display.frameBufferSize.height,
							pixelFormat.external,
							pixelFormat.opengl,
							display.frameBufferPointer
						);

						swapBuffers();
					}
					
					externalActions();
					
					//GC.minimize();
					//GC.collect();

					cpu.interrupts.queue(Interrupts.Type.VBLANK);
					display.VBLANK_COUNT++;
					while (true) {
						if (performanceCounter - backPerformanceCounter >= delay) break;
						GC.minimize();

						if (performanceCounter - backPerformanceCounter >= delay) break;
						Sleep(1);
					}
					//cpu.display.fpsCounter++;
				}
			} catch (Object e) {
				writefln("GLControlDisplay.threadRun.error: %s", e);
			} finally {
				writefln("GLControlDisplay.threadRun.end");
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
	
	this(Cpu cpu, Display display) {
		this.cpu     = cpu;
		this.display = display;
		this.externalActions = new TaskQueue;
	}
	
	override void onHandleCreated(EventArgs ea) {
		super.onHandleCreated(ea);
		(new Thread(&threadRun)).start();
	}
	
	~this() {
		stop();
	}
}
