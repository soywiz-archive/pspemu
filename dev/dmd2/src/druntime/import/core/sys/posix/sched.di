// D import file generated from 'src\core\sys\posix\sched.d'
module core.sys.posix.sched;
private import core.sys.posix.config;

public import core.sys.posix.time;

public import core.sys.posix.sys.types;

extern (C) 
{
    version (linux)
{
    struct sched_param
{
    int sched_priority;
}
    enum SCHED_OTHER = 0;
    enum SCHED_FIFO = 1;
    enum SCHED_RR = 2;
}
else
{
    version (OSX)
{
    enum SCHED_OTHER = 1;
    enum SCHED_FIFO = 4;
    enum SCHED_RR = 2;
    private enum __SCHED_PARAM_SIZE__ = 4;

    struct sched_param
{
    int sched_priority;
    byte[__PTHREAD_MUTEX_SIZE__] __opaque;
}
}
else
{
    version (FreeBSD)
{
    struct sched_param
{
    int sched_priority;
}
    enum SCHED_FIFO = 1;
    enum SCHED_OTHER = 2;
    enum SCHED_RR = 3;
}
}
}
    version (Posix)
{
    int sched_getparam(pid_t, sched_param*);
    int sched_getscheduler(pid_t);
    int sched_setparam(pid_t, in sched_param*);
    int sched_setscheduler(pid_t, int, in sched_param*);
}
    version (linux)
{
    int sched_yield();
}
else
{
    version (OSX)
{
    int sched_yield();
}
else
{
    version (FreeBSD)
{
    int sched_yield();
}
}
}
    version (linux)
{
    int sched_get_priority_max(int);
    int sched_get_priority_min(int);
    int sched_rr_get_interval(pid_t, timespec*);
}
else
{
    version (OSX)
{
    int sched_get_priority_min(int);
    int sched_get_priority_max(int);
}
else
{
    version (FreeBSD)
{
    int sched_get_priority_min(int);
    int sched_get_priority_max(int);
    int sched_rr_get_interval(pid_t, timespec*);
}
}
}
}
