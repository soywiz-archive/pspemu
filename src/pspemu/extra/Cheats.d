module pspemu.extra.Cheats;

import std.stdio;

import pspemu.core.Memory;
import pspemu.utils.Expression;

struct CheatEntry {
	uint size;
	uint address;
	uint value;
	
	void executeCheat(Memory memory) {
		// writefln("%08X <- %08X", address, value);
		switch (size) {
			case 32: memory.twrite(address, cast(uint)value); break;
			case 16: memory.twrite(address, cast(ushort)value); break;
			case  8: memory.twrite(address, cast(ubyte)value); break;
			default: throw(new Exception(std.string.format("Invalid CheatEntry.size(%d)", size)));
		}
	}
}

class Cheats {
	CheatEntry[] entries;
	string[] traceThreadNames;
	
	void addTraceThread(string threadName) {
		traceThreadNames ~= threadName;
	}
	
	bool mustTraceThreadName(string threadNameToCheck) {
		foreach (threadName; traceThreadNames) if (threadName == threadNameToCheck) return true;
		return false;
	}
	
	void addCheatString(string component, uint size) {
		string[] parts = std.string.split(component, ":");
		auto address = parseString(parts[0]) + 0x_08_00_00_00;
		auto value   = parseString(parts[1]);
		entries ~= CheatEntry(size, cast(uint)address, cast(uint)value);
		
		//writefln("%08X: Added cheat: %08X, %08X", cast(uint)cast(void*)this, address, value);
	}
	
	void executeCheats(Memory memory) {
		//writefln("%08X: Executing cheats...", cast(uint)cast(void*)this);
		foreach (ref entry; entries) {
			//writefln("    %s", entry);
			entry.executeCheat(memory);
		}
	}
}

__gshared Cheats globalCheats;

static this() {
	if (globalCheats is null) {
		globalCheats = new Cheats();
	}
}