module pspemu.hle.kd.mpeg_vsh; // kd/mpeg_vsh.prx (sceMpeg_library)

import pspemu.hle.Module;

debug = DEBUG_SYSCALL;

alias void* ScePVoid;
alias ScePVoid SceMpeg;
struct SceMpegAu {
    /** presentation timestamp MSB */
	SceUInt32			iPtsMSB;
    /** presentation timestamp LSB */
	SceUInt32			iPts;
    /** decode timestamp MSB */
	SceUInt32			iDtsMSB;
    /** decode timestamp LSB */
	SceUInt32			iDts;
    /** Es buffer handle */
	SceUInt32			iEsBuffer;
    /** Au size */
	SceUInt32			iAuSize;
}

class sceMpeg : Module {
	void initNids() {
		mixin(registerd!(0x0E3C2E9D, sceMpegAvcDecode));
		mixin(registerd!(0x0F6C18D7, sceMpegAvcDecodeDetail));
		mixin(registerd!(0x13407F13, sceMpegRingbufferDestruct));
		mixin(registerd!(0x167AFD9E, sceMpegInitAu));
		mixin(registerd!(0x21FF80E4, sceMpegQueryStreamOffset));
		mixin(registerd!(0x37295ED8, sceMpegRingbufferConstruct));
		mixin(registerd!(0x42560F23, sceMpegRegistStream));
		mixin(registerd!(0x4571CC64, sceMpegAvcDecodeFlushFunction));
		mixin(registerd!(0x591A4AA2, sceMpegUnRegistStream));
		mixin(registerd!(0x606A4649, sceMpegDelete));
		mixin(registerd!(0x611E9E11, sceMpegQueryStreamSize));
		mixin(registerd!(0x682A619B, sceMpegInit));
		mixin(registerd!(0x707B7629, sceMpegFlushAllStream));
		mixin(registerd!(0x740FCCD1, sceMpegAvcDecodeStop));
		mixin(registerd!(0x800C44DF, sceMpegAtracDecode));
		mixin(registerd!(0x874624D6, sceMpegFinish));
		mixin(registerd!(0xA780CF7E, sceMpegMallocAvcEsBuf));
		mixin(registerd!(0xB240A59E, sceMpegRingbufferPut));
		mixin(registerd!(0xB5F6DC87, sceMpegRingbufferAvailableSize));
		mixin(registerd!(0xC132E22F, sceMpegQueryMemSize));
		mixin(registerd!(0xCEB870B1, sceMpegFreeAvcEsBuf));
		mixin(registerd!(0xD7A29F46, sceMpegRingbufferQueryMemSize));
		mixin(registerd!(0xD8C5F121, sceMpegCreate));
		mixin(registerd!(0xE1CE83A7, sceMpegGetAtracAu));
		mixin(registerd!(0xF8DCB679, sceMpegQueryAtracEsSize));
		mixin(registerd!(0xFE246728, sceMpegGetAvcAu));
		mixin(registerd!(0xA11C7026, sceMpegAvcDecodeMode));
	}

	/**
	 * sceMpegAvcDecode
	 *
	 * @param Mpeg - SceMpeg handle
	 * @param pAu - video Au
	 * @param iFrameWidth - output buffer width, set to 512 if writing to framebuffer
	 * @param pBuffer - buffer that will contain the decoded frame
	 * @param iInit - will be set to 0 on first call, then 1
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegAvcDecode(SceMpeg* Mpeg, SceMpegAu* pAu, SceInt32 iFrameWidth, ScePVoid pBuffer, SceInt32* iInit) {
		unimplemented();
		return -1;
	}

	// @TODO: Unknown.
	void sceMpegAvcDecodeDetail() { unimplemented(); }
	void sceMpegRingbufferDestruct() { unimplemented(); }
	void sceMpegInitAu() { unimplemented(); }
	void sceMpegQueryStreamOffset() { unimplemented(); }
	void sceMpegRingbufferConstruct() { unimplemented(); }
	void sceMpegRegistStream() { unimplemented(); }
	void sceMpegAvcDecodeFlushFunction() { unimplemented(); }
	void sceMpegUnRegistStream() { unimplemented(); }
	void sceMpegDelete() { unimplemented(); }
	void sceMpegQueryStreamSize() { unimplemented(); }
	void sceMpegInit() { unimplemented(); }
	void sceMpegFlushAllStream() { unimplemented(); }
	void sceMpegAvcDecodeStop() { unimplemented(); }
	void sceMpegAtracDecode() { unimplemented(); }
	void sceMpegFinish() { unimplemented(); }
	void sceMpegMallocAvcEsBuf() { unimplemented(); }
	void sceMpegRingbufferPut() { unimplemented(); }
	void sceMpegRingbufferAvailableSize() { unimplemented(); }
	void sceMpegQueryMemSize() { unimplemented(); }
	void sceMpegFreeAvcEsBuf() { unimplemented(); }
	void sceMpegRingbufferQueryMemSize() { unimplemented(); }
	void sceMpegCreate() { unimplemented(); }
	void sceMpegGetAtracAu() { unimplemented(); }
	void sceMpegQueryAtracEsSize() { unimplemented(); }
	void sceMpegGetAvcAu() { unimplemented(); }
	void sceMpegAvcDecodeMode() { unimplemented(); }
}

static this() {
	mixin(Module.registerModule("sceMpeg"));
}
