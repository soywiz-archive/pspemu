// D import file generated from 'src\core\sys\posix\sys\stat.d'
module core.sys.posix.sys.stat;
private import core.sys.posix.config;

private import core.stdc.stdint;

private import core.sys.posix.time;

public import core.stdc.stddef;

public import core.sys.posix.sys.types;

extern (C) 
{
    version (linux)
{
    static if(__USE_LARGEFILE64)
{
    private alias uint _pad_t;

}
else
{
    private alias ushort _pad_t;

}
    struct stat_t
{
    dev_t st_dev;
    _pad_t __pad1;
    static if(__USE_FILE_OFFSET64)
{
    ino_t __st_ino;
}
else
{
    ino_t st_ino;
}
    mode_t st_mode;
    nlink_t st_nlink;
    uid_t st_uid;
    gid_t st_gid;
    dev_t st_rdev;
    _pad_t __pad2;
    off_t st_size;
    blksize_t st_blksize;
    blkcnt_t st_blocks;
    static if(false)
{
    timespec st_atim;
    timespec st_mtim;
    timespec st_ctim;
    alias st_atim.tv_sec st_atime;
    alias st_mtim.tv_sec st_mtime;
    alias st_ctim.tv_sec st_ctime;
}
else
{
    time_t st_atime;
    c_ulong st_atimensec;
    time_t st_mtime;
    c_ulong st_mtimensec;
    time_t st_ctime;
    c_ulong st_ctimensec;
}
    static if(__USE_FILE_OFFSET64)
{
    ino_t st_ino;
}
else
{
    c_ulong __unused4;
    c_ulong __unused5;
}
}
    enum S_IRUSR = 256;
    enum S_IWUSR = 128;
    enum S_IXUSR = 64;
    enum S_IRWXU = S_IRUSR | S_IWUSR | S_IXUSR;
    enum S_IRGRP = S_IRUSR >> 3;
    enum S_IWGRP = S_IWUSR >> 3;
    enum S_IXGRP = S_IXUSR >> 3;
    enum S_IRWXG = S_IRWXU >> 3;
    enum S_IROTH = S_IRGRP >> 3;
    enum S_IWOTH = S_IWGRP >> 3;
    enum S_IXOTH = S_IXGRP >> 3;
    enum S_IRWXO = S_IRWXG >> 3;
    enum S_ISUID = 2048;
    enum S_ISGID = 1024;
    enum S_ISVTX = 512;
    private extern (D) bool S_ISTYPE(mode_t mode, uint mask)
{
return (mode & S_IFMT) == mask;
}


    extern (D) bool S_ISBLK(mode_t mode)
{
return S_ISTYPE(mode,S_IFBLK);
}

    extern (D) bool S_ISCHR(mode_t mode)
{
return S_ISTYPE(mode,S_IFCHR);
}

    extern (D) bool S_ISDIR(mode_t mode)
{
return S_ISTYPE(mode,S_IFDIR);
}

    extern (D) bool S_ISFIFO(mode_t mode)
{
return S_ISTYPE(mode,S_IFIFO);
}

    extern (D) bool S_ISREG(mode_t mode)
{
return S_ISTYPE(mode,S_IFREG);
}

    extern (D) bool S_ISLNK(mode_t mode)
{
return S_ISTYPE(mode,S_IFLNK);
}

    extern (D) bool S_ISSOCK(mode_t mode)
{
return S_ISTYPE(mode,S_IFSOCK);
}

    static if(true)
{
    extern bool S_TYPEISMQ(stat_t* buf)
{
return false;
}

    extern bool S_TYPEISSEM(stat_t* buf)
{
return false;
}

    extern bool S_TYPEISSHM(stat_t* buf)
{
return false;
}

}
}
else
{
    version (OSX)
{
    struct stat_t
{
    dev_t st_dev;
    ino_t st_ino;
    mode_t st_mode;
    nlink_t st_nlink;
    uid_t st_uid;
    gid_t st_gid;
    dev_t st_rdev;
    static if(false)
{
    timespec st_atimespec;
    timespec st_mtimespec;
    timespec st_ctimespec;
}
else
{
    time_t st_atime;
    c_long st_atimensec;
    time_t st_mtime;
    c_long st_mtimensec;
    time_t st_ctime;
    c_long st_ctimensec;
}
    off_t st_size;
    blkcnt_t st_blocks;
    blksize_t st_blksize;
    uint st_flags;
    uint st_gen;
    int st_lspare;
    long[2] st_qspare;
}
    enum S_IRUSR = 256;
    enum S_IWUSR = 128;
    enum S_IXUSR = 64;
    enum S_IRWXU = S_IRUSR | S_IWUSR | S_IXUSR;
    enum S_IRGRP = S_IRUSR >> 3;
    enum S_IWGRP = S_IWUSR >> 3;
    enum S_IXGRP = S_IXUSR >> 3;
    enum S_IRWXG = S_IRWXU >> 3;
    enum S_IROTH = S_IRGRP >> 3;
    enum S_IWOTH = S_IWGRP >> 3;
    enum S_IXOTH = S_IXGRP >> 3;
    enum S_IRWXO = S_IRWXG >> 3;
    enum S_ISUID = 2048;
    enum S_ISGID = 1024;
    enum S_ISVTX = 512;
    private extern (D) bool S_ISTYPE(mode_t mode, uint mask)
{
return (mode & S_IFMT) == mask;
}


    extern (D) bool S_ISBLK(mode_t mode)
{
return S_ISTYPE(mode,S_IFBLK);
}

    extern (D) bool S_ISCHR(mode_t mode)
{
return S_ISTYPE(mode,S_IFCHR);
}

    extern (D) bool S_ISDIR(mode_t mode)
{
return S_ISTYPE(mode,S_IFDIR);
}

    extern (D) bool S_ISFIFO(mode_t mode)
{
return S_ISTYPE(mode,S_IFIFO);
}

    extern (D) bool S_ISREG(mode_t mode)
{
return S_ISTYPE(mode,S_IFREG);
}

    extern (D) bool S_ISLNK(mode_t mode)
{
return S_ISTYPE(mode,S_IFLNK);
}

    extern (D) bool S_ISSOCK(mode_t mode)
{
return S_ISTYPE(mode,S_IFSOCK);
}

}
else
{
    version (FreeBSD)
{
    struct stat_t
{
    dev_t st_dev;
    ino_t st_ino;
    mode_t st_mode;
    nlink_t st_nlink;
    uid_t st_uid;
    gid_t st_gid;
    dev_t st_rdev;
    time_t st_atime;
    c_long __st_atimensec;
    time_t st_mtime;
    c_long __st_mtimensec;
    time_t st_ctime;
    c_long __st_ctimensec;
    off_t st_size;
    blkcnt_t st_blocks;
    blksize_t st_blksize;
    fflags_t st_flags;
    uint st_gen;
    int st_lspare;
    time_t st_birthtime;
    c_long st_birthtimensec;
    ubyte[16 - timespec.sizeof] padding;
}
    enum S_IRUSR = 256;
    enum S_IWUSR = 128;
    enum S_IXUSR = 64;
    enum S_IRWXU = 448;
    enum S_IRGRP = 32;
    enum S_IWGRP = 16;
    enum S_IXGRP = 8;
    enum S_IRWXG = 56;
    enum S_IROTH = 4;
    enum S_IWOTH = 2;
    enum S_IXOTH = 1;
    enum S_IRWXO = 7;
    enum S_ISUID = 2048;
    enum S_ISGID = 1024;
    enum S_ISVTX = 512;
    private extern (D) bool S_ISTYPE(mode_t mode, uint mask)
{
return (mode & S_IFMT) == mask;
}


    extern (D) bool S_ISBLK(mode_t mode)
{
return S_ISTYPE(mode,S_IFBLK);
}

    extern (D) bool S_ISCHR(mode_t mode)
{
return S_ISTYPE(mode,S_IFCHR);
}

    extern (D) bool S_ISDIR(mode_t mode)
{
return S_ISTYPE(mode,S_IFDIR);
}

    extern (D) bool S_ISFIFO(mode_t mode)
{
return S_ISTYPE(mode,S_IFIFO);
}

    extern (D) bool S_ISREG(mode_t mode)
{
return S_ISTYPE(mode,S_IFREG);
}

    extern (D) bool S_ISLNK(mode_t mode)
{
return S_ISTYPE(mode,S_IFLNK);
}

    extern (D) bool S_ISSOCK(mode_t mode)
{
return S_ISTYPE(mode,S_IFSOCK);
}

}
}
}
    version (Posix)
{
    int chmod(in char*, mode_t);
    int fchmod(int, mode_t);
    int mkdir(in char*, mode_t);
    int mkfifo(in char*, mode_t);
    mode_t umask(mode_t);
}
    version (linux)
{
    static if(__USE_LARGEFILE64)
{
    int fstat64(int, stat_t*);
    alias fstat64 fstat;
    int lstat64(in char*, stat_t*);
    alias lstat64 lstat;
    int stat64(in char*, stat_t*);
    alias stat64 stat;
}
else
{
    int fstat(int, stat_t*);
    int lstat(in char*, stat_t*);
    int stat(in char*, stat_t*);
}
}
else
{
    version (Posix)
{
    int fstat(int, stat_t*);
    int lstat(in char*, stat_t*);
    int stat(in char*, stat_t*);
}
}
    version (linux)
{
    enum S_IFMT = 61440;
    enum S_IFBLK = 24576;
    enum S_IFCHR = 8192;
    enum S_IFIFO = 4096;
    enum S_IFREG = 32768;
    enum S_IFDIR = 16384;
    enum S_IFLNK = 40960;
    enum S_IFSOCK = 49152;
    int mknod(in char*, mode_t, dev_t);
}
else
{
    version (OSX)
{
    enum S_IFMT = 61440;
    enum S_IFBLK = 24576;
    enum S_IFCHR = 8192;
    enum S_IFIFO = 4096;
    enum S_IFREG = 32768;
    enum S_IFDIR = 16384;
    enum S_IFLNK = 40960;
    enum S_IFSOCK = 49152;
    int mknod(in char*, mode_t, dev_t);
}
else
{
    version (FreeBSD)
{
    enum S_IFMT = 61440;
    enum S_IFBLK = 24576;
    enum S_IFCHR = 8192;
    enum S_IFIFO = 4096;
    enum S_IFREG = 32768;
    enum S_IFDIR = 16384;
    enum S_IFLNK = 40960;
    enum S_IFSOCK = 49152;
    int mknod(in char*, mode_t, dev_t);
}
}
}
}
