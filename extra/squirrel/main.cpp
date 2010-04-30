#include <pspkernel.h>
#include <pspdisplay.h>
#include <pspdebug.h>
#include <stdlib.h>
#include <pspctrl.h>
#include <pspgu.h>
#include <pspgum.h>

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdarg.h> 

#include <squirrel.h> 
#include <sqstdio.h> 
#include <sqstdaux.h> 
#include <sqstdblob.h> 
#include <sqstdmath.h> 
#include <sqstdstring.h> 
#include <sqstdsystem.h> 

#include <SDL/SDL.h>
#include <SDL/SDL_thread.h>
#include <SDL/SDL_Image.h>

#define BUF_WIDTH (512)
#define SCR_WIDTH (480)
#define SCR_HEIGHT (272)

//void* sceGuGetMemory(int size);

static unsigned int __attribute__((aligned(16))) list[262144];
struct TexVertex {
	short u, v;
	short x, y, z;
};
struct Vertex {
	short x, y, z;
};

int bufferTick = 0;

#include "utils.h"

HSQUIRRELVM v;

/*
using namespace std;

PSP_MODULE_INFO("squirrel", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);
*/

#include "main_bitmap.hpp"
#include "main_tilemap.hpp"
#include "main_sqlite.hpp"

void printfunc(HSQUIRRELVM vm, const SQChar *s, ...) {
	char temp[1024];
	va_list vl;
	va_start(vl, s);
	vsprintf(temp, s, vl);
	va_end(vl);
	pspDebugScreenPrintf("%s", temp);
}

void* buffers[2] = {(void *)0, (void *)(512 * 272 * 4)};

void swapBuffers() {
	bufferTick ^= 1;
	sceGuDrawBuffer(GU_PSM_8888, buffers[bufferTick], BUF_WIDTH);
	sceGuDispBuffer(SCR_WIDTH, SCR_HEIGHT, buffers[bufferTick ^ 1], BUF_WIDTH);
}

void psp_init() {
	
	//void* depthBufferPointer = (void*)(512 * 272 * 4);

	sceGuInit();

	sceGuStart(GU_DIRECT, list);
	{
		swapBuffers();
		//sceGuDepthBuffer(depthBufferPointer, BUF_WIDTH);
		sceGuOffset(2048 - (SCR_WIDTH / 2), 2048 - (SCR_HEIGHT / 2));
		sceGuViewport(2048, 2048, SCR_WIDTH, SCR_HEIGHT);
		//sceGuDepthRange(65535, 0);
		sceGuScissor(0, 0, SCR_WIDTH, SCR_HEIGHT);
		sceGuEnable(GU_SCISSOR_TEST);
		sceGuFrontFace(GU_CW);
		sceGuShadeModel(GU_SMOOTH);
		sceGuDisable(GU_TEXTURE_2D);
		sceGuBlendFunc(GU_ADD, GU_SRC_ALPHA, GU_ONE_MINUS_SRC_ALPHA, 0, 0);
		sceGuEnable(GU_BLEND);
		sceGuColor(0xFFFFFFFF);
	}
	sceGuFinish();
	sceGuSync(0, 0);

	sceGuDisplay(1);
	
	pspDebugScreenInit();
	
	sceGuStart(GU_DIRECT, list);
}

DSQ_FUNC(clear)
{
	//EXTRACT_PARAM_START();

	sceGuClearColor(0);
	sceGuClearDepth(0);
	sceGuClear(GU_COLOR_BUFFER_BIT | GU_DEPTH_BUFFER_BIT);

	RETURN_VOID;
}

DSQ_FUNC(frame)
{
	//EXTRACT_PARAM_START();
	//EXTRACT_PARAM_INT(2, fps, 30);
	//EXTRACT_PARAM_INT(3, swap_type, 1);

	sceGuFinish();
	sceGuSync(0, 0);
	sceGuStart(GU_DIRECT, list);
	sceKernelDcacheWritebackInvalidateAll();
	sceDisplayWaitVblankStart();
	swapBuffers();

	RETURN_VOID;
}

DSQ_FUNC(color)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, color, 0);

	sceGuColor(color);

	RETURN_VOID;
}

