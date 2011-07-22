// D import file generated from 'src\core\runtime.d'
module core.runtime;
private 
{
    extern (C) bool rt_isHalting();

    alias bool function() ModuleUnitTester;
    alias bool function(Object) CollectHandler;
    alias Throwable.TraceInfo function(void* ptr = null) TraceHandler;
    extern (C) void rt_setCollectHandler(CollectHandler h);

    extern (C) CollectHandler rt_getCollectHandler();

    extern (C) void rt_setTraceHandler(TraceHandler h);

    extern (C) TraceHandler rt_getTraceHandler();

    alias void delegate(Throwable) ExceptionHandler;
    extern (C) bool rt_init(ExceptionHandler dg = null);

    extern (C) bool rt_term(ExceptionHandler dg = null);

    extern (C) void* rt_loadLibrary(in char[] name);

    extern (C) bool rt_unloadLibrary(void* ptr);

    extern (C) string[] rt_args();

    version (linux)
{
    import core.demangle;
    import core.stdc.stdlib;
    import core.stdc.string;
    extern (C) int backtrace(void**, size_t);

    extern (C) char** backtrace_symbols(void**, int);

    extern (C) void backtrace_symbols_fd(void**, int, int);

    import core.sys.posix.signal;
}
else
{
    version (OSX)
{
    import core.demangle;
    import core.stdc.stdlib;
    import core.stdc.string;
    extern (C) int backtrace(void**, size_t);

    extern (C) char** backtrace_symbols(void**, int);

    extern (C) void backtrace_symbols_fd(void**, int, int);

    import core.sys.posix.signal;
}
else
{
    version (Windows)
{
    import core.sys.windows.stacktrace;
}
}
}
    version (Windows)
{
    import core.sys.windows.windows;
}
else
{
    version (Posix)
{
    import core.sys.posix.unistd;
}
}
}
static this();
struct Runtime
{
    static bool initialize(ExceptionHandler dg = null)
{
return rt_init(dg);
}

    static bool terminate(ExceptionHandler dg = null)
{
return rt_term(dg);
}

    deprecated static @property bool isHalting()
{
return rt_isHalting();
}


    static @property string[] args()
{
return rt_args();
}

    static void* loadLibrary(in char[] name)
{
return rt_loadLibrary(name);
}

    static bool unloadLibrary(void* p)
{
return rt_unloadLibrary(p);
}

    static @property void traceHandler(TraceHandler h)
{
rt_setTraceHandler(h);
}

    static @property TraceHandler traceHandler()
{
return rt_getTraceHandler();
}

    static @property void collectHandler(CollectHandler h)
{
rt_setCollectHandler(h);
}

    static @property CollectHandler collectHandler()
{
return rt_getCollectHandler();
}

    static @property void moduleUnitTester(ModuleUnitTester h)
{
sm_moduleUnitTester = h;
}

    static @property ModuleUnitTester moduleUnitTester()
{
return sm_moduleUnitTester;
}

    private __gshared ModuleUnitTester sm_moduleUnitTester = null;


}
extern (C) bool runModuleUnitTests();

Throwable.TraceInfo defaultTraceHandler(void* ptr = null);
