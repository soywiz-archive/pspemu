module pspemu.hle.kd.mpegbase.sceMpegbase;

import pspemu.hle.kd.Types;
import pspemu.hle.ModuleNative;

// __attribute__((aligned(64))) SceMpegLLI;
struct SceMpegLLI
{
	ScePVoid pSrc;
	ScePVoid pDst;
	ScePVoid Next;
	SceInt32 iSize;
}

// __attribute__((aligned(64))) SceMpegYCrCbBuffer;
struct SceMpegYCrCbBuffer
{
	SceInt32	iFrameBufferHeight16;
	SceInt32	iFrameBufferWidth16;
	SceInt32	iUnknown;			// Set to 0
	SceInt32	iUnknown2;			// Set to 1
	ScePVoid	pYBuffer;			// pointer to YBuffer (in VME EDRAM?)
	ScePVoid	pYBuffer2;			// pointer to YBuffer + framebufferwidth*(frameheight/32)
	ScePVoid	pCrBuffer;			// pointer to CrBuffer (in VME EDRAM?)
	ScePVoid	pCbBuffer;			// pointer to CbBuffer (in VME EDRAM?)
	ScePVoid	pCrBuffer2;			// pointer to CrBuffer + (framebufferwidth/2)*(frameheight/64)
	ScePVoid	pCbBuffer2;			// pointer to CbBuffer + (framebufferwidth/2)*(frameheight/64)
	SceInt32	iFrameHeight;
	SceInt32	iFrameWidth;
	SceInt32	iFrameBufferWidth;
	SceInt32	iUnknown3[11];
}

class sceMpegbase : ModuleNative {
	void initNids() {
		mixin(registerd!(0xBEA18F91, sceMpegbase_BEA18F91));
		mixin(registerd!(0x492B5E4B, sceMpegBaseCscInit));
		mixin(registerd!(0x0530BE4E, sceMpegbase_0530BE4E));
		mixin(registerd!(0x91929A21, sceMpegBaseCscAvc));
		mixin(registerd!(0x304882E1, sceMpegBaseCscAvcRange));
		mixin(registerd!(0x7AC0321A, sceMpegBaseYCrCbCopy));
	}
	
	SceInt32 sceMpegBaseYCrCbCopyVme(void* YUVBuffer, SceInt32 *Buffer, SceInt32 Type) { unimplemented(); return 0; }
	SceInt32 sceMpegBaseCscInit(SceInt32 width) { unimplemented(); return 0; }
	SceInt32 sceMpegBaseCscVme(void* pRGBbuffer, void* pRGBbuffer2, SceInt32 width, SceMpegYCrCbBuffer* pYCrCbBuffer) { unimplemented(); return 0; }
	SceInt32 sceMpegbase_BEA18F91(SceMpegLLI *pLLI) { unimplemented(); return 0; }
	
	void sceMpegBaseCscAvc() {
		unimplemented();
	}

	void sceMpegBaseCscAvcRange() {
		unimplemented();
	}
	
	void sceMpegBaseYCrCbCopy() {
		unimplemented();
	}
	
	void sceMpegbase_0530BE4E() {
		unimplemented();
	}
}

static this() {
	mixin(ModuleNative.registerModule("sceMpegbase"));
}
