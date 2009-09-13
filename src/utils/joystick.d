module utils.joystick;

import std.string;
import std.stdio;

pragma(lib, "winmm.lib");

extern (System) {
	uint joyGetNumDevs();
	uint joyGetPosEx(uint uJoyID, JOYINFOEX*);

	struct JOYINFOEX {
		uint dwSize; 
		uint dwFlags; 
		uint dwXpos; 
		uint dwYpos; 
		uint dwZpos; 
		uint dwRpos; 
		uint dwUpos; 
		uint dwVpos; 
		uint dwButtons; 
		uint dwButtonNumber; 
		uint dwPOV; 
		uint dwReserved1; 
		uint dwReserved2; 
	}

	const uint JOY_RETURNX        = (1 <<  0);
	const uint JOY_RETURNY        = (1 <<  1);
	const uint JOY_RETURNZ        = (1 <<  2);
	const uint JOY_RETURNR        = (1 <<  3);
	const uint JOY_RETURNU        = (1 <<  4);
	const uint JOY_RETURNV        = (1 <<  5);
	const uint JOY_RETURNPOV      = (1 <<  6);
	const uint JOY_RETURNBUTTONS  = (1 <<  7);
	const uint JOY_RETURNRAWDATA  = (1 <<  8);
	const uint JOY_RETURNPOVCTS   = (1 <<  9);
	const uint JOY_RETURNCENTERED = (1 << 10);
	const uint JOY_USEDEADZONE    = (1 << 11);
	const uint JOY_RETURNALL      = (JOY_RETURNX | JOY_RETURNY | JOY_RETURNZ | JOY_RETURNR | JOY_RETURNU | JOY_RETURNV | JOY_RETURNPOV | JOY_RETURNBUTTONS);
}

class Joystick {
	static Joystick[] joys;
	
	static uint count() { return joyGetNumDevs(); }
	
	static Joystick opIndex(int idx) { return joys[idx]; }
	
	static Joystick open(uint id) {
		if (id < 0 || id >= count) throw(new Exception("Invalid joystick id"));
		return new Joystick(id);
	}

	static void openAll() {
		joys.length = count;
		for (int n = 0; n < joys.length; n++) joys[n] = open(n);
	}
	
	static void updateAll() {
		for (int n = 0; n < joys.length; n++) joys[n].update();
	}

	uint id;
	char[] name() {
		return std.string.format("Unknown_%d", id);
	}


	int  x, y, z;
	int  r, u, v;
	uint buttons;
	uint buttonsCount;
	int  povX, povY;
	
	private this(uint id) { this.id = id; }
	
	void update() {
		JOYINFOEX ji;
		ji.dwSize = JOYINFOEX.sizeof;
		ji.dwFlags = JOY_RETURNALL;
		int result = joyGetPosEx(id, &ji);

		x = (cast(int)ji.dwXpos);
		y = (cast(int)ji.dwYpos);
		z = (cast(int)ji.dwZpos);
		r = (cast(int)ji.dwRpos);
		u = (cast(int)ji.dwUpos);
		v = (cast(int)ji.dwVpos);
		buttons = ji.dwButtons;
		buttonsCount = ji.dwButtonNumber;
		
		if (ji.dwPOV == 0xFFFF) {
			povY = povX = 0;
		} else {
			if (ji.dwPOV == 9000 || ji.dwPOV == 27000) povY = 0;
			else if (ji.dwPOV > 9000 && ji.dwPOV < 27000) povY = -1;
			else povY = 1;

			if (ji.dwPOV == 0 || ji.dwPOV == 18000) povX = 0;
			else if (ji.dwPOV > 18000) povX = -1;
			else povX = 1;
		}
	}
}
