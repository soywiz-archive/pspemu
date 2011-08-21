module pspemu.hle.kd.iofilemgr.IoFileMgr; // kd/iofilemgr.prx (sceIOFileManager)

import pspemu.hle.ModuleNative;

//debug = DEBUG_SYSCALL;

import std.stdio;
import std.encoding;
import std.datetime;
import std.stream;
import std.file;
import std.string;
import std.conv;
import std.utf;

//import pspemu.utils.AsyncStream;

//import pspemu.core.cpu.Interrupts;

import pspemu.hle.ModuleNative;

//import pspemu.utils.Utils;
import pspemu.utils.Path;
import pspemu.utils.Logger;
import pspemu.hle.vfs.VirtualFileSystem;

import pspemu.hle.kd.iofilemgr.Types;

import pspemu.hle.kd.iofilemgr.IoFileMgr_Directories;
import pspemu.hle.kd.iofilemgr.IoFileMgr_FilesAsync;

import pspemu.hle.RootFileSystem;

import pspemu.Emulator;

import pspemu.hle.vfs.devices.IoDevice;

import pspemu.hle.kd.sysmem.Types;

import pspemu.hle.kd.mediaman.sceUmd;


class IoFileMgrForKernel : HleModuleHost {
	mixin TRegisterModule;
	
	mixin IoFileMgrForKernel_Directories;
	mixin IoFileMgrForKernel_FilesAsync;
	
	@property RootFileSystem rootFileSystem() {
		return hleEmulatorState.rootFileSystem;
	}
	
	@property VirtualFileSystem fsroot() {
		return rootFileSystem.fsroot;
	}

	void initModule() {
		initModule_Directories();
		initModule_FilesAsync();
	}

	void initNids() {
		initNids_Directories();
		initNids_FilesAsync();
		
		mixin(registerFunction!(0x810C4BC3, sceIoClose));
		mixin(registerFunction!(0x109F50BC, sceIoOpen));
		mixin(registerFunction!(0x6A638D83, sceIoRead));
		mixin(registerFunction!(0x42EC03AC, sceIoWrite));
		mixin(registerFunction!(0x27EB27B8, sceIoLseek));
		mixin(registerFunction!(0x68963324, sceIoLseek32));

		mixin(registerFunction!(0x54F5FB11, sceIoDevctl));

		mixin(registerFunction!(0xACE946E8, sceIoGetstat));
		mixin(registerFunction!(0xB8A740F4, sceIoChstat));
		mixin(registerFunction!(0xF27A9C51, sceIoRemove));
		mixin(registerFunction!(0x779103A0, sceIoRename));
	
		mixin(registerFunction!(0x63632449, sceIoIoctl));

		mixin(registerFunction!(0x3C54E908, sceIoReopen));
		mixin(registerFunction!(0x8E982A74, sceIoAddDrv));
		mixin(registerFunction!(0xC7F35804, sceIoDelDrv));
	}

	/*
	Stream[SceUID] openedStreams;

	Stream getStreamFromFD(SceUID uid) {
		if ((uid in openedStreams) is null) {
			throw(new Exception(std.string.format("No file opened with FD/UID(%d)", uid)));
			//Logger.log(Logger.Level.WARNING, "iofilemgr", "No file opened with FD/UID(%d)", uid);
		}
		return openedStreams[uid];
	}
	*/

	/**
	 * Change the name of a file
	 *
	 * @param oldname - The old filename
	 * @param newname - The new filename
	 *
	 * @return < 0 on error.
	 */
	int sceIoRename(string oldname, string newname) {
		logInfo("sceIoRename('%s', '%s')", oldname, newname);
		try {
			fsroot().rename(oldname, newname);
			return 0;
		} catch (Throwable o) {
			logError("%s", o);
			return -1;
		}
	}

	/*
	class DirectoryIterator {
		string dirname;
		uint pos;
		VFS vfs;
		VFS[] children;
		this(string dirname) {
			this.dirname = dirname;
			this.pos = 0;
			this.vfs = fsroot[dirname];
			foreach (child; this.vfs) children ~= child;
		}
		uint left() { return children.length - pos; }
		VFS extract() {
			return children[pos++];
		}
	}
	*/


