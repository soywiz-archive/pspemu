module pspemu.hle.kd.avcodec.sceAudiocodec;

import pspemu.hle.ModuleNative;

enum PspAudioCodec {
	PSP_CODEC_AT3PLUS	= (0x00001000),
	PSP_CODEC_AT3		= (0x00001001),
	PSP_CODEC_MP3		= (0x00001002),
	PSP_CODEC_AAC		= (0x00001003),
}

class sceAudiocodec : HleModuleHost {
	mixin TRegisterModule;

	void initNids() {
		mixin(registerFunction!(0x9D3F790C, sceAudiocodecCheckNeedMem));
		mixin(registerFunction!(0x5B37EB1D, sceAudiocodecInit));
		mixin(registerFunction!(0x70A703F8, sceAudiocodecDecode));
		mixin(registerFunction!(0x3A20A200, sceAudiocodecGetEDRAM));
		mixin(registerFunction!(0x29681260, sceAudiocodecReleaseEDRAM));
	}
	
	int sceAudiocodecCheckNeedMem(uint *Buffer, PspAudioCodec Type) {
		//logInfo("sceAudiocodecCheckNeedMem(%08X, %s)", cast(uint)Buffer, to!string(Type));
		//unimplemented_notice();
		//return 0;
		return 4096;
	}

	int sceAudiocodecInit(uint *Buffer, PspAudioCodec Type) {
		//logInfo("sceAudiocodecInit(%08X, %s)", cast(uint)Buffer, to!string(Type));
		//unimplemented_notice();
		return 0;
	}

	int sceAudiocodecDecode(uint *Buffer, PspAudioCodec Type) {
		//logInfo("sceAudiocodecDecode(%08X, %s)", cast(uint)Buffer, to!string(Type));
		//unimplemented_notice();
		return 0;
	}

	int sceAudiocodecGetEDRAM(uint *Buffer, PspAudioCodec Type) {
		//logInfo("sceAudiocodecGetEDRAM(%08X, %s)", cast(uint)Buffer, to!string(Type));
		//unimplemented_notice();
		return 0x_08_00_00_00;
	}

	int sceAudiocodecReleaseEDRAM(uint *Buffer) {
		//logInfo("sceAudiocodecReleaseEDRAM(%08X)", cast(uint)Buffer);
		//unimplemented_notice();
		return 0;
	}
}
