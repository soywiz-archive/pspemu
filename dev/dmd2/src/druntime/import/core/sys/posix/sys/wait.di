// D import file generated from 'src\core\sys\posix\sys\wait.d'
module core.sys.posix.sys.wait;
private import core.sys.posix.config;

public import core.sys.posix.sys.types;

public import core.sys.posix.signal;

extern (C) 
{
    version (linux)
{
    enum WNOHANG = 1;
    enum WUNTRACED = 2;
    private 
{
    enum __W_CONTINUED = 65535;
    extern (D) int __WTERMSIG(int status)
{
return status & 127;
}

}
    extern (D) int WEXITSTATUS(int status)
{
return (status & 65280) >> 8;
}

    extern (D) int WIFCONTINUED(int status)
{
return status == __W_CONTINUED;
}

    extern (D) bool WIFEXITED(int status)
{
return __WTERMSIG(status) == 0;
}

    extern (D) bool WIFSIGNALED(int status)
{
return cast(byte)((status & 127) + 1) >> 1 > 0;
}

    extern (D) bool WIFSTOPPED(int status)
{
return (status & 255) == 127;
}

    extern (D) int WSTOPSIG(int status)
{
return WEXITSTATUS(status);
}

    extern (D) int WTERMSIG(int status)
{
return status & 127;
}

}
else
{
    version (OSX)
{
    enum WNOHANG = 1;
    enum WUNTRACED = 2;
    private enum _WSTOPPED = 127;

    extern (D) int _WSTATUS(int status)
{
return status & 127;
}

    extern (D) int WEXITSTATUS(int status)
{
return status >> 8;
}

    extern (D) int WIFCONTINUED(int status)
{
return status == 19;
}

    extern (D) bool WIFEXITED(int status)
{
return _WSTATUS(status) == 0;
}

    extern (D) bool WIFSIGNALED(int status)
{
return _WSTATUS(status) != _WSTOPPED && _WSTATUS(status) != 0;
}

    extern (D) bool WIFSTOPPED(int status)
{
return _WSTATUS(status) == _WSTOPPED;
}

    extern (D) int WSTOPSIG(int status)
{
return status >> 8;
}

    extern (D) int WTERMSIG(int status)
{
return _WSTATUS(status);
}

}
else
{
    version (FreeBSD)
{
    enum WNOHANG = 1;
    enum WUNTRACED = 2;
    private enum _WSTOPPED = 127;

    extern (D) int _WSTATUS(int status)
{
return status & 127;
}

    extern (D) int WEXITSTATUS(int status)
{
return status >> 8;
}

    extern (D) int WIFCONTINUED(int status)
{
return status == 19;
}

    extern (D) bool WIFEXITED(int status)
{
return _WSTATUS(status) == 0;
}

    extern (D) bool WIFSIGNALED(int status)
{
return _WSTATUS(status) != _WSTOPPED && _WSTATUS(status) != 0;
}

    extern (D) bool WIFSTOPPED(int status)
{
return _WSTATUS(status) == _WSTOPPED;
}

    extern (D) int WSTOPSIG(int status)
{
return status >> 8;
}

    extern (D) int WTERMSIG(int status)
{
return _WSTATUS(status);
}

}
}
}
    version (Posix)
{
    pid_t wait(int*);
    pid_t waitpid(pid_t, int*, int);
}
    version (linux)
{
    enum WEXITED = 4;
    enum WSTOPPED = 2;
    enum WCONTINUED = 8;
    enum WNOWAIT = 16777216;
    enum idtype_t 
{
P_ALL,
P_PID,
P_PGID,
}
    int waitid(idtype_t, id_t, siginfo_t*, int);
}
else
{
    version (OSX)
{
    enum WEXITED = 4;
    enum WSTOPPED = 8;
    enum WCONTINUED = 16;
    enum WNOWAIT = 32;
    enum idtype_t 
{
P_ALL,
P_PID,
P_PGID,
}
    int waitid(idtype_t, id_t, siginfo_t*, int);
}
else
{
    version (FreeBSD)
{
    enum WSTOPPED = WUNTRACED;
    enum WCONTINUED = 4;
    enum WNOWAIT = 8;
}
}
}
}
