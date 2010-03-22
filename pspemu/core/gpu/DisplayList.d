module pspemu.core.gpu.DisplayList;

import pspemu.utils.Utils;

import pspemu.core.gpu.Commands;
import pspemu.core.gpu.Types;

static struct DisplayList {
	Command* base, pointer, stall;

	string toString() {
		return std.string.format("DisplayList(%08X-%08X-%08X):%08X", cast(uint)base, cast(uint)pointer, cast(uint)stall, cast(uint)(pointer - base));
	}

	void set(void* base, void* stall) {
		this.base  = cast(Command*)base;
		this.stall = cast(Command*)stall;
		this.pointer = this.base;
	}

	void jump(void* pointer) {
		this.pointer = cast(Command*)pointer;
	}

	void end() {
		base = pointer = stall = null;
	}

	bool isStalled() {
		if (stall is null) return false;
		//return pointer >= stall;
		return pointer == stall;
	}

	bool hasMore() {
		return (pointer !is null);
	}

	Command read() {
		return *pointer++;
	}

	static DisplayList opCall(void* base, void* stall) {
		DisplayList dl = void;
		dl.set(base, stall);
		return dl;
	}
}

alias Queue!(DisplayList) DisplayLists;
