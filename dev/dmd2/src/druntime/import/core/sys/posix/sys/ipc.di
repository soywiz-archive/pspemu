// D import file generated from 'src\core\sys\posix\sys\ipc.d'
module core.sys.posix.sys.ipc;
private import core.sys.posix.config;

public import core.sys.posix.sys.types;

extern (C) version (linux)
{
    struct ipc_perm
{
    key_t __key;
    uid_t uid;
    gid_t gid;
    uid_t cuid;
    gid_t cgid;
    ushort mode;
    ushort __pad1;
    ushort __seq;
    ushort __pad2;
    c_ulong __unused1;
    c_ulong __unused2;
}
    enum IPC_CREAT = 512;
    enum IPC_EXCL = 1024;
    enum IPC_NOWAIT = 2048;
    enum key_t IPC_PRIVATE = 0;
    enum IPC_RMID = 0;
    enum IPC_SET = 1;
    enum IPC_STAT = 2;
    key_t ftok(in char*, int);
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
    struct ipc_perm_old
{
    ushort cuid;
    ushort cguid;
    ushort uid;
    ushort gid;
    ushort mode;
    ushort seq;
    key_t key;
}
    struct ipc_perm
{
    uid_t cuid;
    gid_t cgid;
    uid_t uid;
    gid_t gid;
    mode_t mode;
    ushort seq;
    key_t key;
}
    enum IPC_CREAT = 512;
    enum IPC_EXCL = 1024;
    enum IPC_NOWAIT = 2048;
    enum key_t IPC_PRIVATE = 0;
    enum IPC_RMID = 0;
    enum IPC_SET = 1;
    enum IPC_STAT = 2;
    key_t ftok(in char*, int);
}
}
}

