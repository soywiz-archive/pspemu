// D import file generated from 'src\core\sys\posix\sys\time.d'
module core.sys.posix.sys.time;
private import core.sys.posix.config;

public import core.sys.posix.sys.types;

public import core.sys.posix.sys.select;

extern (C) version (linux)
{
    struct timeval
{
    time_t tv_sec;
    suseconds_t tv_usec;
}
    struct itimerval
{
    timeval it_interval;
    timeval it_value;
}
    enum ITIMER_REAL = 0;
    enum ITIMER_VIRTUAL = 1;
    enum ITIMER_PROF = 2;
    int getitimer(int, itimerval*);
    int gettimeofday(timeval*, void*);
    int setitimer(int, in itimerval*, itimerval*);
    int utimes(in char*, ref const(timeval)[2]);
}
else
{
    version (OSX)
{
    struct timeval
{
    time_t tv_sec;
    suseconds_t tv_usec;
}
    struct itimerval
{
    timeval it_interval;
    timeval it_value;
}
    struct timezone_t
{
    int tz_minuteswest;
    int tz_dsttime;
}
    int getitimer(int, itimerval*);
    int gettimeofday(timeval*, timezone_t*);
    int setitimer(int, in itimerval*, itimerval*);
    int utimes(in char*, ref const(timeval)[2]);
}
else
{
    version (FreeBSD)
{
    struct timeval
{
    time_t tv_sec;
    suseconds_t tv_usec;
}
    struct itimerval
{
    timeval it_interval;
    timeval it_value;
}
    struct timezone_t
{
    int tz_minuteswest;
    int tz_dsttime;
}
    int getitimer(int, itimerval*);
    int gettimeofday(timeval*, timezone_t*);
    int setitimer(int, in itimerval*, itimerval*);
    int utimes(in char*, ref const(timeval)[2]);
}
}
}

