// D import file generated from 'src\core\sys\posix\sys\mman.d'
module core.sys.posix.sys.mman;
private import core.sys.posix.config;

public import core.stdc.stddef;

public import core.sys.posix.sys.types;

extern (C) 
{
    version (linux)
{
    enum POSIX_MADV_NORMAL = 0;
    enum POSIX_MADV_RANDOM = 1;
    enum POSIX_MADV_SEQUENTIAL = 2;
    enum POSIX_MADV_WILLNEED = 3;
    enum POSIX_MADV_DONTNEED = 4;
}
else
{
    version (OSX)
{
    enum POSIX_MADV_NORMAL = 0;
    enum POSIX_MADV_RANDOM = 1;
    enum POSIX_MADV_SEQUENTIAL = 2;
    enum POSIX_MADV_WILLNEED = 3;
    enum POSIX_MADV_DONTNEED = 4;
}
else
{
    version (FreeBSD)
{
    enum POSIX_MADV_NORMAL = 0;
    enum POSIX_MADV_RANDOM = 1;
    enum POSIX_MADV_SEQUENTIAL = 2;
    enum POSIX_MADV_WILLNEED = 3;
    enum POSIX_MADV_DONTNEED = 4;
}
}
}
    version (linux)
{
    enum PROT_NONE = 0;
    enum PROT_READ = 1;
    enum PROT_WRITE = 2;
    enum PROT_EXEC = 4;
}
else
{
    version (OSX)
{
    enum PROT_NONE = 0;
    enum PROT_READ = 1;
    enum PROT_WRITE = 2;
    enum PROT_EXEC = 4;
}
else
{
    version (FreeBSD)
{
    enum PROT_NONE = 0;
    enum PROT_READ = 1;
    enum PROT_WRITE = 2;
    enum PROT_EXEC = 4;
}
}
}
    version (linux)
{
    int munmap(void*, size_t);
    static if(__USE_LARGEFILE64)
{
    void* mmap64(void*, size_t, int, int, int, off_t);
    alias mmap64 mmap;
}
else
{
    void* mmap(void*, size_t, int, int, int, off_t);
}
}
else
{
    version (OSX)
{
    void* mmap(void*, size_t, int, int, int, off_t);
    int munmap(void*, size_t);
}
else
{
    version (FreeBSD)
{
    void* mmap(void*, size_t, int, int, int, off_t);
    int munmap(void*, size_t);
}
}
}
    version (linux)
{
    enum MAP_SHARED = 1;
    enum MAP_PRIVATE = 2;
    enum MAP_FIXED = 16;
    enum MAP_ANON = 32;
    enum MAP_FAILED = cast(void*)-1;
    enum 
{
MS_ASYNC = 1,
MS_SYNC = 4,
MS_INVALIDATE = 2,
}
    int msync(void*, size_t, int);
}
else
{
    version (OSX)
{
    enum MAP_SHARED = 1;
    enum MAP_PRIVATE = 2;
    enum MAP_FIXED = 16;
    enum MAP_ANON = 4096;
    enum MAP_FAILED = cast(void*)-1;
    enum MS_ASYNC = 1;
    enum MS_INVALIDATE = 2;
    enum MS_SYNC = 16;
    int msync(void*, size_t, int);
}
else
{
    version (FreeBSD)
{
    enum MAP_SHARED = 1;
    enum MAP_PRIVATE = 2;
    enum MAP_FIXED = 16;
    enum MAP_ANON = 4096;
    enum MAP_FAILED = cast(void*)-1;
    enum MS_SYNC = 0;
    enum MS_ASYNC = 1;
    enum MS_INVALIDATE = 2;
    int msync(void*, size_t, int);
}
}
}
    version (linux)
{
    enum MCL_CURRENT = 1;
    enum MCL_FUTURE = 2;
    int mlockall(int);
    int munlockall();
}
else
{
    version (OSX)
{
    enum MCL_CURRENT = 1;
    enum MCL_FUTURE = 2;
    int mlockall(int);
    int munlockall();
}
else
{
    version (FreeBSD)
{
    enum MCL_CURRENT = 1;
    enum MCL_FUTURE = 2;
    int mlockall(int);
    int munlockall();
}
}
}
    version (linux)
{
    int mlock(in void*, size_t);
    int munlock(in void*, size_t);
}
else
{
    version (OSX)
{
    int mlock(in void*, size_t);
    int munlock(in void*, size_t);
}
else
{
    version (FreeBSD)
{
    int mlock(in void*, size_t);
    int munlock(in void*, size_t);
}
}
}
    version (OSX)
{
    int mprotect(void*, size_t, int);
}
else
{
    version (FreeBSD)
{
    int mprotect(void*, size_t, int);
}
}
    version (linux)
{
    int shm_open(in char*, int, mode_t);
    int shm_unlink(in char*);
}
else
{
    version (OSX)
{
    int shm_open(in char*, int, mode_t);
    int shm_unlink(in char*);
}
else
{
    version (FreeBSD)
{
    int shm_open(in char*, int, mode_t);
    int shm_unlink(in char*);
}
}
}
}
