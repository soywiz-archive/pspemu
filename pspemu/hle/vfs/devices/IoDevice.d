module pspemu.hle.vfs.devices.IoDevice;

public import pspemu.hle.vfs.ProxyVirtualFileSystem;
public import pspemu.hle.HleEmulatorState;

struct DeviceSize {
	/**
	 * Total number of clusters on the device.
	 */
	uint totalClusters;

	/**
	 * Number of free clusters on the device.
	 */
	uint freeClusters;

	/**
	 * ???
	 */
	uint maxSectors;

	/**
	 * Sector size in bytes.
	 */
	uint sectorSize;

	/**
	 * Number of sectors per each cluster.
	 */
	uint sectorsPerCluster;
	
	/**
	 * Size in bytes of each cluster.
	 */
	uint clusterSize() {
		return sectorSize * sectorsPerCluster;
	}
}

class IoDevice : ProxyVirtualFileSystem {
	HleEmulatorState hleEmulatorState;
	
	this(HleEmulatorState hleEmulatorState, VirtualFileSystem parentVirtualFileSystem) {
		super(parentVirtualFileSystem);
		this.hleEmulatorState = hleEmulatorState;
	}

	override int ioctl(FileHandle fileHandle, uint cmd, ubyte[] indata, ubyte[] outdata) {
		throw(new Exception("Must implemente ioctl (IoDevice)"));
	}

	override int devctl(string devname, uint cmd, ubyte[] indata, ubyte[] outdata) {
		throw(new Exception("Must implemente devctl (IoDevice)"));
	}
	
	bool present() { return true; }
	
	bool inserted() { return true; }
	bool inserted(bool value) { return true; }
}