module pspemu.hle.vfs.VirtualFileSystem;

//import std.stdio;
public import std.stream;
public import std.conv;
public import std.datetime;

public import pspemu.Exceptions;

class FileNotExistsException : Exception {
	this(string msg) { super(msg); }
}

enum FileAccessMode : uint {
	All          = octal!777,
	
	UserRead     = 0b001 << (3 * 0),
	UserWrite    = 0b010 << (3 * 0),
	UserExecute  = 0b110 << (3 * 0),

	GroupRead    = 0b001 << (3 * 1),
	GroupWrite   = 0b010 << (3 * 1),
	GroupExecute = 0b110 << (3 * 1),

	OtherRead    = 0b001 << (3 * 2),
	OtherWrite   = 0b010 << (3 * 2),
	OtherExecute = 0b110 << (3 * 2),
}

enum FileOpenMode {
	In     = 1,
	Out    = 2,
	OutNew = 4 | 2,
	Append = 8 | 2,
}

enum Whence {
	Set     = 0,
	Current = 1,
	End     = 2,
}

class FileStat {
	VirtualFileSystem virtualFileSystem;
	uint     permissions;
	bool     isDir;
	bool     isRoot;
	ulong    size;
	SysTime  ctime;
	SysTime  atime;
	SysTime  mtime;
	uint     sectorOffset;
	
	this(VirtualFileSystem virtualFileSystem) {
		this.virtualFileSystem = virtualFileSystem;
	}

	string toString() {
		return std.string.format("FileStat(size:%d, isDir:%s, ctime:%s)", size, isDir, ctime);
	}
}

class FileEntry {
	VirtualFileSystem virtualFileSystem;
	FileStat stat;
	string name;
	
	this(VirtualFileSystem virtualFileSystem) {
		this.virtualFileSystem = virtualFileSystem;
	}
	
	string toString() {
		return std.string.format("FileEntry('%s', %s)", name, stat);
	}
}

class FileHandle : Stream {
	VirtualFileSystem virtualFileSystem;
	ulong lastOperationResult;
	
	this(VirtualFileSystem virtualFileSystem) {
		this.virtualFileSystem = virtualFileSystem;
		this.readable  = true;
		this.writeable = true;
		this.seekable  = true;
	}
	
	T get(T = FileHandle)(VirtualFileSystem virtualFileSystem = null) {
		if (virtualFileSystem !is null) {
			if (this.virtualFileSystem != virtualFileSystem) throw(new Exception("Invalid filesystem"));
		}
		return cast(T)this;
	}
	
	void flush() {
	}
	
	void close() {
		flush();
		virtualFileSystem.close(this);
	}
	
	size_t readBlock(void* buffer, size_t size) {
		return virtualFileSystem.read(this, (cast(ubyte *)buffer)[0..size]);
	}

	size_t writeBlock(const void* buffer, size_t size) {
		virtualFileSystem.write(this, (cast(ubyte *)buffer)[0..size]);
		return size;
	}

	ulong seek(long offset, SeekPos whence) {
		return virtualFileSystem.seek(this, offset, cast(Whence)whence);
	}
}

class StreamFileHandle : FileHandle {
	Stream stream;
	
	public this(VirtualFileSystem virtualFileSystem, Stream stream) {
		super(virtualFileSystem);
		this.stream = stream;
	}
}

template VirtualFileSystem_Stream() {
	Stream getStreamFromHandle(FileHandle handle) {
		return handle.get!StreamFileHandle(this).stream;
	}
	
	override void close(FileHandle handle) {
		Stream stream = getStreamFromHandle(handle);
		stream.flush(); 
		stream.close();
	}
	
	override int read(FileHandle handle, ubyte[] data) {
		return getStreamFromHandle(handle).read(data);
	}
	
	override int write(FileHandle handle, ubyte[] data) {
		return getStreamFromHandle(handle).write(data);
	}
	
	override long seek(FileHandle handle, long offset, Whence whence) {
		return getStreamFromHandle(handle).seek(offset, cast(SeekPos)whence);
	}
}

class DirHandle {
	VirtualFileSystem virtualFileSystem;

	this(VirtualFileSystem virtualFileSystem) {
		this.virtualFileSystem = virtualFileSystem;
	}
	
	int opApply(int delegate(ref FileEntry) dg) {
		int result = 0;
		FileEntry fileEntry;
		while ((fileEntry = virtualFileSystem.dread(this)) !is null) {
		    result = dg(fileEntry);
		    if (result) break;
		}
		return result;
	}
}

class VirtualFileSystem {
	void init() {
	}
	
	void exit() {
	}
	
	/*
	string getInternalPath(string path) {
		return path;
	}
	*/
	
	FileHandle open(string file, FileOpenMode flags, FileAccessMode mode) {
		throw(new NotImplementedException("VirtualFileSystem.open"));
	}
	
	void close(FileHandle handle) {
		throw(new NotImplementedException("VirtualFileSystem.close"));
	}

	int read(FileHandle handle, ubyte[] data) {
		throw(new NotImplementedException("VirtualFileSystem.read"));
	}

	int write(FileHandle handle, ubyte[] data) {
		throw(new NotImplementedException("VirtualFileSystem.write"));
	}

	long seek(FileHandle handle, long offset, Whence whence) {
		throw(new NotImplementedException("VirtualFileSystem.seek"));
	}
	
	void unlink(string file) {
		throw(new NotImplementedException("VirtualFileSystem.unlink"));
	}

	void mkdir(string file, FileAccessMode mode) {
		throw(new NotImplementedException("VirtualFileSystem.mkdir"));
	}

	void rmdir(string file) {
		throw(new NotImplementedException("VirtualFileSystem.rmdir"));
	}

	DirHandle dopen(string file) {
		throw(new NotImplementedException("VirtualFileSystem.dopen"));
	}

	void dclose(DirHandle handle) {
		throw(new NotImplementedException("VirtualFileSystem.dclose"));
	}
	
	FileEntry dread(DirHandle handle) {
		throw(new NotImplementedException("VirtualFileSystem.drrad"));
	}
	
	FileStat getstat(string file) {
		throw(new NotImplementedException("VirtualFileSystem.getstat"));
	}

	void setstat(string file, FileStat stat) {
		throw(new NotImplementedException("VirtualFileSystem.getstat"));
	}
	
	void rename(string oldname, string newname) {
		throw(new NotImplementedException("VirtualFileSystem.rename"));
	}

	int ioctl(FileHandle fileHandle, uint cmd, ubyte[] indata, ubyte[] outdata) {
		throw(new NotImplementedException("VirtualFileSystem.ioctl (VirtualFileSystem)"));
	}

	int devctl(string devname, uint cmd, ubyte[] indata, ubyte[] outdata) {
		throw(new NotImplementedException("VirtualFileSystem.devctl (VirtualFileSystem)"));
	}
	
	ubyte[] readAll(string file) {
		ubyte[] data;
		Stream stream = open(file, FileOpenMode.In, FileAccessMode.All);
		data = new ubyte[cast(uint)stream.size];
		data.length = stream.read(data);
		stream.close();
		return data;
	}
}