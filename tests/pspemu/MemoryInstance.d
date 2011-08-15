module pspemu.MemoryInstance;

public import pspemu.core.Memory;

final abstract class MemoryInstance {
	static Memory instance;
	
	static this() {
		instance = new Memory();
	}
}
