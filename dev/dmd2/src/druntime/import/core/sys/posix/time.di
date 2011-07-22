// D import file generated from 'src\core\sys\posix\time.d'
module core.sys.posix.time;
private import core.sys.posix.config;

public import core.stdc.time;

public import core.sys.posix.sys.types;

public import core.sys.posix.signal;

extern (C) 
{
    version (linux)
{
    time_t timegm(tm*);
}
else
{
    version (OSX)
{
    time_t timegm(tm*);
}
else
{
    version (FreeBSD)
{
    time_t timegm(tm*);
}
}
}
    version (linux)
{
    enum CLOCK_MONOTONIC = 1;
    enum CLOCK_MONOTONIC_RAW = 4;
    enum CLOCK_MONOTONIC_COARSE = 6;
}
else
{
    version (FreeBSD)
{
    enum CLOCK_MONOTONIC = 4;
    enum CLOCK_MONOTONIC_PRECISE = 11;
    enum CLOCK_MONOTONIC_FAST = 12;
}
else
{
    version (OSX)
{
}
else
{
    version (Windows)
{
    pragma (msg, "no Windows support for CLOCK_MONOTONIC");
}
else
{
    static assert(0);
}
}
}
}
    version (linux)
{
    enum CLOCK_PROCESS_CPUTIME_ID = 2;
    enum CLOCK_THREAD_CPUTIME_ID = 3;
    struct itimerspec
{
    timespec it_interval;
    timespec it_value;
}
    enum CLOCK_REALTIME = 0;
    enum CLOCK_REALTIME_COARSE = 5;
    enum TIMER_ABSTIME = 1;
    alias int clockid_t;
    alias int timer_t;
    int clock_getres(clockid_t, timespec*);
    int clock_gettime(clockid_t, timespec*);
    int clock_settime(clockid_t, in timespec*);
    int nanosleep(in timespec*, timespec*);
    int timer_create(clockid_t, sigevent*, timer_t*);
    int timer_delete(timer_t);
    int timer_gettime(timer_t, itimerspec*);
    int timer_getoverrun(timer_t);
    int timer_settime(timer_t, int, in itimerspec*, itimerspec*);
}
else
{
    version (OSX)
{
    int nanosleep(in timespec*, timespec*);
}
else
{
    version (FreeBSD)
{
    enum CLOCK_THREAD_CPUTIME_ID = 15;
    struct itimerspec
{
    timespec it_interval;
    timespec it_value;
}
    enum CLOCK_REALTIME = 0;
    enum TIMER_ABSTIME = 1;
    alias int clockid_t;
    alias int timer_t;
    int clock_getres(clockid_t, timespec*);
    int clock_gettime(clockid_t, timespec*);
    int clock_settime(clockid_t, in timespec*);
    int nanosleep(in timespec*, timespec*);
    int timer_create(clockid_t, sigevent*, timer_t*);
    int timer_delete(timer_t);
    int timer_gettime(timer_t, itimerspec*);
    int timer_getoverrun(timer_t);
    int timer_settime(timer_t, int, in itimerspec*, itimerspec*);
}
}
}
    version (linux)
{
    char* asctime_r(in tm*, char*);
    char* ctime_r(in time_t*, char*);
    tm* gmtime_r(in time_t*, tm*);
    tm* localtime_r(in time_t*, tm*);
}
else
{
    version (OSX)
{
    char* asctime_r(in tm*, char*);
    char* ctime_r(in time_t*, char*);
    tm* gmtime_r(in time_t*, tm*);
    tm* localtime_r(in time_t*, tm*);
}
else
{
    version (FreeBSD)
{
    char* asctime_r(in tm*, char*);
    char* ctime_r(in time_t*, char*);
    tm* gmtime_r(in time_t*, tm*);
    tm* localtime_r(in time_t*, tm*);
}
}
}
    version (linux)
{
    extern __gshared int daylight;

    extern __gshared c_long timezone;

    tm* getdate(in char*);
    char* strptime(in char*, in char*, tm*);
}
else
{
    version (OSX)
{
    extern __gshared c_long timezone;

    extern __gshared int daylight;

    tm* getdate(in char*);
    char* strptime(in char*, in char*, tm*);
}
else
{
    version (FreeBSD)
{
    char* strptime(in char*, in char*, tm*);
}
else
{
    version (Solaris)
{
    extern __gshared c_long timezone;

    char* strptime(in char*, in char*, tm*);
}
}
}
}
}
