module pspemu.hle.kd.libfont.sceLibFont;

import pspemu.hle.ModuleNative;
import pspemu.hle.kd.libfont.Types;

class sceLibFont : HleModuleHost {
	mixin TRegisterModule;
	
	void initNids() {
        mixin(registerFunction!(0x67F17ED7, sceFontNewLib));
        mixin(registerFunction!(0x574B6FBC, sceFontDoneLib));

        mixin(registerFunction!(0xA834319D, sceFontOpen));
        mixin(registerFunction!(0xBB8E7FE6, sceFontOpenUserMemory));
        mixin(registerFunction!(0x57FCB733, sceFontOpenUserFile));
        mixin(registerFunction!(0x3AEA8CB6, sceFontClose));

        mixin(registerFunction!(0x27F6E642, sceFontGetNumFontList));
		mixin(registerFunction!(0x099EF33C, sceFontFindOptimumFont));
        mixin(registerFunction!(0x681E61A7, sceFontFindFont));

		mixin(registerFunction!(0x0DA7535E, sceFontGetFontInfo));
        mixin(registerFunction!(0x5333322D, sceFontGetFontInfoByIndexNumber));

        mixin(registerFunction!(0xDCC80C2F, sceFontGetCharInfo));
		mixin(registerFunction!(0x980F4895, sceFontGetCharGlyphImage));
        mixin(registerFunction!(0xCA1E6945, sceFontGetCharGlyphImage_Clip));
        mixin(registerFunction!(0xBC75D85B, sceFontGetFontList));
        mixin(registerFunction!(0xEE232411, sceFontSetAltCharacterCode));
        mixin(registerFunction!(0x5C3E4A9E, sceFontGetCharImageRect));
        mixin(registerFunction!(0x472694CD, sceFontPointToPixelH));
        mixin(registerFunction!(0x48293280, sceFontSetResolution));
        mixin(registerFunction!(0x3C4B7E82, sceFontPointToPixelV));
        mixin(registerFunction!(0x74B21701, sceFontPixelToPointH));
        mixin(registerFunction!(0xF8F0752E, sceFontPixelToPointV));
        mixin(registerFunction!(0x2F67356A, sceFontCalcMemorySize));
        mixin(registerFunction!(0x48B06520, sceFontGetShadowImageRect));
        mixin(registerFunction!(0x568BE516, sceFontGetShadowGlyphImage));
        mixin(registerFunction!(0x5DCF6858, sceFontGetShadowGlyphImage_Clip));
        mixin(registerFunction!(0xAA3DE7B5, sceFontGetShadowInfo));
        mixin(registerFunction!(0x02D7F94B, sceFontFlush));
	}
	
	class FontLibrary {
		static string[] fontOrder = ["jpn0.pgf", "ltn0.pgf", "ltn1.pgf", "ltn2.pgf", "ltn3.pgf", "ltn4.pgf", "ltn5.pgf", "ltn6.pgf", "ltn7.pgf", "ltn8.pgf", "ltn9.pgf", "ltn10.pgf", "ltn11.pgf", "ltn11.pgf", "ltn12.pgf", "ltn13.pgf", "ltn14.pgf", "ltn15.pgf", "kr0.pgf"];
		string[] fontNames;
		FontStyle[] fontStyles;
		FontNewLibParams params;

