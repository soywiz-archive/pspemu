// D import file generated from 'src\core\sys\posix\sys\shm.d'
module core.sys.posix.sys.shm;
private import core.sys.posix.config;

public import core.sys.posix.sys.types;

public import core.sys.posix.sys.ipc;

extern (C) version (linux)
{
    enum SHM_RDONLY = 4096;
    enum SHM_RND = 8192;
    int __getpagesize();
    alias __getpagesize SHMLBA;
    alias c_ulong shmatt_t;
    struct shmid_ds
{
    ipc_perm shm_perm;
    size_t shm_segsz;
    time_t shm_atime;
    c_ulong __unused1;
    time_t shm_dtime;
    c_ulong __unused2;
    time_t shm_ctime;
    c_ulong __unused3;
    pid_t shm_cpid;
    pid_t shm_lpid;
    shmatt_t shm_nattch;
    c_ulong __unused4;
    c_ulong __unused5;
}
    void* shmat(int, in void*, int);
    int shmctl(int, int, shmid_ds*);
    int shmdt(in void*);
    int shmget(key_t, size_t, int);
}
else
{
    version (FreeBSD)
{
    enum SHM_RDONLY = 4096;
    enum SHM_RND = 8192;
    enum SHMLBA = 1 << 12;
    alias c_ulong shmatt_t;
    struct shmid_ds_old
{
    ipc_perm_old shm_perm;
    int shm_segsz;
    pid_t shm_lpid;
    pid_t shm_cpid;
    short shm_nattch;
    time_t shm_atime;
    time_t shm_dtime;
    time_t shm_ctime;
    void* shm_internal;
}
    struct shmid_ds
{
    ipc_perm shm_perm;
    int shm_segsz;
    pid_t shm_lpid;
    pid_t shm_cpid;
    short shm_nattch;
    time_t shm_atime;
    time_t shm_dtime;
    time_t shm_ctime;
}
    void* shmat(int, in void*, int);
    int shmctl(int, int, shmid_ds*);
    int shmdt(in void*);
    int shmget(key_t, size_t, int);
}
else
{
    version (OSX)
{
}
}
}

