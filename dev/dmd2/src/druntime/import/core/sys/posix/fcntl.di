// D import file generated from 'src\core\sys\posix\fcntl.d'
module core.sys.posix.fcntl;
private import core.sys.posix.config;

private import core.stdc.stdint;

public import core.stdc.stddef;

public import core.sys.posix.sys.types;

public import core.sys.posix.sys.stat;

extern (C) 
{
    version (linux)
{
    enum F_DUPFD = 0;
    enum F_GETFD = 1;
    enum F_SETFD = 2;
    enum F_GETFL = 3;
    enum F_SETFL = 4;
    static if(__USE_FILE_OFFSET64)
{
    enum F_GETLK = 12;
    enum F_SETLK = 13;
    enum F_SETLKW = 14;
}
else
{
    enum F_GETLK = 5;
    enum F_SETLK = 6;
    enum F_SETLKW = 7;
}
    enum F_GETOWN = 9;
    enum F_SETOWN = 8;
    enum FD_CLOEXEC = 1;
    enum F_RDLCK = 0;
    enum F_UNLCK = 2;
    enum F_WRLCK = 1;
    enum O_CREAT = 64;
    enum O_EXCL = 128;
    enum O_NOCTTY = 256;
    enum O_TRUNC = 512;
    enum O_APPEND = 1024;
    enum O_NONBLOCK = 2048;
    enum O_SYNC = 4096;
    enum O_DSYNC = O_SYNC;
    enum O_RSYNC = O_SYNC;
    enum O_ACCMODE = 3;
    enum O_RDONLY = 0;
    enum O_WRONLY = 1;
    enum O_RDWR = 2;
    struct flock
{
    short l_type;
    short l_whence;
    off_t l_start;
    off_t l_len;
    pid_t l_pid;
}
    static if(__USE_LARGEFILE64)
{
    int creat64(in char*, mode_t);
    alias creat64 creat;
    int open64(in char*, int,...);
    alias open64 open;
}
else
{
    int creat(in char*, mode_t);
    int open(in char*, int,...);
}
}
else
{
    version (OSX)
{
    enum F_DUPFD = 0;
    enum F_GETFD = 1;
    enum F_SETFD = 2;
    enum F_GETFL = 3;
    enum F_SETFL = 4;
    enum F_GETOWN = 5;
    enum F_SETOWN = 6;
    enum F_GETLK = 7;
    enum F_SETLK = 8;
    enum F_SETLKW = 9;
    enum FD_CLOEXEC = 1;
    enum F_RDLCK = 1;
    enum F_UNLCK = 2;
    enum F_WRLCK = 3;
    enum O_CREAT = 512;
    enum O_EXCL = 2048;
    enum O_NOCTTY = 0;
    enum O_TRUNC = 1024;
    enum O_RDONLY = 0;
    enum O_WRONLY = 1;
    enum O_RDWR = 2;
    enum O_ACCMODE = 3;
    enum O_NONBLOCK = 4;
    enum O_APPEND = 8;
    enum O_SYNC = 128;
    struct flock
{
    off_t l_start;
    off_t l_len;
    pid_t l_pid;
    short l_type;
    short l_whence;
}
    int creat(in char*, mode_t);
    int open(in char*, int,...);
}
else
{
    version (FreeBSD)
{
    enum F_DUPFD = 0;
    enum F_GETFD = 1;
    enum F_SETFD = 2;
    enum F_GETFL = 3;
    enum F_SETFL = 4;
    enum F_GETOWN = 5;
    enum F_SETOWN = 6;
    enum F_GETLK = 11;
    enum F_SETLK = 12;
    enum F_SETLKW = 13;
    enum F_OGETLK = 7;
    enum F_OSETLK = 8;
    enum F_OSETLKW = 9;
    enum F_DUP2FD = 10;
    enum FD_CLOEXEC = 1;
    enum F_RDLCK = 1;
    enum F_UNLCK = 2;
    enum F_WRLCK = 3;
    enum O_CREAT = 512;
    enum O_EXCL = 2048;
    enum O_NOCTTY = 32768;
    enum O_TRUNC = 1024;
    enum O_RDONLY = 0;
    enum O_WRONLY = 1;
    enum O_RDWR = 2;
    enum O_ACCMODE = 3;
    enum O_NONBLOCK = 4;
    enum O_APPEND = 8;
    enum O_SYNC = 128;
    struct flock
{
    off_t l_start;
    off_t l_len;
    pid_t l_pid;
    short l_type;
    short l_whence;
    int l_sysid;
}
    struct oflock
{
    off_t l_start;
    off_t l_len;
    pid_t l_pid;
    short l_type;
    short l_whence;
}
    int creat(in char*, mode_t);
    int open(in char*, int,...);
}
}
}
    version (Posix)
{
    int fcntl(int, int,...);
}
}
