#pragma compile, "%PSPSDK%/bin/psp-gcc" -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g line.c ../common/emits.c ../common/vram.c -lpspgum -lpspgu -lm -lpsprtc -lpspdebug -lpspdisplay -lpspge -lpspsdk -lc -lpspuser -lpspkernel -o line.elf
#pragma compile, "%PSPSDK%/bin/psp-fixup-imports" line.elf

#include <pspkernel.h>
#include <pspdisplay.h>
#include <pspdebug.h>
#include <stdlib.h>
#include <pspctrl.h>
#include <pspgu.h>
#include <pspgum.h>

#include "../common/vram.h"
#include "../common/emits.h"

PSP_MODULE_INFO("Test Line Drawing", 0, 1, 1);

static unsigned int __attribute__((aligned(16))) list[262144];

struct Vertex { float x, y, z; };

struct Vertex __attribute__((aligned(16))) vertices[2] = {
       {  0.0f,   0.0f, 0.0f},
       {480.0f, 272.0f, 0.0f},
};

#define BUF_WIDTH (512)
#define SCR_WIDTH (480)
#define SCR_HEIGHT (272)

int main(int argc, char* argv[]) {
   void* frameBufferPointer = getStaticVramBuffer(BUF_WIDTH, SCR_HEIGHT, GU_PSM_8888);
   void* depthBufferPointer = getStaticVramBuffer(BUF_WIDTH, SCR_HEIGHT, GU_PSM_4444);

   sceGuInit();

   sceGuStart(GU_DIRECT, list);
   {
      sceGuDrawBuffer(GU_PSM_8888, frameBufferPointer, BUF_WIDTH);
      sceGuDispBuffer(SCR_WIDTH, SCR_HEIGHT, frameBufferPointer, BUF_WIDTH);
      sceGuDepthBuffer(depthBufferPointer, BUF_WIDTH);
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

   sceGuDisplay(1);

   {
      sceGuStart(GU_DIRECT,list);
      {
         sceGuClearColor(0);
         sceGuClearDepth(0);
         sceGuClear(GU_COLOR_BUFFER_BIT | GU_DEPTH_BUFFER_BIT);

         sceGumMatrixMode(GU_PROJECTION); sceGumLoadIdentity();
         sceGumMatrixMode(GU_VIEW); sceGumLoadIdentity();
         sceGumMatrixMode(GU_MODEL); sceGumLoadIdentity();

         sceGuColor(0xFFFFFFFF);

         sceGumDrawArray(GU_LINES, GU_VERTEX_32BITF | GU_TRANSFORM_2D, 2, 0, vertices);
      }
      sceGuFinish();
      sceGuSync(0, 0);
   }

   // It will check the contents of the frameBuffer.
   emitMemoryBlock((void *)((unsigned int)frameBufferPointer | 0x04000000), SCR_WIDTH * SCR_HEIGHT * 4);
   
   sceGuTerm();
   sceKernelExitGame();
   return 0;
}
