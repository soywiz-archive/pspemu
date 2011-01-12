module pspsdk.utils.callback;

import pspsdk.pspkerneltypes;
import pspsdk.psploadexec;
import pspsdk.pspthreadman;

extern (C):

private int done = 0;

/* Exit callback */
static int exit_callback(int arg1, int arg2, void *common) {
	//sceKernelExitGame();
	done = 1;
	return 0;
}

/* Callback thread */
static int CallbackThread(SceSize args, void *argp) {
	int cbid;

	cbid = sceKernelCreateCallback("Exit Callback", &exit_callback, null);
	sceKernelRegisterExitCallback(cbid);

	sceKernelSleepThreadCB();

	return 0;
}

/* Sets up the callback thread and returns its thread id */
int SetupCallbacks() {
	SceUID thid = 0;

	thid = sceKernelCreateThread("update_thread", &CallbackThread, 0x11, 0xFA0, 0, null);
	if(thid >= 0) sceKernelStartThread(thid, 0, null);

	return thid;
}

bool running() {
	return !done;
}