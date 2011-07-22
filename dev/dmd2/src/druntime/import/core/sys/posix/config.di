// D import file generated from 'src\core\sys\posix\config.d'
module core.sys.posix.config;
public import core.stdc.config;

extern (C) version (linux)
{
    enum bool __USE_LARGEFILE64 = true;
    enum bool __USE_FILE_OFFSET64 = __USE_LARGEFILE64;
    enum bool __REDIRECT = false;
}

