module pspemu.core.gpu.Gpu;

debug = GPU_UNKNOWN_COMMANDS;
//debug = GPU_UNKNOWN_COMMANDS_STOP;

import core.thread;

import std.c.windows.windows;
import std.windows.syserror;
import std.stdio, std.bitmanip;

import std.contracts;

import pspemu.utils.Utils;
import pspemu.utils.OpenGL;

import pspemu.core.Memory;
import pspemu.core.gpu.Commands;

import pspemu.core.gpu.ops.Special;
import pspemu.core.gpu.ops.Flow;
import pspemu.core.gpu.ops.Colors;
import pspemu.core.gpu.ops.Draw;

extern (Windows) {
	bool  SetPixelFormat(HDC, int, PIXELFORMATDESCRIPTOR*);
	bool  SwapBuffers(HDC);
	int   ChoosePixelFormat(HDC, PIXELFORMATDESCRIPTOR*);
	HBITMAP CreateDIBSection(HDC hdc, const BITMAPINFO *pbmi, UINT iUsage, VOID **ppvBits, HANDLE hSection, DWORD dwOffset);
	const uint BI_RGB = 0;
	const uint DIB_RGB_COLORS = 0;
}

class Gpu {
	Memory memory;

	bool _running;
	Command* list, stall;

	Info info;
	Thread thread;

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

		//int _address = 0;
		int _address = 0x04_000000;

		int address(int value) { return _address = 0x04_000000 | value; }
		int address() { return _address; }
		/*
		int formatGl() { return PIXELF_T[format].opengl; }
		float psize() { return PIXELF_T[format].size; }
		*/

		void* pointer() { return memory.getPointer(_address); }
	}

	struct Colorf {
		union {
			struct { float[4] components; }
			struct { float r, g, b, a; }
			struct { float red, green, blue, alpha; }
		}
	}

	class Info {
		ScreenBuffer drawBuffer, displayBuffer;
		uint baseAddress;
		uint vertexAddress;
		uint indexAddress;
		int  clearFlags;
		VertexType vertexType;
		Colorf ambientModelColor, diffuseModelColor, specularModelColor;

		void *vertexPointer() { return memory.getPointer(vertexAddress); }
		void *indexPointer () { return memory.getPointer(indexAddress); }
	}

	this(Memory memory) {
		this.memory = memory;
		info = new Info;
		info.drawBuffer    = new ScreenBuffer;
		info.displayBuffer = new ScreenBuffer;
	}

	void start() {
		if (running) return;
		thread = new Thread(&run);
		thread.start();
	}

	void stop() {
		_running = false;
	}

	bool running() { return _running && (thread && thread.isRunning); }

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
		mixin Gpu_Colors;
		mixin Gpu_Draw;

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

	HDC hdc;
	HGLRC hglrc;
	uint *bitmapData;

	void initializeOpenGL() {
		// http://nehe.gamedev.net/data/lessons/lesson.asp?lesson=41
		// http://msdn.microsoft.com/en-us/library/ms970768.aspx
		// http://www.codeguru.com/cpp/g-m/opengl/article.php/c5587
		// PFD_DRAW_TO_BITMAP
		HBITMAP hbmpTemp;
		PIXELFORMATDESCRIPTOR pfd;
		BITMAPINFO bi;
		
		hdc = CreateCompatibleDC(GetDC(null));

		bi.bmiHeader.biSize			= BITMAPINFOHEADER.sizeof;
		bi.bmiHeader.biBitCount		= 32;
		bi.bmiHeader.biWidth		= 512;
		bi.bmiHeader.biHeight		= 272;
		bi.bmiHeader.biCompression	= BI_RGB;
		bi.bmiHeader.biPlanes		= 1;

		hbmpTemp = enforce(CreateDIBSection(hdc, &bi, DIB_RGB_COLORS, cast(void **)&bitmapData, null, 0));
		enforce(SelectObject(hdc, hbmpTemp));
		
        pfd.nSize = pfd.sizeof;
        pfd.nVersion = 1;
		pfd.dwFlags = PFD_DRAW_TO_BITMAP | PFD_SUPPORT_OPENGL | PFD_SUPPORT_GDI;
		pfd.iPixelType = PFD_TYPE_RGBA;
		pfd.cColorBits = 32;
		pfd.cRedBits = 0;
		pfd.cRedShift = 0;
		pfd.cGreenBits = 0;
		pfd.cGreenShift = 0;
		pfd.cBlueBits = 0;
		pfd.cBlueShift = 0;
		pfd.cAlphaBits = 0;
		pfd.cAlphaShift = 0;
		pfd.cAccumBits = 0;
		pfd.cAccumRedBits = 0;
		pfd.cAccumGreenBits = 0;
		pfd.cAccumBlueBits = 0;
		pfd.cAccumAlphaBits = 0;
		pfd.cDepthBits = 32;
		pfd.cStencilBits = 0;
		pfd.cAuxBuffers = 0;
		pfd.iLayerType = PFD_MAIN_PLANE;
		pfd.bReserved = 0;
		pfd.dwLayerMask = 0;
		pfd.dwVisibleMask = 0;
		pfd.dwDamageMask = 0;

		enforce(SetPixelFormat(
			hdc,
			enforce(ChoosePixelFormat(hdc, &pfd)),
			&pfd
		));

		hglrc = enforce(wglCreateContext(hdc));
		openglMakeCurrent();
	}

	void openglMakeCurrent() {
		wglMakeCurrent(null, null);
		wglMakeCurrent(hdc, hglrc);
		assert(wglGetCurrentDC() == hdc);
		assert(wglGetCurrentContext() == hglrc);
	}

	private void run() {
		try {
			//Sleep(5000);
			initializeOpenGL();
			_running = true;
			while (_running) {
				while (hasMoreToProcess) process(*list++);
				//Thread.sleep(0_5000);
				Sleep(1);
			}
		} catch (Object o) {
			writefln("Gpu.run exception: %s", o);
		}
	}

	void loadFrameBuffer() {
		bitmapData[0..512 * 272] = (cast(uint *)memory.getPointer(info.drawBuffer.address))[0..512 * 272];
	}

	void storeFrameBuffer() {
		(cast(uint *)memory.getPointer(info.drawBuffer.address))[0..512 * 272] = bitmapData[0..512 * 272];
	}

	template ExternalInterface() {
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
			while (running && hasMoreToProcess) {
				//Thread.sleep(0_5000);
				Sleep(1);
			}

			storeFrameBuffer();
		}
	}

	mixin ExternalInterface;
}