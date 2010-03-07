#include <pspkernel.h>
#include <pspdisplay.h>
#include <pspdebug.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
//#include <assert.h>

#include <pspctrl.h>
#include <pspgu.h>
#include <psprtc.h>

PSP_MODULE_INFO("Test1", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);

#define assert(v) { if (!(v)) { asm("break"); } }
void emitInt(int v) {
	//asm("syscall 0x2308");
}
void emitFloat(float f) {
	//asm("syscall 0x2309");
}

void testIntegerSum() {
	int n, sum = 0;
	for (n = -50; n < 100; n++) sum += n;
	assert(sum == 3675);
	assert(n == 100);
	emitInt(sum);
	emitInt(n);
}

int main(int argc, char* argv[]) {
	float f = 1.0;
	pspDebugScreenInit();
	//setupCallbacks();

	testIntegerSum();
	emitFloat(0.1);
	emitFloat(f);
	
	while (1) {
		sceDisplayWaitVblankStart();
		//pspDebugScreenSetXY(0, 0);
		pspDebugScreenPrintf("Hola %f!\r", f);
		f += 0.1;
	}
	return 0;
}