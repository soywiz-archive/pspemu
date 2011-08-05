module pspemu.core.controller.ControllerTest;

import pspemu.core.controller.Controller;
import pspemu.hle.kd.ctrl.Types;
import pspemu.utils.CircularList;

import tests.Test;

class ControllerTest : Test {
	Controller controller;
	
	this() {
		controller = new Controller();
	}
	
	void setUp() {
		controller.reset();
	}
	
	void testController() {
		controller.sceCtrlData.Buttons = PspCtrlButtons.PSP_CTRL_CROSS | PspCtrlButtons.PSP_CTRL_UP;
		controller.sceCtrlData.Lx = 0;
		controller.sceCtrlData.Ly = 127;
		controller.sceCtrlData.TimeStamp++;
		controller.push();

		controller.sceCtrlData.Buttons = PspCtrlButtons.PSP_CTRL_CROSS | PspCtrlButtons.PSP_CTRL_DOWN;
		controller.sceCtrlData.Lx = 255;
		controller.sceCtrlData.Ly = 127;
		controller.sceCtrlData.TimeStamp++;
		controller.push();
		
		assertEquals(controller.readAt(0).Buttons, PspCtrlButtons.PSP_CTRL_CROSS | PspCtrlButtons.PSP_CTRL_DOWN);
		assertEquals(controller.readAt(1).Buttons, PspCtrlButtons.PSP_CTRL_CROSS | PspCtrlButtons.PSP_CTRL_UP);
	}
}