DSQ_FUNC(colorf)
{
	float colors[4];
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_COL(2, colors);

	unsigned int r = (unsigned int)(colors[0] * 0xFF) & 0xFF;
	unsigned int g = (unsigned int)(colors[1] * 0xFF) & 0xFF;
	unsigned int b = (unsigned int)(colors[2] * 0xFF) & 0xFF;
	unsigned int a = (unsigned int)(colors[3] * 0xFF) & 0xFF;
	sceGuColor((a << 24) | (b << 16) | (g << 8) | (r << 0));

	RETURN_VOID;
}

DSQ_FUNC(line)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, x1, 0);
	EXTRACT_PARAM_INT(3, y1, 0);
	EXTRACT_PARAM_INT(4, x2, 0);
	EXTRACT_PARAM_INT(5, y2, 0);

	Vertex *vl = (Vertex *)sceGuGetMemory(2 * sizeof(Vertex));
	vl[0].x = x1;
	vl[0].y = y1;
	vl[0].z = 0;
	vl[1].x = x2;
	vl[1].y = y2;
	vl[1].z = 0;

	sceGumDrawArray(GU_LINES, GU_VERTEX_16BIT | GU_TRANSFORM_2D, 2, 0, vl);

	RETURN_VOID;
}

DSQ_FUNC(point)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, x, 0);
	EXTRACT_PARAM_INT(3, y, 0);

	Vertex *vl = (Vertex *)sceGuGetMemory(2 * sizeof(Vertex));
	vl[0].x = x;
	vl[0].y = y;
	vl[0].z = 0;

	sceGumDrawArray(GU_POINTS, GU_VERTEX_16BIT | GU_TRANSFORM_2D, 1, 0, vl);

	RETURN_VOID;
}

DSQ_FUNC(sleep)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_INT(2, milliseconds, 0);

	SDL_Delay(milliseconds);

	RETURN_VOID;
}

DSQ_FUNC(printf)
{
	EXTRACT_PARAM_START();
	const char *s = NULL;
	sq_pushroottable(v);
	sq_pushstring(v, "format", -1);
	sq_get(v, -2); //get the function from the root table
	//sq_pushroottable(v); //íthisí (function environment object)
	for (int n = 1; n <= nargs; n++) sq_push(v, n);
	sq_call(v, nargs, 1, 0);
	sq_getstring(v, -1, &s);
	pspDebugScreenPrintf("%s", s);
	return 0;
}

DSQ_FUNC(exit)
{
	game_quit();
	return 0;
}

DSQ_FUNC(resources_loading_count)
{
	RETURN_INT(BitmapLoadingCount);
}


/*DSQ_FUNC(exiting)
{
	RETURN_INT(1);
}*/

extern "C" int SDL_main(int argc, char* argv[])  { 
	v = sq_open(1024);
	
	SDL_Init(0);

	psp_init();
	BitmapLoadingCount = 0;
	
	sq_pushroottable(v);
	sqstd_register_iolib(v); 
	sqstd_register_bloblib(v);
	sqstd_register_mathlib(v);
	sqstd_register_stringlib(v);
	sqstd_register_systemlib(v);

	// Our classes.
	register_Bitmap(v);
	register_Tilemap(v);
	register_Sqlite(v);
	
	// Out functions.
	NEWSLOT_FUNC(clear, 0, "");
	NEWSLOT_FUNC(color, 0, "");
	NEWSLOT_FUNC(colorf, 0, "");
	NEWSLOT_FUNC(line, 0, "");
	NEWSLOT_FUNC(point, 0, "");
	NEWSLOT_FUNC(frame, 0, "");
	NEWSLOT_FUNC(printf, 0, "");
	NEWSLOT_FUNC(exit, 0, "");
	NEWSLOT_FUNC(sleep, 0, "");
	NEWSLOT_FUNC(resources_loading_count, 0, "");

	sqstd_seterrorhandlers(v);

	sq_setprintfunc(v, printfunc, printfunc);

	sq_pushroottable(v);
	sqstd_dofile(v, _SC("main.nut"), SQFalse, SQTrue);

	sq_pop(v, 1);
	sq_close(v); 

	return 0; 
} 
