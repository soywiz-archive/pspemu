/*
FPU Test. Originally from jpcsp project:
http://code.google.com/p/jpcsp/source/browse/trunk/demos/src/fputest/main.c
Modified to perform automated tests.
*/

//#pragma compile, "%PSPSDK%/bin/psp-gcc" -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g prefixes.c ../common/emits.c -lpspsdk -lc -lpspuser -lpspkernel -o prefixes.elf
//#pragma compile, "%PSPSDK%/bin/psp-fixup-imports" prefixes.elf

#include <pspkernel.h>
#include <stdio.h>
#include <string.h>
#include "../common/emits.h"

PSP_MODULE_INFO("vfpu test", 0, 1, 1);

PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER | PSP_THREAD_ATTR_VFPU);

int main(int argc, char *argv[]) {

	return 0;
}