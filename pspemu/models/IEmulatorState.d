interface IGpu {
	void setInstructionList(void *list, void *stall = null);
	void setInstructionStall(void *stall);
	void synchronizeGpu();
	void stop();
}

interface IEmulatorState {
	IGpu gpu();
}