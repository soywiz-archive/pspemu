
class Bitmap { public:
	SDL_Surface *surface;
	int slice_x, slice_y, slice_w, slice_h;
	int cx, cy;

	Bitmap(int width, int height, int bpp) {
		//pspDebugScreenPrintf("Bitmap::Bitmap\n");
		surface = SDL_CreateRGBSurface(SDL_HWSURFACE, width, height, bpp * 8, 0, 0, 0, 0);
		slice_x = 0;
		slice_y = 0;
		slice_w = width;
		slice_h = height;
		cx = 0;
		cy = 0;
	}
	
	Bitmap() {
	}
	
	~Bitmap() {
		//pspDebugScreenPrintf("Bitmap::~Bitmap\n");
		if (surface != NULL) SDL_FreeSurface(surface);
	}
	
	Bitmap *slice(int x, int y, int w, int h) {
		Bitmap *newbitmap = new Bitmap();
		newbitmap->surface = surface;

		if (x < 0) x = 0;
		if (y < 0) y = 0;
		if (x > slice_w) x = slice_w;
		if (y > slice_h) y = slice_h;
		newbitmap->slice_x = slice_x + x;
		newbitmap->slice_y = slice_y + y;

		if (w < 0) w = 0;
		if (h < 0) h = 0;
		if (w >= slice_w - x) w = slice_w - x;
		if (h >= slice_h - y) h = slice_h - y;
		newbitmap->slice_w = w;
		newbitmap->slice_h = h;
		
		newbitmap->surface->refcount++;

		newbitmap->cx = 0;
		newbitmap->cy = 0;

		return newbitmap;
	}
	
	static Bitmap *fromFile(const char *name) {
		Bitmap *bitmap = new Bitmap();
		bitmap->surface = IMG_Load(name);
		bitmap->slice_x = 0;
		bitmap->slice_y = 0;
		bitmap->slice_w = bitmap->surface->w;
		bitmap->slice_h = bitmap->surface->h;
		bitmap->cx = 0;
		bitmap->cy = 0;
		int reqW = 1, reqH = 1;
		while (reqW < bitmap->slice_w) reqW <<= 1;
		while (reqH < bitmap->slice_h) reqH <<= 1;
		SDL_Surface *newsurface = SDL_CreateRGBSurface(SDL_SWSURFACE, reqW, reqH, 32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000);
		SDL_SetAlpha(bitmap->surface, 0, SDL_ALPHA_OPAQUE);
		SDL_BlitSurface(bitmap->surface, NULL, newsurface, NULL);
		SDL_FreeSurface(bitmap->surface);
		bitmap->surface = newsurface;
		return bitmap;
	}
	
	void draw(int x, int y) {
		//pspDebugScreenPrintf("Bitmap::draw(%d, %s)\n", data[0], test);
		if (surface == NULL) return;

		sceGuEnable(GU_TEXTURE_2D);
		//sceGuEnable(GU_BLEND);

		sceGuTexMode(GU_PSM_8888, 0, 0, 0);
		sceGuTexFilter(GU_LINEAR, GU_LINEAR);
		sceGuTexFunc(GU_TFX_REPLACE, GU_TCC_RGBA);
		sceGuTexImage(0, surface->w, surface->h, surface->w, surface->pixels);

		TexVertex *vl = (TexVertex *)sceGuGetMemory(2 * sizeof(TexVertex));

		vl[0].x = x - cx;
		vl[0].y = y - cy;
		vl[0].z = 0;
		vl[0].u = slice_x;
		vl[0].v = slice_y;

		vl[1].x = x + slice_w - cx;
		vl[1].y = y + slice_h - cy;
		vl[1].z = 0;
		vl[1].u = slice_x + slice_w;
		vl[1].v = slice_y + slice_h;
		
		sceGumDrawArray(GU_SPRITES, GU_TEXTURE_16BIT | GU_VERTEX_16BIT | GU_TRANSFORM_2D, 2, 0, vl);

		sceGuDisable(GU_TEXTURE_2D);
		//sceGuDisable(GU_BLEND);
	}
};

