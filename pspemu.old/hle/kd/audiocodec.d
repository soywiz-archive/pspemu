module pspemu.hle.kd.audiocodec; // kd/audiocodec.prx (sceAudiocodec_Driver):

import pspemu.hle.Module;

debug = DEBUG_SYSCALL;

class sceAudiocodec : Module {
	void initNids() {
		mixin(registerd!(0x9D3F790C, sceAudiocodeCheckNeedMem));
		mixin(registerd!(0x5B37EB1D, sceAudiocodecInit));
		mixin(registerd!(0x70A703F8, sceAudiocodecDecode));
		mixin(registerd!(0x3A20A200, sceAudiocodecGetEDRAM));
		mixin(registerd!(0x29681260, sceAudiocodecReleaseEDRAM));
	}
	
	void sceAudiocodeCheckNeedMem() { unimplemented(); }
	void sceAudiocodecInit() { unimplemented(); }
	void sceAudiocodecDecode() { unimplemented(); }
	void sceAudiocodecGetEDRAM() { unimplemented(); }
	void sceAudiocodecReleaseEDRAM() { unimplemented(); }
}

static this() {
	mixin(Module.registerModule("sceAudiocodec"));
}
