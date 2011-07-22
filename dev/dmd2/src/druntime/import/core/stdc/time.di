// D import file generated from 'src\core\stdc\time.d'
module core.stdc.time;
private import core.stdc.config;

private import core.stdc.stddef;

extern (C) nothrow 
{
    version (Windows)
{
    struct tm
{
    int tm_sec;
    int tm_min;
    int tm_hour;
    int tm_mday;
    int tm_mon;
    int tm_year;
    int tm_wday;
    int tm_yday;
    int tm_isdst;
}
}
else
{
    struct tm
{
    int tm_sec;
    int tm_min;
    int tm_hour;
    int tm_mday;
    int tm_mon;
    int tm_year;
    int tm_wday;
    int tm_yday;
    int tm_isdst;
    c_long tm_gmtoff;
    char* tm_zone;
}
}
    alias c_long time_t;
    alias c_long clock_t;
    version (Windows)
{
    enum clock_t CLOCKS_PER_SEC = 1000;
}
else
{
    version (OSX)
{
    enum clock_t CLOCKS_PER_SEC = 100;
}
else
{
    version (FreeBSD)
{
    enum clock_t CLOCKS_PER_SEC = 128;
}
else
{
    version (linux)
{
    enum clock_t CLOCKS_PER_SEC = 1000000;
}
}
}
}
    clock_t clock();
    double difftime(time_t time1, time_t time0);
    time_t mktime(tm* timeptr);
    time_t time(time_t* timer);
    char* asctime(in tm* timeptr);
    char* ctime(in time_t* timer);
    tm* gmtime(in time_t* timer);
    tm* localtime(in time_t* timer);
    size_t strftime(char* s, size_t maxsize, in char* format, in tm* timeptr);
    version (Windows)
{
    void tzset();
    void _tzset();
    char* _strdate(char* s);
    char* _strtime(char* s);
    extern __gshared const(char)*[2] tzname;

}
else
{
    version (OSX)
{
    void tzset();
    extern __gshared const(char)*[2] tzname;

}
else
{
    version (linux)
{
    void tzset();
    extern __gshared const(char)*[2] tzname;

}
else
{
    version (FreeBSD)
{
    void tzset();
    extern __gshared const(char)*[2] tzname;

}
}
}
}
}