		this(FontNewLibParams* params) {
			this.params = *params;
			
			fontStyles ~= FontStyle(0x288, 0x288, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SANS_SERIF, FontStyle.Style.FONT_STYLE_DB         , 0, FontStyle.Language.FONT_LANGUAGE_JAPANESE, 0, 1, "jpn0.pgf" , "FTT-NewRodin Pro DB"   , 0, 0);
			fontStyles ~= FontStyle(0x288, 0x288, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SANS_SERIF, FontStyle.Style.FONT_STYLE_REGULAR    , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn0.pgf" , "FTT-NewRodin Pro Latin", 0, 0);
			fontStyles ~= FontStyle(0x288, 0x288, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SERIF     , FontStyle.Style.FONT_STYLE_REGULAR    , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn1.pgf" , "FTT-Matisse Pro Latin" , 0, 0);
			fontStyles ~= FontStyle(0x288, 0x288, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SANS_SERIF, FontStyle.Style.FONT_STYLE_ITALIC     , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn2.pgf" , "FTT-NewRodin Pro Latin", 0, 0);
			fontStyles ~= FontStyle(0x288, 0x288, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SERIF     , FontStyle.Style.FONT_STYLE_ITALIC     , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn3.pgf" , "FTT-Matisse Pro Latin" , 0, 0);
			fontStyles ~= FontStyle(0x288, 0x288, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SANS_SERIF, FontStyle.Style.FONT_STYLE_BOLD       , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn4.pgf" , "FTT-NewRodin Pro Latin", 0, 0);
			fontStyles ~= FontStyle(0x288, 0x288, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SERIF     , FontStyle.Style.FONT_STYLE_BOLD       , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn5.pgf" , "FTT-Matisse Pro Latin" , 0, 0);
			fontStyles ~= FontStyle(0x288, 0x288, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SANS_SERIF, FontStyle.Style.FONT_STYLE_BOLD_ITALIC, 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn6.pgf" , "FTT-NewRodin Pro Latin", 0, 0);
			fontStyles ~= FontStyle(0x288, 0x288, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SERIF     , FontStyle.Style.FONT_STYLE_BOLD_ITALIC, 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn7.pgf" , "FTT-Matisse Pro Latin" , 0, 0);
			fontStyles ~= FontStyle(0x1c0, 0x1c0, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SANS_SERIF, FontStyle.Style.FONT_STYLE_REGULAR    , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn8.pgf" , "FTT-NewRodin Pro Latin", 0, 0);
			fontStyles ~= FontStyle(0x1c0, 0x1c0, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SERIF     , FontStyle.Style.FONT_STYLE_REGULAR    , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn9.pgf" , "FTT-Matisse Pro Latin" , 0, 0);
			fontStyles ~= FontStyle(0x1c0, 0x1c0, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SANS_SERIF, FontStyle.Style.FONT_STYLE_ITALIC     , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn10.pgf", "FTT-NewRodin Pro Latin", 0, 0);
			fontStyles ~= FontStyle(0x1c0, 0x1c0, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SERIF     , FontStyle.Style.FONT_STYLE_ITALIC     , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn11.pgf", "FTT-Matisse Pro Latin" , 0, 0);
			fontStyles ~= FontStyle(0x1c0, 0x1c0, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SANS_SERIF, FontStyle.Style.FONT_STYLE_BOLD       , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn12.pgf", "FTT-NewRodin Pro Latin", 0, 0);
			fontStyles ~= FontStyle(0x1c0, 0x1c0, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SERIF     , FontStyle.Style.FONT_STYLE_BOLD       , 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn13.pgf", "FTT-Matisse Pro Latin" , 0, 0);
			fontStyles ~= FontStyle(0x1c0, 0x1c0, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SANS_SERIF, FontStyle.Style.FONT_STYLE_BOLD_ITALIC, 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn14.pgf", "FTT-NewRodin Pro Latin", 0, 0);
			fontStyles ~= FontStyle(0x1c0, 0x1c0, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SERIF     , FontStyle.Style.FONT_STYLE_BOLD_ITALIC, 0, FontStyle.Language.FONT_LANGUAGE_LATIN   , 0, 1, "ltn15.pgf", "FTT-Matisse Pro Latin" , 0, 0);
			fontStyles ~= FontStyle(0x288, 0x288, 0x2000, 0x2000, 0, 0, FontStyle.Family.FONT_FAMILY_SANS_SERIF, FontStyle.Style.FONT_STYLE_REGULAR    , 0, FontStyle.Language.FONT_LANGUAGE_KOREAN  , 0, 3, "kr0.pgf"  , "AsiaNHH(512Johab)"     , 0, 0);

			foreach (item; hleEmulatorState.rootFileSystem.fsroot.dopen("flash0:/font")) {
				if (item.stat.isDir) continue;
				fontNames ~= "flash0:/font/" ~ item.name;
				//writefln("%s", item.name);
			}
		}
	}
	
	class Font {
		FontLibrary fontLibrary;
		
		this(FontLibrary fontLibrary) {
			this.fontLibrary = fontLibrary;
		}
		
		Font setByIndex(int index) {
			return setByFileName(fontLibrary.fontNames[index]);
		}
		
		Font setByData(ubyte[] data) {
			return this;
		}
		
		Font setByFileName(string fileName) {
			return this;
		}
	}
	
	/**
	 * Creates a new font library.
	 *
	 * @param  params     Parameters of the new library.
	 * @param  errorCode  Pointer to store any error code.
	 *
	 * @return FontLibraryHandle
	 */
	FontLibraryHandle sceFontNewLib(FontNewLibParams* params, uint* errorCode) {
		unimplemented_notice();

		*errorCode = 0;
		
		return uniqueIdFactory.add(new FontLibrary(params));
	}

	/**
	 * Releases the font library.
	 *
	 * @param  libHandle  Handle of the library.
	 *
	 * @return 0 on success
	 */
	int sceFontDoneLib(FontLibraryHandle libHandle) {
		unimplemented();

		return 0;
	}
	
	/**
	 * Opens a new font.
	 *
	 * @param  libHandle  Handle of the library.
	 * @param  index      Index of the font.
	 * @param  mode       Mode for opening the font.
	 * @param  errorCode  Pointer to store any error code.
	 *
	 * @return FontHandle
	 */
	FontHandle sceFontOpen(FontLibraryHandle libHandle, int index, int mode, uint* errorCode) {
		unimplemented_notice();

		*errorCode = 0;
		
		return uniqueIdFactory.add(
			(new Font(uniqueIdFactory.get!FontLibrary(libHandle)))
				.setByIndex(index)
		);
	}

	/**
	 * Opens a new font from memory.
	 *
	 * @param  libHandle         Handle of the library.
	 * @param  memoryFontAddr    Index of the font.
	 * @param  memoryFontLength  Mode for opening the font.
	 * @param  errorCode         Pointer to store any error code.
	 *
	 * @return FontHandle
	 */
	FontHandle sceFontOpenUserMemory(FontLibraryHandle libHandle, void* memoryFontAddr, int memoryFontLength, uint* errorCode) {
		unimplemented_notice();

		*errorCode = 0;
		
		return uniqueIdFactory.add(
			(new Font(uniqueIdFactory.get!FontLibrary(libHandle)))
				.setByData((cast(ubyte *)memoryFontAddr)[0..memoryFontLength])
		);
	}
	
	/**
	 * Opens a new font from a file.
	 *
	 * @param  libHandle  Handle of the library.
	 * @param  fileName   Path to the font file to open.
	 * @param  mode       Mode for opening the font.
	 * @param  errorCode  Pointer to store any error code.
	 *
	 * @return FontHandle
	 */
	FontHandle sceFontOpenUserFile(FontLibraryHandle libHandle, string fileName, int mode, uint* errorCode) {
		unimplemented_notice();
		
		*errorCode = 0;

		return uniqueIdFactory.add(
			(new Font(uniqueIdFactory.get!FontLibrary(libHandle)))
				.setByFileName(fileName)
		);
	}

	/**
	 * Closes the specified font file.
	 *
	 * @param  fontHandle  Handle of the font.
	 *
	 * @return 0 on success.
	 */
	int sceFontClose(FontHandle fontHandle) {
		unimplemented();

		return 0;
	}

	/**
	 * Returns the number of available fonts.
	 *
	 * @param  libHandle  Handle of the library.
	 * @param  errorCode  Pointer to store any error code.
	 *
	 * @return Number of fonts
	 */
	int sceFontGetNumFontList(FontLibraryHandle libHandle, uint* errorCode) {
		unimplemented_notice();

		//unimplemented();
		FontLibrary fontLibrary = uniqueIdFactory.get!FontLibrary(libHandle);
		*errorCode = 0;

		return fontLibrary.fontNames.length;		
	}
	
	/**
	 * Retrieves all the font styles up to numFonts.
	 *
	 * @param  libHandle   Handle of the library.
	 * @param  fontStyles  Pointer to store the font styles.
	 * @param  numFonts    Number of fonts to write.
	 *
	 * @return Number of fonts
	 */
    int sceFontGetFontList(FontLibraryHandle libHandle, FontStyle* fontStyles, int numFonts) {
		unimplemented_notice();

    	FontLibrary fontLibrary = uniqueIdFactory.get!FontLibrary(libHandle);
    	fontStyles[0..numFonts] = fontLibrary.fontStyles[0..numFonts];
    	return 0;
    }

	/**
	 * Returns a font index that best matches the specified FontStyle.
	 *
	 * @param  libHandle  Handle of the library.
	 * @param  fontStyle  Family, style and 
	 * @param  errorCode  Pointer to store any error code.
	 *
	 * @return Font index
	 */
	int sceFontFindOptimumFont(FontLibraryHandle libHandle, FontStyle* fontStyle, uint* errorCode) {
		//unimplemented();
		unimplemented_notice();

		*errorCode = 0;
		return 1;
	}

	/**
	 * Returns a font index that best matches the specified FontStyle.
	 *
	 * @param  libHandle  Handle of the library.
	 * @param  fontStyle  Family, style and language.
	 * @param  errorCode  Pointer to store any error code.
	 *
	 * @return Font index
	 */
	int sceFontFindFont(FontLibraryHandle libHandle, FontStyle* fontStyle, uint* errorCode) {
		unimplemented();

		*errorCode = 0;
		return 0;
	}

	/**
	 * Obtains the FontInfo of a FontHandle.
	 *
	 * @param  fontHandle  Font Handle to get the information from.
	 * @param  fontInfo    Pointer to a FontInfo structure that will hold the information.
	 *
	 * @return 0 on success
	 */
	int sceFontGetFontInfo(FontHandle fontHandle, FontInfo* fontInfo) {
		unimplemented_notice();

		return 0;
	}
	
	/**
	 * Obtains the FontInfo of a Font with its index.
	 *
	 * @param  libHandle  Handle of the library.
	 * @param  fontInfo   Pointer to a FontInfo structure that will hold the information.
	 * @param  unknown    ???
	 * @param  fontIndex  Index of the font to get the information from.
	 *
	 * @return 0 on success
	 */
	int sceFontGetFontInfoByIndexNumber(FontLibraryHandle libHandle, FontInfo* fontInfo, int unknown, int fontIndex) {
		unimplemented();

		return 0;
	}
	
    int sceFontGetCharInfo(FontHandle fontHandle, uint charCode, FontCharInfo* fontCharInfo) {
    	unimplemented();
    	
        return 0;
    }
    
    
	void sceFontGetCharGlyphImage() { unimplemented(); }
    void sceFontGetCharGlyphImage_Clip() { unimplemented(); }
    void sceFontSetAltCharacterCode() { unimplemented(); }
    void sceFontGetCharImageRect() { unimplemented(); }
    void sceFontPointToPixelH() { unimplemented(); }
    void sceFontSetResolution() { unimplemented(); }
    void sceFontPointToPixelV() { unimplemented(); }
    void sceFontPixelToPointH() { unimplemented(); }
    void sceFontPixelToPointV() { unimplemented(); }
    void sceFontCalcMemorySize() { unimplemented(); }
    void sceFontGetShadowImageRect() { unimplemented(); }
    void sceFontGetShadowGlyphImage() { unimplemented(); }
    void sceFontGetShadowGlyphImage_Clip() { unimplemented(); }
    void sceFontGetShadowInfo() { unimplemented(); }
    void sceFontFlush() { unimplemented(); }

}