	/** 
	 * Send a devctl command to a device.
	 *
	 * @par Example: Sending a simple command to a device (not a real devctl)
	 * <code>
	 *     sceIoDevctl("ms0:", 0x200000, indata, 4, NULL, NULL); 
	 * </code>
	 *
	 * @param dev     - String for the device to send the devctl to (e.g. "ms0:")
	 * @param cmd     - The command to send to the device
	 * @param indata  - A data block to send to the device, if NULL sends no data
	 * @param inlen   - Length of indata, if 0 sends no data
	 * @param outdata - A data block to receive the result of a command, if NULL receives no data
	 * @param outlen  - Length of outdata, if 0 receives no data
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceIoDevctl(string dev, int cmd, void* indata, int inlen, void* outdata, int outlen) {
		logWarning("sceIoDevctl(dev='%s', cmd=0x%08X, indata=0x%08X, inlen=%d, outdata=0x%08X, outlen=%d)", dev, cmd, cast(uint)indata, inlen, cast(uint)outdata, outlen);
		try {
			return rootFileSystem().getDevice(dev).devctl(dev, cmd, (cast(ubyte*)indata)[0..inlen], (cast(ubyte*)outdata)[0..outlen]);
		} catch (Throwable o) {
			logError("sceIoDevctl: %s", std.encoding.sanitize(o.toString));
			return -1;
		}
	}

	/**
	 * Delete a descriptor
	 *
	 * <code>
	 *     sceIoClose(fd);
	 * </code>
	 *
	 * @param fd - File descriptor to close
	 * @return < 0 on error
	 */
	int sceIoClose(SceUID fd) {
		logInfo("sceIoClose('%d')", fd);
		if (fd < 0) return -1;
		try {
			FileHandle fileHandle = uniqueIdFactory.get!FileHandle(fd);
			fsroot().close(fileHandle);
			uniqueIdFactory.remove!FileHandle(fd);
			return 0;
		} catch (Throwable o) {
			.writefln("sceIoClose(%d) : %s", fd, o);
			return 0;
		}
	}
	
	string getAbsolutePathFromRelative(string relativePath) {
		//auto indexHasDevice = relativePath.indexOf(":/");
		auto indexHasDevice = relativePath.indexOf(":");
		string absolutePath;

		if (indexHasDevice >= 0) {
			absolutePath = relativePath;
		} else {
			absolutePath = hleEmulatorState.rootFileSystem.fscurdir ~ "/" ~ relativePath;
			/*
			if (relativePath.length && relativePath[0] == '/') {
				absolutePath = hleEmulatorState.rootFileSystem.fscurdir ~ "/" ~ relativePath;
			} else {
				
			}
			*/
		}

		logTrace("getAbsolutePathFromRelative('%s') : '%s'", relativePath, absolutePath);
		return absolutePath;
	}

	/*
	VFS locateParentAndUpdateFile(ref string file) {
		VFS vfs;
		auto indexLastSeparator = file.lastIndexOf("/");
		if (indexLastSeparator >= 0) {
			string path = file[0..indexLastSeparator];
			file = file[indexLastSeparator + 1..$];
			vfs = fsroot.access(path);
		} else {
			writefln(" :: %s", hleEmulatorState.rootFileSystem.fscurdir);
			writefln(" :: %s", fsroot);
			vfs = fsroot.access(hleEmulatorState.rootFileSystem.fscurdir);
		}
		
		//writefln("locateParentAndUpdateFile('%s', '%s')", vfs, file);

		return vfs;
	}
	*/
	
	FileHandle _open(string file, SceIoFlags flags, SceMode mode) {
		file = getAbsolutePathFromRelative(file);
		try {
			return fsroot().open(file, sceFlagsToFileOpenMode(flags), sceModeToFileAccessMode(mode));
		} catch (Throwable o) {
			logWarning("Can't open file '%s'", file);
			throw(o);
		}
	}

