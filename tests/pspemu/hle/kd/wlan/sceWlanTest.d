module pspemu.hle.kd.wlan.sceWlanTest;

import tests.Test;

import pspemu.hle.kd.wlan.sceWlan;

class sceWlanTest : Test {
	mixin TRegisterTest;
	sceWlanDrv sceWlan;
	
	public void setUp() {
		sceWlan = new sceWlanDrv(); 
	}
	
	public void testGetEtherAddr() {
		//ubyte[6] addr;
		//sceWlan.sceWlanGetEtherAddr(addr.ptr);
		//writefln("%s", addr);
		
		foreach (func; sceWlan.hleFunctionsByNid) {
			writefln("%s", func);
		}
		
	}
}