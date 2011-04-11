module pspemu.models.ISyscall;

public import pspemu.All;

interface ISyscall {
	void opCall(ExecutionState executionState, int code);
}