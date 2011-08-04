module pspemu.hle.kd.stdio.StdioForKernel; // kd/stdio.prx (sceStdio)

import pspemu.hle.ModuleNative;

import std.stdio;
import std.stream;
import pspemu.utils.AsyncStream;

import pspemu.hle.ModuleNative;

import pspemu.hle.vfs.VirtualFileSystem;
import pspemu.hle.vfs.LocalFileSystem;

public import pspemu.hle.kd.stdio.Types;

class FileWrapperStream : Stream {
	std.stdio.File file;
	
	this(std.stdio.File file) {
		this.file = file;
	}
	
	size_t readBlock(void* buffer, size_t size) {
		return this.file.rawRead((cast(ubyte *)buffer)[0..size]).length;		
	}
	
	size_t writeBlock(const void* buffer, size_t size) {
		this.file.rawWrite((cast(ubyte *)buffer)[0..size]);
		return size;
	}
	
	ulong seek(long offset, SeekPos whence) {
		throw(new Exception("Not implemented"));
	}
}

class StdioForUser : ModuleNative {
	void initNids() {
		mixin(registerd!(0x172D316E, sceKernelStdin));
		mixin(registerd!(0xA6BAB2E9, sceKernelStdout));
		mixin(registerd!(0xF78BA90A, sceKernelStderr));
		mixin(registerd!(0x98220F3E, sceKernelStdoutReopen));
		mixin(registerd!(0xFB5380C5, sceKernelStderrReopen));
		mixin(registerd!(0xD97C8CB9, puts));
		//mixin(registerd!(0xCAB439DF, printf));
	}
	
	void initModule() {
		uniqueIdFactory.set!LocalFileHandle(cast(uint)1, new LocalFileHandle(null, new FileWrapperStream(stdin )));
		uniqueIdFactory.set!LocalFileHandle(cast(uint)2, new LocalFileHandle(null, new FileWrapperStream(stdout)));
		uniqueIdFactory.set!LocalFileHandle(cast(uint)3, new LocalFileHandle(null, new FileWrapperStream(stderr)));
	}

	/**
	 * Function to get the current standard in file no
	 * 
	 * @return The stdin fileno
	 */
	SceUID sceKernelStdin() { return STDIN; }

	/**
	 * Function to get the current standard out file no
	 * 
	 * @return The stdout fileno
	 */
	SceUID sceKernelStdout() { return STDOUT; }

	/**
	 * Function to get the current standard err file no
	 * 
	 * @return The stderr fileno
	 */
	SceUID sceKernelStderr() { return STDERR; }

	/** 
	 * Function reopen the stdout file handle to a new file
	 *
	 * @param file - The file to open.
	 * @param flags - The open flags 
	 * @param mode - The file mode
	 * 
	 * @return < 0 on error.
	 */
	int sceKernelStdoutReopen(string file, int flags, SceMode mode) {
		unimplemented();
		return -1;
	}

	/** 
	 * Function reopen the stderr file handle to a new file
	 *
	 * @param file - The file to open.
	 * @param flags - The open flags 
	 * @param mode - The file mode
	 * 
	 * @return < 0 on error.
	 */
	int sceKernelStderrReopen(string file, int flags, SceMode mode) {
		unimplemented();
		return -1;
	}
	
	int puts(string str) {
		Logger.log(Logger.Level.WARNING, "StdioForKernel.puts", str);
		//unimplemented();
		return 0;
	}
}

class StdioForKernel : StdioForUser {
}

static this() {
	mixin(ModuleNative.registerModule("StdioForKernel"));
	mixin(ModuleNative.registerModule("StdioForUser"));
}