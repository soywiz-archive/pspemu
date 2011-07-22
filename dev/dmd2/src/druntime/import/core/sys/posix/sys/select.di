// D import file generated from 'src\core\sys\posix\sys\select.d'
module core.sys.posix.sys.select;
private import core.sys.posix.config;

public import core.stdc.time;

public import core.sys.posix.sys.time;

public import core.sys.posix.sys.types;

public import core.sys.posix.signal;

version (unittest)
{
    import core.stdc.stdio;
}
extern (C) 
{
    version (linux)
{
    private 
{
    alias c_long __fd_mask;
    enum uint __NFDBITS = 8 * __fd_mask.sizeof;
    extern (D) auto  __FDELT(int d)
{
return d / __NFDBITS;
}

    extern (D) auto  __FDMASK(int d)
{
return cast(__fd_mask)1 << d % __NFDBITS;
}

}
    enum FD_SETSIZE = 1024;
    struct fd_set
{
    __fd_mask[FD_SETSIZE / __NFDBITS] fds_bits;
}
    extern (D) void FD_CLR(int fd, fd_set* fdset)
{
fdset.fds_bits[__FDELT(fd)] &= ~__FDMASK(fd);
}

    extern (D) bool FD_ISSET(int fd, const(fd_set)* fdset)
{
return (fdset.fds_bits[__FDELT(fd)] & __FDMASK(fd)) != 0;
}

    extern (D) void FD_SET(int fd, fd_set* fdset)
{
fdset.fds_bits[__FDELT(fd)] |= __FDMASK(fd);
}

    extern (D) void FD_ZERO(fd_set* fdset)
{
fdset.fds_bits[0..$] = 0;
}

    int pselect(int, fd_set*, fd_set*, fd_set*, in timespec*, in sigset_t*);
    int select(int, fd_set*, fd_set*, fd_set*, timeval*);
}
else
{
    version (OSX)
{
    private 
{
    enum uint __DARWIN_NBBY = 8;
    enum uint __DARWIN_NFDBITS = (int).sizeof * __DARWIN_NBBY;
}
    enum FD_SETSIZE = 1024;
    struct fd_set
{
    int[(FD_SETSIZE + (__DARWIN_NFDBITS - 1)) / __DARWIN_NFDBITS] fds_bits;
}
    extern (D) void FD_CLR(int fd, fd_set* fdset)
{
fdset.fds_bits[fd / __DARWIN_NFDBITS] &= ~(1 << fd % __DARWIN_NFDBITS);
}

    extern (D) bool FD_ISSET(int fd, const(fd_set)* fdset)
{
return (fdset.fds_bits[fd / __DARWIN_NFDBITS] & 1 << fd % __DARWIN_NFDBITS) != 0;
}

    extern (D) void FD_SET(int fd, fd_set* fdset)
{
fdset.fds_bits[fd / __DARWIN_NFDBITS] |= 1 << fd % __DARWIN_NFDBITS;
}

    extern (D) void FD_ZERO(fd_set* fdset)
{
fdset.fds_bits[0..$] = 0;
}

    int pselect(int, fd_set*, fd_set*, fd_set*, in timespec*, in sigset_t*);
    int select(int, fd_set*, fd_set*, fd_set*, timeval*);
}
else
{
    version (FreeBSD)
{
    private 
{
    alias c_ulong __fd_mask;
    enum _NFDBITS = __fd_mask.sizeof * 8;
}
    enum uint FD_SETSIZE = 1024;
    struct fd_set
{
    __fd_mask[(FD_SETSIZE + (_NFDBITS - 1)) / _NFDBITS] __fds_bits;
}
    extern (D) __fd_mask __fdset_mask(uint n)
{
return cast(__fd_mask)1 << n % _NFDBITS;
}

    extern (D) void FD_CLR(int n, fd_set* p)
{
p.__fds_bits[n / _NFDBITS] &= ~__fdset_mask(n);
}

    extern (D) bool FD_ISSET(int n, const(fd_set)* p)
{
return (p.__fds_bits[n / _NFDBITS] & __fdset_mask(n)) != 0;
}

    extern (D) void FD_SET(int n, fd_set* p)
{
p.__fds_bits[n / _NFDBITS] |= __fdset_mask(n);
}

    extern (D) void FD_ZERO(fd_set* p);

    int pselect(int, fd_set*, fd_set*, fd_set*, in timespec*, in sigset_t*);
    int select(int, fd_set*, fd_set*, fd_set*, timeval*);
}
}
}
    }
