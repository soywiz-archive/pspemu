// http://psp.jim.sh/pspsdk-doc/pspmoduleinfo_8h.html

// imports
//
extern (C) void pspDebugScreenInit();
extern (C) void pspDebugScreenPrintf(char*,...);
extern (C) void pspDebugScreenSetOffset(int);
extern (C) void pspDebugScreenSetXY(int, int);


extern (C) int sceKernelSleepThread();
extern (C) int sceKernelExitGame();
extern (C) int sceDisplayWaitVblankStart();

alias uint SceSize;

extern (C) int sceKernelCreateCallback(char*, int function(int, int, void*), void*);
extern (C) int sceKernelRegisterExitCallback(int);
extern (C) int sceKernelSleepThreadCB();
extern (C) int sceKernelCreateThread(char *, int function(SceSize, void *), int, int, int, int);
extern (C) int sceKernelStartThread(int, int, int);

import pspsdk.pspctrl;
import pspsdk.pspge;
import pspsdk.pspgu;
import pspsdk.pspgum;
import std.string;
import std.math;

align(16) static uint list[262144];
 
static const uint BUF_WIDTH = 512;
static const uint SCR_WIDTH = 480;
static const uint SCR_HEIGHT = 272;

struct Vertex {
   uint color;
   float x, y, z;
}

align(16) Vertex vertices[] = [
	{0xFF0000FF, 0.0f, -50.0f, 0.0f}, // Top, red
	{0xFF00FF00, 50.0f, 50.0f, 0.0f}, // Right, green
	{0xFFFF0000, -50.0f, 50.0f, 0.0f}, // Left, blue
];

/* Exit callback */
extern (C) static int exit_callback(int arg1, int arg2, void *common) {
	sceKernelExitGame();
	return 0;
}

/* Callback thread */
extern (C) static int CallbackThread(SceSize args, void *argp) {
	int cbid;

	cbid = sceKernelCreateCallback("Exit Callback", &exit_callback, null);
	sceKernelRegisterExitCallback(cbid);

	sceKernelSleepThreadCB();

	return 0;
}

/* Sets up the callback thread and returns its thread id */
extern (C) int SetupCallbacks() {
	int thid = 0;

	thid = sceKernelCreateThread("update_thread", &CallbackThread, 0x11, 0xFA0, 0, 0);
	if(thid >= 0) {
		  sceKernelStartThread(thid, 0, 0);
	}

	return thid;
} 

bool running() { return true; }

int main()
{
	SetupCallbacks();
	pspDebugScreenInit();
	
	//void* fbp0 = getStaticVramBuffer(BUF_WIDTH,SCR_HEIGHT,GU_PSM_8888);
	//void* fbp1 = getStaticVramBuffer(BUF_WIDTH,SCR_HEIGHT,GU_PSM_8888);
	//void* zbp = getStaticVramBuffer(BUF_WIDTH,SCR_HEIGHT,GU_PSM_4444);
	//void* base = sceGeEdramGetAddr();
	void* base = null;
	void* fbp0 = base;
	void* fbp1 = fbp0 + (BUF_WIDTH * SCR_HEIGHT * 4);
	void* zbp  = fbp1 + (BUF_WIDTH * SCR_HEIGHT * 4);

	sceGuInit();
	sceGuStart(GU_DIRECT, cast(void *)list.ptr);
	sceGuDrawBuffer(GU_PSM_8888, fbp0, BUF_WIDTH);
	sceGuDispBuffer(SCR_WIDTH,SCR_HEIGHT,fbp1,BUF_WIDTH);
	sceGuDepthBuffer(zbp,BUF_WIDTH);
	sceGuOffset(2048 - (SCR_WIDTH/2),2048 - (SCR_HEIGHT/2));
	sceGuViewport(2048,2048,SCR_WIDTH,SCR_HEIGHT);
	sceGuDepthRange(65535,0);
	sceGuScissor(0,0,SCR_WIDTH,SCR_HEIGHT);
	sceGuEnable(GU_SCISSOR_TEST);
	sceGuFrontFace(GU_CW);
	sceGuShadeModel(GU_SMOOTH);
	sceGuDisable(GU_TEXTURE_2D);
	sceGuFinish();
	sceGuSync(0,0);

	sceDisplayWaitVblankStart();
	sceGuDisplay(1);

	sceCtrlSetSamplingCycle(0);
	sceCtrlSetSamplingMode(PSP_CTRL_MODE_ANALOG);
	
	ScePspFVector3 pos = {240.0f, 136.0f, 0.0f};

	int val = 0;

	while(running())
	{
		SceCtrlData pad;
 
		sceGuStart(GU_DIRECT, cast(void *)list.ptr);
 
		sceGuClearColor(0);
		sceGuClearDepth(0);
		sceGuClear(GU_COLOR_BUFFER_BIT|GU_DEPTH_BUFFER_BIT);

		sceCtrlPeekBufferPositive(&pad, 1);

		if(pad.Buttons & PSP_CTRL_UP)
			pos.z += 1.0f / 100.0f;
		if(pad.Buttons & PSP_CTRL_DOWN)
			pos.z -= 1.0f / 100.0f;

		if(abs(pad.Lx-128) > 32)
			pos.x += ((pad.Lx-128)/128.0f);
		if(abs(pad.Ly-128) > 32)
			pos.y += ((pad.Ly-128)/128.0f);
 
		sceGumMatrixMode(GU_PROJECTION);
		sceGumLoadIdentity();
		sceGumOrtho(0, 480, 272, 0, -1, 1);

		sceGumMatrixMode(GU_VIEW);
		sceGumLoadIdentity();
 
		sceGumMatrixMode(GU_MODEL);
		sceGumLoadIdentity();

                // Draw triangle
                
                sceGumTranslate(&pos);
                sceGumRotateZ(val*0.03f);

                sceGumDrawArray(GU_TRIANGLES,GU_COLOR_8888|GU_VERTEX_32BITF|GU_TRANSFORM_3D,1*3,null,vertices.ptr);

		sceGuFinish();
		sceGuSync(0,0);

		pspDebugScreenSetOffset(cast(int)fbp0);
		pspDebugScreenSetXY(0,0);

		pspDebugScreenPrintf("x: %.2f y: %.2f z: %.2f",pos.x,pos.y,pos.z);

		sceDisplayWaitVblankStart();

		try {
			throw(new Exception("Hello World"));
		} catch {
			fbp0 = sceGuSwapBuffers();
		} finally {
			val++;
		}

	}
 
	sceGuTerm();

	//sceKernelSleepThread();
	sceKernelExitGame();
	return 0;
}
