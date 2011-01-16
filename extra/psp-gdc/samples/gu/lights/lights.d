/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * Copyright (c) 2005 Jesper Svennevid
 */

import pspsdk.all;
import pspsdk.utils.geometry;
import std.string;
import std.math;
import std.c.math;

version (BUILD_INFO) {
	pragma(MODULE_NAME, "Lights Sample");
	pragma(PSP_EBOOT_TITLE, "Lights Sample");
	pragma(PSP_MAIN_THREAD_ATTR, THREAD_ATTR_USER);
	pragma(PSP_FW_VERSION, 150);
}

align(16) static uint list[262144];

static const uint BUF_WIDTH = (512);
static const uint SCR_WIDTH = (480);
static const uint SCR_HEIGHT = (272);

static const uint GRID_COLUMNS = 32;
static const uint GRID_ROWS = 32;
static const float GRID_SIZE = 10.0f;

align(16) NPVertex grid_vertices[GRID_COLUMNS * GRID_ROWS];
align(16) ushort grid_indices[(GRID_COLUMNS - 1) * (GRID_ROWS - 1) * 6];

static const uint TORUS_SLICES = 48; // numc
static const uint TORUS_ROWS = 48; // numt
static const float TORUS_RADIUS = 1.0f;
static const float TORUS_THICKNESS = 0.5f;

static const float LIGHT_DISTANCE = 3.0f;

align (16) NPVertex torus_vertices[TORUS_SLICES * TORUS_ROWS];
align (16) ushort torus_indices[TORUS_SLICES * TORUS_ROWS * 6];

uint colors[4] = [
	0xffff0000,
	0xff00ff00,
	0xff0000ff,
	0xffff00ff
];

int main(char[][] args) {
	SetupCallbacks();

	// generate geometry

	generateGridNP(GRID_COLUMNS, GRID_ROWS, GRID_SIZE, GRID_SIZE, grid_vertices.ptr, grid_indices.ptr);
	generateTorusNP(TORUS_SLICES, TORUS_ROWS, TORUS_RADIUS, TORUS_THICKNESS, torus_vertices.ptr, torus_indices.ptr);

	// flush cache so that no stray data remains

	sceKernelDcacheWritebackAll();

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
	sceGuDepthRange(0xc350, 0x2710);
	sceGuScissor(0, 0, SCR_WIDTH, SCR_HEIGHT);
	sceGuEnable(GU_SCISSOR_TEST);
	sceGuDepthFunc(GU_GEQUAL);
	sceGuEnable(GU_DEPTH_TEST);
	sceGuFrontFace(GU_CW);
	sceGuShadeModel(GU_SMOOTH);
	sceGuEnable(GU_CULL_FACE);
	sceGuEnable(GU_CLIP_PLANES);
	sceGuEnable(GU_LIGHTING);
	sceGuEnable(GU_LIGHT0);
	sceGuEnable(GU_LIGHT1);
	sceGuEnable(GU_LIGHT2);
	sceGuEnable(GU_LIGHT3);
	sceGuFinish();
	sceGuSync(0, 0);
	sceDisplayWaitVblankStart();
	sceGuDisplay(GU_TRUE);

	// run sample

	int val = 0;

	while (running)
	{
		sceGuStart(GU_DIRECT, &list);

		// clear screen

		sceGuClearColor(0x554433);
		sceGuClearDepth(0);
		sceGuClear(GU_COLOR_BUFFER_BIT|GU_DEPTH_BUFFER_BIT);

		// setup a light
	
		for (int i = 0; i < 4; ++i) {
			ScePspFVector3 pos = void;
			{
				pos.x = cosf(i * (GU_PI / 2) + val * (GU_PI / 180)) * LIGHT_DISTANCE;
				pos.y = 0;
				pos.z = sinf(i * (GU_PI / 2) + val * (GU_PI / 180)) * LIGHT_DISTANCE;
			}
			sceGuLight(i, GU_POINTLIGHT, GU_DIFFUSE_AND_SPECULAR, &pos);
			sceGuLightColor(i, GU_DIFFUSE, colors[i]);
			sceGuLightColor(i, GU_SPECULAR, 0xffffffff);
			sceGuLightAtt(i, 0.0f, 1.0f, 0.0f);
		}

		sceGuSpecular(12.0f);
		sceGuAmbient(0x00222222);

		// setup matrices for cube

		sceGumMatrixMode(GU_PROJECTION);
		sceGumLoadIdentity();
		sceGumPerspective(75.0f, 16.0f / 9.0f, 1.0f, 1000.0f);

		sceGumMatrixMode(GU_VIEW);
		{
			ScePspFVector3 pos = {0, 0, -3.5f};

			sceGumLoadIdentity();
			sceGumTranslate(&pos);
		}

		// draw grid

		sceGumMatrixMode(GU_MODEL);
		{
			ScePspFVector3 pos = {0, -1.5f, 0};

			sceGumLoadIdentity();
			sceGumTranslate(&pos);
		}

		sceGuColor(0xff7777);
		sceGumDrawArray(GU_TRIANGLES, NPVertex.FORMAT | GU_INDEX_16BIT | GU_TRANSFORM_3D, grid_indices.length, &grid_indices, &grid_vertices);

		// draw torus

		sceGumMatrixMode(GU_MODEL);
		{
			ScePspFVector3 rot = {
				val * 0.79f * (GU_PI / 180.0f),
				val * 0.98f * (GU_PI / 180.0f),
				val * 1.32f * (GU_PI / 180.0f)
			};

			sceGumLoadIdentity();
			sceGumRotateXYZ(&rot);
		}

		sceGuColor(0xffffff);
		sceGumDrawArray(GU_TRIANGLES, NPVertex.FORMAT | GU_INDEX_16BIT | GU_TRANSFORM_3D, torus_indices.length, &torus_indices, &torus_vertices);

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
