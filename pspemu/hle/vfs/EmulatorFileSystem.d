module pspemu.hle.vfs.EmulatorFileSystem;

public import pspemu.hle.vfs.VirtualFileSystem;

import pspemu.hle.HleEmulatorState;

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

class EmulatorFileHandle : FileHandle {
	Stream stream;
	
	public this(VirtualFileSystem virtualFileSystem, Stream stream) {
		super(virtualFileSystem);
		this.stream = stream;
	}
}

class KprintfStream : Stream {
	HleEmulatorState hleEmulatorState;

	public this(HleEmulatorState hleEmulatorState) {
		this.hleEmulatorState = hleEmulatorState;
	}
	
	size_t readBlock(void* buffer, size_t size) {
		throw(new Exception("Can't read from KprintfStream"));
	}

	size_t writeBlock(const void* buffer, size_t size) {
		hleEmulatorState.kPrint.Kprint(cast(string)(cast(const char*)buffer)[0..size]);
		return size;
	}

	ulong seek(long offset, SeekPos whence) {
		throw(new Exception("Can't seek from KprintfStream"));
	}
}

class EmulatorFileSystem : VirtualFileSystem {
	HleEmulatorState hleEmulatorState;

	public this(HleEmulatorState hleEmulatorState) {
		this.hleEmulatorState = hleEmulatorState;
	}
	
	override FileHandle open(string file, FileOpenMode flags, FileAccessMode mode) {
		switch (file) {
			case "Kprintf":
				break;
			default: throw(new Exception(std.string.format("Unknown EmulatorFileSystem::'%s'", file)));
		}
		return new EmulatorFileHandle(this, new KprintfStream(hleEmulatorState));
	}
	
	Stream getStreamFromHandle(FileHandle handle) {
		return handle.get!EmulatorFileHandle(this).stream;
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
	
	string toString() {
		return std.string.format("EmulatorFileSystem()");
	}
}