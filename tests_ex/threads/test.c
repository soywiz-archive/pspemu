//#pragma compile, "%PSPSDK%/bin/psp-gcc" -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g -O0 test.c ../common/emits.c -lpspsdk -lc -lpspuser -lpspkernel -o test.elf
//#pragma compile, "%PSPSDK%/bin/psp-fixup-imports" test.elf

#include <pspkernel.h>
#include <pspthreadman.h>
#include <../common/emits.h>

PSP_MODULE_INFO("THREAD TEST", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER | THREAD_ATTR_VFPU);

int pointer;

void threadFunction(int args, void* argp) {
	int *ptr = &pointer;
	while (1) {
		sceKernelDelayThread(1000);
		ptr = 0;
	}
}

void threadFunction2(int args, void* argp) {
	int *ptr = &pointer;
	//sceKernelDelayThread(1000);
	while (1) {
		*ptr = *ptr + 1;
		sceKernelDelayThread(0);
	}
}

int main(int argc, char** argv) {
	int n;
	sceKernelStartThread(
		sceKernelCreateThread("Test Thread", (void *)&threadFunction, 0x12, 0x10000, 0, NULL),
		0, NULL
	);
	sceKernelStartThread(
		sceKernelCreateThread("Test Thread", (void *)&threadFunction2, 0x12, 0x10000, 0, NULL),
		0, NULL
	);
	for (n = 0; n < 10; n++) {
		asm volatile("addi $2, $0, 0");
		sceKernelDelayThread(1000);
	}
	emitInt(1);
	sceKernelExitGame();
	return 0;
}