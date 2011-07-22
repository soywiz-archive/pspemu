module pspemu.hle.ModulePsp;

import std.conv;
import pspemu.hle.Module;

import pspemu.hle.kd.loadcore.Types;

class ModulePsp : Module {
	void initNids() {
		
	}
	
	override public bool isNative() {
		return false;
	}
	
	string name() {
		return to!string(sceModule.modname.ptr);
	}
}