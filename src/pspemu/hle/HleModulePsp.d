module pspemu.hle.HleModulePsp;

import std.conv;
import pspemu.hle.HleModule;

import pspemu.hle.kd.loadcore.Types;

class HleModulePsp : HleModule {
	void initNids() {
		
	}
	
	override public bool isNative() {
		return false;
	}
	
	string name() {
		return to!string(sceModule.modname.ptr);
	}
}