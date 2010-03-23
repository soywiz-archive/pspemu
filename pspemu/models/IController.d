module pspemu.models.IController;

import std.stdio;
import std.c.time;

import pspemu.utils.Utils;

class Controller { // SceCtrl
	enum Buttons {	
		SELECT     = 0x000001 , // Select button.
		START      = 0x000008 , // Start button.
		UP         = 0x000010 , // Up D-Pad button.
		RIGHT      = 0x000020 , // Right D-Pad button.
		DOWN       = 0x000040 , // Down D-Pad button.
		LEFT       = 0x000080 , // Left D-Pad button.
		LTRIGGER   = 0x000100 , // Left trigger.
		RTRIGGER   = 0x000200 , // Right trigger.
		TRIANGLE   = 0x001000 , // Triangle button.
		CIRCLE     = 0x002000 , // Circle button.
		CROSS      = 0x004000 , // Cross button.
		SQUARE     = 0x008000 , // Square button.
		HOME       = 0x010000 , // Home button.
		HOLD       = 0x020000 , // Hold button.
		NOTE       = 0x800000 , // Music Note button.
		SCREEN     = 0x400000 , // Screen button.
		VOLUP      = 0x100000 , // Volume up button.
		VOLDOWN    = 0x200000 , // Volume down button.
		WLAN_UP    = 0x040000 , // Wlan switch up.
		REMOTE     = 0x080000 , // Remote hold position.
		DISC       = 0x1000000, // Disc present.
		MS         = 0x2000000, // Memory stick present.
	}

	enum Mode {	
		DIGITAL = 0, // Digitial.
		ANALOG  = 1, // Analog.
	}

	struct Frame {		
		uint  TimeStamp; // The current read frame.
		uint  Buttons;   // Bit mask containing zero or more of ::PspCtrlButtons.
		ubyte Lx = 0x7F; // Analogue stick, X axis.
		ubyte Ly = 0x7F; // Analogue stick, Y axis.
		ubyte Rsrv[6];   // Reserved.

		// D additions.
		float x() { return (cast(float)Lx / 255.0) * 2.0 - 0.5; }
		float y() { return (cast(float)Ly / 255.0) * 2.0 - 0.5; }
		float x(float v) { Lx = cast(ubyte)(((v / 2.0) + 0.5) * 255.0); return v; }
		float y(float v) { Ly = cast(ubyte)(((v / 2.0) + 0.5) * 255.0); return v; }

		static assert(this.sizeof == 16);
	}
	alias CircularList!(Frame, false) Frames ;

	struct Latch {
		uint uiMake;
		uint uiBreak;
		uint uiPress;
		uint uiRelease;
	}
	
	int  sampCycle = 0;
	Mode sampMode = Mode.ANALOG;
	Frames frames;
	Frame currentFrame;

	Frame frameRead(int index = 0) {
		return frames.readFromTail(-(index + 1));
	}
	
	void frameWrite() {
		currentFrame.TimeStamp = clock(); // Should be ticks?/seconds?/frames?
		currentFrame.Rsrv[] = 0;
		frames.queue(currentFrame);
	}
	
	this() {
		frames = new Frames(128);
	}
}

alias Controller IController;