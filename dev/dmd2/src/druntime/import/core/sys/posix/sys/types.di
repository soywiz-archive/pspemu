// D import file generated from 'src\core\sys\posix\sys\types.d'
module core.sys.posix.sys.types;
private import core.sys.posix.config;

private import core.stdc.stdint;

public import core.stdc.stddef;

public import core.stdc.time;

extern (C) 
{
    version (linux)
{
    static if(__USE_FILE_OFFSET64)
{
    alias long blkcnt_t;
    alias ulong ino_t;
    alias long off_t;
}
else
{
    alias c_long blkcnt_t;
    alias c_ulong ino_t;
    alias c_long off_t;
}
    alias c_long blksize_t;
    alias ulong dev_t;
    alias uint gid_t;
    alias uint mode_t;
    alias c_ulong nlink_t;
    alias int pid_t;
    alias c_long ssize_t;
    alias uint uid_t;
}
else
{
    version (OSX)
{
    alias long blkcnt_t;
    alias int blksize_t;
    alias int dev_t;
    alias uint gid_t;
    alias uint ino_t;
    alias ushort mode_t;
    alias ushort nlink_t;
    alias long off_t;
    alias int pid_t;
    alias c_long ssize_t;
    alias uint uid_t;
}
else
{
    version (FreeBSD)
{
    alias long blkcnt_t;
    alias uint blksize_t;
    alias uint dev_t;
    alias uint gid_t;
    alias uint ino_t;
    alias ushort mode_t;
    alias ushort nlink_t;
    alias long off_t;
    alias int pid_t;
    alias c_long ssize_t;
    alias uint uid_t;
    alias uint fflags_t;
}
}
}
    version (linux)
{
    static if(__USE_FILE_OFFSET64)
{
    alias ulong fsblkcnt_t;
    alias ulong fsfilcnt_t;
}
else
{
    alias c_ulong fsblkcnt_t;
    alias c_ulong fsfilcnt_t;
}
    alias uint id_t;
    alias int key_t;
    alias c_long suseconds_t;
    alias uint useconds_t;
}
else
{
    version (OSX)
{
    alias uint fsblkcnt_t;
    alias uint fsfilcnt_t;
    alias uint id_t;
    alias int suseconds_t;
    alias uint useconds_t;
}
else
{
    version (FreeBSD)
{
    alias ulong fsblkcnt_t;
    alias ulong fsfilcnt_t;
    alias long id_t;
    alias c_long key_t;
    alias c_long suseconds_t;
    alias uint useconds_t;
}
}
}
    version (linux)
{
    version (X86)
{
    enum __SIZEOF_PTHREAD_ATTR_T = 36;
    enum __SIZEOF_PTHREAD_MUTEX_T = 24;
    enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
    enum __SIZEOF_PTHREAD_COND_T = 48;
    enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
    enum __SIZEOF_PTHREAD_RWLOCK_T = 32;
    enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
    enum __SIZEOF_PTHREAD_BARRIER_T = 20;
    enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
}
else
{
    version (X86_64)
{
    enum __SIZEOF_PTHREAD_ATTR_T = 56;
    enum __SIZEOF_PTHREAD_MUTEX_T = 40;
    enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
    enum __SIZEOF_PTHREAD_COND_T = 48;
    enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
    enum __SIZEOF_PTHREAD_RWLOCK_T = 56;
    enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
    enum __SIZEOF_PTHREAD_BARRIER_T = 32;
    enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
}
}
    union pthread_attr_t
{
    byte[__SIZEOF_PTHREAD_ATTR_T] __size;
    c_long __align;
}
    private alias int __atomic_lock_t;

    private struct _pthread_fastlock
{
    c_long __status;
    __atomic_lock_t __spinlock;
}

    private alias void* _pthread_descr;

    union pthread_cond_t
{
    byte[__SIZEOF_PTHREAD_COND_T] __size;
    long __align;
}
    union pthread_condattr_t
{
    byte[__SIZEOF_PTHREAD_CONDATTR_T] __size;
    int __align;
}
    alias uint pthread_key_t;
    union pthread_mutex_t
{
    byte[__SIZEOF_PTHREAD_MUTEX_T] __size;
    c_long __align;
}
    union pthread_mutexattr_t
{
    byte[__SIZEOF_PTHREAD_MUTEXATTR_T] __size;
    int __align;
}
    alias int pthread_once_t;
    struct pthread_rwlock_t
{
    byte[__SIZEOF_PTHREAD_RWLOCK_T] __size;
    c_long __align;
}
    struct pthread_rwlockattr_t
{
    byte[__SIZEOF_PTHREAD_RWLOCKATTR_T] __size;
    c_long __align;
}
    alias c_ulong pthread_t;
}
else
{
    version (OSX)
{
    version (X86_64)
{
    enum __PTHREAD_SIZE__ = 1168;
    enum __PTHREAD_ATTR_SIZE__ = 56;
    enum __PTHREAD_MUTEXATTR_SIZE__ = 8;
    enum __PTHREAD_MUTEX_SIZE__ = 56;
    enum __PTHREAD_CONDATTR_SIZE__ = 8;
    enum __PTHREAD_COND_SIZE__ = 40;
    enum __PTHREAD_ONCE_SIZE__ = 8;
    enum __PTHREAD_RWLOCK_SIZE__ = 192;
    enum __PTHREAD_RWLOCKATTR_SIZE__ = 16;
}
else
{
    version (X86)
{
    enum __PTHREAD_SIZE__ = 596;
    enum __PTHREAD_ATTR_SIZE__ = 36;
    enum __PTHREAD_MUTEXATTR_SIZE__ = 8;
    enum __PTHREAD_MUTEX_SIZE__ = 40;
    enum __PTHREAD_CONDATTR_SIZE__ = 4;
    enum __PTHREAD_COND_SIZE__ = 24;
    enum __PTHREAD_ONCE_SIZE__ = 4;
    enum __PTHREAD_RWLOCK_SIZE__ = 124;
    enum __PTHREAD_RWLOCKATTR_SIZE__ = 12;
}
}
    struct pthread_handler_rec
{
    void function(void*) __routine;
    void* __arg;
    pthread_handler_rec* __next;
}
    struct pthread_attr_t
{
    c_long __sig;
    byte[__PTHREAD_ATTR_SIZE__] __opaque;
}
    struct pthread_cond_t
{
    c_long __sig;
    byte[__PTHREAD_COND_SIZE__] __opaque;
}
    struct pthread_condattr_t
{
    c_long __sig;
    byte[__PTHREAD_CONDATTR_SIZE__] __opaque;
}
    alias c_ulong pthread_key_t;
    struct pthread_mutex_t
{
    c_long __sig;
    byte[__PTHREAD_MUTEX_SIZE__] __opaque;
}
    struct pthread_mutexattr_t
{
    c_long __sig;
    byte[__PTHREAD_MUTEXATTR_SIZE__] __opaque;
}
    struct pthread_once_t
{
    c_long __sig;
    byte[__PTHREAD_ONCE_SIZE__] __opaque;
}
    struct pthread_rwlock_t
{
    c_long __sig;
    byte[__PTHREAD_RWLOCK_SIZE__] __opaque;
}
    struct pthread_rwlockattr_t
{
    c_long __sig;
    byte[__PTHREAD_RWLOCKATTR_SIZE__] __opaque;
}
    private struct _opaque_pthread_t
{
    c_long __sig;
    pthread_handler_rec* __cleanup_stack;
    byte[__PTHREAD_SIZE__] __opaque;
}

    alias _opaque_pthread_t* pthread_t;
}
else
{
    version (FreeBSD)
{
    alias int lwpid_t;
    alias void* pthread_attr_t;
    alias void* pthread_cond_t;
    alias void* pthread_condattr_t;
    alias void* pthread_key_t;
    alias void* pthread_mutex_t;
    alias void* pthread_mutexattr_t;
    alias void* pthread_once_t;
    alias void* pthread_rwlock_t;
    alias void* pthread_rwlockattr_t;
    alias void* pthread_t;
}
}
}
    version (linux)
{
    struct pthread_barrier_t
{
    byte[__SIZEOF_PTHREAD_BARRIER_T] __size;
    c_long __align;
}
    struct pthread_barrierattr_t
{
    byte[__SIZEOF_PTHREAD_BARRIERATTR_T] __size;
    int __align;
}
}
else
{
    version (FreeBSD)
{
    alias void* pthread_barrier_t;
    alias void* pthread_barrierattr_t;
}
}
    version (linux)
{
    alias int pthread_spinlock_t;
}
else
{
    version (OSX)
{
}
else
{
    version (FreeBSD)
{
    alias void* pthread_spinlock_t;
}
}
}
}
