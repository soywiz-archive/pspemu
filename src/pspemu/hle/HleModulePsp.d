module pspemu.hle.HleModulePsp;

import std.conv;
import pspemu.hle.Module;

import pspemu.hle.kd.loadcore.Types;

class HleModulePsp : Module {
	void initNids() {
		
	}
	
	override public bool isNative() {
		return false;
	}
	
	string name() {
		return to!string(sceModule.modname.ptr);
	}
}