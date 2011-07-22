// D import file generated from 'src\core\sys\posix\sys\socket.d'
module core.sys.posix.sys.socket;
private import core.sys.posix.config;

public import core.sys.posix.sys.types;

public import core.sys.posix.sys.uio;

extern (C) 
{
    version (linux)
{
    alias uint socklen_t;
    alias ushort sa_family_t;
    struct sockaddr
{
    sa_family_t sa_family;
    byte[14] sa_data;
}
    private enum : size_t
{
_SS_SIZE = 128,
_SS_PADSIZE = _SS_SIZE - c_ulong.sizeof * 2,
}

    struct sockaddr_storage
{
    sa_family_t ss_family;
    c_ulong __ss_align;
    byte[_SS_PADSIZE] __ss_padding;
}
    struct msghdr
{
    void* msg_name;
    socklen_t msg_namelen;
    iovec* msg_iov;
    size_t msg_iovlen;
    void* msg_control;
    size_t msg_controllen;
    int msg_flags;
}
    struct cmsghdr
{
    size_t cmsg_len;
    int cmsg_level;
    int cmsg_type;
    static if(false)
{
    ubyte[1] __cmsg_data;
}
}
    enum : uint
{
SCM_RIGHTS = 1,
}
    static if(false)
{
    extern (D) ubyte[1] CMSG_DATA(cmsghdr* cmsg)
{
return cmsg.__cmsg_data;
}

}
else
{
    extern (D) ubyte* CMSG_DATA(cmsghdr* cmsg)
{
return cast(ubyte*)(cmsg + 1);
}

}
    private cmsghdr* __cmsg_nxthdr(msghdr*, cmsghdr*);

    alias __cmsg_nxthdr CMSG_NXTHDR;
    extern (D) size_t CMSG_FIRSTHDR(msghdr* mhdr)
{
return cast(size_t)(mhdr.msg_controllen >= cmsghdr.sizeof ? cast(cmsghdr*)mhdr.msg_control : cast(cmsghdr*)null);
}

    struct linger
{
    int l_onoff;
    int l_linger;
}
    enum 
{
SOCK_DGRAM = 2,
SOCK_SEQPACKET = 5,
SOCK_STREAM = 1,
}
    enum 
{
SOL_SOCKET = 1,
}
    enum 
{
SO_ACCEPTCONN = 30,
SO_BROADCAST = 6,
SO_DEBUG = 1,
SO_DONTROUTE = 5,
SO_ERROR = 4,
SO_KEEPALIVE = 9,
SO_LINGER = 13,
SO_OOBINLINE = 10,
SO_RCVBUF = 8,
SO_RCVLOWAT = 18,
SO_RCVTIMEO = 20,
SO_REUSEADDR = 2,
SO_SNDBUF = 7,
SO_SNDLOWAT = 19,
SO_SNDTIMEO = 21,
SO_TYPE = 3,
}
    enum 
{
SOMAXCONN = 128,
}
    enum : uint
{
MSG_CTRUNC = 8,
MSG_DONTROUTE = 4,
MSG_EOR = 128,
MSG_OOB = 1,
MSG_PEEK = 2,
MSG_TRUNC = 32,
MSG_WAITALL = 256,
}
    enum 
{
AF_INET = 2,
AF_UNIX = 1,
AF_UNSPEC = 0,
}
    enum 
{
SHUT_RD,
SHUT_WR,
SHUT_RDWR,
}
    int accept(int, sockaddr*, socklen_t*);
    int bind(int, in sockaddr*, socklen_t);
    int connect(int, in sockaddr*, socklen_t);
    int getpeername(int, sockaddr*, socklen_t*);
    int getsockname(int, sockaddr*, socklen_t*);
    int getsockopt(int, int, int, void*, socklen_t*);
    int listen(int, int);
    ssize_t recv(int, void*, size_t, int);
    ssize_t recvfrom(int, void*, size_t, int, sockaddr*, socklen_t*);
    ssize_t recvmsg(int, msghdr*, int);
    ssize_t send(int, in void*, size_t, int);
    ssize_t sendmsg(int, in msghdr*, int);
    ssize_t sendto(int, in void*, size_t, int, in sockaddr*, socklen_t);
    int setsockopt(int, int, int, in void*, socklen_t);
    int shutdown(int, int);
    int socket(int, int, int);
    int sockatmark(int);
    int socketpair(int, int, int, ref int[2]);
}
else
{
    version (OSX)
{
    alias uint socklen_t;
    alias ubyte sa_family_t;
    struct sockaddr
{
    ubyte sa_len;
    sa_family_t sa_family;
    byte[14] sa_data;
}
    private enum : size_t
{
_SS_PAD1 = (long).sizeof - (ubyte).sizeof - sa_family_t.sizeof,
_SS_PAD2 = 128 - (ubyte).sizeof - sa_family_t.sizeof - _SS_PAD1 - (long).sizeof,
}

    struct sockaddr_storage
{
    ubyte ss_len;
    sa_family_t ss_family;
    byte[_SS_PAD1] __ss_pad1;
    long __ss_align;
    byte[_SS_PAD2] __ss_pad2;
}
    struct msghdr
{
    void* msg_name;
    socklen_t msg_namelen;
    iovec* msg_iov;
    int msg_iovlen;
    void* msg_control;
    socklen_t msg_controllen;
    int msg_flags;
}
    struct cmsghdr
{
    socklen_t cmsg_len;
    int cmsg_level;
    int cmsg_type;
}
    enum : uint
{
SCM_RIGHTS = 1,
}
    struct linger
{
    int l_onoff;
    int l_linger;
}
    enum 
{
SOCK_DGRAM = 2,
SOCK_SEQPACKET = 5,
SOCK_STREAM = 1,
}
    enum : uint
{
SOL_SOCKET = 65535,
}
    enum : uint
{
SO_ACCEPTCONN = 2,
SO_BROADCAST = 32,
SO_DEBUG = 1,
SO_DONTROUTE = 16,
SO_ERROR = 4103,
SO_KEEPALIVE = 8,
SO_LINGER = 4224,
SO_NOSIGPIPE = 4130,
SO_OOBINLINE = 256,
SO_RCVBUF = 4098,
SO_RCVLOWAT = 4100,
SO_RCVTIMEO = 4102,
SO_REUSEADDR = 4,
SO_SNDBUF = 4097,
SO_SNDLOWAT = 4099,
SO_SNDTIMEO = 4101,
SO_TYPE = 4104,
}
    enum 
{
SOMAXCONN = 128,
}
    enum : uint
{
MSG_CTRUNC = 32,
MSG_DONTROUTE = 4,
MSG_EOR = 8,
MSG_OOB = 1,
MSG_PEEK = 2,
MSG_TRUNC = 16,
MSG_WAITALL = 64,
}
    enum 
{
AF_INET = 2,
AF_UNIX = 1,
AF_UNSPEC = 0,
}
    enum 
{
SHUT_RD,
SHUT_WR,
SHUT_RDWR,
}
    int accept(int, sockaddr*, socklen_t*);
    int bind(int, in sockaddr*, socklen_t);
    int connect(int, in sockaddr*, socklen_t);
    int getpeername(int, sockaddr*, socklen_t*);
    int getsockname(int, sockaddr*, socklen_t*);
    int getsockopt(int, int, int, void*, socklen_t*);
    int listen(int, int);
    ssize_t recv(int, void*, size_t, int);
    ssize_t recvfrom(int, void*, size_t, int, sockaddr*, socklen_t*);
    ssize_t recvmsg(int, msghdr*, int);
    ssize_t send(int, in void*, size_t, int);
    ssize_t sendmsg(int, in msghdr*, int);
    ssize_t sendto(int, in void*, size_t, int, in sockaddr*, socklen_t);
    int setsockopt(int, int, int, in void*, socklen_t);
    int shutdown(int, int);
    int socket(int, int, int);
    int sockatmark(int);
    int socketpair(int, int, int, ref int[2]);
}
else
{
    version (FreeBSD)
{
    alias uint socklen_t;
    alias ubyte sa_family_t;
    struct sockaddr
{
    ubyte sa_len;
    sa_family_t sa_family;
    byte[14] sa_data;
}
    private 
{
    enum _SS_ALIGNSIZE = (long).sizeof;
    enum _SS_MAXSIZE = 128;
    enum _SS_PAD1SIZE = _SS_ALIGNSIZE - (ubyte).sizeof - sa_family_t.sizeof;
    enum _SS_PAD2SIZE = _SS_MAXSIZE - (ubyte).sizeof - sa_family_t.sizeof - _SS_PAD1SIZE - _SS_ALIGNSIZE;
}
    struct sockaddr_storage
{
    ubyte ss_len;
    sa_family_t ss_family;
    byte[_SS_PAD1SIZE] __ss_pad1;
    long __ss_align;
    byte[_SS_PAD2SIZE] __ss_pad2;
}
    struct msghdr
{
    void* msg_name;
    socklen_t msg_namelen;
    iovec* msg_iov;
    int msg_iovlen;
    void* msg_control;
    socklen_t msg_controllen;
    int msg_flags;
}
    struct cmsghdr
{
    socklen_t cmsg_len;
    int cmsg_level;
    int cmsg_type;
}
    enum : uint
{
SCM_RIGHTS = 1,
}
    private 
{
    enum _ALIGNBYTES = (int).sizeof - 1;
    extern (D) size_t _ALIGN(size_t p)
{
return p + _ALIGNBYTES & ~_ALIGNBYTES;
}

}
    extern (D) ubyte* CMSG_DATA(cmsghdr* cmsg)
{
return cast(ubyte*)cmsg + _ALIGN(cmsghdr.sizeof);
}

    extern (D) cmsghdr* CMSG_NXTHDR(msghdr* mhdr, cmsghdr* cmsg);

    extern (D) cmsghdr* CMSG_FIRSTHDR(msghdr* mhdr)
{
return mhdr.msg_controllen >= cmsghdr.sizeof ? cast(cmsghdr*)mhdr.msg_control : null;
}

    struct linger
{
    int l_onoff;
    int l_linger;
}
    enum 
{
SOCK_DGRAM = 2,
SOCK_SEQPACKET = 5,
SOCK_STREAM = 1,
}
    enum : uint
{
SOL_SOCKET = 65535,
}
    enum : uint
{
SO_ACCEPTCONN = 2,
SO_BROADCAST = 32,
SO_DEBUG = 1,
SO_DONTROUTE = 16,
SO_ERROR = 4103,
SO_KEEPALIVE = 8,
SO_LINGER = 128,
SO_NOSIGPIPE = 2048,
SO_OOBINLINE = 256,
SO_RCVBUF = 4098,
SO_RCVLOWAT = 4100,
SO_RCVTIMEO = 4102,
SO_REUSEADDR = 4,
SO_SNDBUF = 4097,
SO_SNDLOWAT = 4099,
SO_SNDTIMEO = 4101,
SO_TYPE = 4104,
}
    enum 
{
SOMAXCONN = 128,
}
    enum : uint
{
MSG_CTRUNC = 32,
MSG_DONTROUTE = 4,
MSG_EOR = 8,
MSG_OOB = 1,
MSG_PEEK = 2,
MSG_TRUNC = 16,
MSG_WAITALL = 64,
}
    enum 
{
AF_INET = 2,
AF_UNIX = 1,
AF_UNSPEC = 0,
}
    enum 
{
SHUT_RD = 0,
SHUT_WR = 1,
SHUT_RDWR = 2,
}
    int accept(int, sockaddr*, socklen_t*);
    int bind(int, in sockaddr*, socklen_t);
    int connect(int, in sockaddr*, socklen_t);
    int getpeername(int, sockaddr*, socklen_t*);
    int getsockname(int, sockaddr*, socklen_t*);
    int getsockopt(int, int, int, void*, socklen_t*);
    int listen(int, int);
    ssize_t recv(int, void*, size_t, int);
    ssize_t recvfrom(int, void*, size_t, int, sockaddr*, socklen_t*);
    ssize_t recvmsg(int, msghdr*, int);
    ssize_t send(int, in void*, size_t, int);
    ssize_t sendmsg(int, in msghdr*, int);
    ssize_t sendto(int, in void*, size_t, int, in sockaddr*, socklen_t);
    int setsockopt(int, int, int, in void*, socklen_t);
    int shutdown(int, int);
    int socket(int, int, int);
    int sockatmark(int);
    int socketpair(int, int, int, ref int[2]);
}
}
}
    version (linux)
{
    enum 
{
AF_INET6 = 10,
}
}
else
{
    version (OSX)
{
    enum 
{
AF_INET6 = 30,
}
}
else
{
    version (FreeBSD)
{
    enum 
{
AF_INET6 = 28,
}
}
}
}
    version (linux)
{
    enum 
{
SOCK_RAW = 3,
}
}
else
{
    version (OSX)
{
    enum 
{
SOCK_RAW = 3,
}
}
else
{
    version (FreeBSD)
{
    enum 
{
SOCK_RAW = 3,
}
}
}
}
}
