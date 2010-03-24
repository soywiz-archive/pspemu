module pspemu.models.IDisplay;

import std.c.windows.windows;

import std.stdio;

import pspemu.utils.Utils;

/**
 * Interface for the Display.
 */
interface IDisplay {
	static struct Size { int x, y; alias x width; alias y height; }
	static struct Info {
		uint topaddr = /*Memory.frameBufferAddress*/0x04_000000;
		int bufferwidth = 512;
		int pixelformat = 3;
		int sync = 0;
		int mode = 0;
		int width = 480;
		int height = 272;
	}

	Info info(Info info);
	Info info();

	/**
	 * Returns a pointer to the begin of the frameBuffer.
	 */
	void* frameBufferPointer();

	int frameBufferPixelFormat();

	/**
	 * Returns the size of the frameBuffer Size(512, 272).
	 */
	Size frameBufferSize();

	/**
	 * Returns the size of the visible screen Size(480, 272).
	 */
	Size displaySize();

	/**
	 * Returns the refresh rate 60hz.
	 */
	int verticalRefreshRate();

	/**
	 * Triggers an vblank event.
	 */
	bool vblank(bool status);

	/**
	 * Obtains the status of the vblank.
	 */
	bool vblank();

	/**
	 * Wait vblank.
	 */
	void waitVblank();
}

abstract class BasePspDisplay : IDisplay {
	Info _info;
	Info info(Info info) { return _info = info; }
	Info info() { return _info; }
	
	int frameBufferPixelFormat() { return _info.pixelformat; }

	Size frameBufferSize() { return Size(512, 272); }
	Size displaySize() { return Size(480, 272); }
	int verticalRefreshRate() { return 60; }
	
	this() {
	}
	
	void waitVblank() {
		InfiniteLoop!(512) loop;
		while (vblank) {
			Sleep(1);
			loop.increment();
		}
		while (!vblank) {
			Sleep(1);
			loop.increment();
		}
	}
}

class NullDisplay : BasePspDisplay {
	uint[] data;

	this() {
		data = new uint[512 * 272];
		for (int y = 0, n = 0; y < 272; y++) {
			for (int x = 0; x < 512; x++) {
				if (((x / 32) % 2) ^ ((y / 16) % 2)) {
					data[n++] = 0xFFFFFFFF;
				} else {
					data[n++] = 0x00000000;
				}
			}
		}
		super();
	}
	void* frameBufferPointer() { return data.ptr; }
	bool vblank() { return false; }
	bool vblank(bool status) { return vblank; }
}
