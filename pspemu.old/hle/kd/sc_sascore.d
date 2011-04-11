module pspemu.hle.kd.sc_sascore; // kd/sc_sascore.prx ()

import pspemu.hle.Module;

class sceSasCore : Module {
	void initNids() {
		mixin(registerd!(0x019B25EB, __sceSasSetADSRFunction));
		mixin(registerd!(0x267A6DD2, __sceSasRevParamFunction));
		mixin(registerd!(0x2C8E6AB3, __sceSasGetPauseFlagFunction));
		mixin(registerd!(0x33D4AB37, __sceSasRevTypeFunction));
		mixin(registerd!(0x42778A9F, __sceSasInitFunction));
		mixin(registerd!(0x440CA7D8, __sceSasSetVolumeFunction));
		mixin(registerd!(0x50A14DFC, __sceSasCoreWithMixFunction));
		mixin(registerd!(0x5F9529F6, __sceSasSetSLFunction));
		mixin(registerd!(0x68A46B95, __sceSasGetEndFlagFunction));
		mixin(registerd!(0x74AE582A, __sceSasGetEnvelopeHeightFunction));
		mixin(registerd!(0x76F01ACA, __sceSasSetKeyOnFunction));
		mixin(registerd!(0x787D04D5, __sceSasSetPauseFunction));
		mixin(registerd!(0x99944089, __sceSasSetVoiceFunction));
		mixin(registerd!(0x9EC3676A, __sceSasSetADSRmodeFunction));
		mixin(registerd!(0xA0CF2FA4, __sceSasSetKeyOffFunction));
		mixin(registerd!(0xA232CBE6, __sceSasSetTrianglarWaveFunction));
		mixin(registerd!(0xA3589D81, __sceSasCoreFunction));
		mixin(registerd!(0xAD84D37F, __sceSasSetPitchFunction));
		mixin(registerd!(0xB7660A23, __sceSasSetNoiseFunction));
		mixin(registerd!(0xBD11B7C2, __sceSasGetGrainFunction));
		mixin(registerd!(0xCBCD4F79, __sceSasSetSimpleADSRFunction));
		mixin(registerd!(0xD1E0A01E, __sceSasSetGrainFunction));
		mixin(registerd!(0xD5A229C9, __sceSasRevEVOLFunction));
		mixin(registerd!(0xD5EBBBCD, __sceSasSetSteepWaveFunction));
		mixin(registerd!(0xE175EF66, __sceSasGetOutputmodeFunction));
		mixin(registerd!(0xE855BF76, __sceSasSetOutputmodeFunction));
		mixin(registerd!(0xF983B186, __sceSasRevVONFunction));
	}

	// @TODO: Unknown.
	void __sceSasSetADSRFunction() { unimplemented(); }
	void __sceSasRevParamFunction() { unimplemented(); }
	void __sceSasGetPauseFlagFunction() { unimplemented(); }
	void __sceSasRevTypeFunction() { unimplemented(); }
	void __sceSasInitFunction() { unimplemented(); }
	void __sceSasSetVolumeFunction() { unimplemented(); }
	void __sceSasCoreWithMixFunction() { unimplemented(); }
	void __sceSasSetSLFunction() { unimplemented(); }
	void __sceSasGetEndFlagFunction() { unimplemented(); }
	void __sceSasGetEnvelopeHeightFunction() { unimplemented(); }
	void __sceSasSetKeyOnFunction() { unimplemented(); }
	void __sceSasSetPauseFunction() { unimplemented(); }
	void __sceSasSetVoiceFunction() { unimplemented(); }
	void __sceSasSetADSRmodeFunction() { unimplemented(); }
	void __sceSasSetKeyOffFunction() { unimplemented(); }
	void __sceSasSetTrianglarWaveFunction() { unimplemented(); }
	void __sceSasCoreFunction() { unimplemented(); }
	void __sceSasSetPitchFunction() { unimplemented(); }
	void __sceSasSetNoiseFunction() { unimplemented(); }
	void __sceSasGetGrainFunction() { unimplemented(); }
	void __sceSasSetSimpleADSRFunction() { unimplemented(); }
	void __sceSasSetGrainFunction() { unimplemented(); }
	void __sceSasRevEVOLFunction() { unimplemented(); }
	void __sceSasSetSteepWaveFunction() { unimplemented(); }
	void __sceSasGetOutputmodeFunction() { unimplemented(); }
	void __sceSasSetOutputmodeFunction() { unimplemented(); }
	void __sceSasRevVONFunction() { unimplemented(); }
}

static this() {
	mixin(Module.registerModule("sceSasCore"));
}
