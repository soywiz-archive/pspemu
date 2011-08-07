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
			case "Kprintf": return new StreamFileHandle(this, new KprintfStream(hleEmulatorState));
			default: throw(new Exception(std.string.format("Unknown EmulatorFileSystem::'%s'", file)));
		}
	}
	
	mixin VirtualFileSystem_Stream;
	
	string toString() {
		return std.string.format("EmulatorFileSystem()");
	}
}