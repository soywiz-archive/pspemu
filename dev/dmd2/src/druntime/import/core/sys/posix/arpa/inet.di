// D import file generated from 'src\core\sys\posix\arpa\inet.d'
module core.sys.posix.arpa.inet;
private import core.sys.posix.config;

public import core.stdc.inttypes;

public import core.sys.posix.sys.socket;

extern (C) 
{
    version (linux)
{
    alias uint16_t in_port_t;
    alias uint32_t in_addr_t;
    struct in_addr
{
    in_addr_t s_addr;
}
    enum INET_ADDRSTRLEN = 16;
    uint32_t htonl(uint32_t);
    uint16_t htons(uint16_t);
    uint32_t ntohl(uint32_t);
    uint16_t ntohs(uint16_t);
    in_addr_t inet_addr(in char*);
    char* inet_ntoa(in_addr);
    char* inet_ntop(int, in void*, char*, socklen_t);
    int inet_pton(int, in char*, void*);
}
else
{
    version (OSX)
{
    alias uint16_t in_port_t;
    alias uint32_t in_addr_t;
    struct in_addr
{
    in_addr_t s_addr;
}
    enum INET_ADDRSTRLEN = 16;
    uint32_t htonl(uint32_t);
    uint16_t htons(uint16_t);
    uint32_t ntohl(uint32_t);
    uint16_t ntohs(uint16_t);
    in_addr_t inet_addr(in char*);
    char* inet_ntoa(in_addr);
    char* inet_ntop(int, in void*, char*, socklen_t);
    int inet_pton(int, in char*, void*);
}
else
{
    version (FreeBSD)
{
    alias uint16_t in_port_t;
    alias uint32_t in_addr_t;
    struct in_addr
{
    in_addr_t s_addr;
}
    enum INET_ADDRSTRLEN = 16;
    uint32_t htonl(uint32_t);
    uint16_t htons(uint16_t);
    uint32_t ntohl(uint32_t);
    uint16_t ntohs(uint16_t);
    in_addr_t inet_addr(in char*);
    char* inet_ntoa(in_addr);
    const(char)* inet_ntop(int, in void*, char*, socklen_t);
    int inet_pton(int, in char*, void*);
}
}
}
    version (linux)
{
    enum INET6_ADDRSTRLEN = 46;
}
else
{
    version (OSX)
{
    enum INET6_ADDRSTRLEN = 46;
}
else
{
    version (FreeBSD)
{
    enum INET6_ADDRSTRLEN = 46;
}
}
}
}
