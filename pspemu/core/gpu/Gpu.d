module pspemu.core.gpu.Gpu;

// http://hitmen.c02.at/files/yapspd/psp_doc/chap11.html

//debug = DEBUG_GPU_VERBOSE;
debug = GPU_UNKNOWN_COMMANDS;
//debug = GPU_UNKNOWN_COMMANDS_STOP;
//debug = DEBUG_GPU_SHOW_COMMAND;

//debug = DEBUG_WARNING_PERFORM_BUFFER_OP;

import core.thread;

import std.stdio;
import std.conv;

import pspemu.utils.Utils;
import pspemu.utils.Math;
import pspemu.utils.Logger;

import pspemu.core.Memory;
import pspemu.core.gpu.Commands;
import pspemu.core.gpu.Types;
import pspemu.core.gpu.GpuState;
import pspemu.core.gpu.GpuImpl;
import pspemu.core.gpu.DisplayList;

import pspemu.core.gpu.ops.Special;
import pspemu.core.gpu.ops.Flow;
import pspemu.core.gpu.ops.Colors;
import pspemu.core.gpu.ops.Draw;
import pspemu.core.gpu.ops.Matrix;
import pspemu.core.gpu.ops.Texture;
import pspemu.core.gpu.ops.Enable;
import pspemu.core.gpu.ops.Lights;
import pspemu.core.gpu.ops.Morph;
import pspemu.core.gpu.ops.Clut;
import pspemu.core.gpu.ops.Fog;
import pspemu.core.gpu.ops.Dither;
import pspemu.core.gpu.ops.Depth;

class Gpu : PspHardwareComponent {
	Memory   memory;
	GpuImpl  impl;
	GpuState state;

	DisplayList* currentDisplayList;
	DisplayLists displayLists;

	TaskQueue externalActions;
	
	this(GpuImpl impl, Memory memory) {
		this.impl   = impl;
		this.memory = memory;
		this.reset();
	}

	override void reset() {
		this.state = GpuState.init;
		this.displayLists    = new DisplayLists(1024);
		this.externalActions = new TaskQueue;
		this.state.memory = memory;
		this.impl.reset();
		this.impl.setState(&state);
	}

