/**
 * This demo tests that sceKernelStartThread is scheduled immediately and can access the parent stack without have been modified.
 * This feature is used in pspaudio library and probably in a lot of games.
 *
 * It checks also the correct behaviour of semaphores: sceKernelCreateSema, sceKernelSignalSema and sceKernelWaitSema.
 *
 * If new threads are not executed immediately, it would output: 2, 2, -1.
 * It's expected to output 0, 1, -1.
 */
//#pragma compile, "%PSPSDK%/bin/psp-gcc" -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g thread_start.c ../common/emits.c -lpspsdk -lc -lpspuser -lpspkernel -o thread_start.elf
//#pragma compile, "%PSPSDK%/bin/psp-fixup-imports" thread_start.elf

#include <pspkernel.h>
#include <pspthreadman.h>
#include <../common/emits.h>

PSP_MODULE_INFO("THREAD TEST", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER | THREAD_ATTR_VFPU);

static int semaphore = 0;

static int threadFunction(int args, void* argp) {
	int local_value = *(int *)argp;

	emitInt(local_value);

	sceKernelSignalSema(semaphore, 1);
	
	return 0;
}

int main() {
	int n;

	// Create a semaphore for waiting both threads to execute.
	semaphore = sceKernelCreateSema("Semaphore", 0, 0, 2, NULL);
	
	for (n = 0; n < 2; n++) {
		// Create and start a new thread passing a stack local variable as parameter.
		// When sceKernelStartThread, thread is executed immediately, so in a while it has access
		// to the unmodified stack of the thread that created this one and can access n,
		// before it changes its value.
		sceKernelStartThread(
			sceKernelCreateThread("Test Thread", (void *)&threadFunction, 0x12, 0x10000, 0, NULL),
			1, &n
		);
	}

	// Wait until semaphore have been signaled two times (both new threads have been executed).
	sceKernelWaitSema(semaphore, 2, NULL);

	// After both threads have been executed, we will emit a -1 to check that semaphores work fine.
	emitInt(-1);
	
	sceKernelExitGame();
	
	return 0;
}