module pspemu.hle.vfs.LocalFileSystem;

public import pspemu.hle.vfs.VirtualFileSystem;

import std.conv;
import std.path;
import std.stdio;
import std.string;
import std.array;
import std.datetime;
import std.stream;
import std.file;
import pspemu.utils.String;
import std.algorithm;

FileStat dirEntryToFileStat(VirtualFileSystem virtualFileSystem, DirEntry dirEntry) {
	//if (dirEntry is null) return null;
	FileStat stat = new FileStat(virtualFileSystem);
	stat.permissions  = octal!777;
	stat.isDir  = dirEntry.isDir;
	stat.isRoot = false;
	stat.size  = dirEntry.size;
	stat.ctime = dirEntry.timeCreated;
	stat.atime = dirEntry.timeLastAccessed;
	stat.mtime = dirEntry.timeLastModified;
	return stat;	
}

FileEntry dirEntryToFileEntry(VirtualFileSystem virtualFileSystem, DirEntry dirEntry) {
	//if (dirEntry is null) return null;
	FileEntry fileEntry = new FileEntry(virtualFileSystem);
	fileEntry.name = std.path.basename(dirEntry.name);
	fileEntry.stat = dirEntryToFileStat(virtualFileSystem, dirEntry);
	return fileEntry;
}


class LocalFileHandle : FileHandle {
	Stream stream;
	
	public this(VirtualFileSystem virtualFileSystem, Stream stream) {
		super(virtualFileSystem);
		this.stream = stream;
	}
}

class LocalDirHandle : DirHandle {
	string path;
	DirEntry[] entries;
	int currentIndex;
	
	public this(VirtualFileSystem virtualFileSystem, string path) {
		super(virtualFileSystem);
		this.path = path;
		init();
	}
	
	void init() {
		//throw(new Exception("BUG"));
		
		if (!std.file.exists(path)) {
			throw(new Exception(std.string.format("Path '%s' doesn't exists", path)));
		} else {
			foreach (DirEntry entry; dirEntries(path, SpanMode.shallow, true)) entries ~= entry;
			std.algorithm.sort!("a.name < b.name")(entries);
		}
	}
	
	bool hasMore() {
		return currentIndex < entries.length;
	}
	
	DirEntry next() {
		if (currentIndex < entries.length) {
			return entries[currentIndex++];
		} else {
			throw(new Exception("No more entries"));
		}
	}
}

class LocalFileSystem : VirtualFileSystem {
	string rootPath;

	this(string rootPath) {
		this.rootPath = rootPath;
	}
	
	FileMode openModeToDMode(FileOpenMode mode) {
		return cast(FileMode)mode;
	}
	
	string getInternalPath(string path) {
		path = std.array.replace(path, r"\", "/");
		string[] parts;
		foreach (part; path.split("/")) {
			if (part == "") continue;
			if (part == ".") continue;
			if (part == "..") {
				if (parts.length) parts.length = parts.length - 1;
				continue;
			}
			parts ~= part;
		}
		string internalPath = rootPath ~ "/" ~ std.string.join(parts, "/");
		//writefln("%s", internalPath);
		internalPath = std.array.replace(internalPath, r"\", "/");
		//writefln("%s", internalPath);
		internalPath = rtrim_str(internalPath, '/');
		//writefln("%s", internalPath);
		//writefln("internalPath: %s", internalPath);
		return internalPath; 
	}
	
	override FileHandle open(string file, FileOpenMode flags, FileAccessMode mode) {
		auto dmode = openModeToDMode(flags);
		Stream stream;
		
		if ((dmode & FileMode.Out) != 0) {
			stream = new std.stream.File(getInternalPath(file), dmode);
		} else {
			stream = new std.stream.BufferedFile(getInternalPath(file), dmode);
		}
		return new LocalFileHandle(this, stream);
	}
	
	Stream getStreamFromHandle(FileHandle handle) {
		return handle.get!LocalFileHandle(this).stream;
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
	
	override DirHandle dopen(string file) {
		string internalPath = getInternalPath(file);
		
		// Bug in DMD. Throwing the Exception in the constructor, crashes the program.
		if (!std.file.exists(internalPath)) {
			throw(new Exception(std.string.format("Path '%s' doesn't exists", internalPath)));
		}

		return new LocalDirHandle(this, internalPath);
	}

	override void dclose(DirHandle handle) {
	}
	
	override FileEntry dread(DirHandle handle) {
		LocalDirHandle localDirHandle = cast(LocalDirHandle)handle;
		if (localDirHandle.hasMore) {
			return dirEntryToFileEntry(this, localDirHandle.next);
		} else {
			return null;			
		}
	}
	
	override FileStat getstat(string file) {
		//writefln("getstat: %s", file);
		string realPath = getInternalPath(file);
		//writefln("realPath:'%s'", realPath);
		if (!std.file.exists(realPath)) throw(new Exception(std.string.format("Path '%s' doesn't exists", realPath)));
		return dirEntryToFileStat(this, std.file.dirEntry(realPath));
	}
	
	string toString() {
		return std.string.format("LocalFileSystem('%s')", rootPath);
	}
}