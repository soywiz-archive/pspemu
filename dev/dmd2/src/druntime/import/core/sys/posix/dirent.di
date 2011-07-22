// D import file generated from 'src\core\sys\posix\dirent.d'
module core.sys.posix.dirent;
private import core.sys.posix.config;

public import core.sys.posix.sys.types;

extern (C) 
{
    version (linux)
{
    enum 
{
DT_UNKNOWN = 0,
DT_FIFO = 1,
DT_CHR = 2,
DT_DIR = 4,
DT_BLK = 6,
DT_REG = 8,
DT_LNK = 10,
DT_SOCK = 12,
DT_WHT = 14,
}
    struct dirent
{
    ino_t d_ino;
    off_t d_off;
    ushort d_reclen;
    ubyte d_type;
    char[256] d_name;
}
    struct DIR
{
}
    static if(__USE_LARGEFILE64)
{
    dirent* readdir64(DIR*);
    alias readdir64 readdir;
}
else
{
    dirent* readdir(DIR*);
}
}
else
{
    version (OSX)
{
    enum 
{
DT_UNKNOWN = 0,
DT_FIFO = 1,
DT_CHR = 2,
DT_DIR = 4,
DT_BLK = 6,
DT_REG = 8,
DT_LNK = 10,
DT_SOCK = 12,
DT_WHT = 14,
}
    align (4)struct dirent
{
    ino_t d_ino;
    ushort d_reclen;
    ubyte d_type;
    ubyte d_namlen;
    char[256] d_name;
}

    struct DIR
{
}
    dirent* readdir(DIR*);
}
else
{
    version (FreeBSD)
{
    enum 
{
DT_UNKNOWN = 0,
DT_FIFO = 1,
DT_CHR = 2,
DT_DIR = 4,
DT_BLK = 6,
DT_REG = 8,
DT_LNK = 10,
DT_SOCK = 12,
DT_WHT = 14,
}
    align (4)struct dirent
{
    uint d_fileno;
    ushort d_reclen;
    ubyte d_type;
    ubyte d_namlen;
    char[256] d_name;
}

    typedef void* DIR;
    dirent* readdir(DIR*);
}
else
{
    version (Posix)
{
    dirent* readdir(DIR*);
}
}
}
}
    version (Posix)
{
    int closedir(DIR*);
    DIR* opendir(in char*);
    void rewinddir(DIR*);
}
    version (linux)
{
    static if(__USE_LARGEFILE64)
{
    int readdir64_r(DIR*, dirent*, dirent**);
    alias readdir64_r readdir_r;
}
else
{
    int readdir_r(DIR*, dirent*, dirent**);
}
}
else
{
    version (OSX)
{
    int readdir_r(DIR*, dirent*, dirent**);
}
else
{
    version (FreeBSD)
{
    int readdir_r(DIR*, dirent*, dirent**);
}
}
}
    version (linux)
{
    void seekdir(DIR*, c_long);
    c_long telldir(DIR*);
}
else
{
    version (FreeBSD)
{
    void seekdir(DIR*, c_long);
    c_long telldir(DIR*);
}
}
}
