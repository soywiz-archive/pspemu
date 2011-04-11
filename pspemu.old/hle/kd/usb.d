module pspemu.hle.kd.usb; // kd/usb.prx (sceUSB_Driver):

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class sceUsb : Module {
	void initNids() {
		mixin(registerd!(0xAE5DE6AF, sceUsbStart));
		mixin(registerd!(0x586DB82C, sceUsbActivate));
		mixin(registerd!(0xC572A9C8, sceUsbDeactivate));
		mixin(registerd!(0xC2464FA0, sceUsbStop));
		mixin(registerd!(0xC21645A4, sceUsbGetState));
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

	/**
	 * Stop a USB driver.
	 * 
	 * @param driverName - name of the USB driver to stop
	 * @param size - Size of arguments to pass to USB driver start
	 * @param args - Arguments to pass to USB driver start
	 *
	 * @return 0 on success
	 */
	int sceUsbStop(string driverName, int size, void* args) {
		unimplemented();
		return -1;
	}

	/**
	 * Get USB state
	 * 
	 * @return OR'd PSP_USB_* constants
	 */
	int sceUsbGetState() {
		unimplemented();
		return -1;
	}
}

static this() {
	mixin(Module.registerModule("sceUsb"));
}
