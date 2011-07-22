// D import file generated from 'src\core\sys\posix\stdio.d'
module core.sys.posix.stdio;
private import core.sys.posix.config;

public import core.stdc.stdio;

public import core.sys.posix.sys.types;

extern (C) 
{
    version (linux)
{
    static if(__USE_LARGEFILE64)
{
    int fgetpos64(FILE*, fpos_t*);
    alias fgetpos64 fgetpos;
    FILE* fopen64(in char*, in char*);
    alias fopen64 fopen;
    FILE* freopen64(in char*, in char*, FILE*);
    alias freopen64 freopen;
    int fseek64(FILE*, c_long, int);
    alias fseek64 fseek;
    int fsetpos64(FILE*, in fpos_t*);
    alias fsetpos64 fsetpos;
    FILE* tmpfile64();
    alias tmpfile64 tmpfile;
}
else
{
    int fgetpos(FILE*, fpos_t*);
    FILE* fopen(in char*, in char*);
    FILE* freopen(in char*, in char*, FILE*);
    int fseek(FILE*, c_long, int);
    int fsetpos(FILE*, in fpos_t*);
    FILE* tmpfile();
}
}
    version (linux)
{
    enum L_ctermid = 9;
    static if(__USE_FILE_OFFSET64)
{
    int fseeko64(FILE*, off_t, int);
    alias fseeko64 fseeko;
}
else
{
    int fseeko(FILE*, off_t, int);
}
    static if(__USE_LARGEFILE64)
{
    off_t ftello64(FILE*);
    alias ftello64 ftello;
}
else
{
    off_t ftello(FILE*);
}
}
else
{
    version (Posix)
{
    int fseeko(FILE*, off_t, int);
    off_t ftello(FILE*);
}
}
    version (Posix)
{
    char* ctermid(char*);
    FILE* fdopen(int, in char*);
    int fileno(FILE*);
    char* gets(char*);
    int pclose(FILE*);
    FILE* popen(in char*, in char*);
}
    version (linux)
{
    void flockfile(FILE*);
    int ftrylockfile(FILE*);
    void funlockfile(FILE*);
    int getc_unlocked(FILE*);
    int getchar_unlocked();
    int putc_unlocked(int, FILE*);
    int putchar_unlocked(int);
}
    version (linux)
{
    enum P_tmpdir = "/tmp";
    char* tempnam(in char*, in char*);
}
}
