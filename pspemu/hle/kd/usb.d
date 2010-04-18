module pspemu.hle.kd.usb; // kd/usb.prx (sceUSB_Driver):

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class sceUsb : Module {
	void initNids() {
		mixin(registerd!(0xAE5DE6AF, sceUsbStart));
		mixin(registerd!(0x586DB82C, sceUsbActivate));
		mixin(registerd!(0xC572A9C8, sceUsbDeactivate));
	}

	/**
	 * Start a USB driver.
	 * 
	 * @param driverName - name of the USB driver to start
	 * @param size - Size of arguments to pass to USB driver start
	 * @param args - Arguments to pass to USB driver start
	 *
	 * @return 0 on success
	 */
	int sceUsbStart(string driverName, int size, void* args) {
		unimplemented();
		return -1;
	}

	/**
	 * Activate a USB driver.
	 * 
	 * @param pid - Product ID for the default USB Driver
	 *
	 * @return 0 on success
	 */
	int sceUsbActivate(u32 pid) {
		unimplemented();
		return -1;
	}

	/**
	 * Deactivate USB driver.
	 *
	 * @param pid - Product ID for the default USB driver
	 * 
	 * @return 0 on success
	 */
	int sceUsbDeactivate(u32 pid) {
		unimplemented();
		return -1;
	}
}

static this() {
	mixin(Module.registerModule("sceUsb"));
}
