#include <pspkernel.h>
#include <pspdisplay.h>
#include <pspdebug.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

#include <pspctrl.h>
#include <pspgu.h>
#include <psprtc.h>

PSP_MODULE_INFO("Test1", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);

int main(int argc, char* argv[]) {
	int n = 0;
	pspDebugScreenInit();
	//setupCallbacks();
	
	while (1) {
		sceDisplayWaitVblankStart();
		pspDebugScreenSetXY(0, 0);
		pspDebugScreenPrintf("Hola %f!\n", (float)n);
		n++;
	}
	return 0;
}