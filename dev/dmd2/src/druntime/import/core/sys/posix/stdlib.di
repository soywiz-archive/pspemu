// D import file generated from 'src\core\sys\posix\stdlib.d'
module core.sys.posix.stdlib;
private import core.sys.posix.config;

public import core.stdc.stdlib;

public import core.sys.posix.sys.wait;

extern (C) 
{
    version (linux)
{
    int posix_memalign(void**, size_t, size_t);
}
else
{
    version (FreeBSD)
{
    int posix_memalign(void**, size_t, size_t);
}
}
    version (linux)
{
    int setenv(in char*, in char*, int);
    int unsetenv(in char*);
    void* valloc(size_t);
}
else
{
    version (OSX)
{
    int setenv(in char*, in char*, int);
    int unsetenv(in char*);
    void* valloc(size_t);
}
else
{
    version (FreeBSD)
{
    int setenv(in char*, in char*, int);
    int unsetenv(in char*);
    void* valloc(size_t);
}
}
}
    version (linux)
{
    int rand_r(uint*);
}
else
{
    version (OSX)
{
    int rand_r(uint*);
}
else
{
    version (FreeBSD)
{
    int rand_r(uint*);
}
}
}
    version (linux)
{
    c_long a64l(in char*);
    double drand48();
    char* ecvt(double, int, int*, int*);
    double erand48(ref ushort[3]);
    char* fcvt(double, int, int*, int*);
    char* gcvt(double, int, char*);
    int getsubopt(char**, in char**, char**);
    int grantpt(int);
    char* initstate(uint, char*, size_t);
    c_long jrand48(ref ushort[3]);
    char* l64a(c_long);
    void lcong48(ref ushort[7]);
    c_long lrand48();
    char* mktemp(char*);
    c_long mrand48();
    c_long nrand48(ref ushort[3]);
    int posix_openpt(int);
    char* ptsname(int);
    int putenv(char*);
    c_long random();
    char* realpath(in char*, char*);
    ushort seed48(ref ushort[3]);
    void setkey(in char*);
    char* setstate(in char*);
    void srand48(c_long);
    void srandom(uint);
    int unlockpt(int);
    static if(__USE_LARGEFILE64)
{
    int mkstemp64(char*);
    alias mkstemp64 mkstemp;
}
else
{
    int mkstemp(char*);
}
}
else
{
    version (OSX)
{
    c_long a64l(in char*);
    double drand48();
    char* ecvt(double, int, int*, int*);
    double erand48(ref ushort[3]);
    char* fcvt(double, int, int*, int*);
    char* gcvt(double, int, char*);
    int getsubopt(char**, in char**, char**);
    int grantpt(int);
    char* initstate(uint, char*, size_t);
    c_long jrand48(ref ushort[3]);
    char* l64a(c_long);
    void lcong48(ref ushort[7]);
    c_long lrand48();
    char* mktemp(char*);
    int mkstemp(char*);
    c_long mrand48();
    c_long nrand48(ref ushort[3]);
    int posix_openpt(int);
    char* ptsname(int);
    int putenv(char*);
    c_long random();
    char* realpath(in char*, char*);
    ushort seed48(ref ushort[3]);
    void setkey(in char*);
    char* setstate(in char*);
    void srand48(c_long);
    void srandom(uint);
    int unlockpt(int);
}
else
{
    version (FreeBSD)
{
    c_long a64l(in char*);
    double drand48();
    double erand48(ref ushort[3]);
    int getsubopt(char**, in char**, char**);
    int grantpt(int);
    char* initstate(uint, char*, size_t);
    c_long jrand48(ref ushort[3]);
    char* l64a(c_long);
    void lcong48(ref ushort[7]);
    c_long lrand48();
    char* mktemp(char*);
    int mkstemp(char*);
    c_long mrand48();
    c_long nrand48(ref ushort[3]);
    int posix_openpt(int);
    char* ptsname(int);
    int putenv(char*);
    c_long random();
    char* realpath(in char*, char*);
    ushort seed48(ref ushort[3]);
    void setkey(in char*);
    char* setstate(in char*);
    void srand48(c_long);
    void srandom(uint);
    int unlockpt(int);
}
}
}
}
