module pspemu.hle.kd.iofilemgr; // kd/iofilemgr.prx (sceIOFileManager)

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

import pspemu.utils.VirtualFileSystem;

__gshared static {
	VFS fsroot;
	string fscurdir = "ms0:/PSP/GAME/virtual";
}

static this() {
	fsroot = new VFS();

	//fsroot["/ms0/PSP/GAME"].addChild(new VFS_Proxy("virtual", new VFS()));

	fsroot.addChild(new FileSystem("pspfs/ms0"), "ms0:");
	fsroot.addChild(new FileSystem("pspfs/flash0"), "flash0:");

	// Aliases.
	fsroot.addChild(fsroot["ms0:"], "ms:");
}

class IoFileMgrForKernel : Module {
	this() {
		mixin(register(0xB29DDF9C, "sceIoDopen"));
		mixin(register(0xEB092469, "sceIoDclose"));
		mixin(register(0x55F4717D, "sceIoChdir"));
		mixin(registerd!(0x810C4BC3, sceIoClose));
		mixin(registerd!(0x109F50BC, sceIoOpen));
		mixin(registerd!(0x6A638D83, sceIoRead));
		mixin(registerd!(0x42EC03AC, sceIoWrite));
		mixin(registerd!(0x27EB27B8, sceIoLseek));
		mixin(registerd!(0xACE946E8, sceIoGetstat));
	}

	Stream stream(SceUID fd) { return cast(Stream)cast(void *)fd; }

	/**
	 * Delete a descriptor
	 *
	 * @code
	 * sceIoClose(fd);
	 * @endcode
	 *
	 * @param fd - File descriptor to close
	 * @return < 0 on error
	 */
	int sceIoClose(SceUID fd) {
		stream(fd).close();
		return 0;
	}

	/**
	 * Open or create a file for reading or writing
	 *
	 * @par Example1: Open a file for reading
	 * @code
	 * if(!(fd = sceIoOpen("device:/path/to/file", O_RDONLY, 0777)) {
	 *	// error
	 * }
	 * @endcode
	 * @par Example2: Open a file for writing, creating it if it doesnt exist
	 * @code
	 * if(!(fd = sceIoOpen("device:/path/to/file", O_WRONLY|O_CREAT, 0777)) {
	 *	// error
	 * }
	 * @endcode
	 *
	 * @param file - Pointer to a string holding the name of the file to open
	 * @param flags - Libc styled flags that are or'ed together
	 * @param mode - File access mode.
	 * @return A non-negative integer is a valid fd, anything else an error
	 */
	SceUID sceIoOpen(/*const*/ string file, int flags, SceMode mode) {
		try {
			//writefln("opening...'%s/%s'", fscurdir, file);
			FileMode fmode;

			if (mode & PSP_O_RDONLY) fmode |= FileMode.In;
			if (mode & PSP_O_WRONLY) fmode |= FileMode.Out;
			if (mode & PSP_O_APPEND) fmode |= FileMode.Append;
			if (mode & PSP_O_CREAT ) fmode |= FileMode.OutNew;

			auto stream = fsroot[fscurdir].open(file, fmode, 0777);
			return cast(SceUID)cast(void *)stream;
		} catch (Object o) {
			writefln("sceIoOpen exception: %s", o);
			return -1;
		}
	}

	/**
	 * Read input
	 *
	 * @par Example:
	 * @code
	 * bytes_read = sceIoRead(fd, data, 100);
	 * @endcode
	 *
	 * @param fd - Opened file descriptor to read from
	 * @param data - Pointer to the buffer where the read data will be placed
	 * @param size - Size of the read in bytes
	 * 
	 * @return The number of bytes read
	 */
	int sceIoRead(SceUID fd, void* data, SceSize size) {
		return stream(fd).read((cast(ubyte *)data)[0..size]);
	}

	/**
	 * Write output
	 *
	 * @par Example:
	 * @code
	 * bytes_written = sceIoWrite(fd, data, 100);
	 * @endcode
	 *
	 * @param fd - Opened file descriptor to write to
	 * @param data - Pointer to the data to write
	 * @param size - Size of data to write
	 *
	 * @return The number of bytes written
	 */
	int sceIoWrite(SceUID fd, /*const*/ void* data, SceSize size) {
		auto s = stream(fd);
		assert (s.position < 256 * 1024 * 1024); // Less than 256 MB.
		return s.write((cast(ubyte *)data)[0..size]);
	}

	/**
	 * Reposition read/write file descriptor offset
	 *
	 * @par Example:
	 * @code
	 * pos = sceIoLseek(fd, -10, SEEK_END);
	 * @endcode
	 *
	 * @param fd - Opened file descriptor with which to seek
	 * @param offset - Relative offset from the start position given by whence
	 * @param whence - Set to SEEK_SET to seek from the start of the file, SEEK_CUR
	 * seek from the current position and SEEK_END to seek from the end.
	 *
	 * @return The position in the file after the seek. 
	 */
	SceOff sceIoLseek(SceUID fd, SceOff offset, int whence) {
		auto s = stream(fd);
		s.seek(offset, cast(SeekPos)whence);
		//writefln("  position:%08X", s.position);
		return s.position;
	}

