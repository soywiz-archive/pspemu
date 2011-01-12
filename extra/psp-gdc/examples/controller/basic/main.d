/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * main.c - Basic Input demo -- reads from control pad and indicates button
 *          presses.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 * Copyright (c) 2005 Donour Sizemore <donour@uchicago.edu>
 *
 * $Id: main.c 1095 2005-09-27 21:02:16Z jim $
 */

import pspsdk.pspkernel;
import pspsdk.pspdebug;
import pspsdk.pspctrl;
import pspsdk.psploadexec;
import pspsdk.utils.callback;

version (BUILD_INFO) {
	pragma(MODULE_NAME, "CONTROLTEST");
	pragma(PSP_EBOOT_TITLE, "Controller Basic");
	pragma(PSP_MAIN_THREAD_ATTR, THREAD_ATTR_USER | THREAD_ATTR_VFPU);
	pragma(PSP_FW_VERSION, 150);
}

int main() {
	SceCtrlData pad;

	pspDebugScreenInit();
	SetupCallbacks();

	sceCtrlSetSamplingCycle(0);
	sceCtrlSetSamplingMode(PSP_CTRL_MODE_ANALOG);

	while (running) {
		pspDebugScreenSetXY(0, 2);

		sceCtrlReadBufferPositive(&pad, 1); 

		pspDebugScreenPrintf(
			"Analog X,Y = (%d, %d):(%.2f, %.2f) \n",
			pad.Lx, pad.Ly,
			pad.x, pad.y
		);

		if (pad.Buttons != 0){
			if (pad.Buttons & PSP_CTRL_SQUARE  ) pspDebugScreenPrintf("Square pressed \n");
			if (pad.Buttons & PSP_CTRL_TRIANGLE) pspDebugScreenPrintf("Triangle pressed \n");
			if (pad.Buttons & PSP_CTRL_CIRCLE  ) pspDebugScreenPrintf("Cicle pressed \n");
			if (pad.Buttons & PSP_CTRL_CROSS   ) pspDebugScreenPrintf("Cross pressed \n");
			if (pad.Buttons & PSP_CTRL_UP      ) pspDebugScreenPrintf("Up pressed \n");
			if (pad.Buttons & PSP_CTRL_DOWN    ) pspDebugScreenPrintf("Down pressed \n");
			if (pad.Buttons & PSP_CTRL_LEFT    ) pspDebugScreenPrintf("Left pressed \n");
			if (pad.Buttons & PSP_CTRL_RIGHT   ) pspDebugScreenPrintf("Right pressed \n");
			if (pad.Buttons & PSP_CTRL_START   ) pspDebugScreenPrintf("Start pressed \n");
			if (pad.Buttons & PSP_CTRL_SELECT  ) pspDebugScreenPrintf("Select pressed \n");
			if (pad.Buttons & PSP_CTRL_LTRIGGER) pspDebugScreenPrintf("L-trigger pressed \n");
			if (pad.Buttons & PSP_CTRL_RTRIGGER) pspDebugScreenPrintf("R-trigger pressed \n");
		}
	}

	sceKernelExitGame();
	return 0;
}
