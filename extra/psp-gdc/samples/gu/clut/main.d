/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * main.c - Basic Input demo -- reads from control pad and indicates button
 *          presses.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 * Copyright (c) 2005 Donour Sizemore <donour@uchicago.edu>
 *
 * $Id: main.c 1095 2005-09-27 21:02:16Z jim $
 */

import pspsdk.pspctrl;
import pspsdk.pspge;
import pspsdk.pspgu, pspsdk.pspgum;
import pspsdk.pspdebug;
import pspsdk.pspkerneltypes;
import pspsdk.pspthreadman;
import pspsdk.psploadexec;
import pspsdk.pspdisplay;
import pspsdk.psputils;
import pspsdk.utils.callback;
import pspsdk.utils.vram;
import std.string;
import std.math;

version (BUILD_INFO) {
	pragma(MODULE_NAME, "CLUTSAMPLE");
	pragma(PSP_EBOOT_TITLE, "Clut Sample");
	pragma(PSP_MAIN_THREAD_ATTR, THREAD_ATTR_USER | THREAD_ATTR_VFPU);
	pragma(PSP_FW_VERSION, 150);
}

align(16) static uint list[262144];

struct Vertex {
	float u, v;
	float x, y, z;
}

static const uint BUF_WIDTH    = 512;
static const uint SCR_WIDTH    = 480;
static const uint SCR_HEIGHT   = 272;
static const uint PIXEL_SIZE   = 4; /* change this if you change to another screenmode */
static const uint FRAME_SIZE   = (BUF_WIDTH * SCR_HEIGHT * PIXEL_SIZE);
static const uint ZBUF_SIZE    = (BUF_WIDTH * SCR_HEIGHT * ushort.sizeof); /* zbuffer seems to be 16-bit? */

static const uint NUM_SLICES   = 128;
static const uint NUM_ROWS     = 128;
static const float RING_SIZE   = 2.0f;
static const float RING_RADIUS = 1.0f;
static const float SPRITE_SIZE = 0.025f;

uint colors[8] = 
[
	0xffff0000,
	0xffff00ff,
	0xff0000ff,
	0xff00ffff,
	0xff00ff00,
	0xffffff00,
	0xffffffff,
	0xff00ffff
];

align(16) uint clut256[256];
align(16) ubyte tex256[256 * 256];

int main()
{
	uint i,j;

	SetupCallbacks();

	// initialize texture

	for (j = 0; j < 256; ++j) {
		for (i = 0; i < 256; ++i) {
			tex256[i + j * 256] = cast(ubyte)(j ^ i);
		}
	}

	sceKernelDcacheWritebackAll();

	// setup GU

	sceGuInit();
	sceGuStart(GU_DIRECT, &list);

	sceGuDrawBuffer(GU_PSM_8888, cast(void*)(0), BUF_WIDTH);
	sceGuDispBuffer(SCR_WIDTH,SCR_HEIGHT,cast(void*)FRAME_SIZE,BUF_WIDTH);
	sceGuDepthBuffer(cast(void*)(FRAME_SIZE*2),BUF_WIDTH);
	sceGuOffset(2048 - (SCR_WIDTH/2),2048 - (SCR_HEIGHT/2));
	sceGuViewport(2048,2048,SCR_WIDTH,SCR_HEIGHT);
	sceGuDepthRange(0xc350,0x2710);
	sceGuScissor(0,0,SCR_WIDTH,SCR_HEIGHT);
	sceGuEnable(GU_SCISSOR_TEST);
	sceGuFrontFace(GU_CW);
	sceGuEnable(GU_TEXTURE_2D);
	sceGuClear(GU_COLOR_BUFFER_BIT|GU_DEPTH_BUFFER_BIT);
	sceGuFinish();
	sceGuSync(0,0);

	sceDisplayWaitVblankStart();
	sceGuDisplay(GU_TRUE);

	// run sample

	int offset = 0;

	while (running) {
		sceGuStart(GU_DIRECT, &list);

		// animate palette

		uint* clut = cast(uint*)((cast(uint)&clut256)|0x40000000);
		for (i = 0; i < 256; ++i)
		{
			j = (i + offset)&0xff;
			*(clut++) = (j << 24)|(j << 16)|(j << 8)|(j);
		}

		// clear screen

		sceGuClearColor(0xff00ff);
		sceGuClear(GU_COLOR_BUFFER_BIT);

		// setup CLUT texture

		sceGuClutMode(GU_PSM_8888,0,0xff,0); // 32-bit palette
		sceGuClutLoad((256/8),&clut256); // upload 32*8 entries (256)
		sceGuTexMode(GU_PSM_T8,0,0,0); // 8-bit image
		sceGuTexImage(0,256,256,256,&tex256);
		sceGuTexFunc(GU_TFX_REPLACE,GU_TCC_RGB);
		sceGuTexFilter(GU_LINEAR,GU_LINEAR);
		sceGuTexScale(1.0f,1.0f);
		sceGuTexOffset(0.0f,0.0f);
		sceGuAmbientColor(0xffffffff);

		// render sprite

		sceGuColor(0xffffffff);
		Vertex* vertices = cast(Vertex*)sceGuGetMemory(2 * Vertex.sizeof);
		vertices[0].u = 0; vertices[0].v = 0;
		vertices[0].x = 0; vertices[0].y = 0; vertices[0].z = 0;
		vertices[1].u = 256; vertices[1].v = 256;
		vertices[1].x = 480; vertices[1].y = 272; vertices[1].z = 0;
		sceGuDrawArray(GU_SPRITES,GU_TEXTURE_32BITF|GU_VERTEX_32BITF|GU_TRANSFORM_2D,2,null,vertices);

		// wait for next frame

		sceGuFinish();
		sceGuSync(0,0);

		sceDisplayWaitVblankStart();
		sceGuSwapBuffers();

		offset++;
	}

	sceGuTerm();

	sceKernelExitGame();
	return 0;
}
