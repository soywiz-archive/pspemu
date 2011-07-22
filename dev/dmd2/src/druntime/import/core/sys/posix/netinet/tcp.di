// D import file generated from 'src\core\sys\posix\netinet\tcp.d'
module core.sys.posix.netinet.tcp;
private import core.sys.posix.config;

extern (C) version (linux)
{
    enum TCP_NODELAY = 1;
}
else
{
    version (OSX)
{
    enum TCP_NODELAY = 1;
}
else
{
    version (FreeBSD)
{
    enum TCP_NODELAY = 1;
}
}
}

