// D import file generated from 'src\core\stdc\string.d'
module core.stdc.string;
private import core.stdc.stddef;

extern (C) nothrow @system 
{
    pure void* memchr(in void* s, int c, size_t n);

    pure int memcmp(in void* s1, in void* s2, size_t n);

    void* memcpy(void* s1, in void* s2, size_t n);
    void* memmove(void* s1, in void* s2, size_t n);
    void* memset(void* s, int c, size_t n);
    char* strcpy(char* s1, in char* s2);
    char* strncpy(char* s1, in char* s2, size_t n);
    char* strcat(char* s1, in char* s2);
    char* strncat(char* s1, in char* s2, size_t n);
    pure int strcmp(in char* s1, in char* s2);

    int strcoll(in char* s1, in char* s2);
    pure int strncmp(in char* s1, in char* s2, size_t n);

    size_t strxfrm(char* s1, in char* s2, size_t n);
    pure char* strchr(in char* s, int c);

    pure size_t strcspn(in char* s1, in char* s2);

    char* strpbrk(in char* s1, in char* s2);
    pure char* strrchr(in char* s, int c);

    pure size_t strspn(in char* s1, in char* s2);

    pure char* strstr(in char* s1, in char* s2);

    char* strtok(char* s1, in char* s2);
    char* strerror(int errnum);
    pure size_t strlen(in char* s);

    char* strdup(in char* s);
}


