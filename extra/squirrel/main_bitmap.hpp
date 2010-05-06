// http://wiki.ps2dev.org/psp:ge_faq
void swizzle_fast(u8* out, const u8* in, unsigned int width, unsigned int height) {
	unsigned int blockx, blocky;
	unsigned int j;

	unsigned int width_blocks = (width / 16);
	unsigned int height_blocks = (height / 8);

	unsigned int src_pitch = (width-16)/4;
	unsigned int src_row = width * 8;

	const u8* ysrc = in;
	u32* dst = (u32*)out;

	for (blocky = 0; blocky < height_blocks; ++blocky) {
		const u8* xsrc = ysrc;
		for (blockx = 0; blockx < width_blocks; ++blockx) {
			const u32* src = (u32*)xsrc;
			for (j = 0; j < 8; ++j) {
				*(dst++) = *(src++);
				*(dst++) = *(src++);
				*(dst++) = *(src++);
				*(dst++) = *(src++);
				src += src_pitch;
			}
			xsrc += 16;
		}
		ysrc += src_row;
	}
}

/*
texture reads from user memory (mem range 0x08800000 - 0x01800000) have a bandwidth of 50MB/s
texture reads from GE memory or VRAM (mem range 0x04000000 - 0x00200000) have a bandwidth of 500MB/s
if you have a texture in user memory it is possible to load that texture to VRAM at a bandwidth of 150MB/s

10x faster
*/

unsigned int graphicMemory = (512 * 272 * 4 * 1);

static int BitmapLoadingCount;
class Bitmap { public:
	char name[256];
	SDL_Surface *surface;
	int slice_x, slice_y, slice_w, slice_h;
	int cx, cy;
	bool ready;
	bool swizzled;
	bool hasAlpha;

	Bitmap(int width, int height, int bpp) {
		name[0] = 0;
		//pspDebugScreenPrintf("Bitmap::Bitmap\n");
		surface = SDL_CreateRGBSurface(SDL_HWSURFACE, width, height, bpp * 8, 0, 0, 0, 0);
		slice_x = 0;
		slice_y = 0;
		slice_w = width;
		slice_h = height;
		cx = 0;
		cy = 0;
		swizzled = false;
		ready = true;
	}
	
	Bitmap() {
	}
	
	~Bitmap() {
		//pspDebugScreenPrintf("Bitmap::~Bitmap\n");
		if (surface != NULL) SDL_FreeSurface(surface);
	}
	
	Bitmap *slice(int x, int y, int w, int h) {
		waitReady();

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

		newbitmap->swizzled = swizzled;
		newbitmap->cx = 0;
		newbitmap->cy = 0;

		return newbitmap;
	}
	
	static int fromFileThread(void *_bitmap) {
		//SDL_Delay(1); // @BUG! This causes errors some times on d pspemu
		Bitmap *bitmap = (Bitmap *)_bitmap;
		bitmap->surface = IMG_Load(bitmap->name);
		if (bitmap->surface == NULL) {
			bitmap->surface = SDL_CreateRGBSurface(SDL_HWSURFACE, 1, 1, 32, 0, 0, 0, 0);
		}
		bitmap->swizzled = 0;
		bitmap->slice_x = 0;
		bitmap->slice_y = 0;
		bitmap->slice_w = bitmap->surface->w;
		bitmap->slice_h = bitmap->surface->h;
		bitmap->cx = 0;
		bitmap->cy = 0;
		int reqW = 1, reqH = 1;
		while (reqW < bitmap->slice_w) reqW <<= 1;
		while (reqH < bitmap->slice_h) reqH <<= 1;
		if ((bitmap->surface->w != reqW)) {
			SDL_Surface *newsurface = SDL_CreateRGBSurface(SDL_SWSURFACE, reqW, reqH, 32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000);
			SDL_SetAlpha(bitmap->surface, 0, SDL_ALPHA_OPAQUE);
			SDL_BlitSurface(bitmap->surface, NULL, newsurface, NULL);
			SDL_FreeSurface(bitmap->surface);
			bitmap->surface = newsurface;
		}
		bitmap->surface->h = reqH;

		// Swizzle.
		if (bitmap->surface->pixels) {
			u8 *newdata = (u8 *)malloc(bitmap->surface->pitch * bitmap->surface->h);
			swizzle_fast(newdata, (const u8*)bitmap->surface->pixels, bitmap->surface->w * 4, bitmap->surface->h);
			free(bitmap->surface->pixels);
			bitmap->surface->pixels = newdata;
			bitmap->swizzled = 1;
		}
		
		bitmap->ready = true;
		BitmapLoadingCount--;
		return 0;
	}
	
