module pspemu.hle.kd.iofilemgr.Types;

public import pspemu.hle.kd.Types;

enum { SEEK_SET = 0, SEEK_CUR = 1, SEEK_END = 2 }

/** Access modes for st_mode in SceIoStat (confirm?). */
enum IOAccessModes {
	FIO_S_IFMT		= 0xF000, /// Format bits mask
	FIO_S_IFLNK		= 0x4000, /// Symbolic link
	FIO_S_IFDIR		= 0x1000, /// Directory
	FIO_S_IFREG		= 0x2000, /// Regular file

	FIO_S_ISUID		= 0x0800, /// Set UID
	FIO_S_ISGID		= 0x0400, /// Set GID
	FIO_S_ISVTX		= 0x0200, /// Sticky

	FIO_S_IRWXU		= 0x01C0, /// User access rights mask
	FIO_S_IRUSR		= 0x0100, /// Read user permission
	FIO_S_IWUSR		= 0x0080, /// Write user permission
	FIO_S_IXUSR		= 0x0040, /// Execute user permission

	FIO_S_IRWXG		= 0x0038, /// Group access rights mask
	FIO_S_IRGRP		= 0x0020, /// Group read permission
	FIO_S_IWGRP		= 0x0010, /// Group write permission
	FIO_S_IXGRP		= 0x0008, /// Group execute permission

	FIO_S_IRWXO		= 0x0007, /// Others access rights mask
	FIO_S_IROTH		= 0x0004, /// Others read permission
	FIO_S_IWOTH		= 0x0002, /// Others write permission
	FIO_S_IXOTH		= 0x0001, /// Others execute permission
}

/** File modes, used for the st_attr parameter in SceIoStat (confirm?). */
enum IOFileModes {
	FIO_SO_IFMT			= 0x0038,		/// Format mask
	FIO_SO_IFLNK		= 0x0008,		/// Symbolic link
	FIO_SO_IFDIR		= 0x0010,		/// Directory
	FIO_SO_IFREG		= 0x0020,		/// Regular file

	FIO_SO_IROTH		= 0x0004,		/// Hidden read permission
	FIO_SO_IWOTH		= 0x0002,		/// Hidden write permission
	FIO_SO_IXOTH		= 0x0001,		/// Hidden execute permission
}

/*
#define FIO_SO_ISLNK(m)	(((m) & FIO_SO_IFMT) == FIO_SO_IFLNK)
#define FIO_SO_ISREG(m)	(((m) & FIO_SO_IFMT) == FIO_SO_IFREG)
#define FIO_SO_ISDIR(m)	(((m) & FIO_SO_IFMT) == FIO_SO_IFDIR)
*/

/** Structure to hold the status information about a file */
struct SceIoStat {
	SceMode         st_mode;
	IOFileModes     st_attr;
	SceOff          st_size;  /// Size of the file in bytes.
	ScePspDateTime  st_ctime; /// Creation time.
	ScePspDateTime  st_atime; /// Access time.
	ScePspDateTime  st_mtime; /// Modification time.
	uint            st_private[6]; /// Device-specific data.
}

enum SceIoFlags : uint {
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
	SceIoStat   d_stat;    /// File status.
	char[256]   d_name;    /// File name.
	void*       d_private; /// Device-specific data.
	int         dummy;
}

enum : uint { PSP_SEEK_SET, PSP_SEEK_CUR, PSP_SEEK_END }

/** Structure passed to the init and exit functions of the io driver system */
struct PspIoDrvArg {
	PspIoDrv* drv; /// Pointer to the original driver which was added
	void*     arg; /// Pointer to a user defined argument (if written by the driver will preseve across calls
}

/** Structure passed to the file functions of the io driver system */
struct PspIoDrvFileArg {
	u32 unk1;         /// Unknown
	u32 fs_num;       /// The file system number, e.g. if a file is opened as host5:/myfile.txt this field will be 5
	PspIoDrvArg *drv; /// Pointer to the driver structure
	u32 unk2;         /// Unknown, again
	void *arg;        /// Pointer to a user defined argument, this is preserved on a per file basis
}

/** Structure to maintain the file driver pointers */
struct PspIoDrvFuncs { extern (C):
	int function(PspIoDrvArg* arg) IoInit;
	int function(PspIoDrvArg* arg) IoExit;

	int function(PspIoDrvFileArg* arg, char* file, int flags, SceMode mode) IoOpen;
	int function(PspIoDrvFileArg* arg) IoClose;
	int function(PspIoDrvFileArg* arg, char* data, int len) IoRead;
	int function(PspIoDrvFileArg* arg, const char* data, int len) IoWrite;
	SceOff function(PspIoDrvFileArg* arg, SceOff ofs, int whence) IoLseek;
	int function(PspIoDrvFileArg* arg, uint cmd, void* indata, int inlen, void* outdata, int outlen) IoIoctl;
	int function(PspIoDrvFileArg* arg, const char* name) IoRemove;
	int function(PspIoDrvFileArg* arg, const char* name, SceMode mode) IoMkdir;
	int function(PspIoDrvFileArg* arg, const char* name) IoRmdir;
	int function(PspIoDrvFileArg* arg, const char* dirname) IoDopen;
	int function(PspIoDrvFileArg* arg) IoDclose;
	int function(PspIoDrvFileArg* arg, SceIoDirent* dir) IoDread;
	int function(PspIoDrvFileArg* arg, const char* file, SceIoStat* stat) IoGetstat;
	int function(PspIoDrvFileArg* arg, const char* file, SceIoStat* stat, int bits) IoChstat;
	int function(PspIoDrvFileArg* arg, const char* oldname, const char* newname) IoRename;
	int function(PspIoDrvFileArg* arg, const char* dir) IoChdir;
	int function(PspIoDrvFileArg* arg) IoMount;
	int function(PspIoDrvFileArg* arg) IoUmount;
	int function(PspIoDrvFileArg* arg, const char* devname, uint cmd, void* indata, int inlen, void* outdata, int outlen) IoDevctl;
	int function(PspIoDrvFileArg* arg) IoUnk21;
}

struct PspIoDrv {
	char* name;           /// The name of the device to add
	u32 dev_type;         /// Device type, this 0x10 is for a filesystem driver
	u32 unk2;             /// Unknown, set to 0x800
	char* name2;          /// This seems to be the same as name but capitalised :/
	PspIoDrvFuncs* funcs; /// Pointer to a filled out functions table
}
