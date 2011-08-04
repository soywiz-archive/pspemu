module pspemu.hle.kd.videocodec.sceVideocodec;

import pspemu.hle.ModuleNative;


class sceVideocodec : ModuleNative {
	void initNids() {
		mixin(registerd!(0x2D31F5B1, sceVideocodecGetEDRAM));
		mixin(registerd!(0x4F160BF4, sceVideocodecReleaseEDRAM));
		mixin(registerd!(0xC01EC829, sceVideocodecOpen));
		mixin(registerd!(0x17099F0A, sceVideocodecInit));
		mixin(registerd!(0xDBA273FA, sceVideocodecDecode));
		mixin(registerd!(0xA2F0564E, sceVideocodecStop));
		mixin(registerd!(0x307E6E1C, sceVideocodecDelete));
		mixin(registerd!(0x745A7B7A, sceVideocodecSetMemory));
	}

	int sceVideocodecOpen(uint *Buffer, int Type) {
		unimplemented_notice();
		return 0;
	}
	int sceVideocodecGetEDRAM(uint *Buffer, int Type) {
		unimplemented_notice();
		return 0;
	}
	int sceVideocodecInit(uint *Buffer, int Type) {
		unimplemented_notice();
		return 0;
	}
	int sceVideocodecDecode(uint *Buffer, int Type) {
		unimplemented_notice();
		return 0;
	}
	int sceVideocodecReleaseEDRAM(uint *Buffer) {
		unimplemented_notice();
		return 0;
	}
	
	void sceVideocodecGetVersion() { unimplemented(); }
	void sceVideocodecScanHeader() { unimplemented(); }
	void sceVideocodecDelete() { unimplemented(); }
	void sceVideocodecSetMemory() { unimplemented(); }
	void sceVideocodecStop() { unimplemented(); }

}

static this() {
	mixin(ModuleNative.registerModule("sceVideocodec"));
}
