// D import file generated from 'src\core\sys\posix\netinet\in_.d'
module core.sys.posix.netinet.in_;
private import core.sys.posix.config;

public import core.stdc.inttypes;

public import core.sys.posix.arpa.inet;

public import core.sys.posix.sys.socket;

extern (C) 
{
    version (linux)
{
    private enum __SOCK_SIZE__ = 16;

    struct sockaddr_in
{
    sa_family_t sin_family;
    in_port_t sin_port;
    in_addr sin_addr;
    ubyte[__SOCK_SIZE__ - sa_family_t.sizeof - in_port_t.sizeof - in_addr.sizeof] __pad;
}
    enum 
{
IPPROTO_IP = 0,
IPPROTO_ICMP = 1,
IPPROTO_TCP = 6,
IPPROTO_UDP = 17,
}
    enum uint INADDR_ANY = 0;
    enum uint INADDR_BROADCAST = -1u;
    enum INET_ADDRSTRLEN = 16;
}
else
{
    version (OSX)
{
    private enum __SOCK_SIZE__ = 16;

    struct sockaddr_in
{
    ubyte sin_len;
    sa_family_t sin_family;
    in_port_t sin_port;
    in_addr sin_addr;
    ubyte[8] sin_zero;
}
    enum 
{
IPPROTO_IP = 0,
IPPROTO_ICMP = 1,
IPPROTO_TCP = 6,
IPPROTO_UDP = 17,
}
    enum uint INADDR_ANY = 0;
    enum uint INADDR_BROADCAST = -1u;
    enum INET_ADDRSTRLEN = 16;
}
else
{
    version (FreeBSD)
{
    struct sockaddr_in
{
    ubyte sin_len;
    sa_family_t sin_family;
    in_port_t sin_port;
    in_addr sin_addr;
    ubyte[8] sin_zero;
}
    enum 
{
IPPROTO_IP = 0,
IPPROTO_ICMP = 1,
IPPROTO_TCP = 6,
IPPROTO_UDP = 17,
}
    enum uint INADDR_ANY = 0;
    enum uint INADDR_BROADCAST = -1u;
}
}
}
    version (linux)
{
    struct in6_addr
{
    union
{
uint8_t[16] s6_addr;
uint16_t[8] s6_addr16;
uint32_t[4] s6_addr32;
}
}
    struct sockaddr_in6
{
    sa_family_t sin6_family;
    in_port_t sin6_port;
    uint32_t sin6_flowinfo;
    in6_addr sin6_addr;
    uint32_t sin6_scope_id;
}
    extern immutable __gshared in6_addr in6addr_any;

    extern immutable __gshared in6_addr in6addr_loopback;

    struct ipv6_mreq
{
    in6_addr ipv6mr_multiaddr;
    uint ipv6mr_interface;
}
    enum : uint
{
IPPROTO_IPV6 = 41,
INET6_ADDRSTRLEN = 46,
IPV6_JOIN_GROUP = 20,
IPV6_LEAVE_GROUP = 21,
IPV6_MULTICAST_HOPS = 18,
IPV6_MULTICAST_IF = 17,
IPV6_MULTICAST_LOOP = 19,
IPV6_UNICAST_HOPS = 16,
IPV6_V6ONLY = 26,
}
    extern (D) int IN6_IS_ADDR_UNSPECIFIED(in6_addr* addr)
{
return (cast(uint32_t*)addr)[0] == 0 && (cast(uint32_t*)addr)[1] == 0 && (cast(uint32_t*)addr)[2] == 0 && (cast(uint32_t*)addr)[3] == 0;
}

    extern (D) int IN6_IS_ADDR_LOOPBACK(in6_addr* addr)
{
return (cast(uint32_t*)addr)[0] == 0 && (cast(uint32_t*)addr)[1] == 0 && (cast(uint32_t*)addr)[2] == 0 && (cast(uint32_t*)addr)[3] == htonl(1);
}

    extern (D) int IN6_IS_ADDR_MULTICAST(in6_addr* addr)
{
return (cast(uint8_t*)addr)[0] == 255;
}

    extern (D) int IN6_IS_ADDR_LINKLOCAL(in6_addr* addr)
{
return ((cast(uint32_t*)addr)[0] & htonl(-4194304u)) == htonl(-25165824u);
}

    extern (D) int IN6_IS_ADDR_SITELOCAL(in6_addr* addr)
{
return ((cast(uint32_t*)addr)[0] & htonl(-4194304u)) == htonl(-20971520u);
}

    extern (D) int IN6_IS_ADDR_V4MAPPED(in6_addr* addr)
{
return (cast(uint32_t*)addr)[0] == 0 && (cast(uint32_t*)addr)[1] == 0 && (cast(uint32_t*)addr)[2] == htonl(65535);
}

    extern (D) int IN6_IS_ADDR_V4COMPAT(in6_addr* addr)
{
return (cast(uint32_t*)addr)[0] == 0 && (cast(uint32_t*)addr)[1] == 0 && (cast(uint32_t*)addr)[2] == 0 && ntohl((cast(uint32_t*)addr)[3]) > 1;
}

    extern (D) int IN6_IS_ADDR_MC_NODELOCAL(in6_addr* addr)
{
return IN6_IS_ADDR_MULTICAST(addr) && ((cast(uint8_t*)addr)[1] & 15) == 1;
}

    extern (D) int IN6_IS_ADDR_MC_LINKLOCAL(in6_addr* addr)
{
return IN6_IS_ADDR_MULTICAST(addr) && ((cast(uint8_t*)addr)[1] & 15) == 2;
}

    extern (D) int IN6_IS_ADDR_MC_SITELOCAL(in6_addr* addr)
{
return IN6_IS_ADDR_MULTICAST(addr) && ((cast(uint8_t*)addr)[1] & 15) == 5;
}

    extern (D) int IN6_IS_ADDR_MC_ORGLOCAL(in6_addr* addr)
{
return IN6_IS_ADDR_MULTICAST(addr) && ((cast(uint8_t*)addr)[1] & 15) == 8;
}

    extern (D) int IN6_IS_ADDR_MC_GLOBAL(in6_addr* addr)
{
return IN6_IS_ADDR_MULTICAST(addr) && ((cast(uint8_t*)addr)[1] & 15) == 14;
}

}
else
{
    version (OSX)
{
    struct in6_addr
{
    union
{
uint8_t[16] s6_addr;
uint16_t[8] s6_addr16;
uint32_t[4] s6_addr32;
}
}
    struct sockaddr_in6
{
    uint8_t sin6_len;
    sa_family_t sin6_family;
    in_port_t sin6_port;
    uint32_t sin6_flowinfo;
    in6_addr sin6_addr;
    uint32_t sin6_scope_id;
}
    extern immutable __gshared in6_addr in6addr_any;

    extern immutable __gshared in6_addr in6addr_loopback;

    struct ipv6_mreq
{
    in6_addr ipv6mr_multiaddr;
    uint ipv6mr_interface;
}
    enum : uint
{
IPPROTO_IPV6 = 41,
INET6_ADDRSTRLEN = 46,
IPV6_JOIN_GROUP = 12,
IPV6_LEAVE_GROUP = 13,
IPV6_MULTICAST_HOPS = 10,
IPV6_MULTICAST_IF = 9,
IPV6_MULTICAST_LOOP = 11,
IPV6_UNICAST_HOPS = 4,
IPV6_V6ONLY = 27,
}
    extern (D) int IN6_IS_ADDR_UNSPECIFIED(in6_addr* addr)
{
return (cast(uint32_t*)addr)[0] == 0 && (cast(uint32_t*)addr)[1] == 0 && (cast(uint32_t*)addr)[2] == 0 && (cast(uint32_t*)addr)[3] == 0;
}

    extern (D) int IN6_IS_ADDR_LOOPBACK(in6_addr* addr)
{
return (cast(uint32_t*)addr)[0] == 0 && (cast(uint32_t*)addr)[1] == 0 && (cast(uint32_t*)addr)[2] == 0 && (cast(uint32_t*)addr)[3] == ntohl(1);
}

    extern (D) int IN6_IS_ADDR_MULTICAST(in6_addr* addr)
{
return addr.s6_addr[0] == 255;
}

    extern (D) int IN6_IS_ADDR_LINKLOCAL(in6_addr* addr)
{
return addr.s6_addr[0] == 254 && (addr.s6_addr[1] & 192) == 128;
}

    extern (D) int IN6_IS_ADDR_SITELOCAL(in6_addr* addr)
{
return addr.s6_addr[0] == 254 && (addr.s6_addr[1] & 192) == 192;
}

    extern (D) int IN6_IS_ADDR_V4MAPPED(in6_addr* addr)
{
return (cast(uint32_t*)addr)[0] == 0 && (cast(uint32_t*)addr)[1] == 0 && (cast(uint32_t*)addr)[2] == ntohl(65535);
}

    extern (D) int IN6_IS_ADDR_V4COMPAT(in6_addr* addr)
{
return (cast(uint32_t*)addr)[0] == 0 && (cast(uint32_t*)addr)[1] == 0 && (cast(uint32_t*)addr)[2] == 0 && (cast(uint32_t*)addr)[3] != 0 && (cast(uint32_t*)addr)[3] != ntohl(1);
}

    extern (D) int IN6_IS_ADDR_MC_NODELOCAL(in6_addr* addr)
{
return IN6_IS_ADDR_MULTICAST(addr) && ((cast(uint8_t*)addr)[1] & 15) == 1;
}

    extern (D) int IN6_IS_ADDR_MC_LINKLOCAL(in6_addr* addr)
{
return IN6_IS_ADDR_MULTICAST(addr) && ((cast(uint8_t*)addr)[1] & 15) == 2;
}

    extern (D) int IN6_IS_ADDR_MC_SITELOCAL(in6_addr* addr)
{
return IN6_IS_ADDR_MULTICAST(addr) && ((cast(uint8_t*)addr)[1] & 15) == 5;
}

    extern (D) int IN6_IS_ADDR_MC_ORGLOCAL(in6_addr* addr)
{
return IN6_IS_ADDR_MULTICAST(addr) && ((cast(uint8_t*)addr)[1] & 15) == 8;
}

    extern (D) int IN6_IS_ADDR_MC_GLOBAL(in6_addr* addr)
{
return IN6_IS_ADDR_MULTICAST(addr) && ((cast(uint8_t*)addr)[1] & 15) == 14;
}

}
else
{
    version (FreeBSD)
{
    struct in6_addr
{
    union
{
uint8_t[16] s6_addr;
uint16_t[8] s6_addr16;
uint32_t[4] s6_addr32;
}
}
    struct sockaddr_in6
{
    uint8_t sin6_len;
    sa_family_t sin6_family;
    in_port_t sin6_port;
    uint32_t sin6_flowinfo;
    in6_addr sin6_addr;
    uint32_t sin6_scope_id;
}
    extern immutable __gshared in6_addr in6addr_any;

    extern immutable __gshared in6_addr in6addr_loopback;

    struct ipv6_mreq
{
    in6_addr ipv6mr_multiaddr;
    uint ipv6mr_interface;
}
    enum INET6_ADDRSTRLEN = 46;
    enum IPPROTO_IPV6 = 41;
    enum 
{
IPV6_SOCKOPT_RESERVED1 = 3,
IPV6_UNICAST_HOPS = 4,
IPV6_MULTICAST_IF = 9,
IPV6_MULTICAST_HOPS = 10,
IPV6_MULTICAST_LOOP = 11,
IPV6_JOIN_GROUP = 12,
IPV6_LEAVE_GROUP = 13,
IPV6_PORTRANGE = 14,
ICMP6_FILTER = 18,
IPV6_CHECKSUM = 26,
IPV6_V6ONLY = 27,
}
    private enum 
{
__IPV6_ADDR_SCOPE_NODELOCAL = 1,
__IPV6_ADDR_SCOPE_INTFACELOCAL = 1,
__IPV6_ADDR_SCOPE_LINKLOCAL = 2,
__IPV6_ADDR_SCOPE_SITELOCAL = 5,
__IPV6_ADDR_SCOPE_ORGLOCAL = 8,
__IPV6_ADDR_SCOPE_GLOBAL = 14,
}

    extern (D) int IN6_IS_ADDR_UNSPECIFIED(in in6_addr* a)
{
return *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[0] == 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[4] == 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[8] == 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[12] == 0;
}

    extern (D) int IN6_IS_ADDR_LOOPBACK(in in6_addr* a)
{
return *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[0] == 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[4] == 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[8] == 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[12] == ntohl(1);
}

    extern (D) int IN6_IS_ADDR_V4COMPAT(in in6_addr* a)
{
return *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[0] == 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[4] == 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[8] == 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[12] != 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[12] != ntohl(1);
}

    extern (D) int IN6_IS_ADDR_V4MAPPED(in in6_addr* a)
{
return *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[0] == 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[4] == 0 && *cast(const(uint32_t*))cast(const(void*))&a.s6_addr[8] == ntohl(65535);
}

    extern (D) int IN6_IS_ADDR_LINKLOCAL(in in6_addr* a)
{
return a.s6_addr[0] == 254 && (a.s6_addr[1] & 192) == 128;
}

    extern (D) int IN6_IS_ADDR_SITELOCAL(in in6_addr* a)
{
return a.s6_addr[0] == 254 && (a.s6_addr[1] & 192) == 192;
}

    extern (D) int IN6_IS_ADDR_MULTICAST(in in6_addr* a)
{
return a.s6_addr[0] == 255;
}

    extern (D) uint8_t __IPV6_ADDR_MC_SCOPE(in in6_addr* a)
{
return a.s6_addr[1] & 15;
}

    extern (D) int IN6_IS_ADDR_MC_NODELOCAL(in in6_addr* a)
{
return IN6_IS_ADDR_MULTICAST(a) && __IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_NODELOCAL;
}

    extern (D) int IN6_IS_ADDR_MC_LINKLOCAL(in in6_addr* a)
{
return IN6_IS_ADDR_MULTICAST(a) && __IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_LINKLOCAL;
}

    extern (D) int IN6_IS_ADDR_MC_SITELOCAL(in in6_addr* a)
{
return IN6_IS_ADDR_MULTICAST(a) && __IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_SITELOCAL;
}

    extern (D) int IN6_IS_ADDR_MC_ORGLOCAL(in in6_addr* a)
{
return IN6_IS_ADDR_MULTICAST(a) && __IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_ORGLOCAL;
}

    extern (D) int IN6_IS_ADDR_MC_GLOBAL(in in6_addr* a)
{
return IN6_IS_ADDR_MULTICAST(a) && __IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_GLOBAL;
}

}
}
}
    version (linux)
{
    enum uint IPPROTO_RAW = 255;
}
else
{
    version (OSX)
{
    enum uint IPPROTO_RAW = 255;
}
else
{
    version (FreeBSD)
{
    enum uint IPPROTO_RAW = 255;
}
}
}
}
