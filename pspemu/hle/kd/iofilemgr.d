module pspemu.hle.kd.iofilemgr; // kd/iofilemgr.prx (sceIOFileManager)

debug = DEBUG_SYSCALL;

import std.date;

import pspemu.hle.Module;

import pspemu.utils.Utils;
import pspemu.utils.VirtualFileSystem;

class IoFileMgrForKernel : Module {
	VFS fsroot, gameroot;
	string fscurdir;

	void initModule() {
		fsroot = new VFS("<root>");

		//fsroot["/ms0/PSP/GAME"].addChild(new VFS_Proxy("virtual", new VFS()));

		writefln("ApplicationPaths.exe:%s", ApplicationPaths.exe);
		static if (true) {
			fsroot.addChild(new FileSystem(ApplicationPaths.exe ~ "/pspfs/ms0"), "ms0:");
			fsroot.addChild(new FileSystem(ApplicationPaths.exe ~ "/pspfs/flash0"), "flash0:");
		} else {
			fsroot.addChild(new FileSystem("pspfs/ms0"), "ms0:");
			fsroot.addChild(new FileSystem("pspfs/flash0"), "flash0:");
		}

		// Aliases.
		fsroot.addChild(fsroot["ms0:"], "ms:");
		
		fscurdir = "ms0:/PSP/GAME/virtual";

		gameroot = new VFS_Proxy("<gameroot>", fsroot[fscurdir]);
	}

	void setVirtualDir(string path) {
		fsroot["ms0:/PSP/GAME"].addChild(new FileSystem(path), "virtual");
		gameroot = new VFS_Proxy("<gameroot>", fsroot[fscurdir]);
	}

	void initNids() {
		mixin(registerd!(0x55F4717D, sceIoChdir));
		mixin(registerd!(0x810C4BC3, sceIoClose));
		mixin(registerd!(0x109F50BC, sceIoOpen));
		mixin(registerd!(0x6A638D83, sceIoRead));
		mixin(registerd!(0x42EC03AC, sceIoWrite));
		mixin(registerd!(0x27EB27B8, sceIoLseek));

		mixin(registerd!(0x54F5FB11, sceIoDevctl));

		mixin(registerd!(0xACE946E8, sceIoGetstat));
		mixin(registerd!(0xB8A740F4, sceIoChstat));
		mixin(registerd!(0xF27A9C51, sceIoRemove));
		mixin(registerd!(0x779103A0, sceIoRename));

		mixin(registerd!(0xB29DDF9C, sceIoDopen));
		mixin(registerd!(0xEB092469, sceIoDclose));
		mixin(registerd!(0xE3EB004C, sceIoDread));
		mixin(registerd!(0x06A70004, sceIoMkdir));
		mixin(registerd!(0x1117C65F, sceIoRmdir));
	}

	/** 
	  * Reads an entry from an opened file descriptor.
	  *
	  * @param fd - Already opened file descriptor (using sceIoDopen)
	  * @param dir - Pointer to an io_dirent_t structure to hold the file information
	  *
	  * @return Read status
	  * -   0 - No more directory entries left
	  * - > 0 - More directory entired to go
	  * - < 0 - Error
	  */
	int sceIoDread(SceUID fd, SceIoDirent *dir) {
		unimplemented();
		return -1;
	}

	/**
	 * Make a directory file
	 *
	 * @param path
	 * @param mode - Access mode.
	 * @return Returns the value 0 if its succesful otherwise -1
	 */
	int sceIoMkdir(string path, SceMode mode) {
		unimplemented();
		return -1;
	}

	/**
	 * Remove a directory file
	 *
	 * @param path - Removes a directory file pointed by the string path
	 * @return Returns the value 0 if its succesful otherwise -1
	 */
	int sceIoRmdir(string path) {
		unimplemented();
		return -1;
	}

	/**
	 * Change the name of a file
	 *
	 * @param oldname - The old filename
	 * @param newname - The new filename
	 * @return < 0 on error.
	 */
	int sceIoRename(string oldname, string newname) {
		unimplemented();
		return -1;
	}

	/**
	 * Open a directory
	 * 
	 * @par Example:
	 * @code
	 * int dfd;
	 * dfd = sceIoDopen("device:/");
	 * if(dfd >= 0)
	 * { Do something with the file descriptor }
	 * @endcode
	 * @param dirname - The directory to open for reading.
	 * @return If >= 0 then a valid file descriptor, otherwise a Sony error code.
	 */
	SceUID sceIoDopen(string dirname) {
		unimplemented();
		return -1;
	}

	/**
	 * Close an opened directory file descriptor
	 *
	 * @param fd - Already opened file descriptor (using sceIoDopen)
	 * @return < 0 on error
	 */
	int sceIoDclose(SceUID fd) {
		unimplemented();
		return -1;
	}

	/**
	 * Change the current directory.
	 *
	 * @param path - The path to change to.
	 * @return < 0 on error.
	 */
	int sceIoChdir(string path) {
		unimplemented();
		return -1;
	}

