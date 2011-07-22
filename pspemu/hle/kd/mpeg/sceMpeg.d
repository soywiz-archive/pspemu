module pspemu.hle.kd.mpeg.sceMpeg;

import pspemu.hle.kd.Types;

import pspemu.hle.ModuleNative;

class sceMpeg : ModuleNative {
	void initNids() {
		mixin(registerd!(0x682A619B, sceMpegInit));
		mixin(registerd!(0x874624D6, sceMpegFinish));
		mixin(registerd!(0xD7A29F46, sceMpegRingbufferQueryMemSize));
		mixin(registerd!(0x37295ED8, sceMpegRingbufferConstruct));
		mixin(registerd!(0xC132E22F, sceMpegQueryMemSize));
		mixin(registerd!(0xD8C5F121, sceMpegCreate));
		mixin(registerd!(0x0E3C2E9D, sceMpegAvcDecode));
		mixin(registerd!(0xA11C7026, sceMpegAvcDecodeMode));
	    mixin(registerd!(0x13407F13, sceMpegRingbufferDestruct));
	    mixin(registerd!(0x167AFD9E, sceMpegInitAu));
	    mixin(registerd!(0x21FF80E4, sceMpegQueryStreamOffset));
	    mixin(registerd!(0x42560F23, sceMpegRegistStream));
	    mixin(registerd!(0x591A4AA2, sceMpegUnRegistStream));
	    mixin(registerd!(0x606A4649, sceMpegDelete));
	    mixin(registerd!(0x611E9E11, sceMpegQueryStreamSize));
	    mixin(registerd!(0x707B7629, sceMpegFlushAllStream));
	    mixin(registerd!(0x740FCCD1, sceMpegAvcDecodeStop));
	    mixin(registerd!(0x800C44DF, sceMpegAtracDecode));
	    mixin(registerd!(0xA780CF7E, sceMpegMallocAvcEsBuf));
	    mixin(registerd!(0xB240A59E, sceMpegRingbufferPut));
	    mixin(registerd!(0xB5F6DC87, sceMpegRingbufferAvailableSize));
	    mixin(registerd!(0xCEB870B1, sceMpegFreeAvcEsBuf));
	    mixin(registerd!(0xE1CE83A7, sceMpegGetAtracAu));
	    mixin(registerd!(0xF8DCB679, sceMpegQueryAtracEsSize));
	    mixin(registerd!(0xFE246728, sceMpegGetAvcAu));
		mixin(registerd!(0x0F6C18D7, sceMpegAvcDecodeDetail));
		mixin(registerd!(0x4571CC64, sceMpegAvcDecodeFlush));
	}
	
	void sceMpegAvcDecodeDetail() {
		unimplemented();
	}
	
	void sceMpegAvcDecodeFlush() {
		unimplemented();
	}
	
	/**
	 * sceMpegGetAvcAu
	 *
	 * @param Mpeg    - SceMpeg handle
	 * @param pStream - associated stream
	 * @param pAu     - will contain pointer to Au
	 * @param iUnk    - unknown
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegGetAvcAu(SceMpeg* Mpeg, SceMpegStream* pStream, SceMpegAu* pAu, SceInt32* iUnk) {
		unimplemented_notice();
		return 0;
	}
	
	/**
	 * sceMpegQueryAtracEsSize
	 *
	 * @param Mpeg     - SceMpeg handle
	 * @param iEsSize  - will contain size of Es
	 * @param iOutSize - will contain size of decoded data
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegQueryAtracEsSize(SceMpeg* Mpeg, SceInt32* iEsSize, SceInt32* iOutSize) {
		unimplemented_notice();
		return 0;
	}
	
	/**
	 * sceMpegGetAtracAu
	 *
	 * @param Mpeg    - SceMpeg handle
	 * @param pStream - associated stream
	 * @param pAu     - will contain pointer to Au
	 * @param pUnk    - unknown
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegGetAtracAu(SceMpeg* Mpeg, SceMpegStream* pStream, SceMpegAu* pAu, ScePVoid pUnk) {
		unimplemented_notice();
		return 0;
	}
	
	/**
	 * sceMpegFreeAvcEsBuf
	 *
	 */
	void sceMpegFreeAvcEsBuf(SceMpeg* Mpeg, ScePVoid pBuf) {
		unimplemented_notice();
		return;
	}
	
	/**
	 * sceMpegQueryMemSize 
	 *
	 * @param Ringbuffer - pointer to a sceMpegRingbuffer struct
	 *
	 * @return < 0 if error else number of free packets in the ringbuffer.
	 */
	SceInt32 sceMpegRingbufferAvailableSize(SceMpegRingbuffer* Ringbuffer) {
		unimplemented_notice();
		//return -1;
		return 0;
	}
	
