module pspemu.hle.KPrint;

import std.stdio;
import std.string;

import pspemu.utils.Logger;

class HleKPrint {
	string outputBuffer = "";
	
	bool outputKprint = false;
	
	void Kprint(string outstr) {
		outputBuffer ~= outstr;
		if (outputKprint) {
			stdout.writef("%s", outstr);
			stdout.flush();			
		} else {
			Logger.log(Logger.Level.INFO, "KDebugForKernel", "KPrintf: %s", outstr);
		}
		//stdout.writef("%s", outstr);
		//stdout.flush();
		//unimplemented();
	}
	
	void Kprintf(T...)(T args) {
		Kprint(std.string.format(args));
	}
}