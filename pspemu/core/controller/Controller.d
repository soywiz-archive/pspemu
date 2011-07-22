module pspemu.core.controller.Controller;

import pspemu.utils.CircularList;
public import pspemu.hle.kd.ctrl.Types;

class Controller {
	CircularList!(SceCtrlData) sceCtrlDataFrames;
	SceCtrlData sceCtrlData;
	PspCtrlMode samplingMode;
	int samplingCycle;
	
	this() {
		sceCtrlDataFrames = new CircularList!(SceCtrlData)();
	}
	
	public void reset() {
		this.sceCtrlDataFrames.clear();
		this.sceCtrlData   = this.sceCtrlData.init;
		this.samplingMode  = this.samplingMode.init;
		this.samplingCycle = this.samplingCycle.init;
	}
	
	public void push() {
		sceCtrlDataFrames.enqueue(sceCtrlData);
		sceCtrlData.TimeStamp++;
	}
	
	public ref SceCtrlData readAt(int n) {
		return this.sceCtrlDataFrames.readFromTail(-(n + 1));
	}
}