	/**
	 * Open or create a file for reading or writing
	 *
	 * @par Example1: Open a file for reading
	 * <code>
	 * if(!(fd = sceIoOpen("device:/path/to/file", O_RDONLY, 0777)) {
	 *	// error
	 * }
	 * </code>
	 * @par Example2: Open a file for writing, creating it if it doesnt exist
	 * <code>
	 * if(!(fd = sceIoOpen("device:/path/to/file", O_WRONLY|O_CREAT, 0777)) {
	 *	// error
	 * }
	 * </code>
	 *
	 * @param file  - Pointer to a string holding the name of the file to open
	 * @param flags - Libc styled flags that are or'ed together
	 * @param mode  - File access mode.
	 *
	 * @return A non-negative integer is a valid fd, anything else is an error
	 */
	SceUID sceIoOpen(string file, SceIoFlags flags, SceMode mode) {
		try {
			logInfo("sceIoOpen('%s', %d, %d) : %08X, %08X, %08X", file, flags, mode, currentRegisters().A0, currentRegisters().A1, currentRegisters().A2);
			logInfo("   %s", (cast(ubyte*)currentMemory().getPointer(currentRegisters().A0))[0..0x10]);
			SceUID ret = uniqueIdFactory.add!FileHandle(_open(file, flags, mode));
			logInfo("sceIoOpen():%d", ret);
			return ret;
		} catch (Throwable o) {
			logWarning("sceIoOpen failed to open '%s' for '%d'", file, flags);
			logWarning("        : '%s'", std.encoding.sanitize(o.toString));
			return SceKernelErrors.ERROR_ERRNO_FILE_NOT_FOUND;
		}
	}

	/**
	 * Read input
	 *
	 * @par Example:
	 * <code>
	 *     bytes_read = sceIoRead(fd, data, 100);
	 * </code>
	 *
	 * @param fd   - Opened file descriptor to read from
	 * @param data - Pointer to the buffer where the read data will be placed
	 * @param size - Size of the read in bytes
	 * 
	 * @return The number of bytes read
	 */
	int sceIoRead(SceUID fd, void* data, SceSize size) {
		try {
			FileHandle fileHandle = uniqueIdFactory.get!FileHandle(fd);
			logInfo("sceIoRead(%d, %08X, %d) : %d", fd, cast(uint)data, size, fileHandle.position);
			if (data is null) return -1;
			try {
				int readed = fsroot().read(fileHandle, (cast(ubyte *)data)[0..size]);
				if (readed == 0) return -1;
				return readed;
			} catch (Throwable o) {
				logError("ERROR: sceIoRead: %s", o);
				return -1;
			}
		} catch (UniqueIdNotFoundException) {
			// @TODO: Check this error. 
			return SceKernelErrors.ERROR_KERNEL_BAD_FILE_DESCRIPTOR;
		}
	}

	/**
	 * Write output
	 *
	 * @par Example:
	 * <code>
	 *     bytes_written = sceIoWrite(fd, data, 100);
	 * </code>
	 *
	 * @param fd   - Opened file descriptor to write to
	 * @param data - Pointer to the data to write
	 * @param size - Size of data to write
	 *
	 * @return The number of bytes written
	 */
	int sceIoWrite(SceUID fd, /*const*/ void* data, SceSize size) {
		logInfo("sceIoWrite(%d, %d)", fd, size);
		if (fd < 0) return -1;
		if (data is null) return -1;
		FileHandle fileHandle = uniqueIdFactory.get!FileHandle(fd);

		// Less than 256 MB.
		/*
		if (asyncStream.stream.position >= 256 * 1024 * 1024) {
			throw(new Exception(std.string.format("Write position over 256MB! There was a prolem with sceIoWrite: position(%d)", asyncStream.stream.position)));
		}
		*/

		try {
			return fsroot().write(fileHandle, (cast(ubyte *)data)[0..size]);
		} catch (Throwable o) {
			Logger.log(Logger.Level.WARNING, "IoFileMgrForKernel", "sceIoWrite.ERROR :: %s", o);
			return 0;
		}
	}

