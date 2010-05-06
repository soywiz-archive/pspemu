#include "main_pathfind.hpp"

//#define TILEMAP_DEBUG 1
#define TILEMAP_DEBUG 0

class TileMap { public:
	unsigned short w, h;
	unsigned short *data;
	unsigned char  *blockInfo; int blockInfoLength;
	unsigned short *translateBlockType;
	Pathfind *pathfind;
	
	TileMap(unsigned short w, unsigned short h, unsigned short V) {
		this->w = w;
		this->h = h;
		this->pathfind = NULL;
		this->blockInfo = new unsigned char[blockInfoLength = 2048];
		this->translateBlockType = new unsigned short[blockInfoLength];
		for (int n = 0; n < blockInfoLength; n++) {
			this->blockInfo[n] = 0;
			this->translateBlockType[n] = n;
		}
		if (w > 0 && h > 0 && w <= 2048 && h <= 2048) {
			this->data = new unsigned short[w * h];
			if (this->data != NULL) {
				for (int n = w * h - 1; n >= 0; n--) this->data[n] = V;
				//__memset16(this->data, V, w * h);
			}
		} else {
			this->data = NULL;
		}
	}

	~TileMap() {
		if (data != NULL) delete data;
		if (pathfind != NULL) delete pathfind;
		if (blockInfo != NULL) delete blockInfo;
		if (translateBlockType != NULL) delete translateBlockType;
	}

	int getTranslateBlock(unsigned short block) {
		return this->translateBlockType[block % blockInfoLength];
	}

	int setTranslateBlock(unsigned short block, unsigned short blockTo) {
		return this->translateBlockType[block % blockInfoLength] = (blockTo % blockInfoLength);
	}
	
	bool pathFind(int x0, int y0, int x1, int y1, bool diagonals = true) {
		if (this->pathfind == NULL) {
			if ((this->pathfind = new Pathfind(data, blockInfo, blockInfoLength, w, h, TILEMAP_DEBUG)) == NULL) return false;
		}
		bool r = this->pathfind->find(x0, y0, x1, y1, diagonals);
		if (TILEMAP_DEBUG) printf("pathFind:end\n");
		return r;
	}
	
	int setBlockInfo(unsigned short type, unsigned char v) {
		if (type >= blockInfoLength) return 0;
		return (blockInfo[type] = v);
	}

	int getBlockInfo(unsigned short type) {
		if (type >= blockInfoLength) return 0;
		return (blockInfo[type]);
	}
	
	int set(int x, int y, unsigned short v) {
		if (x < 0 || y < 0 || x >= w || y >= h) return -1;
		return data[y * w + x] = v;
	}

	int get(int x, int y) {
		if (x < 0 || y < 0 || x >= w || y >= h) return -1;
		return data[y * w + x];
	}
	
	int get_repeat(int x, int y, bool repeat_x, bool repeat_y) {
		if (repeat_x) x = rmod(x, w);
		if (repeat_y) y = rmod(y, h);
		return get(x, y);
	}
	
	void draw(Bitmap *bitmap, int tile_w = 32, int tile_h = 32, int put_x = 0, int put_y = 0, int scroll_x = -5, int scroll_y = -5, int scroll_w = 16, int scroll_h = 16, bool repeat_x = true, bool repeat_y = true, float size = 1, int margin_x = 0, int margin_y = 0) {
		if (bitmap == NULL) return;

		bitmap->waitReady();

		if (tile_w < 1 || tile_h < 1) return; // Too small tile
		if (bitmap->slice_w / tile_w <= 0) return; // Too small image

		TexVertex *vl = (TexVertex *)sceGuGetMemory(scroll_w * scroll_h * 2 * sizeof(TexVertex));
		int vlpos = 0;

		{
			int tiles_per_row = bitmap->slice_w / tile_w;
			
			//glScalef(size, size, 0);
			//glTranslatef(put_x, put_y, 0);

			for (int y = 0, my = 0; y < scroll_h; y++, my += tile_h + margin_y) {
				for (int x = 0, mx = 0; x < scroll_w; x++, mx += tile_w + margin_x) {
					int idx = get_repeat(scroll_x + x, scroll_y + y, repeat_x, repeat_y);
					if (idx < 0) continue;
					idx = translateBlockType[idx % blockInfoLength];
					if (idx < 0) continue;
					idx = idx % blockInfoLength;

					int tile_x = (idx % tiles_per_row) * tile_w, tile_y = (idx / tiles_per_row) * tile_h;
					bitmap->writeCoords(&vl[vlpos], mx + put_x, my + put_y, tile_x, tile_y, tile_w, tile_h); vlpos += 2;
				}
			}
		}
		bitmap->use();
		{
			sceGumDrawArray(GU_SPRITES, GU_TEXTURE_16BIT | GU_VERTEX_16BIT | GU_TRANSFORM_2D, vlpos, 0, vl);
		}
		bitmap->unuse();
	}
};

