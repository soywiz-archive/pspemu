module pspemu.models.IController;

import std.stdio;
import std.c.time;

import pspemu.utils.Utils;

static struct SceCtrlData {		
	uint  TimeStamp; // The current read frame.
	uint  Buttons;   // Bit mask containing zero or more of ::PspCtrlButtons.
	ubyte Lx = 0x7F; // Analogue stick, X axis.
	ubyte Ly = 0x7F; // Analogue stick, Y axis.
	ubyte Rsrv[6];   // Reserved.

	// D additions.
	double x() { return ((cast(double)Lx / 255.0) - 0.5) * 2.0; }
	double y() { return ((cast(double)Ly / 255.0) - 0.5) * 2.0; }
	double x(double v) { Lx = cast(ubyte)(((v / 2.0) + 0.5) * 255.0); return v; }
	double y(double v) { Ly = cast(ubyte)(((v / 2.0) + 0.5) * 255.0); return v; }

	string toString() {
		return std.string.format("Controller.SceCtrlData(TimeStamp=0x%08X, Buttons=0b%026b, Lx=%.2f, Ly=%.2f)", TimeStamp, Buttons, x, y);
	}

	static assert(this.sizeof == 16);
}

class Controller { // SceCtrl
	enum Buttons {	
		SELECT     = 0x0000001 , // Select button.
		START      = 0x0000008 , // Start button.
		UP         = 0x0000010 , // Up D-Pad button.
		RIGHT      = 0x0000020 , // Right D-Pad button.
		DOWN       = 0x0000040 , // Down D-Pad button.
		LEFT       = 0x0000080 , // Left D-Pad button.
		LTRIGGER   = 0x0000100 , // Left trigger.
		RTRIGGER   = 0x0000200 , // Right trigger.
		TRIANGLE   = 0x0001000 , // Triangle button.
		CIRCLE     = 0x0002000 , // Circle button.
		CROSS      = 0x0004000 , // Cross button.
		SQUARE     = 0x0008000 , // Square button.
		HOME       = 0x0010000 , // Home button.
		HOLD       = 0x0020000 , // Hold button.
		NOTE       = 0x0800000 , // Music Note button.
		SCREEN     = 0x0400000 , // Screen button.
		VOLUP      = 0x0100000 , // Volume up button.
		VOLDOWN    = 0x0200000 , // Volume down button.
		WLAN_UP    = 0x0040000 , // Wlan switch up.
		REMOTE     = 0x0080000 , // Remote hold position.
		DISC       = 0x1000000, // Disc present.
		MS         = 0x2000000, // Memory stick present.
	}
	
	enum Mode {	
		DIGITAL = 0, // Digitial.
		ANALOG  = 1, // Analog.
	}

	alias SceCtrlData Frame;
	alias CircularList!(Frame, false) Frames;

	struct Latch {
		uint uiMake;
		uint uiBreak;
		uint uiPress;
		uint uiRelease;
	}
	
	int    samplingCycle = 0;
	Mode   samplingMode  = Mode.ANALOG;

	Frames frames;
	Frame  currentFrame;

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