	/** 
	  * Get the status of a file.
	  * 
	  * @param file - The path to the file.
	  * @param stat - A pointer to an io_stat_t structure.
	  * 
	  * @return < 0 on error.
	  */
	int sceIoGetstat(const char *file, SceIoStat *stat) {
		return 0;
	}
}

class IoFileMgrForUser : IoFileMgrForKernel {
}

enum { SEEK_SET = 0, SEEK_CUR = 1, SEEK_END = 2 }

/** Access modes for st_mode in SceIoStat (confirm?). */
enum IOAccessModes {
	/** Format bits mask */
	FIO_S_IFMT		= 0xF000,
	/** Symbolic link */
	FIO_S_IFLNK		= 0x4000,
	/** Directory */
	FIO_S_IFDIR		= 0x1000,
	/** Regular file */
	FIO_S_IFREG		= 0x2000,

	/** Set UID */
	FIO_S_ISUID		= 0x0800,
	/** Set GID */
	FIO_S_ISGID		= 0x0400,
	/** Sticky */
	FIO_S_ISVTX		= 0x0200,

	/** User access rights mask */
	FIO_S_IRWXU		= 0x01C0,	
	/** Read user permission */
	FIO_S_IRUSR		= 0x0100,
	/** Write user permission */
	FIO_S_IWUSR		= 0x0080,
	/** Execute user permission */
	FIO_S_IXUSR		= 0x0040,	

	/** Group access rights mask */
	FIO_S_IRWXG		= 0x0038,	
	/** Group read permission */
	FIO_S_IRGRP		= 0x0020,
	/** Group write permission */
	FIO_S_IWGRP		= 0x0010,
	/** Group execute permission */
	FIO_S_IXGRP		= 0x0008,

	/** Others access rights mask */
	FIO_S_IRWXO		= 0x0007,	
	/** Others read permission */
	FIO_S_IROTH		= 0x0004,	
	/** Others write permission */
	FIO_S_IWOTH		= 0x0002,	
	/** Others execute permission */
	FIO_S_IXOTH		= 0x0001,	
}

/** File modes, used for the st_attr parameter in SceIoStat (confirm?). */
enum IOFileModes {
	/** Format mask */
	FIO_SO_IFMT			= 0x0038,		// Format mask
	/** Symlink */
	FIO_SO_IFLNK		= 0x0008,		// Symbolic link
	/** Directory */
	FIO_SO_IFDIR		= 0x0010,		// Directory
	/** Regular file */
	FIO_SO_IFREG		= 0x0020,		// Regular file

	/** Hidden read permission */
	FIO_SO_IROTH		= 0x0004,		// read
	/** Hidden write permission */
	FIO_SO_IWOTH		= 0x0002,		// write
	/** Hidden execute permission */
	FIO_SO_IXOTH		= 0x0001,		// execute
}

/** Structure to hold the status information about a file */
struct SceIoStat {
	SceMode         st_mode;
	uint            st_attr;
	/** Size of the file in bytes. */
	SceOff          st_size;
	/** Creation time. */
	ScePspDateTime  st_ctime;
	/** Access time. */
	ScePspDateTime  st_atime;
	/** Modification time. */
	ScePspDateTime  st_mtime;
	/** Device-specific data. */
	uint            st_private[6];
}

enum : uint {
	PSP_O_RDONLY   = 0x0001,
	PSP_O_WRONLY   = 0x0002,
	PSP_O_RDWR     = (PSP_O_RDONLY | PSP_O_WRONLY),
	PSP_O_NBLOCK   = 0x0004,
	PSP_O_DIROPEN  = 0x0008, // Internal use for dopen
	PSP_O_APPEND   = 0x0100,
	PSP_O_CREAT    = 0x0200,
	PSP_O_TRUNC    = 0x0400,
	PSP_O_EXCL     = 0x0800,
	PSP_O_UNKNOWN1 = 0x4000, // something async?
	PSP_O_NOWAIT   = 0x8000,
	PSP_O_UNKNOWN2 = 0xf0000, // seen on Wipeout Pure and Infected
	PSP_O_UNKNOWN3 = 0x2000000, // seen on Puzzle Guzzle, Hammerin' Hero
}

enum : uint { PSP_SEEK_SET, PSP_SEEK_CUR, PSP_SEEK_END }

static this() {
	mixin(Module.registerModule("IoFileMgrForUser"));
	mixin(Module.registerModule("IoFileMgrForKernel"));
}