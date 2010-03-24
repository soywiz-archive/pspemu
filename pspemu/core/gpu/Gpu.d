module pspemu.core.gpu.Gpu;

//debug = DEBUG_GPU_VERBOSE;
debug = GPU_UNKNOWN_COMMANDS;
//debug = GPU_UNKNOWN_COMMANDS_STOP;
//debug = DEBUG_GPU_SHOW_COMMAND;

import core.thread;

import std.stdio;

import pspemu.utils.Utils;

import pspemu.core.Memory;
import pspemu.core.gpu.Commands;
import pspemu.core.gpu.Types;
import pspemu.core.gpu.DisplayList;

import pspemu.core.gpu.ops.Special;
import pspemu.core.gpu.ops.Flow;
import pspemu.core.gpu.ops.Colors;
import pspemu.core.gpu.ops.Draw;
import pspemu.core.gpu.ops.Matrix;
import pspemu.core.gpu.ops.Texture;
import pspemu.core.gpu.ops.Enable;

class Gpu {
	mixin PspHardwareComponent;

	Memory   memory;
	GpuImpl  impl;
	GpuState state;

	DisplayList* currentDisplayList;
	DisplayLists displayLists;

	TaskQueue externalActions;
	
	this(GpuImpl impl, Memory memory) {
		this.impl            = impl;
		this.memory          = memory;
		this.displayLists    = new DisplayLists(1024);
		this.externalActions = new TaskQueue;
		state.memory = memory;
		impl.setState(&state);
	}

	void executeSingleCommand(ref DisplayList displayList) {
		//debug (DEBUG_GPU_VERBOSE) writefln("  executeCommand");
		auto commandPointer = displayList.pointer;
		Command command = displayList.read;
		Gpu gpu = this;

		void doassert() {
			writefln("0x%08X: Stop %s", reinterpret!(uint)(&command), command);
			throw(new Exception("Unimplemented"));
		}
		void unimplemented() {
			debug (GPU_UNKNOWN_COMMANDS) writefln("0x%08X: Unimplemented %s", reinterpret!(uint)(&command), command);
			debug (GPU_UNKNOWN_COMMANDS_STOP) doassert(0);
		}

		mixin Gpu_Enable;
		mixin Gpu_Special;
		mixin Gpu_Flow;
		mixin Gpu_Colors;
		mixin Gpu_Draw;
		mixin Gpu_Matrix;
		mixin Gpu_Texture;

		mixin({
			string s;
			s ~= "switch (command.opcode) {";
			for (int n = 0; n < 0x100; n++) {
				s ~= "case " ~ tos(n) ~ ":";
				{
					string opname = enumToString(cast(Opcode)n);
					string func = "OP_" ~ opname;
					debug (DEBUG_GPU_SHOW_COMMAND) s ~= "writefln(\"%08X:%s: %06X\", memory.getPointerReverseOrNull(commandPointer), \"" ~ opname ~ "\", command.param24);";
					s ~= "mixin(\"static if (__traits(compiles, " ~ func ~ ")) { " ~ func ~ "(); } else { unimplemented(); }\");";
				}
				s ~= "break;";
			}
			/*
			s ~= "default:";
			s ~= "	writefln(\"default!!\");";
			s ~= "	unimplemented();";
			s ~= "	break;";
			*/
			s ~= "}";
			return s;
		}());
	}

	/**
	 * Executes a DisplayList.
	 */
	void executeList(ref DisplayList displayList) {
		// Execute commands while has more.	
		currentDisplayList = &displayList;

		debug (DEBUG_GPU_VERBOSE) writefln("<executeList> (%s)", displayList);
		Command* lastCommandPointer;
		try {
			while (displayList.hasMore) {
				while (displayList.isStalled) {
					debug (DEBUG_GPU_VERBOSE) writefln("  stalled() : %s", displayList);
					WaitAndCheck;
				}
				WaitAndCheck(0);
				lastCommandPointer = displayList.pointer;
				executeSingleCommand(displayList);
			}
		} catch (Object o) {
			writefln("Last command: %s", *lastCommandPointer);
			throw(o);
		} finally {
			debug (DEBUG_GPU_VERBOSE) writefln("</executeList>");
			displayList.end();
			currentDisplayList = null;
		}
	}

