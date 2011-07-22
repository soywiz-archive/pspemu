// D import file generated from 'src\core\sys\posix\netdb.d'
module core.sys.posix.netdb;
private import core.sys.posix.config;

public import core.stdc.inttypes;

public import core.sys.posix.netinet.in_;

public import core.sys.posix.sys.types;

public import core.sys.posix.sys.socket;

extern (C) 
{
    version (linux)
{
    struct hostent
{
    char* h_name;
    char** h_aliases;
    int h_addrtype;
    int h_length;
    char** h_addr_list;
    char* h_addr()
{
return h_addr_list[0];
}
}
    struct netent
{
    char* n_name;
    char** n_aliase;
    int n_addrtype;
    uint32_t n_net;
}
    struct protoent
{
    char* p_name;
    char** p_aliases;
    int p_proto;
}
    struct servent
{
    char* s_name;
    char** s_aliases;
    int s_port;
    char* s_proto;
}
    enum IPPORT_RESERVED = 1024;
    enum HOST_NOT_FOUND = 1;
    enum NO_DATA = 4;
    enum NO_RECOVERY = 3;
    enum TRY_AGAIN = 2;
    struct addrinfo
{
    int ai_flags;
    int ai_family;
    int ai_socktype;
    int ai_protocol;
    socklen_t ai_addrlen;
    sockaddr* ai_addr;
    char* ai_canonname;
    addrinfo* ai_next;
}
    enum AI_PASSIVE = 1;
    enum AI_CANONNAME = 2;
    enum AI_NUMERICHOST = 4;
    enum AI_NUMERICSERV = 1024;
    enum AI_V4MAPPED = 8;
    enum AI_ALL = 16;
    enum AI_ADDRCONFIG = 32;
    enum NI_NOFQDN = 4;
    enum NI_NUMERICHOST = 1;
    enum NI_NAMEREQD = 8;
    enum NI_NUMERICSERV = 2;
    enum NI_DGRAM = 16;
    enum NI_MAXHOST = 1025;
    enum NI_MAXSERV = 32;
    enum EAI_AGAIN = -3;
    enum EAI_BADFLAGS = -1;
    enum EAI_FAIL = -4;
    enum EAI_FAMILY = -6;
    enum EAI_MEMORY = -10;
    enum EAI_NONAME = -2;
    enum EAI_SERVICE = -8;
    enum EAI_SOCKTYPE = -7;
    enum EAI_SYSTEM = -11;
    enum EAI_OVERFLOW = -12;
}
else
{
    version (OSX)
{
    struct hostent
{
    char* h_name;
    char** h_aliases;
    int h_addrtype;
    int h_length;
    char** h_addr_list;
    char* h_addr()
{
return h_addr_list[0];
}
}
    struct netent
{
    char* n_name;
    char** n_aliase;
    int n_addrtype;
    uint32_t n_net;
}
    struct protoent
{
    char* p_name;
    char** p_aliases;
    int p_proto;
}
    struct servent
{
    char* s_name;
    char** s_aliases;
    int s_port;
    char* s_proto;
}
    enum IPPORT_RESERVED = 1024;
    enum HOST_NOT_FOUND = 1;
    enum NO_DATA = 4;
    enum NO_RECOVERY = 3;
    enum TRY_AGAIN = 2;
    struct addrinfo
{
    int ai_flags;
    int ai_family;
    int ai_socktype;
    int ai_protocol;
    socklen_t ai_addrlen;
    char* ai_canonname;
    sockaddr* ai_addr;
    addrinfo* ai_next;
}
    enum AI_PASSIVE = 1;
    enum AI_CANONNAME = 2;
    enum AI_NUMERICHOST = 4;
    enum AI_NUMERICSERV = 4096;
    enum AI_V4MAPPED = 2048;
    enum AI_ALL = 256;
    enum AI_ADDRCONFIG = 1024;
    enum NI_NOFQDN = 1;
    enum NI_NUMERICHOST = 2;
    enum NI_NAMEREQD = 4;
    enum NI_NUMERICSERV = 8;
    enum NI_DGRAM = 16;
    enum NI_MAXHOST = 1025;
    enum NI_MAXSERV = 32;
    enum EAI_AGAIN = 2;
    enum EAI_BADFLAGS = 3;
    enum EAI_FAIL = 4;
    enum EAI_FAMILY = 5;
    enum EAI_MEMORY = 6;
    enum EAI_NONAME = 8;
    enum EAI_SERVICE = 9;
    enum EAI_SOCKTYPE = 10;
    enum EAI_SYSTEM = 11;
    enum EAI_OVERFLOW = 14;
}
else
{
    version (FreeBSD)
{
    struct hostent
{
    char* h_name;
    char** h_aliases;
    int h_addrtype;
    int h_length;
    char** h_addr_list;
    char* h_addr()
{
return h_addr_list[0];
}
}
    struct netent
{
    char* n_name;
    char** n_aliase;
    int n_addrtype;
    uint32_t n_net;
}
    struct protoent
{
    char* p_name;
    char** p_aliases;
    int p_proto;
}
    struct servent
{
    char* s_name;
    char** s_aliases;
    int s_port;
    char* s_proto;
}
    enum IPPORT_RESERVED = 1024;
    enum HOST_NOT_FOUND = 1;
    enum NO_DATA = 4;
    enum NO_RECOVERY = 3;
    enum TRY_AGAIN = 2;
    struct addrinfo
{
    int ai_flags;
    int ai_family;
    int ai_socktype;
    int ai_protocol;
    socklen_t ai_addrlen;
    char* ai_canonname;
    sockaddr* ai_addr;
    addrinfo* ai_next;
}
    enum AI_PASSIVE = 1;
    enum AI_CANONNAME = 2;
    enum AI_NUMERICHOST = 4;
    enum AI_NUMERICSERV = 8;
    enum AI_V4MAPPED = 2048;
    enum AI_ALL = 256;
    enum AI_ADDRCONFIG = 1024;
    enum NI_NOFQDN = 1;
    enum NI_NUMERICHOST = 2;
    enum NI_NAMEREQD = 4;
    enum NI_NUMERICSERV = 8;
    enum NI_DGRAM = 16;
    enum NI_MAXHOST = 1025;
    enum NI_MAXSERV = 32;
    enum EAI_AGAIN = 2;
    enum EAI_BADFLAGS = 3;
    enum EAI_FAIL = 4;
    enum EAI_FAMILY = 5;
    enum EAI_MEMORY = 6;
    enum EAI_NONAME = 8;
    enum EAI_SERVICE = 9;
    enum EAI_SOCKTYPE = 10;
    enum EAI_SYSTEM = 11;
    enum EAI_OVERFLOW = 14;
}
}
}
    version (Posix)
{
    void endhostent();
    void endnetent();
    void endprotoent();
    void endservent();
    void freeaddrinfo(addrinfo*);
    const(char)* gai_strerror(int);
    int getaddrinfo(const(char)*, const(char)*, const(addrinfo)*, addrinfo**);
    hostent* gethostbyaddr(const(void)*, socklen_t, int);
    hostent* gethostbyname(const(char)*);
    hostent* gethostent();
    int getnameinfo(const(sockaddr)*, socklen_t, char*, socklen_t, char*, socklen_t, int);
    netent* getnetbyaddr(uint32_t, int);
    netent* getnetbyname(const(char)*);
    netent* getnetent();
    protoent* getprotobyname(const(char)*);
    protoent* getprotobynumber(int);
    protoent* getprotoent();
    servent* getservbyname(const(char)*, const(char)*);
    servent* getservbyport(int, const(char)*);
    servent* getservent();
    void sethostent(int);
    void setnetent(int);
    void setprotoent(int);
    void setservent(int);
}
}
