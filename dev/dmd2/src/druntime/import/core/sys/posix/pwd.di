// D import file generated from 'src\core\sys\posix\pwd.d'
module core.sys.posix.pwd;
private import core.sys.posix.config;

public import core.sys.posix.sys.types;

extern (C) 
{
    version (linux)
{
    struct passwd
{
    char* pw_name;
    char* pw_passwd;
    uid_t pw_uid;
    gid_t pw_gid;
    char* pw_gecos;
    char* pw_dir;
    char* pw_shell;
}
}
else
{
    version (OSX)
{
    struct passwd
{
    char* pw_name;
    char* pw_passwd;
    uid_t pw_uid;
    gid_t pw_gid;
    time_t pw_change;
    char* pw_class;
    char* pw_gecos;
    char* pw_dir;
    char* pw_shell;
    time_t pw_expire;
}
}
else
{
    version (FreeBSD)
{
    struct passwd
{
    char* pw_name;
    char* pw_passwd;
    uid_t pw_uid;
    gid_t pw_gid;
    time_t pw_change;
    char* pw_class;
    char* pw_gecos;
    char* pw_dir;
    char* pw_shell;
    time_t pw_expire;
    int pw_fields;
}
}
}
}
    version (Posix)
{
    passwd* getpwnam(in char*);
    passwd* getpwuid(uid_t);
}
    version (linux)
{
    int getpwnam_r(in char*, passwd*, char*, size_t, passwd**);
    int getpwuid_r(uid_t, passwd*, char*, size_t, passwd**);
}
else
{
    version (OSX)
{
    int getpwnam_r(in char*, passwd*, char*, size_t, passwd**);
    int getpwuid_r(uid_t, passwd*, char*, size_t, passwd**);
}
else
{
    version (FreeBSD)
{
    int getpwnam_r(in char*, passwd*, char*, size_t, passwd**);
    int getpwuid_r(uid_t, passwd*, char*, size_t, passwd**);
}
}
}
    version (linux)
{
    void endpwent();
    passwd* getpwent();
    void setpwent();
}
else
{
    version (OSX)
{
    void endpwent();
    passwd* getpwent();
    void setpwent();
}
else
{
    version (FreeBSD)
{
    void endpwent();
    passwd* getpwent();
    void setpwent();
}
}
}
}
