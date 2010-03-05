module pspemu.models.IDisplay;

/**
 * Interface for the Display.
 */
interface IDisplay {
	static struct Size { int x, y; alias x width; alias y height; }

	/**
	 * Returns a pointer to the begin of the frameBuffer.
	 */
	void* frameBufferPointer();

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
	void vblank(bool status);
}

abstract class BasePspDisplay : IDisplay {
	Size frameBufferSize() { return Size(512, 272); }
	Size displaySize() { return Size(480, 272); }
	int verticalRefreshRate() { return 60; }
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
	}
	void* frameBufferPointer() { return data.ptr; }
	void vblank(bool status) { }
}
