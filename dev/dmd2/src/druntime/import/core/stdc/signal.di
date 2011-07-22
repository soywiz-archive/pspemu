// D import file generated from 'src\core\stdc\signal.d'
module core.stdc.signal;
extern (C) 
{
    alias int sig_atomic_t;
    private alias void function(int) sigfn_t;

    version (Posix)
{
    enum SIG_ERR = cast(sigfn_t)-1;
    enum SIG_DFL = cast(sigfn_t)0;
    enum SIG_IGN = cast(sigfn_t)1;
    enum SIGABRT = 6;
    enum SIGFPE = 8;
    enum SIGILL = 4;
    enum SIGINT = 2;
    enum SIGSEGV = 11;
    enum SIGTERM = 15;
}
else
{
    enum SIG_ERR = cast(sigfn_t)-1;
    enum SIG_DFL = cast(sigfn_t)0;
    enum SIG_IGN = cast(sigfn_t)1;
    enum SIGABRT = 22;
    enum SIGFPE = 8;
    enum SIGILL = 4;
    enum SIGINT = 2;
    enum SIGSEGV = 11;
    enum SIGTERM = 15;
}
    sigfn_t signal(int sig, sigfn_t func);
    int raise(int sig);
}