	/** 
	 * Send a devctl command to a device.
	 *
	 * @par Example: Sending a simple command to a device (not a real devctl)
	 * @code
	 * sceIoDevctl("ms0:", 0x200000, indata, 4, NULL, NULL); 
	 * @endcode
	 *
	 * @param dev - String for the device to send the devctl to (e.g. "ms0:")
	 * @param cmd - The command to send to the device
	 * @param indata - A data block to send to the device, if NULL sends no data
	 * @param inlen - Length of indata, if 0 sends no data
	 * @param outdata - A data block to receive the result of a command, if NULL receives no data
	 * @param outlen - Length of outdata, if 0 receives no data
	 * @return 0 on success, < 0 on error
	 */
	int sceIoDevctl(string dev, int cmd, void* indata, int inlen, void* outdata, int outlen) {
		unimplemented();
		return -1;
	}

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
		reinterpret!(Stream)(fd).close();
		return 0;
	}

	VFS locateParentAndUpdateFile(ref string file) {
		VFS vfs = gameroot;

		// A full path.
		if (file.indexOf(":") >= 0) {
			vfs = fsroot;
			//while (file.length && file[0] == '/') file = file[1..$];
		}
		
		//writefln("\n\n\nSELECTED DIR: %s\n\n", vfs);

		return vfs;
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
			
			auto stream = new SliceStream(locateParentAndUpdateFile(file).open(file, fmode, 0777), 0);
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
		auto stream = reinterpret!(Stream)(fd);
		if (stream is null) return -1;
		if (data is null) return -1;
		try {
			return stream.read((cast(ubyte *)data)[0..size]);
		} catch (Object o) {
			throw(o);
			return -1;
		}
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
		auto stream = reinterpret!(Stream)(fd);
		if (stream is null) return -1;
		if (data is null) return -1;
		assert (stream.position < 256 * 1024 * 1024); // Less than 256 MB.
		try {
			return stream.write((cast(ubyte *)data)[0..size]);
		} catch (Object o) {
			throw(o);
			return -1;
		}
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
		auto stream = reinterpret!(Stream)(fd);
		static if (0) {
			writef("posBefore(%d) | ", stream.position);
			switch (whence) {
				case SEEK_SET: stream.position = offset; break;
				case SEEK_CUR: stream.position = stream.position + offset; break;
				case SEEK_END: stream.position = stream.size + offset; break;
			}
			writef("posAfter(%d) | ", stream.position);
		} else {
			stream.seek(offset, cast(SeekPos)whence);
		}
		return stream.position;
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
		ScePspDateTime convertTime(d_time timeD) {
			ScePspDateTime dateTimePsp;
			std.date.Date dateTimeD;
			dateTimeD.parse(toUTCString(timeD));
			with (dateTimePsp) {
				year   = cast(ushort)dateTimeD.year;
				month  = cast(ushort)dateTimeD.month;
				day    = cast(ushort)dateTimeD.day;
				hour   = cast(ushort)dateTimeD.hour;
				minute = cast(ushort)dateTimeD.minute;
				second = cast(ushort)dateTimeD.second;
				microsecond = dateTimeD.ms * 1000;
			}
			return dateTimePsp;
		}
		
		try {
			auto fentry   = locateParentAndUpdateFile(file)[file];
			
			{
				stat.st_mode = 0;
				
				// User access rights mask
				stat.st_mode |= IOAccessModes.FIO_S_IRUSR | IOAccessModes.FIO_S_IWUSR | IOAccessModes.FIO_S_IXUSR;
				// Group access rights mask
				stat.st_mode |= IOAccessModes.FIO_S_IRGRP | IOAccessModes.FIO_S_IWGRP | IOAccessModes.FIO_S_IXGRP;
				// Others access rights mask
				stat.st_mode |= IOAccessModes.FIO_S_IROTH | IOAccessModes.FIO_S_IWOTH | IOAccessModes.FIO_S_IXOTH;

				//stat.st_mode |= FIO_S_IFLNK
				stat.st_mode |= fentry.stats.isdir ? IOAccessModes.FIO_S_IFDIR : IOAccessModes.FIO_S_IFREG;
			}
			{
				stat.st_attr  = 0;
				
				//stat.st_attr |= IOFileModes.FIO_SO_IFLNK;

				stat.st_attr |= fentry.stats.isdir ? IOFileModes.FIO_SO_IFDIR : IOFileModes.FIO_SO_IFREG;
				stat.st_attr |= IOFileModes.FIO_SO_IROTH | IOFileModes.FIO_SO_IWOTH | IOFileModes.FIO_SO_IXOTH; // rwx
			}
			
			stat.st_size  = fentry.stats.size;
			stat.st_ctime = convertTime(fentry.stats.time_c);
			stat.st_atime = convertTime(fentry.stats.time_a);
			stat.st_mtime = convertTime(fentry.stats.time_m);
			return 0;
		} catch (Exception e) {
			writefln("ERROR: STAT!! FAILED: %s", e);
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
	 * @return < 0 on error
	 */
	int sceIoRemove(string file) {
		unimplemented();
		return -1;
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

/*
#define FIO_SO_ISLNK(m)	(((m) & FIO_SO_IFMT) == FIO_SO_IFLNK)
#define FIO_SO_ISREG(m)	(((m) & FIO_SO_IFMT) == FIO_SO_IFREG)
#define FIO_SO_ISDIR(m)	(((m) & FIO_SO_IFMT) == FIO_SO_IFDIR)
*/

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

struct SceIoDirent {
	/** File status. */
	SceIoStat 	d_stat;
	/** File name. */
	char 		d_name[256];
	/** Device-specific data. */
	void * 		d_private;
	int 		dummy;
}

enum : uint { PSP_SEEK_SET, PSP_SEEK_CUR, PSP_SEEK_END }

static this() {
	mixin(Module.registerModule("IoFileMgrForUser"));
	mixin(Module.registerModule("IoFileMgrForKernel"));
}