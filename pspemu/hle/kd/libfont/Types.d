module pspemu.hle.kd.libfont.Types;

public import pspemu.hle.kd.Types;

alias uint FontLibraryHandle;
alias uint FontHandle;

struct FontNewLibParams {
	uint* userDataAddr;
	uint  numFonts;
	uint* cacheDataAddr;

	// Driver callbacks.
	uint* allocFuncAddr;
	uint* freeFuncAddr;
	uint* openFuncAddr;
	uint* closeFuncAddr;
	uint* readFuncAddr;
	uint* seekFuncAddr;
	uint* errorFuncAddr;
	uint* ioFinishFuncAddr;
}

struct FontStyle {
	enum Family : ushort {
		FONT_FAMILY_SANS_SERIF = 1,
		FONT_FAMILY_SERIF      = 2,
	}
	
	enum Style : ushort {
		FONT_STYLE_REGULAR     = 1,
		FONT_STYLE_ITALIC      = 2,
		FONT_STYLE_BOLD        = 5,
		FONT_STYLE_BOLD_ITALIC = 6,
		FONT_STYLE_DB          = 103, // Demi-Bold / semi-bold
	}
	
	enum Language : ushort {
		FONT_LANGUAGE_JAPANESE = 1,
		FONT_LANGUAGE_LATIN    = 2,
		FONT_LANGUAGE_KOREAN   = 3,
	}

	float    fontH;
	float    fontV;
	float    fontHRes;
	float    fontVRes;
	float    fontWeight;
	Family   fontFamily;
	Style    fontStyleStyle;
	// Check.
	ushort   fontStyleSub;
	Language fontLanguage;
	ushort   fontRegion;
	ushort   fontCountry;
	char[64] fontFileName;
	char[64] fontName;
	uint     fontAttributes;
	uint     fontExpire;
	
	static FontStyle opCall(
		int fontH, int fontV, int fontHRes, int fontVRes,
		int fontAttributes, int fontWeight,
		Family fontFamily, Style fontStyleStyle, ushort fontStyleSub, Language fontLanguage,
		ushort fontRegion, ushort fontCountry, string fontFileName,
		string fontName, int fontExpire, int shadow_option
	) {
		FontStyle fontStyle;
		{
			fontStyle.fontH          = fontH;
			fontStyle.fontV          = fontV;
			fontStyle.fontHRes       = fontVRes;
			fontStyle.fontHRes       = fontVRes;
			fontStyle.fontWeight     = fontWeight;
			fontStyle.fontFamily     = fontFamily;
			fontStyle.fontStyleStyle = fontStyleStyle;
			fontStyle.fontStyleSub   = fontStyleSub;
			fontStyle.fontLanguage   = fontLanguage;
			fontStyle.fontRegion     = fontRegion;
			fontStyle.fontCountry    = fontCountry;
			
			fontStyle.fontFileName   = fontFileName; // Changed order?
			fontStyle.fontName       = fontName;
			fontStyle.fontAttributes = fontAttributes;
			fontStyle.fontExpire     = fontExpire;
		}
		return fontStyle;
	}
}

struct FontInfo {
    // Glyph metrics (in 26.6 signed fixed-point).
    uint maxGlyphWidthI;
    uint maxGlyphHeightI;
    uint maxGlyphAscenderI;
    uint maxGlyphDescenderI;
    uint maxGlyphLeftXI;
    uint maxGlyphBaseYI;
    uint minGlyphCenterXI;
    uint maxGlyphTopYI;
    uint maxGlyphAdvanceXI;
    uint maxGlyphAdvanceYI;

    // Glyph metrics (replicated as float).
    float maxGlyphWidthF;
    float maxGlyphHeightF;
    float maxGlyphAscenderF;
    float maxGlyphDescenderF;
    float maxGlyphLeftXF;
    float maxGlyphBaseYF;
    float minGlyphCenterXF;
    float maxGlyphTopYF;
    float maxGlyphAdvanceXF;
    float maxGlyphAdvanceYF;
    
    // Bitmap dimensions.
    short maxGlyphWidth;
    short maxGlyphHeight;
    uint  charMapLength;   // Number of elements in the font's charmap.
    uint  shadowMapLength; // Number of elements in the font's shadow charmap.
    
    // Font style (used by font comparison functions).
    FontStyle fontStyle;
    
    ubyte BPP = 4; // Font's BPP.
    ubyte[3] pad;
}

/*
 * Char's metrics:
 *
 *           Width / Horizontal Advance
 *           <---------->
 *      |           000 |
 *      |           000 |  Ascender
 *      |           000 |
 *      |     000   000 |
 *      | -----000--000-------- Baseline
 *      |        00000  |  Descender
 * Height /
 * Vertical Advance
 *
 * The char's bearings represent the difference between the
 * width and the horizontal advance and/or the difference
 * between the height and the vertical advance.
 * In our debug font, these measures are the same (block pixels),
 * but in real PGF fonts they can vary (italic fonts, for example).
 */
struct FontCharInfo {
	uint bitmapWidth;
	uint bitmapHeight;
	uint bitmapLeft;
	uint bitmapTop;

	// Glyph metrics (in 26.6 signed fixed-point).
    uint sfp26Width;
    uint sfp26Height;
    uint sfp26Ascender;
    uint sfp26Descender;
    uint sfp26BearingHX;
    uint sfp26BearingHY;
    uint sfp26BearingVX;
    uint sfp26BearingVY;
    uint sfp26AdvanceH;
    uint sfp26AdvanceV;
    uint padding;
    
    static assert(this.sizeof == 4 * 15);
}