	/**
	 * sceMpegRingbufferPut
	 *
	 * @param Ringbuffer - pointer to a sceMpegRingbuffer struct
	 * @param iNumPackets - num packets to put into the ringbuffer
	 * @param iAvailable - free packets in the ringbuffer, should be sceMpegRingbufferAvailableSize()
	 *
	 * @return < 0 if error else number of packets.
	 */
	SceInt32 sceMpegRingbufferPut(SceMpegRingbuffer* Ringbuffer, SceInt32 iNumPackets, SceInt32 iAvailable) {
		unimplemented_notice();
		return 0;
	}
	
	/**
	 * sceMpegMallocAvcEsBuf
	 *
	 * @return 0 if error else pointer to buffer.
	 */
	ScePVoid sceMpegMallocAvcEsBuf(SceMpeg* Mpeg) {
		unimplemented_notice();
		return null;
	}
	
	/**
	 * sceMpegAtracDecode
	 *
	 * @param Mpeg    - SceMpeg handle
	 * @param pAu     - video Au
	 * @param pBuffer - buffer that will contain the decoded frame
	 * @param iInit   - set this to 1 on first call
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegAtracDecode(SceMpeg* Mpeg, SceMpegAu* pAu, ScePVoid pBuffer, SceInt32 iInit) {
		unimplemented_notice();
		return -1;
	}
	
	/**
	 * sceMpegAvcDecodeStop
	 *
	 * @param Mpeg        - SceMpeg handle
	 * @param iFrameWidth - output buffer width, set to 512 if writing to framebuffer
	 * @param pBuffer     - buffer that will contain the decoded frame
	 * @param iStatus     - frame number
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegAvcDecodeStop(SceMpeg* Mpeg, SceInt32 iFrameWidth, ScePVoid pBuffer, SceInt32* iStatus) {
		unimplemented_notice();
		return -1;
	}
	
	/**
	 * sceMpegFlushAllStreams
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegFlushAllStream(SceMpeg* Mpeg) {
		unimplemented_notice();
		return -1;
	}
	
	/**
	 * sceMpegQueryStreamSize
	 *
	 * @param pBuffer - pointer to file header
	 * @param iSize - will contain stream size in bytes
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegQueryStreamSize(ScePVoid pBuffer, SceInt32* iSize) {
		unimplemented_notice();
		
		*iSize = 0;
		
		return -1;
	}
	
	/**
	 * sceMpegDelete
	 *
	 * @param Mpeg - SceMpeg handle
	 */
	void sceMpegDelete(SceMpeg* Mpeg) {
		unimplemented_notice();
	}
	
	/**
	 * sceMpegUnRegistStream
	 *
	 * @param Mpeg - SceMpeg handle
	 * @param pStream - pointer to stream
	 */
	void sceMpegUnRegistStream(SceMpeg Mpeg, SceMpegStream* pStream) {
		unimplemented_notice();
	}
	
	/**
	 * sceMpegRegistStream
	 *
	 * @param Mpeg - SceMpeg handle
	 * @param iStreamID - stream id, 0 for video, 1 for audio
	 * @param iUnk - unknown, set to 0
	 *
	 * @return 0 if error.
	 */
	SceMpegStream* sceMpegRegistStream(SceMpeg* Mpeg, SceInt32 iStreamID, SceInt32 iUnk) {
		unimplemented_notice();
		return null;
	}
	
	/**
	 * sceMpegRingbufferDestruct
	 *
	 * @param Ringbuffer - pointer to a sceMpegRingbuffer struct
	 */
	void sceMpegRingbufferDestruct(SceMpegRingbuffer* Ringbuffer) {
		unimplemented_notice();
	}
	
	/**
	 * sceMpegInitAu
	 *
	 * @param Mpeg      - SceMpeg handle
	 * @param pEsBuffer - prevously allocated Es buffer
	 * @param pAu       - will contain pointer to Au
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegInitAu(SceMpeg* Mpeg, ScePVoid pEsBuffer, SceMpegAu* pAu) {
		unimplemented_notice();
		return -1;
	}

	/**
	 * sceMpegQueryStreamOffset
	 *
	 * @param Mpeg    - SceMpeg handle
	 * @param pBuffer - pointer to file header
	 * @param iOffset - will contain stream offset in bytes, usually 2048
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegQueryStreamOffset(SceMpeg* Mpeg, ScePVoid pBuffer, SceInt32* iOffset) {
		unimplemented_notice();
		*iOffset = 0;
		return 0;
	}
	
	/**
	 * sceMpegInit
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegInit() {
		unimplemented_notice();
		return 0;
	}
	
	/**
	 * sceMpegFinish
	 */
	void sceMpegFinish() {
		unimplemented_notice();
	}
	
