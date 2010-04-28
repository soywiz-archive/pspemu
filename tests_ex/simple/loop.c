//#pragma compile, "%PSPSDK%/bin/psp-gcc" -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g loop.c common/emits.c common/vram.c -lpspgum -lpspgu -lm -lpsprtc -lpspdebug -lpspdisplay -lpspge -lpspsdk -lc -lpspuser -lpspkernel -o loop.elf
//#pragma compile, "%PSPSDK%/bin/psp-fixup-imports" loop.elf

#include <pspkernel.h>
#include <pspdisplay.h>
#include <pspdebug.h>
#include <stdlib.h>
#include <pspctrl.h>
#include <pspgu.h>
#include <pspgum.h>

PSP_MODULE_INFO("Loop test", 0, 1, 1);

int main(int argc, char* argv[]) {
	unsigned char *buffer = 0x04000000;
	unsigned char v = 0;
	int n;
	
	while (1) {
		for (n = 0; n < 512 * 272 * 4; n++) {
			buffer[n] = v;
		}
		v++;
		sceDisplayWaitVblankStart();
	}

	return 0;
}