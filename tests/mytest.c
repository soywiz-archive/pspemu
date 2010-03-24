#include <pspkernel.h>
#include <pspdisplay.h>
#include <pspdebug.h>
#include <stdlib.h>
#include <pspctrl.h>
#include <pspgu.h>
#include <pspgum.h>

#include "common/callbacks.h"
#include "common/vram.h"

PSP_MODULE_INFO("MYTEST", 0, 1, 1);

int main(int argc, char* argv[]) {
	int n;
	pspDebugScreenInit();
	setupCallbacks();
 
	pspDebugScreenPrintf("Program started\n");
	for (n = 1; n < 10; n++) {
		sceKernelDelayThread(1000000);
		pspDebugScreenPrintf("Elapsed %d seconds\n", n);
	}
 
	sceKernelExitGame();
	return 0;
}
