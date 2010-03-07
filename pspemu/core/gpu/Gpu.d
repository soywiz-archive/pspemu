module pspemu.core.gpu.Gpu;

debug = GPU_UNKNOWN_COMMANDS;
//debug = GPU_UNKNOWN_COMMANDS_STOP;

import core.thread;

import std.c.windows.windows;
import std.stdio, std.bitmanip;

import pspemu.utils.Utils;
import pspemu.utils.OpenGL;

import pspemu.core.Memory;
import pspemu.core.gpu.Commands;

import pspemu.core.gpu.ops.Special;
import pspemu.core.gpu.ops.Flow;

class Gpu {
	Memory memory;

	bool running;
	Command* list, stall;

	struct VertexType {
		union {
			uint v;
			struct {
				mixin(bitfields!(
					uint, "texture",  2,
					uint, "color",    3,
					uint, "normal",   2,
					uint, "position", 2,
					uint, "weight",   2,
					uint, "index",    2,
					uint, "__0",      1,
					uint, "skinningWeightCountM1", 3,
					uint, "__1",      1,
					uint, "morphingVertexCount",   2,
					uint, "__2",      3,
					uint, "transform2D",           1,
					uint, "__3",      8
				));
				uint skinningWeightCount() { return skinningWeightCountM1 + 1; }
			}
		}
	}

	class ScreenBuffer {
		public int width  = 512;
		public int format = 3;

		int _address = 0;
		
		int address(int value) { return _address = 0x04000000 | value; }
		int address() { return _address; }
		/*
		int formatGl() { return PIXELF_T[format].opengl; }
		float psize() { return PIXELF_T[format].size; }
		*/
		
		void* pointer() { return memory.getPointer(_address); }
	}

	class Info {
		ScreenBuffer drawBuffer, displayBuffer;
		uint baseAddress;
		uint vertexAddress;
		uint indexAddress;
		int  clearFlags;
		VertexType vertexType;
		
		void *vertexPointer() { return memory.getPointer(vertexAddress); }
		void *indexPointer () { return memory.getPointer(indexAddress); }
	}

	Info info;

	this(Memory memory) {
		this.memory = memory;
		info = new Info;
		info.drawBuffer    = new ScreenBuffer;
		info.displayBuffer = new ScreenBuffer;
	}

	void start() {
		running = true;
		(new Thread(&run)).start();
	}

	void stop() {
		running = false;
	}

	void process(ref Command command) {
		Gpu gpu = this;

		void unimplemented() {
			debug (GPU_UNKNOWN_COMMANDS) {
				writefln("0x%08X: Unimplemented %s", reinterpret!(uint)(&command), command);
			}
		}
		void doassert() {
			writefln("0x%08X: Stop %s", reinterpret!(uint)(&command), command);
			assert(0);
		}
		
		mixin Gpu_Special;
		mixin Gpu_Flow;

		mixin({
			string s;
			s ~= "switch (command.opcode) {";
			for (int n = 0; n < 0x100; n++) {
				s ~= "case " ~ tos(n) ~ ":";
				{
					string opname = enumToString(cast(Opcode)n);
					string func = "OP_" ~ opname;
					s ~= "mixin(\"static if (__traits(compiles, " ~ func ~ ")) { " ~ func ~ "(); } else { unimplemented(); }\");";
				}
				s ~= "break;";
			}
			s ~= "default: unimplemented(); break;";
			s ~= "}";
			return s;
		}());
	}

	protected bool hasMoreToProcess() { return (stall >= list + 4); }

	private void run() {
		while (running) {
			while (hasMoreToProcess) process(*list++);
			Thread.sleep(0_5000);
		}
	}

	void setInstructionList(void *list, void *stall = null) {
		this.stall = cast(Command *)stall;
		this.list  = cast(Command *)list;
	}

	void setInstructionStall(void *stall) {
		//if (this.list == this.stall) writefln("New data! %s", *cast(Command *)this.list);
		this.stall = cast(Command *)stall;
	}

	/**
	 * Wait until all the remaining commands have been executed.
	 */
	void synchronizeGpu() {
		while (running && hasMoreToProcess) Thread.sleep(0_5000);
	}
}