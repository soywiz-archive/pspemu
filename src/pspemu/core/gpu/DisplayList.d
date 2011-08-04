module pspemu.core.gpu.DisplayList;

//import pspemu.utils.Utils;
import std.conv;
import pspemu.utils.CircularList;
import pspemu.utils.Stack;

import pspemu.utils.sync.WaitEvent;

import pspemu.core.gpu.Commands;
import pspemu.core.gpu.Types;

import std.stdio;

static struct DisplayList {
	Command* base, pointer, stall;
	Stack!(Command*) callStack;
	WaitEvent displayListEndedEvent;
	WaitEvent displayListStalledEvent;
	WaitEvent displayListNewDataEvent;
	
	void init() {
		displayListEndedEvent   = new WaitEvent("DisplayList.displayListEndedEvent");
		displayListStalledEvent = new WaitEvent("DisplayList.displayListStalledEvent");
		displayListNewDataEvent = new WaitEvent("DisplayList.displayListNewDataEvent");
		callStack = new Stack!(Command*)(1024);
	}

	string toString() {
		return std.string.format("DisplayList(%08X-%08X-%08X):%08X", cast(uint)base, cast(uint)pointer, cast(uint)stall, cast(uint)(pointer - base));
	}

	void set(void* base, void* stall) {
		this.base  = cast(Command*)base;
		this.stall = cast(Command*)stall;
		this.pointer = this.base;
		displayListEndedEvent.reset();
		displayListNewDataEvent.signal();
	}

	void jump(void* pointer) {
		this.pointer = cast(Command*)pointer;
	}
	
	void call(void *pointer) {
		callStack.push(this.pointer);
		this.pointer = cast(Command*)pointer;
	}
	
	void ret() {
		this.pointer = callStack.pop();
	}

	void end() {
		base = pointer = stall = null;
		displayListEndedEvent.signal();
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
		scope (exit) {
			if (pointer == stall) {
				displayListStalledEvent.signal();
			}
		}
		return *pointer++;
	}

	static DisplayList opCall(void* base, void* stall) {
		DisplayList dl = void;
		dl.init();
		dl.set(base, stall);
		return dl;
	}
}

alias Queue!(DisplayList) DisplayLists;
