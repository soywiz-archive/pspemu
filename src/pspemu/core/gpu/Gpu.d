module pspemu.core.gpu.Gpu;

// http://hitmen.c02.at/files/yapspd/psp_doc/chap11.html

//debug = DEBUG_GPU_VERBOSE;
//debug = DEBUG_GPU_SHOW_COMMAND;

//debug = DEBUG_WARNING_PERFORM_BUFFER_OP;

import core.thread;
import core.time;
import std.datetime;

import std.stdio;
import std.conv;

import pspemu.Exceptions;

import pspemu.utils.Logger;
import pspemu.utils.Event;

import pspemu.interfaces.IResetable;

import pspemu.utils.TaskQueue;
import pspemu.utils.CircularList;
import pspemu.utils.Stack;
import pspemu.utils.MathUtils;
import pspemu.utils.BitUtils;
import pspemu.utils.String;

import pspemu.utils.sync.WaitEvent;
import pspemu.utils.sync.WaitMultipleObjects;
//import pspemu.utils.Logger;

import pspemu.core.Memory;
import pspemu.core.gpu.Commands;
import pspemu.core.gpu.Types;
import pspemu.core.gpu.GpuState;
import pspemu.core.gpu.GpuImpl;
import pspemu.core.gpu.DisplayList;

import pspemu.core.gpu.ops.Gpu_Special;
import pspemu.core.gpu.ops.Gpu_Flow;
import pspemu.core.gpu.ops.Gpu_Colors;
import pspemu.core.gpu.ops.Gpu_Draw;
import pspemu.core.gpu.ops.Gpu_Matrix;
import pspemu.core.gpu.ops.Gpu_Texture;
import pspemu.core.gpu.ops.Gpu_Enable;
import pspemu.core.gpu.ops.Gpu_Lights;
import pspemu.core.gpu.ops.Gpu_Morph;
import pspemu.core.gpu.ops.Gpu_Clut;
import pspemu.core.gpu.ops.Gpu_Fog;
import pspemu.core.gpu.ops.Gpu_Dither;
import pspemu.core.gpu.ops.Gpu_Depth;
import pspemu.core.gpu.ops.Gpu_Spline;

import pspemu.hle.kd.ge.Types;

import std.datetime;

class Gpu : IResetable {
	//bool componentInitialized;
	bool running = true;
	
	Memory           memory;
	GpuImplAbstract  impl;
	GpuState         state;

	DisplayList*     currentDisplayList;
	DisplayLists     displayLists;

	TaskQueue        externalActions;

	bool implInitialized;
	Thread thread;

	WaitEvent endedExecutingListsEvent;
	WaitEvent interruptedEvent;
	
	Event signalEvent;
	Event finishEvent;
	PspGeCallbackData pspGeCallbackData;
	bool recordFrameEnd = false;
	bool recordFrameStart = false;
	
	// Statistics.
	StopWatch gpuTimePerFrameStopWatch;
	StopWatch vertexExtractionStopWatch;
	StopWatch bufferTransferStopWatch;

	uint lastFrameTime;
	uint lastSetStateTime;
	uint lastVertexExtractionTime;
	uint lastDrawTime;
	uint lastBufferTransferTime;

	uint numberOfPrims, numberOfPrimsTemp;
	uint numberOfVertices, numberOfVerticesTemp;
	
	bool drawBufferTransferEnabled = true;
	bool justDrawOnVblank = false;
	
	WaitEvent initializedEvent;
	
	enum RecordFrameStep {
		doNone,
		doStart,
		doEnd
	}
	
	RecordFrameStep recordFrameStep = RecordFrameStep.doNone;

	public this(Memory memory, GpuImplAbstract impl) {
		this.endedExecutingListsEvent = new WaitEvent();
		this.initializedEvent = new WaitEvent();
		this.interruptedEvent = new WaitEvent();

		this.memory = memory;
		this.impl   = impl;

		this.reset();
	}

	public void reset() {
		this.externalActions = new TaskQueue;
		this.state = GpuState.init;
		this.state.reset();
		this.displayLists = new DisplayLists(1024);
		this.state.memory = memory;
		this.interruptedEvent.reset();
		this.signalEvent.reset();
		this.finishEvent.reset();
		this.running = true;
		
		this.externalActionAdd({
			this.impl.reset();
			this.impl.setState(&state);
		});
	}
	
