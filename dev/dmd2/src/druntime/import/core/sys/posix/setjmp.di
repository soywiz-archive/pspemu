// D import file generated from 'src\core\sys\posix\setjmp.d'
module core.sys.posix.setjmp;
private import core.sys.posix.config;

private import core.sys.posix.signal;

extern (C) 
{
    version (linux)
{
    version (X86_64)
{
    alias long[8] __jmp_buf;
}
else
{
    version (X86)
{
    alias int[6] __jmp_buf;
}
else
{
    version (SPARC)
{
    alias int[3] __jmp_buf;
}
}
}
    struct __jmp_buf_tag
{
    __jmp_buf __jmpbuf;
    int __mask_was_saved;
    sigset_t __saved_mask;
}
    alias __jmp_buf_tag[1] jmp_buf;
    alias _setjmp setjmp;
    void longjmp(ref jmp_buf, int);
}
else
{
    version (FreeBSD)
{
    version (X86)
{
    enum _JBLEN = 11;
    struct _jmp_buf
{
    int[_JBLEN + 1] _jb;
}
}
else
{
    version (X86_64)
{
    enum _JBLEN = 12;
    struct _jmp_buf
{
    c_long[_JBLEN] _jb;
}
}
else
{
    version (SPARC)
{
    enum _JBLEN = 5;
    struct _jmp_buf
{
    c_long[_JBLEN + 1] _jb;
}
}
else
{
    static assert(0);
}
}
}
    alias _jmp_buf[1] jmp_buf;
    int setjmp(ref jmp_buf);
    void longjmp(ref jmp_buf, int);
}
}
    version (linux)
{
    alias jmp_buf sigjmp_buf;
    int __sigsetjmp(sigjmp_buf, int);
    alias __sigsetjmp sigsetjmp;
    void siglongjmp(sigjmp_buf, int);
}
else
{
    version (FreeBSD)
{
    version (X86)
{
    struct _sigjmp_buf
{
    int[_JBLEN + 1] _ssjb;
}
}
else
{
    version (X86_64)
{
    struct _sigjmp_buf
{
    c_long[_JBLEN] _sjb;
}
}
else
{
    version (SPARC)
{
    enum _JBLEN = 5;
    enum _JB_FP = 0;
    enum _JB_PC = 1;
    enum _JB_SP = 2;
    enum _JB_SIGMASK = 3;
    enum _JB_SIGFLAG = 5;
    struct _sigjmp_buf
{
    c_long[_JBLEN + 1] _sjb;
}
}
else
{
    static assert(0);
}
}
}
    alias _sigjmp_buf[1] sigjmp_buf;
    int sigsetjmp(ref sigjmp_buf);
    void siglongjmp(ref sigjmp_buf, int);
}
}
    version (linux)
{
    int _setjmp(ref jmp_buf);
    void _longjmp(ref jmp_buf, int);
}
else
{
    version (FreeBSD)
{
    int _setjmp(ref jmp_buf);
    void _longjmp(ref jmp_buf, int);
}
}
}
