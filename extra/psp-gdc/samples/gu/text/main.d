/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * Copyright (c) 2006 McZonk (mczonk@teamemergencyexit.com)
 *
 * Simple example for drawing text with the gu
 *
 */

import pspsdk.all;
import std.string;
import std.math;
import std.c.math;

auto font = import("font.raw");

version (BUILD_INFO) {
	pragma(MODULE_NAME, "GuText Sample");
	pragma(PSP_EBOOT_TITLE, "GuText Sample");
	pragma(PSP_MAIN_THREAD_ATTR, THREAD_ATTR_USER);
	pragma(PSP_FW_VERSION, 150);
}

align(16) static uint list[262144];

static int fontwidthtab[128] = [
	10, 10, 10, 10, 
	10, 10, 10, 10,
	10, 10, 10, 10, 
	10, 10, 10, 10,

	10, 10, 10, 10, 
	10, 10, 10, 10,
	10, 10, 10, 10,
	10, 10, 10, 10,

	10,  6,  8, 10, //   ! " #
	10, 10, 10,  6, // $ % & '
	10, 10, 10, 10, // ( ) * +
	 6, 10,  6, 10, // , - . /

	10, 10, 10, 10, // 0 1 2 3
	10, 10, 10, 10, // 6 5 8 7
	10, 10,  6,  6, // 10 9 : ;
	10, 10, 10, 10, // < = > ?

	16, 10, 10, 10, // @ A B C
	10, 10, 10, 10, // D E F G
	10,  6,  8, 10, // H I J K
	 8, 10, 10, 10, // L M N O

	10, 10, 10, 10, // P Q R S
	10, 10, 10, 12, // T U V W
	10, 10, 10, 10, // X Y Z [
	10, 10,  8, 10, // \ ] ^ _

	 6,  8,  8,  8, // ` a b c
	 8,  8,  6,  8, // d e f g
	 8,  6,  6,  8, // h i j k
	 6, 10,  8,  8, // l m n o

	 8,  8,  8,  8, // p q r s
	 8,  8,  8, 12, // t u v w
	 8,  8,  8, 10, // x y z {
	 8, 10,  8, 12  // | } ~  
];

static const int BUF_WIDTH = (512);
static const int SCR_WIDTH = (480);
static const int SCR_HEIGHT = (272);
static const int PIXEL_SIZE = (4);
static const int FRAME_SIZE = (BUF_WIDTH * SCR_HEIGHT * PIXEL_SIZE);

/*
	This function draws a string on the screen
	The chars are handled as sprites.
	It supportes colors and blending.
	The fontwidth can be selected with the parameter fw, if it is 0 the best width for each char is selected.
*/
void drawString(char[] text, int x, int y, uint color, int fw) {
	if (!text.length) return;

	struct VERT {
		float s, t;
		uint c;
		float x, y, z;
	}

	auto v = cast(VERT *)sceGuGetMemory(VERT.sizeof * 2 * text.length);

	for (int i = 0; i < text.length; i++) {
		ubyte c = cast(ubyte)text[i];
		if (c < 32) {
			c = 0;
		} else if(c >= 128) {
			c = 0;
		}

		int tx = (c & 0x0F) << 4;
		int ty = (c & 0xF0);

		VERT* v0 = &v[i*2+0];
		VERT* v1 = &v[i*2+1];
		
		v0.s = cast(float)(tx + (fw ? ((16 - fw) >> 1) : ((16 - fontwidthtab[c]) >> 1)));
		v0.t = cast(float)(ty);
		v0.c = color;
		v0.x = cast(float)(x);
		v0.y = cast(float)(y);
		v0.z = 0.0f;

		v1.s = cast(float)(tx + 16 - (fw ? ((16 - fw) >> 1) : ((16 - fontwidthtab[c]) >> 1)));
		v1.t = cast(float)(ty + 16);
		v1.c = color;
		v1.x = cast(float)(x + (fw ? fw : fontwidthtab[c]));
		v1.y = cast(float)(y + 16);
		v1.z = 0.0f;

		x += (fw ? fw : fontwidthtab[c]);
	}

	sceGumDrawArray(GU_SPRITES, 
		GU_TEXTURE_32BITF | GU_COLOR_8888 | GU_VERTEX_32BITF | GU_TRANSFORM_2D,
		text.length * 2, null, v
	);
}