	bool executingDisplayList() { return (currentDisplayList !is null); }
	
	private void run() {
		try {
			impl.init();
			_running = true;
			while (true) {
				while (displayLists.readAvailable) executeList(displayLists.consume);

				WaitAndCheck;
			}
		} catch (Object o) {
			writefln("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			writefln("Gpu.run exception: %s", o);
			writefln("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		} finally {
			writefln("Gpu.shutdown");
		}
	}

	template ExternalInterface() {
		DisplayList* sceGeListEnQueue(void* list, void* stall = null) {
			InfiniteLoop!(512) loop;
			while (!displayLists.writeAvailable) {
				loop.increment();
				sleep(1);
			}
			DisplayList* ret = &displayLists.queue(DisplayList(list, stall));
			//writefln("%s", *ret);
			return ret;
		}

		// @TODO!!!! @FIXME!! change queue for queueHead
		DisplayList* sceGeListEnQueueHead(void* list, void* stall = null) {
			InfiniteLoop!(512) loop;
			while (!displayLists.writeAvailable) {
				loop.increment();
				sleep(1);
			}
			DisplayList* ret = &displayLists.queue(DisplayList(list, stall));
			return ret;
		}

		void sceGeListUpdateStallAddr(DisplayList* displayList, void* stall) {
			displayList.stall = cast(Command*)stall;
		}

		void sceGeListDeQueue(DisplayList* displayList) {
		}

		/**
		 * Wait until the specified list have been executed.
		 */
		void sceGeListSync(DisplayList* displayList, int syncType) {
			// While this displayList has more items to read.
			try {
				InfiniteLoop!(512) loop;
				while (displayList.hasMore) {
					loop.increment();
					WaitAndCheck;
				}
			} catch {
			}

			checkStoreFrameBuffer();
		}
		
		/**
		 * Wait until all the remaining commands have been executed.
		 */
		void sceGeDrawSync(int syncType) {
			// While we have display lists queued
			// Or if we are currently executing a displayList
			try {
				InfiniteLoop!(512) loop;
				while (displayLists.readAvailable || executingDisplayList) {
					loop.increment({
						writefln("  executingDisplayList: %s", executingDisplayList);
						writefln("  displayLists.readAvailable: %d", displayLists.readAvailable);
					});
					WaitAndCheck;
				}
			} catch {
			}
			
			checkStoreFrameBuffer();
		}
	}

	bool inDrawingThread() { return Thread.getThis == thread; }

	void WaitAndCheck(uint count = 1) {
		if (!running) throw(new Exception("Gpu Stopping Execution"));
		if (inDrawingThread) externalActions();
		if (count > 0) sleep(count);
	}

	void* drawBufferAddress() {
		//writefln("%s", state.drawBuffer);
		if (state.drawBuffer.address == 0) return null;
		return memory.getPointer(state.drawBuffer.address);
	}

	void externalActionAdd(TaskQueue.Task task) {
		externalActions.add(task);
		if (inDrawingThread) externalActions(); else externalActions.waitEmpty();
	}

	void loadFrameBuffer () { if (drawBufferAddress) externalActionAdd(delegate void() { impl.frameLoad (drawBufferAddress); }); }
	void storeFrameBuffer() { if (drawBufferAddress) externalActionAdd(delegate void() { impl.frameStore(drawBufferAddress); }); }

	//void loadFrameBufferActually() { impl.frameLoad(drawBufferAddress); }
	//void storeFrameBufferActually() { impl.frameStore(drawBufferAddress); }

	bool mustLoadFrameBuffer;
	void checkLoadFrameBuffer() {
		if (!mustLoadFrameBuffer) return; else mustLoadFrameBuffer = false;
		loadFrameBuffer();
	}

	bool mustStoreFrameBuffer;
	void checkStoreFrameBuffer() {
		if (!mustStoreFrameBuffer) return; else mustStoreFrameBuffer = false;
		storeFrameBuffer();
	}

	mixin ExternalInterface;
}