	/**
	 * Reposition read/write file descriptor offset
	 *
	 * @par Example:
	 * <code>
	 *     pos = sceIoLseek(fd, -10, SEEK_END);
	 * </code>
	 *
	 * @param fd     - Opened file descriptor with which to seek
	 * @param offset - Relative offset from the start position given by whence
	 * @param whence - Set to SEEK_SET to seek from the start of the file, SEEK_CUR
	 *                 seek from the current position and SEEK_END to seek from the end.
	 *
	 * @return The position in the file after the seek. 
	 */
	SceOff sceIoLseek(SceUID fd, SceOff offset, int whence) {
		logInfo("sceIoLseek(%d, %d, %d)", fd, offset, whence);
		if (fd < 0) return -1;
		FileHandle fileHandle = uniqueIdFactory.get!FileHandle(fd);
		return fsroot().seek(fileHandle, offset, cast(Whence)whence);
	}

	/**
	 * Reposition read/write file descriptor offset (32bit mode)
	 *
	 * @par Example:
	 * <code>
	 *     pos = sceIoLseek32(fd, -10, SEEK_END);
	 * </code>
	 *
	 * @param fd     - Opened file descriptor with which to seek
	 * @param offset - Relative offset from the start position given by whence
	 * @param whence - Set to SEEK_SET to seek from the start of the file, SEEK_CUR
	 *                 seek from the current position and SEEK_END to seek from the end.
	 *
	 * @return The position in the file after the seek. 
	 */
	int sceIoLseek32(SceUID fd, int offset, int whence) {
		logInfo("sceIoLseek32(%d, %d, %d)", fd, offset, whence);
		return cast(int)sceIoLseek(fd, offset, whence);
	}

	/** 
	  * Get the status of a file.
	  * 
	  * @param file - The path to the file.
	  * @param stat - A pointer to an io_stat_t structure.
	  * 
	  * @return < 0 on error.
	  */
	int sceIoGetstat(string file, SceIoStat* stat) {
		file = getAbsolutePathFromRelative(file);
		logInfo("sceIoGetstat('%s')", file);
		try {
			*stat = fileStatToSceIoStat(fsroot().getstat(file));
			return 0;
		} catch (Throwable o) {
			logError("ERROR: STAT(%s)!! FAILED: %s", file, o);
			return -1;
		}
	}

	/** 
	 * Change the status of a file.
	 *
	 * @param file - The path to the file.
	 * @param stat - A pointer to an io_stat_t structure.
	 * @param bits - Bitmask defining which bits to change.
	 *
	 * @return < 0 on error.
	 */
	int sceIoChstat(string file, SceIoStat *stat, int bits) {
		unimplemented();
		return -1;
	}

	/**
	 * Remove directory entry
	 *
	 * @param file - Path to the file to remove
	 *
	 * @return < 0 on error
	 */
	int sceIoRemove(string file) {
		logWarning("sceIoRemove('%s')", file);
		unimplemented_notice();
		return 0;
	}

	/**
	 * Perform an ioctl on a device.
	 *
	 * @param  fd      - Opened file descriptor to ioctl to
	 * @param  cmd     - The command to send to the device
	 * @param  indata  - A data block to send to the device, if NULL sends no data
	 * @param  inlen   - Length of indata, if 0 sends no data
	 * @param  outdata - A data block to receive the result of a command, if NULL receives no data
	 * @param  outlen  - Length of outdata, if 0 receives no data
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceIoIoctl(SceUID fd, uint cmd, void* indata, int inlen, void* outdata, int outlen) {
		//unimplemented_notice();
		logInfo("sceIoIoctl(%d, 0x%08X, 0x%08X, %d, 0x%08X, %d)", fd, cmd, cast(uint)indata, inlen, cast(uint)outdata, outlen);
		FileHandle fileHandle = uniqueIdFactory.get!FileHandle(fd);
		//logInfo("---%s", fileHandle);
		logInfo("---%s", fileHandle.virtualFileSystem);
		int result = fileHandle.virtualFileSystem.ioctl(fileHandle, cmd, (cast(ubyte*)indata)[0..inlen], (cast(ubyte*)outdata)[0..outlen]);
		
		/*
		logWarning("sceIoDevctl('%s', 0x%08X)", dev, cmd);
		try {
			return rootFileSystem().getDevice(dev).devctl(dev, cmd, (cast(ubyte*)indata)[0..inlen], (cast(ubyte*)outdata)[0..outlen]);
		} catch (Throwable o) {
			logError("sceIoDevctl: %s", std.encoding.sanitize(o.toString));
			return -1;
		}
		*/
		
