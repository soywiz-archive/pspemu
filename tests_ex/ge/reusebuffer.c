//#pragma compile, "%PSPSDK%/bin/psp-gcc" -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g reusebuffer.c ../common/emits.c ../common/vram.c -lpspgum -lpspgu -lm -lpsprtc -lpspdebug -lpspdisplay -lpspge -lpspsdk -lc -lpspuser -lpspkernel -o reusebuffer.elf
//#pragma compile, "%PSPSDK%/bin/psp-fixup-imports" reusebuffer.elf

#include <pspkernel.h>
#include <pspdisplay.h>
#include <pspdebug.h>
#include <stdlib.h>
#include <pspctrl.h>
#include <pspgu.h>
#include <pspgum.h>

#include "../common/vram.h"
#include "../common/emits.h"

PSP_MODULE_INFO("Test Reuse Buffer", 0, 1, 1);

static unsigned int __attribute__((aligned(16))) list[262144];

struct Vertex { unsigned short x, y, z; };

struct Vertex __attribute__((aligned(16))) vertices[] = {
       {1, 0, 0},
};

#define BUF_WIDTH (512)
#define SCR_WIDTH (480)
#define SCR_HEIGHT (272)

void* convertGeToMemoryAddress(void *ptr) {
	return (void *)((unsigned int)ptr | 0x04000000);
}

int main(int argc, char* argv[]) {
	void* frameBufferPointer = getStaticVramBuffer(BUF_WIDTH, SCR_HEIGHT, GU_PSM_8888);
	int row = 0, col = 0;

	sceGuInit();
	
	sceGuDisplay(0);

	sceGuStart(GU_DIRECT, list);
	{
		sceGuDrawBuffer(GU_PSM_8888, frameBufferPointer, BUF_WIDTH);
		sceGuDispBuffer(SCR_WIDTH, SCR_HEIGHT, frameBufferPointer, BUF_WIDTH);
		sceGuOffset(2048 - (SCR_WIDTH / 2), 2048 - (SCR_HEIGHT / 2));
		sceGuViewport(2048, 2048, SCR_WIDTH, SCR_HEIGHT);
		sceGuDepthRange(65535, 0);
		sceGuScissor(0, 0, SCR_WIDTH, SCR_HEIGHT);
		sceGuEnable(GU_SCISSOR_TEST);
		sceGuFrontFace(GU_CW);
		sceGuShadeModel(GU_SMOOTH);
		sceGuDisable(GU_TEXTURE_2D);
	}
	sceGuFinish();
	sceGuSync(0, 0);

	{
		sceGuStart(GU_DIRECT, list);
		{
			sceGuClearColor(0);
			sceGuClearDepth(0);
			sceGuClear(GU_COLOR_BUFFER_BIT | GU_DEPTH_BUFFER_BIT);
		}
		sceGuFinish();
		sceGuSync(0, 0);
	}

	sceGuDisplay(1);

	for (row = 0; row < 3; row++) {
		(((unsigned int *)convertGeToMemoryAddress(frameBufferPointer)) + 512 * row)[0] = 0xFF0000FF;
		// Draw a Pixel
		{
			sceGuStart(GU_DIRECT, list);
			{
				sceGuColor(0xFF00FF00);
				sceGumDrawArray(GU_POINTS, GU_VERTEX_16BIT | GU_TRANSFORM_2D, 1, 0, vertices);
			}
			sceGuFinish();
			sceGuSync(0, 0);
		}
		(((unsigned int *)convertGeToMemoryAddress(frameBufferPointer)) + 512 * row)[2] = 0xFFFF0000;
		vertices[0].y++;
	}

	// It will check the contents of the frameBuffer.
	for (row = 0; row < 4; row++) {
		unsigned int *rowp = ((unsigned int *)convertGeToMemoryAddress(frameBufferPointer)) + 512 * row;
		for (col = 0; col < 4; col++) {
			emitHex(rowp + col, 4);
		}
	}

	sceGuTerm();
	sceKernelExitGame();
	return 0;
}