	// Utility.
	static pure string ArrayOperation(string vtype, int from, int to, string code, int step = 1) {
		string r;
		assert(vtype[$ - 2..$] == "_n");
		assert(vtype[0..3] == "OP_");
		assert(from <= to);
		
		auto type = vtype[0..$ - 2];

		// Aliases.
		r ~= "alias " ~ type ~ "_n ";
		for (int n = from; n <= to; n++) {
			if (n > from) r ~= ", ";
			r ~= "" ~ type ~ tos(n);
		}
		r ~= ";";

		// Operations.
		r ~= "auto " ~ type ~ "_n() { uint Index = BaseIndex(Opcode." ~ type[3..$] ~ tos(from) ~ ") / " ~ tos(step) ~ "; " ~ code ~ "}";
		return r;
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
		uint BaseIndex(uint base) { return command.opcode - base; }

		mixin Gpu_Enable;
		mixin Gpu_Special;
		mixin Gpu_Flow;
		mixin Gpu_Colors;
		mixin Gpu_Draw;
		mixin Gpu_Matrix;
		mixin Gpu_Texture;
		mixin Gpu_Lights;
		mixin Gpu_Morph;
		mixin Gpu_Clut;
		mixin Gpu_Fog;
		mixin Gpu_Dither;
		mixin Gpu_Depth;

		mixin({
			string s;
			s ~= "switch (command.opcode) {";
			for (int n = 0; n < 0x100; n++) {
				s ~= "case " ~ tos(n) ~ ":";
				{
					string opname = to!string(cast(Opcode)n);
					string func = "OP_" ~ opname;
					debug (DEBUG_GPU_SHOW_COMMAND) s ~= "writefln(\"%08X:%s: %06X\", memory.getPointerReverseOrNull(commandPointer), \"" ~ opname ~ "\", command.param24);";
					s ~= "mixin(\"static if (__traits(compiles, " ~ func ~ ")) { " ~ func ~ "(); } else { unimplemented(); }\");";
				}
				s ~= "break;";
			}
			s ~= "default:";
			s ~= "	writefln(\"default!!\");";
			s ~= "	unimplemented();";
			s ~= "	break;";
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
		} catch (Throwable o) {
			writefln("Last command: %s", *lastCommandPointer);
			throw(o);
		} finally {
			debug (DEBUG_GPU_VERBOSE) writefln("</executeList>");
			displayList.end();
			currentDisplayList = null;
		}
	}

	bool executingDisplayList() { return (currentDisplayList !is null); }

	bool implInitialized;

	override void run() {
		try {
			if (!implInitialized) {
				impl.init();
				implInitialized = true;
			}
			componentInitialized = true;
			while (true) {
				while (displayLists.readAvailable) {
					impl.startDisplayList();
					{
						executeList(displayLists.consume);
					}
					impl.endDisplayList();
				}
				if (runningState != RunningState.RUNNING) waitUntilResume();
				WaitAndCheck;
			}
		} catch (HaltException e) {
			Logger.log(Logger.Level.DEBUG, "Gpu", "Gpu.run HaltException: %s", e);
		} catch (Throwable e) {
			Logger.log(Logger.Level.CRITICAL, "Gpu", "Gpu.run exception: %s", e);
		} finally {
			Logger.log(Logger.Level.DEBUG, "Gpu", "Gpu.shutdown");
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

			performBufferOp(BufferOperation.STORE);
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
			
			performBufferOp(BufferOperation.STORE);
		}
	}

	bool inDrawingThread() { return Thread.getThis == thread; }

	void WaitAndCheck(uint count = 1) {
		if (!running) throw(new Exception("Gpu Stopping Execution"));
		if (inDrawingThread) externalActions();
		if (count > 0) sleep(count);
	}

	void externalActionAdd(TaskQueue.Task task) {
		externalActions.add(task);
		if (inDrawingThread) externalActions(); else externalActions.waitEmpty();
	}
	
	void loadBuffer(ScreenBuffer* buffer) {
		if (buffer.loadAddress) {
			uint loadAddress = buffer.loadAddress;
			buffer.loadAddress = 0;
			externalActionAdd(delegate void() {
				if (buffer == &state.drawBuffer ) impl.frameLoad(memory.getPointerOrNull(loadAddress), null);
				if (buffer == &state.depthBuffer) impl.frameLoad(null, memory.getPointerOrNull(loadAddress));
			});
		}
	}

	void storeBuffer(ScreenBuffer* buffer) {
		if (buffer.storeAddress) {
			uint storeAddress = buffer.storeAddress;
			buffer.storeAddress = 0;
			externalActionAdd(delegate void() {
				if (buffer == &state.drawBuffer ) impl.frameStore(memory.getPointerOrNull(storeAddress), null);
				if (buffer == &state.depthBuffer) impl.frameStore(null, memory.getPointerOrNull(storeAddress));
			});
		}
	}
	
	enum BufferType {
		COLOR = 1,
		DEPTH = 2,
		// All
		ALL   = COLOR | DEPTH,
	}
	
	enum BufferOperation {
		LOAD  = 0,
		STORE = 1,
	}
	
	void markBufferOp(BufferOperation bufferOperation, BufferType bufferType = BufferType.ALL) {
		if (bufferOperation == BufferOperation.LOAD) {
			if (bufferType & BufferType.COLOR) state.drawBuffer.loadAddress  = state.drawBuffer.address;
			if (bufferType & BufferType.DEPTH) state.depthBuffer.loadAddress = state.depthBuffer.address;
		} else {
			if (bufferType & BufferType.COLOR) state.drawBuffer.storeAddress  = state.drawBuffer.address;
			if (bufferType & BufferType.DEPTH) state.depthBuffer.storeAddress = state.depthBuffer.address;
		}
	}
	
	void performBufferOp(BufferOperation bufferOperation, BufferType bufferType = BufferType.ALL) {
		if (bufferOperation == BufferOperation.LOAD) {
			if (state.drawBuffer.storeAddress) {
				debug (DEBUG_WARNING_PERFORM_BUFFER_OP) writefln("WARNING! performBufferOp(LOAD) has state.drawBuffer.mustStore. It wasn't stored yet!");
				//return;
			}
			if (bufferType & BufferType.COLOR) loadBuffer(&state.drawBuffer);
			if (bufferType & BufferType.DEPTH) loadBuffer(&state.depthBuffer);
		} else {
			if (state.drawBuffer.loadAddress) {
				debug (DEBUG_WARNING_PERFORM_BUFFER_OP) writefln("WARNING! performBufferOp(STORE) has state.drawBuffer.mustLoad. It wasn't stored yet!");
			}
			if (bufferType & BufferType.COLOR) storeBuffer(&state.drawBuffer);
			if (bufferType & BufferType.DEPTH) storeBuffer(&state.depthBuffer);
		}
	}

	mixin ExternalInterface;
}
