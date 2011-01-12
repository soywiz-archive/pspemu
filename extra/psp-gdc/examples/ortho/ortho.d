import pspsdk.pspctrl;
import pspsdk.pspge;
import pspsdk.pspgu;
import pspsdk.pspgum;
import pspsdk.pspdebug;
import pspsdk.pspkerneltypes;
import pspsdk.pspthreadman;
import pspsdk.psploadexec;
import pspsdk.pspdisplay;
import pspsdk.utils.callback;
import pspsdk.utils.vram;
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
	{0xFF0000FF,   0.0f, -50.0f, 0.0f}, // Top, red
	{0xFF00FF00,  50.0f,  50.0f, 0.0f}, // Right, green
	{0xFFFF0000, -50.0f,  50.0f, 0.0f}, // Left, blue
];

int main() {
	SetupCallbacks();
	pspDebugScreenInit();
	
	void* fbp0 = getStaticVramBuffer(BUF_WIDTH,SCR_HEIGHT,GU_PSM_8888);
	void* fbp1 = getStaticVramBuffer(BUF_WIDTH,SCR_HEIGHT,GU_PSM_8888);
	void* zbp  = getStaticVramBuffer(BUF_WIDTH,SCR_HEIGHT,GU_PSM_4444);

	sceGuInit();
	sceGuStart(GU_DIRECT, cast(void *)list.ptr);
	sceGuDrawBuffer(GU_PSM_8888, fbp0, BUF_WIDTH);
	sceGuDispBuffer(SCR_WIDTH, SCR_HEIGHT, fbp1, BUF_WIDTH);
	sceGuDepthBuffer(zbp, BUF_WIDTH);
	sceGuOffset(2048 - (SCR_WIDTH / 2),2048 - (SCR_HEIGHT / 2));
	sceGuViewport(2048, 2048, SCR_WIDTH, SCR_HEIGHT);
	sceGuDepthRange(65535, 0);
	sceGuScissor(0, 0, SCR_WIDTH, SCR_HEIGHT);
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

	while(running) {
		SceCtrlData pad;

		sceGuStart(GU_DIRECT, cast(void *)list.ptr);

		sceGuClearColor(0);
		sceGuClearDepth(0);
		sceGuClear(GU_COLOR_BUFFER_BIT | GU_DEPTH_BUFFER_BIT);

		sceCtrlPeekBufferPositive(&pad, 1);

		if(pad.Buttons & PSP_CTRL_UP  ) pos.z += 1.0f / 100.0f;
		if(pad.Buttons & PSP_CTRL_DOWN) pos.z -= 1.0f / 100.0f;

		if(abs(pad.x) > 0.25) pos.x += pad.x;
		if(abs(pad.y) > 0.25) pos.y += pad.y;

		sceGumMatrixMode(GU_PROJECTION);
		sceGumLoadIdentity();
		sceGumOrtho(0, 480, 272, 0, -1, 1);

		sceGumMatrixMode(GU_VIEW);
		sceGumLoadIdentity();

		sceGumMatrixMode(GU_MODEL);
		sceGumLoadIdentity();

		// Draw triangle
		{
			sceGumTranslate(&pos);
			sceGumRotateZ(val * 0.03f);

			sceGumDrawArray(GU_TRIANGLES,GU_COLOR_8888|GU_VERTEX_32BITF|GU_TRANSFORM_3D,1*3,null,vertices.ptr);
		}

		sceGuFinish();
		sceGuSync(0, 0);

		pspDebugScreenSetOffset(cast(int)fbp0);
		pspDebugScreenSetXY(0, 0);

		pspDebugScreenPrintf("x: %.2f y: %.2f z: %.2f", pos.x, pos.y, pos.z);

		sceDisplayWaitVblankStart();

		try {
			throw(new Exception("Exception test"));
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
