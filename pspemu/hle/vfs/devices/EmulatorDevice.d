module pspemu.hle.vfs.devices.EmulatorDevice;

import pspemu.hle.vfs.devices.IoDevice;
import pspemu.hle.vfs.EmulatorFileSystem;

import pspemu.utils.Logger;
import pspemu.hle.kd.SceKernelErrors;

enum IoEmulatorCtlCommand {
	GetHasDisplay = 0x00000001,
}

class EmulatorDevice : IoDevice {
	this(HleEmulatorState hleEmulatorState, VirtualFileSystem parentVirtualFileSystem) {
		super(hleEmulatorState, parentVirtualFileSystem);
	}

	override int ioctl(FileHandle fileHandle, uint cmd, ubyte[] indata, ubyte[] outdata) {
		throw(new Exception("Must implemente ioctl (EmulatorDevice)"));
	}

	override int devctl(string devname, uint cmd, ubyte[] indata, ubyte[] outdata) {
		IoEmulatorCtlCommand command = cast(IoEmulatorCtlCommand)cmd;
		switch (command) {
			case IoEmulatorCtlCommand.GetHasDisplay: {
				//uint seekOffset = *(cast(uint*)indata.ptr);
				//fileHandle.position = seekOffset;
				uint hasDisplay = hleEmulatorState.osConfig.enabledDisplay;
				*(cast(uint*)(outdata.ptr)) = hasDisplay;
				Logger.log(Logger.Level.INFO, "EmulatorDevice", "GetHasDisplay: %d", hasDisplay);
				return 0;
			} break;
			default:
				throw(new Exception(std.string.format("Unknown IoCtrlCommand 0x%08X (EmulatorDevice)", cmd)));
			break;
		}
	}
}