int main(char[][] args) {
	SetupCallbacks();

	sceGuInit();
	sceGuStart(GU_DIRECT, &list);
	sceGuDrawBuffer(GU_PSM_8888, cast(void*)0, BUF_WIDTH);
	sceGuDispBuffer(SCR_WIDTH, SCR_HEIGHT, cast(void*)0x88000, BUF_WIDTH);
	sceGuDepthBuffer(cast(void*)0x110000, BUF_WIDTH);
	sceGuOffset(2048 - (SCR_WIDTH / 2),2048 - (SCR_HEIGHT / 2));
	sceGuViewport(2048, 2048, SCR_WIDTH, SCR_HEIGHT);
	sceGuDepthRange(0xc350, 0x2710);
	sceGuScissor(0, 0, SCR_WIDTH, SCR_HEIGHT);
	sceGuEnable(GU_SCISSOR_TEST);
	sceGuDisable(GU_DEPTH_TEST);
	sceGuShadeModel(GU_SMOOTH);
	sceGuEnable(GU_BLEND);
	sceGuBlendFunc(GU_ADD, GU_SRC_ALPHA, GU_ONE_MINUS_SRC_ALPHA, 0, 0);
	sceGuEnable(GU_TEXTURE_2D);
	sceGuTexMode(GU_PSM_8888, 0, 0, 0);
	sceGuTexImage(0, 256, 128, 256, &font);
	sceGuTexFunc(GU_TFX_MODULATE, GU_TCC_RGBA);
	sceGuTexEnvColor(0x0);
	sceGuTexOffset(0.0f, 0.0f);
	sceGuTexScale(1.0f / 256.0f, 1.0f / 128.0f);
	sceGuTexWrap(GU_REPEAT, GU_REPEAT);
	sceGuTexFilter(GU_NEAREST, GU_NEAREST);
	sceGuFinish();
	sceGuSync(0, 0);
	sceGuDisplay(GU_TRUE);

	while (running) {
		sceGuStart(GU_DIRECT, &list);
		sceGuClear(GU_COLOR_BUFFER_BIT);

		/*
			No matrixes are needed because the font is drawn with GU_TRANSFORM_2D
		*/

		drawString("Hello World in red",   0,  0, 0xFF0000FF, 0);
		drawString("Hello World in green", 0, 16, 0xFF00FF00, 0);
		drawString("Hello World in blue",  0, 32, 0xFFFF0000, 0);

		drawString("Hello World with free char width",     0, 64, 0xFFFFFFFF, 0);
		drawString("Hello World with block char width 10", 0, 80, 0xFFFFFFFF, 10);
		drawString("Hello World with block char width 12", 0, 96, 0xFFFFFFFF, 12);

		drawString("Hello World with opacity 100%", 0, 128, 0xFFFFFFFF, 0);
		drawString("Hello World with opacity  50%", 0, 144, 0x7FFFFFFF, 0);
		drawString("Hello World with opacity  10%", 0, 160, 0x18FFFFFF, 0);

		drawString("Hello World with shadow", 2, 194, 0x40FFFFFF, 0);
		drawString("Hello World with shadow", 0, 192, 0xFFFFFFFF, 0);

		static float t = 0.0f;
		t += 0.1f;

		uint c = 0xFF000000 |
			cast(uint)((sinf(t * 0.393f + 0.086f) / 2.0f + 0.5f) * 255.0f) << 16 |
			cast(uint)((sinf(t * 0.444f + 0.854f) / 2.0f + 0.5f) * 255.0f) <<  8 |
			cast(uint)((sinf(t * 0.117f + 1.337f) / 2.0f + 0.5f) * 255.0f) <<  0;

		drawString("Hello World from pspdev", 0, 224, c, 0);

		sceGuFinish();
		sceGuSync(0, 0);

		sceDisplayWaitVblankStart();
		sceGuSwapBuffers();
	}

	sceGuDisplay(GU_FALSE);
	sceGuTerm();

	return 0;
}
