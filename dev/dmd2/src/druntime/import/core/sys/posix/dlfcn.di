// D import file generated from 'src\core\sys\posix\dlfcn.d'
module core.sys.posix.dlfcn;
private import core.sys.posix.config;

extern (C) version (linux)
{
    enum RTLD_LAZY = 1;
    enum RTLD_NOW = 2;
    enum RTLD_GLOBAL = 256;
    enum RTLD_LOCAL = 0;
    int dlclose(void*);
    char* dlerror();
    void* dlopen(in char*, int);
    void* dlsym(void*, in char*);
}
else
{
    version (OSX)
{
    enum RTLD_LAZY = 1;
    enum RTLD_NOW = 2;
    enum RTLD_GLOBAL = 256;
    enum RTLD_LOCAL = 0;
    int dlclose(void*);
    char* dlerror();
    void* dlopen(in char*, int);
    void* dlsym(void*, in char*);
}
else
{
    version (FreeBSD)
{
    enum RTLD_LAZY = 1;
    enum RTLD_NOW = 2;
    enum RTLD_GLOBAL = 256;
    enum RTLD_LOCAL = 0;
    int dlclose(void*);
    char* dlerror();
    void* dlopen(in char*, int);
    void* dlsym(void*, in char*);
}
}
}