#define SQTAG_TileMap (SQUserPointer)0x80000001
DSQ_RELEASE_AUTO(TileMap);

DSQ_METHOD(TileMap, constructor)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, w, 1);
	EXTRACT_PARAM_INT(3, h, 1);
	EXTRACT_PARAM_INT(4, V, 0);

	TileMap *self = new TileMap(w, h, V);
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(TileMap));
	sq_pushstring(v, "w", 1); sq_pushinteger(v, w); sq_rawset(v, -3);
	sq_pushstring(v, "h", 1); sq_pushinteger(v, h); sq_rawset(v, -3);
	
	return 0;
}

DSQ_METHOD(TileMap, _get)
{
	EXTRACT_PARAM_START();

	if (nargs >= 2) {
		EXTRACT_PARAM_SELF(TileMap);
		EXTRACT_PARAM_STR(2, s, NULL);
		
		char *c = (char *)s.data;
		
		if (strcmp(c, "w" ) == 0) RETURN_INT(self->w);
		if (strcmp(c, "h" ) == 0) RETURN_INT(self->h);
	}
	
	return 0;
}

DSQ_METHOD(TileMap, get)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(TileMap);
	EXTRACT_PARAM_INT(2, x, 0);
	EXTRACT_PARAM_INT(3, y, 0);

	RETURN_INT(self->get(x, y));
}

DSQ_METHOD(TileMap, set)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(TileMap);
	EXTRACT_PARAM_INT(2, x, 0);
	EXTRACT_PARAM_INT(3, y, 0);
	EXTRACT_PARAM_INT(4, V, 0);

	RETURN_INT(self->set(x, y, V));
}

DSQ_METHOD(TileMap, setRect)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(TileMap);
	EXTRACT_PARAM_INT(2, x0, 0);
	EXTRACT_PARAM_INT(3, y0, 0);
	EXTRACT_PARAM_INT(4, x1, 0);
	EXTRACT_PARAM_INT(5, y1, 0);
	EXTRACT_PARAM_INT(6, V, 0);

	for (int y = y0; y < y1; y++) for (int x = x0; x < x1; x++) {
		self->set(x, y, V);
	}

	RETURN_INT(V);
}

DSQ_METHOD(TileMap, getBlockInfo)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(TileMap);
	EXTRACT_PARAM_INT(2, block, 0);

	RETURN_INT(self->getBlockInfo(block));
}

DSQ_METHOD(TileMap, setBlockInfo)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(TileMap);
	EXTRACT_PARAM_INT(2, block, 0);
	EXTRACT_PARAM_INT(3, value, 0);

	RETURN_INT(self->setBlockInfo(block, value));
}

DSQ_METHOD(TileMap, getTranslateBlock)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(TileMap);
	EXTRACT_PARAM_INT(2, block, 0);

	RETURN_INT(self->getTranslateBlock(block));
}

DSQ_METHOD(TileMap, setTranslateBlock)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(TileMap);
	EXTRACT_PARAM_INT(2, block, 0);
	EXTRACT_PARAM_INT(3, value, 0);

	RETURN_INT(self->setTranslateBlock(block, value));
}

DSQ_METHOD(TileMap, draw)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(TileMap);
	EXTRACT_PARAM_OBJ(2 , Bitmap, bitmap);
	EXTRACT_PARAM_INT(3 , tile_w, 32);
	EXTRACT_PARAM_INT(4 , tile_h, 32);
	EXTRACT_PARAM_INT(5 , repeat_x, 1);
	EXTRACT_PARAM_INT(6 , repeat_y, 1);
	EXTRACT_PARAM_INT(7 , put_x, 0);
	EXTRACT_PARAM_INT(8 , put_y, 0);
	EXTRACT_PARAM_INT(9 , scroll_x, 0);
	EXTRACT_PARAM_INT(10, scroll_y, 0);
	EXTRACT_PARAM_INT(11, scroll_w, 21);
	EXTRACT_PARAM_INT(12, scroll_h, 13);
	EXTRACT_PARAM_FLO(13, alpha, 1.0);
	EXTRACT_PARAM_INT(14, margin_x, 0);
	EXTRACT_PARAM_INT(15, margin_y, 0);
	
	//printf("%d, %d\n", margin_x, margin_y);
	
	//glColor4f(1, 1, 1, alpha);
	self->draw(
		bitmap,
		tile_w, tile_h,
		put_x, put_y,
		scroll_x, scroll_y,
		scroll_w, scroll_h,
		repeat_x, repeat_y,
		1.0, // size
		margin_x, margin_y
	);
	return 0;
}

