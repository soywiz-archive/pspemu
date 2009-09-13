module psp.bios_graphics;

import std.stdio;
import std.string;
import std.random;
import std.c.time;
import std.file;
import std.cstream, std.stream;
import std.utf;
import psp.controller;

import dfl.all, dfl.internal.winapi;
import std.c.windows.windows;

import psp.memory;
import psp.disassembler.cpu;
import psp.gpu;
import psp.cpu;
import psp.bios;
import glcontrol;

class Module_sceDisplay : Module {
	static this() { BIOS_HLE.addModule("sceDisplay", Module_sceDisplay.classinfo); }

	this() {
		list[0x0E20F177] = &sceDisplaySetMode;
		list[0x289D82FE] = &sceDisplaySetFrameBuf;
		list[0x984C27E7] = &sceDisplayWaitVblankStart;
		list[0x46F186C3] = &sceDisplayWaitVblankStartCB;
	}	
	
	void sceDisplaySetMode() {
		writefln("SetMode (%d,%d,%d)", a(0), a(1), a(2));
	}
	
	void sceDisplaySetFrameBuf() {
		debug (bios_debug) writefln("sceDisplaySetFrameBuf (0x%08X, 0x%08X, 0x%08X, 0x%08X)", a(0), a(1), a(2), a(3));
		
		cpu.gpu.displayBuffer.ptr = a(0);
		cpu.gpu.displayBuffer.width = a(1);
		cpu.gpu.displayBuffer.format = a(2);
	}
	
	void sceDisplayWaitVblankStart() {
		debug (bios_debug) writefln("sceDisplayWaitVblankStart");
		bios.waitVBlank = true;
		while (!bios.vblank && !cpu.interrupt) {
			//printf(".");
			usleep(1000);
		}
		bios.waitVBlank = false;
		bios.vblank = false;
	}
	
	void sceDisplayWaitVblankStartCB() {
		debug (bios_debug) writefln("sceDisplayWaitVblankStartCB");
		sceDisplayWaitVblankStart();
	}
}

class Module_sceGe_user : Module {
	static this() { BIOS_HLE.addModule("sceGe_user", Module_sceGe_user.classinfo); }

	this() {
		list[0xE47E40E4] = &sceGeEdramGetAddr;
		list[0xA4FC06A4] = &sceGeSetCallback;
		list[0xAB49E76A] = &sceGeListEnQueue;
		list[0xE0D68148] = &sceGeListUpdateStallAddr;
		list[0x03444EB4] = &sceGeListSync;
		list[0xB287BD61] = &sceGeDrawSync;
		list[0x05DB22CE] = &sceGeUnsetCallback;
	}
	
	enum PspGeSyncType {
		PSP_GE_LIST_DONE = 0,
		PSP_GE_LIST_QUEUED,
		PSP_GE_LIST_DRAWING_DONE,
		PSP_GE_LIST_STALL_REACHED,
		PSP_GE_LIST_CANCEL_DONE
	} 
	
	void sceGeEdramGetAddr() {
		debug (bios_debug) writefln("sceGeEdramGetAddr()");
		retval = 0x04000000;
	}
	
	void sceGeListEnQueue() {
		debug (bios_debug) writefln("sceGeListEnQueue(0x%08X, 0x%08X, 0x%08X, 0x%08X)", a(0), a(1), a(2), a(3));
		retval = cpu.gpu.enqueue(GPU.DisplayList(a(0), a(1), a(2), a(3)));
	}
	
	void sceGeListUpdateStallAddr() {
		debug (bios_debug) writefln("sceGeListUpdateStallAddr(0x%08X, 0x%08X)", a(0), a(1));
		cpu.gpu.displaylists[a(0)].StallAddress = a(1);
		retval = 0;		
	}
	
	void sceGeListSync() {
		debug (bios_debug) writefln("sceGeListSync(0x%08X, 0x%08X)", a(0), a(1));
		retval = 0;
	}
	
	void sceGeDrawSync() {
		debug (bios_debug) writefln("sceGeDrawSync(0x%08X)", a(0));
		retval = cpu.gpu.draw(a(0));
	}
	
	void sceGeSetCallback() {
		debug (bios_debug) writefln("sceGeSetCallback(0x%08X)", a(0));
		retval = cpu.gpu.setCallback();
	}	
	
	void sceGeUnsetCallback() {
		debug (bios_debug) writefln("sceGeUnsetCallback()");
		retval = cpu.gpu.unsetCallback();
	}
}
