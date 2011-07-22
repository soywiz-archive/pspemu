module pspemu.hle.vfs.devices.MemoryStickDevice;

public import pspemu.hle.vfs.devices.IoDevice;

import pspemu.core.cpu.CpuThreadBase;
import pspemu.hle.Callbacks;
import pspemu.utils.Logger;
import pspemu.hle.kd.SceKernelErrors;

import std.stdio;

class MemoryStickDevice : IoDevice {
	bool _inserted = true;

	this(HleEmulatorState hleEmulatorState, VirtualFileSystem parentVirtualFileSystem) {
		super(hleEmulatorState, parentVirtualFileSystem);
	}

	override bool inserted() { return _inserted; }
	uint insertedValue() { return inserted ? 1 : 2; }
	override bool inserted(bool value) {
		if (_inserted != value) {
			_inserted = value;
			triggerInsertedOnCallbackThread();
		}
		return _inserted;
	}
	
	void triggerInsertedOnCallbackThread() {
		Logger.log(Logger.Level.INFO, "Devices", "MemoryStickDevice.setInserted: %d", inserted);

		hleEmulatorState.callbacksHandler.trigger(
			CallbacksHandler.Type.MemoryStickInsertEject,
			[0, insertedValue, 0]
		);
	}
	
	uint triggerInsertedOnCurrentThread(CpuThreadBase cpuThreadBase, uint callbackPtr) {
		return hleEmulatorState.executeGuestCode(cpuThreadBase.threadState, callbackPtr, [0, inserted ? 1 : 2, 0]);
	}

	override int ioctl(FileHandle fileHandle, uint cmd, ubyte[] indata, ubyte[] outdata) {
		throw(new Exception("Must implemente ioctl (MemoryStickDevice)"));
	}

	override int devctl(string devname, uint cmd, ubyte[] inData, ubyte[] outData) {
		PspCallback pspCallback;

		switch (cmd) {
			case 0x02425823: // Check if the device is assigned/inserted (fatms0).
                // 0 - Device is not assigned (callback not registered).
                // 1 - Device is assigned (callback registered).
                *(cast(uint*)outData.ptr) = 1;
                return 0;
			break;
			case 0x02025806: // MScmIsMediumInserted
				Logger.log(Logger.Level.INFO, "Devices", "MScmIsMediumInserted");
				*(cast(uint*)outData.ptr) = insertedValue;
				//*(cast(uint*)outData.ptr) = inserted;
				return 0;
			break;
			case 0x02415821: // MScmRegisterMSInsertEjectCallback
				Logger.log(Logger.Level.INFO, "Devices", "MScmRegisterMSInsertEjectCallback");
				
				if (devname != "fatms0:") return SceKernelErrors.ERROR_MEMSTICK_DEVCTL_BAD_PARAMS;
				if (inData.ptr == null || inData.length < 4) return -1;

				uint callbackId = *(cast(uint*)inData.ptr);
				pspCallback = hleEmulatorState.uniqueIdFactory.get!PspCallback(callbackId);
				hleEmulatorState.callbacksHandler.register(CallbacksHandler.Type.MemoryStickInsertEject, pspCallback);
				
				if (outData.ptr != null && outData.length >= 4) { 
					*(cast(uint*)outData.ptr) = 0;
				}
				
				// Trigger callback immediately
				// @TODO: CHECK
				//triggerInsertedOnCurrentThread(cpuThreadBase, callbackPtr);
				triggerInsertedOnCallbackThread();
				
				return 0;
			break;
			case 0x02415822: // MScmUnregisterMSInsertEjectCallback
				Logger.log(Logger.Level.INFO, "Devices", "MScmUnregisterMSInsertEjectCallback");
			
				pspCallback = hleEmulatorState.uniqueIdFactory.get!PspCallback(*(cast(uint*)inData.ptr));
				hleEmulatorState.callbacksHandler.unregister(CallbacksHandler.Type.MemoryStickInsertEject, pspCallback);
				
				return 0;
			break;
			case 0x02425818:
				// 2 GB
				ulong totalSize = 2 * 1024 * 1024 * 1024;
				ulong freeSize  = 1 * 1024 * 1024 * 1024;
			
				DeviceSize* deviceSize       = cast(DeviceSize*)hleEmulatorState.emulatorState.memory.getPointer(*cast(uint *)inData.ptr);
				deviceSize.maxSectors        = 512;
				deviceSize.sectorSize        = 0x200;
				deviceSize.sectorsPerCluster = 0x08;
				deviceSize.totalClusters     = cast(uint)((totalSize * 95 / 100) / deviceSize.clusterSize);
				deviceSize.freeClusters      = cast(uint)((freeSize  * 95 / 100) / deviceSize.clusterSize);
				return 0;
			break;
			case 0x02025801: // Check the MemoryStick's driver status (mscmhc0).
				*(cast(uint*)outData.ptr) = 1;
				return 0;
			break;
			default: // Unknown command
				Logger.log(Logger.Level.ERROR, "Devices", "MemoryStickDevice.sceIoDevctl: Unknown command 0x%08X!", cmd);
				return -1;
			break;
		}
	}
}