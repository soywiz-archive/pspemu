module pspemu.hle.vfs.devices.UmdDevice;

import pspemu.hle.vfs.devices.IoDevice;
import pspemu.hle.vfs.IsoFileSystem;

import pspemu.utils.Logger;
import pspemu.hle.kd.SceKernelErrors;

enum IoUmdCtlCommand {
	UmdSeekFile           = 0x01010005,
	GetUmdFileStartSector = 0x01020006,
	GetUmdFileLength      = 0x01020007,
}

class UmdDevice : IoDevice {
	this(HleEmulatorState hleEmulatorState, VirtualFileSystem parentVirtualFileSystem) {
		super(hleEmulatorState, parentVirtualFileSystem);
	}

	override int ioctl(FileHandle fileHandle, uint cmd, ubyte[] indata, ubyte[] outdata) {
		IoUmdCtlCommand command = cast(IoUmdCtlCommand)cmd;
		switch (command) {
			case IoUmdCtlCommand.UmdSeekFile: {
				uint seekOffset = *(cast(uint*)indata.ptr);
				fileHandle.position = seekOffset;
				Logger.log(Logger.Level.INFO, "UmdDevice", "Seek: %d", seekOffset);
				return 0;
			} break;
			case IoUmdCtlCommand.GetUmdFileStartSector: {
				if (outdata.length < 4) return SceKernelErrors.ERROR_INVALID_ARGUMENT;
				if (fileHandle is null) return SceKernelErrors.ERROR_INVALID_ARGUMENT;
				
				IsoFileHandle isoFileHandle = cast(IsoFileHandle)fileHandle;
				
				uint sector = cast(uint)isoFileHandle.isoNode.directoryRecord.extent;
				*(cast(uint*)outdata.ptr) = sector;
				Logger.log(Logger.Level.INFO, "UmdDevice", "Sector: %d", sector);
				return 0;
			} break;
			case IoUmdCtlCommand.GetUmdFileLength: {
				if (outdata.length < 8) return SceKernelErrors.ERROR_INVALID_ARGUMENT;
				if (fileHandle is null) return SceKernelErrors.ERROR_INVALID_ARGUMENT;
				*(cast(ulong*)outdata.ptr) = cast(ulong)fileHandle.size;
				Logger.log(Logger.Level.INFO, "UmdDevice", "File Size: %d", fileHandle.size);
				return 0;
			} break;
			default:
				throw(new Exception(std.string.format("Unknown IoCtrlCommand 0x%08X (UmdDevice)", cmd)));
			break;
		}
		//throw(new Exception("Must implemente ioctl"));
	}

	override int devctl(string devname, uint cmd, ubyte[] indata, ubyte[] outdata) {
		throw(new Exception("Must implemente devctl (UmdDevice)"));
	}
}