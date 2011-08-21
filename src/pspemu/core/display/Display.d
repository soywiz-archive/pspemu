module pspemu.core.display.Display;

import pspemu.interfaces.IResetable;
import pspemu.interfaces.IInterruptable;
import pspemu.interfaces.IDisplay;

import core.thread;
import std.stdio;
//import std.signals;

import core.sync.mutex;
import core.sync.condition;

import std.datetime;

import pspemu.utils.Logger;
import pspemu.utils.Event;

import pspemu.core.Interrupts;

import pspemu.utils.sync.WaitEvent;
import pspemu.utils.sync.WaitMultipleObjects;

/*
http://lan.st/archive/index.php/t-1103.html

Very sexy stuff, great work ;).
	
VSYNC freq of native psp lcd == (approx) 59.94Hz
	
or precisely (pixel_clk_freq * cycles_per_pixel)/(row_pixels * column_pixel)
so (9MHz * 1)/(525 * 286) == 59.9400599........ etc. etc.
	
HSYNC freq == (appox) 17.142KHz
	
or precisely (pixel_clk_freq * cycles_per_pixel)/(row_pixels)
so (9MHz * 1)/(525) == 17142.85714........ etc. etc.
*/
class Display : IDisplay {
	struct Info {
		/**
		 * Mode of the screen.
		 * Usually it's 0.
		 */
		int  mode;
		int  width;
		int  height;
		uint topaddr;
		uint bufferwidth;
		
		/**
		 * Format of every pixel on the screen.
		 */
		PspDisplayPixelFormats pixelformat;
		PspDisplaySetBufSync sync;
		uint CURRENT_HCOUNT;
		uint VBLANK_COUNT;
		
		public string toString() {
			string r = "";
			r ~= format("Display(");
			r ~= format("mode=%d, ", mode);
			r ~= format("width=%d, ", width);
			r ~= format("bufferwidth=%d, ", width);
			r ~= format("height=%d, ", height);
			r ~= format("topaddr=0x%08X, ", topaddr);
			r ~= format("pixelformat=%d:'%s', ", pixelformat, to!string(pixelformat));
			r ~= format("sync=%d:'%s', ", sync, to!string(sync));
			r ~= format("CURRENT_HCOUNT=%d, ", CURRENT_HCOUNT);
			r ~= format("VBLANK_COUNT=%d, ", VBLANK_COUNT);
			r ~= format(")");
			return r;
		}
	}
	
	@property public uint currentVblankCount() {
		return info.VBLANK_COUNT;
	}
	
	public Interrupts interrupts;
	public Info info;
	
	protected Thread thread;

	WaitEvent drawRow0ConditionEvent;
	WaitEvent vblankStartConditionEvent;
	WaitEvent interruptedEvent;
	WaitEvent initializedEvent;
	Event vblankEvent;
	
	protected bool running = true;
	
	public bool enableWaitVblank = true;
	
	const real processed_pixels_per_second = 9_000_000; // hz
	const real cycles_per_pixel            = 1;
	const real pixels_in_a_row             = 525;
	const real vsync_row                   = 272;
	const real number_of_rows              = 286;
	
	const real hsync_hz = (processed_pixels_per_second * cycles_per_pixel) / pixels_in_a_row;
	const real vsync_hz = hsync_hz / number_of_rows;
	
	this(Interrupts interrupts) {
		this.interrupts = interrupts;

		//this.drawRow0Condition    = new Condition(new Mutex);
		//this.vblankStartCondition = new Condition(new Mutex);

		this.drawRow0ConditionEvent    = new WaitEvent("drawRow0ConditionEvent");
		this.vblankStartConditionEvent = new WaitEvent("vblankStartConditionEvent");
		this.interruptedEvent          = new WaitEvent("interruptedEvent");
		
		this.initializedEvent = new WaitEvent("Display.initializedEvent");
		
		sceDisplaySetMode(0, 480, 272);
		sceDisplaySetFrameBuf(0x44000000, 512, PspDisplayPixelFormats.PSP_DISPLAY_PIXEL_FORMAT_8888, PspDisplaySetBufSync.PSP_DISPLAY_SETBUF_IMMEDIATE);
	}
	
	void reset() {
		this.running = true;
	}
	
	void interrupt() {
		this.running = false;
		interruptedEvent.wait();
	}

	public void sceDisplaySetMode(int mode = 0, int width = 480, int height = 272) {
		Logger.log(Logger.Level.TRACE, "Display", "sceDisplaySetMode(%d, %d, %d)", mode, width, height);
		this.info.mode   = mode;
		this.info.width  = width;
		this.info.height = height;
	}
	
	public void sceDisplaySetFrameBuf(uint topaddr, uint bufferwidth, PspDisplayPixelFormats pixelformat, PspDisplaySetBufSync sync) {
		this.info.topaddr     = topaddr;
		this.info.bufferwidth = bufferwidth;
		this.info.pixelformat = pixelformat;
		this.info.sync        = sync;
		Logger.log(Logger.Level.TRACE, "Display", "sceDisplaySetFrameBuf(%08X, %d, %d, %d)", topaddr, bufferwidth, pixelformat, sync);
	}
	
	public void start() {
		this.thread = new Thread(&this.run);
		this.thread.name = "DisplayThread";
		this.thread.start();
	}
	
	public void waitStarted() {
		initializedEvent.wait();
	}
	
	int lastWaitedVblank = -1;

	public void waitVblankReadCtrlFrame() {
		if (enableWaitVblank) {
			Thread.sleep(dur!"msecs"(10));
		}
	}	
	
	public void waitVblank(bool processCallbacks = false) {
		//writefln("***************************************** [1]");
		if (enableWaitVblank) {
			//writefln("***************************************** [2]");
			if (lastWaitedVblank >= info.VBLANK_COUNT) {
				//writefln("***************************************** [3]");
				//vblankStartCondition.wait(processCallbacks);
				WaitMultipleObjects waitMultipleObjects = new WaitMultipleObjects();
				waitMultipleObjects.add(vblankStartConditionEvent);
				waitMultipleObjects.waitAny();
			}
			lastWaitedVblank = info.VBLANK_COUNT;
		}
	}

	protected void run() {
		StopWatch stopWatch;
		
		initializedEvent.signal();
		
		// @TODO: use stopWatch to allow frameskipping
		uint drawAdd = 0;
		while (this.running) {
			info.CURRENT_HCOUNT = 0;
			
			ulong second = 1_000_000;
			
			if (!enableWaitVblank) {
				second = 100_000;
				drawAdd += 1;
			} else {
				drawAdd += 10;
			}

			if (drawAdd >= 10) {
				//this.drawRow0Condition.notifyAll();
				this.drawRow0ConditionEvent.signal();
			}
			Thread.sleep(dur!"usecs"(cast(ulong)(second * (vsync_row / hsync_hz))));
			info.CURRENT_HCOUNT = cast(uint)vsync_row;

			if (drawAdd >= 10) {
				this.vblankEvent();
				//this.vblankStartCondition.notifyAll();
				this.vblankStartConditionEvent.signal();
			}

			this.interrupts.interrupt(Interrupts.Type.Vblank);
			info.VBLANK_COUNT++;

			Thread.sleep(dur!"usecs"(cast(ulong)(second * ((number_of_rows - vsync_row) / hsync_hz))));
			
			if (drawAdd >= 10) {
				drawAdd -= 10;
			}
		}
		
		interruptedEvent.signal();
		
		Logger.log(Logger.Level.TRACE, "Display", "Display.run::ended");
	}
	
	public string toString() {
		return info.toString();
	}
}
