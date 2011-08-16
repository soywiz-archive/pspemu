module gdb.IGdbProcessor;

import gdb.Sigval;

interface IGdbProcessor {
	void registerOnSigval(void delegate(Sigval sigval) callback);

	uint getRegister(uint index);
	void setRegister(uint index, uint value);

	int  getMemoryRange(ubyte[] buffer);
	int  setMemoryRange(ubyte[] buffer);

	void run();	
	void stepInto();
	void stepOver();
	void pause();
	void stop();
	@property bool isRunning();
}