#define SQTAG_Bitmap (SQUserPointer)0x80000000
//DSQ_RELEASE_AUTO_RELEASECAPTURE(Bitmap);
DSQ_RELEASE_AUTO(Bitmap);

DSQ_METHOD(Bitmap, constructor)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, width,  0);
	EXTRACT_PARAM_INT(3, height, 0);
	EXTRACT_PARAM_INT(4, bpp,    4);

	Bitmap *self = new Bitmap(width, height, bpp);
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Bitmap));
	return 0;
}

DSQ_METHOD(Bitmap, fromFile)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, filename,  "");

	Bitmap *newbmp = Bitmap::fromFile((const char *)filename.data);
	CREATE_OBJECT(Bitmap, newbmp);
	return 1;
}

DSQ_METHOD(Bitmap, draw)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_INT(2, x,  0);
	EXTRACT_PARAM_INT(3, y, 0);
	
	self->draw(x, y);
	return 0;
}

DSQ_METHOD(Bitmap, slice)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_INT(2, x, 0);
	EXTRACT_PARAM_INT(3, y, 0);
	EXTRACT_PARAM_INT(4, w, 0);
	EXTRACT_PARAM_INT(5, h, 0);
	
	Bitmap *newbmp = self->slice(x, y, w, h);
	CREATE_OBJECT(Bitmap, newbmp);
	return 1;
}

DSQ_METHOD(Bitmap, center)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_INT(2, cx, self->slice_w / 2);
	EXTRACT_PARAM_INT(3, cy, self->slice_h / 2);

	self->cx = cx;
	self->cy = cy;
	
	sq_push(v, -3); return 1;
}

DSQ_METHOD(Bitmap, centerf)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Bitmap);
	EXTRACT_PARAM_FLO(2, cx, 0.5);
	EXTRACT_PARAM_FLO(3, cy, 0.5);

	self->cx = (float)self->slice_w * cx;
	self->cy = (float)self->slice_h * cy;
	
	sq_push(v, -3); return 1;
}

DSQ_METHOD(Bitmap, _get)
{
	EXTRACT_PARAM_START();

	if (nargs >= 2) {
		EXTRACT_PARAM_SELF(Bitmap);
		EXTRACT_PARAM_STR(2, s, NULL);
		
		char *c = (char *)s.data;
		
		if (strcmp(c, "w" ) == 0) RETURN_INT(self->slice_w);
		if (strcmp(c, "h" ) == 0) RETURN_INT(self->slice_h);
		if (strcmp(c, "cx") == 0) RETURN_INT(self->cx);
		if (strcmp(c, "cy") == 0) RETURN_INT(self->cy);
	}
	
	return 0;
}

DSQ_METHOD(Bitmap, _set)
{
	EXTRACT_PARAM_START();

	if (nargs >= 3) {
		EXTRACT_PARAM_SELF(Bitmap);
		EXTRACT_PARAM_STR(2, s, NULL);
		EXTRACT_PARAM_INT(3, vi, 0);
		
		char *c = (char *)s.data;
		
		if (strcmp(c, "cx") == 0) self->cx = vi;
		if (strcmp(c, "cy") == 0) self->cy = vi;
	}
	
	return 0;
}

void register_Bitmap(HSQUIRRELVM v) {
	CLASS_START(Bitmap);
	{
		NEWSLOT_METHOD(Bitmap, constructor, 0, "");
		NEWSLOT_METHOD(Bitmap, fromFile, 0, "");
		NEWSLOT_METHOD(Bitmap, _get, 0, ".");
		NEWSLOT_METHOD(Bitmap, _set, 0, ".");
		NEWSLOT_METHOD(Bitmap, draw, 0, ".");
		NEWSLOT_METHOD(Bitmap, slice, 0, ".");
		NEWSLOT_METHOD(Bitmap, center, 0, ".");
		NEWSLOT_METHOD(Bitmap, centerf, 0, ".");
	}
	CLASS_END;
}
