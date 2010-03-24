module pspemu.models.ISyscall;

interface ISyscall {
	void opCall(int code);
}