DSQ_METHOD(TileMap, draw2)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(TileMap);
	EXTRACT_PARAM_OBJ(2 , Bitmap, bitmap);
	EXTRACT_PARAM_FLO(3 , size, 1.0);
	EXTRACT_PARAM_INT(4 , tile_w, 32);
	EXTRACT_PARAM_INT(5 , tile_h, 32);
	EXTRACT_PARAM_INT(6 , repeat_x, 1);
	EXTRACT_PARAM_INT(7 , repeat_y, 1);
	EXTRACT_PARAM_INT(8 , x, 0);
	EXTRACT_PARAM_INT(9 , y, 0);
	EXTRACT_PARAM_INT(10, view_x, 0);
	EXTRACT_PARAM_INT(11, view_y, 0);
	EXTRACT_PARAM_INT(12, view_w, 480);
	EXTRACT_PARAM_INT(13, view_h, 272);
	EXTRACT_PARAM_FLO(14, alpha, 1.0);
	
	//glEnable(GL_SCISSOR_TEST);
	//glScissor(view_x, screen_h_real - view_y - view_h, view_w, view_h);
	//glColor4f(1, 1, 1, alpha);
	{
		self->draw(	
			bitmap,
			tile_w, tile_h,
			view_x - (x % tile_w) - tile_w, view_y - (y % tile_h) - tile_h,
			x / tile_w - 1, y / tile_h - 1,
			(int)(((float)view_w / size / tile_w)) + 3, (int)((float)view_h / size / tile_h) + 3,
			repeat_x, repeat_y,
			size
		);
	}
	//glDisable(GL_SCISSOR_TEST);
	return 0;
}

DSQ_METHOD(TileMap, pathFind)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(TileMap);
	EXTRACT_PARAM_INT(2, sx, 0);
	EXTRACT_PARAM_INT(3, sy, 0);
	EXTRACT_PARAM_INT(4, dx, 0);
	EXTRACT_PARAM_INT(5, dy, 0);
	EXTRACT_PARAM_INT(6, diagonals, 1);

	if (self && self->pathFind(sx, sy, dx, dy, diagonals)) {
		sq_newarray(v, 0);
		for (int n = self->pathfind->path_length - 1; n >= 0; n--) {
			sq_newtable(v);
			sq_pushstring(v, "x", 1); sq_pushinteger(v, self->pathfind->path[n].x); sq_rawset(v, -3);
			sq_pushstring(v, "y", 1); sq_pushinteger(v, self->pathfind->path[n].y); sq_rawset(v, -3);
			sq_arrayappend(v, -2);
		}

		return 1;
	} else {
		RETURN_VOID;
	}
}

void register_Tilemap(HSQUIRRELVM v) {
	CLASS_START(TileMap);
	{
		NEWSLOT_METHOD(TileMap, constructor, 0, "");
		NEWSLOT_METHOD(TileMap, _get, 0, "");
		NEWSLOT_METHOD(TileMap, set, 0, "");
		NEWSLOT_METHOD(TileMap, setRect, 0, "");
		NEWSLOT_METHOD(TileMap, get, 0, "");
		NEWSLOT_METHOD(TileMap, setBlockInfo, 0, "");
		NEWSLOT_METHOD(TileMap, getBlockInfo, 0, "");
		NEWSLOT_METHOD(TileMap, getTranslateBlock, 0, "");
		NEWSLOT_METHOD(TileMap, setTranslateBlock, 0, "");
		NEWSLOT_METHOD(TileMap, draw, 0, "");
		NEWSLOT_METHOD(TileMap, draw2, 0, "");
		NEWSLOT_METHOD(TileMap, pathFind, 0, "");
	}
	CLASS_END;
}
