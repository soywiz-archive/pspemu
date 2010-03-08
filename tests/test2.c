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

PSP_MODULE_INFO("Test2", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);

#define assert(v) { if (!(v)) { asm("break"); } }
void emitInt   (int   v) { asm("syscall 0x2308"); }
void emitFloat (float v) { asm("syscall 0x2309"); }
void emitString(char *v) { asm("syscall 0x230A"); }

int main(int argc, char* argv[]) {
	int table[] = {8, 10, 12};
	int n;
	float x = 0;

	emitFloat(x);
	for (n = 0; n < sizeof(table) / sizeof(table[0]); n++) {
		x += table[n];
		emitFloat(x);
	}

	return 0;
}