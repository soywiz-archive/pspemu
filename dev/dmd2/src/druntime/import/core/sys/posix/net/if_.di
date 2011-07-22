// D import file generated from 'src\core\sys\posix\net\if_.d'
module core.sys.posix.net.if_;
private import core.sys.posix.config;

extern (C) version (linux)
{
    struct if_nameindex_t
{
    uint if_index;
    char* if_name;
}
    enum IF_NAMESIZE = 16;
    uint if_nametoindex(in char*);
    char* if_indextoname(uint, char*);
    if_nameindex_t* if_nameindex();
    void if_freenameindex(if_nameindex_t*);
}
else
{
    version (OSX)
{
    struct if_nameindex_t
{
    uint if_index;
    char* if_name;
}
    enum IF_NAMESIZE = 16;
    uint if_nametoindex(in char*);
    char* if_indextoname(uint, char*);
    if_nameindex_t* if_nameindex();
    void if_freenameindex(if_nameindex_t*);
}
else
{
    version (FreeBSD)
{
    struct if_nameindex_t
{
    uint if_index;
    char* if_name;
}
    enum IF_NAMESIZE = 16;
    uint if_nametoindex(in char*);
    char* if_indextoname(uint, char*);
    if_nameindex_t* if_nameindex();
    void if_freenameindex(if_nameindex_t*);
}
}
}

