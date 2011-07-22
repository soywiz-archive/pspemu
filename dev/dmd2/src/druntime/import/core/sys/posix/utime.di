// D import file generated from 'src\core\sys\posix\utime.d'
module core.sys.posix.utime;
private import core.sys.posix.config;

public import core.sys.posix.sys.types;

extern (C) version (linux)
{
    struct utimbuf
{
    time_t actime;
    time_t modtime;
}
    int utime(in char*, in utimbuf*);
}
else
{
    version (OSX)
{
    struct utimbuf
{
    time_t actime;
    time_t modtime;
}
    int utime(in char*, in utimbuf*);
}
else
{
    version (FreeBSD)
{
    struct utimbuf
{
    time_t actime;
    time_t modtime;
}
    int utime(in char*, in utimbuf*);
}
}
}

