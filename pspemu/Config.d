module pspemu.Config;

import std.stdio;

class Config {
	public bool audioEnabled = true;
	public bool frameLimiting = true;
}

__gshared Config _GlobalConfig;

Config GlobalConfig() {
	if (_GlobalConfig is null) {
		_GlobalConfig = new Config;
		writefln("*********Config");
	}
	return _GlobalConfig;
}
