// D import file generated from 'src\core\sys\posix\sys\uio.d'
module core.sys.posix.sys.uio;
private import core.sys.posix.config;

public import core.sys.posix.sys.types;

extern (C) version (linux)
{
    struct iovec
{
    void* iov_base;
    size_t iov_len;
}
    ssize_t readv(int, in iovec*, int);
    ssize_t writev(int, in iovec*, int);
}
else
{
    version (OSX)
{
    struct iovec
{
    void* iov_base;
    size_t iov_len;
}
    ssize_t readv(int, in iovec*, int);
    ssize_t writev(int, in iovec*, int);
}
else
{
    version (FreeBSD)
{
    struct iovec
{
    void* iov_base;
    size_t iov_len;
}
    ssize_t readv(int, in iovec*, int);
    ssize_t writev(int, in iovec*, int);
}
}
}