	public void interrupt() {
		this.interruptedEvent.signal();
		this.running = false;
	}

	// Utility.
	static private pure string ArrayOperation(string vtype, int from, int to, string code, int step = 1) {
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

		void doassert(string file = __FILE__, int line = __LINE__) {
			logWarning("0x%08X: Stop %s : %s:%d", reinterpret!(uint)(&command), command, file, line);
			throw(new Exception(std.string.format("Unimplemented %s:%d", file, line)));
		}
		void unimplemented(string file = __FILE__, int line = __LINE__) {
			logWarning("0x%08X: Unimplemented %s : %s:%d", reinterpret!(uint)(&command), command, file, line);
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
		mixin Gpu_Spline;

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
			gpuTimePerFrameStopWatch.start();
			while (displayList.hasMore) {
				while (displayList.isStalled) {
					logTrace("  stalled() : %s", displayList);
					newWaitAndCheck([displayList.displayListNewDataEvent]);
				}
				lastCommandPointer = displayList.pointer;
				executeSingleCommand(displayList);
			}
			gpuTimePerFrameStopWatch.stop();
			newWaitAndCheck2();
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

	public void start() {
		thread = new Thread(&run);
		thread.name = "GpuThread";
		thread.start();
	}
	
	public void waitStarted() {
		initializedEvent.wait();
	}
	
	protected void run() {
		while (running) {
			try {
				if (!implInitialized) {
					impl.init();
					implInitialized = true;
					initializedEvent.signal();
				}
				//componentInitialized = true;
				while (running) {
					//writefln("[1]");
					//writefln("displayLists.readAvailable");
					endedExecutingListsEvent.reset();
					while (displayLists.readAvailable) {
						impl.startDisplayList();
						{
							executeList(displayLists.consume);
						}
						impl.endDisplayList();
					}
					endedExecutingListsEvent.signal();
					//if (runningState != RunningState.RUNNING) waitUntilResume();
					newWaitAndCheck([displayLists.readAvailableEvent]);
					newWaitAndCheck2();
				}
			} catch (HaltException e) {
				logDebug("Gpu.run HaltException: %s", e);
			} catch (Throwable e) {
				logCritical("Gpu.run exception: %s", e);
			} finally {
				logDebug("Gpu.shutdown");
			}
		}
	}

	template ExternalInterface() {
		// @TODO!!!! @FIXME!! change queue for queueHead
		DisplayList* _sceGeListEnQueue(void* list, void* stall = null, bool enqueueHead = false) {
			while (!displayLists.writeAvailable) {
				// @TODO: Must handle the ended execution event
				displayLists.writeAvailableEvent.wait(1);
			}
			DisplayList* ret = &displayLists.enqueue(DisplayList(list, stall));
			return ret;
		}
		
		DisplayList* sceGeListEnQueue(void* list, void* stall = null) { return _sceGeListEnQueue(list, stall, false); }
		DisplayList* sceGeListEnQueueHead(void* list, void* stall = null) { return _sceGeListEnQueue(list, stall, true); }
		void sceGeListUpdateStallAddr(DisplayList* displayList, void* stall) { displayList.stall = cast(Command*)stall; }
		void sceGeListDeQueue(DisplayList* displayList) { logWarning("Not implemented sceGeListDeQueue"); }

		/**
		 * Wait until the specified list have been executed.
		 */
		void sceGeListSync(DisplayList* displayList, int syncType) {
			while (displayList.hasMore) {
				newWaitAndCheck([displayList.displayListEndedEvent]);
			}

			performBufferOp2(BufferOperation.STORE);
		}
		
		void waitVblank() {
			uint lastFrameTimeTemp = cast(uint)gpuTimePerFrameStopWatch.peek().msecs;
			
			if (lastFrameTimeTemp != 0) {
				lastFrameTime = lastFrameTimeTemp;
			}
			
			lastSetStateTime = cast(uint)impl.setStateStopWatch.peek().msecs;
			lastDrawTime = cast(uint)impl.drawStopWatch.peek().msecs;
			lastVertexExtractionTime = cast(uint)vertexExtractionStopWatch.peek().msecs;
			lastBufferTransferTime = cast(uint)bufferTransferStopWatch.peek().msecs;
			
			if (numberOfPrimsTemp != 0) {
				numberOfPrims = numberOfPrimsTemp; numberOfPrimsTemp = 0;
			}

			if (numberOfVerticesTemp != 0) {
				numberOfVertices = numberOfVerticesTemp; numberOfVerticesTemp = 0;
			}

			//writefln("Frame: %s", lastFrameTime);
			gpuTimePerFrameStopWatch.reset();
			vertexExtractionStopWatch.reset();
			bufferTransferStopWatch.reset();
			impl.setStateStopWatch.reset();
			impl.drawStopWatch.reset();
			
			if (justDrawOnVblank) {
				performBufferOp(BufferOperation.STORE);
			}
		}
		
		/**
		 * Wait until all the remaining commands have been executed.
		 */
		void sceGeDrawSync(int syncType) {
			//writefln("sceGeDrawSync [1]");
			while (displayLists.readAvailable || executingDisplayList) {
				newWaitAndCheck([displayLists.readAvailableEvent, endedExecutingListsEvent]);
			}
			
			if (recordFrameStep == RecordFrameStep.doEnd) {
				recordFrameStep = RecordFrameStep.doNone;
				impl.recordFrameEnd();
			}
			
			performBufferOp2(BufferOperation.STORE);
			
			if (recordFrameStep == RecordFrameStep.doStart) {
				recordFrameStep = RecordFrameStep.doEnd;
				impl.recordFrameStart();
			}
		}
	}

	@property bool inDrawingThread() { return (Thread.getThis() == thread) || (thread is null); }
	
	void newWaitAndCheck(WaitEvent[] waitEvents, string file = __FILE__, int line = __LINE__) {
		scope WaitMultipleObjects waitMultipleObjects = new WaitMultipleObjects();
		waitMultipleObjects.add(interruptedEvent);
		if (inDrawingThread) waitMultipleObjects.add(externalActions.newAvailableTasksEvent);
		foreach (waitEvent; waitEvents) waitMultipleObjects.add(waitEvent);
		//writefln("[1 %s:%d]", file, line);
		waitMultipleObjects.waitAny(1);
		//writefln("[2]");
	}

	void newWaitAndCheck2() {
		if (!running) throw(new HaltException("Gpu Stopping Execution"));
		if (inDrawingThread) externalActions();
	}

	/*
	void externalActionAdd(TaskQueue.Task task) {
		if (inDrawingThread) {
			task();
		} else {
			externalActions.addAndWait(task);
		}
	}
	*/
	void externalActionAdd(TaskQueue.Task task, bool wait = true) {
		if (inDrawingThread) {
			externalActions.add(task);
			externalActions.executeAll();
		} else {
			externalActions.addAndWait(task);
		}
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

	void storeBuffer(ScreenBuffer* buffer, bool isDepthBuffer = false) {
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
	
	void performBufferOp2(BufferOperation bufferOperation, BufferType bufferType = BufferType.ALL) {
		if (!justDrawOnVblank) {
			performBufferOp(bufferOperation, bufferType);
		}
	}
	
	void performBufferOp(BufferOperation bufferOperation, BufferType bufferType = BufferType.ALL) {
		bufferTransferStopWatch.start(); scope (exit) bufferTransferStopWatch.stop();

		//if (!drawBufferTransferEnabled) return;
		
		if (bufferOperation == BufferOperation.LOAD) {
			if (state.drawBuffer.storeAddress) logTrace("performBufferOp(LOAD) has state.drawBuffer.mustStore. It wasn't stored yet!");
			if (bufferType & BufferType.COLOR) loadBuffer(&state.drawBuffer);
			if (bufferType & BufferType.DEPTH) loadBuffer(&state.depthBuffer);
		} else {
			if (state.drawBuffer.loadAddress) logTrace("performBufferOp(STORE) has state.drawBuffer.mustLoad. It wasn't stored yet!");
			if (bufferType & BufferType.COLOR) storeBuffer(&state.drawBuffer);
			if (bufferType & BufferType.DEPTH) storeBuffer(&state.depthBuffer, /*isDepthBuffer=*/true);
		}
	}
	
	void recordFrame() {
		recordFrameStep = RecordFrameStep.doStart;
	}

	mixin ExternalInterface;
	
	mixin Logger.DebugLogPerComponent!"Gpu";
}
