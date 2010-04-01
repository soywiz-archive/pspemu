module pspemu.models.IDisplay;

import std.c.windows.windows;

import std.stdio;

import pspemu.utils.Utils;

/**
 * Interface for the Display.
 */
abstract class Display {
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

	bool frameLimiting = true;
	//bool frameLimiting = false;

	Info info;

	uint VBLANK_COUNT;

	uint fpsCounter;

	/**
	 * Returns a pointer to the begin of the frameBuffer.
	 */
	abstract void* frameBufferPointer();

	void reset() {
		VBLANK_COUNT = 0;
	}

	int frameBufferPixelFormat() { return info.pixelformat; }

	/**
	 * Returns the size of the frameBuffer Size(512, 272).
	 */
	Size frameBufferSize() { return Size(512, 272); }

	/**
	 * Returns the size of the visible screen Size(480, 272).
	 */
	Size displaySize() { return Size(480, 272); }

	/**
	 * Returns the refresh rate 60hz.
	 */
	int verticalRefreshRate() { return 60; }
}

class NullDisplay : Display {
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
	}
	void* frameBufferPointer() { return data.ptr; }
}
