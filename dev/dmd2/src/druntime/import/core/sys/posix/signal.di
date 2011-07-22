// D import file generated from 'src\core\sys\posix\signal.d'
module core.sys.posix.signal;
private import core.sys.posix.config;

public import core.stdc.signal;

public import core.stdc.stddef;

public import core.sys.posix.sys.types;

extern (C) 
{
    version (Posix)
{
    private alias void function(int) sigfn_t;

    private alias void function(int, siginfo_t*, void*) sigactfn_t;

    enum 
{
SIGEV_SIGNAL,
SIGEV_NONE,
SIGEV_THREAD,
}
    union sigval
{
    int sival_int;
    void* sival_ptr;
}
    private extern (C) int __libc_current_sigrtmin();


    private extern (C) int __libc_current_sigrtmax();


    alias __libc_current_sigrtmin SIGRTMIN;
    alias __libc_current_sigrtmax SIGRTMAX;
}
    version (linux)
{
    enum SIGALRM = 14;
    enum SIGBUS = 7;
    enum SIGCHLD = 17;
    enum SIGCONT = 18;
    enum SIGHUP = 1;
    enum SIGKILL = 9;
    enum SIGPIPE = 13;
    enum SIGQUIT = 3;
    enum SIGSTOP = 19;
    enum SIGTSTP = 20;
    enum SIGTTIN = 21;
    enum SIGTTOU = 22;
    enum SIGUSR1 = 10;
    enum SIGUSR2 = 12;
    enum SIGURG = 23;
}
else
{
    version (OSX)
{
    enum SIGALRM = 14;
    enum SIGBUS = 10;
    enum SIGCHLD = 20;
    enum SIGCONT = 19;
    enum SIGHUP = 1;
    enum SIGKILL = 9;
    enum SIGPIPE = 13;
    enum SIGQUIT = 3;
    enum SIGSTOP = 17;
    enum SIGTSTP = 18;
    enum SIGTTIN = 21;
    enum SIGTTOU = 22;
    enum SIGUSR1 = 30;
    enum SIGUSR2 = 31;
    enum SIGURG = 16;
}
else
{
    version (FreeBSD)
{
    enum SIGALRM = 14;
    enum SIGBUS = 10;
    enum SIGCHLD = 20;
    enum SIGCONT = 19;
    enum SIGHUP = 1;
    enum SIGKILL = 9;
    enum SIGPIPE = 13;
    enum SIGQUIT = 3;
    enum SIGSTOP = 17;
    enum SIGTSTP = 18;
    enum SIGTTIN = 21;
    enum SIGTTOU = 22;
    enum SIGUSR1 = 30;
    enum SIGUSR2 = 31;
    enum SIGURG = 16;
}
}
}
    version (FreeBSD)
{
    struct sigaction_t
{
    union
{
sigfn_t sa_handler;
sigactfn_t sa_sigaction;
}
    int sa_flags;
    sigset_t sa_mask;
}
}
else
{
    version (Posix)
{
    struct sigaction_t
{
    static if(true)
{
    union
{
sigfn_t sa_handler;
sigactfn_t sa_sigaction;
}
}
else
{
    sigfn_t sa_handler;
}
    sigset_t sa_mask;
    int sa_flags;
    version (OSX)
{
}
else
{
    void function() sa_restorer;
}
}
}
}
    version (linux)
{
    enum SIG_HOLD = cast(sigfn_t)1;
    private enum _SIGSET_NWORDS = 1024 / (8 * c_ulong.sizeof);

    struct sigset_t
{
    c_ulong[_SIGSET_NWORDS] __val;
}
    enum SA_NOCLDSTOP = 1;
    enum SIG_BLOCK = 0;
    enum SIG_UNBLOCK = 1;
    enum SIG_SETMASK = 2;
    private enum __SI_MAX_SIZE = 128;

    static if(false)
{
    private enum __SI_PAD_SIZE = __SI_MAX_SIZE / (int).sizeof - 4;

}
else
{
    private enum __SI_PAD_SIZE = __SI_MAX_SIZE / (int).sizeof - 3;

}
    struct siginfo_t
{
    int si_signo;
    int si_errno;
    int si_code;
    union _sifields_t
{
    int[__SI_PAD_SIZE] _pad;
    struct _kill_t
{
    pid_t si_pid;
    uid_t si_uid;
}
    _kill_t _kill;
    struct _timer_t
{
    int si_tid;
    int si_overrun;
    sigval si_sigval;
}
    _timer_t _timer;
    struct _rt_t
{
    pid_t si_pid;
    uid_t si_uid;
    sigval si_sigval;
}
    _rt_t _rt;
    struct _sigchild_t
{
    pid_t si_pid;
    uid_t si_uid;
    int si_status;
    clock_t si_utime;
    clock_t si_stime;
}
    _sigchild_t _sigchld;
    struct _sigfault_t
{
    void* si_addr;
}
    _sigfault_t _sigfault;
    struct _sigpoll_t
{
    c_long si_band;
    int si_fd;
}
    _sigpoll_t _sigpoll;
}
    _sifields_t _sifields;
}
    enum 
{
SI_ASYNCNL = -60,
SI_TKILL = -6,
SI_SIGIO,
SI_ASYNCIO,
SI_MESGQ,
SI_TIMER,
SI_QUEUE,
SI_USER,
SI_KERNEL = 128,
}
    int kill(pid_t, int);
    int sigaction(int, in sigaction_t*, sigaction_t*);
    int sigaddset(sigset_t*, int);
    int sigdelset(sigset_t*, int);
    int sigemptyset(sigset_t*);
    int sigfillset(sigset_t*);
    int sigismember(in sigset_t*, int);
    int sigpending(sigset_t*);
    int sigprocmask(int, in sigset_t*, sigset_t*);
    int sigsuspend(in sigset_t*);
    int sigwait(in sigset_t*, int*);
}
else
{
    version (OSX)
{
    alias uint sigset_t;
    struct siginfo_t
{
    int si_signo;
    int si_errno;
    int si_code;
    pid_t si_pid;
    uid_t si_uid;
    int si_status;
    void* si_addr;
    sigval si_value;
    int si_band;
    uint[7] pad;
}
    int kill(pid_t, int);
    int sigaction(int, in sigaction_t*, sigaction_t*);
    int sigaddset(sigset_t*, int);
    int sigdelset(sigset_t*, int);
    int sigemptyset(sigset_t*);
    int sigfillset(sigset_t*);
    int sigismember(in sigset_t*, int);
    int sigpending(sigset_t*);
    int sigprocmask(int, in sigset_t*, sigset_t*);
    int sigsuspend(in sigset_t*);
    int sigwait(in sigset_t*, int*);
}
else
{
    version (FreeBSD)
{
    struct sigset_t
{
    uint[4] __bits;
}
    struct siginfo_t
{
    int si_signo;
    int si_errno;
    int si_code;
    pid_t si_pid;
    uid_t si_uid;
    int si_status;
    void* si_addr;
    sigval si_value;
    union __reason
{
    struct __fault
{
    int _trapno;
}
    __fault _fault;
    struct __timer
{
    int _timerid;
    int _overrun;
}
    __timer _timer;
    struct __mesgq
{
    int _mqd;
}
    __mesgq _mesgq;
    struct __poll
{
    c_long _band;
}
    __poll _poll;
    struct ___spare___
{
    c_long __spare1__;
    int[7] __spare2__;
}
    ___spare___ __spare__;
}
    __reason _reason;
}
    int kill(pid_t, int);
    int sigaction(int, in sigaction_t*, sigaction_t*);
    int sigaddset(sigset_t*, int);
    int sigdelset(sigset_t*, int);
    int sigemptyset(sigset_t*);
    int sigfillset(sigset_t*);
    int sigismember(in sigset_t*, int);
    int sigpending(sigset_t*);
    int sigprocmask(int, in sigset_t*, sigset_t*);
    int sigsuspend(in sigset_t*);
    int sigwait(in sigset_t*, int*);
}
}
}
    version (linux)
{
    enum SIGPOLL = 29;
    enum SIGPROF = 27;
    enum SIGSYS = 31;
    enum SIGTRAP = 5;
    enum SIGVTALRM = 26;
    enum SIGXCPU = 24;
    enum SIGXFSZ = 25;
    enum SA_ONSTACK = 134217728;
    enum SA_RESETHAND = -2147483648u;
    enum SA_RESTART = 268435456;
    enum SA_SIGINFO = 4;
    enum SA_NOCLDWAIT = 2;
    enum SA_NODEFER = 1073741824;
    enum SS_ONSTACK = 1;
    enum SS_DISABLE = 2;
    enum MINSIGSTKSZ = 2048;
    enum SIGSTKSZ = 8192;
    struct stack_t
{
    void* ss_sp;
    int ss_flags;
    size_t ss_size;
}
    struct sigstack
{
    void* ss_sp;
    int ss_onstack;
}
    enum 
{
ILL_ILLOPC = 1,
ILL_ILLOPN,
ILL_ILLADR,
ILL_ILLTRP,
ILL_PRVOPC,
ILL_PRVREG,
ILL_COPROC,
ILL_BADSTK,
}
    enum 
{
FPE_INTDIV = 1,
FPE_INTOVF,
FPE_FLTDIV,
FPE_FLTOVF,
FPE_FLTUND,
FPE_FLTRES,
FPE_FLTINV,
FPE_FLTSUB,
}
    enum 
{
SEGV_MAPERR = 1,
SEGV_ACCERR,
}
    enum 
{
BUS_ADRALN = 1,
BUS_ADRERR,
BUS_OBJERR,
}
    enum 
{
TRAP_BRKPT = 1,
TRAP_TRACE,
}
    enum 
{
CLD_EXITED = 1,
CLD_KILLED,
CLD_DUMPED,
CLD_TRAPPED,
CLD_STOPPED,
CLD_CONTINUED,
}
    enum 
{
POLL_IN = 1,
POLL_OUT,
POLL_MSG,
POLL_ERR,
POLL_PRI,
POLL_HUP,
}
    sigfn_t bsd_signal(int sig, sigfn_t func);
    sigfn_t sigset(int sig, sigfn_t func);
    int killpg(pid_t, int);
    int sigaltstack(in stack_t*, stack_t*);
    int sighold(int);
    int sigignore(int);
    int siginterrupt(int, int);
    int sigpause(int);
    int sigrelse(int);
}
else
{
    version (OSX)
{
    enum SIGPOLL = 7;
    enum SIGPROF = 27;
    enum SIGSYS = 12;
    enum SIGTRAP = 5;
    enum SIGVTALRM = 26;
    enum SIGXCPU = 24;
    enum SIGXFSZ = 25;
    enum SA_ONSTACK = 1;
    enum SA_RESETHAND = 4;
    enum SA_RESTART = 2;
    enum SA_SIGINFO = 64;
    enum SA_NOCLDWAIT = 32;
    enum SA_NODEFER = 16;
    enum SS_ONSTACK = 1;
    enum SS_DISABLE = 4;
    enum MINSIGSTKSZ = 32768;
    enum SIGSTKSZ = 131072;
    struct stack_t
{
    void* ss_sp;
    size_t ss_size;
    int ss_flags;
}
    struct sigstack
{
    void* ss_sp;
    int ss_onstack;
}
    enum ILL_ILLOPC = 1;
    enum ILL_ILLOPN = 4;
    enum ILL_ILLADR = 5;
    enum ILL_ILLTRP = 2;
    enum ILL_PRVOPC = 3;
    enum ILL_PRVREG = 6;
    enum ILL_COPROC = 7;
    enum ILL_BADSTK = 8;
    enum FPE_INTDIV = 7;
    enum FPE_INTOVF = 8;
    enum FPE_FLTDIV = 1;
    enum FPE_FLTOVF = 2;
    enum FPE_FLTUND = 3;
    enum FPE_FLTRES = 4;
    enum FPE_FLTINV = 5;
    enum FPE_FLTSUB = 6;
    enum 
{
SEGV_MAPERR = 1,
SEGV_ACCERR,
}
    enum 
{
BUS_ADRALN = 1,
BUS_ADRERR,
BUS_OBJERR,
}
    enum 
{
TRAP_BRKPT = 1,
TRAP_TRACE,
}
    enum 
{
CLD_EXITED = 1,
CLD_KILLED,
CLD_DUMPED,
CLD_TRAPPED,
CLD_STOPPED,
CLD_CONTINUED,
}
    enum 
{
POLL_IN = 1,
POLL_OUT,
POLL_MSG,
POLL_ERR,
POLL_PRI,
POLL_HUP,
}
    sigfn_t bsd_signal(int sig, sigfn_t func);
    sigfn_t sigset(int sig, sigfn_t func);
    int killpg(pid_t, int);
    int sigaltstack(in stack_t*, stack_t*);
    int sighold(int);
    int sigignore(int);
    int siginterrupt(int, int);
    int sigpause(int);
    int sigrelse(int);
}
else
{
    version (FreeBSD)
{
    enum SIGPROF = 27;
    enum SIGSYS = 12;
    enum SIGTRAP = 5;
    enum SIGVTALRM = 26;
    enum SIGXCPU = 24;
    enum SIGXFSZ = 25;
    enum 
{
SA_ONSTACK = 1,
SA_RESTART = 2,
SA_RESETHAND = 4,
SA_NODEFER = 16,
SA_NOCLDWAIT = 32,
SA_SIGINFO = 64,
}
    enum 
{
SS_ONSTACK = 1,
SS_DISABLE = 4,
}
    enum MINSIGSTKSZ = 512 * 4;
    enum SIGSTKSZ = MINSIGSTKSZ + 32768;
    struct stack_t
{
    void* ss_sp;
    size_t ss_size;
    int ss_flags;
}
    struct sigstack
{
    void* ss_sp;
    int ss_onstack;
}
    enum 
{
ILL_ILLOPC = 1,
ILL_ILLOPN,
ILL_ILLADR,
ILL_ILLTRP,
ILL_PRVOPC,
ILL_PRVREG,
ILL_COPROC,
ILL_BADSTK,
}
    enum 
{
BUS_ADRALN = 1,
BUS_ADRERR,
BUS_OBJERR,
}
    enum 
{
SEGV_MAPERR = 1,
SEGV_ACCERR,
}
    enum 
{
FPE_INTOVF = 1,
FPE_INTDIV,
FPE_FLTDIV,
FPE_FLTOVF,
FPE_FLTUND,
FPE_FLTRES,
FPE_FLTINV,
FPE_FLTSUB,
}
    enum 
{
TRAP_BRKPT = 1,
TRAP_TRACE,
}
    enum 
{
CLD_EXITED = 1,
CLD_KILLED,
CLD_DUMPED,
CLD_TRAPPED,
CLD_STOPPED,
CLD_CONTINUED,
}
    enum 
{
POLL_IN = 1,
POLL_OUT,
POLL_MSG,
POLL_ERR,
POLL_PRI,
POLL_HUP,
}
    sigfn_t sigset(int sig, sigfn_t func);
    int killpg(pid_t, int);
    int sigaltstack(in stack_t*, stack_t*);
    int sighold(int);
    int sigignore(int);
    int siginterrupt(int, int);
    int sigpause(int);
    int sigrelse(int);
}
}
}
    version (linux)
{
    struct timespec
{
    time_t tv_sec;
    c_long tv_nsec;
}
}
else
{
    version (OSX)
{
    struct timespec
{
    time_t tv_sec;
    c_long tv_nsec;
}
}
else
{
    version (FreeBSD)
{
    struct timespec
{
    time_t tv_sec;
    c_long tv_nsec;
}
}
}
}
    version (linux)
{
    private enum __SIGEV_MAX_SIZE = 64;

    static if(false)
{
    private enum __SIGEV_PAD_SIZE = __SIGEV_MAX_SIZE / (int).sizeof - 4;

}
else
{
    private enum __SIGEV_PAD_SIZE = __SIGEV_MAX_SIZE / (int).sizeof - 3;

}
    struct sigevent
{
    sigval sigev_value;
    int sigev_signo;
    int sigev_notify;
    union _sigev_un_t
{
    int[__SIGEV_PAD_SIZE] _pad;
    pid_t _tid;
    struct _sigev_thread_t
{
    void function(sigval) _function;
    void* _attribute;
}
    _sigev_thread_t _sigev_thread;
}
    _sigev_un_t _sigev_un;
}
    int sigqueue(pid_t, int, in sigval);
    int sigtimedwait(in sigset_t*, siginfo_t*, in timespec*);
    int sigwaitinfo(in sigset_t*, siginfo_t*);
}
else
{
    version (FreeBSD)
{
    struct sigevent
{
    int sigev_notify;
    int sigev_signo;
    sigval sigev_value;
    union _sigev_un
{
    lwpid_t _threadid;
    struct _sigev_thread
{
    void function(sigval) _function;
    void* _attribute;
}
    c_long[8] __spare__;
}
}
    int sigqueue(pid_t, int, in sigval);
    int sigtimedwait(in sigset_t*, siginfo_t*, in timespec*);
    int sigwaitinfo(in sigset_t*, siginfo_t*);
}
}
    version (linux)
{
    int pthread_kill(pthread_t, int);
    int pthread_sigmask(int, in sigset_t*, sigset_t*);
}
else
{
    version (OSX)
{
    int pthread_kill(pthread_t, int);
    int pthread_sigmask(int, in sigset_t*, sigset_t*);
}
else
{
    version (FreeBSD)
{
    int pthread_kill(pthread_t, int);
    int pthread_sigmask(int, in sigset_t*, sigset_t*);
}
}
}
}
