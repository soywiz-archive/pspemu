module pspemu.hle.vfs.ProxyVirtualFileSystem;

public import pspemu.hle.vfs.VirtualFileSystem;

class ProxyVirtualFileSystem : VirtualFileSystem {
	VirtualFileSystem parentVirtualFileSystem;
	
	this(VirtualFileSystem parentVirtualFileSystem) {
		this.parentVirtualFileSystem = parentVirtualFileSystem;
	}
	
	void init() {
		this.parentVirtualFileSystem.init();
	}
	
	void exit() {
		this.parentVirtualFileSystem.exit();
	}
	
	VirtualFileSystem rewriteFileSystemAndPath(VirtualFileSystem virtualFileSystem, ref string path) {
		path = path;
		return virtualFileSystem;
	}
	
	FileStat rewriteReadedFileStat(FileStat fileStat) {
		return fileStat;
	}

	FileStat rewriteFileStatToWrite(FileStat fileStat) {
		return fileStat;
	}
	
	override FileHandle open(string file, FileOpenMode flags, FileAccessMode mode) {
		VirtualFileSystem newFileSystem = rewriteFileSystemAndPath(parentVirtualFileSystem, file);
		return newFileSystem.open(file, flags, mode);
	}

	override void close(FileHandle handle) {
		handle.virtualFileSystem.close(handle);
	}

	override int read(FileHandle handle, ubyte[] data) {
		return handle.virtualFileSystem.read(handle, data);
	}

	override int write(FileHandle handle, ubyte[] data) {
		return handle.virtualFileSystem.write(handle, data);
	}

	override long seek(FileHandle handle, long offset, Whence whence) {
		return handle.virtualFileSystem.seek(handle, offset, whence);
	}

	override void unlink(string file) {
		VirtualFileSystem newFileSystem = rewriteFileSystemAndPath(parentVirtualFileSystem, file);
		newFileSystem.unlink(file);
	}

	override void mkdir(string file, FileAccessMode mode) {
		VirtualFileSystem newFileSystem = rewriteFileSystemAndPath(parentVirtualFileSystem, file);
		newFileSystem.mkdir(file, mode);
	}

	override void rmdir(string file) {
		VirtualFileSystem newFileSystem = rewriteFileSystemAndPath(parentVirtualFileSystem, file);
		newFileSystem.rmdir(file);
	}

	override DirHandle dopen(string file) {
		VirtualFileSystem newFileSystem = rewriteFileSystemAndPath(parentVirtualFileSystem, file);
		return newFileSystem.dopen(file);
	}

	override void dclose(DirHandle handle) {
		handle.virtualFileSystem.dclose(handle);
	}
	
	override FileEntry dread(DirHandle handle) {
		return handle.virtualFileSystem.dread(handle);
	}
	
	override FileStat getstat(string file) {
		VirtualFileSystem newFileSystem = rewriteFileSystemAndPath(parentVirtualFileSystem, file);
		return newFileSystem.getstat(file);
	}

	override void setstat(string file, FileStat stat) {
		VirtualFileSystem newFileSystem = rewriteFileSystemAndPath(parentVirtualFileSystem, file);
		return newFileSystem.setstat(file, rewriteFileStatToWrite(stat));
	}
	
	override void rename(string oldname, string newname) {
		VirtualFileSystem newFileSystem = rewriteFileSystemAndPath(parentVirtualFileSystem, oldname);
		return newFileSystem.rename(oldname, newname);
	}

	override int ioctl(FileHandle fileHandle, uint cmd, ubyte[] indata, ubyte[] outdata) {
		return parentVirtualFileSystem.ioctl(fileHandle, cmd, indata, outdata);
	}

	override int devctl(string devname, uint cmd, ubyte[] indata, ubyte[] outdata) {
		return parentVirtualFileSystem.devctl(devname, cmd, indata, outdata);
	}
}