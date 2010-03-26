#include <pspkernel.h>
#include <pspdisplay.h>
#include <pspdebug.h>
#include <stdlib.h>
#include <pspctrl.h>
#include <pspgu.h>
#include <pspgum.h>
#include <stdio.h>

#include "common/callbacks.h"
#include "common/vram.h"

PSP_MODULE_INFO("MYTEST", 0, 1, 1);

int testArgThread = 999;

static int threadTest(int args, void *argp) {
	pspDebugScreenPrintf("threadTest: %d, 0x%p\n", args, argp);
	pspDebugScreenPrintf("%d\n", *(int *)argp);
	return 0;
}

int main(int argc, char* argv[]) {
	int n;
	pspDebugScreenInit();
	setupCallbacks();
	
	{
		FILE* f = fopen("ms0:/prueba.txt", "wb");
		fprintf(f, "Hola!\n");
		fclose(f);
	}
	
	pspDebugScreenPrintf("sceKernelCreateThread+sceKernelStartThread\n");
	sceKernelStartThread(
		sceKernelCreateThread(
			"testThread",
			(void*)&threadTest,
			0x12,
			0x10000,
			0,
			NULL
		),
		1,
		&testArgThread
	);
 
	pspDebugScreenPrintf("Program started\n");
	for (n = 1; n < 10; n++) {
		sceKernelDelayThread(1000000);
		pspDebugScreenPrintf("Elapsed %d seconds\n", n);
	}
 
	sceKernelExitGame();
	return 0;
}
