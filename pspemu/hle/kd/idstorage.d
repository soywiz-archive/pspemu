module pspemu.hle.kd.idstorage; // idstorage.prx (sceIdStorage_Service):

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

import std.c.windows.windows;

class sceIdStorage_driver : Module {
	void initNids() {
		mixin(registerd!(0x6FE062D1, sceIdStorageLookup));
	}

	/**
	 * Retrieves the value associated with a key
	 * @param key    - idstorage key
	 * @param offset - offset within the 512 byte leaf
	 * @param buf    - buffer with enough storage
	 * @param len    - amount of data to retrieve (offset + len must be <= 512 bytes)
	 **/
	int sceIdStorageLookup(u16 key, u32 offset, void* buf, u32 len) {
		unimplemented();
		return -1;
	}
}

static this() {
	mixin(Module.registerModule("sceIdStorage_driver"));
}