	static Bitmap *fromFile(const char *name) {
		Bitmap *bitmap = new Bitmap();
		strcpy(bitmap->name, name);
		bitmap->ready = false;
		BitmapLoadingCount++;
		#ifdef VERSION_BACKGROUND_LOADING
			SDL_CreateThread(Bitmap::fromFileThread, bitmap);
		#else
			fromFileThread(bitmap);
		#endif
		return bitmap;
	}

	// Waits until the bitmap have been loaded completely.
	void waitReady() {
		while (!ready) SDL_Delay(1); // @TODO: Use semaphores? Maybe not too necessary.
	}
	
	void use() {
		waitReady();
		sceGuEnable(GU_TEXTURE_2D);
		sceGuTexMode(GU_PSM_8888, 0, 0, swizzled);
		sceGuTexFilter(GU_LINEAR, GU_LINEAR);
		sceGuTexFunc(GU_TFX_REPLACE, GU_TCC_RGBA);
		sceGuTexImage(0, surface->w, surface->h, surface->w, surface->pixels);
	}
	
	void unuse() {
		sceGuDisable(GU_TEXTURE_2D);
	}
	
	void draw(int x, int y) {
		waitReady();

		//pspDebugScreenPrintf("Bitmap::draw(%d, %s)\n", data[0], test);
		if (surface == NULL) return;

		use();
		{
			int width_subslice = 64;
			int x_count = (slice_w / width_subslice) + ((slice_w % width_subslice) ? 1 : 0);

			TexVertex *vl = (TexVertex *)sceGuGetMemory(2 * x_count * sizeof(TexVertex));
			TexVertex *vlp = vl;

			// http://hitmen.c02.at/files/yapspd/psp_doc/chap11.html#sec11
			// The texture cache is very important on the PSP (as it was on the PS2). From experiments it seems to be 8kB,
			// so that means it's 64x32 in 32-bit, 64x64 in 16-bit, 128x64 in 8-bit and 128x128 in 4-bit (the sizes are
			// qualified guesses by looking at the PS2). Ordering your draws so that locality in uv-coordinates is maximized
			// will make sure your rendering is optimal. DXTn is decompressed into 32-bit when loaded into the cache, so what
			// you gain in shrinking the texture-size, you lose in texture-cache. If you can, use 4- or 8-bit textures, which
			// will allow a much larger area to be kept in the cache.

			for (int xpos = 0; xpos < slice_w; xpos += width_subslice, vlp += 2) {
				int cw = (slice_w - xpos);
				if (cw > width_subslice) cw = width_subslice;
				writeCoords(
					vlp,
					x - cx + xpos, y - cy,
					xpos, 0,
					cw, slice_h
				);
				// writeCoords(vl, x - cx, y - cy, 0, 0, slice_w, slice_h);
			}

			sceGuDrawArray(GU_SPRITES, GU_TEXTURE_16BIT | GU_VERTEX_16BIT | GU_TRANSFORM_2D, 2 * x_count, 0, vl);
		}
		unuse();
	}
	
	void writeCoords(TexVertex *vl, int px, int py, int tx, int ty, int tw, int th) {
		vl[0].x = px;
		vl[0].y = py;
		vl[0].z = 0;
		vl[0].u = slice_x + tx;
		vl[0].v = slice_y + ty;

		vl[1].x = vl[0].x + tw;
		vl[1].y = vl[0].y + th;
		vl[1].z = vl[0].z + 0;
		vl[1].u = vl[0].u + tw;
		vl[1].v = vl[0].v + th;
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

	self->waitReady();
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

	self->waitReady();
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
		
		self->waitReady();
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

		self->waitReady();		
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
