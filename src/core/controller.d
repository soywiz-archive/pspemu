module psp.controller;

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
		DIGITAL = 0, /* Digitial. */	
		ANALOG /* Analog. */
	}

	struct Data {		
		uint  TimeStamp; // The current read frame.
		uint  Buttons;   // Bit mask containing zero or more of ::PspCtrlButtons.
		ubyte Lx;        // Analogue stick, X axis.
		ubyte Ly;        // Analogue stick, Y axis.
		ubyte Rsrv[6];   // Reserved.
	}

	struct Latch {
		uint uiMake;
		uint uiBreak;
		uint uiPress;
		uint uiRelease;
	}
	
	int sampCycle = 0;
	Mode sampMode = Mode.ANALOG;
	Data data;
	
	this() {
		data.Ly = data.Lx = 0x7F;
	}
}