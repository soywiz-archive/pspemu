
class Font { public:
	intraFont* font;
	int width;
	int cutLen;

	Font(const char *pgfFilename) {
		// "flash0:/font/ltn0.pgf"
		font = intraFontLoad(pgfFilename, INTRAFONT_STRING_UTF8 | INTRAFONT_CACHE_MED);
		font->size = 1.0;
		font->color = 0xFFFFFFFF;
		font->shadowColor = 0xFF3F3F3F;
		intraFontSetStyle(font, 1.0, 0xFFFFFFFF, 0xFF3F3F3F, 0);
		width = 0;
		cutLen = -1;
	}
	
	~Font() {
		if (font != NULL) intraFontUnload(font);
	}
	
	void print(int x, int y, const char *text) {
		int textLength = (cutLen < 0) ? strlen(text) : cutLen;

		if (width != 0) {
			intraFontPrintColumnEx(font, x, y, width, text, textLength);
		} else {
			intraFontPrintEx(font, x, y, text, textLength);
		}

		sceGuDisable(GU_TEXTURE_2D);
		sceGuDisable(GU_DEPTH_TEST);
	}
};

#define SQTAG_Font (SQUserPointer)0x80010000
DSQ_RELEASE_AUTO(Font);

DSQ_METHOD(Font, constructor)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, pgfFilename, NULL);
	
	if (pgfFilename.data == NULL) {
		pgfFilename.data = (unsigned char *)"flash0:/font/ltn0.pgf";
		pgfFilename.len = strlen((const char *)pgfFilename.data);
	}

	Font *self = new Font((const char *)pgfFilename.data);
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Font));
	return 0;
}

DSQ_METHOD(Font, print)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Font);
	EXTRACT_PARAM_INT(2, x,  0);
	EXTRACT_PARAM_INT(3, y, 0);
	EXTRACT_PARAM_STR(4, text, NULL);
	
	self->print(x, y, (const char *)text.data);
	return 0;
}

DSQ_METHOD(Font, _get)
{
	EXTRACT_PARAM_START();

	if (nargs >= 2) {
		EXTRACT_PARAM_SELF(Font);
		EXTRACT_PARAM_STR(2, s, NULL);
		
		char *c = (char *)s.data;
		
		if (strcmp(c, "size" ) == 0) RETURN_FLOAT(self->font->size);
		if (strcmp(c, "cutLen") == 0) RETURN_INT(self->cutLen);
	}
	
	return 0;
}

DSQ_METHOD(Font, _set)
{
	EXTRACT_PARAM_START();

	if (nargs >= 3) {
		EXTRACT_PARAM_SELF(Font);
		EXTRACT_PARAM_STR(2, s, NULL);
		EXTRACT_PARAM_INT(3, vi, 0);
		EXTRACT_PARAM_FLO(3, vf, 0);
		
		char *c = (char *)s.data;

		if (strcmp(c, "size") == 0) RETURN_FLOAT(self->font->size = vf);
		if (strcmp(c, "cutLen") == 0) RETURN_INT(self->cutLen = vi);
	}
	
	return 0;
}

void register_Font(HSQUIRRELVM v)
{
	CLASS_START(Font);
	{
		NEWSLOT_METHOD(Font, constructor, 0, "");
		NEWSLOT_METHOD(Font, _get, 0, ".");
		NEWSLOT_METHOD(Font, _set, 0, ".");
		NEWSLOT_METHOD(Font, print, 0, ".");
	}
	CLASS_END;
}
