/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * Copyright (c) 2005 Jesper Svennevid
 */

import pspsdk.all;

import std.c.stdlib;
import std.c.time;
import std.c.math;

version (BUILD_INFO) {
	pragma(MODULE_NAME, "Lines Sample");
	pragma(PSP_EBOOT_TITLE, "Lines Sample");
	pragma(PSP_MAIN_THREAD_ATTR, THREAD_ATTR_USER);
	pragma(PSP_FW_VERSION, 150);
}

align (16) uint list[262144];

struct Vertex {
	float x = 0.0, y = 0.0, z = 0.0;
	
	char[] toString() { return std.string.format("Vertex(%f, %f, %f)", x, y, z); }
}

static const uint BUF_WIDTH = (512);
static const uint SCR_WIDTH = (480);
static const uint SCR_HEIGHT = (272);

static const uint NUM_SLICES = 128;
static const uint NUM_ROWS = 128;
static const float RING_SIZE = 2.0f;
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

static const uint NUM_LINES = 12;
static const uint NUM_VERTICES = 8;
static const float SPEED = 4.0f;
static const float FADE_SPEED = 0.015f;

Vertex lines[NUM_LINES][NUM_VERTICES];
uint curr_line = 0;
Vertex position[NUM_VERTICES];
Vertex direction[NUM_VERTICES];

float fade = 0;
uint color_index = 0;

int rand_between(int min, int max) {
	return min + rand() % (max - min);
}

float randf_between(float min = 0.0, float max = 1.0) {
	float v = ((cast(float)rand()) / RAND_MAX);
	return min + v * (max - min);
}

int main(char[][] args) {
	SetupCallbacks();
	
	// initialize lines
	srand(time(null));

	for (uint i = 0; i < position.length; ++i) {
		position[i].x = randf_between(0, SCR_WIDTH - 1);
		position[i].y = randf_between(0, SCR_HEIGHT - 1);
		//emit(position[i].x);
		//emit(position[i].y);

		direction[i].x = randf_between(-1.0, +1.0) * SPEED;
		direction[i].y = randf_between(-1.0, +1.0) * SPEED;
	}

	// setup GU

	void* fbp0 = getStaticVramBuffer(BUF_WIDTH, SCR_HEIGHT, GU_PSM_8888);
	void* fbp1 = getStaticVramBuffer(BUF_WIDTH, SCR_HEIGHT, GU_PSM_8888);
	void* zbp  = getStaticVramBuffer(BUF_WIDTH, SCR_HEIGHT, GU_PSM_4444);

	sceGuInit();

	sceGuStart(GU_DIRECT, &list);
	sceGuDrawBuffer(GU_PSM_8888,fbp0,BUF_WIDTH);
	sceGuDispBuffer(SCR_WIDTH,SCR_HEIGHT,fbp1,BUF_WIDTH);
	sceGuDepthBuffer(zbp,BUF_WIDTH);
	sceGuOffset(2048 - (SCR_WIDTH/2),2048 - (SCR_HEIGHT/2));
	sceGuViewport(2048,2048,SCR_WIDTH,SCR_HEIGHT);
	sceGuDepthRange(65535,0);
	sceGuScissor(0,0,SCR_WIDTH,SCR_HEIGHT);
	sceGuEnable(GU_SCISSOR_TEST);
	sceGuFinish();
	sceGuSync(0,0);

	sceDisplayWaitVblankStart();
	sceGuDisplay(GU_TRUE);

	// run sample

	while (running) {
		// update lines

		for (uint i = 0; i < NUM_VERTICES; ++i)
		{
			position[i].x += direction[i].x;
			position[i].y += direction[i].y;

			if (position[i].x < 0)
			{
				position[i].x = 0;
				direction[i].x = randf_between() * SPEED;
				direction[i].y += 0.1f * (direction[i].y / fabsf(direction[i].y));
			}
			else if (position[i].x >= SCR_WIDTH)
			{
				position[i].x = (SCR_WIDTH-1);
				direction[i].x = -randf_between() * SPEED;
				direction[i].y += 0.1f * (direction[i].y / fabsf(direction[i].y));
			}

			if (position[i].y < 0)
			{
				position[i].y = 0;
				direction[i].x += 0.1f * (direction[i].x / fabsf(direction[i].x));
				direction[i].y = (0.1f + randf_between()) * SPEED;
			}
			else if (position[i].y >= SCR_HEIGHT)
			{
				position[i].y = (SCR_HEIGHT-1);
				direction[i].x += 0.1f * (direction[i].x / fabsf(direction[i].x));
				direction[i].y = -(0.1f + randf_between()) * SPEED;
			}

			lines[curr_line][i].x = position[i].x;
			lines[curr_line][i].y = position[i].y;
		}
		curr_line = (curr_line+1) % NUM_LINES;
		
		fade += FADE_SPEED;
		if (fade >= 1.0f)
		{
			fade -= 1.0f;
			color_index = (color_index+1) & 7;
		}

		sceGuStart(GU_DIRECT, &list);

		// clear screen

		sceGuClearColor(0);
		sceGuClear(GU_COLOR_BUFFER_BIT);

		// render lines

		uint result = 0;
		for (uint i = 0; i < 4; ++i)
		{
			int ca = (colors[color_index] >> (i*8)) & 0xff;
			int cb = (colors[(color_index+1)&7] >> (i*8)) & 0xff;
			result |= (cast(ubyte)(ca + (cb-ca) * fade)) << (i*8);
		}
		
		sceGuColor(result);

		for (uint i = 0; i < NUM_LINES; i++) {
			// we make local copies of the line into the main buffer here, so we don't have to flush the cache

			Vertex* vertices = cast(Vertex*)sceGuGetMemory((NUM_VERTICES + 1) * Vertex.sizeof);

			// create a lineloop

			for (uint j = 0; j < NUM_VERTICES; j++) {
				vertices[j] = lines[i][j];
				//emit(vertices[j].toString);
				//emit(vertices[j].x);
			}
			vertices[NUM_VERTICES] = lines[i][0];
			
			//emitHex(vertices, 1024);
		
			sceGuDrawArray(GU_LINE_STRIP, GU_VERTEX_32BITF | GU_TRANSFORM_2D, (NUM_VERTICES + 1), null, vertices);
		}

		// wait for next frame

		sceGuFinish();
		sceGuSync(0,0);

		sceDisplayWaitVblankStart();
		sceGuSwapBuffers();
	}

	sceGuTerm();

	sceKernelExitGame();
	return 0;
}
