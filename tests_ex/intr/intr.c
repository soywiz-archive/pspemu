//#pragma compile, "%PSPSDK%/bin/psp-gcc" -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g intr.c ../common/emits.c -lpspsdk -lc -lpspuser -lpspkernel -lpsprtc -o intr.elf
//#pragma compile, "%PSPSDK%/bin/psp-fixup-imports" intr.elf

#include <pspkernel.h>
#include <psprtc.h>

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

#include "../common/emits.h"
#include <pspintrman.h>

PSP_MODULE_INFO("intrtest", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);

// http://forums.ps2dev.org/viewtopic.php?t=5687
// @TODO! Fixme! In which thread should handlers be executed?

void vblank_handler_counter(int no, int* counter) {
	*counter = *counter + 1;
}

void checkVblankInterruptHandler() {
	int counter = 0, last_counter = 0;

	sceKernelRegisterSubIntrHandler(PSP_VBLANK_INT, 0, vblank_handler_counter, &counter);
	sceKernelDelayThread(80000);
	emitInt(counter); // 0. Not enabled yet.
	
	sceKernelEnableSubIntr(PSP_VBLANK_INT, 0);
	sceKernelDelayThread(160000);
	emitInt(counter >= 2); // n. Already enabled.

	sceKernelReleaseSubIntrHandler(PSP_VBLANK_INT, 0);
	last_counter = counter;
	sceKernelDelayThread(80000);
	emitInt(last_counter == counter); // n. Disabled.
}

int main() {
	checkVblankInterruptHandler();

	return 0;
}