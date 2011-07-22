// D import file generated from 'src\core\sys\posix\inttypes.d'
module core.sys.posix.inttypes;
private import core.sys.posix.config;

public import core.stdc.inttypes;

version (Posix)
{
    intmax_t imaxabs(intmax_t);
    imaxdiv_t imaxdiv(intmax_t, intmax_t);
    intmax_t strtoimax(in char*, char**, int);
    uintmax_t strtoumax(in char*, char**, int);
    intmax_t wcstoimax(in wchar_t*, wchar_t**, int);
    uintmax_t wcstoumax(in wchar_t*, wchar_t**, int);
}
