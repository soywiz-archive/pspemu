module pspemu.core.controller.Controller;

import pspemu.utils.CircularList;

public import pspemu.hle.kd.ctrl.Types;

import pspemu.interfaces.IResetable;

class Controller : IResetable {
	protected CircularList!(SceCtrlData) sceCtrlDataFrames;
	
	public SceCtrlData sceCtrlData;
	public PspCtrlMode samplingMode;
	public int samplingCycle;
	
	public this() {
		sceCtrlDataFrames = new CircularList!(SceCtrlData)();
	}
	
	public void reset() {
		this.sceCtrlDataFrames.clear();
		this.sceCtrlData   = this.sceCtrlData.init;
		this.samplingMode  = this.samplingMode.init;
		this.samplingCycle = this.samplingCycle.init;
	}

	/**
	 * Pushes the current 'sceCtrlData' to the list of frames.
	 */
	public void push() {
		sceCtrlDataFrames.enqueue(sceCtrlData);
		sceCtrlData.TimeStamp++;
	}
	
	/**
	 * Read sceCtrlData frame from the position 'n' from tail.
	 */
	public ref SceCtrlData readAt(int n) {
		return this.sceCtrlDataFrames.readFromTail(-(n + 1));
	}
}