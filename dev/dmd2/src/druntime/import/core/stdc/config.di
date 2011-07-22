// D import file generated from 'src\core\stdc\config.d'
module core.stdc.config;
extern (C) version (Windows)
{
    alias int c_long;
    alias uint c_ulong;
}
else
{
    static if((void*).sizeof > (int).sizeof)
{
    alias long c_long;
    alias ulong c_ulong;
}
else
{
    alias int c_long;
    alias uint c_ulong;
}
}

