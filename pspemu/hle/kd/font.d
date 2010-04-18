module pspemu.hle.kd.font; // kd/libfont.prx (SceFont_Library):

import pspemu.hle.Module;

class sceLibFont : Module {
	void initNids() {
		mixin(registerd!(0x099EF33C, sceFontFindOptimumFont));
		mixin(registerd!(0x0DA7535E, sceFontGetFontInfo));
		mixin(registerd!(0x67F17ED7, sceFontNewLib));
		mixin(registerd!(0x980F4895, sceFontGetCharGlyphImage));
		mixin(registerd!(0xA834319D, sceFontOpen));
		mixin(registerd!(0xDCC80C2F, sceFontGetCharInfo));
	}

	// @TODO: Unknown.
	void sceFontFindOptimumFont() { unimplemented(); }
	void sceFontGetFontInfo() { unimplemented(); }
	void sceFontNewLib() { unimplemented(); }
	void sceFontGetCharGlyphImage() { unimplemented(); }
	void sceFontOpen() { unimplemented(); }
	void sceFontGetCharInfo() { unimplemented(); }
}

static this() {
	mixin(Module.registerModule("sceLibFont"));
}