		//hleEmulatorState.moduleManager.get!sceUmdUser.triggerUmdStatusChange();

		return result;
	}

	/**
	 * Reopens an existing file descriptor.
	 *
	 * @param file  - The new file to open.
	 * @param flags - The open flags.
	 * @param mode  - The open mode.
	 * @param fd    - The old filedescriptor to reopen
	 *
	 * @return < 0 on error, otherwise the reopened fd.
	 */
	int sceIoReopen(string file, SceIoFlags flags, SceMode mode, SceUID fd) {
		logInfo("sceIoReopen('%s', %d, %d, %d)", file, flags, mode, cast(int)fd);
		
		try {
			FileHandle newStream = _open(file, flags, mode);
			
			fsroot().close(uniqueIdFactory.get!FileHandle(fd));
			uniqueIdFactory.set!FileHandle(fd, newStream);
			
			return fd;
		} catch (Throwable o) {
			logError("Can't reopen file");
			logError("Can't reopen file : %s", std.encoding.sanitize(o.toString));
			//return fd;
			return -1;
		}
	}

	/** 
	 * Adds a new IO driver to the system.
	 * @note This is only exported in the kernel version of IoFileMgr
	 * 
	 * @param drv - Pointer to a filled out driver structure
	 * @return < 0 on error.
	 *
	 * @par Example:
	 * @code
	 * PspIoDrvFuncs host_funcs = { ... };
	 * PspIoDrv host_driver = { "host", 0x10, 0x800, "HOST", &host_funcs };
	 * sceIoDelDrv("host");
	 * sceIoAddDrv(&host_driver);
	 * @endcode
	 */
	int sceIoAddDrv(PspIoDrv* drv) {
		string name  = to!string(cast(char *)currentCpuThread().memory.getPointer(cast(uint)drv.name));
		string name2 = to!string(cast(char *)currentCpuThread().memory.getPointer(cast(uint)drv.name2));
		PspIoDrvFuncs* funcs = cast(PspIoDrvFuncs*)currentCpuThread().memory.getPointer(cast(uint)drv.funcs);
		rootFileSystem().addDriver(name, new IoDevice(hleEmulatorState, new PspVirtualFileSystem(hleEmulatorState, name, drv, funcs)));
		logWarning("sceIoAddDrv('%s', '%s', ...)", name, name2);
		return 0;
	}

	/**
	 * Deletes a IO driver from the system.
	 * @note This is only exported in the kernel version of IoFileMgr
	 *
	 * @param drv_name - Name of the driver to delete.
	 * @return < 0 on error
	 */
	int sceIoDelDrv(string drv_name) {
		logWarning("sceIoDelDrv('%s')", drv_name);
		rootFileSystem().delDriver(drv_name);
		return 0;
	}
}

