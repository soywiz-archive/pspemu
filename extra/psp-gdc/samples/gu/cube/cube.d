/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * Copyright (c) 2005 Jesper Svennevid
 */

import pspsdk.all;
import std.string;
import std.math;
import std.c.math;

version (BUILD_INFO) {
	pragma(MODULE_NAME, "Cube Sample");
	pragma(PSP_EBOOT_TITLE, "Cube Sample");
	pragma(PSP_MAIN_THREAD_ATTR, THREAD_ATTR_USER);
	pragma(PSP_FW_VERSION, 150);
}

align(16) static uint list[262144];
static auto logo_start = cast(ubyte[])import("logo.raw");

struct Vertex {
	float u, v;
	uint color;
	float x,y,z;
};

align (16) Vertex vertices[12 * 3] = [
	{0, 0, 0xff7f0000,-1,-1, 1}, // 0
	{1, 0, 0xff7f0000,-1, 1, 1}, // 4
	{1, 1, 0xff7f0000, 1, 1, 1}, // 5

	{0, 0, 0xff7f0000,-1,-1, 1}, // 0
	{1, 1, 0xff7f0000, 1, 1, 1}, // 5
	{0, 1, 0xff7f0000, 1,-1, 1}, // 1

	{0, 0, 0xff7f0000,-1,-1,-1}, // 3
	{1, 0, 0xff7f0000, 1,-1,-1}, // 2
	{1, 1, 0xff7f0000, 1, 1,-1}, // 6

	{0, 0, 0xff7f0000,-1,-1,-1}, // 3
	{1, 1, 0xff7f0000, 1, 1,-1}, // 6
	{0, 1, 0xff7f0000,-1, 1,-1}, // 7

	{0, 0, 0xff007f00, 1,-1,-1}, // 0
	{1, 0, 0xff007f00, 1,-1, 1}, // 3
	{1, 1, 0xff007f00, 1, 1, 1}, // 7

	{0, 0, 0xff007f00, 1,-1,-1}, // 0
	{1, 1, 0xff007f00, 1, 1, 1}, // 7
	{0, 1, 0xff007f00, 1, 1,-1}, // 4

	{0, 0, 0xff007f00,-1,-1,-1}, // 0
	{1, 0, 0xff007f00,-1, 1,-1}, // 3
	{1, 1, 0xff007f00,-1, 1, 1}, // 7

	{0, 0, 0xff007f00,-1,-1,-1}, // 0
	{1, 1, 0xff007f00,-1, 1, 1}, // 7
	{0, 1, 0xff007f00,-1,-1, 1}, // 4

	{0, 0, 0xff00007f,-1, 1,-1}, // 0
	{1, 0, 0xff00007f, 1, 1,-1}, // 1
	{1, 1, 0xff00007f, 1, 1, 1}, // 2

	{0, 0, 0xff00007f,-1, 1,-1}, // 0
	{1, 1, 0xff00007f, 1, 1, 1}, // 2
	{0, 1, 0xff00007f,-1, 1, 1}, // 3

	{0, 0, 0xff00007f,-1,-1,-1}, // 4
	{1, 0, 0xff00007f,-1,-1, 1}, // 7
	{1, 1, 0xff00007f, 1,-1, 1}, // 6

	{0, 0, 0xff00007f,-1,-1,-1}, // 4
	{1, 1, 0xff00007f, 1,-1, 1}, // 6
	{0, 1, 0xff00007f, 1,-1,-1}, // 5
];

static const BUF_WIDTH  = (512);
static const SCR_WIDTH  = (480);
static const SCR_HEIGHT = (272);

int main(char[][] args) {
	SetupCallbacks();

	// setup GU

	void* fbp0 = getStaticVramBuffer(BUF_WIDTH, SCR_HEIGHT, GU_PSM_8888);
	void* fbp1 = getStaticVramBuffer(BUF_WIDTH, SCR_HEIGHT, GU_PSM_8888);
	void* zbp  = getStaticVramBuffer(BUF_WIDTH, SCR_HEIGHT, GU_PSM_4444);

	sceGuInit();

	sceGuStart(GU_DIRECT, &list);
	sceGuDrawBuffer(GU_PSM_8888, fbp0, BUF_WIDTH);
	sceGuDispBuffer(SCR_WIDTH, SCR_HEIGHT, fbp1, BUF_WIDTH);
	sceGuDepthBuffer(zbp, BUF_WIDTH);
	sceGuOffset(2048 - (SCR_WIDTH / 2), 2048 - (SCR_HEIGHT / 2));
	sceGuViewport(2048, 2048, SCR_WIDTH, SCR_HEIGHT);
	sceGuDepthRange(65535, 0);
	sceGuScissor(0, 0, SCR_WIDTH, SCR_HEIGHT);
	sceGuEnable(GU_SCISSOR_TEST);
	sceGuDepthFunc(GU_GEQUAL);
	sceGuEnable(GU_DEPTH_TEST);
	sceGuFrontFace(GU_CW);
	sceGuShadeModel(GU_SMOOTH);
	sceGuEnable(GU_CULL_FACE);
	sceGuEnable(GU_TEXTURE_2D);
	sceGuEnable(GU_CLIP_PLANES);
	sceGuFinish();
	sceGuSync(0,0);

	sceDisplayWaitVblankStart();
	sceGuDisplay(GU_TRUE);

	// run sample

	int val = 0;

	while (running) {
		sceGuStart(GU_DIRECT, &list);

		// clear screen

		sceGuClearColor(0xff554433);
		sceGuClearDepth(0);
		sceGuClear(GU_COLOR_BUFFER_BIT | GU_DEPTH_BUFFER_BIT);

		// setup matrices for cube

		sceGumMatrixMode(GU_PROJECTION);
		sceGumLoadIdentity();
		sceGumPerspective(75.0f, 16.0f / 9.0f, 0.5f, 1000.0f);

		sceGumMatrixMode(GU_VIEW);
		sceGumLoadIdentity();

		sceGumMatrixMode(GU_MODEL);
		sceGumLoadIdentity();
		{
			ScePspFVector3 pos = { 0, 0, -2.5f };
			ScePspFVector3 rot = {
				val * 0.79f * (GU_PI / 180.0f),
				val * 0.98f * (GU_PI / 180.0f),
				val * 1.32f * (GU_PI / 180.0f)
			};
			sceGumTranslate(&pos);
			sceGumRotateXYZ(&rot);
		}

		// setup texture

		sceGuTexMode(GU_PSM_4444, 0, 0, 0);
		sceGuTexImage(0, 64, 64, 64, logo_start.ptr);
		sceGuTexFunc(GU_TFX_ADD, GU_TCC_RGB);
		sceGuTexEnvColor(0xffff00);
		sceGuTexFilter(GU_LINEAR, GU_LINEAR);
		sceGuTexScale(1.0f, 1.0f);
		sceGuTexOffset(0.0f, 0.0f);
		sceGuAmbientColor(0xffffffff);

		// draw cube

		sceGumDrawArray(GU_TRIANGLES, GU_TEXTURE_32BITF | GU_COLOR_8888 | GU_VERTEX_32BITF | GU_TRANSFORM_3D, 12 * 3, null, &vertices);

		sceGuFinish();
		sceGuSync(0, 0);

		sceDisplayWaitVblankStart();
		sceGuSwapBuffers();

		val++;
	}

	sceGuTerm();

	sceKernelExitGame();
	return 0;
}