	/**
	 * sceMpegRingbufferQueryMemSize
	 *
	 * @param iPackets - number of packets in the ringbuffer
	 *
	 * @return < 0 if error else ringbuffer data size.
	 */
	SceInt32 sceMpegRingbufferQueryMemSize(SceInt32 iPackets) {
		unimplemented_notice();
		return 0;
	}

	/**
	 * sceMpegRingbufferConstruct
	 *
	 * @param Ringbuffer - pointer to a sceMpegRingbuffer struct
	 * @param iPackets   - number of packets in the ringbuffer
	 * @param pData      - pointer to allocated memory
	 * @param iSize      - size of allocated memory, shoud be sceMpegRingbufferQueryMemSize(iPackets)
	 * @param Callback   - ringbuffer callback
	 * @param pCBparam   - param passed to callback
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegRingbufferConstruct(SceMpegRingbuffer* Ringbuffer, SceInt32 iPackets, ScePVoid pData, SceInt32 iSize, sceMpegRingbufferCB Callback, ScePVoid pCBparam) {
		unimplemented_notice();
		return 0;
	}

	/**
	 * sceMpegQueryMemSize
	 *
	 * @param iUnk - Unknown, set to 0
	 *
	 * @return < 0 if error else decoder data size.
	 */
	SceInt32 sceMpegQueryMemSize(int iUnk) {
		return 0;
	}
	
	/**
	 * sceMpegCreate
	 *
	 * @param Mpeg        - will be filled
	 * @param pData       - pointer to allocated memory of size = sceMpegQueryMemSize()
	 * @param iSize       - size of data, should be = sceMpegQueryMemSize()
	 * @param Ringbuffer  - a ringbuffer
	 * @param iFrameWidth - display buffer width, set to 512 if writing to framebuffer
	 * @param iUnk1       - unknown, set to 0
	 * @param iUnk2       - unknown, set to 0
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegCreate(SceMpeg* Mpeg, ScePVoid pData, SceInt32 iSize, SceMpegRingbuffer* Ringbuffer, SceInt32 iFrameWidth, SceInt32 iUnk1, SceInt32 iUnk2) {
		unimplemented_notice();
		Ringbuffer.iPackets = 0;
		return -1;
	}

	/**
	 * sceMpegAvcDecodeMode
	 *
	 * @param Mpeg  - SceMpeg handle
	 * @param pMode - pointer to SceMpegAvcMode struct defining the decode mode (pixelformat)
	 * @return 0 if success.
	 */
	SceInt32 sceMpegAvcDecodeMode(SceMpeg* Mpeg, SceMpegAvcMode* pMode) {
		unimplemented_notice();
		return -1;
	}
	
	/**
	 * sceMpegAvcDecode
	 *
	 * @param Mpeg        - SceMpeg handle
	 * @param pAu         - video Au
	 * @param iFrameWidth - output buffer width, set to 512 if writing to framebuffer
	 * @param pBuffer     - buffer that will contain the decoded frame
	 * @param iInit       - will be set to 0 on first call, then 1
	 *
	 * @return 0 if success.
	 */
	SceInt32 sceMpegAvcDecode(SceMpeg* Mpeg, SceMpegAu* pAu, SceInt32 iFrameWidth, ScePVoid pBuffer, SceInt32* iInit) {
		unimplemented_notice();
		return 0;
	}
}

alias void SceMpegStream;
alias void* ScePVoid;
alias ScePVoid SceMpeg;
alias SceInt32 function(ScePVoid pData, SceInt32 iNumPackets, ScePVoid pParam) sceMpegRingbufferCB;

struct SceMpegAu
{
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

struct SceMpegRingbuffer {
    /** packets */
	SceInt32			iPackets;

    /** unknown */
	SceUInt32			iUnk0;
    /** unknown */
	SceUInt32			iUnk1;
    /** unknown */
	SceUInt32			iUnk2;
    /** unknown */
	SceUInt32			iUnk3;

    /** pointer to data */
	ScePVoid			pData;

    /** ringbuffer callback */
	sceMpegRingbufferCB	Callback;
    /** callback param */
	ScePVoid			pCBparam;

    /** unknown */
	SceUInt32			iUnk4;
    /** unknown */
	SceUInt32			iUnk5;
    /** mpeg id */
	SceMpeg				pSceMpeg;

}

struct SceMpegAvcMode
{
	/** unknown, set to -1 */
	SceInt32			iUnk0;
	/** Decode pixelformat */
	SceInt32			iPixelFormat;

} 

static this() {
	mixin(ModuleNative.registerModule("sceMpeg"));
}