/*
void fillStats(SceIoStat* psp_stats, VFS.Stats vfs_stats) {
	{
		psp_stats.st_mode = 0;
		
		// User access rights mask
		psp_stats.st_mode |= IOAccessModes.FIO_S_IRUSR | IOAccessModes.FIO_S_IWUSR | IOAccessModes.FIO_S_IXUSR;
		// Group access rights mask
		psp_stats.st_mode |= IOAccessModes.FIO_S_IRGRP | IOAccessModes.FIO_S_IWGRP | IOAccessModes.FIO_S_IXGRP;
		// Others access rights mask
		psp_stats.st_mode |= IOAccessModes.FIO_S_IROTH | IOAccessModes.FIO_S_IWOTH | IOAccessModes.FIO_S_IXOTH;

		//psp_stats.st_mode |= FIO_S_IFLNK
		psp_stats.st_mode |= vfs_stats.isdir ? IOAccessModes.FIO_S_IFDIR : IOAccessModes.FIO_S_IFREG;
	}
	{
		//psp_stats.st_attr |= IOFileModes.FIO_SO_IFLNK;
		if (vfs_stats.isdir) {
			psp_stats.st_attr = IOFileModes.FIO_SO_IFDIR;
		} else {
			psp_stats.st_attr  = cast(IOFileModes)0;
			psp_stats.st_attr |= IOFileModes.FIO_SO_IFREG;
			psp_stats.st_attr |= IOFileModes.FIO_SO_IROTH | IOFileModes.FIO_SO_IWOTH | IOFileModes.FIO_SO_IXOTH; // rwx
		}
	}
	
	psp_stats.st_size = vfs_stats.size;
	psp_stats.st_ctime.parse(vfs_stats.time_c);
	psp_stats.st_atime.parse(vfs_stats.time_a);
	psp_stats.st_mtime.parse(vfs_stats.time_m);

	psp_stats.st_private[] = 0;
}
*/

SceIoDirent fileEntryToSceIoDirent(FileEntry fileEntry) {
	SceIoDirent sceIoDirent;
	sceIoDirent.d_name[] = 0;
	sceIoDirent.d_name[0..fileEntry.name.length] = fileEntry.name;
	sceIoDirent.d_stat = fileStatToSceIoStat(fileEntry.stat);
	return sceIoDirent;
}

SceIoStat fileStatToSceIoStat(FileStat fileStat) {
	SceIoStat sceIoStat;
	
	sceIoStat.st_mode = 0;
	sceIoStat.st_mode |= IOAccessModes.FIO_S_IRUSR | IOAccessModes.FIO_S_IWUSR | IOAccessModes.FIO_S_IXUSR;
	sceIoStat.st_mode |= IOAccessModes.FIO_S_IRGRP | IOAccessModes.FIO_S_IWGRP | IOAccessModes.FIO_S_IXGRP;
	sceIoStat.st_mode |= IOAccessModes.FIO_S_IROTH | IOAccessModes.FIO_S_IWOTH | IOAccessModes.FIO_S_IXOTH;

	if (fileStat.isDir) {
		sceIoStat.st_mode = IOAccessModes.FIO_S_IFDIR;	
		sceIoStat.st_attr = IOFileModes.FIO_SO_IFDIR;
	} else {
		sceIoStat.st_mode = IOAccessModes.FIO_S_IFREG;
		sceIoStat.st_attr = IOFileModes.FIO_SO_IFREG | IOFileModes.FIO_SO_IROTH | IOFileModes.FIO_SO_IWOTH | IOFileModes.FIO_SO_IXOTH;
	}
	sceIoStat.st_size = fileStat.size;
	sceIoStat.st_ctime.parse(fileStat.ctime);
	sceIoStat.st_atime.parse(fileStat.atime);
	sceIoStat.st_mtime.parse(fileStat.mtime);
	sceIoStat.st_private[0] = fileStat.sectorOffset;
	sceIoStat.st_private[1..$] = 0;
	return sceIoStat;
}

FileOpenMode sceFlagsToFileOpenMode(uint flags) {
	FileOpenMode fmode;
	if (flags & SceIoFlags.PSP_O_RDONLY) fmode |= FileOpenMode.In;
	if (flags & SceIoFlags.PSP_O_WRONLY) fmode |= FileOpenMode.Out;
	if (flags & SceIoFlags.PSP_O_APPEND) fmode |= FileOpenMode.Append;
	if (flags & SceIoFlags.PSP_O_CREAT ) fmode |= FileOpenMode.OutNew;
	return fmode;
}

FileAccessMode sceModeToFileAccessMode(SceMode mode) {
	return cast(FileAccessMode)mode;
}

class IoFileMgrForUser : IoFileMgrForKernel {
	mixin TRegisterModule;
}
