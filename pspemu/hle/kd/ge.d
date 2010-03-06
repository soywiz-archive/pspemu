module pspemu.hle.kd.ge; // kd/ge.prx (sceGE_Manager)

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class sceGe_driver : Module {
	this() {
		mixin(register(0xE47E40E4, "sceGeEdramGetAddr"));
		mixin(register(0xAB49E76A, "sceGeListEnQueue"));
		mixin(register(0xE0D68148, "sceGeListUpdateStallAddr"));
		mixin(register(0x03444EB4, "sceGeListSync"));
		mixin(register(0xB287BD61, "sceGeDrawSync"));
		mixin(register(0xA4FC06A4, "sceGeSetCallback"));
	}

	void sceGeListSync() {
		// int sceGeListSync (int qid, int syncType)
		cpu.registers.V0 = 0;
		debug (DEBUG_SYSCALL) .writefln("sceGeListSync(%d, %d)", param(0), param(1));
	}

	void sceGeEdramGetAddr() {
		// void* sceGeEdramGetAddr ( void )
		cpu.registers.V0 = cpu.memory.frameBufferAddress;
		debug (DEBUG_SYSCALL) .writefln("sceGeEdramGetAddr()");
	}

	void sceGeSetCallback() {
		// int sceGeSetCallback ( PspGeCallbackData *cb )
		cpu.registers.V0 = 0;
		debug (DEBUG_SYSCALL) .writefln("sceGeSetCallback(0x%08X)", param(0));
	}

	void sceGeListEnQueue() {
		// int sceGeListEnQueue ( const void *list, void *stall, int cbid, PspGeListArgs *arg )
		cpu.registers.V0 = 0;
		debug (DEBUG_SYSCALL) .writefln("sceGeListEnQueue(0x%08X, 0x%08X, %d, 0x%08X)", param(0), param(1), param(2), param(3));
	}
}

class sceGe_user : sceGe_driver {
}

static this() {
	mixin(Module.registerModule("sceGe_driver"));
	mixin(Module.registerModule("sceGe_user"));
}